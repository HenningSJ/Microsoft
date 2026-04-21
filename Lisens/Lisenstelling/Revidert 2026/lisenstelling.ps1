#Dette skriptet kjører alle lisensrapportene for kundene i "Revidert 2026" mappen

# Rotmappe der kundeskriptene ligger
$scriptRoot = "C:\VS Code\Microsoft\Lisens\Lisenstelling\Revidert 2026"

# Skript som IKKE skal kjøres som kundescript
$excludeScripts = @(
    "lisenstelling.ps1",
    "funksjoner.ps1"
)

Write-Host "`n===== Starter samlet lisensrapport =====`n" -ForegroundColor Cyan

# Finn alle .ps1-filer unntatt de ekskluderte
$scripts = Get-ChildItem $scriptRoot -Filter "*.ps1" |
    Where-Object { $_.Name -notin $excludeScripts } |
    Sort-Object Name

foreach ($script in $scripts) {

    Write-Host "=== Starter $($script.Name) ===" -ForegroundColor Yellow
    $startTime = Get-Date

    try {
        # Dot-source kundescriptet
        . $script.FullName

        $duration = (Get-Date) - $startTime
        Write-Host "✓ Ferdig $($script.Name) ($([math]::Round($duration.TotalSeconds,1)) sek)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Feil i $($script.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }

    Write-Host ""  # tom linje mellom kunder
}

Write-Host "===== Alle kundeskript kjørt =====" -ForegroundColor Cyan
