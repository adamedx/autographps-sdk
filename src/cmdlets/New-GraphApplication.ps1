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

. (import-script ../graphservice/ApplicationAPI)
. (import-script ../graphservice/ApplicationObject)
. (import-script ../common/GraphApplicationCertificate)
. (import-script common/PermissionParameterCompleter)
. (import-script common/CommandContext)

function New-GraphApplication {
    [cmdletbinding(defaultparametersetname='publicapp', positionalbinding=$false)]
    param(
        [parameter(position=0, mandatory=$true)]
        [string] $Name,

        [string[]] $RedirectUris = $null,

        [Uri] $InfoUrl,

        [string[]] $Tags,

        [AppTenancy] $Tenancy = ([AppTenancy]::Auto),

        [parameter(parametersetname='publicapp')]
        [String[]] $DelegatedUserPermissions,

        [parameter(parametersetname='confidentialapp', mandatory=$true)]
        [String[]] $ApplicationPermissions,

        [parameter(parametersetname='confidentialapp', mandatory=$true)]
        [parameter(parametersetname='confidentialappexistingcertpath', mandatory=$true)]
        [parameter(parametersetname='confidentialappnewcert', mandatory=$true)]
        [parameter(parametersetname='confidentialappexistingcert', mandatory=$true)]
        [switch] $Confidential,

        [parameter(parametersetname='publicapp')]
        [switch] $AADAccountsOnly,

        [parameter(parametersetname='confidentialapp')]
        [parameter(parametersetname='confidentialappexistingcertpath')]
        [parameter(parametersetname='confidentialappnewcert')]
        [parameter(parametersetname='confidentialappexistingcert')]
        [switch] $NoCredential,

        [switch] $ConsentAllUsers,

        [switch] $NoConsent,

        [switch] $SkipTenantRegistration,

        [switch] $SkipPermissionNameCheck,

        [parameter(parametersetname='confidentialappexistingcertpath', mandatory=$true)]
        $ExistingCertStorePath,

        [parameter(parametersetname='confidentialappnewcert')]
        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='confidentialappexistingcert', mandatory=$true)]
        $Certificate,

        [parameter(parametersetname='confidentialappnewcert')]
        [TimeSpan] $CertValidityTimeSpan,

        [parameter(parametersetname='confidentialappnewcert')]
        [DateTime] $CertValidityStart,

        [parameter(parametersetname='confidentialappnewcert')]
        [string] $CertOutputDirectory,

        [string] $UserIdToConsent,

        [String] $Version = $null,

        [PSCustomObject] $Connection = $null
    )
    Enable-ScriptClassVerbosePreference

    if ( $CertOutputDirectory -and ! (test-path -pathtype container $CertOutputDirectory) ) {
        throw [ArgumentException]::new("The CertOutputDirectory parameter value '$CertOutputDirectory' is not a valid directory")
    }

    if ( $SkipTenantRegistration.IsPresent ) {
        if ( $UserIdToConsent -or $ConsentAllUsers.IsPresent ) {
            throw [ArgumentException]::new("'SkipTenantRegistration' may not be specified if 'UserIdToConsent' or 'ConsentAllUsers' is specified")
        }
    }
    $commandContext = new-so CommandContext $Connection $Version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

    $::.ScopeHelper |=> ValidatePermissions $ApplicationPermissions $true $SkipPermissionNameCheck.IsPresent $commandContext.connection
    $::.ScopeHelper |=> ValidatePermissions $DelegatedUserPermissions $false $SkipPermissionNameCheck.IsPresent $commandContext.connection

    $appOnlyPermissions = $::.ScopeHelper |=> GetAppOnlyResourceAccessPermissions $ApplicationPermissions $commandContext.Connection
    $delegatedPermissions = $::.ScopeHelper |=> GetDelegatedResourceAccessPermissions $DelegatedUserPermissions $commandContext.Connection

    $computedTenancy = if ( $Tenancy -ne ([AppTenancy]::Auto) ) {
        $Tenancy
    } else {
        if( $Confidential.IsPresent ) {
            [AppTenancy]::SingleTenant
        } else {
            [AppTenancy]::AnyTenant
        }
    }

    $appAPI = new-so ApplicationAPI $commandContext.Connection $commandContext.Version

    $newAppRegistration = new-so ApplicationObject $appAPI $Name $InfoUrl $Tags $computedTenancy $AadAccountsOnly.IsPresent $appOnlyPermissions $delegatedPermissions $Confidential.IsPresent $RedirectUris

    $newApp = $newAppRegistration |=> CreateNewApp

    if ( $Confidential.IsPresent -and ! $NoCredential.IsPresent ) {
        $certificate = $null
        try {
            $certificate = new-so GraphApplicationCertificate $newApp.appId $newApp.Id $Name $CertValidityTimeSpan $CertValidityStart $certStoreLocation
            $certificate |=> Create
            $appAPI |=> AddKeyCredentials $newApp $certificate | out-null
        } catch {
            $::.GraphApplicationCertificate |=> FindAppCertificate $newApp.appId | remove-item -erroraction ignore
            $appAPI |=> RemoveApplicationByObjectId $newApp.Id ignore
            throw
        }

        if ( $CertOutputDirectory ) {
            $certificate |=> Export $CertOutputDirectory
        }
    }

    if ( ! $SkipTenantRegistration.IsPresent ) {
        $delegatedPermissionsToConsent = if ( ! $Confidential.IsPresent -and ! $ApplicationPermissions -and ! $DelegatedUserPermissions ) {
            # If at least one delegated permission is not consented, it seems the STS will not grant access when
            # a request is made for the token, so for apps we know to be accessed only as public client apps we
            # consent to offline_access
            write-verbose "No delegated permissions specified for public application, will add 'offline_access' for consent"
            @('offline_access')
            $DelegatedUserPermissions
        } else {
            $DelegatedUserPermissions
        }
        $newAppRegistration |=> Register $true (! $NoConsent.IsPresent) $ConsentAllUsers.IsPresent $UserIdToConsent $delegatedPermissionsToConsent $ApplicationPermissions | out-null
    }

    $newApp
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication DelegatedUserPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication ApplicationPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))

