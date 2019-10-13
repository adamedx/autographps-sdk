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

function Set-GraphApplicationConsent {
    [cmdletbinding(defaultparametersetname='simple', positionalbinding = $false)]
    param(
        [parameter(position=0, parametersetname='simple', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='explicitscopes', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='allconfiguredpermissions', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid[]] $AppId,

        [parameter(parametersetname='explicitscopes')]
        [string[]] $DelegatedUserPermissions,

        [parameter(parametersetname='explicitscopes')]
        [string[]] $ApplicationPermissions,

        [parameter(parametersetname='allconfiguredpermissions', mandatory=$true)]
        [switch] $AllPermissions,

        [switch] $ConsentAllUsers,

        $UserIdToConsent,

        $Connection,

        $Version
    )

    begin {}

    process {
        Enable-ScriptClassVerbosePreference

        $commandContext = new-so CommandContext $Connection $Version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

        $app = $appAPI |=> GetApplicationByAppId $AppId

        $appAPI |=> SetConsent $app.appid $DelegatedUserPermissions $ApplicationPermissions $AllPermissions.IsPresent $UserIdToConsent $ConsentAllUsers.IsPresent $app
    }

    end {}
}

$::.ParameterCompleter |=> RegisterParameterCompleter Set-GraphApplicationConsent DelegatedUserPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter Set-GraphApplicationConsent ApplicationPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))

