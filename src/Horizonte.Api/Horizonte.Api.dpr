program HorizonteApi;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  Horizonte.Api.Server in 'Horizonte.Api.Server.pas',
  Horizonte.Application.ConsultarPedido in '..\Horizonte.Application\Horizonte.Application.ConsultarPedido.pas',
  Horizonte.Application.Observability in '..\Horizonte.Application\Horizonte.Application.Observability.pas',
  Horizonte.Application.Ports in '..\Horizonte.Application\Horizonte.Application.Ports.pas',
  Horizonte.Domain.Pedido in '..\Horizonte.Domain\Horizonte.Domain.Pedido.pas',
  Horizonte.Domain.Types in '..\Horizonte.Domain\Horizonte.Domain.Types.pas',
  Horizonte.Infrastructure.InMemory in '..\Horizonte.Infrastructure\Horizonte.Infrastructure.InMemory.pas',
  Horizonte.Infrastructure.Logging in '..\Horizonte.Infrastructure\Horizonte.Infrastructure.Logging.pas';

var
  LRepositoryObject: TPedidoRepositoryInMemory;
  LRepository: IPedidoRepository;
  LConsultaPedido: IConsultaPedidoApplication;
  LEstoque: IEstoqueApplication;
  LLogger: IApplicationLogger;
  LPedido: TPedido;
  LServer: THorizonteApiServer;
  LToken, LLogDirectory: string;
  LPort: Integer;
begin
  ReportMemoryLeaksOnShutdown := True;
  LRepositoryObject := TPedidoRepositoryInMemory.Create;
  LRepository := LRepositoryObject;
  LPedido := TPedido.Create(1, 101, 1250.50, psAprovado, 1, 1,
    'PV-2026-000001', Now);
  try
    LRepositoryObject.Adicionar(LPedido);
  finally
    LPedido.Free;
  end;
  LConsultaPedido := TConsultarPedido.Create(LRepository);
  LEstoque := TEstoqueServiceFixo.Create(True);
  LLogDirectory := TPath.Combine(ExtractFilePath(ParamStr(0)), 'logs');
  ForceDirectories(LLogDirectory);
  LLogger := TJsonLinesApplicationLogger.Create(
    TPath.Combine(LLogDirectory, 'horizonte-api.jsonl'));
  LToken := GetEnvironmentVariable('HORIZONTE_API_TOKEN');
  if LToken.IsEmpty then
    LToken := 'horizonte-local-only';
  if not TryStrToInt(GetEnvironmentVariable('HORIZONTE_API_PORT'), LPort) then
    LPort := 8080;
  LServer := THorizonteApiServer.Create(
    LConsultaPedido, LEstoque, LLogger, LToken);
  try
    LServer.Start(LPort);
    Writeln(Format('Horizonte API em http://127.0.0.1:%d', [LPort]));
    if FindCmdLineSwitch('service', True) then
      while True do
        TThread.Sleep(1000)
    else
    begin
      Writeln('Pressione ENTER para encerrar.');
      Readln;
    end;
  finally
    LServer.Free;
  end;
end.
