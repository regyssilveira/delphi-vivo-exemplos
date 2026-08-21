unit Horizonte.Infrastructure.InMemory;

interface

uses
  System.Generics.Collections,
  Horizonte.Application.Ports,
  Horizonte.Domain.Pedido,
  Horizonte.Domain.Types;

type
  TPedidoRepositoryInMemory = class(TInterfacedObject, IPedidoRepository)
  private
    FPedidos: TObjectDictionary<Integer, TPedido>;
    function Copiar(const APedido: TPedido): TPedido;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Adicionar(const APedido: TPedido);
    function ObterPorId(const APedidoId: Integer): TPedido;
    procedure Atualizar(const APedido: TPedido);
  end;

  TCreditoServiceFixo = class(TInterfacedObject, ICreditoService)
  private
    FAprovado: Boolean;
  public
    constructor Create(const AAprovado: Boolean = True);
    function PossuiCredito(
      const AClienteId: Integer;
      const AValor: Currency): Boolean;
  end;

  TEstoqueServiceFixo = class(TInterfacedObject, IEstoqueService,
    IEstoqueApplication)
  private
    FDisponivel: Boolean;
    FReservas: TList<Integer>;
  public
    constructor Create(const ADisponivel: Boolean = True);
    destructor Destroy; override;
    function Reservar(const APedidoId: Integer): Boolean;
    procedure Liberar(const APedidoId: Integer);
    function EstaReservado(const APedidoId: Integer): Boolean;
    function ConsultarDisponibilidade(
      const AProdutoId: Integer;
      const AFilialId: Integer): TDisponibilidadeEstoque;
    procedure ReservarPedido(const APedidoId: Integer);
  end;

  TIntegracaoFiscalSimulada = class(TInterfacedObject, IIntegracaoFiscal)
  private
    FProximaFaturaId: Integer;
    FDeveFalhar: Boolean;
  public
    constructor Create(
      const APrimeiraFaturaId: Integer = 1000;
      const ADeveFalhar: Boolean = False);
    function Emitir(
      const APedido: TPedido;
      const AUsuarioId: Integer;
      const AInstante: TDateTime): Integer;
  end;

  TUnitOfWorkInMemory = class(TInterfacedObject, IUnitOfWork)
  private
    FAtiva: Boolean;
    FCommits: Integer;
    FRollbacks: Integer;
  public
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    property Ativa: Boolean read FAtiva;
    property Commits: Integer read FCommits;
    property Rollbacks: Integer read FRollbacks;
  end;

implementation

uses
  System.SysUtils;

constructor TPedidoRepositoryInMemory.Create;
begin
  inherited Create;
  FPedidos := TObjectDictionary<Integer, TPedido>.Create([doOwnsValues]);
end;

destructor TPedidoRepositoryInMemory.Destroy;
begin
  FPedidos.Free;
  inherited Destroy;
end;

function TPedidoRepositoryInMemory.Copiar(const APedido: TPedido): TPedido;
begin
  if APedido.Status = psFaturado then
  begin
    Result := TPedido.Create(
      APedido.Id,
      APedido.ClienteId,
      APedido.ValorTotal,
      psAprovado,
      APedido.EmpresaId,
      APedido.FilialId,
      APedido.Numero,
      APedido.AtualizadoEm);
    Result.MarcarComoFaturado(APedido.FaturaId);
  end
  else
    Result := TPedido.Create(
      APedido.Id,
      APedido.ClienteId,
      APedido.ValorTotal,
      APedido.Status,
      APedido.EmpresaId,
      APedido.FilialId,
      APedido.Numero,
      APedido.AtualizadoEm);
end;

procedure TPedidoRepositoryInMemory.Adicionar(const APedido: TPedido);
begin
  FPedidos.AddOrSetValue(APedido.Id, Copiar(APedido));
end;

function TPedidoRepositoryInMemory.ObterPorId(const APedidoId: Integer): TPedido;
var
  LPedido: TPedido;
