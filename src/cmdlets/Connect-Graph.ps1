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

. (import-script ../Client/GraphConnection)
. (import-script ../Client/GraphContext)
. (import-script ../Client/LogicalGraphManager)
. (import-script New-GraphConnection)
. (import-script common/DynamicParamHelper)
. (import-script ../common/ScopeHelper)
. (import-script common/PermissionParameterCompleter)

function Connect-Graph {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='simple')]
    param(
        [parameter(position=0, parametersetname='simple')]
        [parameter(position=0, parametersetname='apponly', mandatory=$true)]
        [parameter(parametersetname='delegatedconfidential', mandatory=$true)]
        [string] $AppId = $null,

        [String[]] $Permissions = $null,

        [parameter(parametersetname='simple')]
        [parameter(parametersetname='apponly')]
        [parameter(parametersetname='delegatedconfidential')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [parameter(parametersetname='existingconnection',mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [parameter(parametersetname='reconnect', mandatory=$true)]
        [Switch] $Reconnect,

        [parameter(parametersetname='simple')]
        [Switch] $NoBrowserSigninUI,

        [parameter(parametersetname='apponly', mandatory=$true)]
        [Switch] $NoninteractiveAppOnlyAuth,

        [parameter(parametersetname='simple')]
        [parameter(parametersetname='apponly')]
        [parameter(parametersetname='delegatedconfidential')]
        [string] $CertificatePath,

        [parameter(parametersetname='delegatedconfidential', mandatory=$true)]
        [switch] $Confidential,

        [parameter(parametersetname='apponly', mandatory=$true)]
        [parameter(parametersetname='simple')]
        [parameter(parametersetname='delegatedconfidential')]
        [string] $TenantId
    )

    begin {
    }

    process {
        $validatedCloud = if ( $Cloud ) {
            [GraphCloud] $Cloud
        } else {
            ([GraphCloud]::Public)
        }

        $computedScopes = if ( $Permissions -ne $null ) {
            $Permissions
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
                if ( $Permissions -and $context.connection -and $context.connection.identity ) {
                    write-verbose 'Creating connection from existing connection but with new permissions'
                    $identity = new-so GraphIdentity $context.connection.identity.app $context.connection.graphEndpoint $context.connection.identity.tenantname
                    new-so GraphConnection $context.connection.graphEndpoint $identity $computedScopes $NoBrowserSigninUI.IsPresent
                } else {
                    write-verbose 'Just reconnecting the existing connection'
                    $context.connection
                }
            } else {
                write-verbose 'No reconnect -- creating a new connection for this context'
                $appOnlyArguments = @{}
                $delegatedArguments = @{}

                if ( $NoninteractiveAppOnlyAuth.IsPresent ) {
                    $appOnlyArguments['NoninteractiveAppOnlyAuth'] = $NoninteractiveAppOnlyAuth
                    $appOnlyArguments['TenantId'] = $TenantId
                } else {
                    $delegatedArguments['Permissions'] = $computedScopes
                    $delegatedArguments['Confidential'] = $Confidential
                    $delegatedArguments['NoBrowserSigninUI'] = $NoBrowserSigninUI
                    if ( $TenantId ) {
                        $delegatedArguments['TenantId'] = $TenantId
                    }
                }

                try {
                    new-graphconnection -cloud $validatedCloud -appid $applicationid @delegatedArguments @appOnlyArguments -erroraction stop
                } catch {
                    throw
                }
            }

            $context |=> UpdateConnection $newConnection
        }
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Connect-Graph Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))
