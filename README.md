# Microsoft 365 Bulk Group Membership Removal

This PowerShell script removes a specified user from all Microsoft 365 Groups (Unified Groups) in your Azure Active Directory tenant, both as a member and as an owner.

## Description

The script performs the following actions:

1. Authenticates to Microsoft Graph using an Azure AD application's credentials.
2. Prompts for a user's User Principal Name (UPN).
3. Retrieves all Microsoft 365 Groups in the tenant.
4. For each group:
   - Checks if the specified user is a member and removes them if so.
   - Checks if the specified user is an owner and removes them if so.
5. Outputs the results of each removal operation.

## Requirements

- PowerShell 5.1 or later
- Microsoft Graph PowerShell SDK modules:
  - Microsoft.Graph.Authentication
  - Microsoft.Graph.Groups
  - Microsoft.Graph.Users
- An Azure AD application with the following permissions:
  - Group.ReadWrite.All
  - User.Read.All

## Setup

1. Register an application in Azure AD with the required permissions.
2. Create a client secret for the application.
3. Replace the placeholder values in the script:
   - `CLIENT_ID`: Your Azure AD application's client ID
   - `CLIENT_SECRET`: Your Azure AD application's client secret
   - `TENANT_ID`: Your Azure AD tenant ID

## Usage

1. Ensure you have the required PowerShell modules installed.
2. Run the script in PowerShell.
3. When prompted, enter the UPN of the user you want to remove from all Microsoft 365 Groups.

## Notes

- This script will attempt to remove the specified user from all Microsoft 365 Groups, regardless of the user's current membership status.
- The script requires appropriate permissions to modify group memberships and ownerships.
- Error handling is implemented to catch and report issues with individual group operations.

## Caution

Use this script carefully, as it will remove the specified user from all Microsoft 365 Groups in your tenant. Ensure you have the necessary approvals and understand the implications before running this script in a production environment.
