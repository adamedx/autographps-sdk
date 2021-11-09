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
Registers an Azure Active Directory (AAD) application in the organization.

.DESCRIPTION
In order for an Azure Active Directory (AAD) application identity to access resources from Microsoft Graph, it must be registered in the organization. The mere creation of an application in the organization using the Graph API does not register the application -- an application is considered registered only after a service principal resource associated with it has been created in the organization. Register-GraphApplication creates a service principal in the organization for a given application. This is useful for configuring permissions consented to the application before the first sign-in occurs for the application so that identities performing the sign-in are able to obtain the permissions they require.

By default, a service principal is automatically provisioned in the organization the first time a successful sign-in occurs to the application. However the identity performing the sign-in may not be authorized to grant consent to required applications. If there is no service principal created before the first sign-in then there are no permissions consented to the application in the organization. This means that unless the identity performing the sign-in is authorized to grant permissions requested during the sign-in, the sign-in may fail. To ensure that an identity may obtain the correct permissions, an authorized user such as an administrator can create the service principal before a sign-in has occurred using Register-GraphApplication. The use of Register-GraphApplication also includes the ability to specify permissions that should be granted. Alternatively, Register-GraphApplication can be used to simply create the service principal without any granted permissions, and then the Set-GraphApplicationConsent command can be subsequently invoked to configure permission grants.

Note that the functionality of Register-GraphApplication is present in the New-GraphApplication, which creates an AAD application in the organization AND by default registers a service principal for it in the organization; New-GraphApplication can also configure permissions grants just like Register-GraphApplication.

New-GraphApplication's ability to both create an application and register its service principal is limited to use cases where the application resides in only one organization. Multi-tenant applications are applications that allow sign-in from any organization, not just the organization in which the application was created. For such applications, a service principal must be created in all organizations where sign-in is to occur, and New-GraphApplication can only create service principals within the organization in which the new application is being created.

Thus for multi-tenant applications, Register-GraphApplication is the only way to configure the service principal before sign-in for all organizations other than the one that hosts the application.

For more information about consent, see the Set-GraphApplicationConsent command documentation.

Note that the registration peration can be undone. To unregister an application, use the Unregister-GraphApplication command.

.PARAMETER AppId
The AppId parameter specifies the application identifier for the application to register in the organization. If the application is a single-tenant application, the application identifier must refer to an application with that identifier in the organization.

.PARAMETER DelegatedPermissions
The delegated permissions to be consented to the application.

.PARAMETER ApplicationPermissions
The application permissions to be consented to the application.

.PARAMETER SkipPermissionNameCheck
By default, the permission names specified to DelegatedUserPermissions and ApplicationPermissions are validated, and if the command cannot identify them as valid permission names the command fails. In some cases where the identity invoking the command has limited permissions, the command may be unable to perform accurate validation. To work around this problem, secify the SkipPermissionCheck parameter. The command will still fail if the permission name is actually invalid, but only after the application is already registered.

.PARAMETER ImportFromOtherTenant
By default, the Register-GraphApplication command will not register an application if it cannot be found in the directory of the identity invoking the command. To register a multi-tenant application that is not hosted in this organization, speify the ImportFromOtherTenant parameter.

.PARAMETER AllPermissions
Specify the AllPermissions parameter to register all permissions configured for the application. Applications may be configured to require certain permissions; this configuration does not grant the permissons however. The permissions can only be granted after the application is registered. Specifying AllPermissions instructs Register-GraphApplication to read required permissions from the application it registered and then grant those permissions after the registration, i.e. service prinicpal creation, has taken place.

.PARAMETER ConsentForAllPrincipals
Specifies that for delegated permissions specified by the DelegatedPermissions parameter the command should grant the delegated permissions to all principals. If this is not specified and the ConsentedPrincipalId parameter is not specified, then if the signed-in identity invoking the command is a user, the delegated permissions are granted to the signed-in user.

.PARAMETER ConsentedPrincipalId
Use the ConsentedPrincipalId specify the AAD object identifier of a user to whom the permissions specified with the DelegatedPermissions parameter must be consented.

.PARAMETER Connection
Specify the Connection parameter to use an alternative connection to the current connection.

.OUTPUTS
If the application was not registered, i.e. it has no service principal, Register-GraphApplication returns the service principal created for the application by the command. If the application is already registered in the organization, i.e. if the application's service principal already exists, the command fails.

.EXAMPLE
Register-GraphApplication a5ebc719-fee5-4eb8-963c-4f1cf24ae813

In this example, the application with the specified application identifier is registered in the organization.

.EXAMPLE
Register-GraphApplication -AppId 393c7459-2629-4785-9f39-7f36c8d462c3 -ApplicationPermissions Application.Read.All

In this example a multi-tenant application from a different organization is registered in this tenant and granted the Application.Read.All permission.

.EXAMPLE
Register-GraphApplication -AppId 5b02a9d1-061e-4df8-a293-fffb692f7988 -ImportFromOtherTenant -DelegatedPermissions Group.Read.All

In this example the PrincipalIdToConsent parameter is specified to Register-GraphApplication so that when it is registered the permission specified with DelegatedPermissions parameter is granted to the principal (e.g. a user) specified by the PrincipalIdToConsent parameter.

.LINK
Set-GraphApplicationConsent
New-GraphApplication
Unregister-GraphApplication
#>
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

        [PSCustomObject] $Connection = $null
    )

    begin {
        Enable-ScriptClassVerbosePreference

        $commandContext = new-so CommandContext $Connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

        if ( $ApplicationPermissions ) {
            $::.ScopeHelper |=> ValidatePermissions $ApplicationPermissions $true $SkipPermissionNameCheck.IsPresent $commandContext.connection
        }

        if ( $DelegatedUserPermissions ) {
            $::.ScopeHelper |=> ValidatePermissions $DelegatedUserPermissions $false $SkipPermissionNameCheck.IsPresent $commandContext.connection
        }

        $appAPI = new-so ApplicationAPI $commandContext.Connection $commandContext.Version
    }

    process {

        $newAppSP = $appAPI |=> RegisterApplication $AppId $ImportFromOtherTenant.IsPresent

        if ( $newAppSP ) {
            $appAPI |=> SetConsent $appid $DelegatedUserPermissions $ApplicationPermissions $AllPermissions.IsPresent $ConsentedPrincipalId $ConsentForAllPrincipals.IsPresent $newAppSP.Id

            $newAppSP.pstypenames.insert(0, 'AutoGraph.ServicePrincipal')
            $newAppSP
        }
    }

    end {
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Register-GraphApplication DelegatedUserPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

$::.ParameterCompleter |=> RegisterParameterCompleter Register-GraphApplication ApplicationPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))

