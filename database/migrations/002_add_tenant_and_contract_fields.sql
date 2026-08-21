alter table PEDIDO add EMPRESA_ID integer default 1 not null;
alter table PEDIDO add FILIAL_ID integer default 1 not null;
alter table PEDIDO add NUMERO varchar(30);
alter table PEDIDO add ATUALIZADO_EM timestamp default current_timestamp not null;

update PEDIDO
set NUMERO = 'PV-' || cast(ID as varchar(20))
where NUMERO is null;

alter table PEDIDO alter NUMERO set not null;

insert into SCHEMA_VERSION (VERSION_NO, DESCRIPTION)
values (2, 'Tenant e campos do contrato público de pedidos');

commit;
