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

set-strictmode -version 2

Describe "The Test-GraphSettings command" {
    $wellFormedSettingsFileLocation = "$psscriptroot/../../test/assets/profilesettings/wellformedsettings.json"
    $settingswithWarningsFileLocation = "$psscriptroot/../../test/assets/profilesettings/testsettings1.json"
    $nonexistentDefaultSettingsPath = "$($wellFormedSettingsFileLocation)-idontexist.json"
    $simpleSettingsTemplate = '{{"defaultProfile":"{0}","profiles":{{"list":[{{"name":"{0}","promptColor":"Red"}}]}},"connections":{{"defaults":{{"ConsistencyLevel":"Eventual"}}}}}}'

    Context "When invoked without the Path parameter" {
        BeforeAll {
            if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
                remove-item env:AUTOGRAPH_BYPASS_SETTINGS
            }

            if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                remove-item env:AUTOGRAPH_SETTINGS_FILE
            }

            Mock-ScriptClassMethod LocalProfile GetSettingsFileLocation -static {
                $mockContext.wellformedSettingsPath
            } -MockContext @{wellformedSettingsPath = $wellformedSettingsFileLocation}
        }

        BeforeEach {
            if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
                remove-item env:AUTOGRAPH_BYPASS_SETTINGS
            }

            if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                remove-item env:AUTOGRAPH_SETTINGS_FILE
            }
        }

        AfterAll {
            if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
                remove-item env:AUTOGRAPH_BYPASS_SETTINGS
            }

            if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                remove-item env:AUTOGRAPH_SETTINGS_FILE
            }

            Remove-ScriptClassMock LocalProfile GetSettingsFileLocation -static
        }

        It "Should return information about the default settings file when run with no parameters" {
            $settingsInfo = Test-GraphSettings

            $expectedValidatedFile = Get-Item $wellFormedSettingsFileLocation | Select-Object -ExpandProperty FullName
            $actualValidatedFile = Get-Item $settingsInfo.Path | Select-Object -ExpandProperty FullName

            $actualValidatedFile | Should BeExactly $expectedValidatedFile
        }

        It "Should return information about the default settings file when run with no parameters even if settings bypass is enabled" {
            set-item env:AUTOGRAPH_BYPASS_SETTINGS $true

            $settingsInfo = Test-GraphSettings

            $expectedValidatedFile = Get-Item $wellFormedSettingsFileLocation | Select-Object -ExpandProperty FullName
            $actualValidatedFile = Get-Item $settingsInfo.Path | Select-Object -ExpandProperty FullName

            $actualValidatedFile | Should BeExactly $expectedValidatedFile
        }

        It "Should return settings information based on the InputObject parameter and not the default if the InputObject is specified as a JSON string" {
            $profileParam = 'jsonstringinput'
            $result = $simpleSettingsTemplate -f $profileParam | Test-GraphSettings

            $result.Path | Should Be $null
            $result.DefaultprofileName | Should Be $profileParam
            $result.ProfileNames | select -first 1 | Should Be $profileParam
            $result.settings.profiles.list | select -first 1 | select-object -expandproperty Name | Should Be $profileParam
            $result.settings.profiles.list | select -first 1 | select-object -expandproperty Promptcolor | Should Be Red
            $result.settings.connections.defaults.ConsistencyLevel | Should Be Eventual
        }

        It "Should return settings information based on the InputObject parameter and not the default if the InputObject is specified as nested PSCustomObject objects" {
            $profileParam = 'pscustomobjectinput'

            $result = $simpleSettingsTemplate -f $profileParam |
              ConvertTo-Json -depth 4 |
              ConvertFrom-Json | Test-GraphSettings

            $result.Path | Should Be $null
            $result.DefaultprofileName | Should Be $profileParam
            $result.ProfileNames | select -first 1 | Should Be $profileParam
            $result.settings.profiles.list | select -first 1 | select-object -expandproperty Name | Should Be $profileParam
            $result.settings.profiles.list | select -first 1 | select-object -expandproperty Promptcolor | Should Be Red
            $result.settings.connections.defaults.ConsistencyLevel | Should Be Eventual
        }

        It "Should return settings information based on the InputObject parameter and not the default if the InputObject is specified as nested hash tables" {
            $result = @{defaultProfile='main';profiles=@{list=@(@{name='main';promptcolor='green'})};connections=@{defaults=@{ConsistencyLevel='Eventual'}}} | Test-GraphSettings

            $result.Path | Should Be $null
            $result.DefaultProfileName | Should Be main
            $result.settings.connections.defaults.ConsistencyLevel | Should Be Eventual
            $result.settings.profiles.list | select -first 1 | select -expandproperty name | Should Be main
            $result.settings.profiles.list | select -first 1 | select -expandproperty PromptColor | Should Be green
        }
    }

    Context "When processing the AUTOGRAPH_SETTINGS_FILE environment override" {
        BeforeEach {
            if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
                remove-item env:AUTOGRAPH_BYPASS_SETTINGS
            }

            if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                remove-item env:AUTOGRAPH_SETTINGS_FILE
            }
        }

        AfterEach {
            if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
                remove-item env:AUTOGRAPH_BYPASS_SETTINGS
            }

            if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                remove-item env:AUTOGRAPH_SETTINGS_FILE
            }
        }

        It "Should honor the AUTOGRAPH_SETTINGS_FILE environment override and return only information about the configured path of the settings file if the override settings file does not exist" {
            set-item env:AUTOGRAPH_SETTINGS_FILE "$($wellFormedSettingsFileLocation)-idontexist.json"

            $settingsInfo = Test-GraphSettings

            $settingsInfo.Path | Should Be $env:AUTOGRAPH_SETTINGS_FILE
            $settingsInfo.Settings | Should Be $null
        }

        It "Should honor the AUTOGRAPH_SETTINGS_FILE environment override if it is changed in between invocations" {
            set-item env:AUTOGRAPH_SETTINGS_FILE "$($wellFormedSettingsFileLocation)-idontexist.json"

            $emptySettingsInfo = Test-GraphSettings

            $emptySettingsInfo.Path | Should Be $env:AUTOGRAPH_SETTINGS_FILE
            $emptySettingsInfo.Settings | Should Be $null

            set-item env:AUTOGRAPH_SETTINGS_FILE $wellFormedSettingsFileLocation

            $settingsInfo = Test-GraphSettings

            $expectedValidatedFile = Get-Item $wellFormedSettingsFileLocation | Select-Object -ExpandProperty FullName
            $actualValidatedFile = Get-Item $settingsInfo.Path | Select-Object -ExpandProperty FullName

            $actualValidatedFile | Should BeExactly $expectedValidatedFile
        }
    }

    Context "When processing well formed settings" {
        BeforeAll {
            if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
                remove-item env:AUTOGRAPH_BYPASS_SETTINGS
            }

            if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                remove-item env:AUTOGRAPH_SETTINGS_FILE
            }

            $nonexistentSettingsPath = "$($wellFormedSettingsFileLocation)-idontexist.json"

            Mock-ScriptClassMethod LocalProfile GetSettingsFileLocation -static {
                $mockContext.nonexistentPath
            } -MockContext @{nonexistentPath = $nonexistentSettingsPath}
        }

        AfterAll {
            Remove-ScriptClassMock LocalProfile GetSettingsFileLocation -static
        }

        It "Should return information about the non-default specified file only when executed with that path and with the expected content with collection properties sorted" {
            Test-GraphSettings | Select-Object -expandproperty Settings | Should Be $null

            $settingsInfo = Test-GraphSettings $wellFormedSettingsFileLocation

            $expectedValidatedFile = Get-Item $wellFormedSettingsFileLocation | Select-Object -ExpandProperty FullName
            $actualValidatedFile = Get-Item $settingsInfo.Path | Select-Object -ExpandProperty FullName

            $actualValidatedFile | Should BeExactly $expectedValidatedFile

            $settingsInfo.DefaultProfileName | Should Be WilyCORP
            Compare-Object @('Robot', 'WilyCORP', 'WilyDev') (
                $settingsInfo.ProfileNames ) | Should BeExactly $null
            Compare-Object @('AutoWily', 'Developer', 'Operator') (
                $settingsInfo.ConnectionNames ) | Should BeExactly $null
            Compare-Object @('WilyProxy', 'WilyResearch') (
                $settingsInfo.EndpointNames ) | Should BeExactly $null

            # Validate the detailed settings
            $settingsInfo.settings.'$schema' | Should Be 'https://github.com/adamedx/autographps-sdk/blob/main/docs/settings/settings.schema.json'

            # Profiles
            $settingsInfo.settings.profiles.defaults.logLevel | Should Be Full
            $settingsInfo.settings.profiles.list | measure-object | Select-Object -expandproperty Count | Should Be 3
            $profiles = @()
            foreach ( $profileItem in $settingsInfo.settings.profiles.list | sort-object Name ) {
                $profiles += $profileItem
            }
            Compare-Object @('Robot', 'WilyCORP', 'WilyDev') $profiles.name | Should BeExactly $null
            Compare-Object @('Operator', 'AutoWily', 'Developer') $profiles.connection | Should BeExactly $null
            $profiles[1].PromptColor | Should Be Red

            # Connections
            $settingsInfo.settings.connections.defaults.consistencyLevel | Should Be Eventual
            $settingsInfo.settings.connections.list | measure-object | Select-Object -expandproperty Count | Should Be 3
            $connections = @()
            foreach ( $connectionItem in $settingsInfo.settings.connections.list | sort-object Name ) {
                $connections += $connectionItem
            }
            Compare-Object @('AutoWily', 'Developer', 'Operator') $connections.name | Should BeExactly $null
            Compare-Object @('WilyProxy', 'WilyResearch', 'WilyProxy') $connections.endpoint | Should BeExactly $null
            Compare-Object @('d86ff35f-3c5d-4879-89b5-089b74908299', 'db744167-187c-4b96-b6aa-654b2352823a', 'd8dcae77-ddc1-406e-9784-c73cbb305862') $connections.appId | Should BeExactly $null
            Compare-Object @('c166bed2-181c-4696-9a42-1e8385f11f67', '4dd10348-2192-470e-80fe-c53b8eb8378e', 'c166bed2-181c-4696-9a42-1e8385f11f67') $connections.tenantId | Should BeExactly $null
            $connections[0].confidential | Should BeExactly $true
            $connections[1].confidential | Should BeExactly $true
            $connections[2] | get-member confidential -erroraction ignore | Should Be $null
            $connections[0].authType | Should BeExactly AppOnly
            $connections[1] | get-member authType -erroraction ignore | Should Be $null
            $connections[2] | get-member authType -erroraction ignore | Should Be $null

            # Endpoints
            $settingsInfo.settings.endpoints.list | measure-object | Select-Object -expandproperty Count | Should Be 2
            $endpoints = @()
            foreach ( $endpointItem in $settingsInfo.settings.endpoints.list | sort-object Name ) {
                $endpoints += $endpointItem
            }
            Compare-Object @('WilyProxy', 'WilyResearch') $endpoints.Name | Should BeExactly $null
            Compare-Object @('https://graph.wilycorp.com', 'https://graph.dev.wilycorp.com') $endpoints.graphUri | Should BeExactly $null
            Compare-Object @('https://login.wilycorp.com', 'https://login.dev.wilycorp.com') $endpoints.authUri | Should BeExactly $null
        }
    }

    Context "When processing non-well-formed settings" {
            $missingEndpoint = @{
                profiles = @{
                    list = @(
                        @{
                            name='profile1'
                            connection='validpublic'
                        }
                        @{
                            name='profile2'
                            connection='invalidmygraph'
                        }
                    )
                }
                connections = @{
                    list = @(
                        @{
                            name='validpublic'
                            endpoint='public'
                        }
                        @{
                            name='invalidmygraph'
                            endpoint='nonexistent'
                        }
                    )
                }
                endpoints = @{
                    list = @(
                        @{
                            name='validendpoint'
                            graphuri='graph.org'
                            authuri='login.org'
                        }
                    )
                }
            }

        BeforeAll {
            if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
                remove-item env:AUTOGRAPH_BYPASS_SETTINGS
            }

            if ( test-path env:AUTOGRAPH_SETTINGS_FILE ) {
                remove-item env:AUTOGRAPH_SETTINGS_FILE
            }

            Mock-ScriptClassMethod LocalProfile GetSettingsFileLocation -static {
                $mockContext.warningSettingsPath
            } -MockContext @{warningSettingsPath = $settingsWithWarningsFileLocation}
        }

        AfterAll {
            Remove-ScriptClassMock LocalProfile GetSettingsFileLocation -static
        }

        It "Should fail if a non-existent file path is specified to the command" {
            { Test-GraphSettings -Path $nonexistentDefaultSettingsPath } | Should Throw "'$nonexistentDefaultSettingsPath' could not be found"
        }

        It "Should fail if the default profile refers to a nonexistent profile" {
            $existingProfileName = 'profile1'
            $nonexistentProfile = 'idontexist'

            $settings = @{defaultProfile=$null;profiles=@{list=@(@{name=$existingProfileName;promptcolor='magenta'})};connections=@{defaults=@{ConsistencyLevel='Eventual'}}} | ConvertTo-Json -depth 4 | ConvertFrom-json

            $settings.defaultProfile = $existingProfileName

            # This is just to prove that we started with valid settings
            $validSettings = $settings | Test-GraphSettings
            $validSettings.defaultProfileName | Should Be $existingProfileName

            # The settings were valid, now just change the default profile to
            # something that doesn't exist
            $settings.defaultProfile = $nonexistentProfile

            { $settings | Test-GraphSettings } | Should Throw "default profile name '$nonexistentProfile'"
        }

        It "Should fail if the profile is invalid" {
            $settings = @{profiles=@{list=@(@{promptcolor='green'})}} | ConvertTo-Json -depth 4 | ConvertFrom-json

            { $settings | Test-GraphSettings 3>&1 | out-null } | Should Throw "A setting was specified without a name property"
        }

        It "Should fail if an endpoint is missing a path uri without NonStrict" {
            $settings = @{endpoints=@{list=@(
                                          @{name='good';graphuri='https://good.graph.org';authuri='https://login.graph.org';}
                                          @{name='bad'})}}

            { $settings | Test-GraphSettings 3>&1 | out-null } | Should Throw "of setting 'bad' of type 'endpoints' is a required property but was not set"
        }

        It "Should include profiles that reference a bad connection, but not connections that reference a bad endpoint endpoint when NonStrict is enabled" {
            $settings = @{
                profiles=@{list=@(@{name='goodprof';connection='goodcon';promptcolor='blue'}
                                  @{name='badprof';connection='badcon'})}
                connections=@{list=@(@{name='goodcon';endpoint='Public'}
                                     @{name='badcon';endpoint='badend'})}
                endpoints=@{list=@(@{name='goodend';graphuri='https://good.graph.org';authuri='https://login.graph.org'}
                                   @{name='badend'})}}

            $settingsInfo = $null
            $settings | Test-GraphSettings -NonStrict -outvariable settingsInfo 3>&1 | out-null

            ($settingsInfo.ProfileNames | measure-object).Count | Should Be 2
            $settingsInfo.ProfileNames[0] | Should Be 'badprof'
            $settingsInfo.ProfileNames[1] | Should Be 'goodprof'
            ($settingsInfo.ConnectionNames | measure-object).Count | Should Be 1
            $settingsInfo.ConnectionNames | select-object -First 1 | Should Be 'goodcon'
            ($settingsInfo.EndpointNames | measure-object).Count | Should Be 1
            $settingsInfo.EndpointNames | select-object -First 1 | Should Be 'goodend'
        }

        It "Should fail if a file Path with invalid JSON is specified to the command via the Path parameter" {
            { Test-GraphSettings -Path $myinvocation.scriptname 3>&1 | out-null } | Should Throw 'JSON'
        }

        It "Should fail if invalid JSON is specified to the command via the InputObject parameter" {
            { "This {} is not valid json" | Test-GraphSettings 3>&1 | out-null } | Should Throw 'JSON'
        }

        It "Should fail if a file that has any invalid settings or schema deviation is specified via the Path parameter" {
            { Test-GraphSettings -Path $settingswithWarningsFileLocation 3>&1 | out-null } | Should Throw 'ignored'
        }

        It "Should fail if an object that has any invalid settings or schema deviation is specified via the InputObject parameter" {
            { $missingEndpoint | Test-GraphSettings 3>&1 | out-null } | Should Throw "unknown endpoint 'nonexistent' was specified"
        }

        It "Shoud succeed if NonStrict is specified for a file with ignorable errors and not allow connections with invalid endpoints" {
            $allowedSettings = $null
            $missingEndpoint | Test-GraphSettings -outvariable allowedSettings -NonStrict 3>&1 | out-null

            ( $allowedSettings.ConnectionNames | measure-object ).Count | Should Be 1
            ( $allowedSettings.ProfileNames | measure-object ).Count | Should Be 2
        }

        It "Should fail if a property takes on an illegal value" {
            $connectionName = 'alternateapp'
            $settingsTemplate = @{connections=@{list=@(@{name=$connectionName;appId=$null})}}
            $validAppId = (new-guid).guid.ToString()

            $settingsTemplate.connections.list[0].appId = $validAppId

            $validSettings = $settingsTemplate | Test-GraphSettings

            $validSettings.ConnectionNames | Select-Object -First 1 | Should Be $connectionName
            $validSettings.settings.connections.list[0].name | Should Be $connectionName
            $validSettings.settings.connections.list[0].appId | Should Be $validAppId

            $invalidAppId = 'not-a-guid'
            $settingsTemplate.connections.list[0].appId = $invalidAppId

            { $settingsTemplate | Test-GraphSettings 3>&1 | out-null } | Should Throw "'$invalidAppID' is not a valid guid"
        }

        It "Should should return all other valid settings if a property takes on an illegal value and NonStrict is given" {
            $goodConnection = @{name='goodConnection';appId='e107d2e9-8eb3-420a-a59c-2ad8692d0001'}
            $badConnection = @{name='badConnection';appId='not-a-guid'}
            $goodProfile = @{name='goodProfile';connection=$goodConnection.name}
            $badProfile = @{name='badProfile';connection=$badConnection.name}

            $settings = @{defaultProfile=$badProfile.name;profiles=@{list=@($goodProfile,$badProfile)};connections=@{list=@($goodConnection,$badConnection)}}

            $validSettings = $null
            $settings | Test-GraphSettings -NonStrict -OutVariable validSettings 3>&1 | out-null

            $validSettings.DefaultProfileName | Should Be $badProfile.Name

            ($validSettings.ProfileNames | measure-object).Count | Should Be 2
            $validSettings.ProfileNames[0] | Should Be $badProfile.Name
            $validSettings.ProfileNames[1] | Should Be $goodProfile.Name

            ($validSettings.ConnectionNames | measure-object).Count | Should Be 1
            $validSettings.ConnectionNames | select -first 1 | Should Be $goodConnection.Name
        }

        It "Should return results for the valid subset of the settings for an object that has some invalid data specified via the InputObject parameter when the NonStrict parameter is specified'" {
            $settingsInfo = $null
            $missingEndpoint | Test-GraphSettings -NonStrict -OutVariable settingsInfo 3>&1 | out-null

            Compare-Object $settingsInfo.ValidSettings.connections.list.name (
                'validpublic' ) | Should BeExactly $null
            Compare-Object $settingsInfo.ValidSettings.endpoints.list.name (
                'validendpoint' ) | Should BeExactly $null
            Compare-Object $settingsInfo.ValidSettings.profiles.list.name (
                'profile1', 'profile2' ) | Should BeExactly $null
        }

        It "Should fail if NonStrict is specified for content that generates warnings when the WarningAction is set to 'Stop'" {
            { $missingEndpoint | Test-GraphSettings -NonStrict -WarningAction stop 3>&1 | out-null } | Should Throw "unknown endpoint 'nonexistent' was specified"
        }
    }
}
