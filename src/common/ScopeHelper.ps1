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

. (import-script DefaultScopeData)
. (import-script ../REST/GraphRequest)

ScriptClass ScopeHelper {
    static {
        const GraphApplicationId 00000003-0000-0000-c000-000000000000
        $graphSP = $null
        $permissionsByNames = $null
        $permissionsByIds = $null
        $retrievedScopesFromGraphService = $false
        $__graphAuthScopes = $null

        function __AddConnectionScopeData($graphSP, $permissionsByNames, $permissionsByIds) {
            if ( $this.graphSP -and $this.retrievedScopesFromGraphService ) {
                throw "Scope data already dynamically retrieved from Graph service"
            }

            $this.graphSP = $graphSP
            $this.permissionsByNames = $permissionsByNames
            $this.permissionsByIds = $permissionsByIds
        }

        function GetKnownScopes($connection) {
            $activeConnection = if ( $connection -and ( $connection |=> IsConnected ) ) {
                $connection
            }

            __InitializeGraphScopes $activeConnection
            $scopeNames = if ( $this.permissionsByNames ) {
                $this.permissionsByNames.Keys
            } else {
                # At least return something if this fails
                @('User.Read', 'Directory.AccessAsUser.All')
            }

            $this.__graphAuthScopes = @()
            $this.__graphAuthScopes += $scopeNames
            $this.__graphAuthScopes
        }

        function GetDynamicScopeCmdletParameter([boolean] $skipValidation, [HashTable[]] $parameterSets) {
            $scopes = $this |=> GetKnownScopes ($::.GraphContext |=> GetCurrentConnection)
            Get-DynamicValidateSetParameter Scopes $scopes -ParameterType ([String[]]) -SkipValidation:$skipValidation -ParameterSets $parameterSets
        }

        function GetAppOnlyResourceAccessPermissions($scopes, $connection) {
            if ( $scopes ) {
                GetPermissionsByName $scopes Role $connection
            } else {
                @(
                    @{
                        id = 'df021288-bdef-4463-88db-98f22de89214'
                        type = 'Role'
                    }
                )
            }
        }

        function GetDelegatedResourceAccessPermissions($scopes, $connection) {
            if ( $scopes ) {
                GetPermissionsByName $scopes scope $connection
            } else {
                @{
                    id = 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
                    type = 'Scope'
                }
            }
        }

        function GetPermissionsByName {
            param(
                [parameter(mandatory=$true)]
                [string[]] $scopeNames,

                [validateset('scope', 'role')]
                [parameter(mandatory=$true)]
                $permissionType,

                $connection
            )

            $scopeNames | foreach {
                $permissionId = GraphPermissionNameToId $_ $permissionType $connection

                @{
                    id = $permissionId
                    type = $permissionType
                }
            }
        }

        function GetGraphServicePrincipalId {
            __InitializeGraphScopes
            $this.graphSP.Id
        }

        function GraphPermissionNameToId($name, $type, $connection) {

            $graphConnection = if ( $connection ) {
                $connection
            } else {
                'GraphContext' |::> GetConnection
            }

            __InitializeGraphScopes $graphConnection

            $permission = $this.permissionsByNames[$name]

            if ( ! $permission ) {
                throw "Specified permission '$name' could not be mapped to a permission Id"
            }

            if ( $type -and ! (__IsPermissionType $permission.id $type) ) {
                throw "Specified permission '$name' was not of specified type '$type'"
            }

            $permission.id
        }

        function GraphPermissionIdToName($permissionId, $type, $connection) {
            $graphConnection = if ( $connection ) {
                $connection
            } else {
                'GraphContext' |::> GetConnection
            }

            __InitializeGraphScopes $graphConnection

            $permission = $this.permissionsByIds[$permissionId]

            if ( ! $permission ) {
                throw "Specified permission '$permissionId' could not be mapped to a permission name"
            }

            if ( $type -and ! (__IsPermissionType $permission.id $type) ) {
                throw "Specified permission '$permissionId' was not of specified type '$type'"
            }

            $permission.value
        }

        function __IsPermissionType($permissionId, $type) {
            $collection = if ( $type -eq 'role' ) {
                $this.graphSP.appRoles
            } else {
                $this.graphSP.publishedPermissionScopes
            }

            ($collection | where id -eq $permissionId) -ne $null
        }

        function __InitializeGraphScopes($connection) {
            if ( $this.graphSP -and $this.retrievedScopesFromGraphService ) {
                return
            }

            $retrievedFromService = $false
            $graphSP = if ( $connection ) {
                $graphSPResponse = try {
                    # ScriptClass has an apparent problem with string interpolation using $this
                    # in string interpolation in the context of PowerShell argument completion
                    # via dynamic parameters, so get $this.GraphApplicationId into a local
                    # variable as a workaround.
                    $graphAppId = $this.GraphApplicationId
                    $graphSPRequest = new-so GraphRequest $connection "/beta/servicePrincipals" GET $null "`$filter=appId eq '$graphAppId'"
                    $graphSPRequest |=> Invoke
                } catch {
                }

                if ( $graphSPResponse ) {
                    $retrievedFromService = $true
                    $graphSPResponse |=> Content | convertfrom-json | select -expandproperty value
                }
            }

            if ( ! $graphSP ) {
                $graphSP = $__DefaultScopeData
            }

            if ( $graphSP ) {
                $permissionsByNames = @{}
                $permissionsByIds = @{}

                $graphSP.publishedPermissionScopes | foreach {
                    $permissionsByNames[$_.value] = $_
                    $permissionsByIds[$_.id] = $_
                }

                $graphSP.appRoles | foreach {
                    $permissionsByNames[$_.value] = $_
                    $permissionsByIds[$_.id] = $_
                }

                __AddConnectionScopeData $graphSP $permissionsByNames $permissionsByIds

                if ( $retrievedFromService ) {
                    $this.retrievedScopesFromGraphService = $true
                }
            }
        }
    }
}


