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

. (import-script ../../graphservice/GraphEndpoint)

ScriptClass CommandContext {
    $version = $null
    $connection = $null

    function __initialize($Connection, $Version, $Permissions, $Cloud, $VersionDefault) {
        if ( $Connection ) {
            if ( $Cloud -or $Permissions ) {
                throw [ArgumentException]::new("Permissions or Cloud options may not be specified if a Connection is specified")
            }
        }

        $this.version = if ( $Version ) {
            $Version
        } elseif ( $VersionDefault ) {
            $VersionDefault
        }

        $this.connection = if ( $Connection ) {
            $Connection
        } else {
            $currentConnection = 'GraphContext' |::> GetConnection $null $null $cloud $permissions
            $currentConnection |=> Connect
            $currentConnection
        }
    }

    function InvokeRequest(
        $Uri,
        $RESTMethod,
        $Body,
        $Query,
        $OdataFilter,
        $Search,
        $Select,
        $Expand,
        $Descending,
        $RawContent,
        $AbsoluteUri,
        $Headers
    ) {
        $requestParameters = @{}

        $psboundparameters.keys | foreach {
            $requestParameters.Add($_, $psboundparameters[$_])
        }

        __NormalizeParameters $requestParameters

        Invoke-GraphRequest @requestParameters -version $this.version -connection $this.connection
    }

    function __NormalizeParameters([HashTable] $parameterTable) {
        # The method uses Uri instead of RelativeUri as the former
        # may be deprecated in the Invoke-GraphRequest cmdlet
        $uriParameterValue = $parameterTable['uri']

        if ( ! $uriParameterValue ) {
            throw [ArgumentException]::("Missing mandatory Uri parameter")
        }

        $parameterTable.Remove('uri')
        $parameterTable['RelativeUri'] = $uriParameterValue

        # Another workaround for scriptclass -- method name collision with method
        $methodParameterValue = $parameterTable['RESTMethod']

        if ( $methodParameterValue ) {
            $parameterTable.Remove('RESTMethod')
            $parameterTable['method'] = $methodParameterValue
        }

        # Due to issues in ScriptClass with switch parameters, we remove them
        # if they are not set to true
        $falseSwitchParameters = @()
        $parameterTable.keys | foreach {
            $parameterValue = $parameterTable[$_]
            if ( $parameterValue -is [System.Management.Automation.SwitchParameter] -and ! $parameterValue.IsPresent ) {
                $falseSwitchParameters += $_
            }
        }

        $falseSwitchParameters | foreach {
            $parameterTable.Remove($_)
        }
    }
}
