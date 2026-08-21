# Registro de coexistência e feature flags

| Flag/caminho | Padrão | Dono | Telemetria | Condição de retirada |
|---|---|---|---|---|
| `NovoFaturamento` | piloto | Vendas | sucesso, falha e resultado desconhecido | ondas homologadas e caminho antigo sem uso |
| API de consulta v1 | ativa no portal piloto | Plataforma | requisições por rota e status | contrato substituto com convivência |
| Desktop Win32 | clientes bloqueados | Release | instalações por arquitetura | dependências Win64 homologadas |

As flags representam o caso narrativo e não estão habilitadas por configuração no executável didático. Em produto real, cada flag precisa de origem segura, data de expiração e remoção de código após estabilização.
