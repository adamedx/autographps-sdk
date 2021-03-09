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
. (import-script LocalConnectionProfile)
. (import-script ../cmdlets/New-GraphConnection)
. (import-script ../cmdlets/Set-GraphLogOption)

ScriptClass LocalProfile {
    $name = $null
    $connectionProfile = $null
    $profileData = $null
    $connectionData = $null
    $endpointData = $null
    $InitialApiVersion = $null
    $logLevel = $null

    function __initialize([HashTable] $profileData, [HashTable] $connectionData, [HashTable] $endpointData) {
        $this.profileData = $profileData
        $this.connectionData = $connectionData
        $this.endpointData = $endpointData

        $this.name = $profileData.name
        $this.InitialApiVersion = $profileData['initialApiVersion']
        $this.logLevel = $profileData['logLevel']
        $this.connectionProfile = $connectionProfile

        $this.connectionProfile = new-so LocalConnectionProfile $connectionData $endpointData
    }

    function ToConnection([string[]] $permissions, $allowMSA) {
        $parameters = ToConnectionParameters $permissions $allowMSA
        try {
            New-GraphConnection @parameters
        } catch {
            write-verbose $_.exception
        }
    }

    function ToConnectionParameters([string[]] $permissions, $allowMSA) {
        $this.connectionProfile |=> ToConnectionParameters $permissions $allowMSA
    }

    function ToJson {
    }

    static {
        $settings = $null
        $profiles = $null
        $defaultProfileName = $null
        $defaultSettingsPath = '~/.autographps/settings.json'
        $settingsLoadAttempted = $false
        $settingsPath = $null
        $settingsBypassed = $false
        $currentProfile = $null

        $propertyReaders = @{
            name = @{ Validator = 'NameValidator'; Required = $true }
            initialApiVersion = @{ Validator = 'StringValidator'; Required = $false }
            connectionProfile = @{ Validator = 'ConnectionValidator'; Required = $false }
            noBowserSigninUI = @{ Validator = 'BooleanValidator'; Required = $false }
            shellPromptBehavior = @{ Validator = 'StringValidator'; Required = $false }
            autoConnect = @{ Validator = 'BooleanValidator'; Required = $false }
            logLevel = @{ Validator = 'StringValidator'; Required = $false
                          Updater = {
                              $currentProfile = $::.LocalProfile |=> GetCurrentProfile
                              if ( $currentProfile -and $currentProfile.logLevel ) {
                                  Set-GraphLogOption -LogLevel $currentProfile.logLevel -erroraction ignore
                              }
                          }
                        }
        }

        function __initialize {
            __RegisterSettingProperties
        }

        function LoadProfiles {
            if ( $this.settings ) {
                $this.settings |=> Load

                $endpointData = $this.settings |=> GetSettings graphEndpoints
                $connectionData = $this.settings |=> GetSettings connectionProfiles $endpointData
                $profileData = $this.settings |=> GetSettings profiles $connectionData

                $this.profiles = if ( $profileData ) {
                    foreach ( $profileData in $profileData.values ) {
                        $normalizedData = __GetNormalizedProfileData $profileData $connectionData $endpointData
                        new-so LocalProfile $normalizedData.ProfileData $normalizedData.ConnectionProfileData $normalizedData.EndpointData
                    }
                }

                $this.defaultProfileName = $this.settings |=> GetSettingValue defaultProfile

                SetCurrentProfile $this.defaultProfileName

                $::.LocalSettings |=> RefreshBehaviorsFromSettings
            }
        }

        function GetProfiles {
            __LoadProfiles
            $this.profiles
        }

        function GetProfileByName($profileName) {
            __LoadProfiles
            if ( $this.profiles ) {
                $this.profiles | where name -eq $profileName
            }
        }

        function GetDefaultProfile {
            __LoadProfiles
            if ( $this.profiles ) {
                $this.profiles | where name -eq $this.defaultProfileName
            }
        }

        function GetCurrentProfile {
            $this.currentProfile
        }

        function SetCurrentProfile($profileName) {
            if ( $profileName ) {
                $newProfile = GetProfileByName $profileName

                if ( $newProfile ) {
                    $this.currentProfile = $newProfile
                }
            }
        }

        function __LoadSettings($settingsPath) {
            if ( ! $this.settingsLoadAttempted ) {
                $this.settingsLoadAttempted = $true
                if ( $settingsPath ) {
                    $settingsPath
                } else {
                    $this.settingsBypassed = test-path env:AUTOGRAPH_BYPASS_SETTINGS
                    if ( ! $this.settingsBypassed ) {
                        $targetPath = if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                            $env:AUTOGRAPH_SETTINGS_FILE
                        } else {
                            $this.defaultSettingsPath
                        }
                        $this.settings = new-so LocalSettings $targetPath
                    }
                }
            }
        }

        function __LoadProfiles {
            __LoadSettings
            if ( $this.settings -and ! $this.profiles ) {
                LoadProfiles
            }
        }

        function __GetNormalizedProfileData($profileData, $connections, $endpoints) {
            $referencedConnectionName = $profileData['connectionProfile']
            $referencedEndpointName = $null

            $endpointData = $null
            $connectionData = $null

            if ( $connections -and $referencedConnectionName ) {
                $connectionData = $connections[$referencedConnectionName]

                if ( $connectionData ) {
                    $endpointName = $connectionData['graphEndpoint']
                    $referencedEndpointName = if ( $endpointName -and ! ( $::.GraphEndpoint |=> IsWellKnownCloud $endpointName ) ) {
                        $endpointName
                    }

                    $endpointData = if ( $endpoints -and $referencedEndpointName ) {
                        $endpoints[$referencedEndpointName]
                    }
                }
            }

            $profileName = $profileData['name']

            if ( $referencedConnectionName -and ! $connectionData ) {
                throw "Profile '$profileName' refers to non-existent connection name '$connectionProfileName'"
            }

            if ( $referencedEndpointName -and ! $endpointData ) {
                throw "Connection profile '$referencedConnectionName' in profile '$profileName' refers to non-existent endpoint '$referencedEndpointName'"
            }

            @{
                ProfileData = $profileData
                ConnectionProfileData = $connectionData
                EndpointData = $endpointData
            }
        }

        function __RegisterSettingProperties {
            $::.LocalSettings |=> RegisterSettingProperties profiles $this.propertyReaders
        }
    }
}

$::.LocalProfile |=> __initialize
