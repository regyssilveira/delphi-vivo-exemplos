program HorizonteDesktop;

uses
  Vcl.Forms,
  Horizonte.Desktop.MainForm in 'Horizonte.Desktop.MainForm.pas' {MainForm},
  Horizonte.Application.FaturarPedido in '..\Horizonte.Application\Horizonte.Application.FaturarPedido.pas',
  Horizonte.Application.Ports in '..\Horizonte.Application\Horizonte.Application.Ports.pas',
  Horizonte.Domain.Pedido in '..\Horizonte.Domain\Horizonte.Domain.Pedido.pas',
  Horizonte.Domain.Types in '..\Horizonte.Domain\Horizonte.Domain.Types.pas',
  Horizonte.Infrastructure.InMemory in '..\Horizonte.Infrastructure\Horizonte.Infrastructure.InMemory.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
