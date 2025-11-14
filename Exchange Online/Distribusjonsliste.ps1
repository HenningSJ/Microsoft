connect-exchangeonline

Get-DistributionGroup -ResultSize Unlimited | Where-Object {$_.HiddenFromAddressListsEnabled -eq $true} | Select-Object Name, PrimarySmtpAddress, HiddenFromAddressListsEnabled