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

. (import-script ../cmdlets/Invoke-GraphRequest)
. (import-script ../common/GraphApplicationCertificate)

enum AppTenancy {
    SingleTenant
    AnyTenant
}

ScriptClass GraphApplicationRegistration {
    static {
        const DefaultApplicationApiVersion beta

        function AddKeyCredentials($appObject, $appCertificate) {
            $keyCredentials = if ( ($appObject | gm keyCredentials) -and $appObject.keyCredentials ) {
                $appObject.keyCredentials
            } else {
                (, @())
            }

            $encodedCertificate = $appCertificate |=> GetEncodedPublicCertificate

            $keyCredentials += [PSCustomObject] @{
                type = 'AsymmetricX509Cert'
                usage = 'Verify'
                key = $encodedCertificate
            }

            $appPatch = (
                [PSCustomObject] @{
                    keyCredentials = $keyCredentials
                }
            ) | convertto-json -depth 20

            Invoke-GraphRequest "applications/$($appObject.Id)" -method PATCH -Body $appPatch -version $this.DefaultApplicationApiVersion | out-null
        }
    }

    $applicationObject = $null
    $ObjectId = $null
    $AppId = $null

    function __initialize($displayName, $infoUrl, $tags, $tenancy, $aadAccountsOnly, $appOnlyPermissions, $delegatedPermissions, $isAppOnly, $redirectUris) {
        $newApp = __NewAppRegistration @psboundparameters

        if ( ! $isAppOnly ) {
            __SetPublicApp $newApp $redirectUris
        } else {
            __SetConfidentialApp $newApp $redirectUris
        }

        $this.ApplicationObject = $newApp
    }

    function RegisterNewApp {
        if ( $this.objectId ) {
            Throw "Application '$displayName' is already registered with appId '$($this.AppId)' and objectId '$($this.ObjectId)'"
        }

        $appBody = [PSCustomObject] $this.ApplicationObject
        $appObject = Invoke-GraphRequest applications -method POST -body $appBody -version $this.scriptclass.DefaultApplicationApiVersion
        $this.ObjectId = $appObject.id
        $this.AppId = $appObject.appId

        $appObject
    }

    function __SetPublicApp($app, $redirectUris) {
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
        $appRedirectUris = if ( $redirectUris ) {
            $redirectUris
        } else {
            , @('http://localhost')
        }

        $web = @{
            redirectUris = $appRedirectUris
        }

        $app.Add('web', $web)
    }

    function __NewAppRegistration($displayName, $infoUrl, $tags, $tenancy, $aadAccountsOnly, $appOnlyPermissions, $delegatedPermissions) {
        $signInAudience = if ( $tenancy -eq ([AppTenancy]::SingleTenant) ) {
            'AzureADMyOrg'
        } elseif ( $aadAccountsOnly ) {
            'AzureADMultipleOrgs'
        } else {
            'AzureADAndPersonalMicrosoftAccount'
        }

        $resourceAccess = @()
        if ( $appOnlyPermissions ) { $appOnlyPermissions | foreach { $resourceAccess += $_ } }
        if ( $delegatedPermissions ) { $delegatedPermissions | foreach { $resourceAccess += $_ } }

        $app = @{
            displayName = $displayName
            signinAudience = $signInAudience
            requiredResourceAccess = @(
                @{
                    resourceAppId = '00000003-0000-0000-c000-000000000000'
                    resourceAccess = $resourceAccess
                }
            )
        }

        if ( $infoUrl ) { $app.Add('infoUrl', $infoUrl) }
        if ( $tags ) { $app.Add('tags', $tags) }

        $app
    }
}
