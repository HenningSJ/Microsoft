
###
###     Brukes til CodeTwo sertifikatløsning slik at når noen sender epost på vegne 
###     av en delt postboks så vises signaturen til brukeren
###


#####################################
###     Single Shared Mailbox     ###
#####################################

# Connect
Connect-ExchangeOnline

# Define the shared mailbox
$sharedMailbox = "dlp@idemo.no"

# Step 1: Get all 'Send As' permissions using Get-RecipientPermission
Write-Host "Fetching Send As permissions for mailbox: $sharedMailbox"
$sendAsUsers = Get-RecipientPermission -Identity $sharedMailbox -ResultSize Unlimited -ErrorAction SilentlyContinue | Where-Object { 
    $_.AccessRights -contains 'SendAs' -and $_.Trustee -notlike "*NT AUTHORITY*"
}

# Debug output
Write-Host "Send As Users Found:" -ForegroundColor Cyan
$sendAsUsers | ForEach-Object { Write-Host "Trustee: $($_.Trustee), AccessRights: $($_.AccessRights)" }

# Step 2: Get all 'Full Access' permissions using Get-MailboxPermission, excluding 'NT AUTHORITY\SELF'
Write-Host "Fetching Full Access permissions..."
$fullAccessPermissions = Get-MailboxPermission -Identity $sharedMailbox -ResultSize Unlimited -ErrorAction SilentlyContinue
$fullAccessUsers = $fullAccessPermissions | Where-Object { 
    $_.AccessRights -contains 'FullAccess' -and $_.User -notlike "*NT AUTHORITY*"
}

# Debug output
Write-Host "Full Access Users Found:" -ForegroundColor Cyan
$fullAccessUsers | ForEach-Object { Write-Host "User: $($_.User), AccessRights: $($_.AccessRights)" }

# Step 3: Filter users who have both 'Send As' and 'Full Access'
Write-Host "Finding users with both Send As and Full Access permissions..."
$usersWithBothPermissions = @()
foreach ($sendAsUser in $sendAsUsers) {
    foreach ($fullAccessUser in $fullAccessUsers) {
        if ($sendAsUser.Trustee -eq $fullAccessUser.User) {
            $usersWithBothPermissions += $sendAsUser.Trustee
        }
    }
}

# Debug output
Write-Host "Users with both Send As and Full Access:" -ForegroundColor Yellow
$usersWithBothPermissions | ForEach-Object { Write-Host "User: $_" }

# Step 4: Remove 'Send As' permissions and add 'Send on Behalf' permissions
foreach ($user in $usersWithBothPermissions) {
    try {
        Write-Host "Processing user: $user" -ForegroundColor Green

        # Remove 'Send As' permission using Remove-RecipientPermission
        Remove-RecipientPermission -Identity $sharedMailbox -AccessRights SendAs -Trustee $user -Confirm:$false
        Write-Host ("Removed 'Send As' permission for user: " + $user) -ForegroundColor Green

        # Add 'Send on Behalf' permission using Set-Mailbox
        Set-Mailbox -Identity $sharedMailbox -GrantSendOnBehalfTo @{Add=$user}
        Write-Host ("Added 'Send on Behalf' permission for user: " + $user) -ForegroundColor Green
    }
    catch {
        # Capture the error message
        $errorMessage = $Error[0].Exception.Message
        Write-Host ("Error processing user: " + $user + " - " + $errorMessage) -ForegroundColor Red
    }
}


####################################
###     All Shared Mailboxes     ###
####################################

# Connect
Connect-ExchangeOnline


# Step 1: Get all shared mailboxes
Write-Host "Fetching all shared mailboxes..." -ForegroundColor Yellow
$sharedMailboxes = Get-Mailbox -ResultSize Unlimited -Filter 'RecipientTypeDetails -eq "SharedMailbox"'

# Step 2: Loop through each shared mailbox
foreach ($sharedMailbox in $sharedMailboxes) {
    $mailboxAddress = $sharedMailbox.PrimarySmtpAddress
    Write-Host "`nProcessing mailbox: ${mailboxAddress}" -ForegroundColor Yellow

    # Step 3: Get 'Send As' permissions using Get-RecipientPermission
    $sendAsUsers = Get-RecipientPermission -Identity $mailboxAddress -ErrorAction SilentlyContinue

    # Filter 'Send As' users
    $sendAsUsersFiltered = $sendAsUsers | Where-Object {
        $_.AccessRights -contains 'SendAs' -and $_.Trustee -notlike "*NT AUTHORITY*"
    }

    # Step 4: Remove 'Send As' permissions
    if ($sendAsUsersFiltered) {
        foreach ($sendAsUser in $sendAsUsersFiltered) {
            $userToRemove = $sendAsUser.Trustee.ToString()
            try {
                Remove-RecipientPermission -Identity $mailboxAddress -AccessRights SendAs -Trustee $userToRemove -Confirm:$false
                Write-Host "Removed 'Send As' permission for: $userToRemove" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to remove 'Send As' for: $userToRemove" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No 'Send As' permissions found to remove." -ForegroundColor Yellow
    }

    # Step 5: Get 'Full Access' permissions using Get-MailboxPermission
    $fullAccessPermissions = Get-MailboxPermission -Identity $mailboxAddress -ErrorAction SilentlyContinue

    # Filter non-inherited Full Access users
    $fullAccessUsers = $fullAccessPermissions | Where-Object {
        ($_.IsInherited -eq $false) -and ($_.User -notlike "*NT AUTHORITY*") -and ($_.AccessRights -contains "FullAccess")
    }

    # Step 6: Add 'Send on Behalf' permissions for all Full Access users
    foreach ($fullAccessUser in $fullAccessUsers) {
        $user = $fullAccessUser.User.ToString()
        try {
            Set-Mailbox -Identity $mailboxAddress -GrantSendOnBehalfTo @{Add=$user}
            Write-Host "Added 'Send on Behalf' for: $user" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to add 'Send on Behalf' for: $user" -ForegroundColor Red
        }
    }
}



