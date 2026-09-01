Connect-ExchangeOnline

Get-Mailbox -Identity "fjueltromso@fjuel.no" | Select-Object Name, WhenCreatedUTC, WhenMailboxCreated

#Search-UnifiedAuditLog -StartDate "02/02/2023" -EndDate "01/01/2024" -Operations "New-Mailbox" -FreeText "fjueltromso@fjuel.no" | Select-Object CreationTime, UserIds, Operations, AuditData | Format-List
