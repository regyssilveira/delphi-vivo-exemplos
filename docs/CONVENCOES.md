# Convenções de código Delphi

Os exemplos seguem o estilo idiomático da RTL e da VCL: tipos `T`, interfaces `I`, exceções `E`, campos `F` e parâmetros `A` quando isso evita ambiguidade. Variáveis locais, métodos e propriedades usam PascalCase; booleanos possuem nomes afirmativos.

Units são nomeadas por produto, contexto e responsabilidade. Dependências ficam em `implementation` quando possível. A indentação é de dois espaços, os blocos usam `begin`/`end` explícitos e comentários explicam intenção ou restrição.

Objetos adquiridos localmente são liberados com `try..finally`. Exceções só são capturadas quando há tratamento, tradução, registro ou recuperação. A propriedade de objetos e interfaces deve permanecer clara.

SQL usa parâmetros. Transações pertencem ao caso de uso e não permanecem abertas durante interação com o usuário. Forms coordenam estado visual; regras que precisam de verificação migram para objetos testáveis. Arquivos `.pas` e `.dfm` são tratados como unidade inseparável.

Fixtures DUnitX terminam em `Tests` e os métodos descrevem comportamento observável. Testes unitários não dependem de ordem ou banco; testes de integração declaram infraestrutura e limpeza. Código chamado de completo deve compilar no Delphi 13 Florence e passar pelos scripts documentados.
