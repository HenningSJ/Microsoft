# Path to the CSV file containing the list of user mailboxes to convert
$csvPath = "C:\temp\brukereNT.csv"

# Read the CSV file
$mailboxes = Import-Csv -Path $csvPath

# Iterate through each mailbox in the CSV file and convert it to a shared mailbox
foreach ($mailbox in $mailboxes) {
    $primarySmtpAddress = $mailbox.PrimarySmtpAddress
    try {
        # Convert the user mailbox to a shared mailbox
        Set-Mailbox -Identity $primarySmtpAddress -Type Shared
        Write-Host "Converted user mailbox '$primarySmtpAddress' to a shared mailbox."
    } catch {
        Write-Host "Failed to convert user mailbox '$primarySmtpAddress' to a shared mailbox. $_" -ForegroundColor Red
    }
}