set sql dialect 3;

create table SCHEMA_VERSION (
  VERSION_NO integer not null,
  DESCRIPTION varchar(120) not null,
  APPLIED_AT timestamp default current_timestamp not null,
  constraint PK_SCHEMA_VERSION primary key (VERSION_NO)
);

create table PEDIDO (
  ID integer not null,
  CLIENTE_ID integer not null,
  VALOR_TOTAL numeric(15,2) not null,
  STATUS varchar(20) not null,
  FATURA_ID integer,
  constraint PK_PEDIDO primary key (ID),
  constraint CK_PEDIDO_VALOR check (VALOR_TOTAL > 0),
  constraint CK_PEDIDO_STATUS check (STATUS in ('PENDENTE', 'APROVADO', 'FATURADO', 'CANCELADO'))
);

insert into SCHEMA_VERSION (VERSION_NO, DESCRIPTION)
values (1, 'Esquema inicial do ERP Horizonte');

commit;
