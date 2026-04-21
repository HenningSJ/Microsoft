import-module -name Microsoft.Online.SharePoint.PowerShell
connect-sposervice -url https://ibidsa-admin.sharepoint.com

Get-SPOTenant | fl *Shortcut*
Set-SPOTenant -DisableAddShortcutsToOneDrive $false