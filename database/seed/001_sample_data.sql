update or insert into PEDIDO (ID, CLIENTE_ID, VALOR_TOTAL, STATUS, FATURA_ID)
values (1, 101, 1250.50, 'APROVADO', null)
matching (ID);

update or insert into PEDIDO (ID, CLIENTE_ID, VALOR_TOTAL, STATUS, FATURA_ID)
values (2, 102, 300.00, 'PENDENTE', null)
matching (ID);

update or insert into PEDIDO (ID, CLIENTE_ID, VALOR_TOTAL, STATUS, FATURA_ID)
values (3, 103, 890.90, 'FATURADO', 9001)
matching (ID);

commit;
