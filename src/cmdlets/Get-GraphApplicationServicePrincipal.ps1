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
Gets service principal objects for the organization.

.DESCRIPTION
Every Entra ID application that that can be used to access resources in an Entra ID organization has one associated service principal object in the directory. The Get-GraphApplicationServicePrincipal can be used to obtain the service principal objects for Entra ID applications. The command's parameters determine whether the service principal for a specific application is retrieved or whether multiple service principals are retrieved.

Get-GraphApplicationServicePrincipal supports common paging parameters including First and Skip for managing variable size result sets.

The service principal object for a given application may be used to find organization-specific configuration for that application including permissions granted or "consented" to the application.

See the Register-GraphApplication command for more information on how service principals are created or "registered" in an organization.

For more information about permissions and consent, see the Set-GraphApplicationConsent command documentation.

.PARAMETER AppId
The AppId parameter specifies the application identifier of the application for which to obtain the service principal object.

.PARAMETER Filter
An OData filter that can be used to return multiple service principals based on arbitrary properties of service principal objects such as their displayName, tags, or replyUrls properties.

.PARAMETER Descending
By default, when the Filter parameter is used, service principals are returned in sorted order according to their id property (the Entra ID object id). Specify the Descending parameter to reverse the order. This is useful when the command returns multiple results and you are using the paging parameters First and Skip.

.PARAMETER Select
By default, Get-GraphApplicationServicePrincipal returns service principal objects with a large set of properties. To reduce the amount of data transferred from the Graph API to only the necessary properties, specify the Select parameter with the names of the properties to be returned; the returned objects will be limited to just those properties. If there are some properties that are not returned by default, those properties may be specified so that they are returned by the command.

.PARAMETER Expand
Use the Expand parameter to include objects related to the service principal as child objects of each service principal. Related objects are specified by relationship member names including owners, appRoleAssignments, transitiveMemberOf, and many more. See the Graph API documentation for the service principal for details on the relationships accessible from the service principal object.

.PARAMETER All
By default, a maximum limit of service principal objects will be returned when the Filter parameter is specified; the paging parameters First and Skip must be used with additional command invocations to make repeated requests for sequential subsets of the query results. To obtain all service principal objects with a single invocatio of Get-GraphApplicationServicePrincipal, specify the All parameter.

.PARAMETER ConsistencyLevel
Specifies the Entra ID consistency level applied for queries when the Filter parameter is specified. See the documentation for Get-GraphResource for details of the ConsistencyLevel parameter.

.PARAMETER Connection
Specifies the connection to use to access the Graph API as an alternative to the current connection. The connection encapsulates the identity used to access the Graph API. See the Get-GraphResource command documentation for more information on the Connection parameter.

.OUTPUTS
Get-GraphApplicationServicePrincipal returns the service principal objects that satisfy the input parameters.

.EXAMPLE
Get-GraphApplicationServicePrincipal -AppId 01cfea12-f6ee-4044-ac1f-b386fc2751a4

AppId                                DisplayName        CreatedDateTime      Id
-----                                -----------        ---------------      --
01cfea12-f6ee-4044-ac1f-b386fc2751a4 Picture Backup App 4/27/2021 9:14:36 PM 35edf11f-e713-420b-9da2-6f342d382f4b

In this example, the service principal for the application with identifier 01cfea12-f6ee-4044-ac1f-b386fc2751a4 specified as the value of the AppId parameter is emitted.

.EXAMPLE
$servicePrincipals = Get-GraphApplication | Get-GraphApplicationServicePrincipal -ErrorAction SilentlyContinue

In this example, all the organization's applications are enumerated using Get-GraphApplication, and the output is emitted to Get-GraphApplicationServicePrincipal, which returns the service principal for each application it can find. The ErrorAction parameter is specified with the value SilentlyContinue so that the failure to find a service principal does not produce error output. This is necessary since the creation of an application by itself does not create an application; a separate registration step must be invoked in the organization for the service principal to exist.

