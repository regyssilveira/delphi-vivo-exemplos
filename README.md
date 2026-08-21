# Delphi Vivo — exemplos do ERP Horizonte

[![Licença Apache 2.0](https://img.shields.io/badge/licen%C3%A7a-Apache%202.0-blue.svg)](LICENSE)
[![Delphi 13](https://img.shields.io/badge/Delphi-13%20Florence-red.svg)](https://www.embarcadero.com/products/delphi)
[![Firebird 5](https://img.shields.io/badge/Firebird-5.0.3-orange.svg)](https://firebirdsql.org/en/firebird-5-0-3/)

Repositório prático do livro **Delphi Vivo: Como modernizar sistemas existentes sem reescrever tudo**. O ERP Horizonte é um caso fictício e composto, construído para que equipes reconheçam problemas reais de aplicações Delphi longevas sem expor código ou dados de empresas.

O exemplo demonstra modernização progressiva: a aplicação VCL continua útil enquanto regras saem dos Forms, casos de uso ganham testes, a persistência migra para FireDAC e o processo passa a produzir builds repetíveis em Win32 e Win64.

## Estado verificável

- Delphi 13 Florence (Studio 37.0), VCL e MSBuild;
- domínio e caso de uso de faturamento independentes da UI;
- adaptadores em memória e FireDAC;
- Firebird 5.0.3 descartável via Docker Compose;
- 4 testes unitários DUnitX em Win32 e Win64;
- 2 testes de integração FireDAC/Firebird em Win32 e Win64;
- scripts sem paths pessoais ou senhas de produção;
- licença Apache 2.0.

O workflow é manual porque o compilador Delphi exige um runner Windows licenciado e configurado com o rótulo `delphi-13`. Isso evita prometer uma build em runners públicos que não possuem o toolchain.

## Comece em cinco minutos

Pré-requisitos: Windows, RAD Studio/Delphi 13 Florence com suporte Win32 e Win64, PowerShell 7 e Docker Desktop.

```powershell
git clone https://github.com/regyssilveira/delphi-vivo-exemplos.git
cd delphi-vivo-exemplos
.\build\validate.ps1
.\build\database.ps1 -Action Start
.\build\database.ps1 -Action Migrate
.\build\database.ps1 -Action Seed
.\build\prepare-firebird-client.ps1 -Platform Win64
$env:HORIZONTE_FB_CLIENT=(Resolve-Path .\tools\firebird\Win64\fbclient.dll).Path
.\build\integration-test.ps1 -Platform Win64
.\build\package.ps1 -Platform Win64 -Version 0.1.0
```

Abra `src/Horizonte.Desktop/Horizonte.Desktop.dproj` para executar a aplicação VCL. O exemplo da tela usa adaptadores em memória para permanecer executável mesmo sem banco; a implementação FireDAC é exercitada pela suíte de integração. O host didático em `src/Horizonte.Api` executa o contrato de consulta na porta 8080; use `X-Api-Key: horizonte-local-only` somente no laboratório local.

## Arquitetura da fatia

```text
Horizonte.Desktop (VCL)
        ↓
Horizonte.Application (caso de uso e portas)
        ↓
Horizonte.Domain (regras e invariantes)
        ↑
Horizonte.Infrastructure (InMemory / FireDAC / Firebird 5)
```

O sentido das dependências permite testar o comportamento sem abrir Forms ou conectar ao banco. Isso não declara que todo ERP precisa adotar a mesma arquitetura; registra a menor fronteira que resolveu o problema do faturamento.

## Navegação pelo livro

O [guia dos 15 capítulos](docs/capitulos/README.md) relaciona problema, artefato e estado da evolução. As tags `capitulo-01` a `capitulo-15` registram marcos didáticos; a release da edição reúne o estado completo e validado.

## Estrutura

```text
src/        domínio, aplicação, infraestrutura e desktop VCL
tests/      testes unitários e de integração DUnitX
database/   migrations, seed e Docker Compose do Firebird 5
build/      build, testes, banco e validação
docs/       arquitetura, capítulos, IA e artefatos reutilizáveis
config/     modelo de configuração sem segredos
```

## Limites didáticos

Emissão fiscal, crédito e estoque são simulados porque integrações comerciais e credenciais não podem ser redistribuídas. O caso de uso, a transação, os erros e as portas são completos. A API demonstra host, contrato e respostas; autenticação robusta, TLS, rate limiting e operação de backend em produção ficam fora do escopo desta obra.

## Segurança e contribuições

Leia [SECURITY.md](SECURITY.md), a [política de IA](docs/ia/POLITICA_DE_USO.md) e [CONTRIBUTING.md](CONTRIBUTING.md). Nunca abra issue com código proprietário, credenciais, logs ou dados pessoais de clientes.

## Licença

Código e documentação são distribuídos sob a [Apache License 2.0](LICENSE). Delphi, RAD Studio e Embarcadero são marcas de seus respectivos titulares. Firebird é um projeto independente. Este repositório não distribui componentes comerciais nem o compilador Delphi.
