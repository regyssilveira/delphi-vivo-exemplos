unit Horizonte.ContractTests.Api;

interface

uses
  DUnitX.TestFramework,
  IdHTTP,
  Horizonte.Api.Server,
  Horizonte.Application.Observability,
  Horizonte.Application.Ports;

type
  [TestFixture]
  THorizonteApiContractTests = class
  private
    FServer: THorizonteApiServer;
    FHttp: TIdHTTP;
    FRepository: IPedidoRepository;
    FPedidos: IConsultaPedidoApplication;
    FEstoque: IEstoqueApplication;
    FLogger: IApplicationLogger;
    function Get(const APath, AApiKey: string; out AStatus: Integer): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Pedido200_DeveRespeitarContratoDoLivro;
    [Test]
    procedure SemCredencial_DeveRetornar401ProblemDetails;
    [Test]
    procedure SemEscopoPedidos_DeveRetornar403;
    [Test]
    procedure PedidoAusente_DeveRetornar404SemVazarTenant;
    [Test]
    procedure IdentificadorInvalido_DeveRetornar400;
    [Test]
    procedure Estoque200_DeveInformarDisponibilidade;
    [Test]
    procedure CorrelationId_DeveSerPropagado;
  end;

implementation

uses
  System.Classes,
  System.JSON,
  System.SysUtils,
  IdHTTPHeaderInfo,
  Horizonte.Application.ConsultarPedido,
  Horizonte.Domain.Pedido,
  Horizonte.Domain.Types,
  Horizonte.Infrastructure.InMemory,
  Horizonte.Infrastructure.Logging;

procedure THorizonteApiContractTests.Setup;
var
  LRepository: TPedidoRepositoryInMemory;
  LPedido: TPedido;
begin
  LRepository := TPedidoRepositoryInMemory.Create;
  FRepository := LRepository;
  LPedido := TPedido.Create(1, 101, 1250.50, psAprovado, 1, 1,
    'PV-2026-000001', EncodeDate(2026, 8, 17) + EncodeTime(13, 42, 18, 0));
  try
    LRepository.Adicionar(LPedido);
  finally
    LPedido.Free;
  end;
  FPedidos := TConsultarPedido.Create(FRepository);
  FEstoque := TEstoqueServiceFixo.Create(True);
  FLogger := TApplicationLoggerInMemory.Create;
  FServer := THorizonteApiServer.Create(
    FPedidos, FEstoque, FLogger, 'contract-test-token');
  FServer.Start(18081);
  FHttp := TIdHTTP.Create(nil);
  FHttp.HTTPOptions := FHttp.HTTPOptions +
    [hoNoProtocolErrorException, hoWantProtocolErrorContent];
end;

procedure THorizonteApiContractTests.TearDown;
begin
  FHttp.Disconnect;
  FServer.Stop;
  TThread.Sleep(50);
  FHttp.Free;
  FServer.Free;
  FLogger := nil;
  FEstoque := nil;
  FPedidos := nil;
  FRepository := nil;
end;

function THorizonteApiContractTests.Get(
  const APath, AApiKey: string;
  out AStatus: Integer): string;
begin
  FHttp.Request.CustomHeaders.Clear;
  if not AApiKey.IsEmpty then
    FHttp.Request.CustomHeaders.Values['X-Api-Key'] := AApiKey;
  FHttp.Request.CustomHeaders.Values['X-Correlation-ID'] := 'contract-correlation';
  Result := FHttp.Get('http://127.0.0.1:18081' + APath);
  AStatus := FHttp.ResponseCode;
end;

procedure THorizonteApiContractTests.Pedido200_DeveRespeitarContratoDoLivro;
var
  LStatus: Integer;
  LBody: string;
  LJson: TJSONObject;
begin
  LBody := Get('/v1/pedidos/1', 'contract-test-token', LStatus);
  Assert.AreEqual(200, LStatus);
  LJson := TJSONObject.ParseJSONValue(LBody) as TJSONObject;
  try
    Assert.IsNotNull(LJson);
    Assert.AreEqual('PV-2026-000001', LJson.GetValue<string>('numero'));
    Assert.AreEqual('aprovado', LJson.GetValue<string>('situacao'));
    Assert.IsNotNull(LJson.GetValue('cliente'));
    Assert.IsNotNull(LJson.GetValue('atualizadoEm'));
    Assert.IsNull(LJson.GetValue('empresaId'));
    Assert.IsNull(LJson.GetValue('filialId'));
  finally
    LJson.Free;
  end;
end;

procedure THorizonteApiContractTests.SemCredencial_DeveRetornar401ProblemDetails;
var
  LStatus: Integer;
  LBody: string;
begin
  LBody := Get('/v1/pedidos/1', '', LStatus);
  Assert.AreEqual(401, LStatus);
  Assert.Contains(LBody, 'correlationId');
  Assert.AreEqual('application/problem+json', FHttp.Response.ContentType);
end;

procedure THorizonteApiContractTests.SemEscopoPedidos_DeveRetornar403;
var
  LStatus: Integer;
  LBody: string;
begin
  LBody := Get('/v1/pedidos/1', 'horizonte-estoque-only', LStatus);
  Assert.AreEqual(403, LStatus);
  Assert.Contains(LBody, 'pedidos:read');
end;

procedure THorizonteApiContractTests.PedidoAusente_DeveRetornar404SemVazarTenant;
var
  LStatus: Integer;
  LBody: string;
begin
  LBody := Get('/v1/pedidos/999', 'contract-test-token', LStatus);
  Assert.AreEqual(404, LStatus);
  Assert.IsFalse(LBody.Contains('select '));
  Assert.IsFalse(LBody.Contains('stack'));
end;

procedure THorizonteApiContractTests.IdentificadorInvalido_DeveRetornar400;
var
  LStatus: Integer;
  LBody: string;
begin
  LBody := Get('/v1/pedidos/abc', 'contract-test-token', LStatus);
  Assert.AreEqual(400, LStatus);
  Assert.Contains(LBody, 'parametro-invalido');
end;

procedure THorizonteApiContractTests.Estoque200_DeveInformarDisponibilidade;
var
  LStatus: Integer;
  LBody: string;
begin
  LBody := Get('/v1/estoque/10/disponibilidade',
    'contract-test-token', LStatus);
  Assert.AreEqual(200, LStatus);
  Assert.Contains(LBody, 'quantidadeDisponivel');
  Assert.Contains(LBody, '"disponivel":true');
end;

procedure THorizonteApiContractTests.CorrelationId_DeveSerPropagado;
var
  LStatus: Integer;
begin
  Get('/v1/pedidos/1', 'contract-test-token', LStatus);
  Assert.AreEqual('contract-correlation',
    FHttp.Response.RawHeaders.Values['X-Correlation-ID']);
end;

initialization
  TDUnitX.RegisterTestFixture(THorizonteApiContractTests);

end.
