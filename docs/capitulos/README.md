# Evolução prática pelos 15 capítulos

| Nº | Decisão no ERP Horizonte | Material deste repositório |
|---:|---|---|
| 1 | Preservar valor antes de discutir reescrita | [Mapa de valor](../artefatos/mapa-de-valor.md) e [mapa do legado](../artefatos/mapa-do-sistema-legado.md) |
| 2 | Dar nome a projetos, dependências e bloqueadores | [Inventário](../artefatos/inventario-dependencias.csv) e [compatibilidade Delphi 13](../artefatos/matriz-compatibilidade-delphi13.csv) |
| 3 | Priorizar a fatia Vendas/Faturamento por risco | [Matriz de risco](../artefatos/matriz-de-risco.csv) |
| 4 | Criar baseline e build fora da IDE | `build/build.ps1`, [relatório de build](../artefatos/relatorio-build-delphi13.md) e [rollback](../artefatos/checklist-rollback.md) |
| 5 | Caracterizar comportamento antes da refatoração | `tests/Horizonte.UnitTests` e [golden master](../artefatos/golden-master-faturamento.json) |
| 6 | Migrar em lotes pequenos e manter o build verde | [Diário de migração](../artefatos/diario-de-migracao.md) |
| 7 | Retirar faturamento do evento VCL | `Horizonte.Application.FaturarPedido.pas` e [catálogo de decisões](../artefatos/catalogo-decisoes.md) |
| 8 | Colocar FireDAC e transação atrás de portas | `Horizonte.Infrastructure.FireDAC.pas`, migrations e integração |
| 9 | Criar fronteiras dentro do monólito | [Arquitetura](../ARQUITETURA.md), [mapa de módulos](../artefatos/mapa-de-modulos.md) e `build/architecture-test.ps1` |
| 10 | Introduzir API somente para consumidor real | [Contrato HTTP](../contratos/horizonte-api.yaml) |
| 11 | Manter desktop, API e legado em coexistência | [Plano de coexistência](../artefatos/plano-de-coexistencia.md), [feature flags](../artefatos/feature-flags.md) e [ondas de clientes](../artefatos/ondas-de-clientes.csv) |
| 12 | Produzir artefatos repetíveis | scripts `build/`, workflow, [manifesto](../artefatos/release-manifest.example.json), deploy e rollback |
| 13 | Correlacionar operações e proteger logs | [Política de logs](../observabilidade/POLITICA_DE_LOGS.md), logger JSON Lines e [indicadores DORA](../artefatos/indicadores-dora.md) |
| 14 | Tratar dependências, segredos e IA continuamente | [Política de IA](../ia/POLITICA_DE_USO.md), [ameaças](../artefatos/modelo-de-ameacas.md), [vulnerabilidades](../artefatos/backlog-vulnerabilidades.csv) e [calendário](../artefatos/calendario-componentes.csv) |
| 15 | Transformar a primeira fatia em programa contínuo | [Roadmap 6/12/24 meses](../artefatos/roadmap-6-12-24.md) e [critérios de encerramento do XE7](../artefatos/criterios-encerramento-xe7.md) |

As tags `edicao-2026-capitulo-*` são marcos de leitura, não quinze aplicações independentes. Capítulos que formam uma mesma mudança atômica podem apontar para o mesmo commit; a release da edição contém o estado completo. As tags curtas `capitulo-*` permanecem intocadas como histórico da v0.1.
