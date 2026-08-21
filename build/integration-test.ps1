param(
  [ValidateSet('Win32', 'Win64')]
  [string]$Platform = 'Win64',
  [ValidateSet('Debug', 'Release')]
  [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'
if (-not $env:HORIZONTE_FB_CLIENT) {
  throw 'Defina HORIZONTE_FB_CLIENT com o caminho absoluto do fbclient.dll correspondente à plataforma.'
}

& (Join-Path $PSScriptRoot 'database.ps1') -Action Start
$project = Join-Path $PSScriptRoot '..\tests\Horizonte.IntegrationTests\Horizonte.IntegrationTests.dproj'
$rsvars = 'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat'
$command = "call `"$rsvars`" && msbuild `"$project`" /t:Build /p:Config=$Configuration /p:Platform=$Platform /nologo /v:minimal"
& cmd.exe /d /c $command
if ($LASTEXITCODE -ne 0) { throw 'A compilação dos testes de integração falhou.' }

$testExe = Join-Path $PSScriptRoot "..\bin\$Platform\$Configuration\Horizonte.IntegrationTests.exe"
& $testExe
if ($LASTEXITCODE -ne 0) { throw 'Os testes de integração falharam.' }
