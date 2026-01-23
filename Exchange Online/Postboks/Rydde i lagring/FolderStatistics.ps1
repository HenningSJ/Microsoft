Connect-ExchangeOnline

#Dette viser hvor ting er lagret i postboksen, og hvor mye plass de bruker
Get-MailboxFolderStatistics nina@dragoy.no |
Sort-Object FolderSize -Descending |
Select-Object Name,FolderSize


#recovarable items er slettede elementer som kan gjenopprettes:
Get-Mailbox -Identity nina@dragoy.no |
Get-MailboxStatistics |
Select-Object DisplayName,TotalDeletedItemSize,TotalItemSize


#Inspisere store mapper
Get-MailboxFolderStatistics nina@dragoy.no |
Where-Object {$_.FolderId -like "06967759-274D-40B2-A3EB-D7F9E73727D7"} |
fl Name,FolderAndSubfolderSize,ItemsInFolder,FolderPath


#Få Exchange til å rydde opp i lagringen ved å kjøre Managed Folder Assistant
Start-ManagedFolderAssistant -Identity nina@dragoy.no


#Marker postboksen for kjøring, om overnevnte kommando ikke fungerer umiddelbart
Set-Mailbox nina@dragoy.no -OneTimeDiagnostics $true
