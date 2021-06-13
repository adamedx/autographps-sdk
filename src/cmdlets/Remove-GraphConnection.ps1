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

. (import-script Get-GraphConnection)

<#
.SYNOPSIS
Removes a named connection from the list of named connections that can be supplied to commands such as Connect-GraphApi or Select-GraphConnection.

.DESCRIPTION
Commands such as `New-GraphConnection` may be used to create connections with an optionally associated friendly name. Such named connections may also be defined through profile settings. This convenience makes it easier to maintain multiple credentials for different use cases including management of different organizations, management of production vs. developmnt or preproduction resources, or the use of credentials with varying levels of access such as read-only vs. read-write access.

The Remove-GraphConnection command removes the specified named connection from the list of connections. Once the Remove-GraphConnection is successfully executed, the connection specified to it may not longer be referenced by name to commands like Connect-GraphApi or Select-GraphConnection.

.PARAMETER ConnectionName
The name of the connection to remove from the named connections list.

.OUTPUTS
None.

.EXAMPLE
Remove-GraphConnection TempElevatedAccessConnection

.LINK
Connect-GraphApi
New-GraphConnection
Get-GraphConnection
Get-GraphCurrentConnection
Select-GraphConnection
Get-GraphProfile
#>
function Remove-GraphConnection {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [ArgumentCompleter({
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
                               $::.GraphConnection |=> GetNamedConnection | where Name -like "$($wordToComplete)*" | select-object -expandproperty Name
                           })]
        [Alias('Name')]
        [string] $ConnectionName
    )

    begin {
        $currentConnection = $::.GraphContext |=> GetCurrentConnection
    }

    process {
        $targetConnection = Get-GraphConnection $ConnectionName

        if ( $targetConnection.Id -eq $currentConnection.Id ) {
            throw "The specified connection '$($targetConnection.Name)' may not be removed because it is the current connection for this context."
        }

        $::.GraphConnection |=> RemoveNamedConnection $ConnectionName $true
    }

    end {
    }
}
