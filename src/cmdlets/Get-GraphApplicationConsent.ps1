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

. (import-script Invoke-GraphApiRequest)
. (import-script ../graphservice/ApplicationAPI)
. (import-script common/ConsentHelper)
. (import-script common/CommandContext)

<#
.SYNOPSIS
Gets the Graph API objects that configure the consent of Microsoft Graph permissions to Entra ID applications.

.DESCRIPTION
In order for an Entra ID application identity to access resources from Microsoft Graph, permissions must be granted to the application. The grant of permissions is referred to as consent. The Get-GraphApplicationConsent command gets the permissions that were consented to an application and in what circumstances the consent is granted:

    * Application permissions may be consented directly to the application in the form of app-role assignments. In this scenario, the application is authenticated solely with its own identity and no associated user, and upon authentication is granted these application permissions.
    * Delegated permissions may be consented to the application. Delegated consent occurs when the application identity is authenticated as part of a user sign-in; in this case, the authenticated identity includes the user's identity and the granted permissions are based on permissions granted for that user to the application. Some permissions may be granted to the application by the user to the application, and the process of the user granting those permissions may occur as part of an user interface interaction with the user at sign-in, or the user may grant the permissions prior to sign-in using another application to configure the consent. Administrators may also grant consent to an application for all users in the organization or to specific users using either configuration tools / applications or user experiences invoked when the administrator signs in to the application. Most permissions may only be granted by an administrator; users that would like to delegate permissions for an application to obtain that permission when the user signs in must coordinate with the administrator so that the administrator can grant the consent or deny the request if it is not appropriate.

Get-GraphApplicationConsent is useful for administrators to see what permissions have been granted to users in the organization. They can use the related Set-GraphApplicationConsent command to configure the consented permissions.

.PARAMETER AppId
Specify the AppId parameter to return consent objects for permissions granted in the organization to the application with the specified application identifier.

.PARAMETER ConsentForAllPrincipals
Specifies that for delegated permissions the command should return only consent grants that specify that the consented delegated permissions should be granted to all principals in the entire organization and not just specific users or principals. This parameter does not affect which application-only permissions are emitted by the command.

.PARAMETER RawContent
Specify the RawContent parameter to emit the consent objects as JSON rather than objects.

.PARAMETER ConsentedPrincipalId
Use the ConsentedPrincipalId parameter to return only the consent objects that specify that the permission should be granted to that permission. The parameter must be the Entra ID object identifier of a user, group, application, service principal, or any principal for which permissions may be granted. Note that if

.PARAMETER PermissionType
Specifies which consent objects must be returned by the command based on the kind of consented permission. By default the value is 'Any', which returns consent grants for any type of permission. Specify 'Delegated' to return consent objects only for consent to delegated permissions, and 'AppOnly' to return only consent to application permissions.

.PARAMETER All
Specify the All parameter to return all consent objects that match the specified criteria. By default, only a predetermined number of objects controlled by Entra ID is returned to avoid unintentionally inefficient long-running queries.

.PARAMETER Connection
Specify the Connection parameter to use as an alternative connection to the current connection.

.OUTPUTS
The command returns consent objects in the organization that satisfy the specifications of the command's input parameters. If the AppId parameter is specified, the command fails if it cannot find the application.

If there are no consent objects that satisfy the specified input parameters, there will simply be no output rather than a failure.

Each consent object contains properties that include the application identifier for which the consent is granted, the typeof permission consented, whether or not the consent applies to the entire organization or just specific principals, the identity to which the consent is granted, and the service prinicipal object identifier of service principal of the application for which the consent was granted.

.NOTES

The output of Get-GraphApplicationConsent is a custom object rather than one of the types of consent object returned by the Graph API. This is due to the fact that for delegated permissions at least the representation of consent

.EXAMPLE
Get-GraphApplicationConsent a5ebc719-fee5-4eb8-963c-4f1cf24ae813

   AppId: a5ebc719-fee5-4eb8-963c-4f1cf24ae813

PermissionType ServicePrincipalId                   Permission                 GrantedTo
-------------- ------------------                   ----------                 ---------
Delegated      2d764346-15c4-4afa-8bbf-243705f545a8 Chat.ReadWrite             63e85339-92ba-4bae-ba48-d37415b2cff1
Delegated      2d764346-15c4-4afa-8bbf-243705f545a8 User.Read                  AllUsers
Delegated      2d764346-15c4-4afa-8bbf-243705f545a8 openid                     63e85339-92ba-4bae-ba48-d37415b2cff1
Delegated      2d764346-15c4-4afa-8bbf-243705f545a8 profile                    63e85339-92ba-4bae-ba48-d37415b2cff1
Delegated      2d764346-15c4-4afa-8bbf-243705f545a8 offline_access             63e85339-92ba-4bae-ba48-d37415b2cff1
Delegated      2d764346-15c4-4afa-8bbf-243705f545a8 ChannelMessage.Read.All    f786765c-f95c-4807-8f52-08aeba073943

In this example, the AppId parameter is specified as a positional parameter and the consented permissions are displayed with information indicating who was granted consent.

.EXAMPLE

