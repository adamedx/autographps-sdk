# Copyright 2019, Adam Edwards
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

. (import-script ../client/GraphContext)

function Disconnect-Graph {
    [cmdletbinding()]
    param(
        [PSTypeName('GraphConnection')] $Connection
    )
    Enable-ScriptClassVerbosePreference

    if ( $Connection ) {
        $Connection |=> Disconnect
    } else {
        $::.GraphContext |=> DisconnectCurrentConnection
    }

<#
.SYNOPSIS
Removes cached access token credential information from the Connection object of the current Graph so that a new token must be acquired to access the Graph through the Connection

.DESCRIPTION
The Connect-Graph command explicitly invokes a sign-in for a Connection object such as that for the current Graph in order to obtain an access token that can then be used to make REST calls to the Graph. All commands that access the Graph service do this implicitly as well. The Disconnect-Graph command removes the acquired credential so that a new credential must be re-acquired before a successful request can be made to Graph.

If the Connection has no associated credential, the command has no effect and succeeds.

.PARAMETER Connection
By default, Disconnect-Graph operates on the Connection object associated with the default Graph. To disconnect a connection other than the default, specify this parameter with a Connection object like that returned by the New-GraphConnection command.

.OUTPUTS
None.

.EXAMPLE
Disconnect-Graph

This command disconnects the current Graph's connection. Any subsequent Graph acccess will be preceded by a credential acquisition such as an interactive sign-in for delegated authentication scenarios or a non-interactive flow using a private key for app-only flows.

.LINK
Connect-Graph
New-GraphConnection
Get-GraphConnectionInfo
#>
}

