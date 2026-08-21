unit Horizonte.Api.Server;

interface

uses
  IdContext, IdCustomHTTPServer, IdHTTPServer,
  Horizonte.Application.Ports;

type
  THorizonteApiServer = class
  private
    FHttpServer: TIdHTTPServer;
    FRepository: IPedidoRepository;
    FToken: string;
    procedure HandleCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure WriteProblem(AResponseInfo: TIdHTTPResponseInfo;
      const AStatus: Integer; const ATitle: string);
  public
    constructor Create(const ARepository: IPedidoRepository; const AToken: string);
    destructor Destroy; override;
    procedure Start(const APort: Integer);
    procedure Stop;
  end;

implementation

uses
  System.JSON, System.SysUtils,
  Horizonte.Domain.Pedido, Horizonte.Domain.Types;

function StatusToText(const AStatus: TPedidoStatus): string;
begin
  case AStatus of
    psAprovado: Result := 'APROVADO';
    psFaturado: Result := 'FATURADO';
    psCancelado: Result := 'CANCELADO';
  else
    Result := 'PENDENTE';
  end;
end;

constructor THorizonteApiServer.Create(const ARepository: IPedidoRepository;
  const AToken: string);
begin
  inherited Create;
  if not Assigned(ARepository) then
    raise EArgumentNilException.Create('O repositório é obrigatório.');
  if AToken.IsEmpty then
    raise EArgumentException.Create('O token de desenvolvimento é obrigatório.');
  FRepository := ARepository;
  FToken := AToken;
  FHttpServer := TIdHTTPServer.Create(nil);
  FHttpServer.OnCommandGet := HandleCommand;
end;

destructor THorizonteApiServer.Destroy;
begin
  Stop;
  FHttpServer.Free;
  inherited Destroy;
end;

procedure THorizonteApiServer.Start(const APort: Integer);
begin
  FHttpServer.DefaultPort := APort;
  FHttpServer.Active := True;
end;

procedure THorizonteApiServer.Stop;
begin
  FHttpServer.Active := False;
end;

procedure THorizonteApiServer.WriteProblem(AResponseInfo: TIdHTTPResponseInfo;
  const AStatus: Integer; const ATitle: string);
var
  LJson: TJSONObject;
begin
  LJson := TJSONObject.Create;
  try
    LJson.AddPair('type', 'about:blank');
    LJson.AddPair('title', ATitle);
    LJson.AddPair('status', TJSONNumber.Create(AStatus));
    AResponseInfo.ResponseNo := AStatus;
    AResponseInfo.ContentType := 'application/problem+json; charset=utf-8';
    AResponseInfo.ContentText := LJson.ToJSON;
  finally
    LJson.Free;
  end;
end;

procedure THorizonteApiServer.HandleCommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LPedidoId: Integer;
  LPedido: TPedido;
  LJson: TJSONObject;
begin
  if SameText(ARequestInfo.Document, '/health') then
  begin
    AResponseInfo.ContentType := 'application/json; charset=utf-8';
    AResponseInfo.ContentText := '{"status":"ok"}';
    Exit;
  end;
  if not SameText(ARequestInfo.RawHeaders.Values['X-Api-Key'], FToken) then
  begin
    WriteProblem(AResponseInfo, 401, 'Autenticação obrigatória');
    Exit;
  end;
  if not ARequestInfo.Document.StartsWith('/api/v1/pedidos/') or
    not TryStrToInt(ARequestInfo.Document.Substring(16), LPedidoId) or (LPedidoId <= 0) then
  begin
    WriteProblem(AResponseInfo, 404, 'Pedido não encontrado');
    Exit;
  end;
  LPedido := FRepository.ObterPorId(LPedidoId);
  if not Assigned(LPedido) then
  begin
    WriteProblem(AResponseInfo, 404, 'Pedido não encontrado');
    Exit;
  end;
  try
    LJson := TJSONObject.Create;
    try
      LJson.AddPair('id', TJSONNumber.Create(LPedido.Id));
      LJson.AddPair('clienteId', TJSONNumber.Create(LPedido.ClienteId));
      LJson.AddPair('valorTotal', TJSONNumber.Create(Double(LPedido.ValorTotal)));
      LJson.AddPair('status', StatusToText(LPedido.Status));
      AResponseInfo.ContentType := 'application/json; charset=utf-8';
      AResponseInfo.ContentText := LJson.ToJSON;
    finally
      LJson.Free;
    end;
  finally
    LPedido.Free;
  end;
end;

end.
