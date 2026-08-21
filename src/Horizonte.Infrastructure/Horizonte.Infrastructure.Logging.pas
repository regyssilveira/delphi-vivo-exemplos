unit Horizonte.Infrastructure.Logging;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  Horizonte.Application.Observability;

type
  TRecordedLogEntry = record
    Level: string;
    EventName: string;
    CorrelationId: string;
  end;

  TApplicationLoggerInMemory = class(TInterfacedObject, IApplicationLogger)
  private
    FEntries: TList<TRecordedLogEntry>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Information(const AEventName: string;
      const AContext: TOperationContext; const AProperties: TLogProperties);
    procedure Error(const AEventName: string;
      const AContext: TOperationContext; const AException: Exception;
      const AProperties: TLogProperties);
    function Count: Integer;
    function Entry(const AIndex: Integer): TRecordedLogEntry;
  end;

  TJsonLinesApplicationLogger = class(TInterfacedObject, IApplicationLogger)
  private
    FFileName: string;
    procedure WriteEntry(const ALevel, AEventName: string;
      const AContext: TOperationContext; const AProperties: TLogProperties;
      const AException: Exception);
  public
    constructor Create(const AFileName: string);
    procedure Information(const AEventName: string;
      const AContext: TOperationContext; const AProperties: TLogProperties);
    procedure Error(const AEventName: string;
      const AContext: TOperationContext; const AException: Exception;
      const AProperties: TLogProperties);
  end;

implementation

uses
  System.DateUtils,
  System.IOUtils,
  System.JSON;

constructor TApplicationLoggerInMemory.Create;
begin
  inherited Create;
  FEntries := TList<TRecordedLogEntry>.Create;
end;

destructor TApplicationLoggerInMemory.Destroy;
begin
  FEntries.Free;
  inherited Destroy;
end;

procedure TApplicationLoggerInMemory.Information(const AEventName: string;
  const AContext: TOperationContext; const AProperties: TLogProperties);
var
  LEntry: TRecordedLogEntry;
begin
  LEntry.Level := 'Information';
  LEntry.EventName := AEventName;
  LEntry.CorrelationId := AContext.CorrelationId;
  FEntries.Add(LEntry);
end;

procedure TApplicationLoggerInMemory.Error(const AEventName: string;
  const AContext: TOperationContext; const AException: Exception;
  const AProperties: TLogProperties);
var
  LEntry: TRecordedLogEntry;
begin
  LEntry.Level := 'Error';
  LEntry.EventName := AEventName;
  LEntry.CorrelationId := AContext.CorrelationId;
  FEntries.Add(LEntry);
end;

function TApplicationLoggerInMemory.Count: Integer;
begin
  Result := FEntries.Count;
end;

function TApplicationLoggerInMemory.Entry(
  const AIndex: Integer): TRecordedLogEntry;
begin
  Result := FEntries[AIndex];
end;

constructor TJsonLinesApplicationLogger.Create(const AFileName: string);
begin
  inherited Create;
  if AFileName.IsEmpty then
    raise EArgumentException.Create('O arquivo de log é obrigatório.');
  FFileName := AFileName;
end;

procedure TJsonLinesApplicationLogger.WriteEntry(
  const ALevel, AEventName: string;
  const AContext: TOperationContext;
  const AProperties: TLogProperties;
  const AException: Exception);
var
  LJson: TJSONObject;
  LProperty: TLogProperty;
begin
  LJson := TJSONObject.Create;
  try
    LJson.AddPair('timestamp', DateToISO8601(Now, False));
    LJson.AddPair('level', ALevel);
    LJson.AddPair('event', AEventName);
    LJson.AddPair('correlationId', AContext.CorrelationId);
    LJson.AddPair('userId', TJSONNumber.Create(AContext.UserId));
    LJson.AddPair('empresaId', TJSONNumber.Create(AContext.EmpresaId));
    LJson.AddPair('filialId', TJSONNumber.Create(AContext.FilialId));
    for LProperty in AProperties do
      LJson.AddPair(LProperty.Name, LProperty.Value);
    if Assigned(AException) then
      LJson.AddPair('errorType', AException.ClassName);
    TMonitor.Enter(Self);
    try
      TFile.AppendAllText(FFileName, LJson.ToJSON + sLineBreak, TEncoding.UTF8);
    finally
      TMonitor.Exit(Self);
    end;
  finally
    LJson.Free;
  end;
end;

procedure TJsonLinesApplicationLogger.Information(const AEventName: string;
  const AContext: TOperationContext; const AProperties: TLogProperties);
begin
  WriteEntry('Information', AEventName, AContext, AProperties, nil);
end;

procedure TJsonLinesApplicationLogger.Error(const AEventName: string;
  const AContext: TOperationContext; const AException: Exception;
  const AProperties: TLogProperties);
begin
  WriteEntry('Error', AEventName, AContext, AProperties, AException);
end;

end.
