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
Gets the list of profiles defined in the settings file.

.DESCRIPTION
Profiles are a way to customize the behavior of this module's commands through a configuration file. Behaviors such as pre-configured named connections, logging levels, and default Graph API versions are among the options that may be customized. By default, the settings file used by the module is located at ~/.autographps/settings.json. At startup, if a default profile is configured in the settings file, the settings from that profile are applied to the session and apply unless overridden by subsequent commands.

Get-GraphProfile returns the list of all profiles defined in the settings file and it also shows all of the settings defined for the profile. This is useful for understanding what behaviors may be currently customized by a profile, for picking a new profile, or simply for validating that an update to the settings configuration file is accurately reflected in the currently defined profiles.

The active profile may be changed through the Select-GraphProfile command.

See the documentation at https://github.com/adamedx/autographps-sdk/tree/main/docs/settings for more details on what customizations may be made using profiles as well as the structure of the settings configuration file that defines them.

.PARAMETER ProfileName
The name of a specific profile to emit. By default, if no parameters are specified to the command, all profiles are emitted. To emit a specific profile, specify its name through this parameter.

.PARAMETER Current
Specify the Current parameter to emit only the currently active profile (if any). This is useful for seeing what settings are currently active.

.OUTPUTS
Graph profile object.

.EXAMPLE
Get-GraphProfile DeveloperProfile


   ProfileName: DeveloperProfile

Connection        : DevAccount
IsDefault         : False
AutoConnect       :
NoBrowserSigninUI :
InitialApiVersion : beta
LogLevel          : Full

In this example, the profile named DeveloperProfile was specified using the ProfileName parameter, and the details of the settings configured in this profile were displayed.

.EXAMPLE
Get-GraphProfile -Current

   ProfileName: Work

Connection        : WorkOrganization
IsDefault         : True
AutoConnect       :
NoBrowserSigninUI :
InitialApiVersion :
LogLevel          :

In this example the Current parameter is used to show the details of the currently active profile

.LINK
Select-GraphProfile
New-GraphConnection
#>
function Get-GraphProfile {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, parametersetname='byname', mandatory=$true)]
        [ArgumentCompleter({
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
                               $::.LocalProfile |=> GetProfiles | where name -like "$($wordToComplete)*" | select-object -expandproperty name
                           })]
        [string] $ProfileName,

        [parameter(parametersetname='bylist')]
        [switch] $Current
    )

    $profiles = if ( $Current.IsPresent ) {
        $::.LocalProfile |=> GetCurrentProfile
    } else {
        $allProfiles = $::.LocalProfile |=> GetProfiles

        if ( $ProfileName -and $allProfiles ) {
            $allProfiles | where name -eq $ProfileName
        } else {
            $allProfiles | sort-object Name
        }
    }

    foreach ( $matchingProfile in $profiles ) {
        $matchingProfile |=> ToPublicProfile
    }
}
