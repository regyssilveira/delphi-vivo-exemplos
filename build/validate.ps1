$ErrorActionPreference = 'Stop'

foreach ($platform in 'Win32', 'Win64') {
  & (Join-Path $PSScriptRoot 'build.ps1') -Configuration Release -Platform $platform
  & (Join-Path $PSScriptRoot 'test.ps1') -Configuration Release -Platform $platform
}

Write-Host 'Validação completa concluída.'

