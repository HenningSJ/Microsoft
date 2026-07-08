
#Denne henter alle dokumenter i biblioteket, og filtrerer lokalt. Kan ta litt tid avhengig av størrelse på bibliotek.

$LibraryName = "Dokumenter"

Get-PnPListItem -List $LibraryName -PageSize 500 |
Where-Object {$_.HasUniqueRoleAssignments} |
Select-Object ID,
    @{Name="Navn";Expression={$_.FieldValues.FileLeafRef}},
    @{Name="Sti";Expression={$_.FieldValues.FileRef}}
