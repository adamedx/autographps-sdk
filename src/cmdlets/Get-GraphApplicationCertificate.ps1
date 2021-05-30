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

Function Get-GraphApplicationCertificate {
    [cmdletbinding(defaultparametersetname='appid', positionalbinding=$false)]
    param (
        [parameter(parametersetname='appid', position=0, mandatory=$true)]
        [parameter(parametersetname='objectid', valuefrompipelinebypropertyname=$true)]
        $AppId,

        [parameter(parametersetname='appid', valuefrompipelinebypropertyname=$true)]
        [parameter(parametersetname='objectid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        $AppObjectId,

        [parameter(parametersetname='name', mandatory=$true)]
        $Name,

        [switch] $RawContent,

        [PSCustomObject] $Connection = $null
    )

    begin { }

    process {
        Enable-ScriptClassVerbosePreference

        $targetAppId = $AppId
        $targetObjectId = if ( $AppObjectId ) {
            $targetAppId = $null
            $AppObjectId
        }

        if ( ! $targetAppID -and ! $targetObjectId ) {
            throw "Unexpected argument -- an app id or object id must be specified"
        }

        $app = $::.ApplicationHelper |=> QueryApplications $targetAppId $targetObjectId $null $null $RawContent $null $null $null $connection id, appId, keyCredentials

        if ( $app -and ( $app | select -expandproperty KeyCredentials -erroraction ignore ) ) {
            if ( ! $RawContent.IsPresent ) {
                $app | select -expandproperty keycredentials | foreach {
                    $::.ApplicationHelper |=> KeyCredentialToDisplayableObject $_ $app.appId $app.id
                } | sort-object NotAfter
            } else {
                $app.keyCredentials
            }
        }
    }

    end {}
}

