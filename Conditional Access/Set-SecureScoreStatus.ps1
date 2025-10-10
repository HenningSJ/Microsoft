# Permissions required: 
# SecurityEvents.ReadWrite.All

# Step1:
Disconnect-MgGraph

#Step2: 
Connect-MgGraph -Scopes "SecurityEvents.ReadWrite.All"

# Ensure multifactor authentication is enabled for all admin users
$ControlProfileId = "AdminMFAV2"

$params = @{
	assignedTo = ""
	comment = "Solved using Conditional Access"
	state = "thirdParty"
	vendorInformation = @{
		provider = "SecureScore"
		providerVersion = $null
		subProvider = $null
		vendor = "Microsoft"
	}
}

Update-MgSecuritySecureScoreControlProfile -SecureScoreControlProfileId $ControlProfileId -BodyParameter $params

# Ensure multifactor authentication is enabled for all users

$ControlProfileId = "MFARegistrationV2"

$params = @{
	assignedTo = ""
	comment = "Solved using Conditional Access"
	state = "thirdParty"
	vendorInformation = @{
		provider = "SecureScore"
		providerVersion = $null
		subProvider = $null
		vendor = "Microsoft"
	}
}

# Enable Conditional Access policies to block legacy authentication

Update-MgSecuritySecureScoreControlProfile -SecureScoreControlProfileId $ControlProfileId -BodyParameter $params

$ControlProfileId = "BlockLegacyAuthentication"

$params = @{
	assignedTo = ""
	comment = "Solved using Conditional Access"
	state = "thirdParty"
	vendorInformation = @{
		provider = "SecureScore"
		providerVersion = $null
		subProvider = $null
		vendor = "Microsoft"
	}
}

Update-MgSecuritySecureScoreControlProfile -SecureScoreControlProfileId $ControlProfileId -BodyParameter $params







