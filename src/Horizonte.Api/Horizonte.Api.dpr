program HorizonteApi;
{$APPTYPE CONSOLE}
uses
  System.SysUtils,
  Horizonte.Api.Server in 'Horizonte.Api.Server.pas',
  Horizonte.Application.Ports in '..\Horizonte.Application\Horizonte.Application.Ports.pas',
  Horizonte.Domain.Pedido in '..\Horizonte.Domain\Horizonte.Domain.Pedido.pas',
  Horizonte.Domain.Types in '..\Horizonte.Domain\Horizonte.Domain.Types.pas',
  Horizonte.Infrastructure.InMemory in '..\Horizonte.Infrastructure\Horizonte.Infrastructure.InMemory.pas';
var
  LRepositoryObject: TPedidoRepositoryInMemory;
  LRepository: IPedidoRepository;
  LPedido: TPedido;
  LServer: THorizonteApiServer;
  LToken: string;
begin
  ReportMemoryLeaksOnShutdown := True;
  LRepositoryObject := TPedidoRepositoryInMemory.Create;
  LRepository := LRepositoryObject;
  LPedido := TPedido.Create(1, 101, 1250.50, psAprovado);
  try LRepositoryObject.Adicionar(LPedido); finally LPedido.Free; end;
  LToken := GetEnvironmentVariable('HORIZONTE_API_TOKEN');
  if LToken.IsEmpty then LToken := 'horizonte-local-only';
  LServer := THorizonteApiServer.Create(LRepository, LToken);
  try
    LServer.Start(8080);
    Writeln('Horizonte API em http://127.0.0.1:8080');
    Writeln('Pressione ENTER para encerrar.');
    Readln;
  finally
    LServer.Free;
  end;
end.
