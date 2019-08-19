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
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid[]] $AppId,

        [string[]] $RemovedPermissions,

        [switch] $ConsentForTenant,

        [switch] $AllConsent,

        $ConsentForPrincipal,

        $Connection,

        $Version
    )

    begin {}

    process {
        Enable-ScriptClassVerbosePreference

        if ( $ConsentForTenant.IsPresent ) {
            if ( $ConsentForPrincipal ) {
                throw [ArgumentException]::new("The 'ConsentForTenant' option may not be specified when 'ConsentForTenant' is specified'")
            }
        }

        $commandContext = new-so CommandContext $Connection $Version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

        $appSP = $appAPI |=> GetAppServicePrincipal $AppId
        $appSPId = $appSP.id

        $appFilter = "clientId eq '$appSPId'"
        $filterClauses = @($appFilter)

        if ( ! $AllConsent.IsPresent ) {
            $grantFilter = if ( $ConsentForTenant.IsPresent ) {
                "consentType eq 'AllPrincipals'"
            } elseif ( $ConsentForPrincipal ) {
                "consentType eq 'Principal' and principalId eq '$ConsentForPrincipal'"
            }

            $filterClauses += $grantFilter
        }

        $filter = $filterClauses -join ' and '

        $filterArgument = @{ ODataFilter = $filter }

        $grants = $commandContext |=> InvokeRequest -uri oauth2PermissionGrants -RESTmethod GET -ODataFilter $filter

        if ( $grants -and ( $grants | gm id ) ) {
            $grants | foreach {
                if ( ! $RemovedPermissions ) {
                    $commandContext |=> InvokeRequest -uri "/oauth2PermissionGrants/$($_.id)" -RESTmethod DELETE | out-null
                } else {
                    $reducedPermissions = GetReducedPermissionsString $_.scope $RemovedPermissions
                    if ( $reducedPermissions ) {
                        $updatedScope = @{scope = $reducedPermissions}
                        $commandContext |=> InvokeRequest "/oauht2PermissionGrants/$($_.id)" -RESTmethod PATCH -body $updatedScope | out-null
                    } else {
                        write-verbose "Requested permissions were not present in existing grant, no change is necessary, skipping update for grant id='$($_.id)'"
                    }
                }
            }
        }
    }

    end {}
}

$::.ParameterCompleter |=> RegisterParameterCompleter Remove-GraphApplicationConsent RemovedPermissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))

