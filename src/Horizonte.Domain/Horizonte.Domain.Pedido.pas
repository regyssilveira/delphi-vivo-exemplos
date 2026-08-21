unit Horizonte.Domain.Pedido;

interface

uses
  System.SysUtils,
  Horizonte.Domain.Types;

type
  TPedido = class
  private
    FId: Integer;
    FClienteId: Integer;
    FValorTotal: Currency;
    FStatus: TPedidoStatus;
    FFaturaId: Integer;
    FEmpresaId: Integer;
    FFilialId: Integer;
    FNumero: string;
    FAtualizadoEm: TDateTime;
  public
    constructor Create(
      const AId: Integer;
      const AClienteId: Integer;
      const AValorTotal: Currency;
      const AStatus: TPedidoStatus;
      const AEmpresaId: Integer = 1;
      const AFilialId: Integer = 1;
      const ANumero: string = '';
      const AAtualizadoEm: TDateTime = 0);
    procedure MarcarComoFaturado(const AFaturaId: Integer);
    property Id: Integer read FId;
    property ClienteId: Integer read FClienteId;
    property ValorTotal: Currency read FValorTotal;
    property Status: TPedidoStatus read FStatus;
    property FaturaId: Integer read FFaturaId;
    property EmpresaId: Integer read FEmpresaId;
    property FilialId: Integer read FFilialId;
    property Numero: string read FNumero;
    property AtualizadoEm: TDateTime read FAtualizadoEm;
  end;

implementation

constructor TPedido.Create(
  const AId: Integer;
  const AClienteId: Integer;
  const AValorTotal: Currency;
  const AStatus: TPedidoStatus;
  const AEmpresaId: Integer;
  const AFilialId: Integer;
  const ANumero: string;
  const AAtualizadoEm: TDateTime);
begin
  inherited Create;
  if AId <= 0 then
    raise EArgumentOutOfRangeException.Create('O pedido deve possuir um identificador positivo.');
  if AClienteId <= 0 then
    raise EArgumentOutOfRangeException.Create('O cliente deve possuir um identificador positivo.');
  if AValorTotal <= 0 then
    raise EArgumentOutOfRangeException.Create('O valor total deve ser positivo.');
  if AEmpresaId <= 0 then
    raise EArgumentOutOfRangeException.Create('A empresa deve possuir um identificador positivo.');
  if AFilialId <= 0 then
    raise EArgumentOutOfRangeException.Create('A filial deve possuir um identificador positivo.');

  FId := AId;
  FClienteId := AClienteId;
  FValorTotal := AValorTotal;
  FStatus := AStatus;
  FEmpresaId := AEmpresaId;
  FFilialId := AFilialId;
  if ANumero.IsEmpty then
    FNumero := Format('PV-%d', [AId])
  else
    FNumero := ANumero;
  if AAtualizadoEm > 0 then
    FAtualizadoEm := AAtualizadoEm
  else
    FAtualizadoEm := Now;
end;

procedure TPedido.MarcarComoFaturado(const AFaturaId: Integer);
begin
  if FStatus <> psAprovado then
    raise EInvalidOpException.Create('Somente pedidos aprovados podem ser faturados.');
  if AFaturaId <= 0 then
    raise EArgumentOutOfRangeException.Create('A fatura deve possuir um identificador positivo.');

  FFaturaId := AFaturaId;
  FStatus := psFaturado;
  FAtualizadoEm := Now;
end;

end.
