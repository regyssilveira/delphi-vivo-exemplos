unit Horizonte.Desktop.MainForm;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Horizonte.Application.FaturarPedido,
  Horizonte.Application.Ports;

type
  TMainForm = class(TForm)
    btnFaturar: TButton;
    lblTitulo: TLabel;
    memResultado: TMemo;
    procedure btnFaturarClick(Sender: TObject);
  private
    FService: TFaturarPedido;
    FRepository: IPedidoRepository;
    FCredito: ICreditoService;
    FEstoque: IEstoqueService;
    FFiscal: IIntegracaoFiscal;
    FUnitOfWork: IUnitOfWork;
    procedure ConfigurarCasoDidatico;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Horizonte.Domain.Pedido,
  Horizonte.Domain.Types,
  Horizonte.Infrastructure.InMemory;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConfigurarCasoDidatico;
end;

destructor TMainForm.Destroy;
begin
  FService.Free;
  FUnitOfWork := nil;
  FFiscal := nil;
  FEstoque := nil;
  FCredito := nil;
  FRepository := nil;
  inherited Destroy;
end;

procedure TMainForm.ConfigurarCasoDidatico;
var
  LRepository: TPedidoRepositoryInMemory;
  LPedido: TPedido;
begin
  LRepository := TPedidoRepositoryInMemory.Create;
  FRepository := LRepository;
  LPedido := TPedido.Create(1, 10, 250, psAprovado);
  try
    LRepository.Adicionar(LPedido);
  finally
    LPedido.Free;
  end;

  FCredito := TCreditoServiceFixo.Create(True);
  FEstoque := TEstoqueServiceFixo.Create(True);
  FFiscal := TIntegracaoFiscalSimulada.Create;
  FUnitOfWork := TUnitOfWorkInMemory.Create;
  FService := TFaturarPedido.Create(
    FRepository,
    FCredito,
    FEstoque,
    FFiscal,
    FUnitOfWork);
end;

procedure TMainForm.btnFaturarClick(Sender: TObject);
var
  LCommand: TFaturarPedidoCommand;
  LResult: TFaturamentoResult;
begin
  LCommand.PedidoId := 1;
  LCommand.UsuarioId := 7;
  LCommand.Instante := Now;
  LResult := FService.Execute(LCommand);
  memResultado.Lines.Add(Format(
    '%s Fatura: %d',
    [LResult.Mensagem, LResult.FaturaId]));
end;

end.

