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


. (import-script ../Client/GraphContext)
. (import-script ../Client/LogicalGraphManager)

function Get-GraphConnectionInfo {
    [cmdletbinding()]
    param(
        [parameter(position=0, valuefrompipeline=$true)]
        $Graph = $null
    )

    $context = if ( $Graph ) {
        if ( $Graph -is [String] ) {
            $specificContext = $::.LogicalGraphManager |=> Get |=> GetContext $Graph
            if (! $specificContext ) {
                throw "The specified Graph '$Graph' could not be found"
            }
            $specificContext
        } elseif ( $graph | gm Details -erroraction ignore ) {
            $Graph.details
        } else {
            throw "Specified Graph argument '$Graph' is not a valid type returned by Get-Graph"
        }
    } else {
        $::.GraphContext |=> GetCurrent
    }

    [PSCustomObject] @{
        AppId = $context.connection.identity.app.appid
        Endpoint = $context.connection.graphendpoint.graph
        User = $context.connection.identity.GetUserInformation().UserId
        Status = $context.connection.getstatus()
        Connection = $context.connection
    }
}
