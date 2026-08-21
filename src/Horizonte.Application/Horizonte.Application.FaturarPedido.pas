unit Horizonte.Application.FaturarPedido;

interface

uses
  Horizonte.Application.Observability,
  Horizonte.Application.Ports,
  Horizonte.Domain.Types;

type
  TPedidoFaturamentoService = class
  private
    FPedidos: IPedidoRepository;
    FCredito: ICreditoService;
    FEstoque: IEstoqueService;
    FFiscal: IIntegracaoFiscal;
    FUnitOfWork: IUnitOfWork;
    FLogger: IApplicationLogger;
    function ContextFromCommand(
      const ACommand: TFaturarPedidoCommand): TOperationContext;
    procedure LogResult(
      const AContext: TOperationContext;
      const APedidoId: Integer;
      const AResult: TFaturamentoResult;
      const ADurationMs: UInt64);
  public
    constructor Create(
      const APedidos: IPedidoRepository;
      const ACredito: ICreditoService;
      const AEstoque: IEstoqueService;
      const AFiscal: IIntegracaoFiscal;
      const AUnitOfWork: IUnitOfWork;
      const ALogger: IApplicationLogger = nil);
    function Execute(const ACommand: TFaturarPedidoCommand): TFaturamentoResult;
  end;

  TFaturarPedido = TPedidoFaturamentoService;

implementation

uses
  System.SysUtils,
  Winapi.Windows,
  Horizonte.Domain.Pedido;

constructor TPedidoFaturamentoService.Create(
  const APedidos: IPedidoRepository;
  const ACredito: ICreditoService;
  const AEstoque: IEstoqueService;
  const AFiscal: IIntegracaoFiscal;
  const AUnitOfWork: IUnitOfWork;
  const ALogger: IApplicationLogger);
begin
  inherited Create;
  if not Assigned(APedidos) or not Assigned(ACredito) or
    not Assigned(AEstoque) or not Assigned(AFiscal) or
    not Assigned(AUnitOfWork) then
    raise EArgumentNilException.Create('As dependências do faturamento são obrigatórias.');

  FPedidos := APedidos;
  FCredito := ACredito;
  FEstoque := AEstoque;
  FFiscal := AFiscal;
  FUnitOfWork := AUnitOfWork;
  if Assigned(ALogger) then
    FLogger := ALogger
  else
    FLogger := TNullApplicationLogger.Create;
end;

function TPedidoFaturamentoService.ContextFromCommand(
  const ACommand: TFaturarPedidoCommand): TOperationContext;
begin
  if ACommand.CorrelationId.IsEmpty then
    Result := TOperationContext.New(
      ACommand.UsuarioId,
      ACommand.EmpresaId,
      ACommand.FilialId)
  else
    Result := TOperationContext.Create(
      ACommand.CorrelationId,
      ACommand.UsuarioId,
      ACommand.EmpresaId,
      ACommand.FilialId);
end;

procedure TPedidoFaturamentoService.LogResult(
  const AContext: TOperationContext;
  const APedidoId: Integer;
  const AResult: TFaturamentoResult;
  const ADurationMs: UInt64);
begin
  FLogger.Information(
    'pedido.faturamento.concluido',
    AContext,
    [TLogProperty.Create('pedidoId', APedidoId.ToString),
     TLogProperty.Create('status', Ord(AResult.Status).ToString),
     TLogProperty.Create('durationMs', ADurationMs.ToString)]);
end;

function TPedidoFaturamentoService.Execute(
  const ACommand: TFaturarPedidoCommand): TFaturamentoResult;
var
  LPedido: TPedido;
  LFaturaId: Integer;
  LReservado: Boolean;
  LContext: TOperationContext;
  LStartedAt: UInt64;
begin
  LContext := ContextFromCommand(ACommand);
  LStartedAt := GetTickCount64;
  FLogger.Information(
    'pedido.faturamento.iniciado',
    LContext,
    [TLogProperty.Create('pedidoId', ACommand.PedidoId.ToString)]);
  LPedido := FPedidos.ObterPorId(ACommand.PedidoId);
  if not Assigned(LPedido) then
  begin
    Result := TFaturamentoResult.Create(
      fsPedidoNaoEncontrado,
      'Pedido não encontrado.');
    LogResult(LContext, ACommand.PedidoId, Result, GetTickCount64 - LStartedAt);
    Exit;
  end;

  try
    if LPedido.Status <> psAprovado then
    begin
      Result := TFaturamentoResult.Create(
        fsPedidoNaoAprovado,
        'O pedido ainda não está aprovado.');
      LogResult(LContext, LPedido.Id, Result, GetTickCount64 - LStartedAt);
      Exit;
    end;

    if not FCredito.PossuiCredito(LPedido.ClienteId, LPedido.ValorTotal) then
    begin
      Result := TFaturamentoResult.Create(
        fsCreditoRecusado,
        'Crédito insuficiente para o faturamento.');
      LogResult(LContext, LPedido.Id, Result, GetTickCount64 - LStartedAt);
      Exit;
    end;

    LReservado := FEstoque.Reservar(LPedido.Id);
    if not LReservado then
    begin
      Result := TFaturamentoResult.Create(
        fsEstoqueIndisponivel,
        'Não foi possível reservar o estoque.');
      LogResult(LContext, LPedido.Id, Result, GetTickCount64 - LStartedAt);
      Exit;
    end;

    FUnitOfWork.BeginTransaction;
    try
      try
        LFaturaId := FFiscal.Emitir(LPedido, ACommand.UsuarioId, ACommand.Instante);
      except
        on E: Exception do
        begin
          FUnitOfWork.Rollback;
          FEstoque.Liberar(LPedido.Id);
          FLogger.Error(
            'pedido.faturamento.falhou',
            LContext,
            E,
            [TLogProperty.Create('pedidoId', LPedido.Id.ToString),
             TLogProperty.Create('stage', 'emissao_fiscal')]);
          Result := TFaturamentoResult.Create(
            fsFalhaFiscal,
            'A integração fiscal recusou ou não concluiu o faturamento.');
          LogResult(LContext, LPedido.Id, Result, GetTickCount64 - LStartedAt);
          Exit;
        end;
      end;
      try
        LPedido.MarcarComoFaturado(LFaturaId);
        FPedidos.Atualizar(LPedido);
        FUnitOfWork.Commit;
        Result := TFaturamentoResult.Create(
          fsSucesso,
          'Pedido faturado com sucesso.',
          LFaturaId);
        LogResult(LContext, LPedido.Id, Result, GetTickCount64 - LStartedAt);
      except
        on E: Exception do
        begin
          FUnitOfWork.Rollback;
          FEstoque.Liberar(LPedido.Id);
          FLogger.Error(
            'pedido.faturamento.resultado_desconhecido',
            LContext,
            E,
            [TLogProperty.Create('pedidoId', LPedido.Id.ToString),
             TLogProperty.Create('stage', 'persistencia_local'),
             TLogProperty.Create('faturaId', LFaturaId.ToString)]);
          Result := TFaturamentoResult.Create(
            fsResultadoDesconhecido,
            'A emissão fiscal pode ter ocorrido; consulte pelo correlation ID antes de repetir.',
            LFaturaId);
          LogResult(LContext, LPedido.Id, Result, GetTickCount64 - LStartedAt);
        end;
      end;
    except
      FEstoque.Liberar(LPedido.Id);
      raise;
    end;
  finally
    LPedido.Free;
  end;
end;

end.
