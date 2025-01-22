$TenantId = 'a16a84bb-433f-4366-9240-ff2062e4e799'
$ClientId = 'fca1a6eb-f2a7-48a5-b42a-2a93e8d07b6c'
$ClientSecret = 'ThisNeedsToBeSet'
$KeyVaultName = 'kv-ecm-prod-01'
$KeyVaultSecretName = 'ThisNeedsToBeSet'

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

$GetAccessTokenResponse = Invoke-RestMethod @GetAccessTokenParameters

$GetSecretParameters = @{
    Uri        = 'https://' + $KeyVaultName + '.vault.azure.net/secrets/' + $KeyVaultSecretName + '?api-version=7.4'
    Method     = 'GET'
    Headers    = @{
        'Content-Type'    = 'application/json'
        'Authorization'   = 'Bearer ' + $GetAccessTokenResponse.access_token
    }
}

$GetSecretResponse = Invoke-RestMethod @GetSecretParameters