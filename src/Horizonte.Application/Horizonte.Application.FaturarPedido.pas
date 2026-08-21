unit Horizonte.Application.FaturarPedido;

interface

uses
  Horizonte.Application.Ports,
  Horizonte.Domain.Types;

type
  TFaturarPedido = class
  private
    FPedidos: IPedidoRepository;
    FCredito: ICreditoService;
    FEstoque: IEstoqueService;
    FFiscal: IIntegracaoFiscal;
    FUnitOfWork: IUnitOfWork;
  public
    constructor Create(
      const APedidos: IPedidoRepository;
      const ACredito: ICreditoService;
      const AEstoque: IEstoqueService;
      const AFiscal: IIntegracaoFiscal;
      const AUnitOfWork: IUnitOfWork);
    function Execute(const ACommand: TFaturarPedidoCommand): TFaturamentoResult;
  end;

implementation

uses
  System.SysUtils,
  Horizonte.Domain.Pedido;

constructor TFaturarPedido.Create(
  const APedidos: IPedidoRepository;
  const ACredito: ICreditoService;
  const AEstoque: IEstoqueService;
  const AFiscal: IIntegracaoFiscal;
  const AUnitOfWork: IUnitOfWork);
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
end;

function TFaturarPedido.Execute(
  const ACommand: TFaturarPedidoCommand): TFaturamentoResult;
var
  LPedido: TPedido;
  LFaturaId: Integer;
  LReservado: Boolean;
begin
  LPedido := FPedidos.ObterPorId(ACommand.PedidoId);
  if not Assigned(LPedido) then
    Exit(TFaturamentoResult.Create(
      fsPedidoNaoEncontrado,
      'Pedido não encontrado.'));

  try
    if LPedido.Status <> psAprovado then
      Exit(TFaturamentoResult.Create(
        fsPedidoNaoAprovado,
        'O pedido ainda não está aprovado.'));

    if not FCredito.PossuiCredito(LPedido.ClienteId, LPedido.ValorTotal) then
      Exit(TFaturamentoResult.Create(
        fsCreditoRecusado,
        'Crédito insuficiente para o faturamento.'));

    LReservado := FEstoque.Reservar(LPedido.Id);
    if not LReservado then
      Exit(TFaturamentoResult.Create(
        fsEstoqueIndisponivel,
        'Não foi possível reservar o estoque.'));

    FUnitOfWork.BeginTransaction;
    try
      try
        LFaturaId := FFiscal.Emitir(LPedido, ACommand.UsuarioId, ACommand.Instante);
        LPedido.MarcarComoFaturado(LFaturaId);
        FPedidos.Atualizar(LPedido);
        FUnitOfWork.Commit;
        Result := TFaturamentoResult.Create(
          fsSucesso,
          'Pedido faturado com sucesso.',
          LFaturaId);
      except
        FUnitOfWork.Rollback;
        FEstoque.Liberar(LPedido.Id);
        Result := TFaturamentoResult.Create(
          fsFalhaFiscal,
          'O faturamento falhou e as alterações locais foram desfeitas.');
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
