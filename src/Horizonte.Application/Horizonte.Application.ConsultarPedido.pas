unit Horizonte.Application.ConsultarPedido;

interface

uses
  Horizonte.Application.Ports,
  Horizonte.Domain.Types;

type
  TConsultarPedido = class(TInterfacedObject, IConsultaPedidoApplication)
  private
    FPedidos: IPedidoRepository;
  public
    constructor Create(const APedidos: IPedidoRepository);
    function Consultar(
      const AQuery: TConsultarPedidoQuery;
      out APedido: TPedidoConsultaDto): Boolean;
  end;

implementation

uses
  System.SysUtils,
  Horizonte.Domain.Pedido;

function StatusToText(const AStatus: TPedidoStatus): string;
begin
  case AStatus of
    psAprovado: Result := 'aprovado';
    psFaturado: Result := 'faturado';
    psCancelado: Result := 'cancelado';
  else
    Result := 'pendente';
  end;
end;

constructor TConsultarPedido.Create(const APedidos: IPedidoRepository);
begin
  inherited Create;
  if not Assigned(APedidos) then
    raise EArgumentNilException.Create('O repositório de pedidos é obrigatório.');
  FPedidos := APedidos;
end;

function TConsultarPedido.Consultar(
  const AQuery: TConsultarPedidoQuery;
  out APedido: TPedidoConsultaDto): Boolean;
var
  LEntity: TPedido;
begin
  APedido := Default(TPedidoConsultaDto);
  LEntity := FPedidos.ObterPorId(AQuery.PedidoId);
  if not Assigned(LEntity) then
    Exit(False);
  try
    Result := (LEntity.EmpresaId = AQuery.EmpresaId) and
      (LEntity.FilialId = AQuery.FilialId);
    if not Result then
      Exit;
    APedido.Id := LEntity.Id;
    APedido.Numero := LEntity.Numero;
    APedido.Situacao := StatusToText(LEntity.Status);
    APedido.ClienteId := LEntity.ClienteId;
    APedido.ClienteNome := Format('Cliente %d', [LEntity.ClienteId]);
    APedido.ValorTotal := LEntity.ValorTotal;
    APedido.AtualizadoEm := LEntity.AtualizadoEm;
  finally
    LEntity.Free;
  end;
end;

end.
