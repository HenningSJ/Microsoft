

#######################################################
####         Lisensgrupper i Office365             ####
#######################################################

# Brukes av OnOffboarding app
# Navn på grupper blir "LicenseGroup - "

# Import Microsoft Graph Groups module (Ensure it's installed)
Import-Module Microsoft.Graph.Groups

# Connect to Microsoft Graph (if not already connected)
Connect-MgGraph -Scopes "Group.ReadWrite.All", "Directory.ReadWrite.All"


#########################################################
###     Step1: Check for already created license groups
#########################################################

# Get all groups and licenses
$groups = Get-MgGroup -All
$groupsWithLicenses = @()

# Loop through each group and check if it has any licenses assigned
foreach ($group in $groups) {
    $licenses = Get-MgGroup -GroupId $group.Id -Property "AssignedLicenses, Id, DisplayName" | Select-Object AssignedLicenses, DisplayName, Id
    if ($licenses.AssignedLicenses) {
        $groupData = [PSCustomObject]@{
            ObjectId = $group.Id
            DisplayName = $group.DisplayName
            Licenses = $licenses.AssignedLicenses
        }
        $groupsWithLicenses += $groupData
    }
}

$groupsWithLicenses


#########################################################
###     Step2: Remove already created license groups
#########################################################

# PS:
# Gå inn i Admin.microsoft.com -> Billing -> Licenses -> Velg licens -> Groups -> Manage apps & services
# Sjekk om alt er aktivert eller kun spesifikke tjenester
# Noter ned det som ikke er aktiver, slik at du husker å fjerne disse i Step4


# Get all groups and licenses
$groups = Get-MgGroup -All
$groupsWithLicenses = @()

# Loop through each group and check if it has any licenses assigned
foreach ($group in $groups) {
    $licenses = Get-MgGroup -GroupId $group.Id -Property "AssignedLicenses, Id, DisplayName" | 
                Select-Object AssignedLicenses, DisplayName, Id
    if ($licenses.AssignedLicenses) {
        $groupData = [PSCustomObject]@{
            ObjectId    = $group.Id
            DisplayName = $group.DisplayName
            Licenses    = $licenses.AssignedLicenses.SkuId
        }
        $groupsWithLicenses += $groupData
    }
}

# Output found groups before deletion
Write-Host "Groups with assigned licenses:" -ForegroundColor Yellow
$groupsWithLicenses | Format-Table DisplayName, ObjectId, Licenses

