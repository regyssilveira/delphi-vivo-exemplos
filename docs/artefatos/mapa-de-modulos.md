# Mapa de módulos e contratos

```text
Presentation: Horizonte.Desktop | Horizonte.Api
                         ↓
Application: FaturarPedido | ConsultarPedido | IEstoqueApplication
                         ↓
Domain: Pedido | status | DTOs de fronteira
                         ↑
Infrastructure: InMemory | FireDAC | Logging | Firebird
```

| Módulo | Possui | Expõe | Não expõe |
|---|---|---|---|
| Vendas | pedido e faturamento | consulta e faturamento | Form, dataset ou SQL |
| Estoque | saldo e reserva | disponibilidade e reserva | query interna |
| Financeiro | títulos | consequência financeira futura | tabela compartilhada |
| Fiscal | emissão | `IIntegracaoFiscal` | SDK do fornecedor |

`build/architecture-test.ps1` impede dependências de Domain/Application para VCL, FireDAC ou Infrastructure e impede a API de acessar FireDAC diretamente.
