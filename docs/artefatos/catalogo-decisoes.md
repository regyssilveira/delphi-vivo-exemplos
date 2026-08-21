# Catálogo de decisões da migração

| Decisão | Contexto | Evidência | Consequência | Revisar quando |
|---|---|---|---|---|
| Delphi 13 Win32 antes de Win64 | DLLs antigas | matriz de compatibilidade | duas plataformas temporárias | bloqueadores Win64 forem retirados |
| VCL permanece | telas entregam valor | smoke e homologação | modernização sem reescrita visual | novo canal justificar outra UI |
| FireDAC por fatia | DataModule global | integração Firebird 5 | coexistência de acesso a dados | fatia seguinte for priorizada |
| API inicia por leitura | portal é consumidor | contrato e testes | sem idempotência de escrita ainda | comando HTTP for autorizado |
| Firebird 5 em Docker | banco descartável | migrations repetíveis | não representa topologia produtiva | homologação operacional |
