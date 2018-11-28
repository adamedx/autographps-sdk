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

function Get-GraphApplicationConsent {
    param(
        [parameter(position=0, mandatory=$true)]
        $AppId,

        [parameter(parametersetname='entiretenant')]
        [switch] $Tenant,

        [parameter(parametersetname='specificprincipal', mandatory=$true)]
        $Principal
    )

    $app = try {
        $::.GraphApplicationRegistration |=> GetApplicationByAppId $AppId
    } catch {
        throw [Exception]::new("Unable to find application with AppId '$AppId'", $_.exception)
    }

    $appSP = try {
        $::.GraphApplicationRegistration |=> GetAppServicePrincipal $AppId
    } catch {
        throw [Exception]::new("Unable to find a service prinicpal for application with AppId '$AppId', the application may not yet have been accessed in this tenant", $_.exception)
    }

    $appSPId = $appSP.id

    $appFilter = "clientId eq '$appSPId'"
    $filterClauses = @($appFilter)

    $grantFilter = if ( $Tenant.IsPresent ) {
        "consentType eq 'AllPrincipals'"
    } elseif ( $Principal ) {
        "consentType eq 'Principal' and 'principalId' eq '$Principal'"
    }

    if ( $grantFilter ) {
        $filterClauses += $grantFilter
    }

    $filter = $filterClauses -join ' and '

    $filterArgument = @{ ODataFilter = $filter }

    $response = Invoke-GraphRequest /oauth2PermissionGrants -method GET -ODataFilter $filter -version $::.GraphApplicationRegistration.DefaultApplicationApiVersion

    if ( $response | gm id -erroraction silentlycontinue ) {
        $response
    }
}
