param(
  [ValidateSet('Win32', 'Win64')]
  [string]$Platform = 'Win64',
  [string]$Version = '0.1.0'
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'build.ps1') -Configuration Release -Platform $Platform
& (Join-Path $PSScriptRoot 'test.ps1') -Configuration Release -Platform $Platform

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$output = Join-Path $root "artifacts\horizonte-$Version-$Platform"
New-Item -ItemType Directory -Force -Path $output | Out-Null
$executable = Join-Path $root "bin\$Platform\Release\Horizonte.Desktop.exe"
Copy-Item -LiteralPath $executable -Destination $output -Force
$hash = (Get-FileHash -Algorithm SHA256 $executable).Hash.ToLowerInvariant()
$commit = (& git -C $root rev-parse HEAD 2>$null)
if (-not $commit) { $commit = 'working-tree' }
$manifest = [ordered]@{
  produto = 'ERP Horizonte'
  versao = $Version
  gitCommit = $commit
  delphi = '13 Florence / Studio 37.0'
  plataforma = $Platform
  configuracao = 'Release'
  schemaDatabase = 1
  artefatos = @(@{ arquivo = 'Horizonte.Desktop.exe'; sha256 = $hash })
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 (Join-Path $output 'release-manifest.json')
Compress-Archive -Path (Join-Path $output '*') -DestinationPath "$output.zip" -Force
Write-Host "Pacote criado: $output.zip"
