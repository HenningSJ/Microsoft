Connect-ExchangeOnline
Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited 
  #| Select-Object DisplayName,PrimarySmtpAddress,WhenCreated,Alias 
  | Select-Object PrimarySmtpAddress
  | Sort-Object DisplayName




