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

. (import-script ../client/LocalProfile)

<#
.SYNOPSIS
Validates serialized or deserialized settings and when valid returns the resulting profiles and deserialization.

.DESCRIPTION
Test-GraphSettings processes an AutoGraph settings file in either serialized or deserialized form to determine whether it constitutes well-formed settings input. This processing is the same as that performed by AutoGraph at module load time, so if the command is successful, AutoGraph will also be successful when loading the settings, and if it's not successful, AutoGraph will also fail to load them. Thus the command is useful when making changes to a settings file or creating new settings, as the settings contents can be validated before inducing a runtime failure when the module is loaded.

If the input settings data are not valid, the command fails.

.PARAMETER Path
By default, Test-GraphSettings validates the file at the default location, ~/.autographps/settings.json. If the Path parameter is specified, then Test-GraphSettings validates the file present at the location specified by Path.

.PARAMETER NonStrict
By default, Test-GraphSettings fails even in cases where AutoGraph would emit a warning rather than fail an operation when processing settings at module load time or when as settings refresh is implicitly or explicitly invoked. The warnings mean that some configuration was skipped, but other valid settings are still applied. To make Test-GraphSettings treat such errors as non-fatal in the same way, specify the NonStrict parameter. Note that errors such as JSON parsing errors will still result in a failure even with NonStrict specified, which is also true for the settings validation at module load when a parsing error is encountered.

.OUTPUTS
If successful, this cmdlet returns an object that includes the following properties:

    * Path: The location of the file (if any) from which settings were read
    * DefaultProfileName: The name of the default profile (if any) specified in the settings
    * ProfileNames: The names of all profiles specified in the settings
    * ConnectionNames: The names of all connections specified in the settings
    * EndpointNames: The names of all the endpoints specified in the settings
    * Settings: The deserialized representation of the settings read from the file or from the InputObject parameter
    * ValidSettings: The deserialized representation of the subset of the settings (and their properties) represented by the Settings output property that were found to be valid by the command. This will only be different from Settings when NonStrict is specified and there is at least one settings error.

.EXAMPLE
Test-GraphSettings

   Path: ~/.autographps/settings.json

DefaultProfileName : Corp
ProfileNames       : {Corp, Developer, Production, Personal}
ConnectionNames    : {Corp, Dev, Prod, PreProd}
EndpointNames      : {Dev, PreProd}

In this example, Test-GraphSettings is invoked with no arguments, so it processes the file at the default settings file location.

.EXAMPLE
Test-GraphSettings ~/Documents/my-sharedsettings.json

   Path: ~/Documents/my-sharedsettings.json

DefaultProfileName : Company
ProfileNames       : {Internal, Partner, Production}
ConnectionNames    : {Company, PartnerConnection, Prod}
EndpointNames      : {Test, Prod}

Test-GraphSettings may also be invoked with an explicit path to a file. This could be useful for building tools that manage settings -- a "temporary" settings file could be validated, and then moved or copied to its permanent destination for instance after it is known to be correct.

.EXAMPLE
@{connections=@{list=@(
    @{name='Company';appId='65e8321f-e343-4c89-9fd7-2adb63761b40'}
    @{name='TestApp';appId='dfedd96b-0118-4f21-bfa3-f4de568868be'})}} | Test-GraphSettings

   Path:

DefaultProfileName :
ProfileNames       :
ConnectionNames    : {Company, TestApp}
EndpointNames      :

In this case, instead of specifying the settings using a file path, the InputObject parameter was used to supply objects serializable to the JSON settings schema. The specified settings contained two connections, so the output of the command includes those names using the ConnectionNames property.

.EXAMPLE
Test-GraphSettings | Select-Object -ExpandProperty Settings

defaultProfile connections             profiles
-------------- -----------             --------
Collaboration  @{list=System.Object[]} @{list=System.Object[]}

This example shows how the Settings property can be used to obtain the deserialized form of the settings. In this case,
the input originated from the default settings file -- if it were reserialized the resulting JSON would be semantically
the same as the actual settings file itself. This output could also have been obtained by reading the settings file with
Get-Content and sending that output to ConvertFrom-Json.

.EXAMPLE
'{"profiles":{"list":[{"promptColor":"magenta","name":"Work"}]},"connections":{"list":[{"appId":"This should be a guid","name":"Production"},{"appId":"895ab43e-e40f-43da-9a3b-44face21437f","name":"MyWork"}]}}' |
>>     Test-GraphSettings -NonStrict

WARNING: Property 'appId' of setting 'Admin' of type 'connections' is invalid: Specified value 'This should be a guid' is not a valid guid
WARNING: Setting 'Admin' of type 'connections' will be ignored due to an invalid value for required property 'appId'

   Path:

