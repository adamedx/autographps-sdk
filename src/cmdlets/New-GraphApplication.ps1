# Copyright 2020, Adam Edwards
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

        [String[]] $DelegatedUserPermissions,

        [String[]] $ApplicationPermissions,

        [parameter(parametersetname='confidentialapp', mandatory=$true)]
        [parameter(parametersetname='confidentialappexistingcertpath', mandatory=$true)]
        [parameter(parametersetname='confidentialappnewcertexport', mandatory=$true)]
        [parameter(parametersetname='confidentialappexistingcert', mandatory=$true)]
        [switch] $Confidential,

        [parameter(parametersetname='publicapp')]
        [switch] $AllowMSAAccounts,

        [parameter(parametersetname='confidentialapp')]
        [switch] $NoCredential,

        [switch] $ConsentForAllUsers,

        [switch] $NoConsent,

        [switch] $SkipTenantRegistration,

        [switch] $SkipPermissionNameCheck,

        [parameter(parametersetname='confidentialappexistingcertpath', mandatory=$true)]
        $ExistingCertStorePath,

        [parameter(parametersetname='confidentialappnewcert')]
        [parameter(parametersetname='confidentialappnewcertexport')]
        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='confidentialappexistingcert', mandatory=$true)]
        $Certificate,

        [parameter(parametersetname='confidentialappnewcert')]
        [parameter(parametersetname='confidentialappnewcertexport')]
        [TimeSpan] $CertValidityTimeSpan,

        [parameter(parametersetname='confidentialappnewcert')]
        [parameter(parametersetname='confidentialappnewcertexport')]
        [DateTime] $CertValidityStart,

        [parameter(parametersetname='confidentialappnewcertexport', mandatory=$true)]
        [string] $CertOutputDirectory,

        [parameter(parametersetname='confidentialappnewcertexport')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='confidentialappnewcertexport')]
        [switch] $NoCertCredential,

        [string] $UserIdToConsent,

        [String] $Version = $null,

        [PSCustomObject] $Connection = $null
    )
    Enable-ScriptClassVerbosePreference

    $exportedCertCredential = if ( $CertOutputDirectory ) {
        if (! (test-path -pathtype container $CertOutputDirectory) ) {
            throw [ArgumentException]::new("The CertOutputDirectory parameter value '$CertOutputDirectory' is not a valid directory")
        }

        if ( $CertCredential ) {
            $CertCredential
        } elseif ( ! $NoCertCredential.IsPresent ) {
            $userName = if ( $env:user ) { $env:user } else { $env:username }
            Get-Credential -username $userName -Message "Enter password for certificate to be stored in output directory '$CertOutputDirectory'"
        }
    }

    if ( $SkipTenantRegistration.IsPresent ) {
        if ( $UserIdToConsent -or $ConsentForAllUsers.IsPresent ) {
            throw [ArgumentException]::new("'SkipTenantRegistration' may not be specified if 'UserIdToConsent' or 'ConsentForAllUsers' is specified")
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
        [AppTenancy]::SingleTenant
    }

    $appAPI = new-so ApplicationAPI $commandContext.Connection $commandContext.Version

    $newAppRegistration = new-so ApplicationObject $appAPI $Name $InfoUrl $Tags $computedTenancy ( ! $AllowMSAAccounts.IsPresent ) $appOnlyPermissions $delegatedPermissions $Confidential.IsPresent $RedirectUris

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
            $certpassword = if ( $exportedCertCredential ) {
                $exportedCertCredential.Password
            }

            $certificate |=> Export $CertOutputDirectory $certPassword
        }
    }

    if ( ! $SkipTenantRegistration.IsPresent ) {
        $newAppRegistration |=> Register $true (! $NoConsent.IsPresent) $UserIdToConsent $ConsentForAllUsers.IsPresent $DelegatedUserPermissions $ApplicationPermissions | out-null
    }

    $newApp
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication DelegatedUserPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication ApplicationPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))

