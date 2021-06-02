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

        [parameter(parametersetname='name', mandatory=$true)]
        $Name,

        [switch] $RawContent,

        [parameter(parametersetname='All')]
        [switch] $All,

        [Alias('Connection')]
        [PSCustomObject] $ConnectionInfo = $null
    )

    begin {
        Enable-ScriptClassVerbosePreference

        $Connection = if ( $ConnectionInfo ) {
            $ConnectionInfo.Connection
        }

        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
    }

    process {
        $result = $::.ApplicationHelper |=> QueryApplications $AppId $objectId $Filter $Name $RawContent $null $null $null $commandContext.connection $null $null $pscmdlet.pagingparameters.First $pscmdlet.pagingparameters.Skip $All.IsPresent

        $displayableResult = if ( $result ) {
            if ( $RawContent.IsPresent ) {
                $result
            } elseif ( $result | gm id ) {
                $result | sort-object displayname | foreach {
                    $::.ApplicationHelper |=> ToDisplayableObject $_
                }
            }
        }

        if ( ! $displayableResult -and ( $AppId -and $ObjectId ) ) {
            throw "The specified application could not be found."
        }
    }

    end {
        $displayableResult
    }
}
