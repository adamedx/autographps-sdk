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

ScriptClass GraphIdentity {
    $App = strict-val [PSCustomObject]
    $Token = strict-val [PSCustomObject] $null
    $GraphEndpoint = strict-val [PSCustomObject] $null
    $V2AuthContext = $null
    $TenantName = $null

    static {
        $__AuthLibraryLoaded = $null
        $__TokenCache = $null

        function __InitializeTokenCache {
            if ( ! $this.__TokenCache ) {
                # Initialize this cache once per process
                $this.__TokenCache = New-Object "Microsoft.Identity.Client.TokenCache"
            }
        }
    }

    function __initialize([PSCustomObject] $app, [PSCustomObject] $graphEndpoint, [String] $tenantName) {
        $this.App = $app
        $this.GraphEndpoint = $graphEndpoint
        $this.TenantName = $tenantName
    }

    function GetUserInformation {
        $authProtocol = $this.GraphEndPoint.AuthProtocol

        $userId = $null
        $scopes = $null

        if ( $this.token ) {
            if ( $authProtocol -eq ([GraphAuthProtocol]::v1) ) {
                $userId = $this.token.UserInfo.DisplayableId
                $scopes = $null
            } elseif ( $authProtocol -eq ([GraphAuthProtocol]::v2) ) {
                $userId = $this.token.User.DisplayableId
                $scopes = $this.token.scopes
            } else {
                throw ("Unknown auth protocol '{0}'" -f $authProtocol)
            }
        }

        @{
            userId = $userId
            scopes = $scopes
        }
    }

    function Authenticate($graphEndpoint, $scopes = $null) {
        if ( $this.token ) {
            $tokenTimeLeft = $this.token.expireson - [DateTime]::UtcNow
            write-verbose ("Found existing token with {0} minutes left before expiration" -f $tokenTimeLeft.TotalMinutes)

            if ( $graphEndpoint.AuthProtocol -ne [GraphAuthProtocol]::v2 ) {
                write-verbose "Using existing token -- will not attempt refresh since it is not a v2 token"
                return
            }
        }

        if ( $graphEndpoint.AuthProtocol -ne [GraphAuthProtocol]::v1 -and ( $scopes -eq $null -or $scopes.length -eq 0 ) ) {
            throw [ArgumentException]::new('No scopes specified for v1 auth protocol, at least one scope is required')
        }

        $this.scriptclass |=> __LoadAuthLibrary $graphEndpoint.AuthProtocol

        write-verbose ("Getting token for resource {0} from auth endpoint: {1} with protocol {2}" -f $graphEndpoint.Graph, $graphEndpoint.Authentication, $graphEndpoint.AuthProtocol)

        # Cast it in case this is a deserialized object --
        # workaround for a defect in ScriptClass
        $this.Token = switch ([GraphAuthProtocol] $graphEndpoint.AuthProtocol) {
            ([GraphAuthProtocol]::v2) { getV2ProtocolGraphToken $graphEndpoint $scopes }
            ([GraphAuthProtocol]::v1) { getV1ProtocolGraphToken $graphEndpoint $scopes }
            default {
                throw "Unexpected Graph protocol '$($graphEndpoint.GraphAuthProtocol)'"
            }
        }

        if ($this.token -eq $null) {
            throw "Failed to acquire token, no additional error information"
        }
    }

    function ClearAuthentication {
        if ( $this.token ) {
            $userUpn = if ( $this.V2AuthContext ) {
                $this.token.user.displayableid
            } else {
                $this.token.userinfo.displayableid
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

    static {
        function __LoadAuthLibrary([GraphAuthProtocol] $authProtocol) {
            if ( $this.__AuthLibraryLoaded -eq $null ) {
                $this.__AuthLibraryLoaded = @{}
            }

            if ( ! $this.__AuthLibraryLoaded[$authProtocol] ) {
                # Cast it in case this is a deserialized object --
                # workaround for a defect in ScriptClass
                switch ( [GraphAuthProtocol] $authProtocol ) {
                    ([GraphAuthProtocol]::v2) {
                        import-assembly ../../lib/Microsoft.Identity.Client.dll
                    }
                    ([GraphAuthProtocol]::v1) {
                        import-assembly ../../lib/Microsoft.IdentityModel.Clients.ActiveDirectory.dll
                    }
                    default {
                        throw "Unexpected graph type '$authProtocol'"
                    }
                }

                $this.__AuthLibraryLoaded[$authProtocol] = $true
            } else {
                write-verbose "Library already loaded for graph type '$authProtocol'"
            }
        }
    }

    function getV2ProtocolGraphToken($graphEndpoint, $scopes) {
        write-verbose "Attempting to get token for '$($graphEndpoint.Graph)' using V2 protocol..."
        write-verbose "Using app id '$($this.App.AppId)'"

        $this.scriptclass |=> __InitializeTokenCache
        $authUri = $graphEndpoint |=> GetAuthUri $this.TenantName
        write-verbose ("Sending auth request to auth uri '{0}'" -f $authUri)

        $msalAuthContext = New-Object "Microsoft.Identity.Client.PublicClientApplication" -ArgumentList $this.App.AppId, $authUri, $this.scriptclass.__TokenCache

        $requestedScopes = new-object System.Collections.Generic.List[string]

        write-verbose ("Adding scopes to request: {0}" -f ($scopes -join ';'))

        $scopes | foreach {
            $requestedScopes.Add($_)
        }

        $authResult = if ( $this.token ) {
            # Use the silent API since we already have a token that includes a
            # refresh token -- even if our access token has expired, the refresh
            # token can be used to get a new access token without a prompt for ux
            write-verbose 'Acquiring token from existing token -- no user interaction'
            $msalAuthContext.AcquireTokenSilentAsync($requestedScopes, $this.token.User)
        } else {
            # We have no token, so we cannot use the silent flow and a ux
            # prompt must be shown
            write-verbose 'Acquiring new token -- user interaction will be required'
            $msalAuthContext.AcquireTokenAsync($requestedScopes)
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

        $this.V2AuthContext = $msalAuthContext
        $result
    }

    function getV1ProtocolGraphToken($graphEndpoint, $scopes) {
        write-verbose "Attempting to get token for '$($graphEndpoint.Graph)' using V1 protocol..."
        write-verbose "Using app id '$($this.App.AppId)'"
        write-verbose "Using redirect uri '$($this.app.redirecturi)'"

        $authUri = $graphEndpoint |=> GetAuthUri $this.TenantName
        write-verbose ("Sending auth request to auth uri '{0}'" -f $authUri)

        $adalAuthContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authUri

        $promptBehaviorValue = ([Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto)

        $promptBehavior = new-object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList $promptBehaviorValue

        $authResult = $adalAuthContext.AcquireTokenAsync(
            $graphEndpoint.Graph,
            $this.App.AppId,
            $this.App.RedirectUri,
            $promptBehavior)

        if ( $authResult.Status -eq 'Faulted' ) {
            throw "Failed to acquire token for uri '$($graphEndpoint.Graph)' for AppID '$($this.App.AppId)'`n" + $authResult.exception, $authResult.exception
        }
        $authResult.Result
    }
}

