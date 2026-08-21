param(
  [ValidateSet('Win32', 'Win64', 'All')]
  [string]$Platform = 'All'
)

$ErrorActionPreference = 'Stop'
$packages = @{
  Win32 = @{
    Url = 'https://github.com/FirebirdSQL/firebird/releases/download/v5.0.3/Firebird-5.0.3.1683-0-windows-x86.zip'
    Sha256 = '1c0cd191351c1f0adf936a5c393322c438f3d8b30f0fd5eda5bfa813e175b0fb'
  }
  Win64 = @{
    Url = 'https://github.com/FirebirdSQL/firebird/releases/download/v5.0.3/Firebird-5.0.3.1683-0-windows-x64.zip'
    Sha256 = '3e3c38fde46ff1d73cb964c1422a4535892bd2a8e5b6ea692685639a225cf3bd'
  }
}

$selected = if ($Platform -eq 'All') { @('Win32', 'Win64') } else { @($Platform) }
foreach ($current in $selected) {
  $target = Join-Path $PSScriptRoot "..\tools\firebird\$current"
  $archive = Join-Path ([System.IO.Path]::GetTempPath()) "firebird-5.0.3-$current.zip"
  Invoke-WebRequest -Uri $packages[$current].Url -OutFile $archive
  $actualHash = (Get-FileHash -Algorithm SHA256 $archive).Hash.ToLowerInvariant()
  if ($actualHash -ne $packages[$current].Sha256) {
    throw "Hash inválido para o cliente Firebird $current."
  }
  New-Item -ItemType Directory -Force -Path $target | Out-Null
  Expand-Archive -LiteralPath $archive -DestinationPath $target -Force
  Remove-Item -LiteralPath $archive
  Write-Host "Cliente Firebird $current preparado em $target"
}
