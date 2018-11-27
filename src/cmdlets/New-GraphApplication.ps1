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

. (import-script ../graphservice/GraphApplicationRegistration)
. (import-script ../common/GraphApplicationCertificate)

function New-GraphApplication {
    [cmdletbinding(defaultparametersetname='delegated', positionalbinding=$false)]
    param(
        [parameter(position=0, mandatory=$true)]
        [string] $Name,

        [parameter(parametersetname='delegated', position=1)]
        [parameter(parametersetname='apponlynewcert', position=1)]
        [parameter(parametersetname='apponlynocert', position=1)]
        [parameter(parametersetname='apponlyexistingcert', position=1)]

        [string[]] $RedirectUris = $null,

        [parameter(parametersetname='delegated')]
        [parameter(parametersetname='apponlynewcert')]
        [parameter(parametersetname='apponlynocert')]
        [parameter(parametersetname='apponlyexistingcert')]
        [Uri] $InfoUrl,

        [parameter(parametersetname='delegated')]
        [parameter(parametersetname='apponlynewcert')]
        [parameter(parametersetname='apponlynocert')]
        [parameter(parametersetname='apponlyexistingcert')]
        [string[]] $Tags,

        [parameter(parametersetname='delegated')]
        [parameter(parametersetname='apponlynewcert')]
        [parameter(parametersetname='apponlynocert')]
        [parameter(parametersetname='apponlyexistingcert')]
        [AppTenancy] $Tenancy = ([AppTenancy]::AnyTenant),

        [parameter(parametersetname='delegated')]
        [parameter(parametersetname='apponlynewcert')]
        [parameter(parametersetname='apponlynocert')]
        [parameter(parametersetname='apponlyexistingcert')]
        $Scopes,

        [parameter(parametersetname='delegated')]
        [switch] $AADAccountsOnly,

        [parameter(parametersetname='apponlynewcert', mandatory=$true)]
        [parameter(parametersetname='apponlynocert', mandatory=$true)]
        [parameter(parametersetname='apponlyexistingcert', mandatory=$true)]
        [switch] $NoninteractiveAppOnlyAuth,

        [parameter(parametersetname='apponlynocert', mandatory=$true)]
        [switch] $NoCredential,

        [parameter(parametersetname='apponlyexistingcert', mandatory=$true)]
        $ExistingCertStorePath,

        [parameter(parametersetname='apponlynewcert')]
        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='apponlyexistingcert', mandatory=$true)]
        $Certificate,

        [parameter(parametersetname='manifest', mandatory=$true)]
        [string] $Manifest
    )

    $appOnlyPermissions = if ( $NoninteractiveAppOnlyAuth.IsPresent ) { $::.ScopeHelper |=> GetAppOnlyResourceAccessPermissions $Scopes}
    $delegatedPermissions = if ( ! $NoninteractiveAppOnlyAuth.IsPresent ) { $::.ScopeHelper |=> GetDelegatedResourceAccessPermissions $Scopes}

    $newAppRegistration = new-so GraphApplicationRegistration $Name $InfoUrl $Tags $Tenancy $AadAccountsOnly.IsPresent $appOnlyPermissions $delegatedPermissions $NoninteractiveAppOnlyAuth.IsPresent $RedirectUris

    $newApp = $newAppRegistration |=> RegisterNewApp

    if ( $NoninteractiveAppOnlyAuth.IsPresent ) {
        try {
            $certificate = new-so GraphApplicationCertificate $newApp.appId $certStoreLocation
            $certificate |=> Create
            $::.GraphApplicationRegistration |=> AddKeyCredentials $newApp $certificate
        } catch {
            Remove-GraphItem -version $::.GraphApplicationRegistration.DefaultApplicationApiVersion "/applications/$($newApp.Id)" -erroraction silentlycontinue -confirm:$false
            throw
        }
    }

    $newApp
}
