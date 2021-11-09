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


<#
.SYNOPSIS
Consents delegated or app-only permissions to an Azure Active Directory (AAD) application.

.DESCRIPTION
In order for an Azure Active Directory (AAD) application identity to access resources from Microsoft Graph, permissions must be granted to the application. The grant of permissions is referred to as consent. The Set-GraphApplicationConsent command grants consent to an application for app-only or delegated permissions:

    * Application permissions may be consented directly to the application in the form of app-role assignments.
    * Delegated permissions may be consented to specific principals or to all principals in the organization

See the Get-GraphApplicationConsent command for more details on consent.

.PARAMETER AppId
Specifies the application identifier for the application to which consent will be granted.

.PARAMETER DelegatedPermissions
The delegated permissions to be consented to the application. The consent is configured as oauth2PermissionGrant resources documented as part of the Graph API.

.PARAMETER ApplicationPermissions
The application permissions to be consented to the application. The consent is actually configured as app role assignments described by the appRoleAssignment resource documented as part of the Graph API.

.PARAMETER ConsentedPrincipalId
Use the ConsentedPrincipalId parameter to specify a principal such as a user to which the specified delegated permissions should be granted when signed in to the application. If neither this parameter nor the AllPermissions parameter is specified, then if the command is executing using a delegated identity, that identity is granted consent for delegated permissions. If that case is modified so that the command is executing using an application-only identity, then the command will fail if neither AllPermisions or ConsentedPrincipalId is specified. When specifying this parameter, it must be the AAD object identifier guid of the user to which to grant consent.

.PARAMETER AllPermissions
Specify AllPermissions to grant consent to all permissions configured on the application as required permissions.

.PARAMETER ConsentForAllPrincpals
Specify ConsentForAllPrincipals to grant consent for the specified delegated permissions to all principals (including users) in the organization.

.PARAMETER Connection
Specify the Connection parameter to use an alternative connection to the current connection.

.OUTPUTS
The command returns no output.

.EXAMPLE
Set-GraphApplicationConsent -AppId a5ebc719-fee5-4eb8-963c-4f1cf24ae813 -DelegatedPermissions Files.Read -ConsentedPrincipalId 770883fe-8c35-4d44-9047-e54c2667214b

In this example, the delegated permission Files.Read is consented to user 770883fe-8c35-4d44-9047-e54c2667214b when signed in to application a5ebc719-fee5-4eb8-963c-4f1cf24ae813

.EXAMPLE
Set-GraphApplicationConsent -AppId 7fd2ae38-1b03-4874-a9f4-ee3111964f68 -ApplicationPermissions Group.Read.All

Here the ApplicationPermissions parameter is used to consent the app-only permission Group.Read.All to the application.

.EXAMPLE
Get-GraphApplication -Name 'App Provisioning Application' |
    Set-GraphApplicationConsent -ApplicationPermissions Application.ReadWrite.OwnedBy

This example shows how an application object can be piped in to Set-GraphApplication to set consent for the application.

.EXAMPLE
Get-GraphApplication -Filter "startsWith(displayName, 'mytestappx')" |
    Set-GraphApplicationConsent -ApplicationPermissions Group.Read.All

This example shows how to update consent for multiple applications using the pipeline. In this case, Get-GraphApplication is used with a search filter to find all applications with a name that start with a certain substring. The result is piped to Set-GraphApplicationConsent, which sets consent on each application in the pipeline.

.LINK
Get-GraphApplicationConsent
Get-GraphApplication
Register-GraphApplication
New-GraphApplication
#>
function Set-GraphApplicationConsent {
    [cmdletbinding(defaultparametersetname='simple', positionalbinding = $false)]
    param(
        [parameter(position=0, parametersetname='simple', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='explicitscopes', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='allconfiguredpermissions', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='explicitscopes')]
        [string[]] $DelegatedUserPermissions,

        [parameter(parametersetname='explicitscopes')]
        [string[]] $ApplicationPermissions,

        [parameter(parametersetname='allconfiguredpermissions', mandatory=$true)]
        [switch] $AllPermissions,

        [switch] $ConsentForAllPrincipals,

        $ConsentedPrincipalId,

        $Connection
    )

    begin {}

    process {
        Enable-ScriptClassVerbosePreference

        $commandContext = new-so CommandContext $Connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

        $appAPI |=> SetConsent $appId $DelegatedUserPermissions $ApplicationPermissions $AllPermissions.IsPresent $ConsentedPrincipalId $ConsentForAllPrincipals.IsPresent $null $null $true
    }

    end {}
}

$::.ParameterCompleter |=> RegisterParameterCompleter Set-GraphApplicationConsent DelegatedUserPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter Set-GraphApplicationConsent ApplicationPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))

