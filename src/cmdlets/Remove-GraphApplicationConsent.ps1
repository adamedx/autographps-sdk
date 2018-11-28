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

. (import-script ../cmdlets/Invoke-GraphRequest)
. (import-script ../graphservice/GraphApplicationRegistration)

function Remove-GraphApplicationConsent {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='specificprincipal')]
    param(
        [parameter(position=0, mandatory=$true)]
        $AppId,

        [string[]] $Permissions,

        [parameter(parametersetname='entiretenant')]
        [switch] $Tenant,

        [parameter(parametersetname='allgrants')]
        [switch] $AllConsent,

        [parameter(parametersetname='specificprincipal', position=1, mandatory=$true)]
        $Principal
    )

    $appSP = $::.GraphApplicationRegistration |=> GetAppServicePrincipal $AppId
    $appSPId = $appSP.id

    $appFilter = "clientId eq '$appSPId'"
    $filterClauses = @($appFilter)

    if ( ! $AllConsent.IsPresent ) {
        $grantFilter = if ( $Tenant.IsPresent ) {
            "consentType eq 'AllPrincipals'"
        } elseif ( $Principal ) {
            "consentType eq 'Principal' and principalId eq '$Principal'"
        }

        $filterClauses += $grantFilter
    }

    $filter = $filterClauses -join ' and '

    $filterArgument = @{ ODataFilter = $filter }

    $grants = Invoke-GraphRequest /oauth2PermissionGrants -method GET -ODataFilter $filter -version $::.GraphApplicationRegistration.DefaultApplicationApiVersion

    if ( $grants | gm id ) {
        $grants | foreach {
            if ( ! $permissions ) {
                Invoke-GraphRequest "/oauth2PermissionGrants/$($_.id)" -method DELETE -version $::.GraphApplicationRegistration.DefaultApplicationApiVersion | out-null
            } else {
                $reducedPermissions = GetReducedPermissionsString $_.scope $permissions
                if ( $reducedPermissions ) {
                    $updatedScope = @{scope = $reducedPermissions}
                    Invoke-GraphRequest "/oauth2PermissionGrants/$($_.id)" -method PATCH -body $updatedScope -version $::.GraphApplicationRegistration.DefaultApplicationApiVersion | out-null
                } else {
                    write-verbose "Requested permissions were not present in existing grant, no change is necessary, skipping update for grant id='$($_.id)'"
                }
            }
        }
    }
}
