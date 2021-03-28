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

ScriptClass LocalSettings {
    $settingsPath = $null
    $settingsData = $null
    $lastLoadError = $null

    function __initialize($settingsPath) {
        $this.settingsPath = $settingsPath
    }

    function Load {
        write-verbose "Attempting to load settings from path '$this.settingsPath'"

        $this.settingsData = if ( $this.settingsPath -and ( test-path $this.settingsPath ) ) {
            $settingsContent = try {
                get-content $this.settingsPath | out-string
            } catch {
                $this.lastLoadError = $_.exception
                write-verbose "Failed to read settings file at '$($this.settingsPath)'"
                write-verbose $_.exception
            }

            if ( $settingsContent ) {
                try {
                    $settingsContent | convertfrom-json
                } catch {
                    $this.lastLoadError = $_.exception
                    write-warning "Unable to load settings from file '$($this.settingsPath)' because it could not be parsed as valid JSON content"
                    write-warning $_.exception

                }
            }

            $this.lastLoadError = $null

            write-verbose "Successfully read AutoGraph settings file at '$($this.settingsPath)'"
        } else {
            write-verbose "No settings were loaded because the specified path '$($this.settingsPath)' was not a valid path or no file could be accessed there."
        }
    }

    function GetSettingsLocation {
        $this.settingsPath
    }

    function GetSettingValue($settingName) {
        if ( $this.settingsData -and ( $this.settingsData | gm $settingName -erroraction Ignore ) ) {
            $this.settingsData.$settingName
        }
    }

    function GetSettings($settingsType, $context) {
        if ( $this.settingsData ) {
            $settingsData = __ReadGroupData $settingsType
            __GetSettingsFromGroupData $settingsType $settingsData $context
        }
    }

    function __ReadGroupData($groupName) {
        $defaultItem = @{}
        $items = @{}

        $groupData = if ( $this.settingsData -and ( $this.settingsData | gm $groupName -erroraction Ignore ) ) {
            $this.settingsData.$groupName
        }

        if ( $groupData ) {
            $defaultItem = if ( $groupData | gm defaults -erroraction Ignore ) { $groupData.defaults }
            $list = if ( $groupData | gm list -erroraction ignore ) { $groupData.list }

            if ( $list ) {
                foreach ( $listItem in $list ) {
                    if ( $listItem | gm name -erroraction ignore ) {
                        if ( ! $items.ContainsKey($listItem.Name ) ) {
                            $items.Add($listItem.name, $listItem)
                        } else {
                            write-warning "Duplicate setting '$($listItem.name)' found in settings file '$($this.settingsPath)', the duplicate will be ignored; the issue can be fixed by updating the settings file."
                        }
                    }
                }
            }
        }

        @{
            defaultItem = $defaultItem
            list = $items
        }
    }

    function __GetSettingsFromGroupData($groupName, $groupData, $context) {
        $validSettings = @{}

        if ( $groupData ) {
            $defaultSetting = __GetDefaultSettingForGroup $groupName $groupData $context
            $settingInfo = $this.scriptclass |=> __GetSettingTypeInfo $groupName

            foreach ( $setting in $groupData.list.values ) {
                $validSetting = $defaultSetting.Clone()

                $newSetting = __GetValidSetting $groupName $setting $context
                if ( $newSetting ) {
                    foreach ( $propertyName in $newSetting.keys ) {
                        $validSetting[$propertyName] = $newSetting[$propertyName]
                    }
                }

                # Allow default settings to be added unless FailOnIInvalidProperty is set
                if ( $newSetting -or ! $settingInfo.FailOnInvalidProperty ) {
                    $validSettings.Add($validSetting['name'], $validSetting)
                }
            }
        }

        $validSettings
    }

    function __GetDefaultSettingForGroup($groupName, $groupData, $context) {
        if ( $groupData.defaultItem ) {
            __GetValidSetting $groupName $groupData.defaultItem $context $true
        } else {
            @{}
        }
    }

    function __GetValidSetting($settingType, $setting, $context, $isDefault) {
        $validSetting = @{}
        $settingName = if ( ! $isDefault ) { $setting.name } else { @{} }
        $validations = $this.scriptclass |=> __GetPropertyReaders $settingType
        $settingInfo = $this.scriptclass |=> __GetSettingTypeInfo $settingType

        foreach ( $propertyName in $validations.keys ) {
            if ( $isDefault -and $propertyName -eq 'name' ) {
                continue
            }

            $validation = $validations[$propertyName]
            $propertyReaderScript = if ( $validation ) {
                $this.scriptclass |=> __GetPropertyReaderScript $validation
            }

            $propertyValue = if ( $setting | gm $propertyName -erroraction ignore ) {
                $setting.$propertyName
            }

            $result = if ( $validation -and ! ( ! $propertyValue -and ! $validation.Required ) ) {
                . $propertyReaderScript $propertyValue $context
            }

            if ( $result ) {
                if ( $result.ContainsKey('Error') ) {
                    write-warning "Property '$propertyName' of setting '$settingName of type '$settingType' is invalid: $($result.error)"
                    if ( $settingInfo.FailOnInvalidProperty -or ( $validation.Required -and ! $isDefault ) ) {
                        write-warning "Setting '$settingName' of type '$settingType' will be ignored due to an invalid value for required property '$propertyName'"
                        $validSetting = $null
                        break
                    } else {
                        continue
                    }
                }

                if ( ! $result.value -and $validation.Required ) {
                    write-warning "Property '$propertyName' of setting '$settingName' of type '$settingType' is a required property but was not set -- the setting will be ignored"
                    $validSetting = $null
                    break
                }

                $validSetting.Add($propertyName, $result.Value)
            }
        }

        if ( $validSetting -ne $null ) {
            $validSetting
        }
    }

    static {
        $propertyReaders = $null
        $settingTypeInfo = $null

        function __initialize {
            $this.propertyReaders = @{}
            $this.settingTypeInfo = @{}
        }

        function RegisterSettingProperties([string] $settingType, [HashTable] $propertyReaders, $failOnInvalidProperty) {
            $settingTypePropertyReaders = $propertyReaders[$settingType]

            if ( ! $settingTypePropertyReaders ) {
                $settingTypePropertyReaders = @{}
                $this.propertyReaders.Add($settingType, $settingTypePropertyReaders)
                $this.settingTypeInfo.Add($settingType, @{FailOnInvalidProperty=$failOnInvalidProperty})
            }

            foreach ( $property in $propertyReaders.Keys ) {
                $settingTypePropertyReaders.Add($property, $propertyReaders[$property])
            }
        }

        function RefreshBehaviorsFromSettings {
            $updaters = __GetPropertyUpdaters

            foreach ( $updater in $updaters ) {
                . $updater
            }
        }

        function __GetSettingTypeInfo($settingType) {
            $result = $this.settingTypeInfo[$settingType]

            if ( $result ) {
                $result
            } else {
                @{}
            }
        }

        function __GetPropertyReaders($settingType) {
            $result = $this.propertyReaders[$settingType]

            if ( $result ) {
                $result
            } else {
                @{}
            }
        }

        function __GetPropertyUpdaters {
            foreach ( $setting in $this.propertyReaders.Values ) {
                foreach ( $propertyReader in $setting.values ) {
                    if ( $propertyReader['Updater'] ) {
                        $propertyReader['Updater']
                    }
                }
            }
        }

        function __GetPropertyReaderScript($propertyReader) {
            $propertyTypeReaders[$propertyReader.Validator]
        }

        $propertyTypeReaders = @{
            UriValidator = {
                param($value, $context)
                try {
                    @{Value = ([Uri] $value)}
                } catch {
                    @{Error = "The specified URI is invalid"}
                }
            }
            StringValidator = {
                param($value, $context)
                if ( $value -isnot [string] ) {
                    @{ Error = "Expecting a string, but received a $($value.gettype().tostring())" }
                } else {
                    @{Value = [string] $value }
                }
            }
            StringArrayValidator = {
                param($value, $context)
                if ( $value -isnot [string[]] -and $value -isnot [object[]] ) {
                    @{ Error = "Expecting a string array ([string[]]), but received a $($value.gettype().tostring())" }
                } else {
                    @{Value = [string[]] $value }
                }
            }
            GuidStringValidator = {
                param($value, $context)
                $guidValue = if ( $value -isnot [guid] ) {
                    try {
                        @{Value = [guid] $value}
                    } catch {
                    }
                }

                if ( $guidValue ) {
                    $guidValue
                } else {
                    @{ Error = "Specified value '$value' is not a valid guid" }
                }
            }
            TenantValidator = {
                param($value, $context)
                $tenant = if ( $value -is [guid] ) {
                    $value.tostring()
                } elseif ( $value -is [string] ) {
                    # A valid tenant in domain form has at least one '.' char
                    if ( $value.contains('.') ) {
                        $value
                    } else {
                        try {
                            ([guid] $value).tostring()
                        } catch {
                        }
                    }
                }

                if ( $tenant ) {
                    @{Value = $tenant}
                } else {
                    @{Error = "Specified value '$value' is not a valid tenant identifier in domain or guid format" }
                }
            }
            CertificatePathValidator = {
                param($value, $context)
                if ( $value -like "cert:*" -or $value -like "*.pfx" ) {
                    @{ Value = $value }
                } else {
                    @{ Error = "The specified certificate path '$value' is not a valid file system path or PowerShell cert: drive path" }
                }
            }
            NameValidator = {
                param($value, $context)
                if ( ! $value ) {
                    @{ Error = "The 'name' property must be a non-empty string" }
                } else {
                    @{Value = $value }
                }
            }
            BooleanValidator = {
                param($value, $context)
                if ( $value -isnot [boolean] ) {
                    @{ Error = "Expecting a boolean, but received a $($value.gettype().tostring())" }
                } else {
                    @{Value = [boolean] $value }
                }
            }
            AutoProtocolValidator = {
                param($value, $context)
                if ( $value -notin @('v1', 'v2') ) {
                    @{ Error = "Expecting a value in (v1, v2)" }
                } else {
                    @{ Value = $value }
                }
            }
            AppCredentialValidator = {
                param($value, $context)
                $valueData = @{}

                'tenantId', 'certificatePath', 'certificateName' | foreach {
                    if ( $value | gm $_ -erroraction ignore ) {
                        $valueData.Add($_, $value.$_)
                    }
                }

                if ( ! $valueData['tenantId'] ) {
                    @{ Error = "Application credentials value is missing required field 'tenantId'" }
                } else {
                    @{ Value = $valueData }
                }
            }
            EndpointValidator = {
                param($value, $endpoints)
                $errorValue = if ( ! ( $::.GraphEndpoint |=> IsWellKnownCloud $value ) ) {
                    $customEndpoint = $endpoints[$value]

                    if ( ! $customEndpoint ) {
                        @{ Error = "Unknown endpoint '$value' was specified" }
                    }
                }

                if ( $errorValue ) {
                    $errorValue
                } else {
                    @{Value = $value}
                }
            }
            ConnectionValidator = {
                param($value, $connections)
                $connection = $connections[$value]

                if ( ! $connection ) {
                    @{ Error = "Unknown connection '$value' was specified" }
                } else {
                    @{Value = $value}
                }
            }
        }
    }
}

$::.LocalSettings |=> __initialize
