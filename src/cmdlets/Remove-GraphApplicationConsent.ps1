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

function Remove-GraphApplicationConsent {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='delegated')]
    param(
        [parameter(position=0, parametersetname='application', mandatory=$true)]
        [parameter(position=0, parametersetname='delegated', mandatory=$true)]
        [parameter(position=0, parametersetname='delegatedallusers', mandatory=$true)]
        [parameter(position=0, parametersetname='allpermissions', mandatory=$true)]
        [Guid[]] $AppId,

        [parameter(parametersetname='consentgrant', valuefrompipeline=$true, mandatory=$true)]
        $ConsentGrant,

        [parameter(parametersetname='application', mandatory=$true)]
        [string[]] $ApplicationPermissions,

        [parameter(parametersetname='delegated', mandatory=$true)]
        [parameter(parametersetname='delegatedallusers', mandatory=$true)]
        [string[]] $DelegatedUserPermissions,

        [parameter(parametersetname='delegatedallusers', mandatory=$true)]
        [switch] $ConsentForAllUsers,

        [parameter(parametersetname='delegated')]
        $Principal,

        [parameter(parametersetname='allpermissions', mandatory=$true)]
        [switch] $AllPermissions,

        [Alias('Connection')]
        [PSCustomObject] $ConnectionInfo,

        $Version
    )

    begin {
        $Connection = if ( $ConnectionInfo ) {
            $ConnectionInfo.Connection
        }

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

        $commandContext = new-so CommandContext $Connection $Version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
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

        $grantFilter = if ( $ConsentForAllUsers.IsPresent ) {
            "consentType eq 'AllPrincipals'"
        } elseif ( $Principal ) {
            "consentType eq 'Principal' and principalId eq '$Principal'"
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

