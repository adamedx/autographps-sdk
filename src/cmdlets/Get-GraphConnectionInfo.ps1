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
. (import-script ../client/LogicalGraphManager)

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

<#
.SYNOPSIS
Retrieves information about the endpoint and credentials of the current or specified Graph.

.DESCRIPTION
To access Microsoft Graph, the module's commands maintain a state known as a "Graph" that contains information on how to connect to the Graph. This connection information includes the following information:

* The nedpoint URI used to access the Graph, e.g. https://graph.microsoft.com
* The AppId of the Aure Active Directory application used to obtain an access token for the endpoint URI
* The access token used to access the Graph if one has already been granted.

The Get-GraphConnectionInfo command returns a structure that represents the information described above.

.PARAMETER Graph
By default, Get-GraphConnectionInfo returns information about the current Graph; the Graph parameter allows this to be overridden so that information may be returned about an arbitrary Graph.

.OUTPUTS
A PSCustomObject that contains the following fields:

* AppId: The Azure Active Directory AppId of the Graph. By default, this is the AppId of the AutoGraphPS application as registered with Azure.
* Endpoint: The URI endpoint of the Microsoft Graph service instance, e.g.https://graph.microsoft.com
* User: If the user has signed in, this is the user principal name of the user, i.e. user@domain.com
* Status: The value Online or Offline, which can be set with Set-GraphConnectionStatus
* Connection: The full GraphConnection PSCustomObject that can be used with the Connection parameter of commands like Get-GraphItem, Connect-Graph, etc.

.NOTES
In this module, there are no commands to create or find new Graph objects; the module does export interfaces for use in building commands that do this. So by default there is only one active Graph, and it points to the v1.0 Graph API version. Commands such as Get-GraphItem and Invoke-GraphRequest allow you to override the API version with a Version parameter while continuing to use the current Graph's connection information to access the Graph service.

.EXAMPLE
Get-GraphConnectionInfo

AppId      : 9825d80c-5aa0-42ef-bf13-61e12116704c
Endpoint   : https://graph.microsoft.com/
User       : jones@blackbelt.org
Status     : Online
Connection : @{ScriptClass=; NoBrowserUI=False; Scopes=System.String[]; Connected=True; Identity=; GraphEndpoint=; Status=Online;
             PSTypeName=GraphConnection}

.LINK
Connect-Graph
New-GraphConnection
#>
}
