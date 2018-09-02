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

ScriptClass V1AuthProvider {
    $base = $null
    function __initialize( $base ) {
        $this.base = $base
    }

    function GetAuthContext($app, $graphEndpointUri, $authUri) {
        New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authUri, $this.scriptclass.__TokenCache
    }

    function GetUserInformation($token) {
        $userId = $null
        $scopes = $null

        if ( $token ) {
            $userId = $token.UserInfo.DisplayableId
            $scopes = $null
        }

        [PSCustomObject]@{
            userId = $userId
            scopes = $scopes
        }
    }

    function AcquireFirstUserToken($authContext, $scopes) {
        write-verbose 'V1 auth provider acquiring initial user token'

        $promptBehaviorValue = ([Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto)
        $promptBehavior = new-object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList $promptBehaviorValue

        $authContext.protocolContext.AcquireTokenAsync(
            $authContext.GraphEndpointUri,
            $authContext.App.AppId,
            $authContext.App.RedirectUri,
            $promptBehavior)
    }

    function AcquireFirstAppToken($authContext) {
        write-verbose 'V1 auth provider acquiring initial app token'

        __AcquireAppToken $authContext
    }

    function AcquireRefreshedToken($authContext, $token) {
        write-verbose 'V1 auth provider refreshing existing token'

        # The token is irrelevant for v1 auth, since scopes are
        # static and defined per app in v1. So for app-only auth,
        # the token cache can just use the app id as a key, and
        # for user auth, app+user is the key -- if the auth context
        # has a token cache, that's all you need to look up the
        # previously used token
        if ( $authContext.app.authtype -eq ([GraphAppAuthType]::AppOnly) ) {
            __AcquireAppToken $authContext
        } else {
            $userId = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier -ArgumentList $token.userinfo.uniqueid, ([Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifierType]::UniqueId)
            $authContext.protocolContext.AcquireTokenSilentAsync(
                $authContext.GraphEndpointUri,
                $authContext.App.AppId,
                $userId)
        }
    }

    function ClearToken($authContext, $token) {
        write-verbose 'V1 auth provider clearing existing token'
        $userUpn = if ($token.userinfo) {
            $token.userinfo.displayableid
        }
        write-verbose "Clearing token for user '$userUpn'"

        $tokenAsCacheItem = $this.scriptclass.__tokencache.ReadItems() | where { $_.accesstoken -eq $token.accesstoken }

        if ( $tokenAsCacheItem ) {
            write-verbose "Found cached token, clearing..."
            $this.scriptclass.__TokenCache.DeleteItem($tokenAsCacheItem)
            write-verbose "Successfully cleared token from the cache"
        } else {
            write-verbose "Unable to find cached token, skipping unnecessary removal from cache"
        }
    }

    function __AcquireAppToken($authContext) {
        write-verbose 'V1 auth provider acquiring app token'

        if ( $authContext.app.secret.type -ne ([SecretType]::Password) ) {
            throw [ArgumentException]::new("Unsupported secret type '{0}' -- only 'Password' secrets are supported for the v1 auth protocol" -f $authContext.app.secret.type)
        }

        $clientSecret = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.SecureClientSecret -ArgumentList $authcontext.app.secret.data
        $clientCredential = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential -ArgumentList $authContext.App.AppId, $clientSecret

        $authContext.protocolContext.AcquireTokenAsync(
            $authContext.GraphEndpointUri,
            $clientCredential)
    }


    static {
        $__AuthLibraryLoaded = $false
        $__TokenCache = $null

        function InitializeProvider {
            if ( ! $this.__AuthLibraryLoaded ) {
                import-assembly ../../lib/Microsoft.IdentityModel.Clients.ActiveDirectory.dll
                $this.__AuthLibraryLoaded = $true
            }

            if ( ! $this.__TokenCache ) {
                $this.__TokenCache = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.TokenCache
            }
        }

        function RegisterProvider {
            $::.AuthProvider |=> RegisterProvider ([GraphAuthProtocol]::v1) $this
        }
    }
}
