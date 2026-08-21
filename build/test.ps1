param(
  [ValidateSet('Debug', 'Release')]
  [string]$Configuration = 'Debug',

  [ValidateSet('Win32', 'Win64')]
  [string]$Platform = 'Win64'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$testExecutable = Join-Path $repoRoot "bin\$Platform\$Configuration\Horizonte.UnitTests.exe"

if (-not (Test-Path -LiteralPath $testExecutable)) {
  & (Join-Path $PSScriptRoot 'build.ps1') -Configuration $Configuration -Platform $Platform
}

& $testExecutable
if ($LASTEXITCODE -ne 0) {
  throw "Testes falharam com código $LASTEXITCODE."
}

Write-Host "Testes aprovados: $Platform/$Configuration"

