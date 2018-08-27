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

. (import-script AuthProvider)

ScriptClass V2AuthProvider {
    $base = $null
    function __initialize( $base ) {
        $this.base = $base
    }

    function GetAuthContext($app, $graphUri, $authUri) {
        if ( $app |=> IsConfidential ) {
            $base64Secret = $app.secret # __SecretStringToBase64EncodedString $app.secret
            $credential = New-Object "Microsoft.Identity.Client.ClientCredential" -ArgumentList $base64Secret

            New-Object "Microsoft.Identity.Client.ConfidentialClientApplication" -ArgumentList @(
                $App.AppId,
                $authUri,
                $app.RedirectUri,
                $credential,
                $null,
                $this.scriptclass.__AppTokenCache)
        } else {
            New-Object "Microsoft.Identity.Client.PublicClientApplication" -ArgumentList $App.AppId, $authUri, $this.scriptclass.__UserTokenCache
        }
    }

    function GetUserInformation($token) {
        $userId = $null
        $scopes = $null

        if ( $this.token ) {
            $userId = $this.token.User.DisplayableId
            $scopes = $this.token.scopes
        }

        @{
            userId = $userId
            scopes = $scopes
        }
    }

    function AcquireInitialUserToken($authContext, $scopes) {
        write-verbose 'V2 auth provider acquiring initial user token'
        if ( $scopes -eq $null -or $scopes.length -eq 0 ) {
            throw [ArgumentException]::new('No scopes specified for v1 auth protocol, at least one scope is required')
        }

        $authContext.protocolContext.AcquireTokenAsync($scopes)
    }

    function AcquireInitialAppToken($authContext, $scopes) {
        write-verbose 'V2 auth provider acquiring initial app token'
        $requestedScopes = new-object System.Collections.Generic.List[string]
        $defaultScope = $authContext.GraphEndpointUri.tostring().trimend(), '.default' -join '/'
        $requestedScopes.Add($defaultScope)

        $authContext.protocolContext.AcquireTokenForClientAsync($requestedScopes)
    }

    function AcquireTokenFromToken($authContext, $scopes, $token) {
        write-verbose 'V2 auth provider acquiring token from existing token'
        if ( $authContext.app |=> IsConfidential ) {
            $requestedScopes = new-object System.Collections.Generic.List[string]
            $defaultScope = $authContext.GraphEndpointUri.tostring().trimend(), '.default' -join '/'
            $requestedScopes.Add($defaultScope)
            $authContext.protocolContext.AcquireTokenForClientAsync($requestedScopes)
        } else {
            $authContext.protocolContext.AcquireTokenSilentAsync($scopes, $token.user)
        }
    }

    static {
        $__AuthLibraryLoaded = $false
        $__UserTokenCache = $null
        $__AppTokenCache = $null

        function InitializeProvider {
            if ( ! $this.__AuthLibraryLoaded ) {
                import-assembly ../../lib/Microsoft.Identity.Client.dll
                $this.__AuthLibraryLoaded = $true
            }

            if ( ! $this.__UserTokenCache ) {
                $this.__UserTokenCache = New-Object Microsoft.Identity.Client.TokenCache
            }

            if ( ! $this.__AppTokenCache ) {
                $this.__AppTokenCache = New-Object Microsoft.Identity.Client.TokenCache
            }
        }

        function RegisterProvider {
            $::.AuthProvider |=> RegisterProvider ([GraphAuthProtocol]::v2) $this
        }
    }
}
