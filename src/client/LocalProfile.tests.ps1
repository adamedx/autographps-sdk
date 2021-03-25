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
$testSettingsFilePath2 = "$psscriptroot/../../test/assets/profilesettings/testsettings2.json"
$testSettings = get-content $testSettingsFilePath | out-string | convertfrom-json

# Need this as there are assumptions about missing property values
# that cause behavior that's usually desired, but not always intended. :)
# This does result in more checks to see if properties exist, this coudl
# probably be generalized to make the tests more readable.
set-strictmode -version 2

function EnableSettings($settingsPath)  {
    $settingsPath = if ( $settingsPath ) {
        $settingsPath
    } else {
        $testSettingsFilePath
    }

    if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
        remove-item env:AUTOGRAPH_BYPASS_SETTINGS
    }

    set-item env:AUTOGRAPH_SETTINGS_FILE $settingsPath

    $warningpreference = 'silentlycontinue'
    $::.LocalSettings |=> __initialize
    $::.LocalConnectionProfile |=> __initialize
    $::.GraphConnection |=> __initialize
    $::.LocalProfile |=> __initialize (get-command New-GraphConnection).ScriptBlock
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
    $::.GraphConnection |=> __initialize
    $::.LocalProfile |=> __initialize (get-command New-GraphConnection).ScriptBlock
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
            $existingConnection = $testSettings.connectionProfiles.list | where {
                ( $_ | gm name -erroraction ignore ) -and ( $_.name -eq $expectedValue )
            }

            if ( ! $existingConnection ) {
                $expectedValue = $null
            }
        }

        $properties[$propertyName] = $expectedValue
    }
}

function CompareUri($uri1, $uri2) {
    if ( $uri1 -eq $null -or $uri1 -eq $null) {
        $uri1 -eq $null -and $uri2 -eq $null
    } else {
        $uri1.tostring().trim('/') -eq $uri2.tostring().trim('/')
    }
}

$NewGraphConnectionMockScript = {
    [cmdletbinding()]
    param(
        [String[]] $Permissions = $null,
        $AppId = $null,
        [Switch] $NoninteractiveAppOnlyAuth,
        [String] $TenantId = $null,
        [string] $CertificatePath = $null,
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate = $null,
        [switch] $Confidential,
        [Switch] $Secret,
        [SecureString] $Password,
        [string] $Cloud = 'Public',
        [Uri] $AppRedirectUri,
        [Switch] $NoBrowserSigninUI,
        [Uri] $GraphEndpointUri = $null,
        [Uri] $AuthenticationEndpointUri = $null,
        [Uri] $GraphResourceUri = $null,
        [ValidateSet('Default', 'v1', 'v2')]
        [string] $AuthProtocol = 'Default',
        [string] $AccountType = 'Auto',
        [string] $Name = $null,
        [switch] $AADGraph,
        [String] $UserAgent = $null
    )
    # This mock is running within a different module script block than the rest of the test code,
    # so we are using a static class method as a workaround to passing context to and from the mock.
    $mockConnections = $::.MockContext.Connections

    $appIdArg = if ( $appid ) {
        [guid] $appid
    } else {
        new-guid
    }

    $app = new-so GraphApplication $appIdArg $AppRedirectUri $null $NoninteractiveAppOnlyAuth.IsPresent
    $endpoint = new-so GraphEndpoint $Cloud MSGraph $GraphEndpointUri $AuthenticationEndpointUri $AuthProtocol $GraphResourceUri
    $identity = new-so GraphIdentity $app $endpoint $TenantId ($AccountType -eq 'AzureADAndPersonalMicrosoftAccount')
    $connection = New-ScriptObjectMock GraphConnection -PropertyValues @{
        Id = new-guid
        Identity = $identity
        GraphEndpoint = $endpoint
        Scopes = $Permissions
        Connected = $true
        NoBrowserUI = $NoBrowserSigninUi.IsPresent
        UserAgent = $UserAgent
        Name = $Name
    }

    $mockConnections.Add($connection.Id, $connection)

    $connection
}


