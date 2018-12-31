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

#
# This is actually a snapshot of the MS Graph service principal. Some data
# are tenant-specific, but others, such as the guids for role and scope id's,
# are the same in all tenants -- this means this snapshot can be used to
# access API's that require the role and scope id's.
#

$__DefaultScopeData = @'
{
    "id":  "88428b77-6e8e-492d-810b-31d48c81ee66",
    "deletedDateTime":  null,
    "accountEnabled":  true,
    "appDisplayName":  "Microsoft Graph",
    "appId":  "00000003-0000-0000-c000-000000000000",
    "appOwnerOrganizationId":  "f8cdef31-a31e-4b4a-93e4-5f571e91255a",
    "appRoleAssignmentRequired":  false,
    "displayName":  "Microsoft Graph",
    "errorUrl":  null,
    "homepage":  null,
    "logoutUrl":  null,
    "publishedPermissionScopes":  [
                                      {
                                          "adminConsentDescription":  "Allows the app to read identity risky user information for all users in your organization on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read identity risky user information",
                                          "id":  "d04bb851-cb7c-4146-97c7-ca3e71baf56c",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read identity risky user information for all users in your organization on behalf of the signed-in user.",
                                          "userConsentDisplayName":  "Read identity risky user information",
                                          "value":  "identityriskyuser.read.all"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to deliver its notifications on behalf of signed-in users. Also allows the app to read, update, and delete the user\u0027s notification items for this app.",
                                          "adminConsentDisplayName":  "Deliver and manage user notifications for this app",
                                          "id":  "89497502-6e42-46a2-8cb2-427fd3df970a",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to deliver its notifications, on your behalf. Also allows the app to read, update, and delete your notification items for this app.",
                                          "userConsentDisplayName":  "Deliver and manage your notifications for this app",
                                          "value":  "Notifications.ReadWrite.CreatedByApp"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write your organization\u0027s conditional access policies on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write your organization\u0027s conditional access policies",
                                          "id":  "ad902697-1014-4ef5-81ef-2b4301988e8c",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write your organization\u0027s conditional access policies on your behalf.",
                                          "userConsentDisplayName":  "Read and write your organization\u0027s conditional access policies",
                                          "value":  "Policy.ReadWrite.ConditionalAccess"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your organization\u0027s policies on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read your organization\u0027s policies",
                                          "id":  "572fea84-0151-49b2-9301-11cb16974376",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read your organization\u0027s policies on your behalf.",
                                          "userConsentDisplayName":  "Read your organization\u0027s policies",
                                          "value":  "Policy.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read access reviews, reviewers, decisions and settings that the signed-in user has access to in the organization.",
                                          "adminConsentDisplayName":  "Read all access reviews that user can access",
                                          "id":  "ebfcd32b-babb-40f4-a14b-42706e83bd28",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read information on access reviews, reviewers, decisions and settings that you have access to.",
                                          "userConsentDisplayName":  "Read access reviews that you can access",
                                          "value":  "AccessReview.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read, update, delete and perform actions on access reviews, reviewers, decisions and settings that the signed-in user has access to in the organization.",
                                          "adminConsentDisplayName":  "Manage all access reviews that user can access",
                                          "id":  "e4aa47b9-9a69-4109-82ed-36ec70d85ff1",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read, update and perform action on access reviews, reviewers, decisions and settings that you have access to.",
                                          "userConsentDisplayName":  "Manage access reviews that you can access",
                                          "value":  "AccessReview.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read programs and program controls that the signed-in user has access to in the organization.",
                                          "adminConsentDisplayName":  "Read all programs that user can access",
                                          "id":  "c492a2e1-2f8f-4caa-b076-99bbf6e40fe4",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read information on programs and program controls that you have access to.",
                                          "userConsentDisplayName":  "Read programs that you can access",
                                          "value":  "ProgramControl.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read, update, delete and perform actions on programs and program controls that the signed-in user has access to in the organization.",
                                          "adminConsentDisplayName":  "Manage all programs that user can access",
                                          "id":  "50fd364f-9d93-4ae1-b170-300e87cccf84",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read, update and perform action on programs and program controls that you have access to.",
                                          "userConsentDisplayName":  "Manage programs that you can access",
                                          "value":  "ProgramControl.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete apps in the app catalogs.",
                                          "adminConsentDisplayName":  "Read and write to all app catalogs",
                                          "id":  "1ca167d5-1655-44a1-8adf-1414072e1ef9",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to create, read, update, and delete apps in the app catalogs.",
                                          "userConsentDisplayName":  "Read and write to all app catalogs",
                                          "value":  "AppCatalog.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to export data (e.g. customer content or system-generated logs), associated with any user in your company, when the app is used by a privileged user (e.g. a Company Administrator).",
                                          "adminConsentDisplayName":  "Export user\u0027s data",
                                          "id":  "405a51b5-8d8d-430b-9842-8be4b0e9f324",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to export data (e.g. customer content or system-generated logs), associated with any user in your company, when the app is used by a privileged user (e.g. a Company Administrator).",
                                          "userConsentDisplayName":  "Export user\u0027s data",
                                          "value":  "User.Export.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to request and manage just in time elevation (including scheduled elevation) of users to Azure AD built-in administrative roles, on behalf of signed-in users.",
                                          "adminConsentDisplayName":  "Read and write privileged access to Azure AD",
                                          "id":  "3c3c74f5-cdaa-4a97-b7e0-4e788bfcfb37",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to request and manage just in time elevation (including scheduled elevation) of users to Azure AD built-in administrative roles, on your behalf.",
                                          "userConsentDisplayName":  "Read and write privileged access to Azure AD",
                                          "value":  "PrivilegedAccess.ReadWrite.AzureAD"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to request and manage time-based assignment and just-in-time elevation of user privileges to manage Azure resources (like subscriptions, resource groups, storage, compute) on behalf of the signed-in users.",
                                          "adminConsentDisplayName":  "Read and write privileged access to Azure resources",
                                          "id":  "a84a9652-ffd3-496e-a991-22ba5529156a",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to request and manage time-based assignment and just-in-time elevation of user privileges to manage ?your Azure resources (like your subscriptions, resource groups, storage, compute) on your behalf.",
                                          "userConsentDisplayName":  "Read and write privileged access to your Azure resources",
                                          "value":  "PrivilegedAccess.ReadWrite.AzureResources"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read all webhook subscriptions on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read all webhook subscriptions (preview)",
                                          "id":  "5f88184c-80bb-4d52-9ff2-757288b2e9b7",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read all webhook subscriptions on your behalf.",
                                          "userConsentDisplayName":  "Read all webhook subscriptions (preview)",
                                          "value":  "Subscription.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read terms of use agreements on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read all terms of use agreements",
                                          "id":  "af2819c9-df71-4dd3-ade7-4d7c9dc653b7",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read terms of use agreements on your behalf.",
                                          "userConsentDisplayName":  "Read all terms of use agreements",
                                          "value":  "Agreement.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write terms of use agreements on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write all terms of use agreements",
                                          "id":  "ef4b5d93-3104-4664-9053-a5c49ab44218",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write terms of use agreements on your behalf.",
                                          "userConsentDisplayName":  "Read and write all terms of use agreements",
                                          "value":  "Agreement.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read terms of use acceptance statuses on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read user terms of use acceptance statuses",
                                          "id":  "0b7643bb-5336-476f-80b5-18fbfbc91806",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read your terms of use acceptance statuses.",
                                          "userConsentDisplayName":  "Read your terms of use acceptance statuses",
                                          "value":  "AgreementAcceptance.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read terms of use acceptance statuses on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read terms of use acceptance statuses that user can access",
                                          "id":  "a66a5341-e66e-4897-9d52-c2df58c2bfb9",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read terms of use acceptance statuses on your behalf.",
                                          "userConsentDisplayName":  "Read all terms of use acceptance statuses",
                                          "value":  "AgreementAcceptance.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and query your audit log activities, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read audit log data",
                                          "id":  "e4c9e354-4dc5-45b8-9e7c-e1393b0b1a20",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and query your audit log activities, on your behalf.",
                                          "userConsentDisplayName":  "Read audit log data",
                                          "value":  "AuditLog.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and report the signed-in user\u0027s activity in the app.",
                                          "adminConsentDisplayName":  "Read and write app activity to users\u0027 activity feed",
                                          "id":  "47607519-5fb1-47d9-99c7-da4b48f369b1",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read and report your activity in the app.",
                                          "userConsentDisplayName":  "Read and write app activity to your activity feed",
                                          "value":  "UserActivity.ReadWrite.CreatedByApp"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read properties of Microsoft Intune-managed device configuration and device compliance policies and their assignment to groups.",
                                          "adminConsentDisplayName":  "Read Microsoft Intune Device Configuration and Policies",
                                          "id":  "f1493658-876a-4c87-8fa7-edb559b3476a",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read properties of Microsoft Intune-managed device configuration and device compliance policies and their assignment to groups.",
                                          "userConsentDisplayName":  "Read Microsoft Intune Device Configuration and Policies",
                                          "value":  "DeviceManagementConfiguration.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write properties of Microsoft Intune-managed device configuration and device compliance policies and their assignment to groups.",
                                          "adminConsentDisplayName":  "Read and write Microsoft Intune Device Configuration and Policies",
                                          "id":  "0883f392-0a7a-443d-8c76-16a6d39c7b63",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write properties of Microsoft Intune-managed device configuration and device compliance policies and their assignment to groups.",
                                          "userConsentDisplayName":  "Read and write Microsoft Intune Device Configuration and Policies",
                                          "value":  "DeviceManagementConfiguration.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the properties, group assignments and status of apps, app configurations and app protection policies managed by Microsoft Intune.",
                                          "adminConsentDisplayName":  "Read Microsoft Intune apps",
                                          "id":  "4edf5f54-4666-44af-9de9-0144fb4b6e8c",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read the properties, group assignments and status of apps, app configurations and app protection policies managed by Microsoft Intune.",
                                          "userConsentDisplayName":  "Read Microsoft Intune apps",
                                          "value":  "DeviceManagementApps.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write the properties, group assignments and status of apps, app configurations and app protection policies managed by Microsoft Intune.",
                                          "adminConsentDisplayName":  "Read and write Microsoft Intune apps",
                                          "id":  "7b3f05d5-f68c-4b8d-8c59-a2ecd12f24af",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write the properties, group assignments and status of apps, app configurations and app protection policies managed by Microsoft Intune.",
                                          "userConsentDisplayName":  "Read and write Microsoft Intune apps",
                                          "value":  "DeviceManagementApps.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the properties relating to the Microsoft Intune Role-Based Access Control (RBAC) settings.",
                                          "adminConsentDisplayName":  "Read Microsoft Intune RBAC settings",
                                          "id":  "49f0cc30-024c-4dfd-ab3e-82e137ee5431",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read the properties relating to the Microsoft Intune Role-Based Access Control (RBAC) settings.",
                                          "userConsentDisplayName":  "Read Microsoft Intune RBAC settings",
                                          "value":  "DeviceManagementRBAC.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write the properties relating to the Microsoft Intune Role-Based Access Control (RBAC) settings.",
                                          "adminConsentDisplayName":  "Read and write Microsoft Intune RBAC settings",
                                          "id":  "0c5e8a55-87a6-4556-93ab-adc52c4d862d",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write the properties relating to the Microsoft Intune Role-Based Access Control (RBAC) settings.",
                                          "userConsentDisplayName":  "Read and write Microsoft Intune RBAC settings",
                                          "value":  "DeviceManagementRBAC.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the properties of devices managed by Microsoft Intune.",
                                          "adminConsentDisplayName":  "Read Microsoft Intune devices",
                                          "id":  "314874da-47d6-4978-88dc-cf0d37f0bb82",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read the properties of devices managed by Microsoft Intune.",
                                          "userConsentDisplayName":  "Read devices Microsoft Intune devices",
                                          "value":  "DeviceManagementManagedDevices.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write the properties of devices managed by Microsoft Intune. Does not allow high impact operations such as remote wipe and password reset on the device?s owner.",
                                          "adminConsentDisplayName":  "Read and write Microsoft Intune devices",
                                          "id":  "44642bfe-8385-4adc-8fc6-fe3cb2c375c3",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write the properties of devices managed by Microsoft Intune. Does not allow high impact operations such as remote wipe and password reset on the device?s owner.",
                                          "userConsentDisplayName":  "Read and write Microsoft Intune devices",
                                          "value":  "DeviceManagementManagedDevices.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to perform remote high impact actions such as wiping the device or resetting the passcode on devices managed by Microsoft Intune.",
                                          "adminConsentDisplayName":  "Perform user-impacting remote actions on Microsoft Intune devices",
                                          "id":  "3404d2bf-2b13-457e-a330-c24615765193",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to perform remote high impact actions such as wiping the device or resetting the passcode on devices managed by Microsoft Intune.",
                                          "userConsentDisplayName":  "Perform user-impacting remote actions on Microsoft Intune devices",
                                          "value":  "DeviceManagementManagedDevices.PrivilegedOperations.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write Microsoft Intune service properties including device enrollment and third party service connection configuration.",
                                          "adminConsentDisplayName":  "Read and write Microsoft Intune configuration",
                                          "id":  "662ed50a-ac44-4eef-ad86-62eed9be2a29",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write Microsoft Intune service properties including device enrollment and third party service connection configuration.",
                                          "userConsentDisplayName":  "Read and write Microsoft Intune configuration",
                                          "value":  "DeviceManagementServiceConfig.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read Microsoft Intune service properties including device enrollment and third party service connection configuration.",
                                          "adminConsentDisplayName":  "Read Microsoft Intune configuration",
                                          "id":  "8696daa5-bce5-4b2e-83f9-51b6defc4e1e",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read Microsoft Intune service properties including device enrollment and third party service connection configuration.",
                                          "userConsentDisplayName":  "Read Microsoft Intune configuration",
                                          "value":  "DeviceManagementServiceConfig.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your organization?s security events on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read your organization?s security events",
                                          "id":  "64733abd-851e-478a-bffb-e47a14b18235",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read your organization?s security events on your behalf.",
                                          "userConsentDisplayName":  "Read your organization?s security events",
                                          "value":  "SecurityEvents.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your organization?s security events on behalf of the signed-in user. Also allows the app to update editable properties in security events on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and update your organization?s security events",
                                          "id":  "6aedf524-7e1c-45a7-bd76-ded8cab8d0fc",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read your organization?s security events on your behalf. Also allows you to update editable properties in security events.",
                                          "userConsentDisplayName":  "Read and update your organization?s security events",
                                          "value":  "SecurityEvents.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read a scored list of relevant people of the signed-in user or other users in the signed-in user\u0027s organization. The list can include local contacts, contacts from social networking, your organization\u0027s directory, and people from recent communications (such as email and Skype).",
                                          "adminConsentDisplayName":  "Read all users\u0027 relevant people lists",
                                          "id":  "b89f9189-71a5-4e70-b041-9887f0bc7e4a",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read a list of people in the order that is most relevant to you. Allows the app to read a list of people in the order that is most relevant to another user in your organization. These can include local contacts, contacts from social networking, people listed in your organization?s directory, and people from recent communications.",
                                          "userConsentDisplayName":  "Read all users? relevant people lists",
                                          "value":  "People.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Manage the state and settings of all Microsoft education apps on behalf of the user.",
                                          "adminConsentDisplayName":  "Manage education app settings",
                                          "id":  "63589852-04e3-46b4-bae9-15d5b1050748",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to manage the state and settings of all Microsoft education apps on your behalf.",
                                          "userConsentDisplayName":  "Manage your education app settings",
                                          "value":  "EduAdministration.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Read the state and settings of all Microsoft education apps on behalf of the user.",
                                          "adminConsentDisplayName":  "Read education app settings",
                                          "id":  "8523895c-6081-45bf-8a5d-f062a2f12c9f",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to view the state and settings of all Microsoft education apps on your behalf.",
                                          "userConsentDisplayName":  "View your education app settings",
                                          "value":  "EduAdministration.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write assignments and their grades on behalf of the user.",
                                          "adminConsentDisplayName":  "Read and write users\u0027 class assignments and their grades",
                                          "id":  "2f233e90-164b-4501-8bce-31af2559a2d3",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to view and modify your assignments on your behalf including ?grades.",
                                          "userConsentDisplayName":  "View and modify your assignments and grades",
                                          "value":  "EduAssignments.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read assignments and their grades on behalf of the user.",
                                          "adminConsentDisplayName":  "Read users\u0027 class assignments and their grades",
                                          "id":  "091460c9-9c4a-49b2-81ef-1f3d852acce2",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to view your assignments on your behalf including grades.",
                                          "userConsentDisplayName":  "View your assignments and grades",
                                          "value":  "EduAssignments.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write assignments without grades on behalf of the user.",
                                          "adminConsentDisplayName":  "Read and write users\u0027 class assignments without grades",
                                          "id":  "2ef770a1-622a-47c4-93ee-28d6adbed3a0",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to view and modify your assignments on your behalf without seeing grades.",
                                          "userConsentDisplayName":  "View and modify your assignments without grades",
                                          "value":  "EduAssignments.ReadWriteBasic"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read assignments without grades on behalf of the user.",
                                          "adminConsentDisplayName":  "Read users\u0027 class assignments without grades",
                                          "id":  "c0b0103b-c053-4b2e-9973-9f3a544ec9b8",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to view your assignments on your behalf without seeing grades.",
                                          "userConsentDisplayName":  "View your assignments without grades",
                                          "value":  "EduAssignments.ReadBasic"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write the structure of schools and classes in an organization\u0027s roster and education-specific information about users to be read and written on behalf of the user.",
                                          "adminConsentDisplayName":  "Read and write users\u0027 view of the roster",
                                          "id":  "359e19a6-e3fa-4d7f-bcab-d28ec592b51e",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to view and modify information about schools and classes in your organization and education-related information about you and other users on your behalf.",
                                          "userConsentDisplayName":  "View and modify your school, class and user information",
                                          "value":  "EduRoster.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the structure of schools and classes in an organization\u0027s roster and education-specific information about users to be read on behalf of the user.",
                                          "adminConsentDisplayName":  "Read users\u0027 view of the roster",
                                          "id":  "a4389601-22d9-4096-ac18-36a927199112",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to view information about schools and classes in your organization and education-related information about you and other users on your behalf.",
                                          "userConsentDisplayName":  "View your school, class and user information",
                                          "value":  "EduRoster.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read a limited subset of the properties from the structure of schools and classes in an organization\u0027s roster and a limited subset of properties about users to be read on behalf of the user.?Includes name, status, education role, email address and photo.",
                                          "adminConsentDisplayName":  "Read a limited subset of users\u0027 view of the roster",
                                          "id":  "5d186531-d1bf-4f07-8cea-7c42119e1bd9",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to view minimal ?information about both schools and classes in your organization and education-related information about you and other users on your behalf.",
                                          "userConsentDisplayName":  "View a limited subset of your school, class and user information",
                                          "value":  "EduRoster.ReadBasic"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to report the signed-in user\u0027s app activity information to Microsoft Timeline.",
                                          "adminConsentDisplayName":  "Write app activity to users\u0027 timeline",
                                          "id":  "367492fc-594d-4972-a9b5-0d58c622c91c",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to report your app activity information to Microsoft Timeline.",
                                          "userConsentDisplayName":  "Write app activity to your timeline",
                                          "value":  "UserTimelineActivity.Write.CreatedByApp"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete user\u0027s mailbox settings. Does not include permission to send mail.",
                                          "adminConsentDisplayName":  "Read and write user mailbox settings",
                                          "id":  "818c620a-27a9-40bd-a6a5-d96f7d610b4b",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, update, create, and delete your mailbox settings.",
                                          "userConsentDisplayName":  "Read and write to your mailbox settings",
                                          "value":  "MailboxSettings.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to launch another app or communicate with another app on a user\u0027s device on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Communicate with user devices",
                                          "id":  "bac3b9c2-b516-4ef4-bd3b-c2ef73d8d804",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to launch another app or communicate with another app on a device that you own.",
                                          "userConsentDisplayName":  "Communicate with your other devices",
                                          "value":  "Device.Command"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read a user\u0027s list of devices on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read user devices",
                                          "id":  "11d4cd79-5ba5-460f-803f-e22c8ab85ccd",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to see your list of devices.",
                                          "userConsentDisplayName":  "View your list of devices",
                                          "value":  "Device.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read, share, and modify OneNote notebooks that the signed-in user has access to in the organization.",
                                          "adminConsentDisplayName":  "Read and write all OneNote notebooks that user can access",
                                          "id":  "64ac0503-b4fa-45d9-b544-71a463f05da0",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, share, and modify all the OneNote notebooks that you have access to.",
                                          "userConsentDisplayName":  "Read and write all OneNote notebooks that you can access",
                                          "value":  "Notes.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read OneNote notebooks that the signed-in user has access to in the organization.",
                                          "adminConsentDisplayName":  "Read all OneNote notebooks that user can access",
                                          "id":  "dfabfca6-ee36-4db2-8208-7a28381419b3",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read all the OneNote notebooks that you have access to.",
                                          "userConsentDisplayName":  "Read all OneNote notebooks that you can access",
                                          "value":  "Notes.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read, share, and modify OneNote notebooks on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write user OneNote notebooks",
                                          "id":  "615e26af-c38a-4150-ae3e-c3b0d4cb1d6a",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, share, and modify OneNote notebooks on your behalf.",
                                          "userConsentDisplayName":  "Read and write your OneNote notebooks",
                                          "value":  "Notes.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read OneNote notebooks on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read user OneNote notebooks",
                                          "id":  "371361e4-b9e2-4a3f-8315-2a301a3b0a3d",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read OneNote notebooks on your behalf.",
                                          "userConsentDisplayName":  "Read your OneNote notebooks",
                                          "value":  "Notes.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "This is deprecated!  Do not use! This permission no longer has any effect. You can safely consent to it. No additional privileges will be granted to the app.",
                                          "adminConsentDisplayName":  "Limited notebook access (deprecated)",
                                          "id":  "ed68249d-017c-4df5-9113-e684c7f8760b",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "This permission no longer has any effect. You can safely consent to it. No additional privileges will be granted to the app.",
                                          "userConsentDisplayName":  "Limited access to your OneNote notebooks for this app (preview)",
                                          "value":  "Notes.ReadWrite.CreatedByApp"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the titles of OneNote notebooks and sections and to create new pages, notebooks, and sections on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Create user OneNote notebooks",
                                          "id":  "9d822255-d64d-4b7a-afdb-833b9a97ed02",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to view the titles of your OneNote notebooks and sections and to create new pages, notebooks, and sections on your behalf.",
                                          "userConsentDisplayName":  "Create your OneNote notebooks",
                                          "value":  "Notes.Create"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to invite guest users to the organization, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Invite guest users to the organization",
                                          "id":  "63dd7cd9-b489-4adf-a28c-ac38b9a0f962",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to invite guest users to the organization, on your behalf.",
                                          "userConsentDisplayName":  "Invite guest users to the organization",
                                          "value":  "User.Invite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to the read user\u0027s mailbox settings. Does not include permission to send mail.",
                                          "adminConsentDisplayName":  "Read user mailbox settings",
                                          "id":  "87f447af-9fa4-4c32-9dfa-4a57a73d18ce",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your mailbox settings.",
                                          "userConsentDisplayName":  "Read your mailbox settings",
                                          "value":  "MailboxSettings.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "(Preview) Allows the app to read files that the user selects. The app has access for several hours after the user selects a file.",
                                          "adminConsentDisplayName":  "Read files that the user selects (preview)",
                                          "id":  "5447fe39-cb82-4c1a-b977-520e67e724eb",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "(Preview) Allows the app to read files that you select. After you select a file, the app has access to the file for several hours.",
                                          "userConsentDisplayName":  "Read selected files",
                                          "value":  "Files.Read.Selected"
                                      },
                                      {
                                          "adminConsentDescription":  "(Preview) Allows the app to read and write files that the user selects. The app has access for several hours after the user selects a file.",
                                          "adminConsentDisplayName":  "Read and write files that the user selects (preview)",
                                          "id":  "17dde5bd-8c17-420f-a486-969730c1b827",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "(Preview) Allows the app to read and write files that you select. After you select a file, the app has access to the file for several hours.",
                                          "userConsentDisplayName":  "Read and write selected files",
                                          "value":  "Files.ReadWrite.Selected"
                                      },
                                      {
                                          "adminConsentDescription":  "(Preview) Allows the app to read, create, update and delete files in the application\u0027s folder.",
                                          "adminConsentDisplayName":  "Have full access to the application\u0027s folder (preview)",
                                          "id":  "8019c312-3263-48e6-825e-2b833497195b",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "(Preview) Allows the app to read, create, update and delete files in the application\u0027s folder.",
                                          "userConsentDisplayName":  "Have full access to the application\u0027s folder",
                                          "value":  "Files.ReadWrite.AppFolder"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read all service usage reports on behalf of the signed-in user.  Services that provide usage reports include Office 365 and Azure Active Directory.",
                                          "adminConsentDisplayName":  "Read all usage reports",
                                          "id":  "02e97553-ed7b-43d0-ab3c-f8bace0d040c",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows an app to read all service usage reports on your behalf. Services that provide usage reports include Office 365 and Azure Active Directory.",
                                          "userConsentDisplayName":  "Read all usage reports",
                                          "value":  "Reports.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the application to edit or delete documents and list items in all site collections on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Edit or delete items in all site collections",
                                          "id":  "89fe6a52-be36-487e-b7d8-d061c450a026",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allow the application to edit or delete documents and list items in all site collections on your behalf.",
                                          "userConsentDisplayName":  "Edit or delete items in all site collections",
                                          "value":  "Sites.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete tasks a user has permissions to, including their own and shared tasks.",
                                          "adminConsentDisplayName":  "Read and write user and shared tasks",
                                          "id":  "c5ddf11b-c114-4886-8558-8a4e557cd52b",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, update, create, and delete tasks you have permissions to access, including your own and shared tasks.",
                                          "userConsentDisplayName":  "Read and write to your and shared tasks",
                                          "value":  "Tasks.ReadWrite.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read tasks a user has permissions to access, including their own and shared tasks.",
                                          "adminConsentDisplayName":  "Read user and shared tasks",
                                          "id":  "88d21fd4-8e5a-4c32-b5e2-4a1c95f34f72",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read tasks you have permissions to access, including your own and shared tasks.",
                                          "userConsentDisplayName":  "Read your and shared tasks",
                                          "value":  "Tasks.Read.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete contacts a user has permissions to, including their own and shared contacts.",
                                          "adminConsentDisplayName":  "Read and write user and shared contacts",
                                          "id":  "afb6c84b-06be-49af-80bb-8f3f77004eab",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, update, create, and delete contacts you have permissions to access, including your own and shared contacts.",
                                          "userConsentDisplayName":  "Read and write to your and shared contacts",
                                          "value":  "Contacts.ReadWrite.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read contacts a user has permissions to access, including their own and shared contacts.",
                                          "adminConsentDisplayName":  "Read user and shared contacts",
                                          "id":  "242b9d9e-ed24-4d09-9a52-f43769beb9d4",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read contacts you have permissions to access, including your own and shared contacts.",
                                          "userConsentDisplayName":  "Read your and shared contacts",
                                          "value":  "Contacts.Read.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update and delete events in all calendars in the organization user has permissions to access. This includes delegate and shared calendars.",
                                          "adminConsentDisplayName":  "Read and write user and shared calendars",
                                          "id":  "12466101-c9b8-439a-8589-dd09ee67e8e9",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, update, create and delete events in all calendars in your organization you have permissions to access. This includes delegate and shared calendars.",
                                          "userConsentDisplayName":  "Read and write to your and shared calendars",
                                          "value":  "Calendars.ReadWrite.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read events in all calendars that the user can access, including delegate and shared calendars.",
                                          "adminConsentDisplayName":  "Read user and shared calendars",
                                          "id":  "2b9c4092-424d-4249-948d-b43879977640",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read events in all calendars that you can access, including delegate and shared calendars.?",
                                          "userConsentDisplayName":  "Read calendars?you can access",
                                          "value":  "Calendars.Read.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to send mail as the signed-in user, including sending on-behalf of others.",
                                          "adminConsentDisplayName":  "Send mail on behalf of others",
                                          "id":  "a367ab51-6b49-43bf-a716-a1fb06d2a174",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to send mail as you or on-behalf of someone else.",
                                          "userConsentDisplayName":  "Send mail on behalf of others or yourself",
                                          "value":  "Mail.Send.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete mail a user has permission to access, including their own and shared mail. Does not include permission to send mail.",
                                          "adminConsentDisplayName":  "Read and write user and shared mail",
                                          "id":  "5df07973-7d5d-46ed-9847-1271055cbd51",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, update, create, and delete mail you have permission to access, including your own and shared mail. Does not allow the app to send mail on your behalf.",
                                          "userConsentDisplayName":  "Read and write mail?you can access",
                                          "value":  "Mail.ReadWrite.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read mail a user can access, including their own and shared mail.",
                                          "adminConsentDisplayName":  "Read user and shared mail",
                                          "id":  "7b9103a5-4610-446b-9670-80643382c1fa",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read mail you can access, including shared mail.",
                                          "userConsentDisplayName":  "Read mail you can access",
                                          "value":  "Mail.Read.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows users to sign-in to the app, and allows the app to read the profile of signed-in users. It also allows the app to read basic company information of signed-in users.",
                                          "adminConsentDisplayName":  "Sign in and read user profile",
                                          "id":  "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows you to sign in to the app with your organizational account and let the app read your profile. It also allows the app to read basic company information.",
                                          "userConsentDisplayName":  "Sign you in and read your profile",
                                          "value":  "User.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your profile. It also allows the app to update your profile information on your behalf.",
                                          "adminConsentDisplayName":  "Read and write access to user profile",
                                          "id":  "b4e74841-8e56-480b-be8b-910348b18b4c",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your profile, and discover your group membership, reports and manager. It also allows the app to update your profile information on your behalf.",
                                          "userConsentDisplayName":  "Read and update your profile",
                                          "value":  "User.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read a basic set of profile properties of other users in your organization on behalf of the signed-in user. This includes display name, first and last name, email address and photo.",
                                          "adminConsentDisplayName":  "Read all users\u0027 basic profiles",
                                          "id":  "b340eb25-3456-403f-be2f-af7a0d370277",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read a basic set of profile properties of other users in your organization on your behalf. Includes display name, first and last name, email address and photo.",
                                          "userConsentDisplayName":  "Read all users\u0027 basic profiles",
                                          "value":  "User.ReadBasic.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the full set of profile properties, reports, and managers of other users in your organization, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read all users\u0027 full profiles",
                                          "id":  "a154be20-db9c-4678-8ab7-66f6cc099a59",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read the full set of profile properties, reports, and managers of other users in your organization, on your behalf.",
                                          "userConsentDisplayName":  "Read all users\u0027 full profiles",
                                          "value":  "User.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write the full set of profile properties, reports, and managers of other users in your organization, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write all users\u0027 full profiles",
                                          "id":  "204e0828-b5ca-4ad8-b9f3-f32a958e7cc4",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write the full set of profile properties, reports, and managers of other users in your organization, on your behalf.",
                                          "userConsentDisplayName":  "Read and write all users\u0027 full profiles",
                                          "value":  "User.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to list groups, and to read their properties and all group memberships on behalf of the signed-in user.  Also allows the app to read calendar, conversations, files, and other group content for all groups the signed-in user can access. ",
                                          "adminConsentDisplayName":  "Read all groups",
                                          "id":  "5f8c59db-677d-491f-a6b8-5f174b11ec1d",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to list groups, and to read their properties and all group memberships on your behalf.  Also allows the app to read calendar, conversations, files, and other group content for all groups you can access.  ",
                                          "userConsentDisplayName":  "Read all groups",
                                          "value":  "Group.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create groups and read all group properties and memberships on behalf of the signed-in user.  Additionally allows group owners to manage their groups and allows group members to update group content.",
                                          "adminConsentDisplayName":  "Read and write all groups",
                                          "id":  "4e46008b-f24c-477d-8fff-7bb4ec7aafe0",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to create groups and read all group properties and memberships on your behalf.  Additionally allows the app to manage your groups and to update group content for groups you are a member of.",
                                          "userConsentDisplayName":  "Read and write all groups",
                                          "value":  "Group.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read data in your organization\u0027s directory, such as users, groups and apps.",
                                          "adminConsentDisplayName":  "Read directory data",
                                          "id":  "06da0dbc-49e2-44d2-8312-53f166ab848a",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read data in your organization\u0027s directory.",
                                          "userConsentDisplayName":  "Read directory data",
                                          "value":  "Directory.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write data in your organization\u0027s directory, such as users, and groups.  It does not allow the app to delete users or groups, or reset user passwords.",
                                          "adminConsentDisplayName":  "Read and write directory data",
                                          "id":  "c5366453-9fb0-48a5-a156-24f0c49a4b84",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write data in your organization\u0027s directory, such as other users, groups.  It does not allow the app to delete users or groups, or reset user passwords.",
                                          "userConsentDisplayName":  "Read and write directory data",
                                          "value":  "Directory.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to have the same access to information in the directory as the signed-in user.",
                                          "adminConsentDisplayName":  "Access directory as the signed in user",
                                          "id":  "0e263e50-5827-48a4-b97c-d940288653c7",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to have the same access to information in your work or school directory as you do.",
                                          "userConsentDisplayName":  "Access the directory as you",
                                          "value":  "Directory.AccessAsUser.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read email in user mailboxes. ",
                                          "adminConsentDisplayName":  "Read user mail ",
                                          "id":  "570282fd-fa5c-430d-a7fd-fc8dc98a9dca",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read email in your mailbox. ",
                                          "userConsentDisplayName":  "Read your mail ",
                                          "value":  "Mail.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete email in user mailboxes. Does not include permission to send mail. ",
                                          "adminConsentDisplayName":  "Read and write access to user mail ",
                                          "id":  "024d486e-b451-40bb-833d-3e66d98c5c73",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, update, create and delete email in your mailbox. Does not include permission to send mail. ",
                                          "userConsentDisplayName":  "Read and write access to your mail ",
                                          "value":  "Mail.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to send mail as users in the organization. ",
                                          "adminConsentDisplayName":  "Send mail as a user ",
                                          "id":  "e383f46e-2787-4529-855e-0e479a3ffac0",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to send mail as you. ",
                                          "userConsentDisplayName":  "Send mail as you ",
                                          "value":  "Mail.Send"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read events in user calendars . ",
                                          "adminConsentDisplayName":  "Read user calendars ",
                                          "id":  "465a38f9-76ea-45b9-9f34-9e8b0d4b0b42",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read events in your calendars. ",
                                          "userConsentDisplayName":  "Read your calendars ",
                                          "value":  "Calendars.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete events in user calendars. ",
                                          "adminConsentDisplayName":  "Have full access to user calendars ",
                                          "id":  "1ec239c2-d7c9-4623-a91a-a9775856bb36",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, update, create and delete events in your calendars. ",
                                          "userConsentDisplayName":  "Have full access to your calendars  ",
                                          "value":  "Calendars.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read user contacts.  ",
                                          "adminConsentDisplayName":  "Read user contacts ",
                                          "id":  "ff74d97f-43af-4b68-9f2a-b77ee6968c5d",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read contacts in your contact folders. ",
                                          "userConsentDisplayName":  "Read your contacts ",
                                          "value":  "Contacts.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete user contacts. ",
                                          "adminConsentDisplayName":  "Have full access to user contacts ",
                                          "id":  "d56682ec-c09e-4743-aaf4-1a3aac4caa21",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, update, create and delete contacts in your contact folders. ",
                                          "userConsentDisplayName":  "Have full access of your contacts ",
                                          "value":  "Contacts.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the signed-in user\u0027s files.",
                                          "adminConsentDisplayName":  "Read user files",
                                          "id":  "10465720-29dd-4523-a11a-6a75c743c9d9",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your files.",
                                          "userConsentDisplayName":  "Read your files",
                                          "value":  "Files.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read, create, update and delete the signed-in user\u0027s files.",
                                          "adminConsentDisplayName":  "Have full access to user files",
                                          "id":  "5c28f0bf-8a70-41f1-8ab2-9032436ddb65",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, create, update, and delete your files.",
                                          "userConsentDisplayName":  "Have full access to your files",
                                          "value":  "Files.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read all files the signed-in user can access.",
                                          "adminConsentDisplayName":  "Read all files that user can access",
                                          "id":  "df85f4d6-205c-4ac5-a5ea-6bf408dba283",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read all files you can access.",
                                          "userConsentDisplayName":  "Read all files that you have access to",
                                          "value":  "Files.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read, create, update and delete all files the signed-in user can access.",
                                          "adminConsentDisplayName":  "Have full access to all files user can access",
                                          "id":  "863451e7-0667-486c-a5d6-d135439485f0",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, create, update and delete all files that you can access.",
                                          "userConsentDisplayName":  "Have full access to all files you have access to",
                                          "value":  "Files.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the application to read documents and list  items in all site collections on behalf of the signed-in user",
                                          "adminConsentDisplayName":  "Read items in all site collections",
                                          "id":  "205e70e5-aba6-4c52-a976-6d2d46c48043",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allow the application to read documents and list items in all site collections on your behalf",
                                          "userConsentDisplayName":  "Read items in all site collections",
                                          "value":  "Sites.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows users to sign in to the app with their work or school accounts and allows the app to see basic user profile information.",
                                          "adminConsentDisplayName":  "Sign users in",
                                          "id":  "37f7f235-527c-4136-accd-4a02d197296e",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows you to sign in to the app with your work or school account and allows the app to read your basic profile information.",
                                          "userConsentDisplayName":  "Sign in as you",
                                          "value":  "openid"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and update user data, even when they are not currently using the app.",
                                          "adminConsentDisplayName":  "Access user\u0027s data anytime",
                                          "id":  "7427e0e9-2fba-42fe-b0c0-848c9e6a8182",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to see and update your data, even when you are not currently using the app.",
                                          "userConsentDisplayName":  "Access your data anytime",
                                          "value":  "offline_access"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read user tasks",
                                          "adminConsentDisplayName":  "Read user tasks",
                                          "id":  "f45671fb-e0fe-4b4b-be20-3d3ce43f1bcb",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your tasks",
                                          "userConsentDisplayName":  "Read your tasks",
                                          "value":  "Tasks.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your users\u0027 primary email address",
                                          "adminConsentDisplayName":  "View users\u0027 email address",
                                          "id":  "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your primary email address",
                                          "userConsentDisplayName":  "View your email address",
                                          "value":  "email"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to see your users\u0027 basic profile (name, picture, user name)",
                                          "adminConsentDisplayName":  "View users\u0027 basic profile",
                                          "id":  "14dad69e-099b-42c9-810b-d002981feec1",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to see your basic profile (name, picture, user name)",
                                          "userConsentDisplayName":  "View your basic profile",
                                          "value":  "profile"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read identity risk event information for all users in your organization on behalf of the signed-in user. ",
                                          "adminConsentDisplayName":  "Read identity risk event information",
                                          "id":  "8f6a01e7-0391-4ee5-aa22-a3af122cef27",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read identity risk event information for all users in your organization on behalf of the signed-in user. ",
                                          "userConsentDisplayName":  "Read identity risk event information",
                                          "value":  "IdentityRiskEvent.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the memberships of hidden groups and administrative units on behalf of the signed-in user, for those hidden groups and administrative units that the signed-in user has access to.",
                                          "adminConsentDisplayName":  "Read hidden memberships",
                                          "id":  "f6a3db3e-f7e8-4ed2-a414-557c8c9830be",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read the memberships of hidden groups or administrative units on your behalf, for those hidden groups or adminstrative units that you have access to.",
                                          "userConsentDisplayName":  "Read your hidden memberships",
                                          "value":  "Member.Read.Hidden"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update and delete tasks and plans (and tasks in them), that are assigned to or shared with the signed-in user.",
                                          "adminConsentDisplayName":  "Create, read, update and delete user tasks and projects",
                                          "id":  "2219042f-cab5-40cc-b0d2-16b1540b4c5f",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to create, read, update and delete tasks assigned to you and plans (and tasks in them) shared with or owned by you.",
                                          "userConsentDisplayName":  "Create, read, update and delete your tasks and projects",
                                          "value":  "Tasks.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read a ranked list of relevant people of the signed-in user. The list includes local contacts, contacts from social networking, your organization\u0027s directory, and people from recent communications (such as email and Skype).",
                                          "adminConsentDisplayName":  "Read users\u0027 relevant people lists",
                                          "id":  "ba47897c-39ec-4d83-8086-ee8256fa737d",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read a list of people in the order that\u0027s most relevant to you. This includes your local contacts, your contacts from social networking, people listed in your organization\u0027s directory, and people from recent communications.",
                                          "userConsentDisplayName":  "Read your relevant people list",
                                          "value":  "People.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the application to create or delete document libraries and lists in all site collections on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Create, edit, and delete items and lists in all site collections",
                                          "id":  "65e50fdc-43b7-4915-933e-e8138f11f40a",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allow the application to create or delete document libraries and lists in all site collections on your behalf.",
                                          "userConsentDisplayName":  "Create, edit, and delete items and lists in all your site collections",
                                          "value":  "Sites.Manage.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the application to have full control of all site collections on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Have full control of all site collections",
                                          "id":  "5a54b8b3-347c-476d-8f8e-42d5c7424d29",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allow the application to have full control of all site collections on your behalf.",
                                          "userConsentDisplayName":  "Have full control of all your site collections",
                                          "value":  "Sites.FullControl.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write your organization?s identity (authentication) providers? properties on behalf of the user.",
                                          "adminConsentDisplayName":  "Read and write identity providers",
                                          "id":  "f13ce604-1677-429f-90bd-8a10b9f01325",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write your organization?s identity (authentication) providers? properties on your behalf.",
                                          "userConsentDisplayName":  "Read and write identity providers",
                                          "value":  "IdentityProvider.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your organization?s identity (authentication) providers? properties on behalf of the user.",
                                          "adminConsentDisplayName":  "Read identity providers",
                                          "id":  "43781733-b5a7-4d1b-98f4-e8edff23e1a9",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read your organization?s identity (authentication) providers? properties on your behalf.",
                                          "userConsentDisplayName":  "Read identity providers",
                                          "value":  "IdentityProvider.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read bookings appointments, businesses, customers, services, and staff on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read bookings information",
                                          "id":  "33b1df99-4b29-4548-9339-7a7b83eaeebc",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows an app to read bookings appointments, businesses, customers, services, and staff on your behalf.",
                                          "userConsentDisplayName":  "Read bookings information",
                                          "value":  "Bookings.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read and write bookings appointments and customers, and additionally allows read businesses information, services, and staff on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write booking appointments",
                                          "id":  "02a5a114-36a6-46ff-a102-954d89d9ab02",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows an app to read and write bookings appointments and customers, and additionally allows read businesses information, services, and staff on your behalf.",
                                          "userConsentDisplayName":  "Read and write booking appointments",
                                          "value":  "BookingsAppointment.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read and write bookings appointments, businesses, customers, services, and staff on behalf of the signed-in user. Does not allow create, delete and publish of booking businesses.",
                                          "adminConsentDisplayName":  "Read and write bookings information",
                                          "id":  "948eb538-f19d-4ec5-9ccc-f059e1ea4c72",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows an app to read and write Bookings appointments, businesses, customers, services, and staff on your behalf. Does not allow create, delete and publish of booking businesses.",
                                          "userConsentDisplayName":  "Read and write bookings information",
                                          "value":  "Bookings.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read, write and manage bookings appointments, businesses, customers, services, and staff on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Manage bookings information",
                                          "id":  "7f36b48e-542f-4d3b-9bcb-8406f0ab9fdb",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows an app to read, write and manage bookings appointments, businesses, customers, services, and staff on your behalf.",
                                          "userConsentDisplayName":  "Manage bookings information",
                                          "value":  "Bookings.Manage.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to have the same access to mailboxes as the signed-in user via Exchange ActiveSync.",
                                          "adminConsentDisplayName":  "Access mailboxes via Exchange ActiveSync",
                                          "id":  "ff91d191-45a0-43fd-b837-bd682c4a0b0f",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app full access to your mailboxes on your behalf.",
                                          "userConsentDisplayName":  "Access your mailboxes",
                                          "value":  "EAS.AccessAsUser.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write financials data on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write financials data",
                                          "id":  "f534bf13-55d4-45a9-8f3c-c92fe64d6131",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read and write financials data on your behalf.",
                                          "userConsentDisplayName":  "Read and write financials data",
                                          "value":  "Financials.ReadWrite.All"
                                      }
                                  ],
    "preferredTokenSigningKeyThumbprint":  null,
    "publisherName":  "Microsoft Services",
    "replyUrls":  [

                  ],
    "samlMetadataUrl":  null,
    "servicePrincipalNames":  [
                                  "00000003-0000-0000-c000-000000000000/ags.windows.net",
                                  "00000003-0000-0000-c000-000000000000",
                                  "https://canary.graph.microsoft.com",
                                  "https://graph.microsoft.com",
                                  "https://ags.windows.net",
                                  "https://graph.microsoft.us",
                                  "https://graph.microsoft.com/"
                              ],
    "signInAudience":  "AzureADMultipleOrgs",
    "tags":  [

             ],
    "addIns":  [

               ],
    "appRoles":  [
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read, update, delete and perform actions on programs and program controls in the organization, without a signed-in user.",
                         "displayName":  "Manage all programs",
                         "id":  "60a901ed-09f7-4aa5-a16e-7dd3d6f9de36",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ProgramControl.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read programs and program controls in the organization, without a signed-in user.",
                         "displayName":  "Read all programs",
                         "id":  "eedb7fdd-7539-4345-a38b-4839e4a84cbd",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ProgramControl.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read, update, delete and perform actions on access reviews, reviewers, decisions and settings in the organization, without a signed-in user.",
                         "displayName":  "Manage all access reviews",
                         "id":  "ef5f7d5c-338f-44b0-86c3-351f46c8bb5f",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "AccessReview.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read access reviews, reviewers, decisions and settings in the organization, without a signed-in user.",
                         "displayName":  "Read all access reviews",
                         "id":  "d07a8cc0-3d51-4b77-b3b0-32704d1f69fa",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "AccessReview.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the identity risky user information for your organization without a signed in user.",
                         "displayName":  "Read all identity risky user information",
                         "id":  "dc5007c0-2d7d-4c42-879c-2dab87571379",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "identityriskyuser.read.all"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and create online meetings as an application in your organization.",
                         "displayName":  "Read and create online meetings (preview)",
                         "id":  "b8bb2037-6e08-44ac-a4ea-4674e010e2a4",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "OnlineMeetings.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows an app to read all service usage reports without a signed-in user.  Services that provide usage reports include Office 365 and Azure Active Directory.",
                         "displayName":  "Read all usage reports",
                         "id":  "230c1aed-a721-4c5d-9cb4-a90514e508ef",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Reports.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read any user\u0027s scored list of relevant people, without a signed-in user. The list can include local contacts, contacts from social networking, your organization\u0027s directory, and people from recent communications (such as email and Skype).",
                         "displayName":  "Read all users\u0027 relevant people lists",
                         "id":  "b528084d-ad10-4598-8b93-929746b4d7d6",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "People.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to update Microsoft Teams 1-to-1 or group chat messages by patching a set of Data Loss Prevention (DLP) policy violation properties to handle the output of DLP processing.",
                         "displayName":  "Flag chat messages for violating policy",
                         "id":  "7e847308-e030-4183-9899-5235d7270f58",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Chat.UpdatePolicyViolation.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all 1-to-1 or group chat messages in Microsoft Teams.",
                         "displayName":  "Read all chat messages",
                         "id":  "6b7d71aa-70aa-4810-a8d9-5d9fb2830017",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Chat.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all channel messages in Microsoft Teams",
                         "displayName":  "Read all channel messages",
                         "id":  "7b2449af-6ccd-4f4d-9f78-e550c193f0d1",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ChannelMessage.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to update Microsoft Teams channel messages by patching a set of Data Loss Prevention (DLP) policy violation properties to handle the output of DLP processing.",
                         "displayName":  "Flag channel messages for violating policy",
                         "id":  "4d02b0cc-d90b-441f-8d82-4fb55c34d6bb",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ChannelMessage.UpdatePolicyViolation.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create, read, update and delete applications and service principals without a signed-in user.  Does not allow management of consent grants.",
                         "displayName":  "Read and write all applications",
                         "id":  "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Application.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create other applications, and fully manage those applications (read, update, update application secrets and delete), without a signed-in user. ?It cannot update any apps that it is not an owner of.",
                         "displayName":  "Manage apps that this app creates or owns",
                         "id":  "18a4783c-866b-4cc7-a460-3d5e5662c884",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Application.ReadWrite.OwnedBy"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read online meeting details in your organization, without a signed-in user.",
                         "displayName":  "Read online meeting details (preview)",
                         "id":  "c1684f21-1984-47fa-9d61-2dc8c296bb70",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "OnlineMeetings.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to get direct access to media streams in a call, without a signed-in user.",
                         "displayName":  "Access media streams in a call as an app (preview)",
                         "id":  "a7a681dc-756e-4909-b988-f160edc6655f",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.AccessMedia.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to anonymously join group calls and scheduled meetings in your organization, without a signed-in user. ?The app will be joined as a guest to meetings in your organization.",
                         "displayName":  "Join group calls and meetings as a guest (preview)",
                         "id":  "fd7ccf6b-3d28-418b-9701-cd10f5cd2fd4",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.JoinGroupCallAsGuest.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to join group calls and scheduled meetings in your organization, without a signed-in user. ?The app will be joined with the privileges of a directory user to meetings in your organization.",
                         "displayName":  "Join group calls and meetings as an app (preview)",
                         "id":  "f6b49018-60ab-4f81-83bd-22caeabfed2d",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.JoinGroupCall.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to place outbound calls to multiple users and add participants to meetings in your organization, without a signed-in user.",
                         "displayName":  "Initiate outgoing group calls from the app (preview)",
                         "id":  "4c277553-8a09-487b-8023-29ee378d8324",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.InitiateGroupCall.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to place outbound calls to a single user and transfer calls to users in your organization?s directory, without a signed-in user.",
                         "displayName":  "Initiate outgoing 1:1 calls from the app (preview)",
                         "id":  "284383ee-7f6e-4e40-a2a8-e85dcb029101",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.Initiate.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and query your audit log activities, without a signed-in user.",
                         "displayName":  "Read all audit log data",
                         "id":  "b0afded3-3588-46d8-8b3d-9842eff778da",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "AuditLog.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read your organization?s security events without a signed-in user.",
                         "displayName":  "Read your organization?s security events",
                         "id":  "bf394140-e372-4bf9-a898-299cfc7564e5",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "SecurityEvents.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read your organization?s security events without a signed-in user. Also allows the app to update editable properties in security events.",
                         "displayName":  "Read and update your organization?s security events",
                         "id":  "d903a879-88e0-4c09-b0c9-82f6a1333f84",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "SecurityEvents.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create, read, update, and delete documents and list items in all site collections without a signed in user.",
                         "displayName":  "Read and write items in all site collections (preview)",
                         "id":  "9492366f-7969-46a4-8d15-ed1a20078fff",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Sites.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read documents and list items in all site collections without a signed in user.",
                         "displayName":  "Read items in all site collections (preview)",
                         "id":  "332a536c-c7ef-4017-ab91-336970924f0d",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Sites.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Manage the state and settings of all Microsoft education apps.",
                         "displayName":  "Manage education app settings",
                         "id":  "9bc431c3-b8bc-4a8d-a219-40f10f92eff6",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduAdministration.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Read the state and settings of all Microsoft education apps.",
                         "displayName":  "Read Education app settings",
                         "id":  "7c9db06a-ec2d-4e7b-a592-5a1e30992566",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduAdministration.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write assignments and their grades for all users.",
                         "displayName":  "Read and write class assignments with grades",
                         "id":  "0d22204b-6cad-4dd0-8362-3e3f2ae699d9",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduAssignments.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read assignments and their grades for all users.",
                         "displayName":  "Read class assignments with grades",
                         "id":  "4c37e1b6-35a1-43bf-926a-6f30f2cdf585",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduAssignments.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write assignments without grades for all users.",
                         "displayName":  "Read and write class assignments without grades",
                         "id":  "f431cc63-a2de-48c4-8054-a34bc093af84",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduAssignments.ReadWriteBasic.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read assignments without grades for all users.",
                         "displayName":  "Read class assignments without grades",
                         "id":  "6e0a958b-b7fc-4348-b7c4-a6ab9fd3dd0e",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduAssignments.ReadBasic.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write the structure of schools and classes in the organization\u0027s roster and education-specific information about all users to be read and written.",
                         "displayName":  "Read and write the organization\u0027s roster",
                         "id":  "d1808e82-ce13-47af-ae0d-f9b254e6d58a",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduRoster.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the structure of schools and classes in the organization\u0027s roster and education-specific information about all users to be read.",
                         "displayName":  "Read the organization\u0027s roster",
                         "id":  "e0ac9e1b-cb65-4fc5-87c5-1a8bc181f648",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduRoster.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read a limited subset of properties from both the structure of schools and classes in the organization\u0027s roster and education-specific information about all users. Includes name, status, role, email address and photo.",
                         "displayName":  "Read a limited subset of the organization\u0027s roster",
                         "id":  "0d412a8c-a06c-439f-b3ec-8abcf54d2f96",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "EduRoster.ReadBasic.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create, read, update, and delete user\u0027s mailbox settings without a signed-in user. Does not include permission to send mail.",
                         "displayName":  "Read and write all user mailbox settings",
                         "id":  "6931bccd-447a-43d1-b442-00a195474933",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "MailboxSettings.ReadWrite"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all the OneNote notebooks in your organization, without a signed-in user.",
                         "displayName":  "Read and write all OneNote notebooks",
                         "id":  "0c458cef-11f3-48c2-a568-c66751c238c0",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Notes.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all the OneNote notebooks in your organization, without a signed-in user.",
                         "displayName":  "Read all OneNote notebooks",
                         "id":  "3aeca27b-ee3a-4c2b-8ded-80376e2134a4",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Notes.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write all domain properties without a signed in user. ?Also allows the app to add, ?verify and remove domains.",
                         "displayName":  "Read and write domains",
                         "id":  "7e05723c-0bb0-42da-be95-ae9f08a6e53c",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Domain.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to invite guest users to the organization, without a signed-in user.",
                         "displayName":  "Invite guest users to the organization",
                         "id":  "09850681-111b-4a89-9bed-3f2cae46d706",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "User.Invite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read user\u0027s mailbox settings without a signed-in user. Does not include permission to send mail.",
                         "displayName":  "Read all user mailbox settings",
                         "id":  "40f97065-369a-49f4-947c-6a255697ae91",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "MailboxSettings.Read"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the memberships of hidden groups and administrative units without a signed-in user.",
                         "displayName":  "Read all hidden memberships",
                         "id":  "658aa5d8-239f-45c4-aa12-864f4fc7e490",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Member.Read.Hidden"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read mail in all mailboxes without a signed-in user.",
                         "displayName":  "Read mail in all mailboxes",
                         "id":  "810c84a8-4a9e-49e6-bf7d-12d183f40d01",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Mail.Read"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create, read, update, and delete mail in all mailboxes without a signed-in user. Does not include permission to send mail.",
                         "displayName":  "Read and write mail in all mailboxes",
                         "id":  "e2a3a72e-5f79-4c64-b1b1-878b674786c9",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Mail.ReadWrite"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to send mail as any user without a signed-in user.",
                         "displayName":  "Send mail as any user",
                         "id":  "b633e1c5-b582-4048-a93e-9f11b44c7e96",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Mail.Send"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all contacts in all mailboxes without a signed-in user.",
                         "displayName":  "Read contacts in all mailboxes",
                         "id":  "089fe4d0-434a-44c5-8827-41ba8a0b17f5",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Contacts.Read"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create, read, update, and delete all contacts in all mailboxes without a signed-in user.",
                         "displayName":  "Read and write contacts in all mailboxes",
                         "id":  "6918b873-d17a-4dc1-b314-35f528134491",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Contacts.ReadWrite"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read group properties and memberships, and read the calendar and conversations for all groups, without a signed-in user.",
                         "displayName":  "Read all groups",
                         "id":  "5b567255-7703-4780-807c-7be8301ae99b",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Group.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create groups, read all group properties and memberships, update group properties and memberships, and delete groups. Also allows the app to read and write group calendar and conversations.  All of these operations can be performed by the app without a signed-in user.",
                         "displayName":  "Read and write all groups",
                         "id":  "62a82d76-70ea-41e2-9197-370581804d09",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Group.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read data in your organization\u0027s directory, such as users, groups and apps, without a signed-in user.",
                         "displayName":  "Read directory data",
                         "id":  "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Directory.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write data in your organization\u0027s directory, such as users, and groups, without a signed-in user.  Does not allow user or group deletion.",
                         "displayName":  "Read and write directory data",
                         "id":  "19dbc75e-c2e2-444c-a770-ec69d8559fc7",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Directory.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write all device properties without a signed in user.  Does not allow device creation, device deletion or update of device alternative security identifiers.",
                         "displayName":  "Read and write devices",
                         "id":  "1138cb37-bd11-4084-a2b7-9f71582aeddb",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Device.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read user profiles without a signed in user.",
                         "displayName":  "Read all users\u0027 full profiles",
                         "id":  "df021288-bdef-4463-88db-98f22de89214",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "User.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and update user profiles without a signed in user.",
                         "displayName":  "Read and write all users\u0027 full profiles",
                         "id":  "741f803b-c850-494e-b5df-cde7c675a1ca",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "User.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the identity risk event information for your organization without a signed in user.",
                         "displayName":  "Read all identity risk event information",
                         "id":  "6e472fd1-ad78-48da-a0f0-97ab2c6b769e",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "IdentityRiskEvent.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read events of all calendars without a signed-in user.",
                         "displayName":  "Read calendars in all mailboxes",
                         "id":  "798ee544-9d2d-430c-a058-570e29e34338",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calendars.Read"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create, read, update, and delete events of all calendars without a signed-in user.",
                         "displayName":  "Read and write calendars in all mailboxes",
                         "id":  "ef54d2bf-783f-4e0f-bca1-3210c0444d99",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calendars.ReadWrite"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read, create, update and delete all files in all site collections without a signed in user. ",
                         "displayName":  "Read and write files in all site collections",
                         "id":  "75359482-378d-4052-8f01-80520e7db3cd",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Files.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all files in all site collections without a signed in user.",
                         "displayName":  "Read files in all site collections",
                         "id":  "01d4889c-1287-42c6-ac1f-5d1e02578ef6",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Files.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create or delete document libraries and lists in all site collections without a signed in user.",
                         "displayName":  "Create, edit, and delete items and lists in all site collections",
                         "id":  "0c0bf378-bf22-4481-8f81-9e89a9b4960a",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Sites.Manage.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to have full control of all site collections without a signed in user.",
                         "displayName":  "Have full control of all site collections",
                         "id":  "a82116e5-55eb-4c41-a434-62fe8a61c773",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Sites.FullControl.All"
                     }
                 ],
    "keyCredentials":  [

                       ],
    "passwordCredentials":  [

                            ]
}
'@ | ConvertFrom-JSON
