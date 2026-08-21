param(
  [Parameter(Mandatory)] [string]$PackageDirectory,
  [Parameter(Mandatory)] [string]$TargetDirectory
)

$ErrorActionPreference = 'Stop'
$package = (Resolve-Path -LiteralPath $PackageDirectory).Path
$target = [IO.Path]::GetFullPath($TargetDirectory)
if ([IO.Path]::GetPathRoot($target) -eq $target) {
  throw 'O destino não pode ser a raiz de uma unidade.'
}
& (Join-Path $PSScriptRoot 'smoke-test.ps1') -PackageDirectory $package
$backup = "$target.previous"
if (Test-Path -LiteralPath $target) {
  if (Test-Path -LiteralPath $backup) {
    throw "Já existe um backup pendente: $backup"
  }
  Move-Item -LiteralPath $target -Destination $backup
}
New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -Path (Join-Path $package '*') -Destination $target -Recurse -Force
Write-Host "Pacote promovido para $target. Backup: $backup"
