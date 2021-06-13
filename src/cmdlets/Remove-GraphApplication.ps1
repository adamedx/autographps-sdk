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

. (import-script ../graphservice/ApplicationAPI)
. (import-script common/CommandContext)

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