# Confirm before proceeding
$confirmation = Read-Host "Do you want to remove licenses and delete these groups? (yes/no)"
if ($confirmation -eq "yes") {
    foreach ($group in $groupsWithLicenses) {
        try {
            # Remove assigned licenses before deleting the group
            Write-Host "Removing licenses from Group: $($group.DisplayName) [$($group.ObjectId)]" -ForegroundColor Cyan
            Set-MgGroupLicense -GroupId $group.ObjectId -RemoveLicenses $group.Licenses -AddLicenses @{}

            # Wait a few seconds to allow the removal to process
            Start-Sleep -Seconds 5

            # Remove group
            Remove-MgGroup -GroupId $group.ObjectId -Confirm:$false
            Write-Host "Deleted Group: $($group.DisplayName) [$($group.ObjectId)]" -ForegroundColor Green
        } catch {
            Write-Host "Failed to process group: $($group.DisplayName) - Error: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Operation canceled." -ForegroundColor Cyan
}



################################################
###     Step3: Create New license groups        
################################################

# Define License Groups
$licenseGroups = @(
    "Business Basic",
    "Business Standard",
    "Business Premium",
    "Microsoft E3",
    "Microsoft E5",
    "Exchange Online Plan 1",
    "Power BI Pro",
    "Microsoft Copilot",
    "Visio",
    "Project"
)

# Define license SKUs (Get your tenant's SKUs using: Get-MgSubscribedSku)
$licenseSkuMap = @{
    "Business Basic"           = "3b555118-da6a-4418-894f-7df1e2096870" # O365_BUSINESS_ESSENTIALS
    "Business Standard"        = "f245ecc8-75af-4f8e-b61f-27d8114de5f3" # O365_BUSINESS_PREMIUM
    "Business Premium"         = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46" # SPB
    "Microsoft E3"             = "05e9a617-0261-4cee-bb44-138d3ef5d965" # SPE_E3
    "Microsoft E5"             = "06ebc4ee-1bb5-47dd-8120-11324bc54e06" # SPE_E5
    "Exchange Online Plan 1"   = "4b9405b0-7788-4568-add1-99614e613b69" # EXCHANGESTANDARD
    "Power BI Pro"             = "a403ebcc-fae0-4ca2-8c8c-7a907fd6c235" # POWER_BI_STANDARD
    "Microsoft Copilot"        = "639dec6b-bb19-468b-871c-c5c441c4b0cb" # Microsoft_365_Copilot
    "Visio"                    = "c5928f49-12ba-48f7-ada3-0d743a3601d5" # VISIOCLIENT
    "Project"                  = "09015f9f-377f-4538-bbb5-f75ceb09358a" # PROJECTPREMIUM
}

# Store group name and IDs for summary
$groupSummary = @()

# Loop through each license and create a security group
foreach ($license in $licenseGroups) {
    Write-Host "Creating security group for: LicenseGroup - $license" -ForegroundColor Cyan

    # Define Group Parameters
    $params = @{
        displayName = "LicenseGroup - $license"
        description = "Security Group for $license"
        mailEnabled = $false
        mailNickname = "N/A"
        securityEnabled = $true
    }

    # Create the Security Group
    $group = New-MgGroup -BodyParameter $params

    if ($group -and $group.Id) {
        $groupId = $group.Id
        Write-Host "✅ Created Group: LicenseGroup - $license (ID: $groupId)" -ForegroundColor Green

        # Store group name and ID
        $groupSummary += [PSCustomObject]@{
            Name = "LicenseGroup - $license"
            ID   = $groupId
        }

        # Assign License to the Group
        if ($licenseSkuMap.ContainsKey($license)) {
            $skuId = $licenseSkuMap[$license]
            Write-Host "⏳ Assigning license ($skuId) to group: $groupId" -ForegroundColor Yellow
            
            # Define License Assignment Parameters
            $licenseParams = @{
                addLicenses = @(
                    @{
                        disabledPlans = @()   # No disabled plans
                        skuId = $skuId
                    }
                )
                removeLicenses = @() # No licenses removed
            }

            # Assign License to the Group
            Set-MgGroupLicense -GroupId $groupId -BodyParameter $licenseParams

            Write-Host "✅ License assigned successfully!" -ForegroundColor Green
        } else {
            Write-Host "⚠️ No SKU found for: $license" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Failed to create group for: LicenseGroup - $license" -ForegroundColor Red
    }
}

# Print Summary Table
Write-Host "`n===================================" -ForegroundColor Magenta
Write-Host "   Group Creation Summary (Name & ID)" -ForegroundColor Magenta
Write-Host "===================================" -ForegroundColor Magenta
$groupSummary | Format-Table -AutoSize

Write-Host "🎉 All groups created and licenses assigned!" -ForegroundColor Magenta


##################################################
###     Step4: Remove Spesific apps & services 
##################################################

# Husk å fjerne de tjenestene som ikke skal være aktivert, som ble kartlagt i Step2
# Ferdig. 


#############################################################################
###     Step5: Replaces direct assigned license with group based license
##############################################################################

# Finner direkte tildelte lisenser, finner deretter korresponderende lisensgruppe, 
# fjerner så direkte tildelt lisens, for deretter å tildele riktig lisensgruppe. 

$licenseGroups = @()
$groups = Get-MgGroup -All

foreach ($group in $groups) {
    $groupLicenses = Get-MgGroup -GroupId $group.Id -Property "AssignedLicenses" | Select-Object AssignedLicenses
    if ($groupLicenses.AssignedLicenses) {
        $licenseGroups += [PSCustomObject]@{
            GroupId  = $group.Id
            GroupName = $group.DisplayName
            Licenses  = $groupLicenses.AssignedLicenses.SkuId
        }
    }
}

Write-Host "Found $($licenseGroups.Count) license groups." -ForegroundColor Yellow

# Step 2: Get all users and their directly assigned licenses
$users = Get-MgUser -All
$usersWithLicenses = @()

foreach ($user in $users) {
    $userLicenses = Get-MgUserLicenseDetail -UserId $user.Id
    if ($userLicenses) {
        $usersWithLicenses += [PSCustomObject]@{
            UserId   = $user.Id
            UserName = $user.DisplayName
            Licenses = $userLicenses.SkuId
        }
    }
}

Write-Host "Found $($usersWithLicenses.Count) users with direct licenses." -ForegroundColor Yellow

# Step 3: Match user licenses with existing license groups
foreach ($user in $usersWithLicenses) {
    $licensesToRemove = @()
    $groupsToAssign = @()

    foreach ($license in $user.Licenses) {
        # Check if a license exists in a license group
        $matchingGroup = $licenseGroups | Where-Object { $_.Licenses -contains $license }
        
        if ($matchingGroup) {
            Write-Host "User $($user.UserName) [$($user.UserId)] has direct license $license that exists in group: $($matchingGroup.GroupName)" -ForegroundColor Cyan
            $licensesToRemove += $license
            $groupsToAssign += $matchingGroup.GroupId
        }
    }

    # Step 4: Remove direct license and assign group-based license
    if ($licensesToRemove.Count -gt 0 -and $groupsToAssign.Count -gt 0) {
        try {
            # Remove the direct license
            Write-Host "Removing direct licenses from $($user.UserName)..." -ForegroundColor Yellow
            Set-MgUserLicense -UserId $user.UserId -RemoveLicenses $licensesToRemove -AddLicenses @{}

            # Wait a few seconds for license removal to process
            Start-Sleep -Seconds 5

            # Add user to the correct license groups
            foreach ($groupId in $groupsToAssign) {
                Write-Host "Adding $($user.UserName) to group $groupId for license assignment..." -ForegroundColor Green
                New-MgGroupMember -GroupId $groupId -DirectoryObjectId $user.UserId
            }
            
            Write-Host "Updated licensing for user $($user.UserName) successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to update user $($user.UserName) - Error: $_" -ForegroundColor Red
        }
    }
}


# Ferdig




