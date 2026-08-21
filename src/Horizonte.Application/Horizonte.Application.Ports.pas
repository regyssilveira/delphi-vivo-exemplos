unit Horizonte.Application.Ports;

interface

uses
  Horizonte.Domain.Pedido,
  Horizonte.Domain.Types;

type
  IPedidoRepository = interface
    function ObterPorId(const APedidoId: Integer): TPedido;
    procedure Atualizar(const APedido: TPedido);
  end;

  ICreditoService = interface
    function PossuiCredito(
      const AClienteId: Integer;
      const AValor: Currency): Boolean;
  end;

  IEstoqueService = interface
    function Reservar(const APedidoId: Integer): Boolean;
    procedure Liberar(const APedidoId: Integer);
  end;

  IEstoqueApplication = interface
    ['{C35CF2E0-026B-4EE1-A6AB-D34972C4AB13}']
    function ConsultarDisponibilidade(
      const AProdutoId: Integer;
      const AFilialId: Integer): TDisponibilidadeEstoque;
    procedure ReservarPedido(const APedidoId: Integer);
  end;

  IConsultaPedidoApplication = interface
    ['{4D4D5C53-8EF7-4F00-AB4B-AB6E6497D3CC}']
    function Consultar(
      const AQuery: TConsultarPedidoQuery;
      out APedido: TPedidoConsultaDto): Boolean;
  end;

  IIntegracaoFiscal = interface
    function Emitir(
      const APedido: TPedido;
      const AUsuarioId: Integer;
      const AInstante: TDateTime): Integer;
  end;

  IUnitOfWork = interface
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
  end;

implementation

end.
