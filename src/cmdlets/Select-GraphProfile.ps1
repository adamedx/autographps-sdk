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
Sets the current active profile and makes the relevant settings take effect.

.DESCRIPTION
Profiles are a way to customize the behavior of this module's commands through a configuration file. Behaviors such as pre-configured named connections, logging levels, and default Graph API versions are among the options that may be customized. By default, the settings file used by the module is located at ~/.autographps/settings.json. At startup, if a default profile is configured in the settings file, the settings from that profile are applied to the session and apply unless overridden by subsequent commands.

Select-GraphProfile may be used to change the active profile after the module has loaded; this will cause some, but not all settings from the profile to apply immediately; some settings are only applied at startup. For example, logging levels are one option that can apply at any time, so changing the profile through Select-GraphProfile can change the Graph API logging level of subsequent commands.

Every profile has a name -- invoke Select-GraphProfile with the desired named profile to set the active profile and applicable settings. The list of profiles defined in the settings file may be retrieved using Get-GraphProfile

See the documentation at https://github.com/adamedx/autographps-sdk/tree/main/docs/settings for more details on what customizations may be made using profiles as well as the structure of the configuration file that defines them.

.PARAMETER ProfileName
The name of the profile to set as the active profile.

.OUTPUTS
None.

.EXAMPLE
Select-GraphProfile DeveloperProfile

.LINK
Connect-GraphApi
Get-GraphProfile
New-GraphConnection
Get-GraphConnection
Select-GraphConnection
#>
function Select-GraphProfile {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [ArgumentCompleter({
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
                               $::.LocalProfile |=> GetProfiles | where name -like "$($wordToComplete)*" | select-object -expandproperty name
                           })]
        [string] $ProfileName
    )

    $::.LocalProfile |=> SetCurrentProfile $ProfileName $true
}
