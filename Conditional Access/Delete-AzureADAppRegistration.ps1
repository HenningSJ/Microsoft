
Start-Sleep 30

Remove-MgApplication -ApplicationId $env:varDeleteApplication


Write-Host "Clean up - Removed Create-ConditionalAccess App from tenant." -ForegroundColor Green 

