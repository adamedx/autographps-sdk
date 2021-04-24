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
. (import-script LocalConnectionProfile)
. (import-script ../cmdlets/New-GraphConnection)

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

        $endpointCollection = if ( $endpointData ) {
            @{$endpointData.Name=$endpointData}
        }

        $this.connectionProfile = new-so LocalConnectionProfile $connectionData $endpointCollection
    }

    function GetConnection {
        if ( $this.connectionProfile.Name ) {
            $::.GraphConnection |=> GetNamedConnection $this.connectionProfile.Name
        }
    }

    function ToConnectionParameters([string[]] $permissions) {
        $this.connectionProfile |=> ToConnectionParameters $permissions
    }

    function ToPublicProfile {
        $connectionName = if ( $this.connectionProfile ) { $this.connectionProfile.Name }
        $profileInfo = [ordered] @{}

        # Ensure these "well-known" values are part of the structure even
        # if they are not set -- other settings may come from external modules
        # that extend the profile structure with their own module-specific
        # properties
        $profileInfo['ProfileName'] = $this.name
        $profileInfo['Connection'] = $connectionName
        $profileInfo['IsDefault'] = $this.name -eq $this.scriptclass.defaultProfileName
        $profileInfo['AutoConnect'] = $this.profileData['AutoConnect']
        $profileInfo['NoBrowserSigninUI'] = $this.profileData['noBrowserSigninUI']
        $profileInfo['InitialApiVersion'] = $this.InitialApiVersion
        $profileInfo['LogLevel'] = $this.logLevel

        # Add these last so that we get the correct capitalization -- the setting names
        # may be camel-cased or have irregular casing -- we'll at least try to adjust
        # for the camel-case scenario by capitalizing the initial below
        if ( $this.profileData ) {
            foreach ( $property in $this.profileData.keys ) {
                if ( $property -ne 'name' -and ! $profileInfo.Contains($property) ) {
                    $capitalized = $property[0].ToString().ToUpper() + $property.substring(1, $property.length - 1)
                    $profileInfo[$capitalized] = $this.profileData[$property]
                }
            }
        }

        $result = [PSCustomObject] $profileInfo
        $result.pstypenames.insert(0, 'GraphProfileSettings')

        $result
    }

    function GetSetting([string] $settingName) {
        if ( $this.profileData ) {
            $this.profileData[$settingName]
        }
    }

    function ToJson {
    }

    static {
        const defaultSettingsPath '~/.autographps/settings.json'

        $settings = $null
        $profiles = $null
        $defaultProfileName = $null
        $settingsLoadAttempted = $false
        $settingsPath = $null
        $settingsBypassed = $false
        $currentProfile = $null
        $connectionCommand = $null

        $propertyReaders = @{
            name = @{ Validator = 'NameValidator'; Required = $true }
            initialApiVersion = @{ Validator = 'StringValidator'; Required = $false
                                   Updater = {
                                       $currentProfile = $::.LocalProfile |=> GetCurrentProfile
                                       if ( $currentProfile -and $currentProfile.InitialApiVersion ) {
                                           $currentContext = $::.GraphContext |=> GetCurrent
                                           # Only do this if we have a context -- if there is none, this must be startup,
                                           # so let this value be set by the rest of the startup process
                                           if ( $currentContext ) {
                                               $newContext = $::.LogicalGraphManager |=> Get |=> NewContext $currentContext $null $currentProfile.InitialApiVersion $null $false
                                               $::.GraphContext |=> SetCurrentByName $newContext.name
                                           }
                                       }
                                   }
                                 }
            $::.LocalProfileSpec.ConnectionProperty = @{ Validator = 'ConnectionValidator'; Required = $false
                                                         Updater = {
                                                             $currentProfile = $::.LocalProfile |=> GetCurrentProfile
                                                             if ( $currentProfile ) {
                                                                 $connection = $currentProfile |=> GetConnection
                                                                 $currentContext = $::.GraphContext |=> GetCurrent
                                                                 if ( $connection -and $currentContext ) {
                                                                     $currentContext |=> UpdateConnection $connection
                                                                 }
                                                             }
                                                         }
                                                       }
            noBrowserSigninUI = @{ Validator = 'BooleanValidator'; Required = $false }
            autoConnect = @{ Validator = 'BooleanValidator'; Required = $false }
            logLevel = @{ Validator = 'StringValidator'; Required = $false
                          Updater = {
                              $currentProfile = $::.LocalProfile |=> GetCurrentProfile
                              if ( $currentProfile -and $currentProfile.logLevel ) {
                                  try {
                                      $logger = $::.RequestLog |=> GetDefault
                                      $logger.LogLevel = $currentProfile.loglevel
                                  } catch {
                                  }
                              }
                          }
                        }
        }

        function __initialize($connectionCommand) {
            $this.settings = $null
            $this.profiles = $null
            $this.defaultProfileName = $null
            $this.settingsLoadAttempted = $false
            $this.settingsPath = $null
            $this.settingsBypassed = $false
            $this.currentProfile = $null
            $this.connectionCommand = $connectionCommand

            __RegisterSettingProperties
        }

        function LoadProfiles {
            if ( $this.settings ) {
                $this.settings |=> Load

                $settingData = __GetSettingData

                $endpointData = $settingData.endpointData
                $connectionData = $settingData.connectionData
                $profileData = $settingData.profileData

                # We need this strange workaround for scriptclass because scriptclass
                # hosts the code for static methods in a separate 'custom' module from the rest
                # of the class and the overall module itself. So commands exported
                # by this module are invisible (unless you dot source the module's code
                # instead of importing it as a module). So we inject the command script
                # as a parameter, assuming that the caller of __initialize is outside of
                # this custom module and has access to the New-GraphConnection command.
                # TODO: Find a better way to do this. :) Easiest fix would be to simply make an internal
                # version of New-GraphConnection exposed as a class method instead of using the command.
                new-item -force function:New-GraphConnection -value $this.connectionCommand | out-null

                if ( $connectionData ) {
                    foreach ( $connectionElement in $connectionData.values ) {
                        $connectionProfile = new-so LocalConnectionProfile $connectionElement $endpointData

                        $connectionParameters = $connectionProfile |=> ToConnectionParameters

                        write-verbose "Configuring application '$($connectionProfile.name)' with the following parameters:"
                        foreach ( $parameterName in $connectionParameters.Keys ) {
                            write-verbose ( "{0}: {1}" -f $parameterName, $connectionParameters[$parameterName] )
                        }

                        try {
                            New-GraphConnection @connectionParameters -Name $connectionProfile.Name | out-null
                        } catch {
                            write-warning "Unable to configure specified connection setting '$($connectionProfile.name)'"
                            write-warning $_.exception.message
                        }
                    }
                }

                __UpdateProfileSettings $endpointData $connectionData $profileData

                $this.defaultProfileName = $this.settings |=> GetSettingValue defaultProfile

                if ( $this.defaultProfileName ) {
                    SetCurrentProfile $this.defaultProfileName
                }

                $::.LocalSettings |=> RefreshBehaviorsFromSettings
            }
        }

        function ReloadProfileSettings([boolean] $resetAllSettings) {
            $settingData = __GetSettingData

            $currentProfile = $::.LocalProfile |=> GetCurrentProfile

            # This creates new profiles for each reloaded profile, so the current profile will be invalid
            __UpdateProfileSettings $settingData.endpointData $settingData.connectionData $settingData.profileData

            # Set reloaded current profile to be the current profile
            if ( $currentProfile ) {
                SetCurrentProfile $currentProfile.Name
            }

            $::.LocalSettings |=> RefreshBehaviorsFromSettings $resetAllSettings
        }

        function GetProfiles {
            __LoadProfiles
            $this.profiles
        }

        function GetProfileByName($profileName) {
            __GetProfileByName $profileName
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

        function SetCurrentProfile($profileName, $refreshSettings) {
            $newProfile = __GetProfileByName $profileName

            if ( $newProfile ) {
                $this.currentProfile = $newProfile

                if ( $refreshSettings ) {
                    $::.LocalSettings |=> RefreshBehaviorsFromSettings
                }
            } else {
                throw "Cannot set the current profile settings -- the specified profile '$profileName' could not be found."
            }
        }

        function __GetProfileByName($profileName) {
            if ( $this.profiles ) {
                $this.profiles | where name -eq $profileName
            }
        }

        function __LoadSettings($settingsPath) {
            if ( ! $this.settingsLoadAttempted -or $settingsPath ) {
                $this.settingsLoadAttempted = $true
                $this.settingsBypassed = ! $settingsPath -and ( test-path env:AUTOGRAPH_BYPASS_SETTINGS )

                if ( ! $this.settingsBypassed ) {
                    $targetPath = if ( $settingsPath ) {
                        write-verbose "Settings load: Overriding default behaviors and environment variables with explicit path '$settingsPath'"
                        $settingsPath
                    } elseif ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                        $env:AUTOGRAPH_SETTINGS_FILE
                    } else {
                        $this.defaultSettingsPath
                    }
                    $this.settings = new-so LocalSettings $targetPath
                }
            }
        }

        function __LoadProfiles {
            __LoadSettings
            if ( $this.settings -and ! $this.profiles ) {
                LoadProfiles
            }
        }

        function __GetSettingData {
            $endpointData = @{}
            $connectionData = @{}
            $profileData = @{}

            if ( $this.settings ) {
                $endpointData = $this.settings |=> GetSettings $::.LocalProfileSpec.EndpointsCollection
                $connectionData = $this.settings |=> GetSettings $::.LocalProfileSpec.ConnectionsCollection $endpointData
                $profileData = $this.settings |=> GetSettings $::.LocalProfileSpec.ProfilesCollection $connectionData
            }

            @{
                endpointData = $endpointData
                connectionData = $connectionData
                profileData = $profileData
            }
        }

        function __UpdateProfileSettings($endpointData, $connectionData, $profileData) {
            $this.profiles = if ( $profileData ) {
                foreach ( $profileDataItem in $profileData.values ) {
                    $normalizedData = __GetNormalizedProfileData $profileDataItem $connectionData $endpointData
                    new-so LocalProfile $normalizedData.ProfileData $normalizedData.ConnectionProfileData $normalizedData.EndpointData
                }
            }
        }

        function __GetNormalizedProfileData($profileData, $connections, $endpoints) {
            $referencedConnectionName = $profileData[$::.LocalProfileSpec.ConnectionProperty]
            $referencedEndpointName = $null

            $endpointData = $null
            $connectionData = $null

            if ( $connections -and $referencedConnectionName ) {
                $connectionData = $connections[$referencedConnectionName]

                if ( $connectionData ) {
                    $endpointName = $connectionData[$::.LocalProfileSpec.EndpointProperty]
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
            $::.LocalSettings |=> RegisterSettingProperties $::.LocalProfileSpec.ProfilesCollection $this.propertyReaders
        }
    }
}

$::.LocalProfile |=> __initialize (get-command New-GraphConnection).ScriptBlock
