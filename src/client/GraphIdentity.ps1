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
    $TenantName = $null
    $TenantDisplayId = $null
    $TenantDisplayName = $null

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

        __UpdateTenantDisplayInfo
    }

    function GetUserInformation {
        if ( $this.App.AuthType -eq ([GraphAppAuthType]::Delegated) ) {
                 $providerInstance = $::.AuthProvider |=> GetProviderInstance $this.graphEndpoint.AuthProtocol
                 $providerInstance |=> GetUserInformation $this.token
        } else {
            [PSCustomObject]@{
                AppId = $this.App.AppId
                userId = $null
                scopes = $null
            }
        }
    }

    function Authenticate($scopes = $null) {
        if ( $this.token ) {
            $tokenTimeLeft = $this.token.expireson - [DateTime]::UtcNow
            write-verbose ("Found existing token with {0} minutes left before expiration" -f $tokenTimeLeft.TotalMinutes)
        }

        write-verbose ("Getting token for resource {0} from auth endpoint: {1} with protocol {2}" -f $this.graphEndpoint.Graph, $this.graphEndpoint.Authentication, $this.graphEndpoint.AuthProtocol)

        $this.Token = getGraphToken $this.graphEndpoint $scopes

        if ($this.token -eq $null) {
            throw "Failed to acquire token, no additional error information"
        }

        __UpdateTenantDisplayInfo
    }

    function ClearAuthentication {
        if ( $this.token ) {
            $authUri = $this.graphEndpoint |=> GetAuthUri $this.TenantName

            $providerInstance = $::.AuthProvider |=> GetProviderInstance $this.graphEndpoint.AuthProtocol
            $authContext = $providerInstance |=> GetAuthContext $this.app $this.graphEndpoint.Graph $authUri
            $providerInstance |=> ClearToken $authContext $this.token

            $this.token = $null
        }
    }

    function getGraphToken($graphEndpoint, $scopes) {
        write-verbose "Using generic path..."
        write-verbose "Attempting to get token for '$($graphEndpoint.Graph)' ..."
        write-verbose "Using app id '$($this.App.AppId)'"

        write-verbose ("Adding scopes to request: {0}" -f ($scopes -join ';'))

        $authUri = $graphEndpoint |=> GetAuthUri $this.TenantName
        write-verbose ("Sending auth request to auth uri '{0}'" -f $authUri)

        $providerInstance = $::.AuthProvider |=> GetProviderInstance $graphEndpoint.AuthProtocol

        $authContext = $providerInstance |=> GetAuthContext $this.app $graphEndpoint.Graph $authUri

        $authResult = if ( $this.token ) {
            $providerInstance |=> AcquireRefreshedToken $authContext $this.token
        } else {
            if ( $this.App.AuthType -eq ([GraphAppAuthType]::Apponly) ) {
                $providerInstance |=> AcquireFirstAppToken $authContext
            } else {
                $providerInstance |=> AcquireFirstUserToken $authContext $scopes
            }
        }

        write-verbose ("`nToken request status: {0}" -f $authResult.Status)

        if ( $authResult.Status -eq 'Faulted' ) {
            throw "Failed to acquire token for uri '$($graphEndpoint.Graph)' for AppID '$($this.App.AppId)'`n" + $authResult.exception, $authResult.exception
        }

        $result = $authResult.Result

        if ( $authResult.IsFaulted ) {
            write-verbose $authResult.Exception
            throw [Exception]::new(("An authentication error occurred: '{0}'. See verbose output for additional details" -f $authResult.Exception.message), $authResult.Exception)
        }

        try {
            if ( ! $this.tenantId -and $result.tenantid ) {
                $this.tenantid = $result.tenantid
            }
        } catch {
        }

        $result
    }

    function __UpdateTenantDisplayInfo {
        $tenant = try {
            if ( $this.token ) {
                (([uri] $this.token.authority).segments | select -last 1).trimend('/')
            }
        } catch {
        }

        if ( ! $tenant ) {
            $tenant = try {
                (([uri] $this.token.user.identityprovider).segments | select -first 2 | select -last 1).trimend('/')
            } catch {
            }
        }

        $tenantName = $null
        $tenantId = try {
            if ( $this.token ) {
                $this.token.tenantId
            }
        } catch {
        }

        $parsedTenantId = try {
            if ( $tenant ) {
                [guid] $tenant
            }
        } catch {
            $tenantName = $tenant
        }

        if ( ! $tenantName ) {
            $tenantName = $this.tenantName
        }

        if ( ! $tenantId ) {
            $tenantId = $parsedTenantId
        }

        $this.tenantDisplayId = $tenantId
        $this.tenantDisplayName = $tenantName
    }
}

$::.GraphIdentity |=> __initialize
