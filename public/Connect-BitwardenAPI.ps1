Function Connect-BitwardenAPI {
<#
    .SYNOPSIS
        Connects to the Bitwarden API using client credentials authentication.

    .DESCRIPTION
        The Connect-BitwardenAPI function authenticates with the Bitwarden API using client credentials (OAuth2).
        It generates a device identifier and sends a POST request to obtain an access token.

    .PARAMETER Endpoint
        The Bitwarden API endpoint URL. Must start with 'https://'.

    .PARAMETER ClientID
        The client ID for API authentication.

    .PARAMETER ClientSecret
        The client secret for API authentication.

    .PARAMETER Scope
        The API scope for authentication. Valid values are 'api' or 'api.organization'.

    .PARAMETER GrantType
        The OAuth2 grant type. Defaults to 'client_credentials'.

    .EXAMPLE
        Connect-BitwardenAPI -Endpoint 'https://api.bitwarden.com' -ClientID 'your_client_id' -ClientSecret 'your_client_secret' -Scope 'api'

    .NOTES
        Device type 21 represents SDK as defined in Bitwarden server's DeviceType enum.
        Reference: https://github.com/bitwarden/server/blob/main/src/Core/Enums/DeviceType.cs

    .OUTPUTS
        Returns the API response containing the access token and other authentication details.
#>
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^https://.*')]
        [string]$Endpoint,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientID,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("api", "api.organization")]
        [string]$Scope,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$GrantType = 'client_credentials'
    )
    begin {
        Write-Verbose -Message "Generating a new Device identifier"
        $deviceIdentifier = New-Guid
        Write-Verbose -Message "Device Identifier: $deviceIdentifier"
        $splat = @{
            Uri         = $endpoint
            Method      = 'Post'
            Headers     = @{
                "Content-Type" = "application/x-www-form-urlencoded"
            }
            ErrorAction = 'Stop'
            Body        = @{
                'grant_type'       = $grantType
                'scope'            = $scope
                'client_Id'        = $clientID
                'client_secret'    = $ClientSecret
                'deviceIdentifier' = $deviceIdentifier
                'deviceName'       = 'pwsh'
                #devicetype 21 is SDK - https://github.com/bitwarden/server/blob/main/src/Core/Enums/DeviceType.cs
                'deviceType'       = 21
            }
        }
    }

    process {
        Try {
            Write-Verbose -Message "Sending request to $endpoint"
            $response = Invoke-RestMethod @splat
        }
        Catch {
            $_
        }
    }

    end {
        $response
    }
}