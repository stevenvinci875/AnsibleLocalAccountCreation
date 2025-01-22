# Define the username, fullname, and description for the new user
$Username = "SecOpsDiscovery"
$FullName = "ServiceNow Discovery Account"
$Description = "This is a local admin account used for discovery"
$UacRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$TenantId = 'a16a84bb-433f-4366-9240-ff2062e4e799'
$ClientId = 'fca1a6eb-f2a7-48a5-b42a-2a93e8d07b6c'
$ClientSecret = 'ThisNeedsToBeSet'
$KeyVaultName = 'kv-ecm-prod-01'

try
{
    # Define the Access Token request parameters
    $GetAccessTokenParameters = @{
        Uri        = 'https://login.microsoftonline.com/' + $TenantId + '/oauth2/token'
        Method     = 'POST'
        Body       = @{
            grant_type    = 'client_credentials'
            client_id     = $ClientId
            client_secret = $ClientSecret
            resource      = 'https://vault.azure.net'
        }
    }

    # Invoke the Access Token request to get an access_token
    $GetAccessTokenResponse = Invoke-RestMethod @GetAccessTokenParameters

    # Define the Get Secret request parameters
    $GetSecretParameters = @{
        Uri        = 'https://' + $KeyVaultName + '.vault.azure.net/secrets/' + $Username + '?api-version=7.4'
        Method     = 'GET'
        Headers    = @{
            'Content-Type'    = 'application/json'
            'Authorization'   = 'Bearer ' + $GetAccessTokenResponse.access_token
        }
    }

    # Invoke the Get Secret request to retieve the secret
    $GetSecretResponse = Invoke-RestMethod @GetSecretParameters

    # Set the password based on the retrieved secret
    $Password = $GetSecretResponse.value | ConvertTo-SecureString -AsPlainText -Force

    # Check if the user already exists
    $ExistingUser = Get-LocalUser -Name $Username

    if ($ExistingUser) {
        # Update the existing user's password
        $ExistingUser | Set-LocalUser -Password $Password
    }
    else {
        # Create the new local user account
        New-LocalUser -Name $Username -Password $Password -FullName $FullName -Description $Description -AccountNeverExpires -PasswordNeverExpires

        # Add the new user to the local administrators group
        Add-LocalGroupMember -Group "Administrators" -Member $Username

        # Disable UAC
        Set-ItemProperty -Path $UacRegistryPath -Name "EnableLUA" -Value 0

        # Restart Computer
        Restart-Computer -Force
    }
}
catch
{
    Write-Host  -ForegroundColor red $_.Exception;
}