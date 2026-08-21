param(
  [ValidateSet('Debug', 'Release')]
  [string]$Configuration = 'Debug',

  [ValidateSet('Win32', 'Win64')]
  [string]$Platform = 'Win64'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$testExecutables = @(
  (Join-Path $repoRoot "bin\$Platform\$Configuration\Horizonte.UnitTests.exe"),
  (Join-Path $repoRoot "bin\$Platform\$Configuration\Horizonte.ContractTests.exe")
)

if ($testExecutables.Where({ -not (Test-Path -LiteralPath $_) }).Count -gt 0) {
  & (Join-Path $PSScriptRoot 'build.ps1') -Configuration $Configuration -Platform $Platform
}

foreach ($testExecutable in $testExecutables) {
  & $testExecutable
  if ($LASTEXITCODE -ne 0) {
    throw "Testes falharam em $testExecutable com código $LASTEXITCODE."
  }
}

Write-Host "Testes aprovados: $Platform/$Configuration"
