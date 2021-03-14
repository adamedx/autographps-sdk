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

$testSettingsFilePath = "$psscriptroot/../../test/assets/profilesettings/testsettings1.json"
$testSettings = get-content $testSettingsFilePath | out-string | convertfrom-json


function EnableSettings {
    if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
        remove-item env:AUTOGRAPH_BYPASS_SETTINGS
    }

    set-item env:AUTOGRAPH_SETTINGS_FILE $testSettingsFilePath

    $warningpreference = 'silentlycontinue'
    $::.LocalSettings |=> __initialize
    $::.LocalConnectionProfile |=> __initialize
    $::.LocalProfile |=> __initialize
    $::.LogicalGraphManager.sessionManager = $null
    $::.GraphContext |=> __initialize
}

function DisableSettings {
    set-item env:AUTOGRAPH_BYPASS_SETTINGS $true

    if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
        remove-item env:AUTOGRAPH_SETTINGS_FILE
    }

    $warningpreference = 'silentlycontinue'
    $::.LocalSettings |=> __initialize
    $::.LocalConnectionProfile |=> __initialize
    $::.LocalProfile |=> __initialize
    $::.LogicalGraphManager.sessionManager = $null
    $::.GraphContext |=> __initialize
}

function AddExpectedProperties($profileData, $properties, [string[]] $propertyNames, [HashTable] $publicToDataNameMap) {
    foreach ( $propertyName in $propertyNames ) {
        $dataPropertyName = if ( $publicToDataNameMap -and $publicToDataNameMap[$propertyName] ) {
            $publicToDataNameMap[$propertyName]
        } else {
            $propertyName
        }

        $expectedValue = if ( $profileData | gm $dataPropertyName -erroraction ignore ) {
            $profileData.$dataPropertyName
        } elseif ( $testSettings.profiles.defaults | gm $dataPropertyName -erroraction ignore ) {
            $testSettings.profiles.defaults.$dataPropertyName
        }

        # Ignore connections that don't actually exist -- these should resolve as null
        if ( $dataPropertyName -eq 'connectionProfile' -and $expectedValue ) {
            if ( ! ( $testSettings.connectionProfiles.list | where name -eq $expectedValue ) ) {
                $expectedValue = $null
            }
        }

        $properties[$propertyName] = $expectedValue
    }
}

