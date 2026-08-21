# Plano de coexistência

| Caminho | Estado | Motivo | Condição de retirada |
|---|---|---|---|
| ERP XE7 Win32 | manutenção limitada | clientes ainda dependem de componentes antigos | ondas Delphi 13 homologadas e rollback ensaiado |
| ERP Delphi 13 Win32 | transição | preserva DLLs de 32 bits | bloqueadores Win64 substituídos |
| ERP Delphi 13 Win64 | alvo principal | plataforma suportada e maior horizonte operacional | permanece enquanto atender ao produto |
| Consulta por API | capacidade nova | portal B2B possui consumidor real | substituída somente por contrato versionado |
