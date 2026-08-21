param(
  [ValidateSet('Debug', 'Release')]
  [string]$Configuration = 'Debug',

  [ValidateSet('Win32', 'Win64')]
  [string]$Platform = 'Win64'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$rsvars = 'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat'
$projects = @(
  'src\Horizonte.Desktop\Horizonte.Desktop.dproj',
  'src\Horizonte.Api\Horizonte.Api.dproj',
  'tests\Horizonte.UnitTests\Horizonte.UnitTests.dproj'
)

if (-not (Test-Path -LiteralPath $rsvars)) {
  throw "Delphi 13 não localizado em: $rsvars"
}

foreach ($relativeProject in $projects) {
  $project = Join-Path $repoRoot $relativeProject
  $command = 'call "{0}" && msbuild "{1}" /t:Build /p:Config={2} /p:Platform={3} /verbosity:minimal' -f `
    $rsvars, $project, $Configuration, $Platform
  & cmd.exe /d /s /c $command
  if ($LASTEXITCODE -ne 0) {
    throw "Build falhou para $relativeProject com código $LASTEXITCODE."
  }
}

Write-Host "Build concluído: $Platform/$Configuration"
