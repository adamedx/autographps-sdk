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

function Get-GraphProfileSettings {
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
