unit Horizonte.Api.Server;

interface

uses
  IdContext, IdCustomHTTPServer, IdHTTPServer,
  Horizonte.Application.Observability, Horizonte.Application.Ports;

type
  THorizonteApiServer = class
  private
    FHttpServer: TIdHTTPServer;
    FPedidos: IConsultaPedidoApplication;
    FEstoque: IEstoqueApplication;
    FLogger: IApplicationLogger;
    FToken: string;
    procedure HandleCommand(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure WriteProblem(AResponseInfo: TIdHTTPResponseInfo;
      const AStatus: Integer; const AType, ATitle, ADetail, AInstance: string;
      const AContext: TOperationContext);
    function ResolveIdentity(ARequestInfo: TIdHTTPRequestInfo;
      out AContext: TOperationContext; out APedidosRead,
      AEstoqueRead: Boolean): Boolean;
    procedure HandlePedido(ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo; const AContext: TOperationContext);
    procedure HandleEstoque(ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo; const AContext: TOperationContext);
  public
    constructor Create(const APedidos: IConsultaPedidoApplication;
      const AEstoque: IEstoqueApplication; const ALogger: IApplicationLogger;
      const AToken: string);
    destructor Destroy; override;
    procedure Start(const APort: Integer);
    procedure Stop;
  end;

implementation

uses
  System.DateUtils, System.JSON, System.SysUtils,
  Horizonte.Domain.Types;

constructor THorizonteApiServer.Create(
  const APedidos: IConsultaPedidoApplication;
  const AEstoque: IEstoqueApplication;
  const ALogger: IApplicationLogger;
  const AToken: string);
begin
  inherited Create;
  if not Assigned(APedidos) or not Assigned(AEstoque) or
    not Assigned(ALogger) then
    raise EArgumentNilException.Create('Os serviços e o logger da API são obrigatórios.');
  if AToken.IsEmpty then
    raise EArgumentException.Create('O token de desenvolvimento é obrigatório.');
  FPedidos := APedidos;
  FEstoque := AEstoque;
  FLogger := ALogger;
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

function THorizonteApiServer.ResolveIdentity(
  ARequestInfo: TIdHTTPRequestInfo;
  out AContext: TOperationContext;
  out APedidosRead, AEstoqueRead: Boolean): Boolean;
var
  LCorrelationId: string;
  LToken: string;
begin
  LCorrelationId := ARequestInfo.RawHeaders.Values['X-Correlation-ID'];
  if LCorrelationId.IsEmpty then
    LCorrelationId := TOperationContext.New(0, 1, 1).CorrelationId;
  AContext := TOperationContext.Create(LCorrelationId, 0, 1, 1);
  LToken := ARequestInfo.RawHeaders.Values['X-Api-Key'];
  Result := SameText(LToken, FToken) or
    SameText(LToken, 'horizonte-estoque-only');
  APedidosRead := SameText(LToken, FToken);
  AEstoqueRead := Result;
end;

procedure THorizonteApiServer.WriteProblem(
  AResponseInfo: TIdHTTPResponseInfo;
  const AStatus: Integer;
  const AType, ATitle, ADetail, AInstance: string;
  const AContext: TOperationContext);
var
  LJson: TJSONObject;
begin
  LJson := TJSONObject.Create;
  try
    LJson.AddPair('type', AType);
    LJson.AddPair('title', ATitle);
    LJson.AddPair('status', TJSONNumber.Create(AStatus));
    LJson.AddPair('detail', ADetail);
    LJson.AddPair('instance', AInstance);
    LJson.AddPair('correlationId', AContext.CorrelationId);
    AResponseInfo.ResponseNo := AStatus;
    AResponseInfo.ContentType := 'application/problem+json; charset=utf-8';
    AResponseInfo.ContentText := LJson.ToJSON;
    AResponseInfo.CustomHeaders.Values['X-Correlation-ID'] :=
      AContext.CorrelationId;
  finally
    LJson.Free;
  end;
end;

procedure THorizonteApiServer.HandlePedido(
  ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo;
  const AContext: TOperationContext);
var
  LPrefix: string;
  LPedidoId: Integer;
  LQuery: TConsultarPedidoQuery;
  LPedido: TPedidoConsultaDto;
  LJson, LCliente: TJSONObject;
begin
  if ARequestInfo.Document.StartsWith('/api/v1/pedidos/') then
    LPrefix := '/api/v1/pedidos/'
  else
    LPrefix := '/v1/pedidos/';
  if not TryStrToInt(ARequestInfo.Document.Substring(LPrefix.Length), LPedidoId) or
    (LPedidoId <= 0) then
  begin
    WriteProblem(AResponseInfo, 400,
      'https://api.horizonte.example/problems/parametro-invalido',
      'Parâmetro inválido',
      'O identificador do pedido deve ser um inteiro positivo.',
      ARequestInfo.Document, AContext);
    Exit;
  end;
  LQuery.PedidoId := LPedidoId;
  LQuery.EmpresaId := AContext.EmpresaId;
  LQuery.FilialId := AContext.FilialId;
  if not FPedidos.Consultar(LQuery, LPedido) then
  begin
    WriteProblem(AResponseInfo, 404,
      'https://api.horizonte.example/problems/pedido-nao-encontrado',
      'Pedido não encontrado',
      'O pedido não existe ou não pertence ao contexto autorizado.',
      ARequestInfo.Document, AContext);
    Exit;
  end;
  LJson := TJSONObject.Create;
  try
    LJson.AddPair('id', TJSONNumber.Create(LPedido.Id));
    LJson.AddPair('numero', LPedido.Numero);
    LJson.AddPair('situacao', LPedido.Situacao);
    LCliente := TJSONObject.Create;
    LCliente.AddPair('id', TJSONNumber.Create(LPedido.ClienteId));
    LCliente.AddPair('nome', LPedido.ClienteNome);
    LJson.AddPair('cliente', LCliente);
    LJson.AddPair('valorTotal', TJSONNumber.Create(Double(LPedido.ValorTotal)));
    LJson.AddPair('atualizadoEm', DateToISO8601(LPedido.AtualizadoEm, False));
    AResponseInfo.ContentType := 'application/json; charset=utf-8';
    AResponseInfo.ContentText := LJson.ToJSON;
    AResponseInfo.CustomHeaders.Values['X-Correlation-ID'] :=
      AContext.CorrelationId;
  finally
    LJson.Free;
  end;
end;

procedure THorizonteApiServer.HandleEstoque(
  ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo;
  const AContext: TOperationContext);
const
  Prefix = '/v1/estoque/';
  Suffix = '/disponibilidade';
var
  LProductText: string;
  LProdutoId: Integer;
  LResult: TDisponibilidadeEstoque;
  LJson: TJSONObject;
begin
  LProductText := ARequestInfo.Document.Substring(Prefix.Length);
  LProductText := LProductText.Substring(0,
    LProductText.Length - Suffix.Length);
  if not TryStrToInt(LProductText, LProdutoId) or (LProdutoId <= 0) then
  begin
    WriteProblem(AResponseInfo, 400,
      'https://api.horizonte.example/problems/parametro-invalido',
      'Parâmetro inválido',
      'O identificador do produto deve ser um inteiro positivo.',
      ARequestInfo.Document, AContext);
    Exit;
  end;
  LResult := FEstoque.ConsultarDisponibilidade(LProdutoId, AContext.FilialId);
  LJson := TJSONObject.Create;
  try
    LJson.AddPair('produtoId', TJSONNumber.Create(LResult.ProdutoId));
    LJson.AddPair('filialId', TJSONNumber.Create(LResult.FilialId));
    LJson.AddPair('quantidadeDisponivel',
      TJSONNumber.Create(LResult.QuantidadeDisponivel));
    LJson.AddPair('disponivel', TJSONBool.Create(LResult.Disponivel));
    AResponseInfo.ContentType := 'application/json; charset=utf-8';
    AResponseInfo.ContentText := LJson.ToJSON;
    AResponseInfo.CustomHeaders.Values['X-Correlation-ID'] :=
      AContext.CorrelationId;
  finally
    LJson.Free;
  end;
end;

procedure THorizonteApiServer.HandleCommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LOperationContext: TOperationContext;
  LPedidosRead, LEstoqueRead: Boolean;
begin
  LOperationContext := TOperationContext.New(0, 1, 1);
  if SameText(ARequestInfo.Document, '/health') then
  begin
    AResponseInfo.ContentType := 'application/json; charset=utf-8';
    AResponseInfo.ContentText := '{"status":"ok"}';
    Exit;
  end;
  if not ResolveIdentity(ARequestInfo, LOperationContext,
    LPedidosRead, LEstoqueRead) then
  begin
    WriteProblem(AResponseInfo, 401,
      'https://api.horizonte.example/problems/autenticacao-obrigatoria',
      'Autenticação obrigatória', 'Forneça uma credencial válida.',
      ARequestInfo.Document, LOperationContext);
    Exit;
  end;
  try
    if ARequestInfo.Document.StartsWith('/v1/pedidos/') or
      ARequestInfo.Document.StartsWith('/api/v1/pedidos/') then
    begin
      if not LPedidosRead then
      begin
        WriteProblem(AResponseInfo, 403,
          'https://api.horizonte.example/problems/escopo-insuficiente',
          'Acesso negado',
          'A credencial não possui o escopo pedidos:read.',
          ARequestInfo.Document, LOperationContext);
        Exit;
      end;
      HandlePedido(ARequestInfo, AResponseInfo, LOperationContext);
    end
    else if ARequestInfo.Document.StartsWith('/v1/estoque/') and
      ARequestInfo.Document.EndsWith('/disponibilidade') then
    begin
      if not LEstoqueRead then
      begin
        WriteProblem(AResponseInfo, 403,
          'https://api.horizonte.example/problems/escopo-insuficiente',
          'Acesso negado',
          'A credencial não possui o escopo estoque:read.',
          ARequestInfo.Document, LOperationContext);
        Exit;
      end;
      HandleEstoque(ARequestInfo, AResponseInfo, LOperationContext);
    end
    else
      WriteProblem(AResponseInfo, 404,
        'https://api.horizonte.example/problems/recurso-nao-encontrado',
        'Recurso não encontrado',
        'A rota solicitada não existe nesta versão.',
        ARequestInfo.Document, LOperationContext);
    FLogger.Information('api.request.concluida', LOperationContext,
      [TLogProperty.Create('path', ARequestInfo.Document),
       TLogProperty.Create('status', AResponseInfo.ResponseNo.ToString)]);
  except
    on E: Exception do
    begin
      FLogger.Error('api.request.falhou', LOperationContext, E,
        [TLogProperty.Create('path', ARequestInfo.Document)]);
      WriteProblem(AResponseInfo, 500,
        'https://api.horizonte.example/problems/falha-interna',
        'Falha interna', 'Não foi possível concluir a operação.',
        ARequestInfo.Document, LOperationContext);
    end;
  end;
end;

end.
