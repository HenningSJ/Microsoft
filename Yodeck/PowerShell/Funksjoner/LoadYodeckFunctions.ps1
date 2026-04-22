# Load-YodeckFunctions.ps1 (forenklet versjon)

$scriptRoot = $PSScriptRoot

Write-Host "Laster alle Yodeck-funksjoner rekursivt..." -ForegroundColor Cyan

# Hent alle .ps1-filer rekursivt, unntatt loader-skriptet selv
Get-ChildItem -Path $scriptRoot -Filter "*.ps1" -Recurse -File | 
    Where-Object { $_.Name -ne "Load-YodeckFunctions.ps1" } |
    ForEach-Object {
        Write-Verbose "Laster: $($_.FullName)"
        . $_.FullName
    }

Write-Host "Alle funksjoner lastet!" -ForegroundColor Green