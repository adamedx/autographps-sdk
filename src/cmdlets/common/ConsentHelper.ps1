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

. (import-script DisplayTypeFormatter)

ScriptClass ConsentHelper {
    static {
        $formatter = $null

        function __initialize {
            $this.formatter = new-so DisplayTypeFormatter GraphConsentDisplayType 'PermissionType', 'StartTime', 'GrantedTo', 'Permission'
        }

        function ToDisplayableObject($object) {
            $consentEntries = @()
            $isOAuth2PermissionGrant = !(!($object | gm -erroraction ignore clientid))

            if ( $isOAuth2PermissionGrant ) {
                $startTime = $object | gm startTime -erroraction ignore
                $expiryTime = $object | gm expiryTime -erroraction ignore
                $startTimeOffset = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $startTime $true
                $expiryTimeOffset = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $expiryTime $true
                $grantedTo = if ( $object.consentType -eq 'AllPrincipals' ) { 'AllUsers' } else { $object.PrincipalId }
                $scopes = $object.scope -split ' '

                foreach ( $scope in $scopes ) {
                    if ( $scope ) {
                        $consentEntries += @{
                            PermissionType = 'DelegatedUser'
                            StartTime = $startTimeOffset
                            Permission = $scope
                            GrantedTo = $grantedTo
                            GraphResource = $object
                        }
                    }
                }
            } else {
                $roleName = $::.ScopeHelper |=> GraphPermissionIdToName $object.appRoleId role $null $true
                $permissionDisplayName = if ( $roleName ) {
                    $roleName
                } else {
                    $appRoleId
                }

                $creationTimeOffset = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $object.creationTimestamp $true

                $consentEntries += @{
                    PermissionType = 'Application'
                    StartTime = $creationTimeOffset
                    Permission = $permissionDisplayName
                    GrantedTo = $object.PrincipalId
                    GraphResource = $object
                }
            }

            foreach ( $consentEntry in $consentEntries ) {
                $this.formatter |=> DeserializedGraphObjectToDisplayableObject ([PSCustomObject] $consentEntry)
            }
        }
    }
}

$::.ConsentHelper |=> __initialize
