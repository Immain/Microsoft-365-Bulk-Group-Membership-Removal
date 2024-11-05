# Import necessary modules
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Users

$envFile = Join-Path $PSScriptRoot ".env"

# Your Azure AD app registration details
$clientId = "CLIENT_ID"
$clientSecret = "CLIENT_SECRET"
$tenantId = "TENANT_ID"

# Get the access token
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}

try {
    $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody -ErrorAction Stop
    
    # Convert the access token to SecureString
    $secureAccessToken = ConvertTo-SecureString $tokenResponse.access_token -AsPlainText -Force

    # Connect to Microsoft Graph using the SecureString access token
    Connect-MgGraph -AccessToken $secureAccessToken

    # Prompt for user UPN
    $UPN = Read-Host "Enter the user's UPN"

    # Get all Microsoft 365 Groups (Unified Groups)
    $AADGroups = Get-MgGroup -Filter "groupTypes/any(c:c eq 'Unified')" -All

    # Get the user
    $AADUser = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"

    if ($null -eq $AADUser) {
        Write-Error "User with UPN $UPN not found."
        exit
    }

    # Iterate through each group
    foreach ($Group in $AADGroups) {
        # Check if the user is a member of the group
        try {
            $GroupMembers = Get-MgGroupMember -GroupId $Group.Id -ErrorAction Stop
            if ($GroupMembers.Id -contains $AADUser.Id) {
                # Remove user from Group
                try {
                    Remove-MgGroupMemberByRef -GroupId $Group.Id -DirectoryObjectId $AADUser.Id -ErrorAction Stop
                    Write-Output "$UPN is removed from Member of Group '$($Group.DisplayName)'"
                } catch {
                    Write-Warning "Failed to remove $UPN from Member of Group '$($Group.DisplayName)': $($_.Exception.Message)"
                }
            }
        } catch {
            Write-Warning "Failed to get members for Group '$($Group.DisplayName)': $($_.Exception.Message)"
        }

        # Check if the user is an owner of the group
        try {
            $GroupOwners = Get-MgGroupOwner -GroupId $Group.Id -ErrorAction Stop
            if ($GroupOwners.Id -contains $AADUser.Id) {
                # Remove user from Group Owners
                try {
                    Remove-MgGroupOwnerByRef -GroupId $Group.Id -DirectoryObjectId $AADUser.Id -ErrorAction Stop
                    Write-Output "$UPN is removed from Owner of Group '$($Group.DisplayName)'"
                } catch {
                    Write-Warning "Failed to remove $UPN from Owner of Group '$($Group.DisplayName)': $($_.Exception.Message)"
                }
            }
        } catch {
            Write-Warning "Failed to get owners for Group '$($Group.DisplayName)': $($_.Exception.Message)"
        }
    }

    # Disconnect from Microsoft Graph
    Disconnect-MgGraph
}
catch {
    Write-Error "An error occurred: $_"
}
