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
. (import-script common/PermissionParameterCompleter)
. (import-script common/CommandContext)

function Register-GraphApplication {
    [cmdletbinding(defaultparametersetname='delegated', positionalbinding=$false)]
    param(
        [parameter(position=0, mandatory=$true)]
        [string] $AppId,

        [String[]] $GrantedPermissions,

        [switch] $SkipPermissionNameCheck,

        [switch] $NoninteractiveAppOnlyAuth,

        [switch] $ImportFromOtherTenant,

        [switch] $ConsentForTenant,

        [parameter(parametersetname='delegated')]
        [string] $ConsentForPrincipal,

        [String] $Version = $null,

        [parameter(parametersetname='ExistingConnection', mandatory=$true)]
        [PSCustomObject] $Connection = $null
    )
    Enable-ScriptClassVerbosePreference

    $commandContext = new-so CommandContext $Connection $Version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

    $::.ScopeHelper |=> ValidatePermissions $GrantedPermissions $NoninteractiveAppOnlyAuth.IsPresent $SkipPermissionNameCheck.IsPresent $commandContext.connection

    $appOnlyPermissions = if ( $NoninteractiveAppOnlyAuth.IsPresent -and $GrantedPermissions ) { $::.ScopeHelper |=> GetAppOnlyResourceAccessPermissions $GrantedPermissions $commandContext.Connection }
    $delegatedPermissions = if ( ! $NoninteractiveAppOnlyAuth.IsPresent -and $GrantedPermissions ) { $::.ScopeHelper |=> GetDelegatedResourceAccessPermissions $GrantedPermissions $commandContext.Connection }

    $appOnlyPermissionIds = if ( $appOnlyPermissions ) { $appOnlyPermissions.id }
    $delegatedPermissionIds = if ( $delegatedPermissions ) { $delegatedPermissions.id }

    $appAPI = new-so ApplicationAPI $commandContext.Connection $commandContext.Version

    $newAppSP = $appAPI |=> RegisterApplication $AppId $ImportFromOtherTenant.IsPresent

    $appAPI |=> SetConsent $appId $delegatedPermissionIds $appOnlyPermissionIds $false $ConsentForTenant.IsPresent ($ConsentForPrincipal -ne $null) $ConsentForPrincipal $null $newAppSP | out-null

    $newAppSP
}

$::.ParameterCompleter |=> RegisterParameterCompleter Register-GraphApplication GrantedPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))

