Connect-ExchangeOnline



# Hent alle brukere med primæradresse på snowhotelkirkenes.com

$users = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.PrimarySmtpAddress -like "*@snowhotelkirkenes.com" }

foreach ($user in $users) {
    $localPart = ($user.PrimarySmtpAddress -split "@")[0]

    # Lag alias-adresser (smtp: med liten s)
    $aliases = @(
        "smtp:$localPart@snowresort.no",
        "smtp:$localPart@snowresortkirkenes.com",
        "smtp:$localPart@snowresortkirkenes.no"
    )

    # Legg til aliasene uten å overskrive eksisterende
    Set-Mailbox -Identity $user.Identity -EmailAddresses @{add=$aliases}

    Write-Host "Alias lagt til for $($user.PrimarySmtpAddress)"
}


#Test
Get-Mailbox -Identity Taavi.Tiits@snowhotelkirkenes.com | Select-Object -ExpandProperty EmailAddresses