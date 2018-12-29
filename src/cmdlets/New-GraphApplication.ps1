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

. (import-script ../graphservice/ApplicationAPI)
. (import-script ../graphservice/GraphApplicationRegistration)
. (import-script ../common/GraphApplicationCertificate)
. (import-script common/PermissionParameterCompleter)
. (import-script common/CommandContext)

function New-GraphApplication {
    [cmdletbinding(defaultparametersetname='delegated', positionalbinding=$false)]
    param(
        [parameter(position=0, mandatory=$true)]
        [string] $Name,

        [parameter(parametersetname='delegated', position=1)]
        [parameter(parametersetname='apponlynewcert', position=1)]
        [parameter(parametersetname='apponlynocred', position=1)]
        [parameter(parametersetname='apponlyexistingcert', position=1)]
        [string[]] $RedirectUris = $null,

        [parameter(parametersetname='delegated')]
        [parameter(parametersetname='apponlynewcert')]
        [parameter(parametersetname='apponlynocred')]
        [parameter(parametersetname='apponlyexistingcert')]
        [Uri] $InfoUrl,

        [parameter(parametersetname='delegated')]
        [parameter(parametersetname='apponlynewcert')]
        [parameter(parametersetname='apponlynocred')]
        [parameter(parametersetname='apponlyexistingcert')]
        [string[]] $Tags,

        [parameter(parametersetname='delegated')]
        [parameter(parametersetname='apponlynewcert')]
        [parameter(parametersetname='apponlynocred')]
        [parameter(parametersetname='apponlyexistingcert')]
        [AppTenancy] $Tenancy = ([AppTenancy]::Auto),

        [parameter(parametersetname='delegated')]
        [parameter(parametersetname='apponlynewcert')]
        [parameter(parametersetname='apponlynocred')]
        [parameter(parametersetname='apponlyexistingcert')]
        [String[]] $GrantedPermissions,

        [parameter(parametersetname='delegated')]
        [switch] $AADAccountsOnly,

        [parameter(parametersetname='apponlynocred', mandatory=$true)]
        [switch] $NoCredential,

        [switch] $SkipTenantRegistration,

        [switch] $SkipPermissionNameCheck,

        [parameter(parametersetname='apponlynewcert', mandatory=$true)]
        [parameter(parametersetname='apponlynocred', mandatory=$true)]
        [parameter(parametersetname='apponlyexistingcert', mandatory=$true)]
        [switch] $NoninteractiveAppOnlyAuth,

        [parameter(parametersetname='apponlyexistingcert', mandatory=$true)]
        $ExistingCertStorePath,

        [parameter(parametersetname='apponlynewcert')]
        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='apponlyexistingcert', mandatory=$true)]
        $Certificate,

        [switch] $ConsentForTenant,

        [parameter(parametersetname='delegated')]
        [string] $UserIdToConsent,

        [parameter(parametersetname='manifest', mandatory=$true)]
        [string] $Manifest,

        [String] $Version = $null,

        [parameter(parametersetname='ExistingConnection', mandatory=$true)]
        [PSCustomObject] $Connection = $null
    )

    if ( $SkipTenantRegistration.IsPresent ) {
        if ( $UserIdToConsent -or $ConsentForTenant.IsPresent ) {
            throw [ArgumentException]::new("'SkipTenantRegistration' may not be specified if 'UserIdToConsent' or 'ConsentForTenant' is specified")
        }
    }
    $commandContext = new-so CommandContext $Connection $Version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

    $::.ScopeHelper |=> ValidatePermissions $GrantedPermissions $NoninteractiveAppOnlyAuth.IsPresent $SkipPermissionNameCheck.IsPresent $commandContext.connection

    $appOnlyPermissions = if ( $NoninteractiveAppOnlyAuth.IsPresent ) { $::.ScopeHelper |=> GetAppOnlyResourceAccessPermissions $GrantedPermissions $commandContext.Connection }
    $delegatedPermissions = if ( ! $NoninteractiveAppOnlyAuth.IsPresent ) { $::.ScopeHelper |=> GetDelegatedResourceAccessPermissions $GrantedPermissions $commandContext.Connection }

    $computedTenancy = if ( $Tenancy -ne ([AppTenancy]::Auto) ) {
        $Tenancy
    } else {
        if( $NoninteractiveAppOnlyAuth.IsPresent ) {
            [AppTenancy]::SingleTenant
        } else {
            [AppTenancy]::AnyTenant
        }
    }

    $appAPI = new-so ApplicationAPI $commandContext.Connection $commandContext.Version

    $newAppRegistration = new-so GraphApplicationRegistration $appAPI $Name $InfoUrl $Tags $computedTenancy $AadAccountsOnly.IsPresent $appOnlyPermissions $delegatedPermissions $NoninteractiveAppOnlyAuth.IsPresent $RedirectUris

    $newApp = $newAppRegistration |=> CreateNewApp

    if ( $NoninteractiveAppOnlyAuth.IsPresent -and ! $NoCredential.IsPresent ) {
        try {
            $certificate = new-so GraphApplicationCertificate $newApp.appId $newApp.Id $Name $certStoreLocation
            $certificate |=> Create
            $appAPI |=> AddKeyCredentials $newApp $certificate | out-null
        } catch {
            $::.GraphApplicationCertificate |=> FindAppCertificate $newApp.appId | rm -erroraction ignore
            $appAPI |=> RemoveApplicationByObjectId $newApp.Id ignore
            throw
        }
    }

    if ( ! $SkipTenantRegistration.IsPresent ) {
        $newAppRegistration |=> Register $ConsentForTenant.IsPresent $NonInteractiveAppOnlyAuth.IsPresent ($UserIdToConsent -ne $null) $UserIdToConsent $GrantedPermissions | out-null
        if ( $GrantedPermissions -and $NoninteractiveAppOnlyAuth.IsPresent ) {
            write-warning "The application was successfully created, but consent for the application in the tenant could not be granted because the consent API is not yet fully implemented. Please visit the Azure Portal at`n`n    https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredAppsPreview`n`nto manually configure consent for the application. Choose the application '$($newApp.displayname)' with application id '$($newApp.AppId)' and then access API Permissions to grant consent to the application in the tenant."
        }
    }

    $newApp
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication GrantedPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))

