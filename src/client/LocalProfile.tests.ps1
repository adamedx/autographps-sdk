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

function EnableSettings($settingsPath, $connectionCreator)  {
    $settingsPath = if ( $settingsPath ) {
        $settingsPath
    } else {
        $testSettingsFilePath
    }

    if ( test-path env:AUTOGRAPH_BYPASS_SETTINGS ) {
        remove-item env:AUTOGRAPH_BYPASS_SETTINGS
    }

    set-item env:AUTOGRAPH_SETTINGS_FILE $settingsPath

    $connectionScriptBlock = if ( $connectionCreator ) {
        $connectionCreator
    } else {
        (get-command New-GraphConnection).ScriptBlock
    }

    $warningpreference = 'silentlycontinue'
    $::.LocalSettings |=> __initialize
    $::.LocalConnectionProfile |=> __initialize
    $::.GraphConnection |=> __initialize
    $::.LocalProfile |=> __initialize $connectionScriptBlock
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
        if ( $dataPropertyName -eq 'connection' -and $expectedValue ) {
            $existingConnection = $testSettings.connections.list | where {
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
        [ValidateSet('Auto', 'Default', 'Session', 'Eventual')]
        [string] $ConsistencyLevel = 'Auto',
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
        ConsistencyLevel = $ConsistencyLevel
    }

    $mockConnections.Add($connection.Id, $connection)

    $connection
}


# This was a workaround for the MockContext parmaeter of
# Add-MockInScriptClassScope apparently not working despite
# passing tests in its own module :(. Now that Add-MockInScriptClassScope
# is not being used, it's still used to pass state to the mock
# $NewGraphConnectionMockScript.
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

        It 'Should result in no profiles returned to the Get-GraphProfile command and no errors' {
            { Get-GraphProfile | out-null } | Should Not Throw
            Get-GraphProfile | Should Be $null
        }

        It 'Should result in the default profile being returned as $null' {
            Get-GraphProfile -current | Should Be $null
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

        It 'Should enumerate the expected connections' {
            $wellFormedConnections = $testSettings.connections.list |
              where { $_ | gm name -erroraction ignore }

            $expectedConnectionNames = $wellFormedConnections | where name -notin @(
                'ConnectionWithNonexistentEndpoint'
                'ConnectionWithBadEndpoint'
                'MalformedAppId'
                'BadConsistencyLevel'
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
            # Note: We originally used Add-MockInScriptClassScope to inject an override for New-GraphConnection.
            # This actually caused subsequent tests in this area to fail, which wasn't a problem until
            # some additional tests were added outside of this file. At the point we switched to an alternate
            # mechanism. More details on the original problems and workarounds:
            #
            #     The -MockContext parameter of Add-MockInScriptClassScope does not seem to work -- we'll instead
            #     use a custom class, $::.MockContext, to pass information to the Mock function
            #     Also note that Add-MockInScriptClassScope is destructive -- it seems that once the context
            #     block is executed, certain state becomes corrupted and various ScriptClass methods no
            #     longer function -- so the tests can only be run once.
            #
            # This has now been changed to directly access a member on the LocalProfile class through EnableSettings --
            # below we pass in the override scriptblock to replace New-GraphConnection. This more direct injection
            # is inelegant but avoids the state corruption issues of Add-MockInScriptClassScope.
            # REMOVED: Add-MockInScriptClassScope LocalProfile New-GraphConnection $NewGraphConnectionMockScript
            EnableSettings $null $NewGraphConnectionMockScript
        }

        AfterAll {
            DisableSettings
        }

        It 'Should be executing tests with loading of profile settings enabled ' {
            test-path env:AUTOGRAPH_BYPASS_SETTINGS | Should Be $false
            (get-item env:AUTOGRAPH_SETTINGS_FILE).value | Should BeExactly $testSettingsFilePath
        }

        It "Should have the expected default profile" {
            $profileSettings = Get-GraphProfile -current
            $profileSettings.ProfileName | Should Be $testSettings.defaultProfile
            $profileSettings.InitialApiVersion | Should Be ( $testSettings.profiles.list |
              where {
                  if ( $_ | gm name -erroraction ignore ) {
                      $_.name -eq $profileSettings.ProfileName
                  }
              } | select -expandproperty InitialApiVersion )
        }

        It "Should return the expected set of profiles from GetProfiles sorted alphabetically by profile name" {
            $profiles = Get-GraphProfile

            $expectedProfileNames = $testSettings.profiles.list | where { $_ | gm name -erroraction ignore } | select -expandproperty name | select-object -unique | sort-object
            Compare-object $expectedProfileNames $profiles.ProfileName -syncwindow 0 | Should Be $null
        }

        It "Should ignore settings from a duplicated profile" {
            $profiles = Get-GraphProfile

            $expectedProfileData = $testSettings.profiles.list |
              where {
                  if ( $_ | gm name -erroraction ignore ) {
                      $_.name -eq 'DuplicateSettings2'
                  }
              }  | select -first 1

            $expectedProfile = [PSCustomObject] @{
                ProfileName = $expectedProfileData.Name
                Connection = $null
                IsDefault = $false
                AutoConnect = $null
                NoBrowserSigninUI = $null
                InitialApiVersion = $testSettings.profiles.defaults.InitialApiVersion
                LogLevel = $null
            }

            $ignoredProfileData = $testSettings.profiles.list |
              where {
                  ( $_ | gm name -erroraction ignore ) -and ( $_.name -eq 'DuplicateSettings2' )
              } | select -last 1

            $ignoredProfile = [PSCustomObject] @{
                ProfileName = $ignoredProfileData.Name
                Connection = $null
                IsDefault = $false
                AutoConnect = $null
                NoBrowserSigninUI = $null
                InitialApiVersion = $testSettings.profiles.defaults.InitialApiVersion
                LogLevel = $ignoredProfileData.LogLevel
            }

            $actualProfile = $profiles | where ProfileName -eq 'DuplicateSettings2'

            Compare-object $expectedProfile.psobject.properties $actualProfile.psobject.properties -syncwindow 0 | Should Be $null
            # Name and ProfileName are expected differences, but IsDefault is not part of the raw data,
            # so these cancel out and the expected mismatches is just the count of properties on the raw data object
            (Compare-object $expectedProfile.psobject.properties $ignoredProfile.psobject.properties -syncwindow 0).length | Should Be ( ($ignoredProfileData.psobject.properties | measure-object).count )
        }

        It "Should include the initial api version of beta in all versions except when overridden due to inclusion of initialApi version of beta in the defaults section" {
            $profiles = Get-GraphProfile
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
            $profiles = Get-GraphProfile
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
                    Connection = $null
                    IsDefault = $expectedProfileData.Name -eq $defaultProfile
                    AutoConnect = $null
                    NoBrowserSigninUI = $null
                    InitialApiVersion = $null
                    LogLevel = $null
                }

                AddExpectedProperties $expectedProfileData $expectedProfileProperties LogLevel, InitialApiVersion, Connection @{Connection='connection'}
                $expectedProfile = [PSCustomObject] $expectedProfileProperties

                Compare-object $expectedProfile.psobject.properties.Name $actualProfile.psobject.properties.Name -syncwindow 0 | Should Be $null
                # There is something strange about the "." syntax for ".value" on these objects -- it sometimes
                # results in $null, but only when passed to compare-object! Working around it select-object :(
                Compare-object ( $expectedProfile.psobject.properties | select-object -expandproperty Value ) ( $actualProfile.psobject.properties | select-object -expandproperty Value ) -syncwindow 0 | Should Be $null
            }
        }

        It "Should have the expected endpoints" {
            $profiles = $::.LocalProfile |=> GetProfiles

            $actualConnections = $::.MockContext.Connections.Values

            $wellFormedConnections = $testSettings.connections.list |
              where { $_ | gm name -erroraction ignore }

            $expectedConnections = $wellFormedConnections | where name -notin @(
                'ConnectionWithNonexistentEndpoint'
                'ConnectionWithBadEndpoint'
                'MalformedAppId'
                'BadConsistencyLevel'
            )

            # This assumes that this particular test file has a reference to every
            # valid endpoint listed in the file
            $referencedEndpoints = @{}

            foreach ( $graphConnection in $actualConnections ) {
                $expectedConnection = $expectedConnections | where Name -eq $graphConnection.Name

                $expectedEndpoint = if ( $expectedConnection ) {
                    $testSettings.endpoints.list | where {
                        if ( ( $_ | gm name -erroraction ignore ) -and ( $_ | gm graphuri -erroraction ignore ) ) {
                            if ( $expectedConnection | gm endpoint ) {
                                $_.Name -eq $expectedConnection.endpoint
                            }
                        }
                    }
                }

                # If the connection setting has an endpoint, make sure it shows up in the actual connection
                # We can assume these connections are valid given the filtering done earlier
                if ( $expectedEndpoint -and ( $expectedEndpoint.Name -notin 'Public', 'ChinaCloud', 'USGovernmentCloud', 'GermanyCloud' ) ) {
                    $referencedEndpoints.Add($expectedEndpoint.name, $expectedEndpoint)
                    CompareUri $graphConnection.GraphEndpoint.Graph $expectedEndpoint.graphUri | Should Be $true
                    CompareUri $graphConnection.GraphEndpoint.Authentication $expectedEndpoint.authUri | Should Be $true
                    CompareUri $GraphConnection.GraphEndpoint.GraphResourceUri $ExpectedEndpoint.resourceUri | Should Be $true
                  }
            }

            $referencedEndpoints.Count | Should Be 2
        }

        It "Should have the expected connections" {
            $wellFormedConnections = $testSettings.connections.list |
              where { $_ | gm name -erroraction ignore }

            $expectedConnectionNames = $wellFormedConnections | where name -notin @(
                'ConnectionWithNonexistentEndpoint'
                'ConnectionWithBadEndpoint'
                'MalformedAppId'
                'BadConsistencyLevel'
            ) | select -expandproperty name

            $mockConnections = $::.MockContext.Connections

            $mockConnections.Count | Should Be $expectedConnectionNames.Length

            foreach ( $connection in $mockConnections.Values ) {
                $connection.name | Should Not Be $null
                $expectedConnectionName = $expectedConnectionNames | where { $_ -eq $connection.name }
                $expectedConnectionName | Should Not Be $null

                $expectedConnection = $testSettings.connections.list | where {
                    ( $_ | gm name -erroraction ignore ) -and ( $_.name -eq $expectedConnectionName )
                }

                $expectedConnection | Should Not Be $null
                if ( $expectedConnection | gm GraphEndpoint -erroraction ignore ) {
                    $connection.GraphEndpoint | Should Not Be $null
                    if ( $expectedConnection.graphendpoint | gm authUri -erroraction ignore ) {
                        CompareUri $connection.GraphEndpoint.Authentication $expectedConnection.GraphEndpoint.AuthUri | Should Be $true
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
                            $connection.useragent | should be $testsettings.connections.defaults.useragent
                        }

                        if ( $expectedConnection | gm 'tenantid' -erroraction ignore ) {
                            $connection.Identity.TenantName | should be $expectedConnection.tenantid
                        }

                        if ( $expectedConnection | gm 'accountType' -erroraction ignore ) {
                            $expectedAllowMSA = $expectedConnection.accountType -eq 'AzureADAndPersonalMicrosoftAccount'
                            $connection.App.Identity.AllowMSA -eq $expectedAllowMSA
                        }

                        if ( $expectedConnection | gm 'consistencyLevel' -erroraction ignore ) {
                            $connection.consistencyLevel | should be $expectedConnection.consistencyLevel
                        }
                    }
                }

            }
        }
    }
}
