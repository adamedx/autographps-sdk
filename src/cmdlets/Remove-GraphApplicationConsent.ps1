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

. (import-script common/CommandContext)
. (import-script ../graphservice/ApplicationAPI)
. (import-script common/PermissionParameterCompleter)

<#
.SYNOPSIS
Removes consent of delegated or app-only permissions to an Entra ID application.

.DESCRIPTION
In order for an Entra ID application identity to access resources from Microsoft Graph, permissions must be granted to the application. The grant of permissions is referred to as consent. The Remove-GraphApplicationConsent command removes the grant of specified permissions to an Entra ID application. Such grants can be created as part of user interactions that grant consent to permissions at sign-in or through the Graph API, including the use of commands like Set-GraphApplicationConsent, Register-GraphApplication, or New-GraphApplication.

See the Get-GraphApplicationConsent command for more details on consent.

When removing consent, for application permissions it is sufficient to supply the ApplicationPermission parameter to identify the permission to remove. For delegated permissions, a principal must be supplied, either explicitly using the ConsentForAllPrincipals or ConsentedPrincipalId parameter, or implicitly using the object identifier of the user invoking Remove-GraphApplicationConsent. For example, if the application has been granted both Directory.Read.All and Application.ReadWrite.All to user X, then to remove the Application.ReadWrite.All granted to X, the parameters for Remove-GraphApplicationConsent must specify Application.ReadWrite.All as a (delegated) permission through the DelegatedPermissions parameter and the ConsentedPrincipalId must be the directory object identifier for X.

No error occurs if no consent grants can be found to remove that match the specified parameters.

.PARAMETER AppId
Specifies the application identifier for the application to which consent will be removed.

.PARAMETER DelegatedPermissions
Specifies the delegated permissions for which to remove consent. Note that since the consent grant for delegated permissions requires a target, you must specify either the ConsentedPrincipalId parameter or the ConsentForAllUsers parameter so that the command can determine which consent to remove. If the command is being invoked using a connection that was signed in with delegated permissions, then you may omit these parameters and the command will assume the value of the user signed in to the connection for the ConsentedPrincipalId parameter.

.PARAMETER ApplicationPermissions
Specifieds the app-only permissions for which to remove consent.

.PARAMETER ConsentedPrincipalId
Specifies the principal in the grant to remove.

.PARAMETER AllPermissions
Remove consent for all permissions.

.PARAMETER ConsentForAllPrincpals
Specify ConsentForAllPrincipals to remove a consent grant for all principals of the organization rather than a specific principal.

.PARAMETER Connection
Specify the Connection parameter to use as an alternative connection to the current connection.

.OUTPUTS
The command returns no output.

.EXAMPLE
Remove-GraphApplicationConsent -AppId a5ebc719-fee5-4eb8-963c-4f1cf24ae813 -DelegatedPermissions Files.Read -ConsentedPrincipalId 770883fe-8c35-4d44-9047-e54c2667214b

In this example, the consent for the delegated permission Files.Read to principal 770883fe-8c35-4d44-9047-e54c2667214b is removed for the application with identifier a5ebc719-fee5-4eb8-963c-4f1cf24ae813

.EXAMPLE
Get-GraphApplicationConsent -AppId a5ebc719-fee5-4eb8-963c-4f1cf24ae813 -All |
    Remove-GraphApplicationConsent

This example shows how to remove all application permissions granted to an application by enumerating the permissions granted to an application using the Get-GraphApplicationConsent command and piping the output to Remove-GraphApplicationConsent which removes each consented permission emitted by Get-GraphApplicationConsent.

.EXAMPLE
Get-GraphApplicationServicePrincipal -All |
    Remove-GraphApplicationConsent -DelegatedPermissions Directory.AccessAsUser.All

In this example, the delegated permission Directory.AccessAsUser.All is removed from every application in the organization. This is accomplished by enumerating all service principals and then piping the output to Remove-GraphApplicationConsent

