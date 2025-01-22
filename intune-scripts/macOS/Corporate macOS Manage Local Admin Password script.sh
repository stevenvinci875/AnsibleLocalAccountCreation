#!/usr/bin/env bash

## Define variables
username='admin'
password=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) ## Generate a random 16-character password
fullName='Administrator'
computerName=$(scutil --get ComputerName)
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

## Function: waitForSetupAssistant (waits until Setup Assistant is done)
waitForSetupAssistant () {
    until [[ -f /var/db/.AppleSetupDone ]]; do
        delay=$(( $RANDOM % 50 + 10 ))
        sleep $delay
    done
}

## Invoke waitForSetupAssistant function
waitForSetupAssistant

## Get Azure AD access_token using client credentials flow
token=$(curl -s -X POST -d 'grant_type=client_credentials&client_id=d64c3c04-e2f1-4a8a-a1cd-887522ee7f13&client_secret=secret&resource=https%3A%2F%2Fvault.azure.net' https://login.microsoftonline.com/a16a84bb-433f-4366-9240-ff2062e4e799/oauth2/token | sed -e 's/[{}]/''/g' | sed s/\"//g | awk -v RS=',' -F: '$1=="access_token"{print $2}')
## Set the password as a secret in the specified key vault using the access_token
responseCode=$(curl -s -w "%{response_code}" -o /dev/null -X PUT -d "{ \"value\": \"$password\" }" -H "Content-Type: application/json" -H "Authorization: Bearer $token" https://kv-ecm-prod.vault.azure.net/secrets/$serialNumber?api-version=7.4)

if [[ $responseCode == 200 ]]; then
    ## Add the admin user to the HiddenUsersList
    sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add $username
    ## Delete the current admin user, if it exists
    sudo sysadminctl -deleteUser $username
    ## Add the new admin user with the random password
    sudo sysadminctl -adminUser $username -adminPassword $password -addUser $username -fullName $fullName -password $password -admin
fi