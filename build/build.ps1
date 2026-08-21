param(
  [ValidateSet('Debug', 'Release')]
  [string]$Configuration = 'Debug',

  [ValidateSet('Win32', 'Win64')]
  [string]$Platform = 'Win64'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$delphiRoot = $env:BDS
if (-not $delphiRoot) {
  $delphiRoot = 'C:\Program Files (x86)\Embarcadero\Studio\37.0'
}
$rsvars = Join-Path $delphiRoot 'bin\rsvars.bat'
$project = Join-Path $repoRoot 'src\Horizonte.groupproj'

if (-not (Test-Path -LiteralPath $rsvars)) {
  throw "Delphi 13 não localizado em: $rsvars"
}

$command = 'call "{0}" && msbuild "{1}" /t:Build /p:Config={2} /p:Platform={3} /verbosity:minimal' -f `
  $rsvars, $project, $Configuration, $Platform
& cmd.exe /d /s /c $command
if ($LASTEXITCODE -ne 0) {
  throw "Build falhou para $project com código $LASTEXITCODE."
}

Write-Host "Build concluído: $Platform/$Configuration"
