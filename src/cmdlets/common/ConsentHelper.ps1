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
        const CONSENT_DISPLAY_TYPE GraphConsentDisplayType
        $formatter = $null

        function __initialize {
            $this.formatter = new-so DisplayTypeFormatter $CONSENT_DISPLAY_TYPE 'PermissionType', 'StartTime', 'GrantedTo', 'Permission'
            __RegisterDisplayType
        }

        function ToDisplayableObject($object, $targetAppId, $targetServicePrincipalId) {
            $consentEntries = @()
            $isOAuth2PermissionGrant = !(!($object | gm -erroraction ignore clientid))

            if ( $isOAuth2PermissionGrant ) {
                $startTime = if ( $object | gm startTime -erroraction ignore ) { $object.startTime }
                $expiryTime = if ( $object | gm expiryTime -erroraction ignore ) { $object.expiryTime }
                $startTimeOffset = if ( $startTime ) { $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $startTime $true }
                $expiryTimeOffset = if ( $expiryTime ) { $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $expiryTime $true }
                $grantedTo = if ( $object.consentType -eq 'AllPrincipals' ) { 'AllUsers' } else { $object.PrincipalId }
                $scopes = $object.scope -split ' '

                foreach ( $scope in $scopes ) {
                    if ( $scope ) {
                        $consentEntries += [PSCustomObject] @{
                            AppId = $targetAppId
                            PermissionType = 'Delegated'
                            Permission = $scope
                            GrantedTo = $grantedTo
                            ServicePrincipalId = $targetServicePrincipalId
                            StartTime = $startTimeOffset
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

                $creationTimeOffset = if ( $object | gm creationTimeStamp -erroraction ignore ) {
                    $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $object.creationTimestamp $true
                }

                $principalId = if ( $object | gm PrincipalId -erroraction ignore ) {
                    $object.PrincipalId
                }

                $consentEntries += [PSCustomObject] @{
                    AppId = $targetAppId
                    PermissionType = 'Application'
                    Permission = $permissionDisplayName
                    GrantedTo = $object.PrincipalId
                    ServicePrincipalId = $targetServicePrincipalId
                    StartTime = $creationTimeOffset
                    GraphResource = $object
                }
            }

            foreach ( $consentEntry in $consentEntries ) {
                $consentEntry.pstypenames.insert(0, $CONSENT_DISPLAY_TYPE)
                $consentEntry
            }
        }

        function __RegisterDisplayType {
            $typeProperties = @(
                'AppId'
                'PermissionType'
                'Permission'
                'GrantedTo'
                'ServicePrincipalId'
                'StartTime'
            )

            $::.DisplayTypeFormatter |=> RegisterDisplayType $CONSENT_DISPLAY_TYPE $typeProperties $true
        }
    }
}

$::.ConsentHelper |=> __initialize
