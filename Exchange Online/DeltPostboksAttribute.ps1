import-module ExchangeOnlineManagement
connect-exchangeonline -UserPrincipalName seritmigrate@thearctictravelcompany.onmicrosoft.com


Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited |
ForEach-Object {
    Set-Mailbox $_.UserPrincipalName -CustomAttribute2 "Delt postboks"
}