DefaultProfileName :
ProfileNames       : Work
ConnectionNames    : MyWork
EndpointNames      :

The supplied input via the InputObject parameter is actually JSON instead of an object. Here we see how NonStrict allows the command to succeed even when the settings specified as input are invalid. In this the conneection setting "Production" violated the constraint that its appId property must be a valid guid. While the command success, the output omits the "Production" connection because it was not valid, and only emits the one valid connection "MyWork." Additionally, the Warning output stream displays messages to the console with more detail on why the invalid connection was ignored. This behavior mirrors that of the module itself when it loads settings at startup -- invalid settings are ignored and Warning stream messages are emitted to give awareness to the user that they may need to make corrections to the settings to obtain desired functionality.

.EXAMPLE
$updatedSettings | Test-GraphSettings -NonStrict |
    Select-Object -ExpandProperty ValidSettings |
    ConvertTo-Json -Depth 4 | Out-File ~/alternatesettings.json

WARNING: Property 'appId' of setting 'Production of type 'connections' is invalid: Specified value 'This should be a guid' is not a valid guid
WARNING: Setting 'Production' of type 'connections' will be ignored due to an invalid value for required property 'appId'

In this example, settings are specified through the InputObject parameter and the ValidSettings property of the command's output is serialized and written to the file. The structure of the ValidSettings property is the same as that of Settings, except that the settings and properties that it contains are the subset of those from Settings that are "valid," i.e. did not have data type or reference errors. When there are no errors, the Settings and ValidSettings properties are the same. Since the command terminates with an error and no output when any errors are encountered and the NonStrict parameter is not specified, ValidSettings and Settings can only differ when NonStrict is specified. This example shows how to create a new, error-free settings file from settings that contain errors.

Note that in this case Warning stream output is still output to the console indicating the errors that were encountered and filtered out of the settings represented by ValidSettings.

.EXAMPLE
$newSettings | Test-GraphSettings -NonStrict -OutVariable settingsInfo 3>&1 | out-null
$settingsInfo.ValidSettings

Name                           Value
----                           -----
endpoints                      {list}
defaultProfile
connections                    {list}
profiles                       {list}

This example is similar to previous examples that use NonStrict, but in this case the Warning stream output is suppressed by
redirecting it to the Output stream. The actual output is sent to the variable named 'settingsInfo' specified by the OutVariable parameter
of Test-GraphSettings. The variable is then evaluated and emitted to the console. This demonstrates an approach for validating
settings using NonStrict and capturing the results without also emitting to the Warning stream.

.LINK
Get-GraphProfile
#>
function Test-GraphSettings {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(parametersetname='path', position=0)]
        [string] $Path,
        [parameter(parametersetname='data', valuefrompipeline=$true, mandatory=$true)]
        [object] $InputObject,

        [switch] $NonStrict
    )

    $settingsPath = if ( $Path ) {
        $Path
    } elseif ( ! $InputObject ) {
        $::.LocalProfile |=> GetSettingsFileLocation
    }

    $failOnWarnings = ! $NonStrict.IsPresent -or ( $WarningPreference -eq 'Stop' )

    $settings = new-so LocalSettings $settingsPath $true $failOnWarnings
    $settings |=> Load $false $InputObject

    $defaultProfileName = $null
    $profileNames = $null
    $endpointNames = $null
    $connectionNames = $null
    $serializableSettings = $null

    if ( $settings.settingsData ) {
        # This method returns only the settings and properties that are validated
        $serializableSettings = $::.LocalProfile |=> GetValidatedSerializableSettings $settings

        $defaultProfileName = $serializableSettings.defaultProfile

        $profilenames = if ( $serializableSettings.profiles.list ) {
            $serializableSettings.profiles.list.name
        }

        $connectionNames = if ( $serializableSettings.connections.list ) {
            $serializableSettings.connections.list.name
        }

        $endpointNames = if ( $serializableSettings.endpoints.list ) {
            $serializableSettings.endpoints.list.name
        }
    } elseif ( $Path ) {
        throw "The specified settings file '$Path' could not be found."
    }

    $settingsInfo = [PSCustomObject] @{
        Path = $settingsPath
        Settings = $settings.settingsData
        ValidSettings = $serializableSettings
        DefaultProfileName = $defaultProfileName
        ProfileNames = $profileNames | sort-object
        ConnectionNames = $connectionNames | sort-object
        EndpointNames = $endpointNames | sort-object
    }

    $settingsInfo.pstypenames.insert(0, 'AutoGraph.SettingsInfo')

    $settingsInfo
}

