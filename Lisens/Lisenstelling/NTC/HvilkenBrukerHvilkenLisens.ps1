Get-MgUser -All -Property DisplayName,UserPrincipalName,AssignedLicenses |
Where-Object { $_.AssignedLicenses.SkuId -contains $SUM_BB.SkuId } |
Select DisplayName, UserPrincipalName