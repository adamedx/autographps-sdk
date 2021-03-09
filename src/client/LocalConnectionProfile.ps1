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

. (import-script LocalSettings)

ScriptClass LocalConnectionProfile {
    $connectionData = $null
    $endpointData = $null
    $knownCloud = $null
    $customGraphUri = $null
    $customAuthUri = $null
    $customResourceUri = $null

    function __initialize($connectionData, $endpointData) {
        $endpointName = if ( $endpointData ) {
            $endpointData['name']
        }

        $referencedEndpoint = if ( $connectionData ) {
            $connectionData['graphEndpoint']
        }

        if ( $referencedEndpoint ) {
            if ( $::.GraphEndpoint |=> IsWellKnownCloud $referencedEndpoint ) {
                $this.knownCloud = $referencedEndpoint
            } elseif ( ! $endpointName -and ! ( $::.GraphEndpoint |=> IsWellKnownCloud $referencedEndpoint ) ) {
                throw "Connection profile endpoint '$referencedEndpoint' did not match the specified endpoint name '$endpointName'"
            } else {
                $this.customGraphUri = $this.endpointData['graphUri']
                $this.customResourceUri = $this.endpointData['resourceUri']
                if ( ! $this.customResourceUri ) {
                    $this.customResourceUri = $this.customGraphUri
                }

                $this.customAuthUri = $this.endpointData['authUri']
            }
        }

        $this.connectionData = $connectionData
        $this.endpointData = $endpointData
    }

    function ToConnectionParameters([string[]] $permissions, $allowMSA) {
        $parameters = @{}
        $enabledParameter = [System.Management.Automation.SwitchParameter]::new($true)

        if ( $this.connectionData ) {
            if ( $this.connectionData['accountType'] ) { $parameters['AccountType'] = $this.connectionData['accountType'] }
            if ( $this.connectionData['userAgent'] ) { $parameters['UserAgent'] = $this.connectionData['userAgent'] }
            if ( $this.connectionData['appId'] ) { $parameters['AppId'] = $this.connectionData['appId'] }
            if ( $this.connectionData['appRedirectUri'] ) { $parameters['appRedirectUri'] = $this.connectionData['appRedirectUri'] }
            if ( $this.connectionData['confidential'] ) {
                $parameters['Confidential'] = $enabledParameter
                if ( $this.connectionData['authType'] -eq 'appOnly' ) {
                    $parameters['NoninteractiveAppOnlyAuth'] = $enabledParameter
                }

                $appCredentials = $this.connectionData['appCredentials']

                if ( $appCredentials ) {
                    if ( $appCredentials['tenantId'] ) {
                        $parameters['TenantId'] = $appCredentials['tenantId']
                    }

                    if ( $appCredentials['certificatePath'] ) {
                        $parameters['CertificatePath'] = $appCredentials['certificatePath']
                    }
                }
            }
            if ( $this.knownCloud ) {
                $parameters['Cloud'] = $this.knownCloud
            } elseif ( $this.customGraphUri ) {
                $parameters['GraphEndpointUri'] = $this.customGraphUri
                $parameters['GraphResourceUri'] = $this.customResourceUri
                if ( $this.customAuthUri ) {
                    $parameters['AuthenticationEndpointUri'] = $this.customAuthUri
                }
            }
        if ( $this.connectionData['authProtocol'] ) { $parameters['AuthProtocol'] = $this.connectionData['authProtocol'] }

        if ( ! $parameters['NoninteractiveAppOnlyAuth'] -and $permissions ) {
            $parameters['Permissions'] = $permissions }
        }

        $parameters
    }

    function ToConnectionData {
    }

    static {

        $endpointPropertyReaders = @{
            name = @{ Validator = 'NameValidator'; Required = $true }
            graphUri = @{Validator = 'UriValidator'; Required = $true}
            authUri = @{Validator = 'UriValidator'; Required = $true}
            resourceUri = @{Validator = 'UriValidator'; Required = $false}
        }

        $connectionPropertyReaders = @{
            name = @{ Validator = 'NameValidator'; Required = $true }
            appId = @{ Validator = 'GuidStringValidator'; Required = $false }
            authType = @{ Validator = 'StringValidator'; Required = $false }
            accountType = @{ Validator = 'StringValidator'; Required = $false }
            authProtocol = @{ Validator = 'StringValidator'; Required = $false }
            userAgent = @{ Validator = 'StringValidator'; Required = $false }
            appRedirectUri = @{ Validator = 'UriValidator'; Required = $false }
            confidential = @{ Validator = 'BooleanValidator'; Required = $false }
            appCredentials = @{ Validator = 'AppCredentialValidator'; Required = $false }
            graphEndpoint = @{ Validator = 'EndpointValidator'; Required = $false }
        }

        function __initialize {
            __RegisterSettingProperties
        }

        function __RegisterSettingProperties {
            $::.LocalSettings |=> RegisterSettingProperties graphEndpoints $this.endpointPropertyReaders
            $::.LocalSettings |=> RegisterSettingProperties connectionProfiles $this.connectionPropertyReaders
        }
    }
}

$::.LocalConnectionProfile |=> __initialize
