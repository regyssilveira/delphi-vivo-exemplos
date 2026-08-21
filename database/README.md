# Banco de dados

O ambiente de referência usa Firebird 5 em contêiner. Ele é descartável e não deve apontar para dados reais.

```powershell
.\build\database.ps1 -Action Start
.\build\database.ps1 -Action Migrate
.\build\database.ps1 -Action Seed
```

Para encerrar, use `-Action Stop`. Para apagar também o volume de desenvolvimento, use `-Action Reset`; essa operação remove somente o volume nomeado pelo Compose deste repositório.

As credenciais padrão são exclusivamente locais. Copie `config/appsettings.example.ini` para `config/appsettings.ini` e ajuste-as sem versionar o arquivo.
