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

function Remove-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='High', positionalbinding=$false)]
    param(
        [parameter(parametersetname='FromUniqueId', position=0, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='FromUniqueIdExistingConnection', position=0, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='FromThumbprint', position=0, mandatory=$true)]
        [parameter(parametersetname='FromThumbprintExistingConnection', position=0, mandatory=$true)]
        [parameter(parametersetname='AllCertificatesExistingConnection', position=0, mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='FromUniqueId', position=1, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='FromUniqueIdExistingConnection', position=1, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $KeyId,

        [parameter(parametersetname='FromThumbprint', mandatory=$true)]
        [parameter(parametersetname='FromThumbprintExistingConnection', mandatory=$true)]
        $Thumbprint = $null,

        [parameter(parametersetname='AllCertificatesExistingConnection', mandatory=$true)]
        [switch] $AllCertificates,

        [String] $Version = $null,

        [parameter(parametersetname='FromUniqueIdExistingConnection', mandatory=$true)]
        [parameter(parametersetname='FromThumbprintExistingConnection', mandatory=$true)]
        [parameter(parametersetname='AllCertificatesExistingConnection')]
        [PSCustomObject] $Connection = $null
    )

    # Note that PowerShell requires us to use the begin / process / end structure here
    # in order to process more than one element of the pipeline via $App

    begin {
        throw [NotImplementedException]::new("This method is not yet implemented due to missing functionality in the Graph application API")

        $commandContext = new-so CommandContext $connection $version $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version
    }

    process {
        Enable-ScriptClassVerbosePreference

        $keyClientFilter = if ( $AllCertificates.IsPresent ) {
            { $true }
        } elseif ( $KeyId ) {
            { $_.KeyId -eq $KeyId }
        } elseif ( $Thumbprint ) {
            { $_.CustomKeyId -eq $Thumbprint }
        } else {
            throw [ArgumentException]::new("An AppId with Thumbprint or KeyId was not specified or AllCertificates was not specified")
        }

        $keyCredentials = $::.ApplicationHelper |=> QueryApplications $AppId $null $null $null $null $commandContext.version $null null $commandContext.connection keyCredentials |
          select -expandproperty keyCredentials

        $keyToRemove = if ( ! $keyCredentials -and ! ($keyCredentials | gm id -erroraction ignore ) ) {
            throw [ArgumentException]::new("No certificates could be found for AppId '$AppId'")
        } else {
            $keyCredentials | where $keyClientFilter
        }

        if ( ! $keyToRemove ) {
            throw [ArgumentException]::new("The specified certificate could not be found for AppId '$AppId'")
        }

        $remainingCredentials = $keyCredentials | where KeyId -ne $keyToRemove.keyId

        $appAPI |=> SetKeyCredentials $AppId $remainingCredentials
    }

    end {}
}

