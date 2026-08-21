param(
  [Parameter(Mandatory)]
  [string]$PackageDirectory
)

$ErrorActionPreference = 'Stop'
$package = (Resolve-Path -LiteralPath $PackageDirectory).Path
$manifestPath = Join-Path $package 'release-manifest.json'
$manifest = Get-Content -Raw $manifestPath | ConvertFrom-Json
foreach ($artifact in $manifest.artefatos) {
  $file = Join-Path $package $artifact.arquivo
  if (-not (Test-Path -LiteralPath $file)) {
    throw "Artefato ausente no pacote: $($artifact.arquivo)"
  }
  $actual = (Get-FileHash -Algorithm SHA256 $file).Hash.ToLowerInvariant()
  if ($actual -ne $artifact.sha256) {
    throw "Hash divergente no pacote: $($artifact.arquivo)"
  }
}

$api = Join-Path $package 'api\Horizonte.Api.exe'
$env:HORIZONTE_API_PORT = '18082'
$env:HORIZONTE_API_TOKEN = 'smoke-test-token'
$process = Start-Process -FilePath $api -ArgumentList '--service' `
  -PassThru -WindowStyle Hidden
try {
  $ready = $false
  foreach ($attempt in 1..20) {
    try {
      $health = Invoke-RestMethod 'http://127.0.0.1:18082/health' -TimeoutSec 1
      $ready = $health.status -eq 'ok'
      if ($ready) { break }
    }
    catch {
      Start-Sleep -Milliseconds 250
    }
  }
  if (-not $ready) { throw 'A API não respondeu ao health check do pacote.' }
  $pedido = Invoke-RestMethod 'http://127.0.0.1:18082/v1/pedidos/1' `
    -Headers @{ 'X-Api-Key' = 'smoke-test-token' }
  if ($pedido.numero -ne 'PV-2026-000001') {
    throw 'A consulta de pedido falhou no smoke test.'
  }
}
finally {
  if ($process -and -not $process.HasExited) {
    Stop-Process -Id $process.Id
    $process.WaitForExit(5000) | Out-Null
  }
  Remove-Item Env:HORIZONTE_API_PORT -ErrorAction SilentlyContinue
  Remove-Item Env:HORIZONTE_API_TOKEN -ErrorAction SilentlyContinue
}
Write-Host 'Smoke test do pacote aprovado.'
