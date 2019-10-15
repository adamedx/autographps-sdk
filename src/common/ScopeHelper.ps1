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

. (import-script DefaultScopeData)
. (import-script ../REST/GraphRequest)

ScriptClass ScopeHelper -ArgumentList $__DefaultScopeData {
    param($scopeData)

    static {
        const GraphApplicationId 00000003-0000-0000-c000-000000000000
        const DefaultScopeQualifier ([Uri] 'https://graph.microsoft.com')
        $graphSP = $null
        $permissionsByIds = $null
        $appOnlyPermissionsByName = $null
        $delegatedPermissionsByName = $null
        $retrievedScopesFromGraphService = $false
        $sortedGraphPermissions = $null
        $sortedGraphDelegatedPermissions = $null
        $sortedGraphAppOnlyPermissions = $null
        $defaultScopeData = $scopeData

        function __AddConnectionScopeData($graphSP, $permissionsByIds, $sortedPermissionsList, $sortedScopeList, $sortedRoleList) {
            if ( $this.graphSP -and $this.retrievedScopesFromGraphService ) {
                throw "Scope data already dynamically retrieved from Graph service"
            }

            $this.graphSP = $graphSP

            # Note that the ids referenced here are universal across tenants, so the
            # first time we retrieve them will be the only time we need to do so,
            # and it doesn't matter what tenant they come from as they are always
            # the same no matter the tenant.
            $this.permissionsByIds = $permissionsByIds

            $this.delegatedPermissionsByName = $sortedScopeList
            $this.appOnlyPermissionsByName = $sortedRoleList

            $this.sortedGraphPermissions = @() + $sortedPermissionsList.keys
            $this.sortedGraphDelegatedPermissions = @() + $sortedScopeList.keys
            $this.sortedGraphAppOnlyPermissions = @() + $sortedRoleList.keys
        }

        function ValidatePermissions([string[]] $permissions, [boolean] $isNoninteractive = $false, [boolean] $allowPermissionIdGuid = $false, $connection ) {
            $type = if ( $isNoninteractive ) { 'Role' } else { 'Scope' }
            if ( $permissions ) {
                $permissions | foreach {
                    GraphPermissionNameToId $_ $type $connection $allowPermissionIdGuid | out-null
                }
            }
        }

        function GetKnownPermissionsSorted($connection, $graphAppAuthType) {
            __InitializeGraphScopes $connection
            if ( $this.sortedGraphPermissions ) {
                if ( $graphAppAuthType -eq $null ) {
                    $this.sortedGraphPermissions
                } elseif ( $graphAppAuthType -eq ([GraphAppAuthType]::Delegated) ) {
                    $this.sortedGraphDelegatedPermissions
                } elseif ( $graphAppAuthType -eq ([GraphAppAuthType]::AppOnly) ) {
                    $this.sortedGraphAppOnlyPermissions
                } else {
                    throw [ArgumentException]::new("Permissions list requested for permission auth type '$graphAppAuthType'")
                }
            } else {
                # At least return something if this fails
                @('Directory.AccessAsUser.All', 'User.Read')
            }
        }

        function GetAppOnlyResourceAccessPermissions($scopes, $connection) {
            if ( $scopes ) {
                GetPermissionsByName $scopes Role $connection
            } else {
                @()
            }
        }

        function GetDelegatedResourceAccessPermissions($scopes, $connection) {
            if ( $scopes ) {
                GetPermissionsByName $scopes Scope $connection
            } else {
                @()
            }
        }

        function GetPermissionsByName {
            param(
                [parameter(mandatory=$true)]
                [string[]] $scopeNames,

                [validateset('Scope', 'Role')]
                [parameter(mandatory=$true)]
                $permissionType,

                $connection
            )

            # Case matters for the permission type when passed to the protocol, so
            # enforce case and raise an exception if the case is invalid
            $validValues = @('Scope', 'Role')
            if ( $validValues -cnotcontains $permissionType ) {
                $validValueOutput = $validValues -join ', '
                throw [ArgumentException]::new("Specified type '$permissionType' has incorrect casing, case must match the exact case of the values in '$validValueOutput'")
            }

            $scopeNames | foreach {
                $permissionId = GraphPermissionNameToId $_ $permissionType $connection
                $permissionData = $this.permissionsByIds[$permissionId]

                $description = if ( $permissionData | gm adminConsentDescription -erroraction ignore ) {
                    $permissionData.adminConsentDescription
                } elseif ( $permissionData | gm description -erroraction ignore ) {
                    $permissionData.description
                }

                $consentType = 'Admin'
                if ( $permissionType -eq 'Scope' ) {
                    if ( $permissionData | gm type -erroraction ignore ) {
                        $consentType = $permissionData.type
                    }
                }

                @{
                    id = $permissionId
                    type = $permissionType
                    description = $description
                    consentType = $consentType
                    name = $_
                }
            }
        }

        function GetGraphServicePrincipalId($connection) {
            if ( ! $connection ) {
                throw [ArgumentException]::("No connection specified to retrieve the Graph service principal")
            }
            __InitializeGraphScopes $connection

            if ( ! $this.retrievedScopesFromGraphService ) {
                throw "Unable to reach Graph service to retrieve Graph service principal"
            }
            $this.graphSP.Id
        }

        function GraphPermissionNameToId($name, [ValidateSet('Scope', 'Role')] $type, $connection, $allowPermissionIdGuid = $false) {
            __InitializeGraphScopes $connection

            $authDescription = $null
            $otherCollection = $null
            $collection = if ( $type -eq 'Scope' ) {
                $authDescription = 'Delegated'
                $otherCollection = $this.appOnlyPermissionsByName
                $this.delegatedPermissionsByName
            } else {
                $authDescription = 'Noninteractive App-only'
                $otherCollection = $this.delegatedPermissionsByName
                $this.appOnlyPermissionsByName
            }

            $permission = $collection[$name]
            $permissionOfOtherType = $otherCollection[$name]

            if ( ! $permission ) {
                if ( $permissionOfOtherType ) {
                    throw "Specified permission '$name' was not of specified type '$type' required for requested '$authDescription' authentication"
                }
                if ( ! $allowPermissionIdGuid ) {
                    throw "Specified permission '$name' could not be mapped to a permission Id"
                }
                $permission = try {
                    ([Guid] $Name)
                } catch {
                    throw "Specified permission '$name' could not be mapped to a permission Id or interpreted as a permission Id Guid"
                }
            }

            $permission
        }

        function GraphPermissionIdToName($permissionId, $type, $connection, [bool] $ignoreUnknownIds) {
            __InitializeGraphScopes $connection

            $permission = $this.permissionsByIds[$permissionId]

            if ( ! $ignoreUnknownIds ) {
                if ( ! $permission ) {
                    throw "Specified permission '$permissionId' could not be mapped to a permission name"
                }

                if ( $type -and ! (__IsPermissionType $permission.id $type) ) {
                    throw "Specified permission '$permissionId' was not of specified type '$type'"
                }
            }

            $permission.value
        }

        function QualifyScopes([string[]] $scopes, [Uri] $resourceUri) {
            if ( ! $resourceUri -or ( $resourceUri -eq $this.DefaultScopeQualifier ) ) {
                $scopes
            } else {
                foreach ( $scope in $scopes )  {
                    if ( ( [Uri] $scope ).IsAbsoluteUri ) {
                        [string] $scope
                    } else {
                        [string] [Uri]::new($resourceUri, $scope)
                    }
                }
            }
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

            $graphConnection = if ( $connection ) {
                if ( $connection |=> IsConnected ) {
                    $connection
                }
            }

            $retrievedFromService = $false
            $graphSP = if ( $graphConnection ) {
                $graphSPResponse = try {
                    # ScriptClass has an apparent problem with string interpolation using $this
                    # in string interpolation in the context of PowerShell argument completion
                    # via dynamic parameters, so get $this.GraphApplicationId into a local
                    # variable as a workaround.
                    $graphAppId = $this.GraphApplicationId
                    $graphSPRequest = new-so GraphRequest $graphConnection "/beta/servicePrincipals" GET $null "`$filter=appId eq '$graphAppId'"
                    $graphSPRequest |=> Invoke
                } catch {
                }

                if ( $graphSPResponse ) {
                    $retrievedFromService = $true
                    $graphSPResponse |=> Content | convertfrom-json | select -expandproperty value
                }
            }

            if ( ! $graphSP ) {
                $graphSP = $this.defaultScopeData
            }

            if ( $graphSP ) {
                $permissionsByIds = @{}

                $sortedPermissionsList = [System.Collections.Generic.SortedList[string, string]]::new(
                    [System.StringComparer]::CurrentCultureIgnoreCase)
                $sortedScopeList = [System.Collections.Generic.SortedList[string, string]]::new(
                    [System.StringComparer]::CurrentCultureIgnoreCase)
                $sortedRoleList = [System.Collections.Generic.SortedList[string, string]]::new(
                    [System.StringComparer]::CurrentCultureIgnoreCase)

                $graphSP.publishedPermissionScopes | foreach {
                    $sortedPermissionsList.Add($_.value, $_.id)
                    $permissionsByIds[$_.id] = $_
                    $sortedScopeList.Add($_.value, $_.id)
                }

                $graphSP.appRoles | foreach {
                    if ( ! $sortedPermissionsList.ContainsKey($_.value) ) {
                        $sortedPermissionsList.Add($_.value, $_.id)
                    }

                    $sortedRoleList.Add($_.value, $_.id)
                    $permissionsByIds[$_.id] = $_
                }

                __AddConnectionScopeData $graphSP $permissionsByIds $sortedPermissionsList $sortedScopeList $sortedRoleList

                if ( $retrievedFromService ) {
                    $this.retrievedScopesFromGraphService = $true
                }
            }
        }
    }
}