# This is a workaround for the MockContext parmaeter of
# Add-MockInScriptClassScope apparently not working despite
# passing tests in its own module :(
ScriptClass MockContext {
    static {
        $Connections = @{}
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

    Context 'When profile settings have been loaded and connections are enumerated' {
        BeforeAll {
            set-strictmode -version 2
            EnableSettings $testSettingsFilePath2
        }

        AfterAll {
            DisableSettings
        }

        It 'Should be executing tests with loading of profile settings enabled ' {
            test-path env:AUTOGRAPH_BYPASS_SETTINGS | Should Be $false
            (get-item env:AUTOGRAPH_SETTINGS_FILE).value | Should BeExactly $testSettingsFilePath2
        }

        It 'Should enumerate the expected connnections' {
            $wellFormedConnections = $testSettings.connectionProfiles.list |
              where { $_ | gm name -erroraction ignore }

            $expectedConnectionNames = $wellFormedConnections | where name -notin @(
                'ConnectionWithNonexistentEndpoint'
                'ConnectionWithBadEndpoint'
                'MalformedAppId'
            ) | select -expandproperty name

            $actualConnections = Get-GraphConnection | where name -ne ''

            $actualConnections.length | Should Be 5

            $foundConnections = @{}
            foreach ( $connection in $actualConnections) {
                $isInExpectedConnections = $connection.name -in $expectedConnectionNames
                $isInExpectedConnections| should be $true
                $foundConnections.Add($Connection.Name, $connection)
            }
        }
    }

    Context 'When profile settings have been loaded' {
        BeforeAll {
            set-strictmode -version 2
            # The -MockContext parameter of Add-MockInScriptClassScope does not seem to work -- we'll instead
            # use a custom class, $::.MockContext, to pass information to the Mock function
            # Also note that Add-MockInScriptClassScope is destructive -- it seems that once the context
            # block is executed, certain state becomes corrupted and various ScriptClass methods no
            # longer function -- so the tests can only be run once.
            Add-MockInScriptClassScope LocalProfile New-GraphConnection $NewGraphConnectionMockScript
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
            $profileSettings.InitialApiVersion | Should Be ( $testSettings.profiles.list |
              where {
                  if ( $_ | gm name -erroraction ignore ) {
                      $_.name -eq $profileSettings.ProfileName
                  }
              } | select -expandproperty InitialApiVersion )
        }

        It "Should return the expected set of profiles from GetProfiles sorted alphabetically by profile name" {
            $profiles = Get-GraphProfileSettings

            $expectedProfileNames = $testSettings.profiles.list | where { $_ | gm name -erroraction ignore } | select -expandproperty name | select-object -unique | sort-object
            Compare-object $expectedProfileNames $profiles.ProfileName -syncwindow 0 | Should Be $null
        }

        It "Should ignore settings from a duplicated profile" {
            $profiles = Get-GraphProfileSettings

            $expectedProfileData = $testSettings.profiles.list |
              where {
                  if ( $_ | gm name -erroraction ignore ) {
                      $_.name -eq 'DuplicateSettings2'
                  }
              }  | select -first 1

            $expectedProfile = [PSCustomObject] @{
                ProfileName = $expectedProfileData.Name
                LogLevel = $null
                InitialApiVersion = $testSettings.profiles.defaults.InitialApiVersion
                Connection = $null
                IsDefault = $false
            }

            $ignoredProfileData = $testSettings.profiles.list |
              where {
                  ( $_ | gm name -erroraction ignore ) -and ( $_.name -eq 'DuplicateSettings2' )
              } | select -last 1

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
                $profileData = $testSettings.profiles.list |
                  where {
                      if ( $_ | gm name -erroraction ignore ) {
                          $_.name -eq $profileSettings.ProfileName
                      }
                  }

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
                $expectedProfileData = $testSettings.profiles.list |
                  where {
                      if ( $_ | gm name -erroraction ignore ) {
                          $_.name -eq $actualProfile.ProfileName
                      }
                  } | select -first 1

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

        It "Should have the expected endpoints" {
            $profiles = $::.LocalProfile |=> GetProfiles

            $actualEndpoints = @{}

            foreach ( $actualProfile in $profiles ) {
                $endpointData = $actualProfile.endpointData

                if ( $endpointData ) {
                    $actualEndpoints[$endpointData.name] = $endpointData
                }
            }

            # This assumes that this particular test file has a reference to every
            # valid endpoint listed in the file
            $expectedEndpoints = @{}
            $testSettings.graphEndpoints.list |
              where {
                  if ( ( $_ | gm name -erroraction ignore ) -and ( $_ | gm graphUri -erroraction ignore ) ) {
                      $expectedEndpoints.Add($_.name, $_)
                      $actualEndpoints[$_.name] | Should Not Be $null
                      CompareUri $actualEndpoints[$_.name].graphUri $_.graphUri | Should Be $true
                      CompareUri $actualEndpoints[$_.name].authUri $_.authUri | Should Be $true
                      CompareUri $actualEndpoints[$_.name].resourceUri $_.resourceUri | Should Be $true
                  }
              }

            $actualEndpoints.Count | Should Be $expectedEndpoints.Count
        }

        It "Should have the expected connections" {
            $wellFormedConnections = $testSettings.connectionProfiles.list |
              where { $_ | gm name -erroraction ignore }

            $expectedConnectionNames = $wellFormedConnections | where name -notin @(
                'ConnectionWithNonexistentEndpoint'
                'ConnectionWithBadEndpoint'
                'MalformedAppId'
            ) | select -expandproperty name

            $mockConnections = $::.MockContext.Connections

            $mockConnections.Count | Should Be $expectedConnectionNames.Length

            foreach ( $connection in $mockConnections.Values ) {
                $connection.name | Should Not Be $null
                $expectedConnectionName = $expectedConnectionNames | where { $_ -eq $connection.name }
                $expectedConnectionName | Should Not Be $null

                $expectedConnection = $testSettings.connectionProfiles.list | where {
                    ( $_ | gm name -erroraction ignore ) -and ( $_.name -eq $expectedConnectionName )
                }

                $expectedConnection | Should Not Be $null
                if ( $expectedConnection | gm GraphEndpoint -erroraction ignore ) {
                    $connection.GraphEndpoint | Should Not Be $null
                    if ( $expectedConnection.graphendpoint | gm authUri -erroraction ignore ) {
                        CompareUri $connection.GraphEndpoint.Authentication $epxectedConnection.GraphEndpoint.AuthUri | Should Be $true
                    }
                }

                if ( $expectedConnection ) {
                    $connection.Name | Should Be $expectedConnection.Name
                    if ( $expectedConnection | gm appid -erroraction ignore ) {
                        if ( $expectedConnection.AppId ) {
                            $connection.Identity.App.AppId | Should Be $expectedConnection.AppId
                        } else {
                            $connection.Identity.App.AppId.tostring() | Should Be '28830add-2d1b-401f-8762-f7be317e7bd3'
                        }

                        if ( $expectedConnection | gm authtype -erroraction ignore ) {
                            $connection.Identity.App.AuthType | Should Be $expectedConnection.AuthType
                        } else {
                            $connection.Identity.App.AuthType | Should Be 'Delegated'
                        }

                        if ( $expectedConnection | gm 'useragent' -erroraction ignore ) {
                            $connection.useragent | Should Be $expectedConnection.useragent
                        } else {
                            $connection.useragent | should be $testsettings.connectionProfiles.defaults.useragent
                        }

                        if ( $expectedConnection | gm 'appcredentials' -erroraction ignore ) {
                            $connection.Identity.TenantName | should be $expectedConnection.appCredentials.tenantid
                        }

                        if ( $expectedConnection | gm 'accountType' -erroraction ignore ) {
                            $expectedAllowMSA = $expectedConnection.accountType -eq 'AzureADAndPersonalMicrosoftAccount'
                            $connection.App.Identity.AllowMSA -eq $expectedAllowMSA
                        }
                    }
                }

            }
        }
    }
}
