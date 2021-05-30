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

function Remove-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='High', positionalbinding=$false)]
    param(
        [parameter(parametersetname='AppIdFromUniqueId', position=0, mandatory=$true)]
        [parameter(parametersetname='AppIdFromThumbprint', position=0, mandatory=$true)]
        [parameter(parametersetname='AppIdAllCertificates', position=0, mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='ObjectIdFromUniqueId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='ObjectIdFromThumbprint', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='ObjectIdAllCertificates', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        [Guid] $AppObjectId,

        [parameter(parametersetname='AppIdFromUniqueId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='ObjectIdFromUniqueId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $KeyId,

        [parameter(parametersetname='AppIdFromThumbprint', position=1, mandatory=$true)]
        [parameter(parametersetname='ObjectIdFromThumbprint', position=1, mandatory=$true)]
        $Thumbprint = $null,

        [parameter(parametersetname='AppIdAllCertificates', mandatory=$true)]
        [parameter(parametersetname='ObjectIdAllCertificates', mandatory=$true)]
        [switch] $AllCertificates,

        [PSCustomObject] $Connection = $null
    )

    # Note that PowerShell requires us to use the begin / process / end structure here
    # in order to process more than one element of the pipeline via $App

    begin {
        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version
        $appToCredentials = @()
    }

    process {
        Enable-ScriptClassVerbosePreference

        $remainingCredentials = $null

        $targetObjectId = if ( $AppObjectId ) {
            $AppObjectId
        } elseif ($AppId ) {
            $appAPI |=> GetApplicationByAppId $AppId | select -expandproperty id
        } else {
            throw "Unexpected argument -- an app id or object id must be specified"
        }

        if ( ! $AllCertificates.IsPresent ) {
            $keyClientFilter = if ( $KeyId ) {
                { $_.KeyId -eq $KeyId }
            } elseif ( $Thumbprint ) {
                { $_.CustomKeyIdentifier -eq $Thumbprint }
            } else {
                throw [ArgumentException]::new("An AppId with Thumbprint or KeyId was not specified or AllCertificates was not specified")
            }

            $keyCredentials = $::.ApplicationHelper |=> QueryApplications $null $targetObjectId $null $null $null $commandContext.version $null null $commandContext.connection keyCredentials |
              select -expandproperty keyCredentials

            $keyToRemove = if ( ! $keyCredentials -and ! ($keyCredentials | gm id -erroraction ignore ) ) {
                throw [ArgumentException]::new("No certificates could be found for AppId '$AppId'")
            } else {
                $keyCredentials | where $keyClientFilter
            }

            if ( ! $keyToRemove ) {
                throw [ArgumentException]::new("The specified certificate could not be found for AppId '$AppId'")
            }

            $remainingCredentials = $keyCredentials | where KeyId -notin $keyToRemove.keyId
        }

        if ( $remainingCredentials -eq $null ) {
            $remainingCredentials = @()
        }

        $appToCredentials += @{
            AppObjectId = $targetObjectId
            RemainingCredentials = $remainingCredentials
        }
    }

    end {
        foreach ( $appCredential in $appToCredentials ) {
            $appAPI |=> SetKeyCredentials $appCredential.AppObjectId $appCredential.remainingCredentials
        }
    }
}

