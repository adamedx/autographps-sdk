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
Deletes an application object from an Entra ID organization.

.DESCRIPTION
An Entra ID application object is required for software to be able to request an access token to access resources protected by Entra ID. The Remove-GraphApplication command deletes the application object from the tenant in which it is hosted. Any software that uses service principals associated with the application object will fail requests for access tokens after Remove-GraphApplication is invoked successfully for the application. To execute the command, the user must be signed in to the organizaiton that hosts the application -- for single-tenant applications, this is the same organization in which the application is used to request access tokens. For multi-tenant applications, once the application is deleted in the hosting tenant, any software still using that application's identity inside the hosting tenant as well as outside of it will be impacted and will no longer be able to requeset access tokens. For this reason, exercise caution when deleting an multi-tenant application by collaborating with administrators in any other tenants using the application to ensure they are no longer dependent on the application once it is deleted.

Note that the user invoking the Remove-GraphApplication command must be an owner of the application in order to delete it, must be part of a role with access to delete applications such as an application or global administrator, or must otherwise have been granted application permissions required for deletion of applications as documented in the Graph API Permissions Reference (https://docs.microsoft.com/en-us/graph/permissions-reference).

The Remove-GraphApplication command performs a destructive operation, so ensure that you are signed in to the correct organization when executing it and that you are passing it the parameters for the correct application to delete. If you delete an application by mistake, you may be able to recover it using the Graph API's deleted items restore functionality: https://docs.microsoft.com/en-us/graph/api/directory-deleteditems-restore?view=graph-rest-1.0&tabs=http.

.PARAMETER AppId
The AppId of the application to delete.

.PARAMETER ObjectId
The ObjectId of the application to delete.

.PARAMETER Connection
The Graph API connection to use when accessing the organization from which the application must be deleted.

.OUTPUTS
This command produces no output.

.EXAMPLE
Remove-GraphApplication 768a385d-be51-4e78-bbf6-e1655e605a65

This command deletes the application with application ID 768a385d-be51-4e78-bbf6-e1655e605a65.

.EXAMPLE
Remove-GraphApplication 3f12c2bf-95fa-4c30-9747-645bcd212de2

This command deletes the application with object ID 3f12c2bf-95fa-4c30-9747-645bcd212de2.

.EXAMPLE
Get-GraphApplication -Filter "startswith(displayName, 'testapp')" | Remove-GraphApplication -Confirm:$false

In this example, multiple applications returned by the Get-GraphApplication command are removed without a confirmation. This is useful in background automation scripts, such as cleaning up "temporary" applications created as part of a continuous integration pipeline for instance.

.LINK
New-GraphApplication
Get-GraphApplication
Remove-GraphApplicationConsent
Unregister-GraphApplication
#>
function Remove-GraphApplication {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='High', positionalbinding=$false)]
    param(
        [parameter(position=0, parametersetname='FromAppId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='FromObjectId', valuefrompipelinebypropertyname=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='FromObjectId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        [Guid] $ObjectId,

        [PSCustomObject] $Connection = $null
    )

    begin {
        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version
    }

    process {
        Enable-ScriptClassVerbosePreference

        $targetAppId = $AppId
        $appObjectId = $null

        if ( $ObjectId ) {
            $appObjectId = $ObjectId
        } elseif ( $AppId ) {
            try {
                [Guid] $AppId | out-null
            } catch {
                throw [ArgumentException]::new("The specified App Id '$AppId' is not a valid guid")
            }

            $appObject = $appAPI |=> GetApplicationByAppId $AppId

            if ( ! $appObject -or ! ( $appObject | gm id -erroraction silentlycontinue ) ) {
                throw "Application with appid '$AppId' not found"
            }

            $appObjectId = $appObject.id
        }

        $targetAppDescription = if ( $targetAppId ) {
            $targetAppId
        } else {
            'Unspecified App ID'
        }

        if ( $pscmdlet.shouldprocess("Application ID = '$targetAppDescription', Object ID = '$appObjectId'", 'DELETE') ) {
            $appAPI |=> RemoveApplicationByObjectId $appObjectId
        }
    }

    end {}
}
