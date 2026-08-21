# Mapa do Sistema Legado

```text
ERP Horizonte XE7 / Win32
├── Código próprio: Clientes, Produtos, Vendas, Estoque, Financeiro e Fiscal
├── Forms VCL e DataModules compartilhados
├── Firebird e camada histórica de acesso a dados
├── Componentes visuais, fiscais e de relatórios
├── DLL bancária exclusivamente Win32
├── Integrações: fiscal, cobrança, pagamentos e consultas
├── Configuração: INI, Registry e arquivos locais
└── Build/deploy: estação preparada, cópia e atualização manual
```

| Item | Origem | Evidência necessária | Bloqueio Delphi 13/Win64 | Estratégia |
|---|---|---|---|---|
| Projeto principal | Git interno fictício | commit e build XE7 | projeto convertido pela IDE | preservar cópia e migrar em branch |
| Componente fiscal | fornecedor | instalador, fonte, licença e contrato | versão compatível a confirmar | encapsular e testar contrato |
| DLL bancária | banco | SDK e matriz de arquitetura | somente Win32 | processo isolado e substituição |
| Relatórios alterados | pasta histórica | diff contra fornecedor | package local | separar patches e homologar |

Este mapa descreve o estado fictício inicial. O código moderno deste repositório começa na fatia que já chegou ao laboratório Delphi 13; não redistribui o ERP XE7 nem componentes comerciais.
