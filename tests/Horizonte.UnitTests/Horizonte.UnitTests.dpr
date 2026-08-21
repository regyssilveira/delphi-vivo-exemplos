program HorizonteUnitTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  Horizonte.UnitTests.FaturarPedido in 'Horizonte.UnitTests.FaturarPedido.pas',
  Horizonte.Application.FaturarPedido in '..\..\src\Horizonte.Application\Horizonte.Application.FaturarPedido.pas',
  Horizonte.Application.Observability in '..\..\src\Horizonte.Application\Horizonte.Application.Observability.pas',
  Horizonte.Application.Ports in '..\..\src\Horizonte.Application\Horizonte.Application.Ports.pas',
  Horizonte.Domain.Pedido in '..\..\src\Horizonte.Domain\Horizonte.Domain.Pedido.pas',
  Horizonte.Domain.Types in '..\..\src\Horizonte.Domain\Horizonte.Domain.Types.pas',
  Horizonte.Infrastructure.InMemory in '..\..\src\Horizonte.Infrastructure\Horizonte.Infrastructure.InMemory.pas',
  Horizonte.Infrastructure.Logging in '..\..\src\Horizonte.Infrastructure\Horizonte.Infrastructure.Logging.pas';

var
  LRunner: ITestRunner;
  LResults: IRunResults;
begin
  ReportMemoryLeaksOnShutdown := True;
  TDUnitX.CheckCommandLine;
  LRunner := TDUnitX.CreateRunner;
  LRunner.UseRTTI := True;
  LRunner.AddLogger(TDUnitXConsoleLogger.Create(True));
  LRunner.AddLogger(TDUnitXXMLNUnitFileLogger.Create(
    ExtractFilePath(ParamStr(0)) + 'Horizonte.UnitTests-results.xml'));
  LResults := LRunner.Execute;
  if not LResults.AllPassed then
    ExitCode := EXIT_ERRORS;
end.
