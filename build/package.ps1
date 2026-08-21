param(
  [ValidateSet('Win32', 'Win64')]
  [string]$Platform = 'Win64',
  [string]$Version = '0.2.0',
  [switch]$SkipIntegration
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
& (Join-Path $PSScriptRoot 'build.ps1') -Configuration Release -Platform $Platform
& (Join-Path $PSScriptRoot 'test.ps1') -Configuration Release -Platform $Platform

if (-not $SkipIntegration) {
  & (Join-Path $PSScriptRoot 'database.ps1') -Action Start
  & (Join-Path $PSScriptRoot 'database.ps1') -Action Migrate
  & (Join-Path $PSScriptRoot 'database.ps1') -Action Seed
  $client = Join-Path $root "tools\firebird\$Platform\fbclient.dll"
  if (-not (Test-Path -LiteralPath $client)) {
    & (Join-Path $PSScriptRoot 'prepare-firebird-client.ps1') -Platform $Platform
  }
  $env:HORIZONTE_FB_CLIENT = (Resolve-Path $client).Path
  & (Join-Path $PSScriptRoot 'integration-test.ps1') `
    -Platform $Platform -Configuration Release
}

$artifactsRoot = [IO.Path]::GetFullPath((Join-Path $root 'artifacts'))
$output = [IO.Path]::GetFullPath((Join-Path $artifactsRoot "horizonte-$Version-$Platform"))
if (-not $output.StartsWith($artifactsRoot + [IO.Path]::DirectorySeparatorChar,
  [StringComparison]::OrdinalIgnoreCase)) {
  throw 'O diretório calculado do pacote saiu da área artifacts.'
}
New-Item -ItemType Directory -Force -Path $artifactsRoot | Out-Null
if (Test-Path -LiteralPath $output) {
  Remove-Item -LiteralPath $output -Recurse -Force
}

$appDir = New-Item -ItemType Directory -Force -Path (Join-Path $output 'app')
$apiDir = New-Item -ItemType Directory -Force -Path (Join-Path $output 'api')
$databaseDir = New-Item -ItemType Directory -Force -Path (Join-Path $output 'database')
$configDir = New-Item -ItemType Directory -Force -Path (Join-Path $output 'config')
$contractDir = New-Item -ItemType Directory -Force -Path (Join-Path $output 'contracts')
$evidenceDir = New-Item -ItemType Directory -Force -Path (Join-Path $output 'evidence')

Copy-Item -LiteralPath (Join-Path $root "bin\$Platform\Release\Horizonte.Desktop.exe") -Destination $appDir
Copy-Item -LiteralPath (Join-Path $root "bin\$Platform\Release\Horizonte.Api.exe") -Destination $apiDir
Copy-Item -Path (Join-Path $root 'database\migrations\*.sql') -Destination $databaseDir
Copy-Item -LiteralPath (Join-Path $root 'config\appsettings.example.ini') -Destination $configDir
Copy-Item -LiteralPath (Join-Path $root 'docs\contratos\horizonte-api.yaml') -Destination $contractDir
Copy-Item -Path (Join-Path $root "bin\$Platform\Release\*-results.xml") -Destination $evidenceDir

$files = Get-ChildItem -LiteralPath $output -Recurse -File
$artifactEntries = foreach ($file in $files) {
  [ordered]@{
    arquivo = [IO.Path]::GetRelativePath($output, $file.FullName).Replace('\', '/')
    sha256 = (Get-FileHash -Algorithm SHA256 $file.FullName).Hash.ToLowerInvariant()
    tamanho = $file.Length
  }
}
$commit = (& git -C $root rev-parse HEAD 2>$null)
if (-not $commit) { $commit = 'working-tree' }
$manifest = [ordered]@{
  produto = 'ERP Horizonte'
  versao = $Version
  gitCommit = $commit
  build = if ($env:GITHUB_RUN_NUMBER) { $env:GITHUB_RUN_NUMBER } else { 'local' }
  geradoEmUtc = [DateTime]::UtcNow.ToString('o')
  delphi = '13 Florence / Studio 37.0'
  plataforma = $Platform
  configuracao = 'Release'
  schemaMinimo = 2
  assinaturaAplicada = $false
  artefatos = @($artifactEntries)
}
$manifestPath = Join-Path $output 'release-manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 $manifestPath

& (Join-Path $PSScriptRoot 'smoke-test.ps1') -PackageDirectory $output
$archive = "$output.zip"
Compress-Archive -Path (Join-Path $output '*') -DestinationPath $archive -Force
Write-Host "Pacote criado e verificado: $archive"
