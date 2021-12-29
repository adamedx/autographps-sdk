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

. (import-script ../client/GraphConnection)
. (import-script ../client/GraphContext)

<#
.SYNOPSIS
Gets the list of named connections.

.DESCRIPTION
Commands such as `New-GraphConnection` may be used to create connections to the Grapi API; such connections may also be defined through profile settings. The Get-GraphConnection enumerates the named connections and / or the current connection; these connections may be subsequently selected as the active connection using the Select-GraphConnection command.

Note that Get-GraphConnection emits only named connections EXCEPT that it also emits the currently active connection whether or not it is named; unless a name is explicitly specified to commands such as New-GraphConnection or Connect-GraphApi, the resulting connections are 'ad-hoc' and do not have a name; they are still valid as the current connection.

For more information on how connections may be specified using profiles, see the documentation at https://github.com/adamedx/autographps-sdk/tree/main/docs/settings.

.PARAMETER ConnectionName
The name of a named connection to retrieve. By default, if no parameters are specified to the command, all named connections are emitted. To limit output to a specific connection, specify its name with this parameter.

.PARAMETER Current
If specified, only the currently active connection is emitted. The current active connection may be configured through profile settings, or through the Connect-GraphApi and Select-GraphApi commands. Even if the current connection has no name, it is emitted

.OUTPUTS
Graph connection object.

.EXAMPLE
Get-GraphConnection

AppId                                ConnectionName Organization                         AuthType
-----                                -------------- ------------                         --------
8eee1da3-3610-45ce-8c1a-48fadfc21048 DevAccountAuto 8d10e713-08b5-425d-a3c7-7f89e316a92d AppOnly
600700fd-6097-44f0-a286-4b350bcec988 DevAccount     8d10e713-08b5-425d-a3c7-7f89e316a92d Delegated
7663bc10-5a47-4eac-b0f2-4ac3627f9227 Corp                                                Delegated
9821af78-5e32-4040-bd24-38bb07942c7c LinuxClient    8d10e713-08b5-425d-a3c7-7f89e316a92d AppOnly
6fd5d1dc-e06b-4b7d-8aee-339aa8035221 Personal                                            Delegated

In this example, no parameters are specified so all named connections, including the active connection, are emitted

.EXAMPLE
Get-GraphConnection -Current | Format-List

Id               : 11f87424-41c1-4312-9d97-0d2608db22ab
Name             : (Unnamed)
Status           : Online
Connected        : True
OrganizationId   : 7e23c95a-76f2-434e-9433-c095493255e9
User             : raheem@newjustice.org
AppID            : ac70e3e2-a821-4d19-839c-b8af4515254b
AuthType         : Delegated
Endpoint         : https://graph.microsoft.com/
AuthEndpoint     : https://login.microsoftonline.com/
ConsistencyLevel : Eventual

In this example the Current option is specified to limit output to the current active connection, and the output is piped to
Format-List so that the detail given by the additional fields not shown in table view is visible. Note that since the
connection was an ad-hoc connection with no name, the name field shows as "(Unnamed)".

.LINK
Connect-GraphApi
New-GraphConnection
Select-GraphConnection
Get-GraphCurrentConnection
Remove-GraphConnection
Get-GraphProfile
#>
function Get-GraphConnection {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, parametersetname='byname', mandatory=$true)]
        [ArgumentCompleter({
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
                               $::.GraphConnection |=> GetNamedConnection | where Name -like "$($wordToComplete)*" | select-object -expandproperty Name
                           })]
        [string] $ConnectionName,

        [parameter(parametersetname='bylist')]
        [switch] $Current
    )

    $currentConnection = $::.GraphContext |=> GetCurrentConnection

    $connections = if ( $Current.IsPresent ) {
        if ( $currentConnection ) {
            $currentConnection
        }
    } else {
        $connections = $::.GraphConnection |=> GetNamedConnection $ConnectionName $true

        $namedConnections = foreach ( $connection in $connections ) {
            if ( $currentConnection -and $connection.id -eq $currentConnection.id ) {
                $currentConnection = $null
            }
            $connection
        }

        if ( ! $ConnectionName -and $currentConnection ) {
            $currentConnection
        }

        $namedConnections
    }

    $connections
}
