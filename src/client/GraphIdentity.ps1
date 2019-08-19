# Copyright 2019, Adam Edwards
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

. (import-script ../graphservice/GraphEndpoint)
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
        $AuthProvidersInitialized = $false
        function __initialize {
            $::.V1AuthProvider |=> RegisterProvider
            $::.V2AuthProvider |=> RegisterProvider
        }
    }

    function __initialize([PSCustomObject] $app, [PSCustomObject] $graphEndpoint, [String] $tenantName) {
        $this.App = $app
        $this.GraphEndpoint = $graphEndpoint
        $this.TenantName = $tenantName

        $this |=> __UpdateTenantDisplayInfo
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

    function Authenticate($scopes = $null, $noBrowserUI = $false) {
        if ( $this.token ) {
            $tokenTimeLeft = $this.token.expireson - [DateTime]::UtcNow
            write-verbose ("Found existing token with {0} minutes left before expiration" -f $tokenTimeLeft.TotalMinutes)
        }

        write-verbose ("Getting token for resource {0} from auth endpoint: {1} with protocol {2}" -f $this.graphEndpoint.Graph, $this.graphEndpoint.Authentication, $this.graphEndpoint.AuthProtocol)

        $this.Token = getGraphToken $this.graphEndpoint $scopes $noBrowserUI

        if ($this.token -eq $null) {
            throw "Failed to acquire token, no additional error information"
        }

        $this |=> __UpdateTenantDisplayInfo
    }

    function ClearAuthentication {
        if ( $this.token -and $this.app.AuthType -eq ([GraphAppAuthType]::Delegated) ) {
            $authUri = $this.graphEndpoint |=> GetAuthUri $this.TenantName

            $providerInstance = $::.AuthProvider |=> GetProviderInstance $this.graphEndpoint.AuthProtocol
            $authContext = $providerInstance |=> GetAuthContext $this.app $this.graphEndpoint.Graph $authUri
            $providerInstance |=> ClearToken $authContext $this.token
        }

        $this.token = $null
    }

    function getGraphToken($graphEndpoint, $scopes, $noBrowserUI) {
        write-verbose "Attempting to get token in tenant '$($this.tenantName)' for '$($graphEndpoint.Graph)' ..."
        write-verbose "Using app id '$($this.App.AppId)'"
        $isConfidential = ($this.app |=> IsConfidential)
        write-verbose ("Is confidential client: '{0}'" -f $isConfidential)

        write-verbose ("Adding scopes to request: {0}" -f ($scopes -join ';'))

        $authUri = $graphEndpoint |=> GetAuthUri $this.TenantName
        write-verbose ("Sending auth request to auth uri '{0}'" -f $authUri)

        if ( ! $this.scriptclass.AuthProvidersInitialized ) {
            $::.AuthProvider |=> InitializeProviders
            $this.scriptclass.AuthProvidersInitialized = $true
        }

        $providerInstance = $::.AuthProvider |=> GetProviderInstance $graphEndpoint.AuthProtocol

        $authContext = $providerInstance |=> GetAuthContext $this.app $graphEndpoint.Graph $authUri

        $authResult = if ( $this.token ) {
            $providerInstance |=> AcquireRefreshedToken $authContext $this.token
        } else {
            if ( $this.App.AuthType -eq ([GraphAppAuthType]::Apponly) ) {
                $providerInstance |=> AcquireFirstAppToken $authContext
            } else {
                if ( $isConfidential ) {
                    $providerInstance |=> AcquireFirstUserTokenConfidential $authContext $scopes
                } else {
                    $providerInstance |=> AcquireFirstUserToken $authContext $scopes $noBrowserUI
                }
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

        if ( ! $this.tenantDisplayId -and ( $result | gm -erroraction ignore tenantid ) ) {
            if ( $result.tenantid ) {
                $this.tenantDisplayId = $result.tenantid
            }
        }

        $result
    }

    function GetTenantId($specifiedTenantId) {
        if ( $specifiedTenantId ) {
            $specifiedTenantId
        } else {
            $this |=> __UpdateTenantDisplayInfo
            $this.tenantDisplayId
        }
    }

    function __UpdateTenantDisplayInfo {
        $tenant = if ( $this.token -and ( $this.token | gm authority -erroraction ignore ) ) {
            (([uri] $this.token.authority).segments | select -last 1).trimend('/')
        }

        if ( ! $tenant ) {
            $tenant = if ( $this.token -and ( $this.token | gm user -erroraction ignore ) ) {
                if ( $this.token.user | gm identityprovider -erroraction ignore ) {
                    (([uri] $this.token.user.identityprovider).segments | select -first 2 | select -last 1).trimend('/')
                }
            }
        }

        $tenantName = $null
        $tenantId = try {
            if ( $this.token ) {
                $this.token.tenantId
            }
        } catch {
        }

        $isGuid = $false
        $parsedTenantId = $null

        if ( $tenant ) {
            $outputGuid = (new-guid).guid
            $isGuid = [guid]::TryParse($tenant, [ref] $outputguid)
            if ( $isGuid ) {
                $parsedTenantid = $outputguid
            }
        }

        if ( ! $isGuid ) {
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
