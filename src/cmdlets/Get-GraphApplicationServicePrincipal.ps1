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

function Get-GraphApplicationServicePrincipal {
    [cmdletbinding(positionalbinding=$false, supportspaging=$true)]
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

