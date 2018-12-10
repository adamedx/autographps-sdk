# Copyright 2018, Adam Edwards
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

. (import-script ../cmdlets/Invoke-GraphRequest)
. (import-script ../graphservice/GraphApplicationRegistration)
. (import-script common/ApplicationHelper)

function Get-GraphApplicationCertificate {
    [cmdletbinding(defaultparametersetname='appid', positionalbinding=$false)]
    param (
        [parameter(parametersetname='appid', position=0, mandatory=$true)]
        [parameter(parametersetname='NewConnectionAppId', mandatory=$true)]
        [parameter(parametersetname='ExistingConnectionAppId', mandatory=$true)]
        $AppId,

        [parameter(parametersetname='name', mandatory=$true)]
        [parameter(parametersetname='NewConnectionName', mandatory=$true)]
        [parameter(parametersetname='ExistingConnectionName', mandatory=$true)]
        $Name,

        [switch] $RawContent,

        [String] $Version = $null,

        [parameter(parametersetname='NewConnection')]
        [parameter(parametersetname='NewConnectionAppId')]
        [parameter(parametersetname='NewConnectionName')]
        [parameter(parametersetname='NewConnectionFromApp')]
        [String[]] $Permissions = $null,

        [parameter(parametersetname='NewConnection')]
        [parameter(parametersetname='NewConnectionAppId')]
        [parameter(parametersetname='NewConnectionName')]
        [parameter(parametersetname='NewConnectionFromApp')]
        [GraphCloud] $Cloud = [GraphCloud]::Public,

        [parameter(parametersetname='ExistingConnection', mandatory=$true)]
        [parameter(parametersetname='ExistingConnectionAppId', mandatory=$true)]
        [parameter(parametersetname='ExistingConnectionName', mandatory=$true)]
        [parameter(parametersetname='ExistingConnectionFromApp', mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [parameter(parametersetname='FromApp', valuefrompipeline=$true, mandatory=$true)]
        [parameter(parametersetname='ExistingConnectionFromApp', valuefrompipeline=$true, mandatory=$true)]
        [object[]]
        $Application
    )

    begin {}

    process {
        $targetAppId = if ( $Application ) {
            $appIdProperty = if ( $Application | gm appid -erroraction silentlycontinue ) {
                $Application.AppId
            }

            if ( ! $appIdProperty ) {
                throw [ArgumentException]::new("Specified pipeline object is not a valid application object")
            }

            $appIdProperty
        } else {
            $AppId
        }

        $keyCredentials = $::.ApplicationHelper |=> QueryApplications $targetAppId $null $null $null $RawContent $version $permissions $Cloud $connection keyCredentials

        if ( ! $RawContent.IsPresent ) {
            $keyCredentials | select -expandproperty keycredentials | foreach {
                $::.ApplicationHelper |=> KeyCredentialToDisplayableObject $_ $targetAppId
            } | sort NotAfter
        } else {
            $keyCredentials
        }
    }

    end {}
}
