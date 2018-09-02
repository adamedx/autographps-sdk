# Copyright 2018, Adam Edwards
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

. (import-script ../Client/GraphConnection)
. (import-script ../Client/GraphContext)
. (import-script ../Client/LogicalGraphManager)
. (import-script New-GraphConnection)

function Connect-Graph {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0)]
        [parameter(parametersetname='simple')]
        [parameter(parametersetname='reconnect')]
        [String[]] $ScopeNames = $null,

        [parameter(parametersetname='simple')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [parameter(parametersetname='simple')]
        [string] $AppId = $null,

        [parameter(parametersetname='custom',mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [parameter(parametersetname='reconnect', mandatory=$true)]
        [Switch] $Reconnect
    )

    $validatedCloud = if ( $Cloud ) {
        [GraphCloud] $Cloud
    } else {
        ([GraphCloud]::Public)
    }

    $computedScopes = if ( $scopeNames -ne $null ) {
        $ScopeNames
    } else {
        @('User.Read')
    }

    $context = $::.GraphContext |=> GetCurrent

    if ( ! $context ) {
        throw "No current session -- unable to connect it to Graph"
    }

    if ( $Connection ) {
        write-verbose "Explicit connection was specified"

        $newContext = $::.LogicalGraphManager |=> Get |=> NewContext $context $Connection

        $::.GraphContext |=> SetCurrentByName $newContext.name
    } else {
        write-verbose "Connecting context '$($context.name)'"
        $applicationId = if ( $AppId ) {
            [Guid] $AppId
        } else {
            $::.Application.AppId
        }

        $newConnection = if ( $Reconnect.IsPresent ) {
            write-verbose 'Reconnecting using the existing connection if it exists'
            if ( $scopenames -and $context.connection -and $context.connection.identity ) {
                write-verbose 'Creating connection from existing connection but with new scopes'
                $identity = new-so GraphIdentity $context.connection.identity.app $context.connection.graphEndpoint $context.connection.identity.tenantname
                new-so GraphConnection $context.connection.graphEndpoint $identity $computedScopes
            } else {
                write-verbose 'Just reconnecting the existing connection'
                $context.connection
            }
        } else {
            write-verbose 'No reconnect -- creating a new connection for this context'
            new-graphconnection -cloud $validatedCloud -appid $applicationid -scopenames $computedScopes
        }

        $context |=> UpdateConnection $newConnection
    }
}
