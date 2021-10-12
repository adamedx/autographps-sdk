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


. (import-script ../client/GraphContext)
. (import-script ../client/LogicalGraphManager)

<#
.SYNOPSIS
Set-GraphConnectionStatus sets the status of the current connection or specified Graph.

.DESCRIPTION
A connection's status can be either 'Online' or 'Offline'. By default, a connection's status is 'Online,' which means that if you make requests to using the connection, an access token will be acquired if one is not already present and then a request will be sent to the Graph API endpoint for the connection via the network. To suppress token acquisition and any network access, set the connection to Offline. Its status can be later restored to 'Online'.

.PARAMETER Status
The status can be set to 'Online' or 'Offline'.

.PARAMETER Graph
The Graph is an object that contains a connection. If a Graph is specified, instead of the connection status of the current connection being changed, the status of the connection associated with the Graph parameter is updated to the value specified by the Status parameter.

.OUTPUTS
This command produces no output.

.EXAMPLE
Set-GraphConnectionStatus Offline

This sets the current connection's status to offline.

.LINK
Connect-GraphApi
#>
function Set-GraphConnectionStatus {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, mandatory=$true)]
        [GraphConnectionStatus] $Status,

        [parameter(valuefrompipeline=$true)]
        $Graph
    )
    Enable-ScriptClassVerbosePreference

    $context = if ( $Graph ) {
        if ( $Graph -is [String] ) {
            $specificContext = $::.LogicalGraphManager |=> Get |=> GetContext $Graph
            if (! $specificContext ) {
                throw "The specified Graph '$Graph' could not be found"
            }
        } elseif ( $graph | gm Details -erroraction ignore ) {
            $Graph.details
        } else {
            throw "Specified Graph argument '$Graph' is not a valid type returned by Get-Graph"
        }
    } else {
        $::.GraphContext |=> GetCurrent
    }

    $context.connection |=> SetStatus $Status
}
