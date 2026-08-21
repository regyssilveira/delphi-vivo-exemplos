# Evolução prática pelos 15 capítulos

| Nº | Decisão no ERP Horizonte | Material deste repositório |
|---:|---|---|
| 1 | Preservar valor antes de discutir reescrita | [Mapa de valor](../artefatos/mapa-de-valor.md) |
| 2 | Dar nome a projetos, dependências e bloqueadores | [Inventário](../artefatos/inventario-dependencias.csv) |
| 3 | Priorizar a fatia Vendas/Faturamento por risco | [Matriz de risco](../artefatos/matriz-de-risco.csv) |
| 4 | Criar baseline e build fora da IDE | `build/build.ps1` e manifesto de release |
| 5 | Caracterizar comportamento antes da refatoração | `tests/Horizonte.UnitTests` |
| 6 | Migrar em lotes pequenos e manter o build verde | [Diário de migração](../artefatos/diario-de-migracao.md) |
| 7 | Retirar faturamento do evento VCL | `Horizonte.Application.FaturarPedido.pas` |
| 8 | Colocar FireDAC e transação atrás de portas | `Horizonte.Infrastructure.FireDAC.pas`, migrations e integração |
| 9 | Criar fronteiras dentro do monólito | [Arquitetura](../ARQUITETURA.md) e verificação de dependências |
| 10 | Introduzir API somente para consumidor real | [Contrato HTTP](../contratos/horizonte-api.yaml) |
| 11 | Manter desktop, API e legado em coexistência | [Plano de coexistência](../artefatos/plano-de-coexistencia.md) |
| 12 | Produzir artefatos repetíveis | scripts `build/`, workflow e [manifesto](../artefatos/release-manifest.example.json) |
| 13 | Correlacionar operações e proteger logs | [Política de logs](../observabilidade/POLITICA_DE_LOGS.md) |
| 14 | Tratar dependências, segredos e IA continuamente | [Política de IA](../ia/POLITICA_DE_USO.md) e [ameaças](../artefatos/modelo-de-ameacas.md) |
| 15 | Transformar a primeira fatia em programa contínuo | [Roadmap 6/12/24 meses](../artefatos/roadmap-6-12-24.md) |

As tags de capítulo são marcos de leitura, não quinze aplicações independentes. O estado completo permanece na branch principal; cada tag permite comparar o que foi acrescentado à segurança de mudança.
