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

. (import-script common/CommandContext)
. (import-script ../graphservice/ApplicationAPI)
. (import-script common/PermissionParameterCompleter)

function Remove-GraphApplicationConsent {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='delegated')]
    param(
        [parameter(position=0, mandatory=$true)]
        [Guid[]] $AppId,

        [parameter(position=1,parametersetname='application', mandatory=$true)]
        [string[]] $ApplicationPermissions,

        [parameter(position=1,parametersetname='delegated', mandatory=$true)]
        [parameter(position=1,parametersetname='delegatedallusers', mandatory=$true)]
        [string[]] $DelegatedUserPermissions,

        [parameter(parametersetname='delegatedallusers', mandatory=$true)]
        [switch] $AllTenantUsers,

        [parameter(parametersetname='delegated')]
        $Principal,

        [parameter(parametersetname='allapppermissions', mandatory=$true)]
        [switch] $AllApplicationPermissions,

        $Connection,

        $Version
    )

    begin {}

    process {
        Enable-ScriptClassVerbosePreference

        $isAppOnly = $AllApplicationPermissions.IsPresent -or ($ApplicationPermissions -and $ApplicationPermissions.length -gt 0)

        $commandContext = new-so CommandContext $Connection $Version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

        $appSP = $appAPI |=> GetAppServicePrincipal $AppId
        $appSPId = $appSP.id

        $appFilter = "clientId eq '$appSPId'"
        $filterClauses = @($appFilter)

        $grantFilter = if ( $AllTenantUsers.IsPresent ) {
            "consentType eq 'AllPrincipals'"
        } elseif ( $Principal ) {
            "consentType eq 'Principal' and principalId eq '$Principal'"
        }

        if ( $grantFilter ) {
            $filterClauses += $grantFilter
        }

        $filter = $filterClauses -join ' and '

        if ( ! $isAppOnly ) {
            $grants = $commandContext |=> InvokeRequest -uri oauth2PermissionGrants -RESTmethod GET -ODataFilter $filter

            if ( $grants -and ( $grants | gm id ) ) {
                $grants | foreach {
                    if ( ! $DelegatedUserPermissions ) {
                        $commandContext |=> InvokeRequest -uri "/oauth2PermissionGrants/$($_.id)" -RESTmethod DELETE | out-null
                    } else {
                        $reducedPermissions = $appAPI |=> GetReducedPermissionsString $_.scope $DelegatedUserPermissions
                        if ( $reducedPermissions ) {
                            $updatedScope = @{scope = $reducedPermissions}
                            $commandContext |=> InvokeRequest "/oauth2PermissionGrants/$($_.id)" -RESTmethod PATCH -body $updatedScope | out-null
                        } else {
                            write-verbose "Requested permissions were not present in existing grant, no change is necessary, skipping update for grant id='$($_.id)'"
                        }
                    }
                }
            }
        } else {
            $targetPermissions = if ( $ApplicationPermissions ) {
                foreach ( $permission in $ApplicationPermissions ) {
                    $::.ScopeHelper |=> GraphPermissionNameToId $permission 'Role' $CommandContext.connection $true
                }
            }

            $roleAssignments = $commandContext |=> InvokeRequest -uri servicePrincipals/$appSPId/appRoleAssignedTo -RESTMethod GET

            if ( $roleAssignments -and ( $roleAssignments | gm id ) ) {
                $assignmentsToDelete = $roleAssignments | where {
                    $AllApplicationPermissions.IsPresent -or
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

