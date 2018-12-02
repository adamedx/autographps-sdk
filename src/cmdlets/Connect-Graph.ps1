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
. (import-script common/DynamicParamHelper)
. (import-script ../common/ScopeHelper)

function Connect-Graph {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='simple')]
    param(
        <#
        This is implemented as a DynamicParam -- see below
        [parameter(position=0)]
        [parameter(parametersetname='simple')]
        [parameter(parametersetname='reconnect')]
        [String[]] $Permissions = $null,
        #>

        [parameter(parametersetname='simple')]
        [parameter(parametersetname='apponly')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [parameter(parametersetname='simple')]
        [parameter(parametersetname='apponly', mandatory=$true)]
        [string] $AppId = $null,

        [parameter(parametersetname='custom',mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [parameter(parametersetname='reconnect', mandatory=$true)]
        [Switch] $Reconnect,

        [parameter(parametersetname='simple')]
        [parameter(parametersetname='reconnect')]
        [Switch] $SkipScopeValidation,

        [parameter(parametersetname='apponly', mandatory=$true)]
        [Switch] $NoninteractiveAppAuth,

        [parameter(parametersetname='apponly')]
        [string] $CertificatePath,

        [parameter(parametersetname='apponly', mandatory=$true)]
        [parameter(parametersetname='simple')]
        [parameter(parametersetname='custom')]
        [string] $TenantId
    )

    DynamicParam {
        $::.ScopeHelper |=> GetDynamicScopeCmdletParameter Permissions $SkipScopeValidation.IsPresent @(
            @{
                Position = 0
            }
            @{
                ParameterSetName = 'simple'
            }
            @{
                ParameterSetName = 'reconnect'
            }
            @{
                ParameterSetName = 'custom'
            }
            @{
                ParameterSetName = 'apponly'
            }
        )
    }

    begin {
        <# Make a friendly local variable name for the parameter
        [parameter(position=0)]
        [parameter(parametersetname='simple')]
        [parameter(parametersetname='reconnect')]
        [String[]] $Permissions = $null,
        #>
        $Permissions = $PsBoundParameters['Permissions']
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
                    new-so GraphConnection $context.connection.graphEndpoint $identity $computedScopes
                } else {
                    write-verbose 'Just reconnecting the existing connection'
                    $context.connection
                }
            } else {
                write-verbose 'No reconnect -- creating a new connection for this context'
                $appOnlyArguments = @{}
                $permissionsArgument = @{}

                if ( $NonInteractiveAppAuth.IsPresent ) {
                    $appOnlyArguments['NoninteractiveAppAuth'] = $NonInteractiveAppAuth
                    $appOnlyArguments['TenantId'] = $TenantId
                } else {
                    $permissionsArgument['Permissions'] = $computedScopes
                }

                try {
                    new-graphconnection -cloud $validatedCloud -appid $applicationid @permissionsArgument @appOnlyArguments -erroraction stop
                } catch {
                    throw
                }
            }

            $context |=> UpdateConnection $newConnection
        }
    }
}

