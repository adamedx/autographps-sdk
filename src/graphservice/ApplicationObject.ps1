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

. (import-script ../client/Application)
. (import-script ../common/GraphApplicationCertificate)
. (import-script ../common/ScopeHelper)
. (import-script ../graphservice/ApplicationAPI)

ScriptClass ApplicationObject {
    $applicationObject = $null
    $ObjectId = $null
    $AppId = $null
    $AppAPI = $null
    $isConfidential = $false
    $Description = $null
    $requiresBrokerRedirectUri = $false

    static {
        const CommonNativeClientRedirectUri 'https://login.microsoftonline.com/common/oauth2/nativeclient'
    }

    function __initialize($appAPI, $displayName, $infoUrl, $tags, $tenancy, $aadAccountsOnly, $appOnlyPermissions, $delegatedPermissions, $isConfidential, $redirectUris, [HashTable] $additionalProperties, [bool] $includeBrokerRedirectUri = $false) {
        $this.AppAPI = $appAPI

        # Be careful using comparison operators with $null: '$redirectUris -ne $null' doesn't return a boolean, it returns LHS! :(
        # To work around, use '$null -eq $redirectUris', or just use [object]::equals() :)
        # This error is also identified by the PSScriptAnalyzer tool.
        # See https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/possibleincorrectcomparisonwithnull?view=ps-modules
        $this.requiresBrokerRedirectUri = $includeBrokerRedirectUri -or [object]::equals($redirectUris, $null)

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

        if ( $additionalProperties ) {
            foreach ( $propertyName in $additionalProperties.Keys ) {
                $newApp.Add($propertyName, $additionalProperties[$propertyName])
            }
        }

        if ( ! $isConfidential ) {
            __SetPublicApp $newApp $redirectUris
        } else {
            __SetConfidentialApp $newApp $redirectUris
        }

        $this.ApplicationObject = $newApp
    }

    function CreateNewApp {
        if ( $this.objectId ) {
            throw "Application '$($this.Application.displayName)' is already registered with appId '$($this.AppId)' and objectId '$($this.ObjectId)'"
        }

        $appObject = [PSCustomObject] $this.ApplicationObject
        $newApp = $this.AppAPI |=> CreateApp $appObject

        $updatedApp = $this.AppAPI |=> UpdateApplicationSelfReferencingState $newApp $this.requiresBrokerRedirectUri

        $this.ObjectId = $updatedApp.id
        $this.AppId = $updatedApp.appId

        $updatedApp
    }

    function Register($skipRequiredResourcePermissions, $ConsentRequired, $userIdToConsent, $consentAllUsers, $scopes, $roles) {
        $appSP = $this.AppAPI |=> RegisterApplication $this.AppId

        if ( $ConsentRequired ) {
            $this.AppAPI |=> SetConsent $appSP.appId $scopes $roles (! $skipRequiredResourcePermissions) $userIdToConsent $consentAllUsers $appSP.Id
        }

        $appSP
    }

    function __SetPublicApp($app, $redirectUris) {
        $this.isConfidential = $false
        $publicClientRedirectUris = $this.scriptclass.CommonNativeClientRedirectUri, $::.Application.DefaultRedirectUri

        # A weird thing -- did you know that '$null -eq ( if ($true) { @() } )' is true? So
        # we can't just assign to the result of an if when we want @() to stay @(). :(
        if ( $null -ne $redirectUris ) {
            $publicClientRedirectUris = $redirectUris
        }

        $publicClient = [PSCustomObject] @{
            redirectUris = $publicClientRedirectUris
        }

        $app.Add('publicClient', $publicClient)
    }

    function __SetConfidentialApp($app, $redirectUris) {
        $this.isConfidential = $true
        $appRedirectUris = , $::.Application.DefaultRedirectUri

        if ( $null -ne $redirectUris ) {
            $appRedirectUris = $redirectUris
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
