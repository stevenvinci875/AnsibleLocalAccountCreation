# This script is to be run on BOH computers
# This script removes all users in the Administrators group, except for Admin, Administrator, SecOpsDiscovery, LogMeInRemoteUser, LogMeInRemoteUse

try {
    # Retrieve members from the Administrators group
    $AdministratorsGroupMembers = $(net localgroup Administrators)

    # Filter out invalid lines and headers
    $AdministratorsGroupMembers = $AdministratorsGroupMembers | Where-Object { 
     $_.Trim() -ne '' -and
        -not ($_ -match '^-+$|^The command completed successfully.$|^Members$|^Alias name\s+Administrators$|^Comment\s+Administrators have complete and unrestricted access to the computer/domain$|^$')
    }

    # Define users to keep
    $usersToKeep = @("Admin", "Administrator", "SecOpsDiscovery", "LogMeInRemoteUser", "LogMeInRemoteUse")

    foreach ($member in $AdministratorsGroupMembers) {
        if ($usersToKeep -notcontains $member) {
            # Attempt to remove the user
            Remove-LocalGroupMember "Administrators" $member
        }
    }
}
catch {
    Write-Host -ForegroundColor red "Script failed. Error: $($_.Exception.Message)"
}
