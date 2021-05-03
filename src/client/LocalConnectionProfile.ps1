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

. (import-script LocalProfileSpec)
. (import-script LocalSettings)

ScriptClass LocalConnectionProfile {
    $connectionData = $null
    $endpointData = $null
    $knownCloud = $null
    $customGraphUri = $null
    $customAuthUri = $null
    $customResourceUri = $null
    $Name = $null

    function __initialize($connectionData, $endpointData) {
        $this.Name = if ( $connectionData ) {
            $connectionData['name']
        }

        $referencedEndpointName = if ( $connectionData ) {
            $connectionData[$::.LocalProfileSpec.EndpointProperty]
        }

        $targetEndpoint = if ( $referencedEndpointName -and $endpointData ) {
            $endpointData[$referencedEndpointName]
        }

        $isValid = $true

        if ( $referencedEndpointName ) {
            if ( $::.GraphEndpoint |=> IsWellKnownCloud $referencedEndpointName ) {
                $this.knownCloud = $referencedEndpointName
            } elseif ( ! $targetEndpoint -and ! ( $::.GraphEndpoint |=> IsWellKnownCloud $referencedEndpointName ) ) {
                $isValid = $false
                write-warning "The connection endpoint '$referencedEndpointName' specified in the settings configuration could not be found"
            } elseif ( $targetEndpoint ) {
                $this.customGraphUri = $targetEndpoint['graphUri']
                $this.customResourceUri = $targetEndpoint['resourceUri']
                if ( ! $this.customResourceUri ) {
                    $this.customResourceUri = $this.customGraphUri
                }

                $this.customAuthUri = $targetEndpoint['authUri']
            } else {
                $isValid = $false
            }
        }

        if ( $isValid ) {
            $this.connectionData = $connectionData
            $this.endpointData = $targetEndpoint
        }
    }

    function ToConnectionParameters([string[]] $permissions) {
        $parameters = @{}
        $enabledParameter = [System.Management.Automation.SwitchParameter]::new($true)
        $isAppOnly = $false

        if ( $this.connectionData ) {
            if ( $this.connectionData['accountType'] ) { $parameters['AccountType'] = $this.connectionData['accountType'] }
            if ( $this.connectionData['userAgent'] ) { $parameters['UserAgent'] = $this.connectionData['userAgent'] }
            if ( $this.connectionData['appId'] ) { $parameters['AppId'] = $this.connectionData['appId'] }
            if ( $this.connectionData['appRedirectUri'] ) { $parameters['appRedirectUri'] = $this.connectionData['appRedirectUri'] }
            $isConfidential = $this.connectionData['confidential'] -ne $null -or $this.connectionData['authType'] -eq 'appOnly'

            if ( $isConfidential ) {
                $parameters['Confidential'] = $enabledParameter
                if ( $this.connectionData['authType'] -eq 'appOnly' ) {
                    $isAppOnly = $true
                    $parameters['NoninteractiveAppOnlyAuth'] = $enabledParameter
                }

                if ( $this.connectionData['certificatePath'] ) {
                    $parameters['certificatePath'] = $this.connectionData['certificatePath']
                }
            }

            if ( $this.connectionData['tenantId'] ) {
                $parameters['TenantId'] = $this.connectionData['tenantId']
            }

            if ( $this.knownCloud ) {
                $parameters['Cloud'] = $this.knownCloud
            } elseif ( $this.customGraphUri ) {
                $parameters['GraphEndpointUri'] = $this.customGraphUri
                if ( $this.customResourceUri ) {
                    $parameters['GraphResourceUri'] = $this.customResourceUri
                } else {
                    $parameters['GraphResourceUri'] = $this.customGraphUri
                }

                if ( $this.customAuthUri ) {
                    $parameters['AuthenticationEndpointUri'] = $this.customAuthUri
                } else {
                    $parameters['AuthenticationEndpointUri'] = [Uri] 'https://login.microsoftonline.com'
                }
            }

            if ( $this.connectionData['authProtocol'] ) { $parameters['AuthProtocol'] = $this.connectionData['authProtocol'] }

            if ( ! $isAppOnly -and $parameters['authProtocol'] -ne 'v1' -and $this.connectionData['delegatedPermissions'] ) {
                $parameters['Permissions'] = $this.connectionData['delegatedPermissions']
            }

            if ( $this.connectionData['consistencyLevel'] ) {
                $parameters['ConsistencyLevel'] = $this.connectionData['consistencyLevel']
            }
        }

        if ( ! $parameters['NoninteractiveAppOnlyAuth'] -and $permissions ) {
            $parameters['Permissions'] = $permissions
        }

        if ( ! $parameters['tenantid'] ) {
            if ( $parameters['AuthProtocol'] -eq 'v1' ) {
                write-warning "A connection specifies an authProtocol property of 'v1' but does not specify a 'tenantid' property"
            }

            if ( $isAppOnly ) {
                write-warning "A connection specifies an 'authType' proproperty of 'appOnly' but does not specify a 'tenantId' property"
            }
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
            delegatedPermissions = @{ Validator = 'StringArrayValidator'; Required = $false }
            authType = @{ Validator = 'StringValidator'; Required = $false }
            accountType = @{ Validator = 'StringValidator'; Required = $false }
            authProtocol = @{ Validator = 'StringValidator'; Required = $false }
            userAgent = @{ Validator = 'StringValidator'; Required = $false }
            appRedirectUri = @{ Validator = 'UriValidator'; Required = $false }
            confidential = @{ Validator = 'BooleanValidator'; Required = $false }
            tenantId = @{ Validator = 'TenantValidator'; Required = $false }
            certificatePath = @{ Validator = 'CertificatePathValidator'; Required = $false }
            $::.LocalProfileSpec.EndpointProperty = @{ Validator = 'EndpointValidator'; Required = $false }
            consistencyLevel = @{ Validator = 'StringValidator'; Required = $false }
        }

        function __initialize {
            __RegisterSettingProperties
        }

        function __RegisterSettingProperties {
            $::.LocalSettings |=> RegisterSettingProperties $::.LocalProfileSpec.EndpointsCollection $this.endpointPropertyReaders $true
            $::.LocalSettings |=> RegisterSettingProperties $::.LocalProfileSpec.ConnectionsCollection $this.connectionPropertyReaders $true
        }
    }
}

$::.LocalConnectionProfile |=> __initialize
