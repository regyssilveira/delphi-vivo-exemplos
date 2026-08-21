unit Horizonte.Domain.Types;

interface

type
  TPedidoStatus = (psPendente, psAprovado, psFaturado, psCancelado);

  TFaturamentoStatus = (
    fsSucesso,
    fsPedidoNaoEncontrado,
    fsPedidoNaoAprovado,
    fsCreditoRecusado,
    fsEstoqueIndisponivel,
    fsFalhaFiscal
  );

  TFaturarPedidoCommand = record
    PedidoId: Integer;
    UsuarioId: Integer;
    Instante: TDateTime;
  end;

  TFaturamentoResult = record
  private
    FStatus: TFaturamentoStatus;
    FFaturaId: Integer;
    FMensagem: string;
  public
    class function Create(
      const AStatus: TFaturamentoStatus;
      const AMensagem: string;
      const AFaturaId: Integer = 0): TFaturamentoResult; static;
    property Status: TFaturamentoStatus read FStatus;
    property FaturaId: Integer read FFaturaId;
    property Mensagem: string read FMensagem;
    function Sucesso: Boolean;
  end;

implementation

class function TFaturamentoResult.Create(
  const AStatus: TFaturamentoStatus;
  const AMensagem: string;
  const AFaturaId: Integer): TFaturamentoResult;
begin
  Result.FStatus := AStatus;
  Result.FMensagem := AMensagem;
  Result.FFaturaId := AFaturaId;
end;

function TFaturamentoResult.Sucesso: Boolean;
begin
  Result := FStatus = fsSucesso;
end;

end.

