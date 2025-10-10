##Input parameters for ClientID Certiciate Thumbprint and TenantID

#.\Run-DataAssessment.ps1 - -tenantid 256c6ac2-bdec-4852-894d-4995d602734f -clientid 95f12ea4-41ec-45f0-97d3-f2bda3373b1e -thumbprint 619879343B4F264BF8E23F1B133AC86460F97B0A 

param(
    [Parameter(Mandatory = $true)]
    [string]$ClientID, 

    [Parameter(Mandatory = $true)]
    [string]$Thumbprint,

    [Parameter(Mandatory = $true)]
    [string]$TenantID,

    [Parameter(Mandatory = $false)]
    [string]$CSVPath
)
# Connect to Microsoft Graph
Connect-MgGraph -NoWelcome -ClientId $ClientID -CertificateThumbprint $Thumbprint -TenantId $TenantID
$OutputFileName = "C:\DataAssessment\DataAssessment.csv"
if (!$csvPath) {
    $SiteList = (Get-MgSite -All | Where-Object { $_.weburl -notlike "*-my.sharepoint.com*" } |  Select-Object id, WebURL)
}
else {
    Try {
        write-host "Validating CSV file..."
        $SiteList = Import-Csv $csvPath
        $SiteList | add-member -MemberType NoteProperty -Name "ID" -Value $null
        foreach ($site in $SiteList) {
            write-host $site
            $Split = $site.WebURL.Split("/")
            if (!$Split[4]) {
                $JoinedSiteID = "$($Split[2])"
                $Site.Id = (Get-MgSite -SiteId $JoinedSiteID -ErrorAction stop).id
            }
            else {
                $JoinedSiteID = "$($split[2]):/sites/$($split[4])"
                $Site.Id = (Get-MgSite -SiteId $JoinedSiteID -ErrorAction stop).id
            }

        }
    }
    catch {
        Write-Host "Error finding sites in site list: $($_.Exception.Message)" -ForegroundColor Red
        Pause
        Exit
    }
}

##Get a list of items in a document libraries in each site and check permissions on each item using Graph PowerShell
$i = 0
foreach ($site in $SiteList) {
    $i++
    $SiteName = (get-mgsite -SiteId $site.id).DisplayName
    Write-Progress -Activity "Checking Permissions" -Status "Checking Site $i of $($SiteList.Count)" -PercentComplete (($i / $SiteList.Count) * 100)
    [array]$Libraries = Get-MgSiteDrive -SiteId $site.id -Filter "DriveType eq 'documentLibrary'" | Where-Object { $_.name -ne "Preservation Hold Library" }

    foreach ($library in $Libraries) {
        $List = Get-MgSiteList -SiteId $site.id | Where-Object { $_.WebUrl -eq $library.weburl }
        [array]$Items = Get-MgSiteListItem -SiteId $site.id -ListId $List.id 
        $x = 0
        foreach ($item in $Items) {
            $x++
            Write-Progress -Activity "Checking Permissions" -Status "Checking Site $i of $($SiteList.Count) - Item $x of $($items.count)" -PercentComplete (($i / $SiteList.Count) * 100)
            $DriveItem = Get-MgSiteListItemDriveItem -ListId $list.id -SiteId $site.Id -ListItemId $item.id
            $Permissions = Get-MgDriveItemPermission -DriveId $library.id -DriveItemId $Driveitem.id

            $ItemID = $DriveItem.Id
            $Name = $DriveItem.Name
            $URL = $Item.WebUrl
            $SiteGroups = ($permissions.GrantedToV2.SiteGroup.DisplayName | Where-Object { $_ -ne $null }) -join ';'
            $SiteGroupsCount = ($permissions.GrantedToV2.SiteGroup.DisplayName | Where-Object { $_ -ne $null }).count
            $Users = ($permissions.GrantedToV2.User.DisplayName | Where-Object { $_ -ne $null }) -join ';'
            $UsersCount = ($permissions.GrantedToV2.User.DisplayName | Where-Object { $_ -ne $null }).count
            $Links = ($permissions.link.scope | Where-Object { $_ -ne $null }) -join ';'
            $LinksCount = ($permissions.link.scope | Where-Object { $_ -ne $null }).count

            $PermissionObject = New-Object PSObject -Property @{
                Name = $Name
                URL = $URL
                SiteGroups = $SiteGroups
                SiteGroupsCount = $SiteGroupsCount
                Users = $Users
                UsersCount = $UsersCount
                Links = $Links
                LinksCount = $LinksCount
                SiteName = $SiteName
                SiteURL = $site.WebURL
            }
            If ($PSVersionTable.PSVersion.Major -ge 7) {
                $PermissionObject | Export-Csv -Path $OutputFileName -Append
            }
            Else {
                $PermissionObject | Export-Csv -Path $OutputFileName -Append -NoTypeInformation
            }
        }	
    }
}
