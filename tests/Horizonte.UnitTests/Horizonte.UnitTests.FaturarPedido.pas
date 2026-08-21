unit Horizonte.UnitTests.FaturarPedido;

interface

uses
  DUnitX.TestFramework,
  Horizonte.Application.FaturarPedido,
  Horizonte.Application.Ports,
  Horizonte.Infrastructure.InMemory;

type
  [TestFixture]
  TFaturarPedidoTests = class
  private
    FRepositoryObject: TPedidoRepositoryInMemory;
    FEstoqueObject: TEstoqueServiceFixo;
    FUnitOfWorkObject: TUnitOfWorkInMemory;
    FRepository: IPedidoRepository;
    FCredito: ICreditoService;
    FEstoque: IEstoqueService;
    FFiscal: IIntegracaoFiscal;
    FUnitOfWork: IUnitOfWork;
    FService: TFaturarPedido;
    procedure RecriarServico;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure PedidoAprovadoComCreditoEFiscalValido_DeveFaturar;
    [Test]
    procedure CreditoRecusado_NaoDeveAbrirTransacao;
    [Test]
    procedure FalhaFiscal_DeveExecutarRollbackELiberarEstoque;
    [Test]
    procedure PedidoInexistente_DeveRetornarResultadoConhecido;
  end;

implementation

uses
  System.SysUtils,
  Horizonte.Domain.Pedido,
  Horizonte.Domain.Types;

procedure TFaturarPedidoTests.Setup;
var
  LPedido: TPedido;
begin
  FRepositoryObject := TPedidoRepositoryInMemory.Create;
  FRepository := FRepositoryObject;
  FCredito := TCreditoServiceFixo.Create(True);
  FEstoqueObject := TEstoqueServiceFixo.Create(True);
  FEstoque := FEstoqueObject;
  FFiscal := TIntegracaoFiscalSimulada.Create(1000, False);
  FUnitOfWorkObject := TUnitOfWorkInMemory.Create;
  FUnitOfWork := FUnitOfWorkObject;

  LPedido := TPedido.Create(1, 10, 250, psAprovado);
  try
    FRepositoryObject.Adicionar(LPedido);
  finally
    LPedido.Free;
  end;
  RecriarServico;
end;

procedure TFaturarPedidoTests.TearDown;
begin
  FreeAndNil(FService);
  FUnitOfWork := nil;
  FFiscal := nil;
  FEstoque := nil;
  FCredito := nil;
  FRepository := nil;
end;

procedure TFaturarPedidoTests.RecriarServico;
begin
  FreeAndNil(FService);
  FService := TFaturarPedido.Create(
    FRepository,
    FCredito,
    FEstoque,
    FFiscal,
    FUnitOfWork);
end;

procedure TFaturarPedidoTests.PedidoAprovadoComCreditoEFiscalValido_DeveFaturar;
var
  LCommand: TFaturarPedidoCommand;
  LResult: TFaturamentoResult;
  LPedido: TPedido;
begin
  LCommand.PedidoId := 1;
  LCommand.UsuarioId := 7;
  LCommand.Instante := EncodeDate(2026, 8, 20);

  LResult := FService.Execute(LCommand);

  Assert.IsTrue(LResult.Sucesso);
  Assert.AreEqual<Integer>(1000, LResult.FaturaId);
  Assert.AreEqual<Integer>(1, FUnitOfWorkObject.Commits);
  LPedido := FRepository.ObterPorId(1);
  try
    Assert.AreEqual<TPedidoStatus>(psFaturado, LPedido.Status);
  finally
    LPedido.Free;
  end;
end;

procedure TFaturarPedidoTests.CreditoRecusado_NaoDeveAbrirTransacao;
var
  LCommand: TFaturarPedidoCommand;
  LResult: TFaturamentoResult;
begin
  FCredito := TCreditoServiceFixo.Create(False);
  RecriarServico;
  LCommand.PedidoId := 1;
  LCommand.UsuarioId := 7;
  LCommand.Instante := EncodeDate(2026, 8, 20);

  LResult := FService.Execute(LCommand);

  Assert.AreEqual<TFaturamentoStatus>(fsCreditoRecusado, LResult.Status);
  Assert.AreEqual<Integer>(0, FUnitOfWorkObject.Commits);
  Assert.AreEqual<Integer>(0, FUnitOfWorkObject.Rollbacks);
end;

procedure TFaturarPedidoTests.FalhaFiscal_DeveExecutarRollbackELiberarEstoque;
var
  LCommand: TFaturarPedidoCommand;
  LResult: TFaturamentoResult;
begin
  FFiscal := TIntegracaoFiscalSimulada.Create(1000, True);
  RecriarServico;
  LCommand.PedidoId := 1;
  LCommand.UsuarioId := 7;
  LCommand.Instante := EncodeDate(2026, 8, 20);

  LResult := FService.Execute(LCommand);

  Assert.AreEqual<TFaturamentoStatus>(fsFalhaFiscal, LResult.Status);
  Assert.AreEqual<Integer>(1, FUnitOfWorkObject.Rollbacks);
  Assert.IsFalse(FEstoqueObject.EstaReservado(1));
end;

procedure TFaturarPedidoTests.PedidoInexistente_DeveRetornarResultadoConhecido;
var
  LCommand: TFaturarPedidoCommand;
  LResult: TFaturamentoResult;
begin
  LCommand.PedidoId := 999;
  LCommand.UsuarioId := 7;
  LCommand.Instante := EncodeDate(2026, 8, 20);

  LResult := FService.Execute(LCommand);

  Assert.AreEqual<TFaturamentoStatus>(fsPedidoNaoEncontrado, LResult.Status);
end;

initialization
  TDUnitX.RegisterTestFixture(TFaturarPedidoTests);

end.
