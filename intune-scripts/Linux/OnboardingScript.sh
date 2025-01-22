# Add the service principal application ID and secret here
ServicePrincipalId="74953a49-0133-4244-8c66-94d455d309c1";
ServicePrincipalClientSecret="<ENTER SECRET HERE>";


export subscriptionId="3de666cf-b653-4606-b327-d1dbeacfd39d";
export resourceGroup="rg-ARC-production";
export tenantId="a16a84bb-433f-4366-9240-ff2062e4e799";
export location="westus2";
export authType="principal";
export correlationId="00c98aa3-534d-4fd3-9590-185c3dc1d9b1";
export cloud="AzureCloud";


# Download the installation package
output=$(wget https://aka.ms/azcmagent -O /tmp/install_linux_azcmagent.sh 2>&1);
if [ $? != 0 ]; then wget -qO- --method=PUT --body-data="{\"subscriptionId\":\"$subscriptionId\",\"resourceGroup\":\"$resourceGroup\",\"tenantId\":\"$tenantId\",\"location\":\"$location\",\"correlationId\":\"$correlationId\",\"authType\":\"$authType\",\"operation\":\"onboarding\",\"messageType\":\"DownloadScriptFailed\",\"message\":\"$output\"}" "https://gbl.his.arc.azure.com/log" &> /dev/null || true; fi;
echo "$output";

# Install the hybrid agent
bash /tmp/install_linux_azcmagent.sh;

# Run connect command
sudo azcmagent connect --service-principal-id "$ServicePrincipalId" --service-principal-secret "$ServicePrincipalClientSecret" --resource-group "$resourceGroup" --tenant-id "$tenantId" --location "$location" --subscription-id "$subscriptionId" --cloud "$cloud" --tags "ArcSQLServerExtensionDeployment=Disabled" --correlation-id "$correlationId";
