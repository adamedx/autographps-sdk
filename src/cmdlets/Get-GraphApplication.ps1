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

. (import-script common/ApplicationHelper)


<#
.SYNOPSIS
Gets Azure Active Directory (AAD) application resources from the Graph API.

.DESCRIPTION
An Azure Active Directory (AAD) application object is required for software to be able to request an access token to access resources protected by AAD. The Get-GraphApplication returns all such AAD applications in the organizaiton accessible to the command's identity based on input specified to the command.

.PARAMETER AppId
Specify the AppId parameter to return the application in the organization with the specified application identifier.

.PARAMETER ObjectId
Specify the ObjectId parameter to return the application in the organizaiton with the specified directory object identifier.

.PARAMETER Filter
Specify the Filter parameter to return all applications that match the specified OData filter.

.PARAMETER Tags
Specify Tags parameter to filter for only those applications with a Tags property that contains at least one of the values specified to the Tags parameter. Tags are user-defined strings associated with the application to categorize its purpose, origin, or other important information.

.PARAMETER Name
Specify the Name parameter to return the application with the display name propert that matches this parameter exactly.

.PARAMETER RawContent
Specify the RawContent parameter to emit the applications as JSON rather than objects.

.PARAMETER All
Specify the All parameter to return all objects in the organization accessible to the identity executing the command.

.PARAMETER Connection
Specify the Connection parameter to use an alternative connection to the current connection.

.OUTPUTS
The command returns the application objects from the Graph API that satisfy the parameters to the command. The objects are Graph API application resources and have the structure documented for those resources in the Graph API documentation.

If the command cannot find an application that matches the input parameters, no error occurs but there is no output.

.EXAMPLE
Get-GraphApplication a5ebc719-fee5-4eb8-963c-4f1cf24ae813

AppId                                DisplayName        CreatedDateTime       Id
-----                                -----------        ---------------       --
a5ebc719-fee5-4eb8-963c-4f1cf24ae813 Backup Application 4/30/2018 23:03:41 AM 457904dc-6be4-4f21-8f9f-bfd2562ae453

In this example, the AppId parameter is specified as a positional parameter to return an application with a specific application identifier, and the result is emitted as output to the console. Since application identifiers are unique to a single application, only one application object will be returned when the AppId parameter is used.

.EXAMPLE
$backupApps = Get-GraphApplication -Name 'Backup Application'

The Name parameter is used here to search for an application by display name. Because application display names are not unique, there may be more than one application returned when the Name parameter is specified.


.LINK
New-GraphApplication
Register-GraphApplication
Remove-GraphApplication
Set-GraphApplicationCertificate
Get-GraphApplicationConsent
Set-GraphApplicationConsent
#>
function Get-GraphApplication {
    [cmdletbinding(defaultparametersetname='appid', supportspaging=$true, positionalbinding=$false)]
    [OutputType('AutoGraph.Application')]
    param (
        [parameter(position=0, parametersetname='appid', valuefrompipelinebypropertyname=$true)]
        [parameter(position=0, parametersetname='objectid', valuefrompipelinebypropertyname=$true)]
        $AppId,

        [parameter(parametersetname='objectid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        $ObjectId,

        [parameter(parametersetname='odatafilter', mandatory=$true)]
        $Filter,

        [parameter(parametersetname='tags', mandatory=$true)]
        [string[]] $Tags,

        [parameter(parametersetname='name', mandatory=$true)]
        $Name,

        [switch] $RawContent,

        [parameter(parametersetname='All')]
        [parameter(parametersetname='Odatafilter')]
        [parameter(parametersetname='tags')]
        [parameter(parametersetname='name')]
        [switch] $All,

        [PSCustomObject] $Connection = $null
    )

    begin {
        Enable-ScriptClassVerbosePreference

        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

        $targetFilter = if ( $Filter ) {
            $Filter
        } elseif ( $Tags ) {
            $tagFilters = @()
            foreach ( $tag in $Tags ) {
                $tagFilters += "tags/any(t:t eq '$tag')"
            }
            $tagFilters -join ' or '
        }
    }

    process {
        $result = $::.ApplicationHelper |=> QueryApplications $AppId $objectId $targetFilter $Name $RawContent $null $null $null $commandContext.connection $null $null $pscmdlet.pagingparameters.First $pscmdlet.pagingparameters.Skip $All.IsPresent

        $displayableResult = if ( $result ) {
            if ( $RawContent.IsPresent ) {
                $result
            } elseif ( $result | get-member id ) {
                $result | foreach {
                    $::.ApplicationHelper |=> ToDisplayableObject $_
                }
            }
        }

        if ( $displayableResult ) {
            $displayableResult
        } elseif ( $AppId ) {
            write-error "The specified application with application identifier '$AppId' could not be found."
        } elseif ( $ObjectId ) {
            write-error "The specified application with object identifier '$ObjectId' could not be found."
        }
    }

    end {
    }
}
