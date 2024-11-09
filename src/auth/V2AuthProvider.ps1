# Copyright 2021, Adam Edwards
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

. (import-script DeviceCodeAuthenticator)
. (import-script ConsoleAPI)

ScriptClass V2AuthProvider {
    # TODO: Consider removing this store of app contexts, and making auth context
    # a part of the connection itself, since for v2 auth at least this is actually
    # what has been done through group id. At the very least we could move to
    # making group id the only key and do away with the multi-level hash table.
    $publicAppContexts = $null
    $confidentialAppContexts = $null

    function __initialize {
        $this.publicAppContexts = @{}
        $this.confidentialAppContexts = @{}
        $this.scriptclass |=> InitializeProvider
    }

    # The group id concept is really about associating auth context with a connnection so
    # we can look up the right authcontext for a connection. A better approach may be
    # to simply make the auth context part of the connection itself rather than part of
    # a store maintained here.
    function GetAuthContext($app, $authUri, $groupId, [securestring] $certificatePassword, [bool] $useBroker = $false) {
        $isConfidential = $app |=> IsConfidential
        write-verbose "Searching for app context for appid '$($app.AppId)' and uri '$authUri' -- confidential:$isConfidential, groupid '$groupId'"
        $existingApp = $this |=> __GetAppContext $isConfidential $app.AppId $authUri $groupId
        if ( $existingApp ) {
            write-verbose ("Found existing app context with hashcode {0}" -f $existingApp.GetHashCode())
            $existingApp
        } else {
            $targetAppBuilder = if ( $isConfidential ) {
                write-verbose "Confidential app context not found -- will create new context"
                $confidentialAppBuilder = [Microsoft.Identity.Client.ConfidentialClientApplicationBuilder]::Create($app.appid).WithAuthority($authUri).WithRedirectUri($app.RedirectUri)
                $secretCredential = ($app.secret |=> GetSecretData $certificatePassword)

                $confidentialApp = if ( $app.secret.type -eq [SecretType]::Certificate ) {
                    $confidentialAppBuilder.WithCertificate($secretCredential)
                } else {
                    $confidentialAppBuilder.WithClientSecret($secretCredential)
                }

                $confidentialApp
            } else {
                write-verbose "Public app context not found -- will create new context"
                $publicApp = [Microsoft.Identity.Client.PublicClientApplicationBuilder]::Create($App.AppId).WithAuthority($authUri, $true).WithRedirectUri($app.RedirectUri)

                # The broker is supported only on the PublicClientApplication type
                if ( $useBroker ) {
                    $currentOS = [System.Environment]::OSVersion.Platform
                    if ( $currentOS -ne 'Win32NT' ) {
                        throw [System.NotSupportedException]::new("The authentication broker option was specified, but the current OS platform '$currentOS' does not support brokers. This capability is supported only on the Windows OS platform")
                    }

                    # Reiterating: currently the extension builder method below is only supported on the PublicClientApplication
                    $withParentWindow = $publicApp.WithParentActivityOrWindow( ($::.ConsoleAPI |=> GetConsoleWindow ) )

                    $brokerOptions = [Microsoft.Identity.Client.BrokerOptions]::new([Microsoft.Identity.Client.BrokerOptions+OperatingSystems]::Windows)
                    $brokerOptions.Title = 'AutoGraphPS PowerShell'
                    [Microsoft.Identity.Client.Broker.BrokerExtension]::WithBroker($withParentWindow, $brokerOptions)
                } else {
                    $publicApp
                }
            }

            $newApp = $targetAppBuilder.Build()

            $this |=> __AddAppContext $isConfidential $app.AppId $authUri $newApp $groupId

            $newApp
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
        $this |=> __AcquireTokenInteractive $authContext $scopes
    }

    function AcquireFirstUserTokenFromDeviceCode($authContext, $scopes) {
        write-verbose 'V2 auth provider acquiring initial user token using device code'
        $::.DeviceCodeAuthenticator |=> Authenticate $authContext.protocolcontext $scopes
    }

    function AcquireFirstAppToken($authContext, [securestring] $certificatePassword) {
        write-verbose 'V2 auth provider acquiring initial app token'
        $defaultScopeList = $this |=> __GetDefaultScopeList $authContext

        $authContext.protocolContext.AcquireTokenForClient([System.Collections.Generic.List[string]] $defaultScopeList).ExecuteAsync()
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
        $uriResult = $authContext.protocolContext.GetAuthorizationRequestUrl([string[]]$scopeList).ExecuteAsync()
        $authCodeUxUri = $uriResult.Result

        # 2. Use the URI to present a UX to the user via the URI to obtain credentials that
        # yield the authcode in a response
        $authCodeInfo = GetAuthCodeFromURIUserInteraction $authCodeUxUri

        # 3. Now use MSAL's confidential client to obtain the token from the auth code
        $authContext.protocolContext.AcquireTokenByAuthorizationCode([System.Collections.Generic.List[string]] $scopeList, $authCodeInfo.ResponseParameters.Code).ExecuteAsync()
    }

    function AcquireRefreshedToken($authContext, $token) {
        write-verbose 'V2 auth provider refreshing existing token'

        if ( $authContext.app.authtype -eq ([GraphAppAuthType]::AppOnly) ) {
            $defaultScopeList = $this |=> __GetDefaultScopeList $authContext @()
            $authContext.protocolContext.AcquireTokenForClient([System.Collections.Generic.List[string]] $defaultScopeList).ExecuteAsync()
        } else {
            $cachedAccount = $authContext.protocolContext.GetAccountsAsync().Result | select -first 1

            try {
                $authContext.protocolContext.AcquireTokenSilent([System.Collections.Generic.List[string]] @(), $cachedAccount).ExecuteAsync()
            } catch [Microsoft.Identity.Client.MsalUiRequiredException] {
                write-verbose 'Acquire silent failed, retrying interactive'
                $this |=> __AcquireTokenInteractive $authContext @($::.ScopeHelper.DefaultScope)
            }
        }
    }

    function ClearToken($authContext, $token) {
        write-verbose 'V2 auth provider clearing existing token'
        $user = $token.account
        $userUpn = $token.account.username
        write-verbose "Clearing token for user '$userUpn'"
        $this |=> __RemoveCachedtoken $authContext $user
        $this |=> __RemoveAppContext ($authContext.app |=> IsConfidential) $authContext.app.appId $authContext.GraphEndpointUri $authContext.GroupId
    }

    function __RemoveCachedToken($authContext, $user) {
        $asyncRemoveResult = $authContext.protocolContext.RemoveAsync($user)
        $asyncRemoveResult.Wait()
    }

    function __AcquireTokenInteractive($authContext, $scopes) {
        write-verbose 'V2 auth provider acquiring interactive user token'

        $scopeList = $::.ScopeHelper |=> QualifyScopes $scopes $authContext.GraphEndpointUri
        $authContext.protocolContext.AcquireTokenInteractive([System.Collections.Generic.List[string]] $scopeList).ExecuteAsync()
    }

    function __GetContextKey($appId, $groupId) {
        $key = $appId.tostring()
        if ( $groupId ) {
            $key += ':' + $groupId.tostring()
        }
        $key
    }

    function __AddAppContext([bool] $isConfidential, [Guid] $appId, [Uri] $authUri, $appContext, $groupId) {
        $authorities = if ( $isConfidential ) {
            $this.confidentialAppContexts
        } else {
            $this.publicAppContexts
        }

        if ( ! $authorities[$authUri] ) {
            $authorities[$authUri] = @{}
        }

        $contextKey = __GetContextKey $appId $groupId

        write-verbose "Adding app context with key '$contextKey'"
        $authorities[$authUri].Add($contextKey, $appContext)
    }

    function __GetAppContext([bool] $isConfidential, [Guid] $appId, [Uri] $authUri, $groupId) {
        $authorities = if ( $isConfidential ) {
            $this.confidentialAppContexts
        } else {
            $this.publicAppContexts
        }

        $authority = $authorities[$authUri]

        if ( $authority ) {
            $contextKey = __GetContextKey $appId $groupId
            write-verbose "Looking up app context with key '$contextKey'"
            $authority[$contextKey]
        }
    }

    function __RemoveAppContext([bool] $isConfidential, [Guid] $appId, [Uri] $authUri, $groupId) {
        $authorities = if ( $isConfidential ) {
            $this.confidentialAppContexts
        } else {
            $this.publicAppContexts
        }

        $authority = $authorities[$authUri]

        if ( $authority ) {
            $contextKey = __GetContextKey $appId $groupId
            write-verbose "Attempting to remove app context with contextid '$contextkey'"
            if ( $authority[$contextKey] ) {
                write-verbose "Context key '$contextkey' exists, removing app context for it"
                $authority.Remove($contextKey)
                if ( $authority.count -eq 0 ) {
                    $authorities[$authUri].Remove
                }
            }
        }
    }

    function __GetDefaultScopeList($authContext) {
        $::.ScopeHelper |=> QualifyScopes @($::.ScopeHelper.DefaultScope) $authContext.GraphEndpointUri
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
        $scriptRoot = $null

        function __initialize($scriptRoot) {
            $this.scriptRoot = $scriptRoot
        }

        function InitializeProvider {
            if ( ! $this.__AuthLibraryLoaded ) {

                # This works around the fact that Import-Assembly does not currently look
                # for netcoreapp2.1 libraries by default -- fortunately we can override this
                # to get the desired version
                $targetframeworkParameter = if ( $PSEdition -ne 'Desktop' ) {
                    @{TargetFrameworkMoniker = 'net6.0'}
                } else {
                    # And on desktop it defaults to net45, so now even for desktop we must
                    # explicitly override with the a later version since the auth library
                    # no longer seems to support net45. :(
                    @{TargetFrameworkMoniker = 'net472'}
                }

                $libPath = join-path $this.scriptRoot ../../lib
                Import-Assembly Microsoft.Identity.Client -AssemblyRoot $libPath @targetFrameworkParameter | out-null
                $this.__AuthLibraryLoaded = $true

                # An additional library is required to support authentication broker functionality -- it is supported
                # only on Windows, so is considered optional -- try to load it on that platform.
                $currentOS = [System.Environment]::OSVersion.Platform
                if ( $currentOS -eq 'Win32NT' ) {
                    try {
                        $authBrokerLibrary = 'Microsoft.Identity.Client.Broker'
                        Import-Assembly $authBrokerLibrary -AssemblyRoot $libPath @targetFrameworkParameter | out-null
                    } catch {
                        write-warning "Unable to load authentication broker library '$authBrokerLibrary' from search path $libPath; sign-in will not be able to use the broker functionality."
                    }
                }
            }
        }
    }
}

$::.V2AuthProvider |=> __initialize $psscriptroot
