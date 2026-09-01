
#Finn mappen

$Folder = Get-PnPFolder `
    -Url "/sites/Felles/Delte dokumenter/Hovedmappe verksted/_LANDBRUK/A-K"

$Folder

#Hent alle undermapper og filer
$Items = Get-PnPFolderItem `
    -FolderSiteRelativeUrl "Delte dokumenter/Hovedmappe verksted/_LANDBRUK/A-K" `
    -Recursive

#Hvilke har unike rettigheter
foreach ($Item in $Items)
{
    $ListItem = Get-PnPProperty -ClientObject $Item -Property ListItemAllFields

    if ($ListItem.HasUniqueRoleAssignments)
    {
        Write-Host $ListItem["FileRef"] -ForegroundColor Yellow
    }
}

#Denne er ikke effektiv på mange filer, da den kjører call mot hver enkelt fil.. ctrl+c og kjør $Items.Count.
#Hvilke pvirkes av neste skript:
$Count = 0

foreach ($Item in $Items)
{
    $ListItem = Get-PnPProperty -ClientObject $Item -Property ListItemAllFields

    if ($ListItem.HasUniqueRoleAssignments)
    {
        $Count++
        $ListItem["FileRef"]
    }
}

Write-Host "Antall objekter med unike rettigheter:" $Count

#Tilbakestille inheritcance (arv) for alle undermapper og filer med unike rettigheter:
foreach ($Item in $Items)
{
    $ListItem = Get-PnPProperty -ClientObject $Item -Property ListItemAllFields

    if ($ListItem.HasUniqueRoleAssignments)
    {
        $ListItem.ResetRoleInheritance()
        $ListItem.Update()

        Invoke-PnPQuery

        Write-Host "Arv gjenopprettet:" $ListItem["FileRef"] -ForegroundColor Green
    }
}