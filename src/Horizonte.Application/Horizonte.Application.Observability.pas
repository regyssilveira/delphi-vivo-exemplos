unit Horizonte.Application.Observability;

interface

uses
  System.SysUtils;

type
  TOperationContext = record
  private
    FCorrelationId: string;
    FUserId: Integer;
    FEmpresaId: Integer;
    FFilialId: Integer;
  public
    constructor Create(
      const ACorrelationId: string;
      const AUserId: Integer;
      const AEmpresaId: Integer;
      const AFilialId: Integer);
    class function New(
      const AUserId: Integer;
      const AEmpresaId: Integer;
      const AFilialId: Integer): TOperationContext; static;
    property CorrelationId: string read FCorrelationId;
    property UserId: Integer read FUserId;
    property EmpresaId: Integer read FEmpresaId;
    property FilialId: Integer read FFilialId;
  end;

  TLogProperty = record
    Name: string;
    Value: string;
    class function Create(const AName, AValue: string): TLogProperty; static;
  end;

  TLogProperties = TArray<TLogProperty>;

  IApplicationLogger = interface
    ['{A4A7FB89-87C1-4479-86F3-923A97A72B15}']
    procedure Information(
      const AEventName: string;
      const AContext: TOperationContext;
      const AProperties: TLogProperties);
    procedure Error(
      const AEventName: string;
      const AContext: TOperationContext;
      const AException: Exception;
      const AProperties: TLogProperties);
  end;

  TNullApplicationLogger = class(TInterfacedObject, IApplicationLogger)
  public
    procedure Information(const AEventName: string;
      const AContext: TOperationContext; const AProperties: TLogProperties);
    procedure Error(const AEventName: string;
      const AContext: TOperationContext; const AException: Exception;
      const AProperties: TLogProperties);
  end;

implementation

constructor TOperationContext.Create(
  const ACorrelationId: string;
  const AUserId: Integer;
  const AEmpresaId: Integer;
  const AFilialId: Integer);
begin
  if ACorrelationId.IsEmpty then
    raise EArgumentException.Create('O correlation ID é obrigatório.');
  FCorrelationId := ACorrelationId;
  FUserId := AUserId;
  FEmpresaId := AEmpresaId;
  FFilialId := AFilialId;
end;

class function TOperationContext.New(
  const AUserId: Integer;
  const AEmpresaId: Integer;
  const AFilialId: Integer): TOperationContext;
var
  LGuid: TGUID;
begin
  CreateGUID(LGuid);
  Result := TOperationContext.Create(
    GUIDToString(LGuid).Trim(['{', '}']).ToLower,
    AUserId,
    AEmpresaId,
    AFilialId);
end;

class function TLogProperty.Create(
  const AName: string;
  const AValue: string): TLogProperty;
begin
  Result.Name := AName;
  Result.Value := AValue;
end;

procedure TNullApplicationLogger.Information(const AEventName: string;
  const AContext: TOperationContext; const AProperties: TLogProperties);
begin
end;

procedure TNullApplicationLogger.Error(const AEventName: string;
  const AContext: TOperationContext; const AException: Exception;
  const AProperties: TLogProperties);
begin
end;

end.
