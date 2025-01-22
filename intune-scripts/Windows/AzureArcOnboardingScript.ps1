try {
    # Add the service principal application ID and secret here
    $ServicePrincipalId="33102cac-8856-4958-8e5e-3853ad132f2a";
    $ServicePrincipalClientSecret="secret";

    $env:SUBSCRIPTION_ID = "3de666cf-b653-4606-b327-d1dbeacfd39d";
    $env:RESOURCE_GROUP = "rg-ARC-production";
    $env:TENANT_ID = "a16a84bb-433f-4366-9240-ff2062e4e799";
    $env:LOCATION = "westus2";
    $env:AUTH_TYPE = "principal";
    $env:CORRELATION_ID = "3c5a05fa-bed2-4a5c-809b-20c57c774668";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    # Download the installation package
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";

    # Install the hybrid agent
    & "$env:TEMP\install_windows_azcmagent.ps1";
    if ($LASTEXITCODE -ne 0) { exit 1; }

    # Run connect command
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$ServicePrincipalId" --service-principal-secret "$ServicePrincipalClientSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --correlation-id "$env:CORRELATION_ID";
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}
