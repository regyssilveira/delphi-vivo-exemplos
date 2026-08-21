param(
  [Parameter(Mandatory)] [string]$TargetDirectory
)

$ErrorActionPreference = 'Stop'
$target = [IO.Path]::GetFullPath($TargetDirectory)
$backup = "$target.previous"
if ([IO.Path]::GetPathRoot($target) -eq $target) {
  throw 'O destino não pode ser a raiz de uma unidade.'
}
if (-not (Test-Path -LiteralPath $backup)) {
  throw "Backup de rollback não localizado: $backup"
}
$failed = "$target.failed-$(Get-Date -Format yyyyMMddHHmmss)"
if (Test-Path -LiteralPath $target) {
  Move-Item -LiteralPath $target -Destination $failed
}
Move-Item -LiteralPath $backup -Destination $target
Write-Host "Rollback concluído. Versão retirada preservada em $failed"
