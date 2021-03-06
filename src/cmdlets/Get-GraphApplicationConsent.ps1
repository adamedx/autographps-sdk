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

. (import-script Invoke-GraphApiRequest)
. (import-script ../graphservice/ApplicationAPI)
. (import-script common/ConsentHelper)
. (import-script common/CommandContext)

function Get-GraphApplicationConsent {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='TenantOrSpecificPrincipal')]
    param(
        [parameter(position=0, valuefrompipelinebypropertyname = $true, mandatory=$true)]
        [Guid[]] $AppId,

        [parameter(parametersetname='entiretenant', mandatory=$true)]
        [parameter(parametersetname='TenantOrSpecificPrinicpal')]
        [switch] $Tenant,

        [switch] $RawContent,

        [parameter(parametersetname='specificprincipal', mandatory=$true)]
        [parameter(parametersetname='TenantOrSpecificPrinicpal')]
        $Principal
    )

    begin {}

    process {
        Enable-ScriptClassVerbosePreference

        $commandContext = new-so CommandContext $null $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

        $app = try {
            $appAPI |=> GetApplicationByAppId $AppId
        } catch {
            throw [Exception]::new("Unable to find application with AppId '$AppId'", $_.exception)
        }

        $appSP = try {
            $appAPI |=> GetAppServicePrincipal $AppId
        } catch {
            throw [Exception]::new("Unable to find a service prinicpal for application with AppId '$AppId', the application may not yet have been accessed in this tenant", $_.exception)
        }

        if ( ! $appSP ) {
            write-verbose "Unable to find service principal for application '$AppId', assuming no consent exists"
        } else {

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

            $filterArgument = @{ Filter = $filter }

            $RawContentArgument = @{ RawContent = $RawContent }

            $response = Invoke-GraphApiRequest /oauth2PermissionGrants -method GET -Filter $filter -version $::.ApplicationAPI.DefaultApplicationApiVersion @RawContentArgument

            if ( $response ) {
                if ( ! $RawContent.IsPresent ) {
                    if ( $response | gm id -erroraction ignore ) {
                        $response | foreach {
                            $::.ConsentHelper |=> ToDisplayableObject $_
                        }
                    }
                } else {
                    $response
                }
            }

            $roleResponse = Invoke-GraphApiRequest /servicePrincipals/$appSPId/appRoleAssignedTo -method GET -version $::.ApplicationAPI.DefaultApplicationApiVersion @RawContentArgument

            if ( $roleResponse ) {
                if ( ! $RawContent.IsPresent ) {
                    if ( $roleResponse | gm id -erroraction ignore ) {
                        $roleResponse | foreach {
                            $::.ConsentHelper |=> ToDisplayableObject $_
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

