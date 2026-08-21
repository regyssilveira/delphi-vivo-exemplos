param(
  [ValidateSet('Start', 'Stop', 'Reset', 'Migrate', 'Seed', 'Status')]
  [string]$Action = 'Start'
)

$ErrorActionPreference = 'Stop'
$composeFile = Join-Path $PSScriptRoot '..\database\compose\compose.yaml'
$container = 'horizonte-firebird'
$database = 'localhost:/var/lib/firebird/data/horizonte.fdb'

function Invoke-Compose([string[]]$Arguments) {
  & docker compose -f $composeFile @Arguments
  if ($LASTEXITCODE -ne 0) { throw "Docker Compose falhou com código $LASTEXITCODE." }
}

function Invoke-Isql([string]$ScriptPath) {
  Get-Content -Raw $ScriptPath |
    & docker exec -i $container /opt/firebird/bin/isql -user horizonte -password horizonte_dev $database
  if ($LASTEXITCODE -ne 0) { throw "isql falhou ao executar $ScriptPath." }
}

function Test-SchemaInitialized {
  $query = "set heading off; select count(*) from rdb`$relations where rdb`$relation_name = 'SCHEMA_VERSION';"
  $output = $query |
    & docker exec -i $container /opt/firebird/bin/isql -user horizonte -password horizonte_dev $database -q
  if ($LASTEXITCODE -ne 0) { throw 'Não foi possível consultar a versão do schema.' }
  return ($output -join ' ') -match '\b1\b'
}

function Test-MigrationApplied([int]$Version) {
  $query = "set heading off; select count(*) from SCHEMA_VERSION where VERSION_NO = $Version;"
  $output = $query |
    & docker exec -i $container /opt/firebird/bin/isql -user horizonte -password horizonte_dev $database -q
  if ($LASTEXITCODE -ne 0) { throw "Não foi possível consultar a migration $Version." }
  return ($output -join ' ') -match '\b1\b'
}

switch ($Action) {
  'Start' {
    Invoke-Compose @('up', '-d', '--wait')
  }
  'Stop' {
    Invoke-Compose @('down')
  }
  'Reset' {
    Invoke-Compose @('down', '--volumes')
  }
  'Migrate' {
    if (-not (Test-SchemaInitialized)) {
      Invoke-Isql (Join-Path $PSScriptRoot '..\database\migrations\001_create_schema.sql')
    }
    $migrationFiles = Get-ChildItem (Join-Path $PSScriptRoot '..\database\migrations') -Filter '*.sql' |
      Sort-Object Name
    foreach ($migrationFile in $migrationFiles) {
      $version = [int]$migrationFile.BaseName.Split('_')[0]
      if (-not (Test-MigrationApplied $version)) {
        Invoke-Isql $migrationFile.FullName
      }
    }
    Write-Host 'Todas as migrations foram aplicadas.'
  }
  'Seed' {
    Invoke-Isql (Join-Path $PSScriptRoot '..\database\seed\001_sample_data.sql')
  }
  'Status' {
    Invoke-Compose @('ps')
  }
}