Describe 'LocalProfile class' {
    Context 'When there are no profile settings to load' {
        BeforeAll {
            DisableSettings
        }

        AfterAll {
            DisableSettings
        }

        It 'Should be executing tests with loading of profile settings disabled' {
            (get-item env:AUTOGRAPH_BYPASS_SETTINGS).value | Should Be $true
            test-path env:AUTOGRAPH_SETTINGS_FILE | Should Be $false
        }

        It 'Should result in no profiles returned to the Get-GraphProfileSettings command and no errors' {
            { Get-GraphProfileSettings | out-null } | Should Not Throw
            Get-GraphProfileSettings | Should Be $null
        }

        It 'Should result in the default profile being returned as $null' {
            Get-GraphProfileSettings -current | Should Be $null
        }

        It 'Should result in an error when any profile name is specified to Select-GraphProfileSettings' {
            { Select-GraphProfileSettings someprofile | out-null } | Should Throw
        }

        It 'Should result in an error when any profile name is specified to Connect-GraphApi' {
            { Connect-GraphApi someprofile | out-null } | Should Throw
        }
    }

    Context 'When profile settings have been loaded' {
        BeforeAll {
            EnableSettings
        }

        AfterAll {
            DisableSettings
        }

        It 'Should be executing tests with loading of profile settings enabled ' {
            test-path env:AUTOGRAPH_BYPASS_SETTINGS | Should Be $false
            (get-item env:AUTOGRAPH_SETTINGS_FILE).value | Should BeExactly $testSettingsFilePath
        }

        It "Should have the expected default profile" {
            $profileSettings = Get-GraphProfileSettings -current
            $profileSettings.ProfileName | Should Be $testSettings.defaultProfile
            $profileSettings.InitialApiVersion | Should Be ( $testSettings.profiles.list | where name -eq $profileSettings.ProfileName | select -expandproperty InitialApiVersion )
        }

        It "Should return the expected set of profiles from GetProfiles sorted alphabetically by profile name" {
            $profiles = Get-GraphProfileSettings

            $expectedProfileNames = $testSettings.profiles.list.name | select-object -unique | sort-object
            Compare-object $expectedProfileNames $profiles.ProfileName -syncwindow 0 | Should Be $null
        }

        It "Should ignore settings from a duplicated profile" {
            $profiles = Get-GraphProfileSettings

            $expectedProfileData = $testSettings.profiles.list | where name -eq 'DuplicateSettings2' | select -first 1
            $expectedProfile = [PSCustomObject] @{
                ProfileName = $expectedProfileData.Name
                LogLevel = $null
                InitialApiVersion = $testSettings.profiles.defaults.InitialApiVersion
                Connection = $null
                IsDefault = $false
            }

            $ignoredProfileData = $testSettings.profiles.list | where name -eq 'DuplicateSettings2' | select -last 1
            $ignoredProfile = [PSCustomObject] @{
                ProfileName = $ignoredProfileData.Name
                LogLevel = $ignoredProfileData.LogLevel
                InitialApiVersion = $testSettings.profiles.defaults.InitialApiVersion
                Connection = $null
                IsDefault = $false
            }

            $actualProfile = $profiles | where ProfileName -eq 'DuplicateSettings2'

            Compare-object $expectedProfile.psobject.properties $actualProfile.psobject.properties -syncwindow 0 | Should Be $null
            # Name and ProfileName are expected differences, but IsDefault is not part of the raw data,
            # so these cancel out and the expected mismatches is just the count of properties on the raw data object
            (Compare-object $expectedProfile.psobject.properties $ignoredProfile.psobject.properties -syncwindow 0).length | Should Be ( ($ignoredProfileData.psobject.properties | measure-object).count )
        }

        It "Should include the initial api version of beta in all versions except when overridden due to inclusion of initialApi version of beta in the defaults section" {
            $profiles = Get-GraphProfileSettings
            foreach ( $profileSettings in $profiles ) {
                $profileData = $testSettings.profiles.list | where name -eq $profileSettings.ProfileName

                $expectedVersion = if ( $profileData | gm InitialApiVersion -erroraction ignore ) {
                    $profileData.InitialApiVersion
                } else {
                    $testSettings.profiles.defaults.InitialApiVersion
                }

                $profileSettings.InitialApiVersion | Should Be $expectedVersion
            }
        }

        It "Should have the expected settings for each profile" {
            $profiles = Get-GraphProfileSettings
            $defaultProfile = $testSettings.defaultProfile

            foreach ( $actualProfile in $profiles ) {
                $expectedProfileData = $testSettings.profiles.list | where name -eq $actualProfile.ProfileName | select -first 1


                $expectedProfileProperties = [ordered] @{
                    ProfileName = $expectedProfileData.Name
                    LogLevel = $null
                    InitialApiVersion = $null
                    Connection = $null
                    IsDefault = $expectedProfileData.Name -eq $defaultProfile
                }

                AddExpectedProperties $expectedProfileData $expectedProfileProperties LogLevel, InitialApiVersion, Connection @{Connection='connectionProfile'}
                $expectedProfile = [PSCustomObject] $expectedProfileProperties

                Compare-object $expectedProfile.psobject.properties.Name $actualProfile.psobject.properties.Name -syncwindow 0 | Should Be $null
                # There is something strange about the "." syntax for ".value" on these objects -- it sometimes
                # results in $null, but only when passed to compare-object! Working around it select-object :(
                Compare-object ( $expectedProfile.psobject.properties | select-object -expandproperty Value ) ( $actualProfile.psobject.properties | select-object -expandproperty Value ) -syncwindow 0 | Should Be $null
            }
        }
    }
}