.EXAMPLE
$directoryReadWritePermissionId = Find-GraphPermission -Exact Directory.ReadWrite.All -PermissionType AppOnly |
    Select-Object -ExpandProperty id
Get-GraphApplicationServicePrincipal -Expand appRoleAssignments -All |
    Where-Object { $_.AppRoleAssignments.appRoleId -contains $directoryPermissionId }

AppId                                DisplayName   CreatedDateTime      Id
-----                                -----------   ---------------      --
9dca3f68-3c8e-4525-87d8-96f7e89c7139 Doc Backup    6/4/2021 6:31:37 AM  05590861-4c1b-4246-b52c-91673bc6ced4
782e117a-a814-4dd1-97b8-1f970b892e5a Group Monitor 5/31/2021 2:43:29 AM 105969dd-e2fe-45f6-b6a8-918693cabf1b
08224502-5867-42e4-8a3c-0230912a1ea3 LifeGame      6/13/2021 8:07:35 AM 140e2929-f047-4beb-8380-7e9de80bc14b

This example shows how all service principals that have been granted the permission Directory.ReadWrite.All may be retrieved. Here all service principals in the organization are retrieved using Get-GraphApplicationServicePrincipal. However, the Expand parameter is specified with the appRoleAssignments property -- this causes the appRoleAssignment id references to be "expanded" from guid data types to the entire appRoleAssignment resource objects they reference. This allows the output of Get-GraphApplicationServicePrincipal to be filtered by the Where-Object command on the appRoleAssignments property. The script block specified to Where-Object filters the results by looking for the Directory.ReadWrite.All permission id in the appRoleAssignments property. The permission id for Directory.ReadWrite.All is obtained using the Find-GraphPermission command which can translate permissions to identifiers.

.LINK
Set-GraphApplicationConsent
New-GraphApplication
Register-GraphApplication
Unregister-GraphApplication
#>
function Get-GraphApplicationServicePrincipal {
    [cmdletbinding(positionalbinding=$false, supportspaging=$true)]
    [OutputType('AutoGraph.ServicePrincipal')]
    param(
        [parameter(parametersetname = 'appid', position=0, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='query')]
        [string] $Filter,

        [parameter(parametersetname='query')]
        [Switch] $Descending,

        [parameter(parametersetname='query')]
        [Alias('Property')]
        [string[]] $Select,

        [parameter(parametersetname='query')]
        [string[]] $Expand,

        [parameter(parametersetname='query')]
        [switch] $All,

        [parameter(parametersetname='query')]
        [ValidateSet('Auto', 'Default', 'Session', 'Eventual')]
        [string] $ConsistencyLevel = 'Auto',

        [PSCustomObject] $Connection = $null
    )

    begin {
        Enable-ScriptClassVerbosePreference

        $commandContext = new-so CommandContext $Connection v1.0 $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.Connection v1.0

        $results = @()
    }

    process {
        if ( $AppId ) {
            $appSP = $appAPI |=> GetAppServicePrincipal $AppId

            if ( ! $appSP ) {
                write-error "Unable to find service principal application registration object for app id '$AppId'"
            }

            $results += $appSP
        } else {
            # Note that sorting is not supported as the API does not currently support
            # sorting even with eventual consistency :(

            $requestArguments = @{
                Filter = $Filter
                Select = $Select
                Expand = $Expand
                Descending = $Descending
                ConsistencyLevel = $ConsistencyLevel
                All = $All
                First = $pscmdlet.pagingparameters.First
                Skip = $pscmdlet.pagingparameters.Skip
            }

            $results = Invoke-GraphApiRequest @requestArguments -Uri /servicePrincipals
        }
    }

    end {
        foreach ( $servicePrincipal in $results ) {
            $servicePrincipal.pstypenames.insert(0, 'AutoGraph.ServicePrincipal')
            $servicePrincipal
        }
    }
}

