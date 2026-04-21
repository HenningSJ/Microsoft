Get-SPOFontPackage

Remove-SPOFontPackage -Identity af4cc299-1577-454e-9e85-d8b4ab6e4076

Get-SPOFontPackage | Where-Object {$_.IsHidden -eq $true} | Remove-SPOFontPackage

