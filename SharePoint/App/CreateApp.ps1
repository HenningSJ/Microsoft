Connect-MgGraph -Scopes "Application.ReadWrite.All"

$app = New-MgApplication -DisplayName "PnPApp" -SignInAudience "AzureADMyOrg"

New-MgServicePrincipal -AppId $app.AppId

# SharePoint Sites.ReadWrite.All
Add-MgApplicationPermission -ApplicationId $app.Id -PermissionId "Sites.ReadWrite.All"

# Microsoft Graph User.Read
Add-MgApplicationPermission -ApplicationId $app.Id -PermissionId "User.Read"

# Gi admin consent i portalen
