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

. (import-script ../graphservice/ApplicationAPI)
. (import-script ../graphservice/ApplicationObject)
. (import-script ../common/GraphApplicationCertificate)
. (import-script common/PermissionParameterCompleter)
. (import-script common/CommandContext)

function New-GraphApplication {
    [cmdletbinding(defaultparametersetname='publicapp', positionalbinding=$false)]
    [OutputType('AutoGraph.Application')]
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
        [parameter(parametersetname='confidentialappnewcert', mandatory=$true)]
        [parameter(parametersetname='confidentialappnewcertexport', mandatory=$true)]
        [parameter(parametersetname='confidentialappexistingcert', mandatory=$true)]
        [switch] $Confidential,

        [parameter(parametersetname='publicapp')]
        [switch] $AllowMSAAccounts,

        [parameter(parametersetname='confidentialappnewcert', mandatory=$true)]
        [parameter(parametersetname='confidentialappnewcertexport', mandatory=$true)]
        [switch] $NewCredential,

        [parameter(parametersetname='confidentialapp')]
        [switch] $SuppressCredentialWarning,

        [switch] $ConsentForAllUsers,

        [switch] $NoConsent,

        [switch] $SkipTenantRegistration,

        [switch] $SkipPermissionNameCheck,

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

    if ( $SkipTenantRegistration.IsPresent ) {
        if ( $UserIdToConsent -or $ConsentForAllUsers.IsPresent ) {
            throw [ArgumentException]::new("'SkipTenantRegistration' may not be specified if 'UserIdToConsent' or 'ConsentForAllUsers' is specified")
        }
    }

    if ( $NewCredential.IsPresent ) {
        $::.LocalCertificate |=> ValidateCertificateCreationCapability
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

    if ( $Confidential.IsPresent ) {
        if ( $NewCredential.IsPresent ) {
            $newCertificateParameters = @{
                AppId = $newApp.appId
                ObjectId = $newApp.Id
            }

            'CertCredential', 'CertValidityTimeSpan', 'CertValidityStart', 'CertStoreLocation', 'CertOutputDirectory', 'NoCertCredential' | foreach {
                $parameterValue = $PSBoundParameters[$_]
                if ( $parameterValue -ne $null ) {
                    $newCertificateParameters.Add($_, $parameterValue)
                }
            }

            $certificate = try {
                New-GraphApplicationCertificate @newCertificateParameters
            } catch {
                $::.GraphApplicationCertificate |=> FindAppCertificate $newApp.appId | remove-item -erroraction ignore
                $appAPI |=> RemoveApplicationByObjectId $newApp.Id ignore
                throw
            }
        } elseif ( ! $SuppressCredentialWarning.IsPresent ) {
            write-warning "The 'NewCredential' parameter was not specified to the New-GraphApplication command, so this Confidential application cannot sign in until you use issue a subsequent command such as New-GraphApplicationCertificate, Set-GraphApplicationCertificate, or some other method of configuring this application's sign in credential. You can use the 'SuppressCredentialWarning' parameter of New-GraphApplication to silence this warning message."
        }
    }

    if ( ! $SkipTenantRegistration.IsPresent ) {
        $newAppRegistration |=> Register $true (! $NoConsent.IsPresent) $UserIdToConsent $ConsentForAllUsers.IsPresent $DelegatedUserPermissions $ApplicationPermissions | out-null
    }

    $::.ApplicationHelper |=> ToDisplayableObject $newApp
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication DelegatedUserPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication ApplicationPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))