$backupApps = Get-GraphApplication -Name 'Backup Application'

The Name parameter is used here to search for an application by display name. Because application display names are not unique, there may be more than one application returned when the Name parameter is specified.

.EXAMPLE
Get-GraphApplication -All | Get-GraphApplicationConsent -Tenant -PermissionType Delegated -All

   AppId: 25159798-e63d-406c-b36f-a41a2dd3efc7

PermissionType ServicePrincipalId                   Permission     GrantedTo
-------------- ------------------                   ----------     ---------
Delegated      7d3a6fe5-285a-4a9f-9a79-b3395e0c4f5f User.Read      AllUsers
Delegated      7d3a6fe5-285a-4a9f-9a79-b3395e0c4f5f Group.Read.All AllUsers

   AppId: 80fd2571-93c7-4e79-a701-0b45e0f95c17

PermissionType ServicePrincipalId                   Permission                 GrantedTo
-------------- ------------------                   ----------                 ---------
Delegated      d32fd267-624f-4203-a39e-0299bd1d3594 Directory.AccessAsUser.All AllUsers

In this example, all applications in the organization are enumerated using Get-GraphApplication, and then the result is piped to Get-GraphApplicationConsent with the Tenant parameter specified and the PermissionType specified as "delegated", which retrieves only the consent grants to all principals in the organization.

.LINK
Set-GraphApplicationConsent
Remove-GraphApplicationConsent
Get-GraphApplication
Register-GraphApplication
New-GraphApplication
#>
function Get-GraphApplicationConsent {
    [cmdletbinding(positionalbinding=$false, supportspaging=$true, defaultparametersetname='TenantOrSpecificPrincipal')]
    [OutputType('GraphConsentDisplayType')]
    param(
        [parameter(position=0, valuefrompipelinebypropertyname = $true, mandatory=$true)]
        [Guid] $AppId,

        [switch] $ConsentForAllPrincipals,

        [switch] $RawContent,

        $ConsentedPrincipalId,

        [validateset('Any', 'AppOnly', 'Delegated')]
        [string] $PermissionType = 'Any',

        [switch] $All,

        $Connection
    )

    begin {
        $includeAppOnly = $PermissionType -in 'Any', 'AppOnly'
        $includeDelegated = $PermissionType -in 'Any', 'Delegated'
    }

    process {
        Enable-ScriptClassVerbosePreference

        $commandContext = new-so CommandContext $Connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

        $appSP = try {
            $appAPI |=> GetAppServicePrincipal $AppId
        } catch {
            write-error "Unable to find a service prinicpal for application with AppId '$AppId', the application may not yet have been accessed in this tenant"
        }

        if ( ! $appSP ) {
            write-verbose "Unable to find service principal for application '$AppId', assuming no consent exists"
        } else {
            $appSPId = $appSP.id

            $appFilter = "clientId eq '$appSPId'"
            $filterClauses = @($appFilter)

            $grantFilter = if ( $ConsentForAllPrincipals.IsPresent ) {
                "consentType eq 'AllPrincipals'"
            } elseif ( $ConsentedPrincipalId ) {
                "consentType eq 'Principal' and principalId eq '$ConsentedPrincipalId'"
            }

            if ( $grantFilter ) {
                $filterClauses += $grantFilter
            }

            $filter = $filterClauses -join ' and '

            $filterArgument = @{ Filter = $filter }

            $rawContentArgument = @{ RawContent = $RawContent }

            $allArgument = @{ All = $All }

            $pagingParameters = @{}

            if ( $pscmdlet.pagingparameters.first ) {
                $pagingParameters['First'] = $pscmdlet.pagingparameters.first
            }

            if ( $pscmdlet.pagingparameters.skip ) {
                $pagingParameters['Skip'] = $pscmdlet.pagingparameters.skip
            }

            $response = if ( $includeDelegated ) {
                Invoke-GraphApiRequest /oauth2PermissionGrants -method GET -Filter $filter -version $::.ApplicationAPI.DefaultApplicationApiVersion @rawContentArgument @allArgument @pagingParameters -ConsistencyLevel Session -Connection $commandContext.Connection
            }

            if ( $response ) {
                if ( ! $RawContent.IsPresent ) {
                    if ( $response | gm id -erroraction ignore ) {
                        $response | foreach {
                            $::.ConsentHelper |=> ToDisplayableObject $_ $AppId $appSPId
                        }
                    }
                } else {
                    $response
                }
            }

            $roleResponse = if ( $includeAppOnly ) {
                Invoke-GraphApiRequest /servicePrincipals/$appSPId/appRoleAssignments -method GET -version $::.ApplicationAPI.DefaultApplicationApiVersion @RawContentArgument @AllArgument @pagingParameters -ConsistencyLevel Session -Connection $commandContext.Connection
            }

            if ( $roleResponse ) {
                if ( ! $RawContent.IsPresent ) {
                    if ( $roleResponse | gm id -erroraction ignore ) {
                        $roleResponse | foreach {
                            $::.ConsentHelper |=> ToDisplayableObject $_ $AppId $appSPId
                        }
                    }
                } else {
                    $roleResponse
                }
            }
        }
    }

    end {}
}

