# Indicadores de entrega e estabilidade

| Indicador | Definição operacional no Horizonte | Fonte |
|---|---|---|
| frequência de implantação | promoções concluídas por ambiente e plataforma | manifesto/release |
| lead time da mudança | commit elegível até pacote promovido | Git e pipeline |
| taxa de falha de mudança | implantações com rollback, correção urgente ou incidente | release e incidentes |
| tempo de restauração | detecção até serviço restabelecido e validado | logs e registro operacional |
| confiabilidade | cumprimento do objetivo operacional da fatia | health, erros e negócio |

Não há metas universais. O primeiro objetivo é tornar coleta e definição consistentes, sem ocultar falhas ou contar recompilações como entrega de valor.