.LINK
Get-GraphApplicationConsent
Set-GraphApplicationConsent
Get-GraphApplication
Get-GraphApplicationServicePrincipal
Register-GraphApplication
New-GraphApplication
#>
function Remove-GraphApplicationConsent {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='delegated')]
    param(
        [parameter(position=0, parametersetname='application', mandatory=$true)]
        [parameter(position=0, parametersetname='delegated', mandatory=$true)]
        [parameter(position=0, parametersetname='delegatedallusers', mandatory=$true)]
        [parameter(position=0, parametersetname='allpermissions', mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='consentgrant', valuefrompipeline=$true, mandatory=$true)]
        [PSTypeName('GraphConsentDisplayType')] $ConsentGrant,

        [parameter(parametersetname='application', mandatory=$true)]
        [string[]] $ApplicationPermissions,

        [parameter(parametersetname='delegated', mandatory=$true)]
        [parameter(parametersetname='delegatedallusers', mandatory=$true)]
        [string[]] $DelegatedUserPermissions,

        [parameter(parametersetname='delegatedallusers', mandatory=$true)]
        [switch] $ConsentForAllPrincipals,

        [parameter(parametersetname='delegated')]
        $ConsentedPrincipalId,

        [parameter(parametersetname='allpermissions', mandatory=$true)]
        [switch] $AllPermissions,

        $Connection
    )

    begin {
        # This is only for the AllPermissions case and is required to delete multiple oauth2Grants
        # (i.e. delegated permission consents) being passed to the pipeline. This is due to the fact
        # the graph API records multiple permissions per oauth2Grant object, but Get-GraphApplicationConsent
        # returns exactly one custom object per permission. That means that more than one of the objects
        # may reference the same oauth2Grant object. We use this table to keep track of the objects passed
        # to the pipeline so that we can skip any object from a previous permission that has already been
        # deleted.
        $processedOAuth2Grants = @{}
    }

    process {
        Enable-ScriptClassVerbosePreference

        $consentObject = $null
        $consentGrantType = if ( $ConsentGrant ) {
            if ( ! ( $ConsentGrant | gm GraphResource -erroraction ignore ) ) {
                throw "The ConsentGrant parameter was invalid -- it did not have a member named 'GraphResource'"
            }
            $consentObject = $ConsentGrant.GraphResource
            if ( $processedOauth2Grants[$consentObject.id] ) {
                return
            }
            $processedOauth2Grants[$consentObject.id] = $consentObject

            $ConsentGrant.PermissionType
        }

        $isAppOnly = ($consentGrantType -eq 'Application') -or ( $ApplicationPermissions -and ( $ApplicationPermissions.length -gt 0 ) )

        $commandContext = new-so CommandContext $Connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

        $appSPId = if ( $consentObject ) {
            if ( $isAppOnly ) {
                # appRoleAssignment objects have a service principal id
                # in the principalId property
                $consentObject.principalId
            } else {
                # oauth2PermissionGrant objects have a service principal id
                # in the clientId property
                $consentObject.clientId
            }
        } else {
            $appSP = $appAPI |=> GetAppServicePrincipal $AppId
            $appSP.id
        }

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

        $filterArgument = if ( ! $consentObject ) {
            $filterClauses -join ' and '
        }

        # For oauth2 grants, we either delete the entire grant (in the case of AllPermissions)
        # or edit an existing matching grant to remove a targeted permission => principal assigment.
        if ( ! $isAppOnly -or $AllPermissions.IsPresent ) {
            $grants = if ( ! $consentObject ) {
                # Rely on the fact that the scopes are specific to MS Graph -- we don't need to query for
                # the resourceId of the grant to be the Graph service principal because it's implied by the scope names
                $commandContext |=> InvokeRequest -Uri oauth2PermissionGrants -RESTMethod GET -Filter $filterArgument
            } elseif ( ! $isAppOnly ) {
                @($consentObject)
            }

            if ( $grants -and ( $grants | gm id -erroraction ignore ) ) {
                foreach ( $grant in $grants ) {
                    $reducedPermissions = if ( ! $consentObject -and $DelegatedUserPermissions ) {
                        $appAPI |=> GetReducedPermissionsString $grant.scope $DelegatedUserPermissions
                    }

                    if ( $consentObject -or ( ! $DelegatedUserPermissions -or ! $reducedPermissions ) ) {
                        $commandContext |=> InvokeRequest -uri "/oauth2PermissionGrants/$($grant.id)" -RESTMethod DELETE | out-null
                    } elseif ( $reducedPermissions -ne $grant.scope ) {
                        $updatedScope = @{scope = $reducedPermissions}
                        $commandContext |=> InvokeRequest "/oauth2PermissionGrants/$($grant.id)" -RESTMethod PATCH -body $updatedScope | out-null
                    } else {
                        write-verbose "Requested permissions were not present in existing grant, no change is necessary, skipping update for grant id='$($grant.id)'"
                    }
                }
            }
        }

        if ( $isAppOnly -or $AllPermissions.IsPresent ) {
            $targetPermissions = if ( $ApplicationPermissions ) {
                foreach ( $permission in $ApplicationPermissions ) {
                    $::.ScopeHelper |=> GraphPermissionNameToId $permission 'Role' $CommandContext.connection $true
                }
            }

            $roleAssignments = if ( ! $consentObject ) {
                $commandContext |=> InvokeRequest -uri servicePrincipals/$appSPId/appRoleAssignments -RESTMethod GET
            } elseif ( $isAppOnly ) {
                $consentObject
            }

            if ( $roleAssignments -and ( $roleAssignments | gm -erroraction ignore id ) ) {
                # Since the permission id's being tested for are specific to Graph, we
                # don't need to validate the resourceId to ensure that it is Graph
                $assignmentsToDelete = $roleAssignments | where {
                    $consentObject -ne $null -or
                    $AllPermissions.IsPresent -or
                    $targetPermissions -contains $_.appRoleId
                }

                foreach ( $roleAssignment in $assignmentsToDelete ) {
                    $commandContext |=> InvokeRequest -uri "/servicePrincipals/$appSPId/appRoleAssignments/$($roleAssignment.Id)" -RESTmethod DELETE | out-null
                }
            }
        }
    }

    end {}
}

$::.ParameterCompleter |=> RegisterParameterCompleter Remove-GraphApplicationConsent ApplicationPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AppOnlyPermission))
$::.ParameterCompleter |=> RegisterParameterCompleter Remove-GraphApplicationConsent DelegatedUserPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

