
# Prerequisits
# Sjekk i Azure AD at alle brukere har "Usagelocation" satt til = "Norway" ellers vil man ikke få tildelt lisens. 

#  AccountSkuId for Business Premium                    = 'SPB'
#  AccountSkuId for Power Bi Pro                        = 'POWER_BI_PRO'
#  AccountSkuId for Microsoft 365 A3 for faculty        = 'M365EDU_A3_FACULTY'
#  AccountSkuId for Office 365 A3 for faculty           = 'M365EDU_A3_FACULTY'

# Husk å disconnect fra gammel sesjon først
Disconnect-MgGraph

# Nå er du klar til å koble til
Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All"


$users = import-csv "c:\temp7\Karveslettlia-assignlisens-powershell.csv" 

foreach ($user in $users)
{
    $upn = $user.UserPrincipalName
    $BPsku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'ENTERPRISEPACK_FACULTY'
    Set-MgUserLicense -UserId $upn -AddLicenses @{SkuId = $BPsku.SkuId} -RemoveLicenses @()
    Write-Host "License Assigned to UPN:"$upn #Return which UserPrincipalName was successfully assigned with the license
}


