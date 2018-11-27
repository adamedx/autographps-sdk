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

        function __AddConnectionScopeData($graphSP, $permissionsByNames, $permissionsByIds) {
            if ( $this.graphSP ) {
                throw "Scope data for already exists"
            }

            $this.graphSP = $graphSP
            $this.permissionsByNames = $permissionsByNames
            $this.permissionsByIds = $permissionsByIds
        }

        const __graphAuthScopes @(
            'Application.ReadWrite.All',
			'Application.ReadWrite.OwnedBy',
			'Bookings.Read.All',
			'Bookings.ReadWrite.Appointments',
			'Bookings.ReadWrite.All',
			'Bookings.Manage',
			'Calendars.Read',
			'Calendars.Read.Shared',
			'Calendars.ReadWrite',
			'Calendars.ReadWrite.Shared',
			'Calendars.Read',
			'Calendars.ReadWrite',
			'Contacts.Read',
			'Contacts.Read.Shared',
			'Contacts.ReadWrite',
			'Contacts.ReadWrite.Shared',
			'Contacts.Read',
			'Contacts.ReadWrite',
			'Device.Read',
			'Device.Command',
			'Device.ReadWrite.All',
			'Directory.Read.All',
			'Directory.ReadWrite.All',
			'Directory.AccessAsUser.All',
			'Directory.Read.All',
			'Directory.ReadWrite.All',
			'Files.Read',
			'Files.Read.All',
			'Files.ReadWrite',
			'Files.ReadWrite.All',
			'Files.ReadWrite.AppFolder',
			'Files.Read.Selected',
			'Files.ReadWrite.Selected',
			'Files.Read.All',
			'Files.ReadWrite.All',
			'Group.Read.All',
			'Group.ReadWrite.All',
			'Group.Read.All',
			'Group.ReadWrite.All',
			'IdentityRiskEvent.Read.All',
			'IdentityRiskEvent.Read.All',
			'IdentityProvider.Read.All',
			'IdentityProvider.ReadWrite.All',
			'DeviceManagementApps.Read.All',
			'DeviceManagementApps.ReadWrite.All',
			'DeviceManagementConfiguration.Read.All',
			'DeviceManagementConfiguration.ReadWrite.All',
			'DeviceManagementManagedDevices.PrivilegedOperations.All',
			'DeviceManagementManagedDevices.Read.All',
			'DeviceManagementManagedDevices.ReadWrite.All',
			'DeviceManagementRBAC.Read.All',
			'DeviceManagementRBAC.ReadWrite.All',
			'DeviceManagementServiceConfig.Read.All',
			'DeviceManagementServiceConfig.ReadWrite.All',
			'Mail.Read',
			'Mail.ReadWrite',
			'Mail.Read.Shared',
			'Mail.ReadWrite.Shared',
			'Mail.Send',
			'Mail.Send.Shared',
			'MailboxSettings.Read',
			'MailboxSettings.ReadWrite',
			'Mail.Read',
			'Mail.ReadWrite',
			'Mail.Send',
			'MailboxSettings.Read',
			'MailboxSettings.ReadWrite',
			'Member.Read.Hidden',
			'Member.Read.Hidden',
			'Notes.Read',
			'Notes.Create',
			'Notes.ReadWrite',
			'Notes.Read.All',
			'Notes.ReadWrite.All',
			'Notes.ReadWrite.CreatedByApp',
			'Notes.Read.All',
			'Notes.ReadWrite.All',
			'email',
			'offline_access',
			'openid',
			'profile',
			'People.Read',
			'People.Read.All',
			'People.Read.All',
			'Reports.Read.All',
			'Reports.Read.All',
			'SecurityEvents.Read.All',
			'SecurityEvents.ReadWrite.All',
			'SecurityEvents.Read.All',
			'SecurityEvents.ReadWrite.All',
			'Sites.Read.All',
			'Sites.ReadWrite.All',
			'Sites.Manage.All',
			'Sites.FullControl.All',
			'Sites.Read.All',
			'Sites.ReadWrite.All',
			'Sites.Manage.All',
			'Sites.FullControl.All',
			'Tasks.Read',
			'Tasks.Read.Shared',
			'Tasks.ReadWrite',
			'Tasks.ReadWrite.Shared',
			'Agreement.Read.All',
			'Agreement.ReadWrite.All',
			'AgreementAcceptance.Read',
			'AgreementAcceptance.Read.All',
			'User.Read',
			'User.ReadWrite',
			'User.ReadBasic.All',
			'User.Read.All',
			'User.ReadWrite.All',
			'User.Invite.All',
			'User.Export.All',
			'User.Read.All',
			'User.ReadWrite.All',
			'User.Invite.All',
			'User.Export.All',
			'User.ReadBasic.All',
			'User.Read',
			'User.Read.All',
			'User.Read',
			'Files.Read',
			'Mail.Read',
			'Calendars.Read',
			'User.Read',
			'Files.Read',
			'Sites.Read.All',
			'User.ReadWrite',
			'User.ReadWrite.All',
			'User.ReadWrite',
			'Files.ReadWrite',
			'Mail.ReadWrite',
			'Calendars.ReadWrite',
			'User.Export.All',
			'Group.Read.All',
			'Group.Read.All',
			'Group.ReadWrite.All',
			'Sites.ReadWrite.All',
			'Group.ReadWrite.All',
			'Group.ReadWrite.All',
			'UserActivity.ReadWrite.CreatedByApp'
        )

        function GetKnownScopes {
            $this.__graphAuthScopes
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

        function __IsPermissionType($permissionId, $type) {
            $collection = if ( $type -eq 'role' ) {
                $this.graphSP.appRoles
            } else {
                $this.graphSP.publishedPermissionScopes
            }

            ($collection | where id -eq $permissionId) -ne $null
        }

        function __InitializeGraphScopes($connection) {
            if ( ! $this.GraphSP ) {
                $graphSP = if ( $connection ) {
                    $graphSPResponse = try {
                        $graphSPRequest = new-so GraphRequest $connection "/beta/servicePrincipals" GET $null "`$filter=appId eq '$($this.GraphApplicationId)'"
                        $graphSPRequest |=> Invoke
                    } catch {
                    }

                    if ( $graphSPResponse ) {
                        $graphSPResponse |=> Content | convertfrom-json | select -expandproperty value
                    }
                }

                if ( ! $graphSP ) {
                    $graphSP = $__DefaultScopeData
                }

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
            }
        }
    }
}


