$Counter = 0
$BatchSize = 100

foreach ($Item in $Items) {

    $Counter++

    try {
        $Item.ResetRoleInheritance()
        $Item.Update()

        if ($Counter % $BatchSize -eq 0) {
            Invoke-PnPQuery
            Write-Host "Behandlet $Counter av $($Items.Count)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Feil på element ID $($Item.Id): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Invoke-PnPQuery

Write-Host "Ferdig. Arv er forsøkt gjenopprettet på $Counter elementer under A-K." -ForegroundColor Green