


# Module
Import-Module -Name ExchangeOnlineManagement

# Variables - Shared Mailbox
$sharedMailboxName = "Serit - Data Loss Prevention"
$sharedMailboxAlias = "serit-dlp"
$sharedMailbox = "serit-dlp@idemo.no"

# Step1: 
Connect-ExchangeOnline

# Step2: 
# Creates shared mailbox in customer tenant
New-Mailbox -Shared -Name $sharedMailboxName -DisplayName $sharedMailboxName -Alias $sharedMailboxAlias 

# Step3:
# Have to connect to IPPS for New-DLPCompliancePolicy to work. Connect-ExchangeoOnline wont work. 
Connect-IPPSSession


# Define the GDPR policy parameters
$params = @{
    Name = 'Sikrere Sky Pro (GDPR)1449';
    ExchangeLocation = 'All';
    OneDriveLocation = 'All';
    SharePointLocation = 'All';
    TeamsLocation = 'All';
    Mode = 'Enable';
}

# Create the GDPR compliance policy
New-DlpCompliancePolicy @params

# Define sensitive EU data types to monitor
$sensitiveInfoLow = @(
    @{Name = "EU Debit Card Number"; minCount = "1"; maxCount = "4"},
    @{Name = "EU Driver's License Number"; minCount = "1"; maxCount = "4"},
    @{Name = "EU National Identification Number"; minCount = "1"; maxCount = "4"},
    @{Name = "EU Passport Number"; minCount = "1"; maxCount = "4"},
    @{Name = "EU Social Security Number (SSN) or Equivalent ID"; minCount = "1"; maxCount = "4"},
    @{Name = "EU Tax Identification Number (TIN)"; minCount = "1"; maxCount = "4"}
)

# Define sensitive EU data types to monitor
$sensitiveInfoHigh = @(
    @{Name ="EU Debit Card Number"; minCount = "5"},
    @{Name ="EU Driver's License Number"; minCount = "5"},
    @{Name ="EU National Identification Number"; minCount = "5"},
    @{Name ="EU Passport Number"; minCount = "5"},
    @{Name ="EU Social Security Number (SSN) or Equivalent ID"; minCount = "5"},
    @{Name ="EU Tax Identification Number (TIN)"; minCount = "5"}
)

# Define and create a rule for low volume detection
$RuleValueLow = @{
    Name = 'Low Volume GDPR Detection1449';
    Comment = 'Detects low volumes of EU sensitive data shared outside the organization.';
    Policy = 'Sikrere Sky Pro (GDPR)1449';
    ContentContainsSensitiveInformation = $sensitiveInfoLow;
    BlockAccess = $false;
    AccessScope = 'NotInOrganization';
    NotifyUser = @('Owner', 'LastModifier');
    NotifyAllowOverride = 'WithoutJustification';
 #  BlockAccessScope = 'PerUser';
    Disabled = $false;
}

New-DlpComplianceRule @RuleValueLow

# Define and create a rule for high volume detection
$RuleValueHigh = @{
    Name = 'High Volume GDPR Detection1449';
    Comment = 'Detects high volumes of EU sensitive data shared outside the organization.';
    Policy = 'Sikrere Sky Pro (GDPR)1449';
    BlockAccess = $true;
    AccessScope = 'NotInOrganization';
    ReportSeverityLevel = 'Medium';
    IncidentReportContent = 'All';
    GenerateAlert = $sharedMailbox;
    GenerateIncidentReport = $sharedMailbox;
    NotifyUser = @('Owner', 'LastModifier');
    NotifyEmailExchangeIncludeAttachment = $true;
    ContentContainsSensitiveInformation = $sensitiveInfoHigh;
}

New-DlpComplianceRule @RuleValueHigh





################################
###     Fjerning av label    ###
################################

Remove-Label -Identity "defa4170-0d19-0005-0000-bc88714345d2" 

