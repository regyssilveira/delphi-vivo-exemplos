unit Horizonte.Infrastructure.FireDAC;

interface

uses
  FireDAC.Comp.Client,
  Horizonte.Application.Ports,
  Horizonte.Domain.Pedido;

type
  TFirebirdConfig = record
    Server: string;
    Port: Integer;
    Database: string;
    UserName: string;
    Password: string;
    CharacterSet: string;
  end;

  TFireDACConnectionFactory = class
  public
    class function CreateConnection(
      const AConfig: TFirebirdConfig): TFDConnection; static;
  end;

  TPedidoRepositoryFireDAC = class(TInterfacedObject, IPedidoRepository)
  private
    FConnection: TFDConnection;
  public
    constructor Create(const AConnection: TFDConnection);
    function ObterPorId(const APedidoId: Integer): TPedido;
    procedure Atualizar(const APedido: TPedido);
  end;

  TUnitOfWorkFireDAC = class(TInterfacedObject, IUnitOfWork)
  private
    FConnection: TFDConnection;
  public
    constructor Create(const AConnection: TFDConnection);
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.DApt,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Param,
  FireDAC.Phys.FB,
  Horizonte.Domain.Types;

function StatusFromDatabase(const AValue: string): TPedidoStatus;
begin
  if SameText(AValue, 'APROVADO') then
    Exit(psAprovado);
  if SameText(AValue, 'FATURADO') then
    Exit(psFaturado);
  if SameText(AValue, 'CANCELADO') then
    Exit(psCancelado);
  Result := psPendente;
end;

function StatusToDatabase(const AValue: TPedidoStatus): string;
begin
  case AValue of
    psAprovado: Result := 'APROVADO';
    psFaturado: Result := 'FATURADO';
    psCancelado: Result := 'CANCELADO';
  else
    Result := 'PENDENTE';
  end;
end;

class function TFireDACConnectionFactory.CreateConnection(
  const AConfig: TFirebirdConfig): TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  try
    Result.LoginPrompt := False;
    Result.Params.DriverID := 'FB';
    Result.Params.Database := AConfig.Database;
    Result.Params.UserName := AConfig.UserName;
    Result.Params.Password := AConfig.Password;
    Result.Params.Add('Server=' + AConfig.Server);
    Result.Params.Add('Port=' + AConfig.Port.ToString);
    Result.Params.Add('Protocol=TCPIP');
    Result.Params.Add('CharacterSet=' + AConfig.CharacterSet);
    Result.Connected := True;
  except
    Result.Free;
    raise;
  end;
end;

constructor TPedidoRepositoryFireDAC.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise EArgumentNilException.Create('A conexão FireDAC é obrigatória.');
  FConnection := AConnection;
end;

function TPedidoRepositoryFireDAC.ObterPorId(
  const APedidoId: Integer): TPedido;
var
  LQuery: TFDQuery;
  LStatus: TPedidoStatus;
  LInitialStatus: TPedidoStatus;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'select ID, CLIENTE_ID, VALOR_TOTAL, STATUS, FATURA_ID ' +
      'from PEDIDO where ID = :PEDIDO_ID';
    LQuery.ParamByName('PEDIDO_ID').AsInteger := APedidoId;
    LQuery.Open;
    if LQuery.Eof then
      Exit(nil);

    LStatus := StatusFromDatabase(LQuery.FieldByName('STATUS').AsString);
    LInitialStatus := LStatus;
    if LStatus = psFaturado then
      LInitialStatus := psAprovado;
    Result := TPedido.Create(
      LQuery.FieldByName('ID').AsInteger,
      LQuery.FieldByName('CLIENTE_ID').AsInteger,
      LQuery.FieldByName('VALOR_TOTAL').AsCurrency,
      LInitialStatus);
    if LStatus = psFaturado then
      Result.MarcarComoFaturado(LQuery.FieldByName('FATURA_ID').AsInteger);
  finally
    LQuery.Free;
  end;
end;

procedure TPedidoRepositoryFireDAC.Atualizar(const APedido: TPedido);
var
  LCommand: TFDQuery;
begin
  LCommand := TFDQuery.Create(nil);
  try
    LCommand.Connection := FConnection;
    LCommand.SQL.Text :=
      'update PEDIDO set STATUS = :STATUS, FATURA_ID = :FATURA_ID ' +
      'where ID = :PEDIDO_ID';
    LCommand.ParamByName('STATUS').AsString := StatusToDatabase(APedido.Status);
    if APedido.FaturaId > 0 then
      LCommand.ParamByName('FATURA_ID').AsInteger := APedido.FaturaId
    else
      LCommand.ParamByName('FATURA_ID').Clear;
    LCommand.ParamByName('PEDIDO_ID').AsInteger := APedido.Id;
    LCommand.ExecSQL;
    if LCommand.RowsAffected <> 1 then
      raise EInvalidOpException.Create('O pedido não foi atualizado.');
  finally
    LCommand.Free;
  end;
end;

constructor TUnitOfWorkFireDAC.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise EArgumentNilException.Create('A conexão FireDAC é obrigatória.');
  FConnection := AConnection;
end;

procedure TUnitOfWorkFireDAC.BeginTransaction;
begin
  FConnection.StartTransaction;
end;

procedure TUnitOfWorkFireDAC.Commit;
begin
  if FConnection.InTransaction then
    FConnection.Commit;
end;

procedure TUnitOfWorkFireDAC.Rollback;
begin
  if FConnection.InTransaction then
    FConnection.Rollback;
end;

end.
