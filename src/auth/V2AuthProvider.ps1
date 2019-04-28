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

. (import-script AuthProvider)
. (import-script DeviceCodeAuthenticator)

ScriptClass V2AuthProvider {
    $base = $null
    function __initialize( $base ) {
        $this.base = $base
    }

    function GetAuthContext($app, $authUri) {
        if ( $app |=> IsConfidential ) {
            $credential = New-Object Microsoft.Identity.Client.ClientCredential -ArgumentList ($app.secret |=> GetSecretData)
            New-Object "Microsoft.Identity.Client.ConfidentialClientApplication" -ArgumentList @(
                $App.AppId,
                $authUri,
                $app.RedirectUri,
                $credential,
                ($this.scriptclass |=> GetTokenCacheForApp $app.AppId ([GraphAppAuthType]::AppOnly)),
                ($this.scriptclass |=> GetTokenCacheForApp $app.AppId ([GraphAppAuthType]::AppOnly)))
        } else {
            New-Object "Microsoft.Identity.Client.PublicClientApplication" -ArgumentList $App.AppId, $authUri, ($this.scriptclass |=> GetTokenCacheForApp $app.AppId ([GraphAppAuthType]::Delegated))
        }
    }

    function GetUserInformation($token) {
        $userId = $null
        $scopes = $null
        $userObjectId = $null

        if ( $token -and $token.Account ) {
            $userId = $token.Account.Username
            $scopes = $token.scopes
            $userObjectId = $token.uniqueid
        }

        [PSCustomObject]@{
            userId = $userId
            scopes = $scopes
            userObjectId = $userObjectId
        }
    }

    function AcquireFirstUserToken($authContext, $scopes) {
        write-verbose 'V2 auth provider acquiring initial user token'
        if ( $scopes -eq $null -or $scopes.length -eq 0 ) {
            throw [ArgumentException]::new('No scopes specified for v2 auth protocol, at least one scope is required')
        }

        $scopeList = $::.ScopeHelper |=> QualifyScopes $scopes $authContext.GraphEndpointUri

        $authContext.protocolContext.AcquireTokenAsync([System.Collections.Generic.List[string]] $scopeList)
    }

    function AcquireFirstUserTokenFromDeviceCode($authContext, $scopes) {
        write-verbose 'V2 auth provider acquiring initial user token using device code'
        $::.DeviceCodeAuthenticator |=> Authenticate $authContext.protocolcontext $scopes
    }

    function AcquireFirstAppToken($authContext) {
        write-verbose 'V2 auth provider acquiring initial app token'
        $defaultScopeList = $this |=> __GetDefaultScopeList $authContext

        $authContext.protocolContext.AcquireTokenForClientAsync([System.Collections.Generic.List[string]] $defaultScopeList)
    }

    function AcquireFirstUserTokenConfidential($authContext, $scopes) {
        write-verbose 'V2 auth provider acquiring user token via confidential client'

        $scopeList = $::.ScopeHelper |=> QualifyScopes $scopes $authContext.GraphEndpointUri

        # Confidential user flow uses an authcode flow with a confidential rather than public client.
        # First, get the auth code for the user -- MSAL does not support this, but it does return the URI
        # that lets you get the authcode (presumably you're a web app sending that URI to a client
        # web browser and not using it to get credentials locally as in our case). Once you have the auth code,
        # MSAL *does* support an API that lets you get a user token from the auth code using a confidential
        # client that must present its credentials.

        # 1. Get the auth code URI
        $uriResult = $authContext.protocolContext.GetAuthorizationRequestUrlAsync($scopeList, $null, $null)
        $authCodeUxUri = $uriResult.Result

        # 2. Use the URI to present a UX to the user via the URI to obtain credentials that
        # yield the authcode in a response
        $authCodeInfo = GetAuthCodeFromURIUserInteraction $authCodeUxUri

        # 3. Now use MSAL's confidential client to obtain the token from the auth code
        $authContext.protocolContext.AcquireTokenByAuthorizationCodeAsync($authCodeInfo.ResponseParameters.Code, [System.Collections.Generic.List[string]] $scopeList)
    }

    function AcquireRefreshedToken($authContext, $token) {
        write-verbose 'V2 auth provider refreshing existing token'

        if ( $authContext.app.authtype -eq ([GraphAppAuthType]::AppOnly) ) {
            $defaultScopeList = $this |=> __GetDefaultScopeList $authContext @()
            $authContext.protocolContext.AcquireTokenForClientAsync([System.Collections.Generic.List[string]] $defaultScopeList)
        } else {
            $requestedScopesFromToken = $::.ScopeHelper |=> QualifyScopes $token.scopes $authContext.GraphEndpointUri |
              where { $_ -notin @('openid', 'profile', 'offline_access') }
            $authContext.protocolContext.AcquireTokenSilentAsync([System.Collections.Generic.List[string]] $requestedScopesFromToken, $token.account)
        }
    }

    function ClearToken($authContext, $token) {
        write-verbose 'V2 auth provider clearing existing token'
        $user = $token.account
        $userUpn = $token.account.username
        write-verbose "Clearing token for user '$userUpn'"
        $asyncRemoveResult = $authContext.protocolContext.RemoveAsync($user)
        $asyncRemoveResult.Wait()
    }

    function __GetDefaultScopeList($authContext) {
        $::.ScopeHelper |=> QualifyScopes @('.default') $authContext.GraphEndpointUri
    }

    function GetAuthCodeFromURIUserInteraction($authUxUri) {
        add-type -AssemblyName System.Windows.Forms

        $form = new-object -typename System.Windows.Forms.Form -property @{width=600;height=640}
        $browser = new-object -typeName System.Windows.Forms.WebBrowser -property @{width=560;height=640;url=$authUxUri }

        $resultUri = $null
        $authError = $null
        $completedBlock = {
            # Use set-variable to access a variable outside the scope of this block
            set-variable resultUri -scope 1 -value $browser.Url
            if ($resultUri -match "error=[^&]*|code=[^&]*") {
                $authError = $resultUri
                $form.Close()
            }
        }

        $browser.Add_DocumentCompleted($completedBlock)
        $browser.ScriptErrorsSuppressed = $true

        $form.Controls.Add($browser)
        $form.Add_Shown({$form.Activate()})
        $form.ShowDialog() | out-null

        # The response mode for this uri is 'query', so we parse the query parameters
        # to get the result
        $queryParameters = [System.Web.HttpUtility]::ParseQueryString($resultUri.query)

        $queryResponseParameters = @{}

        $queryParameters.keys | foreach {
            $key = $_
            $value = $queryParameters.Get($_)

            $queryResponseParameters[$key] = $value
        }

        $errorDescription = if ( $queryResponseParameters['error'] ) {
            $authError = $queryResponseParameters['error']
            $queryResponseParameters['error_description']
        }

        if ( $authError ) {
            throw ("Error obtaining authorization code: {0}: '{2}' - {1}" -f $authError, $errorDescription, $resultUri)
        }

        @{
            ResponseUri = $resultUri
            ResponseParameters = $queryResponseParameters
        }
    }

    static {
        $__AuthLibraryLoaded = $false
        $__UserTokenCache = @{}
        $__AppTokenCache = @{}
        $scriptRoot = $null

        function __initialize($scriptRoot) {
            $this.scriptRoot = $scriptRoot
        }

        function InitializeProvider {
            if ( ! $this.__AuthLibraryLoaded ) {
                $libPath = join-path $this.scriptRoot ../../lib
                Import-Assembly Microsoft.Identity.Client -AssemblyRoot $libPath | out-null
                $this.__AuthLibraryLoaded = $true
            }
        }

        function GetTokenCacheForApp($appId, [GraphAppAuthType] $authType) {
            $cacheTable = if ( $authType -eq ([GraphAppAuthType]::Delegated) ) {
                $this.__UserTokenCache
            } else {
                $this.__AppTokenCache
            }

            $existingCache = $cacheTable[$appId]

            if ( $existingCache ) {
                $existingCache
            } else {
                $newCache = New-Object Microsoft.Identity.Client.TokenCache
                $cacheTable.Add($appId, $newCache)
                $newCache
            }
        }

        function RegisterProvider {
            $::.AuthProvider |=> RegisterProvider ([GraphAuthProtocol]::v2) $this
        }
    }
}

$::.V2AuthProvider |=> __initialize $psscriptroot
