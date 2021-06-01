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
    [OutputType('AutoGraph.Certificate')]
    param (
        [parameter(parametersetname='appid', position=0, mandatory=$true)]
        [parameter(parametersetname='objectid', position=0, valuefrompipelinebypropertyname=$true)]
        [parameter(parametersetname='appidkeyId', position=0, mandatory=$true)]
        [parameter(parametersetname='objectidkeyId', position=0, valuefrompipelinebypropertyname=$true)]
        $AppId,

        [parameter(parametersetname='appid', valuefrompipelinebypropertyname=$true)]
        [parameter(parametersetname='objectid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='appidkeyId', valuefrompipelinebypropertyname=$true)]
        [parameter(parametersetname='objectidkeyId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        $AppObjectId,

        [parameter(parametersetname='appidkeyId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='objectidkeyId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $KeyId,

        [string] $Thumbprint = $null,

        [parameter(parametersetname='name', mandatory=$true)]
        $Name,

        [PSCustomObject] $Connection = $null
    )

    begin {
        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
    }

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

        $app = $::.ApplicationHelper |=> QueryApplications $targetAppId $targetObjectId $null $null $null $null $null $null $commandContext.connection id, appId, keyCredentials

        $keyCredentials = if ( $app ) {
            $targetAppId = $app.appId
            $targetObjectId = $app.id
            $app | select -expandproperty KeyCredentials -erroraction ignore
        }

        $keyCredentials | where type -eq 'AsymmetricX509Cert' | foreach {
            if ( ! $KeyId -or $_.keyId -eq $KeyId ) {
                if ( ! $Thumbprint -or $_.customKeyIdentifier -eq $Thumbprint ) {
                    $::.ApplicationHelper |=> KeyCredentialToDisplayableObject $_ $targetAppId $targetObjectId
                }
            }
        } | sort-object NotAfter
    }

    end {}
}

