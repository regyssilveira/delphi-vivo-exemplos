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
  public
    constructor Create(
      const AId: Integer;
      const AClienteId: Integer;
      const AValorTotal: Currency;
      const AStatus: TPedidoStatus);
    procedure MarcarComoFaturado(const AFaturaId: Integer);
    property Id: Integer read FId;
    property ClienteId: Integer read FClienteId;
    property ValorTotal: Currency read FValorTotal;
    property Status: TPedidoStatus read FStatus;
    property FaturaId: Integer read FFaturaId;
  end;

implementation

constructor TPedido.Create(
  const AId: Integer;
  const AClienteId: Integer;
  const AValorTotal: Currency;
  const AStatus: TPedidoStatus);
begin
  inherited Create;
  if AId <= 0 then
    raise EArgumentOutOfRangeException.Create('O pedido deve possuir um identificador positivo.');
  if AClienteId <= 0 then
    raise EArgumentOutOfRangeException.Create('O cliente deve possuir um identificador positivo.');
  if AValorTotal <= 0 then
    raise EArgumentOutOfRangeException.Create('O valor total deve ser positivo.');

  FId := AId;
  FClienteId := AClienteId;
  FValorTotal := AValorTotal;
  FStatus := AStatus;
end;

procedure TPedido.MarcarComoFaturado(const AFaturaId: Integer);
begin
  if FStatus <> psAprovado then
    raise EInvalidOpException.Create('Somente pedidos aprovados podem ser faturados.');
  if AFaturaId <= 0 then
    raise EArgumentOutOfRangeException.Create('A fatura deve possuir um identificador positivo.');

  FFaturaId := AFaturaId;
  FStatus := psFaturado;
end;

end.

