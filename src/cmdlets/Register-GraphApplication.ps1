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
. (import-script common/PermissionParameterCompleter)
. (import-script common/CommandContext)

function Register-GraphApplication {
    [cmdletbinding(defaultparametersetname='simple', positionalbinding = $false)]
    param(
        [parameter(position=0, parametersetname='simple', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='explicitscopes', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='consentall', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [string] $AppId,

        [parameter(parametersetname='explicitscopes')]
        [string[]] $DelegatedUserPermissions,

        [parameter(parametersetname='explicitscopes')]
        [string[]] $ApplicationPermissions,

        [parameter(parametersetname='explicitscopes')]
        [switch] $SkipPermissionNameCheck,

        [switch] $ImportFromOtherTenant,

        [parameter(parametersetname='consentall', mandatory=$true)]
        [switch] $AllPermissions,

        [parameter(parametersetname='explicitscopes')]
        [parameter(parametersetname='consentall')]
        [switch] $ConsentForAllPrincipals,

        [parameter(parametersetname='explicitscopes')]
        [parameter(parametersetname='consentall')]
        [string] $ConsentedPrincipalId,

        [String] $Version = $null,

        [PSCustomObject] $Connection = $null
    )
    Enable-ScriptClassVerbosePreference

    $commandContext = new-so CommandContext $Connection $Version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

    if ( $ApplicationPermissions ) {
        $::.ScopeHelper |=> ValidatePermissions $ApplicationPermissions $true $SkipPermissionNameCheck.IsPresent $commandContext.connection
    }

    if ( $DelegatedUserPermissions ) {
        $::.ScopeHelper |=> ValidatePermissions $DelegatedUserPermissions $false $SkipPermissionNameCheck.IsPresent $commandContext.connection
    }

    $appAPI = new-so ApplicationAPI $commandContext.Connection $commandContext.Version

    $newAppSP = $appAPI |=> RegisterApplication $AppId $ImportFromOtherTenant.IsPresent

    $appAPI |=> SetConsent $appid $DelegatedUserPermissions $ApplicationPermissions $AllPermissions.IsPresent $ConsentedPrincipalId $ConsentForAllPrincipals.IsPresent $newAppSP.Id

    $newAppSP
}

$::.ParameterCompleter |=> RegisterParameterCompleter Register-GraphApplication DelegatedUserPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter Register-GraphApplication ApplicationPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))

