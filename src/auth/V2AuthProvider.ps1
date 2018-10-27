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
        if ( $app.authtype -eq ([GraphAppAuthType]::AppOnly) ) {

            $credential = New-Object Microsoft.Identity.Client.ClientCredential -ArgumentList ($app.secret |=> GetSecretData)

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

        if ( $token -and $token.User ) {
            $userId = $token.User.DisplayableId
            $scopes = $token.scopes
        }

        [PSCustomObject]@{
            userId = $userId
            scopes = $scopes
        }
    }

    function AcquireFirstUserToken($authContext, $scopes) {
        write-verbose 'V2 auth provider acquiring initial user token'
        if ( $scopes -eq $null -or $scopes.length -eq 0 ) {
            throw [ArgumentException]::new('No scopes specified for v2 auth protocol, at least one scope is required')
        }

        # See comment on __ScopesAsScopeList member to understand strange call syntax here
        $scopeList = $this.__ScopesAsScopeList.InvokeReturnAsIs(@($scopes))

        $authContext.protocolContext.AcquireTokenAsync($scopeList)
    }

    function AcquireFirstAppToken($authContext) {
        write-verbose 'V2 auth provider acquiring initial app token'
        $defaultScopeList = $this.__GetDefaultScopeList.InvokeReturnAsIs(@($authContext))
        $authContext.protocolContext.AcquireTokenForClientAsync($defaultScopeList)
    }

    function AcquireRefreshedToken($authContext, $token) {
        write-verbose 'V2 auth provider refreshing existing token'
        if ( $authContext.app.authtype -eq ([GraphAppAuthType]::AppOnly) ) {
            $defaultScopeList = $this.__GetDefaultScopeList.InvokeReturnAsIs(@($authContext))
            $authContext.protocolContext.AcquireTokenForClientAsync($defaultScopeList)
        } else {
            # See comment on __ScopesAsScopeList member to understand strange call syntax here
            $requestedScopesFromToken = $this.__ScopesAsScopeList.InvokeReturnAsIs(@($token.scopes))
            $authContext.protocolContext.AcquireTokenSilentAsync($requestedScopesFromToken, $token.user)
        }
    }

    function ClearToken($authContext, $token) {
        write-verbose 'V2 auth provider clearing existing token'
        $user = $token.user
        $userUpn = $user.displayableid
        write-verbose "Clearing token for user '$userUpn'"
        $authContext.protocolContext.Remove($user)
    }

    $__GetDefaultScopeList = {
        param($authContext)
        # See comments for $__ScopesAsScopeList as to why this is a script block instead
        # of a function and has a strange return value
        $scopes = new-object System.Collections.Generic.List[string]
        $defaultScope = $authContext.GraphEndpointUri.tostring().trimend(), '.default' -join '/'
        $scopes.Add($defaultScope)

        # This is not a typo -- see $__ScopesAsScopeList member block comments
        return , $scopes
    }

    $__ScopesAsScopeList = {
        param($scopes)
        $scopeList = new-object System.Collections.Generic.List[string]
        $alreadyPresentScopes = @('openid', 'profile', 'offline_access')
        $scopes | where { $alreadyPresentScopes -notcontains $_ } | foreach {
            $scopeList.Add($_)
        }

        # OK, this last line is *strange*. Yes, the syntax with the comma is correct. This
        # is a trick to get PowerShell to not convert this .NET generic List class to an array,
        # or, in the case of a List with one element simply a single object of that element!
        # In our case, the caller *really* wants this to be the List type as it will be
        # passed to a .NET metho, which means the argument is type checked and the call will
        # fail the call if the argument is not the expected .NET type. See the issue below:
        #
        #    https://stackoverflow.com/questions/16121969/function-not-returning-expected-object
        #
        # Additionally, the problem persists if this is a function. And if you make it a script
        # block and call Invoke, it still happens! The only way I've found around this is the following,
        # which also reveals why this is a script block rather than a function :) :
        #
        #   * Make this a script block rather than a function
        #   * Return the value by explicitly using return, and passing the result preceded by ",", i.e. "return , $myresult"
        #   * Invoke it with the InvokeReturnAsIs method instead of Invoke to preserve the actual type of the return value
        #
        # This is a really unfortunate behavior -- I'm surprised I haven't run into it
        # before, but probably only an issue when doing interop with actual .NET code
        # as in our case.

        return , $scopeList
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
