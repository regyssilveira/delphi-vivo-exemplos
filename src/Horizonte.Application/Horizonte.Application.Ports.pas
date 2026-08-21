unit Horizonte.Application.Ports;

interface

uses
  Horizonte.Domain.Pedido;

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

