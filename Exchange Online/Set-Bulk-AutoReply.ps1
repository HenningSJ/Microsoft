

### Setter autoreply på kontoer i Exchange Online ###
# https://learn.microsoft.com/en-us/powershell/module/exchange/set-mailboxautoreplyconfiguration?view=exchange-ps

# Connect to Exchange Online
Connect-ExchangeOnline

############################################
####     EXTERNAL ONLY with Schedule    ####
############################################

# Import the CSV file
$emailChanges = Import-Csv -Path "C:\temp6\Import-AutoReply-Schedule.csv"

# Loop through each entry in the CSV and set the permanent autoreply
foreach ($entry in $emailChanges) {
    try {
        $Message = "Jeg har fått ny epostadresse. Min nye epostadresse er $($entry.NewUPN)."

        # Directly convert the ISO 8601 date strings to DateTime objects
        $startDate = [datetime]$entry.StartDate
        $endDate = [datetime]$entry.EndDate

        # Log start of processing for each user
        Write-Host "Processing $($entry.OldUPN)..."

        # Set the autoreply configuration
        Set-MailboxAutoReplyConfiguration -Identity $entry.OldUPN `
            -AutoReplyState Scheduled `
            -InternalMessage $Message `
            -ExternalMessage $Message `
            -StartTime $startDate `
            -EndTime $endDate `
            -ExternalAudience All
        
        # Log success
        Write-Host "Successfully set autoreply for $($entry.OldUPN) to inform of new address $($entry.NewUPN)." -ForegroundColor Green
    }
    catch {
        # Log any errors
        Write-Host "Failed to set autoreply for $($entry.OldUPN): $_" -ForegroundColor Red
    }
}


#######################################################
####    Internal and External without Schedule     ####
#######################################################

# Connect to Exchange Online
Connect-ExchangeOnline

# Import the CSV file
$emailChanges = Import-Csv -Path "C:\temp6\Import-AutoReply-NoSchedule.csv"

# Loop through each entry in the CSV and set the permanent autoreply
foreach ($entry in $emailChanges) {
    try {
        $internalMessage = "Jeg har fått ny epostadresse. Min nye epostadresse er $($entry.NewUPN)."
        $externalMessage = "Jeg har fått ny epostadresse. Min nye epostadresse er $($entry.NewUPN)."

        # Log start of processing for each user
        Write-Host "Processing $($entry.OldUPN)..."

        # Set the autoreply configuration
        Set-MailboxAutoReplyConfiguration -Identity $entry.OldUPN `
            -AutoReplyState Enabled `
            -InternalMessage $internalMessage `
            -ExternalMessage $externalMessage `
            -ExternalAudience All
        
        # Log success
        Write-Host "Successfully set autoreply for $($entry.OldUPN) to inform of new address $($entry.NewUPN)." -ForegroundColor Green
    }
    catch {
        # Log any errors
        Write-Host "Failed to set autoreply for $($entry.OldUPN): $_" -ForegroundColor Red
    }
}

