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

. (import-script ../common/GraphApplicationCertificate)
. (import-script ../common/ScopeHelper)
. (import-script ../graphservice/ApplicationAPI)

ScriptClass ApplicationObject {
    $applicationObject = $null
    $ObjectId = $null
    $AppId = $null
    $AppAPI = $null
    $isConfidential = $false

    function __initialize($appAPI, $displayName, $infoUrl, $tags, $tenancy, $aadAccountsOnly, $appOnlyPermissions, $delegatedPermissions, $isConfidential, $redirectUris) {
        $this.AppAPI = $appAPI

        $appParameters = @{
            displayName = $displayName
            infoUrl = $infoUrl
            tags = $tags
            tenancy =$tenancy
            aadAccountsOnly = $aadAccountsOnly
            appOnlyPermissions = $appOnlyPermissions
            delegatedPermissions = $delegatedPermissions
        }

        $newApp = __NewApp @appParameters

        if ( ! $isConfidential ) {
            __SetPublicApp $newApp $redirectUris
        } else {
            __SetConfidentialApp $newApp $redirectUris
        }

        $this.ApplicationObject = $newApp
    }

    function CreateNewApp {
        if ( $this.objectId ) {
            Throw "Application '$($this.Application.displayName)' is already registered with appId '$($this.AppId)' and objectId '$($this.ObjectId)'"
        }

        $appObject = [PSCustomObject] $this.ApplicationObject
        $newApp = $this.AppAPI |=> CreateApp $appObject

        $this.ObjectId = $newApp.id
        $this.AppId = $newApp.appId

        $newApp
    }

    function Register($skipRequiredResourcePermissions, $ConsentRequired, $userIdToConsent, $consentAllUsers, $scopes, $roles) {
        $appSP = $this.AppAPI |=> RegisterApplication $this.AppId

        if ( $ConsentRequired ) {
            $this.AppAPI |=> SetConsent $appSP.appId $scopes $roles (! $skipRequiredResourcePermissions) $userIdToConsent $consentAllUsers $appSP
        }

        $appSP
    }

    function __SetPublicApp($app, $redirectUris) {
        $this.isConfidential = $false
        $publicClientRedirectUris = if ( $redirectUris -ne $null ) {
            $redirectUris
        } else {
            , @('urn:ietf:wg:oauth:2.0:oob')
        }

        $publicClient = [PSCustomObject] @{
            redirectUris = $publicClientRedirectUris
        }

        $app.Add('publicClient', $publicClient)
    }

    function __SetConfidentialApp($app, $redirectUris) {
        $this.isConfidential = $true
        $appRedirectUris = if ( $redirectUris ) {
            $redirectUris
        } else {
            , @('http://localhost', 'urn:ietf:wg:oauth:2.0:oob')
        }

        $web = @{
            redirectUris = $appRedirectUris
        }

        $app.Add('web', $web)
    }

    function __NewApp($displayName, $infoUrl, $tags, $tenancy, $aadAccountsOnly, $appOnlyPermissions, $delegatedPermissions) {
        $signInAudience = if ( $tenancy -eq ([AppTenancy]::SingleTenant) ) {
            'AzureADMyOrg'
        } elseif ( $aadAccountsOnly ) {
            'AzureADMultipleOrgs'
        } else {
            'AzureADAndPersonalMicrosoftAccount'
        }

        $resourceAccess = @()

        $hasScope = $false

        if ( $appOnlyPermissions ) { $appOnlyPermissions | foreach { $accessEntry = @{id=$_.id;type=$_.type}; $resourceAccess += $accessEntry } }
        if ( $delegatedPermissions ) { $delegatedPermissions | foreach { $hasScope = $true; $accessEntry = @{id=$_.id;type=$_.type}; $resourceAccess += $accessEntry } }

        # Add in default required resource access of offline_access if there are no
        # required delegated permission scopes specified. If resource access for scopes
        # is completely absent, the STS behavior is to behave as if the app is not registered at the time
        # a token is requested for the app
        if ( ! $hasScope ) {
            $resourceAccess += @{
                id = $::.ScopeHelper.OfflineAccessScopeId
                type = 'Scope'
            }
        }

        $app = @{
            displayName = $displayName
            signinAudience = $signInAudience
            requiredResourceAccess = @(
                @{
                    resourceAppId = $::.ScopeHelper.GraphApplicationId
                    resourceAccess = $resourceAccess
                }
            )
        }

        if ( $infoUrl ) { $app.Add('infoUrl', $infoUrl) }
        if ( $tags ) { $app.Add('tags', $tags) }

        $app
    }
}