begin
  if FPedidos.TryGetValue(APedidoId, LPedido) then
    Exit(Copiar(LPedido));
  Result := nil;
end;

procedure TPedidoRepositoryInMemory.Atualizar(const APedido: TPedido);
begin
  if not FPedidos.ContainsKey(APedido.Id) then
    raise EInvalidOpException.Create('Pedido não cadastrado no repositório.');
  FPedidos.AddOrSetValue(APedido.Id, Copiar(APedido));
end;

constructor TCreditoServiceFixo.Create(const AAprovado: Boolean);
begin
  inherited Create;
  FAprovado := AAprovado;
end;

function TCreditoServiceFixo.PossuiCredito(
  const AClienteId: Integer;
  const AValor: Currency): Boolean;
begin
  Result := FAprovado and (AClienteId > 0) and (AValor > 0);
end;

constructor TEstoqueServiceFixo.Create(const ADisponivel: Boolean);
begin
  inherited Create;
  FDisponivel := ADisponivel;
  FReservas := TList<Integer>.Create;
end;

destructor TEstoqueServiceFixo.Destroy;
begin
  FReservas.Free;
  inherited Destroy;
end;

function TEstoqueServiceFixo.Reservar(const APedidoId: Integer): Boolean;
begin
  Result := FDisponivel;
  if Result and not FReservas.Contains(APedidoId) then
    FReservas.Add(APedidoId);
end;

procedure TEstoqueServiceFixo.Liberar(const APedidoId: Integer);
begin
  FReservas.Remove(APedidoId);
end;

function TEstoqueServiceFixo.EstaReservado(const APedidoId: Integer): Boolean;
begin
  Result := FReservas.Contains(APedidoId);
end;

function TEstoqueServiceFixo.ConsultarDisponibilidade(
  const AProdutoId: Integer;
  const AFilialId: Integer): TDisponibilidadeEstoque;
begin
  Result.ProdutoId := AProdutoId;
  Result.FilialId := AFilialId;
  if FDisponivel then
    Result.QuantidadeDisponivel := 42
  else
    Result.QuantidadeDisponivel := 0;
  Result.Disponivel := FDisponivel;
end;

procedure TEstoqueServiceFixo.ReservarPedido(const APedidoId: Integer);
begin
  if not Reservar(APedidoId) then
    raise EInvalidOpException.Create('Estoque indisponível para o pedido.');
end;

constructor TIntegracaoFiscalSimulada.Create(
  const APrimeiraFaturaId: Integer;
  const ADeveFalhar: Boolean);
begin
  inherited Create;
  FProximaFaturaId := APrimeiraFaturaId;
  FDeveFalhar := ADeveFalhar;
end;

function TIntegracaoFiscalSimulada.Emitir(
  const APedido: TPedido;
  const AUsuarioId: Integer;
  const AInstante: TDateTime): Integer;
begin
  if FDeveFalhar then
    raise EInvalidOpException.Create('Falha fiscal simulada.');
  if not Assigned(APedido) or (AUsuarioId <= 0) or (AInstante <= 0) then
    raise EArgumentException.Create('Dados insuficientes para emissão fiscal.');

  Result := FProximaFaturaId;
  Inc(FProximaFaturaId);
end;

procedure TUnitOfWorkInMemory.BeginTransaction;
begin
  if FAtiva then
    raise EInvalidOpException.Create('Já existe uma transação ativa.');
  FAtiva := True;
end;

procedure TUnitOfWorkInMemory.Commit;
begin
  if not FAtiva then
    raise EInvalidOpException.Create('Não existe transação ativa.');
  FAtiva := False;
  Inc(FCommits);
end;

procedure TUnitOfWorkInMemory.Rollback;
begin
  if FAtiva then
  begin
    FAtiva := False;
    Inc(FRollbacks);
  end;
end;

end.
