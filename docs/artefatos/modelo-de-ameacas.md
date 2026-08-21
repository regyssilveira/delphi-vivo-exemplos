# Modelo de ameaças da fatia de faturamento

| Ativo/fronteira | Ameaça | Controle mínimo | Evidência |
|---|---|---|---|
| configuração | segredo versionado | arquivo local ignorado e rotação | scanner + revisão |
| banco Firebird | privilégio excessivo | usuário da aplicação sem SYSDBA | teste de conexão e grants |
| API | acesso a pedido alheio | autenticação e autorização contextual | teste de contrato/autorização |
| logs | vazamento de dados | allowlist de campos e sanitização | revisão de eventos |
| uso de IA | envio de código/log privado | contexto mínimo autorizado | registro de uso e política |
