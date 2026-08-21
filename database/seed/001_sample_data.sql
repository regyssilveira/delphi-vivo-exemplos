update or insert into PEDIDO (ID, CLIENTE_ID, VALOR_TOTAL, STATUS, FATURA_ID, EMPRESA_ID, FILIAL_ID, NUMERO, ATUALIZADO_EM)
values (1, 101, 1250.50, 'APROVADO', null, 1, 1, 'PV-2026-000001', current_timestamp)
matching (ID);

update or insert into PEDIDO (ID, CLIENTE_ID, VALOR_TOTAL, STATUS, FATURA_ID, EMPRESA_ID, FILIAL_ID, NUMERO, ATUALIZADO_EM)
values (2, 102, 300.00, 'PENDENTE', null, 1, 2, 'PV-2026-000002', current_timestamp)
matching (ID);

update or insert into PEDIDO (ID, CLIENTE_ID, VALOR_TOTAL, STATUS, FATURA_ID, EMPRESA_ID, FILIAL_ID, NUMERO, ATUALIZADO_EM)
values (3, 103, 890.90, 'FATURADO', 9001, 2, 1, 'PV-2026-000003', current_timestamp)
matching (ID);

commit;
