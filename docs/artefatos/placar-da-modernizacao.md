# Placar verificável da primeira fatia

Este placar separa fatos reproduzíveis do repositório de resultados que somente uma implantação real poderia produzir. O ERP Horizonte é fictício; portanto, não atribuímos a ele quantidades inventadas de clientes, pedidos, incidentes ou ganhos de produtividade.

## Evidência executável da release v0.2.0

| Dimensão | Resultado verificável | Como reproduzir |
|---|---|---|
| compilação | Delphi 13, Win32 e Win64 | `build/validate.ps1` |
| testes unitários | 5 por plataforma | `build/test.ps1` |
| testes de contrato HTTP | 7 por plataforma | `build/test.ps1` |
| testes de integração | 2 por plataforma, com Firebird 5 | `build/integration-test.ps1` |
| persistência | 2 migrations versionadas | `build/database.ps1 -Action Migrate` |
| contrato HTTP | consulta de pedido e disponibilidade de estoque | `docs/contratos/horizonte-api.yaml` |
| entrega | ZIP Win32 e Win64, manifesto com hashes e smoke test | `build/package.ps1` |
| observabilidade | eventos JSON Lines e propagação de `correlationId` | testes de contrato e unitários |
| recuperação | promoção e rollback ensaiáveis em diretório controlado | `build/deploy.ps1` e `build/rollback.ps1` |

Quantidade de testes não equivale a cobertura de um ERP completo. Ela comprova apenas os comportamentos explicitamente exercitados pela fatia didática.

## Indicadores para uma adoção real

Preencha estes campos com dados da sua operação. Use “não medido” quando não houver fonte; zero significa que houve observação e nenhum evento ocorreu.

| Indicador | Tipo | Baseline | Atual | Meta | Fonte e janela | Decisão associada |
|---|---|---:|---:|---:|---|---|
| tempo e taxa de conclusão do faturamento | negócio | não medido | não medido | definir | telemetria e processo | promover ou pausar onda |
| incidentes que impedem faturamento | negócio | não medido | não medido | definir | suporte por release | priorizar correção |
| lead time de mudança | entrega | não medido | não medido | definir | Git e pipeline | ajustar tamanho da fatia |
| proporção de mudanças com falha | entrega | não medido | não medido | definir | releases e incidentes | ampliar ou restringir promoção |
| tempo de recuperação | entrega | não medido | não medido | definir | incidentes e deploy | revisar rollback |
| dependências críticas sem estratégia | risco | inventariar | inventariar | definir | catálogo de componentes | substituir, encapsular ou aceitar |
| clientes no caminho novo e antigo | transição | inventariar | inventariar | definir | versões e telemetria | planejar próxima onda |
| tráfego no contrato antigo | transição | não medido | não medido | definir | logs por versão | retirar ou manter adaptador |

## Regra de interpretação

Cada número deve ser marcado como:

- **baseline observada**;
- **resultado observado**;
- **meta**;
- **hipótese**;
- **não medido**.

Contagens do código demonstram existência e reprodutibilidade. Benefício de negócio exige dados da operação.
