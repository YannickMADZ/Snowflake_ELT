# Charge les variables de .env dans la session PowerShell COURANTE (usage sans Docker).
# À lancer en « dot-sourcing » (le point et l'espace sont indispensables) :
#     . .\scripts\load_env.ps1
$envFile = Join-Path (Split-Path $PSScriptRoot -Parent) ".env"
if (-not (Test-Path $envFile)) { Write-Error ".env introuvable : Copy-Item .env.example .env"; return }
Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
        $name, $value = $line.Split("=", 2)
        $value = $value.Trim()
        # Retire les guillemets entourant la valeur ("..." ou '...')
        if ($value.Length -ge 2 -and (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'")))) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        [Environment]::SetEnvironmentVariable($name.Trim(), $value, "Process")
    }
}
Write-Host "Variables .env chargées (valeurs non affichées)."
