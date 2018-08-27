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
        if ( $app |=> IsConfidential ) {
            throw [NotImplementedExeception]::new("Confidential v1 auth not yet implemented")
        } else {
            New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authUri
        }
    }

    function GetUserInformation($token) {
        $userId = $null
        $scopes = $null

        if ( $this.token ) {
            $userId = $this.token.UserInfo.DisplayableId
            $scopes = $null
        }

        @{
            userId = $userId
            scopes = $scopes
        }
    }

    function AcquireInitialUserToken($authContext, $scopes) {
        write-verbose 'V1 auth provider acquiring initial user token'

        $promptBehaviorValue = ([Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto)
        $promptBehavior = new-object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList $promptBehaviorValue

        $authContext.protocolContext.AcquireTokenAsync(
            $authContext.GraphEndpointUri,
            $authContext.App.AppId,
            $authContext.App.RedirectUri,
            $promptBehavior)
    }

    function AcquireInitialAppToken($authContext, $scopes) {
        write-verbose 'V1 auth provider acquiring initial app token'
        [NotImplementedException]::new("V1 app authentication not yet implemented")
    }

    function AcquireTokenFromToken($authContext, $scopes, $token) {
        write-verbose 'V1 auth provider acquiring token from existing token'
        @{
            Status = 'NoOperation'
            Result = $token
            IsFaulted = $false
        }
    }

    static {
        $__AuthLibraryLoaded = $false
        $__UserTokenCache = $null
        $__AppTokenCache = $null

        function InitializeProvider {
            if ( ! $this.__AuthLibraryLoaded ) {
                import-assembly ../../lib/Microsoft.IdentityModel.Clients.ActiveDirectory.dll
                $this.__AuthLibraryLoaded = $true
            }
        }

        function RegisterProvider {
            $::.AuthProvider |=> RegisterProvider ([GraphAuthProtocol]::v1) $this
        }
    }
}
