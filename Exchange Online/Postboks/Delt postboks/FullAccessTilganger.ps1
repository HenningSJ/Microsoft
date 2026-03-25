$mailboxes = @(
    "nnkm@nnkm.no",
    "foto@nnkm.no",
    "produksjonskalender@nnkm.no",
    "stilling@nnkm.no",
    "venn@nnkm.no",
    "hanne@nnkm.no",
    "direktor@nnkm.no",
    "handle@nnkm.no",
    "lonn@nnkm.no",
    "oystein@nnkm.no",
    "persondata@nnkm.no",
    "presse@nnkm.no",
    "skape@nnkm.no",
    "to@nnkm.no"
)

foreach ($mbx in $mailboxes) {
    Write-Host "`n=== $mbx ===" -ForegroundColor Cyan

    Get-RecipientPermission -Identity $mbx |
        Where-Object { -not $_.IsInherited -and $_.User -notmatch 'NT AUTHORITY|S-1-5-' } |
        Format-Table User, AccessRights
}


# Get-RecipientPermission -Identity <postboks> (Send As-rettigheter)
# (Get-Mailbox -Identity <postboks>).GrantSendOnBehalfTo