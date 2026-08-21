# Política mínima de logs

Cada operação de faturamento deve registrar início, resultado e duração com `correlation_id`, `pedido_id`, operação, componente e categoria do resultado. Falha interna, rejeição de negócio e resultado externo desconhecido são eventos diferentes.

Não registrar senha, token, documento fiscal completo, payload integral, dados bancários ou mensagem de exceção sem sanitização. Logs de desenvolvimento usam dados fictícios; retenção e acesso devem ser definidos pelo ambiente.

Exemplo de evento:

```json
{"timestamp":"2026-08-20T14:00:00-03:00","level":"Information","event":"pedido_faturado","correlation_id":"8ef...","pedido_id":1,"duration_ms":84}
```
