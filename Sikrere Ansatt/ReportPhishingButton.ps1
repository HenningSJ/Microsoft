#Når brukere rapporterer phishing epost, havner den i angitt delt postboks.
#Appen har lesetilgang til alle eposter. 
#Dette skriptet begrenser appen til kun å ha tilgang til epost i opprettet gruppe - kun Nimblr gruppen.

Connect-ExchangeOnline

$deltpostboks = "nimblr@mydland.no"
$ApplikasjonID = "3c4f4f0b-b1bb-4b61-9b3a-0b626d46ee70"
$domnene = "hmydland"

New-DistributionGroup -Name "API-Access-Group" -Type Security -members $deltpostboks

New-ApplicationAccessPolicy -AppId "$ApplikasjonID" -PolicyScopeGroupId "API-Access-Group@$domnene.onmicrosoft.com" -AccessRight RestrictAccess -Description "Restrict app to shared mailbox only"
