# Copyright 2018, Adam Edwards
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. (import-script ../GraphService/GraphEndpoint)
. (import-script GraphApplication)
. (import-script ../auth/AuthProvider)
. (import-script ../auth/V1AuthProvider)
. (import-script ../auth/V2AuthProvider)

ScriptClass GraphIdentity {
    $App = strict-val [PSCustomObject]
    $Token = strict-val [PSCustomObject] $null
    $GraphEndpoint = strict-val [PSCustomObject] $null
    $V2AuthContext = $null
    $TenantName = $null

    static {
        function __initialize {
            $::.V1AuthProvider |=> RegisterProvider
            $::.V2AuthProvider |=> RegisterProvider
            $::.AuthProvider |=> InitializeProviders
        }
    }

    function __initialize([PSCustomObject] $app, [PSCustomObject] $graphEndpoint, [String] $tenantName) {
        $this.App = $app
        $this.GraphEndpoint = $graphEndpoint
        $this.TenantName = $tenantName
    }

    function GetUserInformation {
        $providerInstance = $::.AuthProvider |=> GetProviderInstance $graphEndpoint.AuthProtocol
        $providerInstace |=> GetUserInformation $token
    }

    function Authenticate($graphEndpoint, $scopes = $null) {
        if ( $this.token ) {
            $tokenTimeLeft = $this.token.expireson - [DateTime]::UtcNow
            write-verbose ("Found existing token with {0} minutes left before expiration" -f $tokenTimeLeft.TotalMinutes)
        }

        write-verbose ("Getting token for resource {0} from auth endpoint: {1} with protocol {2}" -f $graphEndpoint.Graph, $graphEndpoint.Authentication, $graphEndpoint.AuthProtocol)

        $this.Token = getGraphToken $graphEndpoint $scopes

        if ($this.token -eq $null) {
            throw "Failed to acquire token, no additional error information"
        }
    }

    function ClearAuthentication {
        if ( $this.token ) {
            $userUpn = if ( $this.V2AuthContext ) {
                if ( $this.token.user ) {
                    $this.token.user.displayableid
                }
            } else {
                if ( $this.token.userinfo ) {
                    $this.token.userinfo.displayableid
                }
            }
            write-verbose "Clearing token for user '$userUpn'"
            if ( $this.V2AuthContext ) {
                write-verbose "Calling Remove on V2 auth context to remove user from token cache"
                $this.V2AuthContext.Remove($this.token.user)
                write-verbose "Clearing V2 auth context"
                $this.V2AuthContext = $null
            }
        }
        $this.token = $null
    }

    function getGraphToken($graphEndpoint, $scopes) {
        write-verbose "Using generic path..."
        write-verbose "Attempting to get token for '$($graphEndpoint.Graph)' using V2 protocol..."
        write-verbose "Using app id '$($this.App.AppId)'"

        write-verbose ("Adding scopes to request: {0}" -f ($scopes -join ';'))
        $requestedScopes = new-object System.Collections.Generic.List[string]
        $scopes | foreach {
            $requestedScopes.Add($_)
        }

        $authUri = $graphEndpoint |=> GetAuthUri $this.TenantName
        write-verbose ("Sending auth request to auth uri '{0}'" -f $authUri)

        $providerInstance = $::.AuthProvider |=> GetProviderInstance $graphEndpoint.AuthProtocol

        $authContext = $providerInstance |=> GetAuthContext $this.app $graphEndpoint.Graph $authUri

        $authResult = if ( $this.token ) {
            $providerInstance |=> AcquireTokenFromToken $authContext $requestedScopes $this.token
        } else {
            if ( $this.app |=> IsConfidential ) {
                $providerInstance |=> AcquireInitialAppToken $authContext $requestedScopes
            } else {
                $providerInstance |=> AcquireInitialUserToken $authContext $requestedScopes
            }
        }

        write-verbose ("`nToken request status: {0}" -f $authResult.Status)

        if ( $authResult.Status -eq 'Faulted' ) {
            throw "Failed to acquire token for uri '$($graphEndpoint.Graph)' for AppID '$($this.App.AppId)'`n" + $authResult.exception, $authResult.exception
        }

        $result = $authResult.Result

        if ( $authResult.IsFaulted ) {
            write-verbose $authResult.Exception
            throw $authResult.Exception
        }

        $this.V2AuthContext = if ( $graphendpoint.authprotocol -eq ([GraphAuthProtocol]::v2) ) {
            $authContext.protocolContext
        }

        $result
    }
}

$::.GraphIdentity |=> __initialize
