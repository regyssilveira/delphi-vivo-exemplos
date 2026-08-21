# Arquitetura e decisões

## Contexto

O ERP Horizonte começou como um executável VCL Win32 que acessava o banco diretamente. A modernização mantém o desktop e extrai somente a fatia de faturamento, escolhida por criticidade, frequência de mudança e possibilidade de verificação.

## Decisões

1. **Domínio sem VCL e FireDAC.** `TPedido` protege transições de estado e pode ser exercitado pelo DUnitX.
2. **Application coordena a transação.** `TFaturarPedido` decide a ordem entre crédito, estoque, persistência e fiscal.
3. **Portas específicas.** Os contratos usam vocabulário de negócio e evitam um repositório genérico artificial.
4. **Infraestrutura substituível.** InMemory acelera testes; FireDAC comprova o caminho real no Firebird.
5. **Composição na borda.** O Form conhece a montagem, mas o caso de uso não conhece o Form.
6. **Win64 principal e Win32 compatível.** As duas plataformas são compiladas para revelar premissas arquiteturais cedo.

## Propriedade e ciclo de vida

Interfaces mantêm vivos os adaptadores de aplicação. A conexão FireDAC é criada e liberada pelo ponto de composição; repositório e unidade de trabalho a utilizam sem assumir sua propriedade. Objetos de domínio retornados por repositórios pertencem ao chamador.

## Simplificações explícitas

- estoque, crédito e fiscal usam simuladores determinísticos;
- autenticação e API completa não pertencem ao escopo deste livro;
- migrations são pequenas e lineares; produtos reais devem registrar execução e compatibilidade de rollback;
- credenciais padrão servem somente ao contêiner local descartável.
