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
. (import-script common/CommandContext)

<#
.SYNOPSIS
Removes application registration information from the current connection's organization so that the application can no longer be used in the organization.

.DESCRIPTION
In order for an access token to be issued for a given application, that application must be registered in the organization, i.e. it must have a service principal associated with it in the organization. If that registration information exists, it can be removed to stop the issuance of new tokens for that applications, thus blocking the usage of the application in that organization. The Unregister-GraphApplication command removes the registration information. Once it has been invoked successfully for an application, that application may no longer be used in that organization.

Note that unregistering an application does *NOT* delete the application, it merely remvoes the information that allows it to be issued an access token, i.e. unregistering removes the application's service principal, not the application. To delete the application, sign in to the organization that hosts the application and use the Remove-GraphApplication command or other tools to delete the actual application.

To re-register an application that has been unregistered using Unregister-GraphApplication, use the Register-GraphApplication command.

.PARAMETER AppId
The AppId of the application to unregister.

.PARAMETER Connection
The Graph connection to use when communicating with Graph to unregister the application.

.OUTPUTS
This command produces no output.

.EXAMPLE
Unregister-GraphApplication f5606706-dbbb-40bd-be31-ec92697ecdf1

This command deletes the service principal for the application f5606706-dbbb-40bd-be31-ec92697ecdf1.

.EXAMPLE
Get-GraphApplication -Name PreviewMailApp | Unregister-GraphApplication

In this example, the application to be unregistered is supplied to Unregister-GraphApplication using the pipeline.

.LINK
Register-GraphApplication
Remove-GraphApplicationConsent
Get-GraphApplication
Get-GraphApplicationServicePrincipal
Get-GraphApplicationConsent
Set-GraphApplicationConsent
New-GraphApplication
Remove-GraphApplication
#>
function Unregister-GraphApplication {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, valuefrompipelinebypropertyname = $true, mandatory=$true)]
        [string] $AppId,

        [PSCustomObject] $Connection = $null
    )
    Enable-ScriptClassVerbosePreference

    $commandContext = new-so CommandContext $Connection v1.0 $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
    $appAPI = new-so ApplicationAPI $commandContext.Connection $commandContext.Version

    $appSP = $appAPI |=> GetAppServicePrincipal $AppId

    if ( $appSP ) {
        write-verbose "Found service principal '$($appSP.id)' for application '$AppId'"
        $commandContext |=> InvokeRequest -uri "servicePrincipals/$($appSP.id)" -RESTMethod DELETE | out-null
    } else {
        throw "Unable to find service principal application registration object for app id '$AppId'"
    }
}

