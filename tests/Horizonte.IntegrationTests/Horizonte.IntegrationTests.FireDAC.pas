unit Horizonte.IntegrationTests.FireDAC;

interface

uses
  DUnitX.TestFramework,
  FireDAC.Comp.Client,
  FireDAC.Phys.FB,
  Horizonte.Application.Ports;

type
  [TestFixture]
  TFireDACRepositoryTests = class
  private
    FConnection: TFDConnection;
    FDriverLink: TFDPhysFBDriverLink;
    FRepository: IPedidoRepository;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure DeveCarregarPedidoFaturadoSemViolarInvariantes;
    [Test]
    procedure DevePersistirFaturamentoDentroDaTransacao;
  end;

implementation

uses
  System.SysUtils,
  Horizonte.Domain.Pedido,
  Horizonte.Domain.Types,
  Horizonte.Infrastructure.FireDAC;

function RequiredEnvironment(const AName: string): string;
begin
  Result := GetEnvironmentVariable(AName);
  if Result.IsEmpty then
    raise EInvalidOpException.CreateFmt(
      'Defina a variável de ambiente %s para executar a integração.', [AName]);
end;

procedure TFireDACRepositoryTests.Setup;
var
  LConfig: TFirebirdConfig;
begin
  FDriverLink := TFDPhysFBDriverLink.Create(nil);
  FDriverLink.VendorLib := RequiredEnvironment('HORIZONTE_FB_CLIENT');
  LConfig.Server := '127.0.0.1';
  LConfig.Port := 3051;
  LConfig.Database := '/var/lib/firebird/data/horizonte.fdb';
  LConfig.UserName := 'horizonte';
  LConfig.Password := 'horizonte_dev';
  LConfig.CharacterSet := 'UTF8';
  FConnection := TFireDACConnectionFactory.CreateConnection(LConfig);
  FRepository := TPedidoRepositoryFireDAC.Create(FConnection);
end;

procedure TFireDACRepositoryTests.TearDown;
begin
  FRepository := nil;
  FConnection.Free;
  FDriverLink.Free;
end;

procedure TFireDACRepositoryTests.DeveCarregarPedidoFaturadoSemViolarInvariantes;
var
  LPedido: TPedido;
begin
  LPedido := FRepository.ObterPorId(3);
  try
    Assert.IsNotNull(LPedido);
    Assert.AreEqual<TPedidoStatus>(psFaturado, LPedido.Status);
    Assert.AreEqual(9001, LPedido.FaturaId);
  finally
    LPedido.Free;
  end;
end;

procedure TFireDACRepositoryTests.DevePersistirFaturamentoDentroDaTransacao;
var
  LPedido: TPedido;
  LReloaded: TPedido;
  LUnitOfWork: IUnitOfWork;
begin
  FConnection.ExecSQL(
    'update PEDIDO set STATUS = ''APROVADO'', FATURA_ID = null where ID = 1');
  LPedido := FRepository.ObterPorId(1);
  LUnitOfWork := TUnitOfWorkFireDAC.Create(FConnection);
  try
    LUnitOfWork.BeginTransaction;
    LPedido.MarcarComoFaturado(9100);
    FRepository.Atualizar(LPedido);
    LUnitOfWork.Commit;
  finally
    LPedido.Free;
  end;

  LReloaded := FRepository.ObterPorId(1);
  try
    Assert.AreEqual<TPedidoStatus>(psFaturado, LReloaded.Status);
    Assert.AreEqual(9100, LReloaded.FaturaId);
  finally
    LReloaded.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TFireDACRepositoryTests);

end.
