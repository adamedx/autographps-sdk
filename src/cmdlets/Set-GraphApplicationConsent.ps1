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
. (import-script common/PermissionParameterCompleter)
. (import-script common/CommandContext)

function Set-GraphApplicationConsent {
    [cmdletbinding(defaultparametersetname='simple', positionalbinding = $false)]
    param(
        [parameter(position=0, parametersetname='simple', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='explicitscopes', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='explicitscopesandexistingconnection', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='explicitscopesnewconnection', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='explicitscopesnewconnectioncloud', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='allconfiguredpermissions', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='allconfiguredpermissionsexistingconnection', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='allconfiguredpermissionsnewconnection', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='allconfiguredpermissionsnewconnectioncloud', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='explicitscopes')]
        [parameter(parametersetname='explicitscopesexistingconnection')]
        [parameter(parametersetname='explicitscopesnewconnection')]
        [parameter(parametersetname='explicitscopesnewconnectioncloud')]
        [string[]] $DelegatedPermissions,

        [parameter(parametersetname='explicitscopes')]
        [parameter(parametersetname='explicitscopesexistingconnection')]
        [parameter(parametersetname='explicitscopesnewconnection')]
        [parameter(parametersetname='explicitscopesnewconnectioncloud')]
        [string[]] $AppOnlyPermissions,

        [parameter(parametersetname='allconfiguredpermissions', mandatory=$true)]
        [parameter(parametersetname='allconfiguredpermissionsexistingconnection', mandatory=$true)]
        [parameter(parametersetname='allconfiguredpermissionsnewconnection', mandatory=$true)]
        [parameter(parametersetname='allconfiguredpermissionsnewconnectioncloud', mandatory=$true)]
        [switch] $AllPermissions,

        [switch] $ConsentForTenant,

        $UserIdToConsent,

        [parameter(parametersetname='allconfiguredpermissionsexistingconnection', mandatory=$true)]
        [parameter(parametersetname='explicitscopesexistingconnection', mandatory=$true)]
        $Connection,

        [parameter(parametersetname='allconfiguredpermissionsnewconnection', mandatory=$true)]
        [parameter(parametersetname='explicitscopesnewconnection', mandatory=$true)]
        [parameter(parametersetname='allconfiguredpermissionsnewconnectioncloud')]
        [parameter(parametersetname='explicitscopesnewconnectioncloud')]
        $Permissions,

        [parameter(parametersetname='allconfiguredpermissionsnewconnection')]
        [parameter(parametersetname='allconfiguredpermissionsnewconnectioncloud', mandatory=$true)]
        [parameter(parametersetname='explicitscopesnewconnection')]
        [parameter(parametersetname='explicitscopesnewconnectioncloud', mandatory=$true)]
        [GraphCloud] $Cloud = [GraphCloud]::Public,

        $Version
    )
    $commandContext = new-so CommandContext $Connection $Version $Permissions $Cloud $::.ApplicationAPI.DefaultApplicationApiVersion
    $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

    $app = $appAPI |=> GetApplicationByAppId $AppId

    $appAPI |=> SetConsent $app.appid $DelegatedPermissions $AppOnlyPermissions $AllPermissions.IsPresent $ConsentForTenant.IsPresent ($UserIdToConsent -ne $null) $UserIdToConsent $app
}

$::.ParameterCompleter |=> RegisterParameterCompleter Set-GraphApplicationConsent DelegatedPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter Set-GraphApplicationConsent AppOnlyPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter Set-GraphApplicationConsent Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))
