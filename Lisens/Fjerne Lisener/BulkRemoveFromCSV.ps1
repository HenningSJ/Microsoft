#Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All


$usersList = Import-Csv -Path "C:\temp\brukereNT.csv"

foreach ($user in $usersList) {
    $upn = $user.UserPrincipalName

    try {
        # Hent brukerens lisensinfo
        $mgUser = Get-MgUser -UserId $upn -Property "id,userPrincipalName,assignedLicenses" -ErrorAction Stop

        # Finn alle SKU-er som er direkte tilordnet
        $removeSkuIds = @($mgUser.AssignedLicenses | ForEach-Object { $_.SkuId })

        if (-not $removeSkuIds -or $removeSkuIds.Count -eq 0) {
            Write-Host "[$upn] Ingen direkte lisenser å fjerne." -ForegroundColor Yellow
            continue
        }

        # Fjern alle direkte lisenser
        Set-MgUserLicense -UserId $mgUser.Id -RemoveLicenses $removeSkuIds -AddLicenses @() -ErrorAction Stop

        Write-Host "[$upn] Fjernet direkte lisenser: $($removeSkuIds -join ', ')" -ForegroundColor Green
    }
    catch {
        Write-Host "[$upn] FEIL: $($_.Exception.Message)" -ForegroundColor Red
    }
}