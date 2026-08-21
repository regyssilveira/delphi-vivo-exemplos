$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$violations = [Collections.Generic.List[string]]::new()

function Assert-NoMatch([string]$Directory, [string]$Pattern, [string]$Rule) {
  Get-ChildItem -LiteralPath (Join-Path $root $Directory) -Filter '*.pas' -File |
    ForEach-Object {
      if (Select-String -LiteralPath $_.FullName -Pattern $Pattern -Quiet) {
        $violations.Add("$Rule — $($_.FullName.Substring($root.Length + 1))")
      }
    }
}

Assert-NoMatch 'src\Horizonte.Domain' `
  '\b(Vcl\.|FireDAC\.|Horizonte\.Infrastructure|Horizonte\.Desktop|Horizonte\.Api)\b' `
  'Domain não pode depender de UI, transporte ou infraestrutura'
Assert-NoMatch 'src\Horizonte.Application' `
  '\b(Vcl\.|FireDAC\.|Horizonte\.Infrastructure|Horizonte\.Desktop|Horizonte\.Api)\b' `
  'Application não pode depender de UI, transporte ou infraestrutura'
Assert-NoMatch 'src\Horizonte.Api' `
  '\b(TFDQuery|TFDConnection|Vcl\.)\b' `
  'API não pode acessar FireDAC ou VCL diretamente'

if ($violations.Count -gt 0) {
  $violations | ForEach-Object { Write-Error $_ }
  throw "Foram encontradas $($violations.Count) violações arquiteturais."
}
Write-Host 'Regras de dependência aprovadas.'
