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
    "id":  "2e0805e3-4dd1-46dc-bcb2-302f00f009e6",
    "deletedDateTime":  null,
    "accountEnabled":  true,
    "appDisplayName":  "Microsoft Graph",
    "appId":  "00000003-0000-0000-c000-000000000000",
    "applicationTemplateId":  null,
    "appOwnerOrganizationId":  "2b2ac5b3-67ed-4e66-82ca-65508361de47",
    "appRoleAssignmentRequired":  false,
    "displayName":  "Microsoft Graph",
    "errorUrl":  null,
    "homepage":  null,
    "info":  {
                 "termsOfServiceUrl":  null,
                 "supportUrl":  null,
                 "privacyStatementUrl":  null,
                 "marketingUrl":  null,
                 "logoUrl":  null
             },
    "loginUrl":  null,
    "logoutUrl":  null,
    "notificationEmailAddresses":  [

                                   ],
    "publishedPermissionScopes":  [
                                      {
                                          "adminConsentDescription":  "Allows the app to read basic BitLocker key properties on behalf of the signed-in user, for their owned devices. Does not allow read of the recovery key itself.",
                                          "adminConsentDisplayName":  "Read BitLocker keys basic information",
                                          "id":  "5a107bfc-4f00-4e1a-b67e-66451267bc68",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read basic BitLocker key properties for your owned devices. Does not allow read of the recovery key itself.",
                                          "userConsentDisplayName":  "Read your BitLocker keys basic information",
                                          "value":  "BitlockerKey.ReadBasic.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read BitLocker keys on behalf of the signed-in user, for their owned devices. Allows read of the recovery key.",
                                          "adminConsentDisplayName":  "Read BitLocker keys",
                                          "id":  "b27a61ec-b99c-4d6a-b126-c4375d08ae30",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read BitLocker keys for your owned devices. Allows read of the recovery key.",
                                          "userConsentDisplayName":  "Read your BitLocker keys",
                                          "value":  "BitlockerKey.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update and delete applications and service principals on behalf of the signed-in user. Does not allow management of consent grants.",
                                          "adminConsentDisplayName":  "Read and write all applications",
                                          "id":  "bdfbf15f-ee85-4955-8675-146e8e5296b5",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to create, read, update and delete applications and service principals on your behalf. Does not allow management of consent grants.",
                                          "userConsentDisplayName":  "Read and write applications",
                                          "value":  "Application.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read applications and service principals on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read applications",
                                          "id":  "c79f8feb-a9db-4090-85f9-90d820caa0eb",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read applications and service principals on your behalf.",
                                          "userConsentDisplayName":  "Read applications",
                                          "value":  "Application.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to send, read, update and delete user?s notifications.",
                                          "adminConsentDisplayName":  "Deliver and manage user\u0027s notifications",
                                          "id":  "26e2f3e8-b2a1-47fc-9620-89bb5b042024",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to send, read, update and delete your app-specific notifications.",
                                          "userConsentDisplayName":  "Deliver and manage your notifications",
                                          "value":  "UserNotification.ReadWrite.CreatedByApp"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to request access to and management of access packages and related entitlement management resources on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write entitlement management resources",
                                          "id":  "ae7a573d-81d7-432b-ad44-4ed5c9d89038",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to request access to and management of access packages and related entitlement management resources that you have access to.",
                                          "userConsentDisplayName":  "Read and write entitlement management resources",
                                          "value":  "EntitlementManagement.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read other users? personal places that the signed-in user has delegate access to. Also allows read of the signed-in user?s personal places.",
                                          "adminConsentDisplayName":  "Read user places for delegates",
                                          "id":  "0b3f56bc-fecd-4036-8930-660fc672e342",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your personal places and other users? personal places that you have delegate access to.",
                                          "userConsentDisplayName":  "Read user delegate places",
                                          "value":  "Place.Read.Shared"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to manage organization places (conference rooms and room lists) for calendar events and other applications, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write organization places",
                                          "id":  "4c06a06a-098a-4063-868e-5dfee3827264",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to manage organization places (conference rooms and room lists) for calendar events and other applications, on your behalf.",
                                          "userConsentDisplayName":  "Read and write organization places",
                                          "value":  "Place.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, and update the signed-in user?s personal places.",
                                          "adminConsentDisplayName":  "Read and write user places",
                                          "id":  "012ba4a5-ca82-4a76-95ba-6c27f44364c3",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to create, read, and update personal places on your behalf.",
                                          "userConsentDisplayName":  "Read and write your places",
                                          "value":  "Place.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the signed-in user?s personal places.",
                                          "adminConsentDisplayName":  "Read user places",
                                          "id":  "40f6bacc-b201-40da-90a5-09775cc4a863",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your personal places.",
                                          "userConsentDisplayName":  "Read your places",
                                          "value":  "Place.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read, install, upgrade, and uninstall Teams apps, on behalf of the signed-in user. Does not give the ability to read or write application-specific settings.",
                                          "adminConsentDisplayName":  "Manage user\u0027s Teams apps",
                                          "id":  "2a5addc2-4d9e-4d7d-8527-5215aec410f3",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read, install, upgrade, and uninstall Teams apps, on your behalf. Does not give the ability to read or write application-specific settings.",
                                          "userConsentDisplayName":  "Manage your Teams apps",
                                          "value":  "TeamsApp.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the Teams apps that are installed for the signed-in user. Does not give the ability to read application-specific settings.",
                                          "adminConsentDisplayName":  "Read user\u0027s installed Teams apps",
                                          "id":  "daef10fc-047a-48b0-b1a5-da4b5e72fabc",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read the Teams apps that are installed for you. Does not give the ability to read application-specific settings.",
                                          "userConsentDisplayName":  "Read your installed Teams apps",
                                          "value":  "TeamsApp.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read a channel\u0027s messages in Microsoft Teams, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read user channel messages",
                                          "id":  "767156cb-16ae-4d10-8f8b-41b657c8c8c8",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read a channel\u0027s messages in Microsoft Teams, on your behalf.",
                                          "userConsentDisplayName":  "Read your channel messages",
                                          "value":  "ChannelMessage.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to send channel messages in Microsoft Teams, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Send channel messages",
                                          "id":  "ebf0f66e-9fb1-49e4-a278-222f76911cf4",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to send channel messages in Microsoft Teams, on your behalf.",
                                          "userConsentDisplayName":  "Send channel messages",
                                          "value":  "ChannelMessage.Send"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to edit channel messages in Microsoft Teams, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Edit user\u0027s channel messages",
                                          "id":  "2b61aa8a-6d36-4b2f-ac7b-f29867937c53",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to edit channel messages in Microsoft Teams, on your behalf.",
                                          "userConsentDisplayName":  "Edit your channel messages",
                                          "value":  "ChannelMessage.Edit"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to delete channel messages in Microsoft Teams, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Delete user\u0027s channel messages",
                                          "id":  "32ea53ac-4a89-4cde-bac4-727c6fb9ac29",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to delete channel messages in Microsoft Teams, on your behalf.",
                                          "userConsentDisplayName":  "Delete your channel messages",
                                          "value":  "ChannelMessage.Delete"
                                      },
                                      {
                                          "adminConsentDescription":  "Allow the app to read external datasets and content, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read items in external datasets",
                                          "id":  "922f9392-b1b7-483c-a4be-0089be7704fb",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read external datasets and content that you have access to.",
                                          "userConsentDisplayName":  "Read items in external datasets",
                                          "value":  "ExternalItem.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write admin consent requests, business flows, and governance policy templates on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write customer lockbox approval requests",
                                          "id":  "115b3477-4404-4685-a45d-4cf6a6092533",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write customer lockbox requests, business flows and governance policy templates on your behalf.",
                                          "userConsentDisplayName":  "Read and write customer lockbox approval requests",
                                          "value":  "ApprovalRequest.ReadWrite.CustomerLockbox"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write admin consent requests, business flows, and governance policy templates on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write admin consent approval requests",
                                          "id":  "0c940179-817f-401c-9a44-277f3fc38e2b",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write admin consent requests, business flows, and governance policy templates on your behalf.",
                                          "userConsentDisplayName":  "Read and write admin consent approval requests",
                                          "value":  "ApprovalRequest.ReadWrite.AdminConsentRequest"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write entitlement management requests, business flows, and governance policy templates on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write entitlement management approval requests",
                                          "id":  "15dc7bc3-a26c-40b1-8b58-b2a764eb06c1",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write entitlement management requests, business flows, and governance policy templates on your behalf.",
                                          "userConsentDisplayName":  "Read and write entitlement management approval requests",
                                          "value":  "ApprovalRequest.ReadWrite.EntitlementManagement"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write privileged access requests, business flows, and governance policy templates on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write privileged access approval requests",
                                          "id":  "51e5d7dc-745e-4986-aa03-63d64036a7a5",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write privileged access requests, business flows, and governance policy templates on your behalf.",
                                          "userConsentDisplayName":  "Read and write privileged access approval requests",
                                          "value":  "ApprovalRequest.ReadWrite.PriviligedAccess"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read customer lockbox requests, business flows and governance policy templates on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read customer lockbox approval requests",
                                          "id":  "8123bef2-defe-4f3a-8d33-02baa9e6fcfc",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read customer lockbox requests, business flows and governance policy templates on your behalf.",
                                          "userConsentDisplayName":  "Read customer lockbox approval requests",
                                          "value":  "ApprovalRequest.Read.CustomerLockbox"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read admin consent requests, business flows, and governance policy templates on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read admin consent approval requests",
                                          "id":  "fad55eff-94e6-4517-9859-439301f0bad2",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read admin consent requests, business flows, and governance policy templates on your behalf.",
                                          "userConsentDisplayName":  "Read admin consent approval requests",
                                          "value":  "ApprovalRequest.Read.AdminConsentRequest"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read entitlement management requests, business flows, and governance policy templates on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read entitlement management approval requests",
                                          "id":  "95b85e04-9c5c-4554-a3ad-2e933c8a81cd",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read entitlement management requests, business flows, and governance policy templates on your behalf.",
                                          "userConsentDisplayName":  "Read entitlement management approval requests",
                                          "value":  "ApprovalRequest.Read.EntitlementManagement"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read privileged access requests, business flows, and governance policy templates on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read privileged access approval requests",
                                          "id":  "31df746c-3cfa-4b19-b243-36a6fb2b6a66",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read privileged access requests, business flows, and governance policy templates on your behalf.",
                                          "userConsentDisplayName":  "Read privileged access approval requests",
                                          "value":  "ApprovalRequest.Read.PriviligedAccess"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read all the indicators for your organization, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read all threat indicators",
                                          "id":  "9cc427b4-2004-41c5-aa22-757b755e9796",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read all the indicators for your organization, on your behalf.",
                                          "userConsentDisplayName":  "Read all threat indicators",
                                          "value":  "ThreatIndicators.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to request and manage time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD groups, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write privileged access to Azure AD groups",
                                          "id":  "32531c59-1f32-461f-b8df-6f8a3b89f73b",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to request and manage time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD groups, on your behalf.",
                                          "userConsentDisplayName":  "Read and write privileged access to Azure AD groups",
                                          "value":  "PrivilegedAccess.ReadWrite.AzureADGroup"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read time-based assignment and just-in-time elevation of Azure resources (like your subscriptions, resource groups, storage, compute) on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read privileged access to Azure resources",
                                          "id":  "1d89d70c-dcac-4248-b214-903c457af83a",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read time-based assignment and just-in-time elevation of Azure resources (like your subscriptions, resource groups, storage, compute) on your behalf.",
                                          "userConsentDisplayName":  "Read privileged access to your Azure resources",
                                          "value":  "PrivilegedAccess.Read.AzureResources"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD groups, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read privileged access to Azure AD groups",
                                          "id":  "d329c81c-20ad-4772-abf9-3f6fdb7e5988",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD groups, on your behalf.",
                                          "userConsentDisplayName":  "Read privileged access to Azure AD groups",
                                          "value":  "PrivilegedAccess.Read.AzureADGroup"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD built-in and custom administrative roles, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read privileged access to Azure AD",
                                          "id":  "b3a539c9-59cb-4ad5-825a-041ddbdc2bdb",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD built-in and custom administrative roles, on your behalf.",
                                          "userConsentDisplayName":  "Read privileged access to Azure AD",
                                          "value":  "PrivilegedAccess.Read.AzureAD"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to request and manage time-based assignment and just-in-time elevation of user privileges to manage Azure resources (like subscriptions, resource groups, storage, compute) on behalf of the signed-in users.",
                                          "adminConsentDisplayName":  "Read and write privileged access to Azure resources",
                                          "id":  "a84a9652-ffd3-496e-a991-22ba5529156a",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to request and manage time-based assignment and just-in-time elevation of user privileges to manage ?your Azure resources (like your subscriptions, resource groups, storage, compute) on your behalf.",
                                          "userConsentDisplayName":  "Read and write privileged access to Azure resources",
                                          "value":  "PrivilegedAccess.ReadWrite.AzureResources"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create new activities in the user\u0027s teamwork activity feed, and send new activities to other users\u0027 activity feed, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Send a teamwork activity as the user",
                                          "id":  "7ab1d787-bae7-4d5d-8db6-37ea32df9186",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to create new activities in your teamwork activity feed, and send new activities to other users\u0027 activity feed, on your behalf.",
                                          "userConsentDisplayName":  "Send a teamwork activity",
                                          "value":  "TeamsActivity.Send"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the signed-in user\u0027s teamwork activity feed.",
                                          "adminConsentDisplayName":  "Read user\u0027s teamwork activity feed",
                                          "id":  "0e755559-83fb-4b44-91d0-4cc721b9323e",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your teamwork activity feed.",
                                          "userConsentDisplayName":  "Read your teamwork activity feed",
                                          "value":  "TeamsActivity.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and create online meetings on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and create user\u0027s online meetings",
                                          "id":  "a65f2972-a4f8-4f5e-afd7-69ccb046d5dc",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read and create online meetings on your behalf.",
                                          "userConsentDisplayName":  "Read and create your online meetings",
                                          "value":  "OnlineMeetings.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read online meeting details on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read user\u0027s online meetings",
                                          "id":  "9be106e1-f4e3-4df5-bdff-e4bc531cbe43",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read online meeting details on your behalf.",
                                          "userConsentDisplayName":  "Read your online meetings",
                                          "value":  "OnlineMeetings.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to manage permission grants for delegated permissions exposed by any API (including Microsoft Graph), on behalf of the signed in user.",
                                          "adminConsentDisplayName":  "Manage all delegated permission grants",
                                          "id":  "41ce6ca6-6826-4807-84f1-1c82854f7ee5",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to manage permission grants for delegated permissions exposed by any API (including Microsoft Graph), on your behalf. ",
                                          "userConsentDisplayName":  "Manage all delegated permission grants",
                                          "value":  "DelegatedPermissionGrant.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to manage permission grants for application permissions to any API (including Microsoft Graph) and application assignments for any app, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Manage app permission grants and app role assignments",
                                          "id":  "84bccea3-f856-4a8a-967b-dbe0a3d53a64",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to manage permission grants for application permissions to any API (including Microsoft Graph) and application assignments for any app, on your behalf.",
                                          "userConsentDisplayName":  "Manage app permission grants and app role assignments",
                                          "value":  "AppRoleAssignment.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read all organizational contacts on behalf of the signed-in user. ?These contacts are managed by the organization and are different from a user\u0027s personal contacts.",
                                          "adminConsentDisplayName":  "Read organizational contacts",
                                          "id":  "08432d1b-5911-483c-86df-7980af5cdee0",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read all organizational contacts on your behalf.? These contacts are managed by the organization and are different from your personal contacts.",
                                          "userConsentDisplayName":  "Read organizational contacts",
                                          "value":  "OrgContact.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read or write your organization\u0027s user flows, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write all identity user flows",
                                          "id":  "281892cc-4dbf-4e3a-b6cc-b21029bb4e82",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read or write your organization\u0027s user flows, on your behalf.",
                                          "userConsentDisplayName":  "Read and write all identity user flows",
                                          "value":  "IdentityUserFlow.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your organization\u0027s user flows, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read all identity user flows",
                                          "id":  "2903d63d-4611-4d43-99ce-a33f3f52e343",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read your organization\u0027s user flows, on your behalf.",
                                          "userConsentDisplayName":  "Read all identity user flows",
                                          "value":  "IdentityUserFlow.Read.All"
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
                                          "adminConsentDescription":  "Allows the app to have the same access to mailboxes as the signed-in user via Exchange Web Services.",
                                          "adminConsentDisplayName":  "Access mailboxes as the signed-in user via Exchange Web Services",
                                          "id":  "9769c687-087d-48ac-9cb3-c37dde652038",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app full access to your mailboxes on your behalf.",
                                          "userConsentDisplayName":  "Access your mailboxes",
                                          "value":  "EWS.AccessAsUser.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to see and update the data you gave it access to, even when users are not currently using the app. This does not give the app any additional permissions.",
                                          "adminConsentDisplayName":  "Maintain access to data you have given it access to",
                                          "id":  "7427e0e9-2fba-42fe-b0c0-848c9e6a8182",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to see and update the data you gave it access to, even when you are not currently using the app. This does not give the app any additional permissions.",
                                          "userConsentDisplayName":  "Maintain access to data you have given it access to",
                                          "value":  "offline_access"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the signed-in user\u0027s activity statistics, such as how much time the user has spent on emails, in meetings, or in chat sessions.",
                                          "adminConsentDisplayName":  "Read user activity statistics",
                                          "id":  "e03cf23f-8056-446a-8994-7d93dfc8b50e",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your activity statistics, such as how much time you\u0027ve spent on emails, in meetings, or in chat sessions.",
                                          "userConsentDisplayName":  "Read your activity statistics",
                                          "value":  "Analytics.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read identity risky user information for all users in your organization on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read identity risky user information",
                                          "id":  "d04bb851-cb7c-4146-97c7-ca3e71baf56c",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read identity risky user information for all users in your organization on behalf of the signed-in user.",
                                          "userConsentDisplayName":  "Read identity risky user information",
                                          "value":  "IdentityRiskyUser.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the signed-in user\u0027s mailbox.",
                                          "adminConsentDisplayName":  "Read user mail ",
                                          "id":  "570282fd-fa5c-430d-a7fd-fc8dc98a9dca",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read email in your mailbox. ",
                                          "userConsentDisplayName":  "Read your mail ",
                                          "value":  "Mail.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and update identity risky user information for all users in your organization on behalf of the signed-in user.?Update operations include dismissing risky users.",
                                          "adminConsentDisplayName":  "Read and write risky user information",
                                          "id":  "e0a7cdbb-08b0-4697-8264-0069786e9674",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and update identity risky user information for all users in your organization on your behalf.?Update operations include dismissing risky users.",
                                          "userConsentDisplayName":  "Read and write identity risky user information",
                                          "value":  "IdentityRiskyUser.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and update identity risk event information for all users in your organization on behalf of the signed-in user.?Update operations include confirming risk event detections.?",
                                          "adminConsentDisplayName":  "Read and write risk event information",
                                          "id":  "9e4862a5-b68f-479e-848a-4e07e25c9916",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and update identity risk event information for all users in your organization on your behalf.?Update operations include confirming risk event detections.?",
                                          "userConsentDisplayName":  "Read and write risk event information",
                                          "value":  "IdentityRiskEvent.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write trust framework key set properties on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write trust framework key sets",
                                          "id":  "39244520-1e7d-4b4a-aee0-57c65826e427",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read or write trust framework key sets, on your behalf.",
                                          "userConsentDisplayName":  "Read and write trust framework key sets",
                                          "value":  "TrustFrameworkKeySet.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read trust framework key set properties on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read trust framework key sets",
                                          "id":  "7ad34336-f5b1-44ce-8682-31d7dfcd9ab9",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read trust framework key sets, on your behalf.",
                                          "userConsentDisplayName":  "Read trust framework key sets",
                                          "value":  "TrustFrameworkKeySet.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write your organization\u0027s trust framework policies on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write your organization\u0027s trust framework policies",
                                          "id":  "cefba324-1a70-4a6e-9c1d-fd670b7ae392",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write your organization\u0027s trust framework policies on your behalf.",
                                          "userConsentDisplayName":  "Read and write trust framework policies",
                                          "value":  "Policy.ReadWrite.TrustFramework"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read and write 1 on 1 or group chats threads, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write user chat messages",
                                          "id":  "9ff7295e-131b-4d94-90e1-69fde507ac11",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows an app to read and write your 1 on 1 or group chat messages in Microsoft Teams, on your behalf.",
                                          "userConsentDisplayName":  "Read and write your chat messages",
                                          "value":  "Chat.ReadWrite"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read 1 on 1 or group chats threads, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read user chat messages",
                                          "id":  "f501c180-9344-439a-bca0-6cbf209fd270",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows an app to read your 1 on 1 or group chat messages in Microsoft Teams, on your behalf.",
                                          "userConsentDisplayName":  "Read your chat messages",
                                          "value":  "Chat.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read security actions, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read your organization\u0027s security actions",
                                          "id":  "1638cddf-07a4-4de2-8645-69c96cacad73",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read security actions, on your behalf.",
                                          "userConsentDisplayName":  "Read your organization\u0027s security actions",
                                          "value":  "SecurityActions.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read or update security actions, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and update your organization\u0027s security actions",
                                          "id":  "dc38509c-b87d-4da0-bd92-6bec988bac4a",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and update security actions, on your behalf.",
                                          "userConsentDisplayName":  "Read and update your organization\u0027s security actions",
                                          "value":  "SecurityActions.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create threat indicators, and fully manage those threat indicators (read, update and delete), on behalf of the signed-in user. ?It cannot update any threat indicators it does not own.",
                                          "adminConsentDisplayName":  "Manage threat indicators this app creates or owns",
                                          "id":  "91e7d36d-022a-490f-a748-f8e011357b42",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to create threat indicators, and fully manage those threat indicators (read, update and delete), on your behalf. ?It cannot update any threat indicators that it is not an owner of.",
                                          "userConsentDisplayName":  "Manage threat indicators this app creates or owns",
                                          "value":  "ThreatIndicators.ReadWrite.OwnedBy"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your family information, members and their basic profile.",
                                          "adminConsentDisplayName":  "Read your family info",
                                          "id":  "3a1e4806-a744-4c70-80fc-223bf8582c46",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read your family information, members and their basic profile.",
                                          "userConsentDisplayName":  "Read your family info",
                                          "value":  "Family.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to create, read, update, and delete administrative units and manage administrative unit membership on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write administrative units",
                                          "id":  "7b8a2d34-6b3f-4542-a343-54651608ad81",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to create, read, update, and delete administrative units and manage administrative unit membership on your behalf.",
                                          "userConsentDisplayName":  "Read and write administrative units",
                                          "value":  "AdministrativeUnit.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read administrative units and administrative unit membership on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read administrative units",
                                          "id":  "3361d15d-be43-4de6-b441-3c746d05163d",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read administrative units and administrative unit membership on your behalf.",
                                          "userConsentDisplayName":  "Read administrative units",
                                          "value":  "AdministrativeUnit.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows an app to read information protection sensitivity labels and label policy settings, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read user sensitivity labels and label policies.",
                                          "id":  "4ad84827-5578-4e18-ad7a-86530b12f884",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows an app to read information protection sensitivity labels and label policy settings, on behalf of the signed-in user.",
                                          "userConsentDisplayName":  "Read user sensitivity labels and label policies.",
                                          "value":  "InformationProtectionPolicy.Read"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to manage hybrid identity service configuration by creating, viewing, updating and deleting on-premises published resources, on-premises agents and agent groups, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Manage on-premises published resources",
                                          "id":  "8c4d5184-71c2-4bf8-bb9d-bc3378c9ad42",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to manage hybrid identity service configuration by creating, viewing, updating and deleting on-premises published resources, on-premises agents and agent groups, on your behalf.",
                                          "userConsentDisplayName":  "Manage on-premises published resources",
                                          "value":  "OnPremisesPublishingProfiles.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read, update, delete and perform actions on access reviews, reviewers, decisions and settings for group and app memberships that the signed-in user has access to in the organization.",
                                          "adminConsentDisplayName":  "Manage access reviews for group and app memberships",
                                          "id":  "5af8c3f5-baca-439a-97b0-ea58a435e269",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read, update and perform action on access reviews, reviewers, decisions and settings that you have access to.",
                                          "userConsentDisplayName":  "Manage access reviews for group and app memberships",
                                          "value":  "AccessReview.ReadWrite.Membership"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read workforce integrations, to synchronize data from Microsoft Teams Shifts, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read workforce integrations",
                                          "id":  "f1ccd5a7-6383-466a-8db8-1a656f7d06fa",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read workforce integrations, to synchronize data from Microsoft Teams Shifts, on your behalf.",
                                          "userConsentDisplayName":  "Read workforce integrations",
                                          "value":  "WorkforceIntegration.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to manage workforce integrations, to synchronize data from Microsoft Teams Shifts, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read and write workforce integrations",
                                          "id":  "08c4b377-0d23-4a8b-be2a-23c1c1d88545",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to manage workforce integrations, to synchronize data from Microsoft Teams Shifts, on your behalf.",
                                          "userConsentDisplayName":  "Read and write workforce integrations",
                                          "value":  "WorkforceIntegration.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read your company\u0027s places (conference rooms and room lists) for calendar events and other applications, on behalf of the signed-in user.",
                                          "adminConsentDisplayName":  "Read all company places",
                                          "id":  "cb8f45a0-5c2e-4ea1-b803-84b870a7d7ec",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read your company\u0027s places (conference rooms and room lists) for calendar events and other applications, on your behalf.",
                                          "userConsentDisplayName":  "Read all company places",
                                          "value":  "Place.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the organization and related resources, on behalf of the signed-in user.?Related resources include things like subscribed skus and tenant branding information.",
                                          "adminConsentDisplayName":  "Read organization information",
                                          "id":  "4908d5b9-3fb2-4b1e-9336-1888b7937185",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read the organization and related resources, on your behalf.?Related resources include things like subscribed skus and tenant branding information.",
                                          "userConsentDisplayName":  "Read organization information",
                                          "value":  "Organization.Read.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write the organization and related resources, on behalf of the signed-in user.?Related resources include things like subscribed skus and tenant branding information.",
                                          "adminConsentDisplayName":  "Read and write organization information",
                                          "id":  "46ca0847-7e6b-426e-9775-ea810a948356",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write the organization and related resources, on your behalf.?Related resources include things like subscribed skus and tenant branding information.",
                                          "userConsentDisplayName":  "Read and write organization information",
                                          "value":  "Organization.ReadWrite.All"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read the role-based access control (RBAC) settings for your company\u0027s directory, on behalf of the signed-in user.  This includes reading directory role templates, directory roles and memberships.",
                                          "adminConsentDisplayName":  "Read directory RBAC settings",
                                          "id":  "741c54c3-0c1e-44a1-818b-3f97ab4e8c83",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read the role-based access control (RBAC) settings for your company\u0027s directory, on your behalf.  This includes reading directory role templates, directory roles and memberships.",
                                          "userConsentDisplayName":  "Read directory RBAC settings",
                                          "value":  "RoleManagement.Read.Directory"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and manage the role-based access control (RBAC) settings for your company\u0027s directory, on behalf of the signed-in user. This includes instantiating directory roles and managing directory role membership, and reading directory role templates, directory roles and memberships.",
                                          "adminConsentDisplayName":  "Read and write directory RBAC settings",
                                          "id":  "d01b97e9-cbc0-49fe-810a-750afd5527a3",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and manage the role-based access control (RBAC) settings for your company\u0027s directory, on your behalf. This includes instantiating directory roles and managing directory role membership, and reading directory role templates, directory roles and memberships.",
                                          "userConsentDisplayName":  "Read and write directory RBAC settings",
                                          "value":  "RoleManagement.ReadWrite.Directory"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read and write your organization\u0027s feature rollout policies on behalf of the signed-in user. Includes abilities to assign and remove users and groups to rollout of a specific feature.",
                                          "adminConsentDisplayName":  "Read and write your organization\u0027s feature rollout policies",
                                          "id":  "92a38652-f13b-4875-bc77-6e1dbb63e1b2",
                                          "isEnabled":  true,
                                          "type":  "Admin",
                                          "userConsentDescription":  "Allows the app to read and write your organization\u0027s feature rollout policies on your behalf. Includes abilities to assign and remove users and groups to rollout of a specific feature.",
                                          "userConsentDisplayName":  "Read and write your organization\u0027s feature rollout policies",
                                          "value":  "Policy.ReadWrite.FeatureRollout"
                                      },
                                      {
                                          "adminConsentDescription":  "Allows the app to read email in the signed-in user\u0027s mailbox except body, previewBody, attachments and any extended properties.",
                                          "adminConsentDisplayName":  "Read user basic mail",
                                          "id":  "a4b8392a-d8d1-4954-a029-8e668a39a170",
                                          "isEnabled":  true,
                                          "type":  "User",
                                          "userConsentDescription":  "Allows the app to read email in the signed-in user\u0027s mailbox except body, previewBody, attachments and any extended properties.",
                                          "userConsentDisplayName":  "Read user basic mail",
                                          "value":  "Mail.ReadBasic"
                                      }
                                  ],
    "preferredSingleSignOnMode":  null,
    "preferredTokenSigningKeyEndDateTime":  null,
    "preferredTokenSigningKeyThumbprint":  null,
    "publisherName":  "Microsoft Services",
    "replyUrls":  [

                  ],
    "samlMetadataUrl":  null,
    "samlSingleSignOnSettings":  null,
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
    "api":  {
                "resourceSpecificApplicationPermissions":  [

                                                           ]
            },
    "appRoles":  [
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows an app to read basic BitLocker key properties for all devices, without a signed-in user. Does not allow read of the recovery key.",
                         "displayName":  "Read all BitLocker keys basic information",
                         "id":  "f690d423-6b29-4d04-98c6-694c42282419",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "BitlockerKey.ReadBasic.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows an app to read BitLocker keys for all devices, without a signed-in user. Allows read of the recovery key.",
                         "displayName":  "Read all BitLocker keys",
                         "id":  "57f1cf28-c0c4-4ec3-9a30-19a2eaaf2f6e",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "BitlockerKey.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all applications and service principals without a signed-in user.",
                         "displayName":  "Read all applications",
                         "id":  "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Application.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to send, read, update and delete user?s notifications, without a signed-in user.",
                         "displayName":  "Deliver and manage all user\u0027s notifications",
                         "id":  "4e774092-a092-48d1-90bd-baad67c7eb47",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "UserNotification.ReadWrite.CreatedByApp"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read, install, upgrade, and uninstall Teams apps for any user, without a signed-in user. Does not give the ability to read or write application-specific settings.",
                         "displayName":  "Manage all users\u0027 Teams apps",
                         "id":  "eb6b3d76-ed75-4be6-ac36-158d04c0a555",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "TeamsApp.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the Teams apps that are installed for any user, without a signed-in user. Does not give the ability to read application-specific settings.",
                         "displayName":  "Read all users\u0027 installed Teams apps",
                         "id":  "afdb422a-4b2a-4e07-a708-8ceed48196bf",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "TeamsApp.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write customer lockbox requests, business flows, and governance policy templates without a signed-in user.",
                         "displayName":  "Read and write all customer lockbox approval requests",
                         "id":  "5f411d27-abad-4dc3-83c6-b84a46ffa434",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ApprovalRequest.ReadWrite.CustomerLockbox"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write admin consent requests, business flows, and governance policy templates without a signed-in user.",
                         "displayName":  "Read and write all admin consent approval requests",
                         "id":  "afe5c674-a576-4b80-818c-e3d7f6afd299",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ApprovalRequest.ReadWrite.AdminConsentRequest"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write entitlement management requests, business flows, and governance policy templates without a signed-in user.",
                         "displayName":  "Read and write all entitlement management approval requests",
                         "id":  "fbfdecc9-4b78-4882-bb98-7decbddcbddf",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ApprovalRequest.ReadWrite.EntitlementManagement"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write privileged access requests, business flows, and governance policy templates without a signed-in user.",
                         "displayName":  "Read and write all privileged access approval requests",
                         "id":  "60182ac6-4565-4baa-8b04-9350fe8dbfca",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ApprovalRequest.ReadWrite.PriviligedAccess"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read customer lockbox requests, business flows, and governance policy templates without a signed-in user.",
                         "displayName":  "Read all customer lockbox approval requests",
                         "id":  "080ce695-a830-4d5c-a45a-375e3ab11b11",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ApprovalRequest.Read.CustomerLockbox"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read admin consent requests, business flows, and governance policy templates without a signed-in user.",
                         "displayName":  "Read all admin consent approval requests",
                         "id":  "0d9d2e88-e2eb-4ac7-9b1d-9b68ed9f9f4f",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ApprovalRequest.Read.AdminConsentRequest"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read entitlement management requests, business flows, and governance policy templates without a signed-in user.",
                         "displayName":  "Read all entitlement management approval requests",
                         "id":  "b2a3adf0-5774-4846-986c-a91c705b0141",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ApprovalRequest.Read.EntitlementManagement"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read privileged access requests, business flows, and governance policy templates without a signed-in user.",
                         "displayName":  "Read all privileged access approval requests",
                         "id":  "3f410ed8-2d83-4435-b2c4-c776f44e4ae1",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ApprovalRequest.Read.PriviligedAccess"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to access only the selected groups it has been granted access to, without a signed-in user. The app will have access to basic properties of the group (name, email address and description). The level of access to the selected groups can range from read access to basic group member properties, to read and write access to all content within the group, such as files, events and notes.",
                         "displayName":  "Access selected groups",
                         "id":  "5ef47bde-23a3-4cfb-be03-6ab63044aec6",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Group.Selected"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all the indicators for your organization, without a signed-in user.",
                         "displayName":  "Read all threat indicators",
                         "id":  "197ee4e9-b993-4066-898f-d6aecc55125b",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ThreatIndicators.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to request and manage time-based assignment and just-in-time elevation of Azure resources (like your subscriptions, resource groups, storage, compute) in your organization, without a signed-in user.",
                         "displayName":  "Read and write privileged access to Azure resources",
                         "id":  "6f9d5abc-2db6-400b-a267-7de22a40fb87",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "PrivilegedAccess.ReadWrite.AzureResources"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to request and manage time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD groups in your organization, without a signed-in user.",
                         "displayName":  "Read and write privileged access to Azure AD groups",
                         "id":  "2f6817f8-7b12-4f0f-bc18-eeaf60705a9e",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "PrivilegedAccess.ReadWrite.AzureADGroup"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to request and manage time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD built-in and custom administrative roles in your organization, without a signed-in user.",
                         "displayName":  "Read and write privileged access to Azure AD roles",
                         "id":  "854d9ab1-6657-4ec8-be45-823027bcd009",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "PrivilegedAccess.ReadWrite.AzureAD"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read time-based assignment and just-in-time elevation of user privileges to audit Azure resources in your organization, without a signed-in user.",
                         "displayName":  "Read privileged access to Azure resources",
                         "id":  "5df6fe86-1be0-44eb-b916-7bd443a71236",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "PrivilegedAccess.Read.AzureResources"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD groups in your organization, without a signed-in user.",
                         "displayName":  "Read privileged access to Azure AD groups",
                         "id":  "01e37dc9-c035-40bd-b438-b2879c4870a6",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "PrivilegedAccess.Read.AzureADGroup"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read time-based assignment and just-in-time elevation (including scheduled elevation) of Azure AD built-in and custom administrative roles in your organization, without a signed-in user.",
                         "displayName":  "Read privileged access to Azure AD roles",
                         "id":  "4cdc2547-9148-4295-8d11-be0db1391d6b",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "PrivilegedAccess.Read.AzureAD"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to send new activities to any users\u0027 teamwork activity feed, without a signed-in user.",
                         "displayName":  "Send a teamwork activity to any user",
                         "id":  "a267235f-af13-44dc-8385-c1dc93023186",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "TeamsActivity.Send"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all users\u0027 teamwork activity feed, without a signed-in user.",
                         "displayName":  "Read all users\u0027 teamwork activity feed",
                         "id":  "70dec828-f620-4914-aa83-a29117306807",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "TeamsActivity.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to manage permission grants for delegated permissions exposed by any API (including Microsoft Graph), without a signed-in user.",
                         "displayName":  "Manage all delegated permission grants",
                         "id":  "8e8e4742-1d95-4f68-9d56-6ee75648c72a",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DelegatedPermissionGrant.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to manage permission grants for application permissions to any API (including Microsoft Graph) and application assignments for any app, without a signed-in user.",
                         "displayName":  "Manage app permission grants and app role assignments",
                         "id":  "06b708a9-e830-4db3-a914-8e69da51d44f",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "AppRoleAssignment.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write Microsoft Intune service properties including device enrollment and third party service connection configuration, without a signed-in user.",
                         "displayName":  "Read and write Microsoft Intune configuration",
                         "id":  "5ac13192-7ace-4fcf-b828-1a26f28068ee",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementServiceConfig.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write the properties relating to the Microsoft Intune Role-Based Access Control (RBAC) settings, without a signed-in user.",
                         "displayName":  "Read and write Microsoft Intune RBAC settings",
                         "id":  "e330c4f0-4170-414e-a55a-2f022ec2b57b",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementRBAC.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write the properties of devices managed by Microsoft Intune, without a signed-in user. Does not allow high impact operations such as remote wipe and password reset on the device?s owner",
                         "displayName":  "Read and write Microsoft Intune devices",
                         "id":  "243333ab-4d21-40cb-a475-36241daa0842",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementManagedDevices.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to perform remote high impact actions such as wiping the device or resetting the passcode on devices managed by Microsoft Intune, without a signed-in user.",
                         "displayName":  "Perform user-impacting remote actions on Microsoft Intune devices",
                         "id":  "5b07b0dd-2377-4e44-a38d-703f09a0dc3c",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementManagedDevices.PrivilegedOperations.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write properties of Microsoft Intune-managed device configuration and device compliance policies and their assignment to groups, without a signed-in user.",
                         "displayName":  "Read and write Microsoft Intune device configuration and policies",
                         "id":  "9241abd9-d0e6-425a-bd4f-47ba86e767a4",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementConfiguration.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write the properties, group assignments and status of apps, app configurations and app protection policies managed by Microsoft Intune, without a signed-in user.",
                         "displayName":  "Read and write Microsoft Intune apps",
                         "id":  "78145de6-330d-4800-a6ce-494ff2d33d07",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementApps.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all organizational contacts without a signed-in user.  These contacts are managed by the organization and are different from a user\u0027s personal contacts.",
                         "displayName":  "Read organizational contacts",
                         "id":  "e1a88a34-94c4-4418-be12-c87b00e26bea",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "OrgContact.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to place outbound calls to a single user and transfer calls to users in your organization?s directory, without a signed-in user.",
                         "displayName":  "Initiate outgoing 1 to 1 calls from the app",
                         "id":  "284383ee-7f6e-4e40-a2a8-e85dcb029101",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.Initiate.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to place outbound calls to multiple users and add participants to meetings in your organization, without a signed-in user.",
                         "displayName":  "Initiate outgoing group calls from the app",
                         "id":  "4c277553-8a09-487b-8023-29ee378d8324",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.InitiateGroupCall.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to join group calls and scheduled meetings in your organization, without a signed-in user. ?The app will be joined with the privileges of a directory user to meetings in your organization.",
                         "displayName":  "Join group calls and meetings as an app",
                         "id":  "f6b49018-60ab-4f81-83bd-22caeabfed2d",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.JoinGroupCall.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to anonymously join group calls and scheduled meetings in your organization, without a signed-in user. ?The app will be joined as a guest to meetings in your organization.",
                         "displayName":  "Join group calls and meetings as a guest",
                         "id":  "fd7ccf6b-3d28-418b-9701-cd10f5cd2fd4",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.JoinGroupCallAsGuest.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to get direct access to media streams in a call, without a signed-in user.",
                         "displayName":  "Access media streams in a call as an app",
                         "id":  "a7a681dc-756e-4909-b988-f160edc6655f",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Calls.AccessMedia.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read online meeting details in your organization, without a signed-in user.",
                         "displayName":  "Read online meeting details",
                         "id":  "c1684f21-1984-47fa-9d61-2dc8c296bb70",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "OnlineMeetings.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and create online meetings as an application in your organization.",
                         "displayName":  "Read and create online meetings",
                         "id":  "b8bb2037-6e08-44ac-a4ea-4674e010e2a4",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "OnlineMeetings.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read or write your organization\u0027s user flows, without a signed-in user.",
                         "displayName":  "Read and write all identity user flows",
                         "id":  "65319a09-a2be-469d-8782-f6b07debf789",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "IdentityUserFlow.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read your organization\u0027s user flows, without a signed-in user.",
                         "displayName":  "Read all identity user flows",
                         "id":  "1b0c317f-dd31-4305-9932-259a8b6e8099",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "IdentityUserFlow.Read.All"
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
                         "description":  "Allows the app to export data (e.g. customer content or system-generated logs), associated with any user in your company, when the app is used by a privileged user (e.g. a Company Administrator).",
                         "displayName":  "Export user\u0027s data",
                         "id":  "405a51b5-8d8d-430b-9842-8be4b0e9f324",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "User.Export.All"
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
                         "description":  "Allows the app to read the identity risky user information for your organization without a signed in user.",
                         "displayName":  "Read all identity risky user information",
                         "id":  "dc5007c0-2d7d-4c42-879c-2dab87571379",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "IdentityRiskyUser.Read.All"
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
                         "description":  "Allows the app to read and update identity risky user information for your organization without a signed-in user. ?Update operations include dismissing risky users.",
                         "displayName":  "Read and write all risky user information",
                         "id":  "656f6061-f9fe-4807-9708-6a2e0934df76",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "IdentityRiskyUser.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and update identity risk detection information for your organization without a signed-in user. Update operations include confirming risk event detections.?",
                         "displayName":  "Read and write all risk detection information",
                         "id":  "db06fb33-1953-4b7b-a2ac-f1e2c854f7ae",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "IdentityRiskEvent.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows an app to read and write all chat messages in Microsoft Teams, without a signed-in user.",
                         "displayName":  "Read and write all chat messages",
                         "id":  "294ce7c9-31ba-490a-ad7d-97a7d075e4ed",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Chat.ReadWrite.All"
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
                         "description":  "Allows the app to read security actions, without a signed-in user.",
                         "displayName":  "Read your organization\u0027s security actions",
                         "id":  "5e0edab9-c148-49d0-b423-ac253e121825",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "SecurityActions.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read or update security actions, without a signed-in user.",
                         "displayName":  "Read and update your organization\u0027s security actions",
                         "id":  "f2bf083f-0179-402a-bedb-b2784de8a49b",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "SecurityActions.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create threat indicators, and fully manage those threat indicators (read, update and delete), without a signed-in user. ?It cannot update any threat indicators it does not own.",
                         "displayName":  "Manage threat indicators this app creates or owns",
                         "id":  "21792b6c-c986-4ffc-85de-df9da54b52fa",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ThreatIndicators.ReadWrite.OwnedBy"
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
                         "description":  "Allows an app to read published sensitivity labels and label policy settings for the entire organization or a specific user, without a signed in user.",
                         "displayName":  "Read all published labels and label policies for an organization.",
                         "id":  "19da66cb-0fb0-4390-b071-ebc76a349482",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "InformationProtectionPolicy.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read administrative units and administrative unit membership without a signed-in user.",
                         "displayName":  "Read all administrative units",
                         "id":  "134fd756-38ce-4afd-ba33-e9623dbe66c2",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "AdministrativeUnit.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create, read, update, and delete administrative units and manage administrative unit membership without a signed-in user.",
                         "displayName":  "Read and write all administrative units",
                         "id":  "5eb59dd3-1da2-4329-8733-9dabdc435916",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "AdministrativeUnit.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read your organization?s identity (authentication) providers? properties without a signed in user.",
                         "displayName":  "Read identity providers",
                         "id":  "e321f0bb-e7f7-481e-bb28-e3b0b32d4bd0",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "IdentityProvider.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write your organization?s identity (authentication) providers? properties without a signed in user.",
                         "displayName":  "Read and write identity providers",
                         "id":  "90db2b9a-d928-4d33-a4dd-8442ae3d41e4",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "IdentityProvider.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read all your organization\u0027s policies without a signed in user.",
                         "displayName":  "Read your organization\u0027s policies",
                         "id":  "246dd0d5-5bd0-4def-940b-0421030a5b68",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Policy.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write your organization\u0027s trust framework policies without a signed in user.",
                         "displayName":  "Read and write your organization\u0027s trust framework policies",
                         "id":  "79a677f7-b79d-40d0-a36a-3e6f8688dd7a",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Policy.ReadWrite.TrustFramework"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read trust framework key set properties without a signed-in user.",
                         "displayName":  "Read trust framework key sets",
                         "id":  "fff194f1-7dce-4428-8301-1badb5518201",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "TrustFrameworkKeySet.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write trust framework key set properties without a signed-in user.",
                         "displayName":  "Read and write trust framework key sets",
                         "id":  "4a771c9a-1cf2-4609-b88e-3d3e02d539cd",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "TrustFrameworkKeySet.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to create, view, update and delete on-premises published resources, on-premises agents and agent groups, as part of a hybrid identity configuration, without a signed in user.",
                         "displayName":  "Manage on-premises published resources",
                         "id":  "0b57845e-aa49-4e6f-8109-ce654fffa618",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "OnPremisesPublishingProfiles.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read Microsoft Intune service properties including device enrollment and third party service connection configuration, without a signed-in user.",
                         "displayName":  "Read Microsoft Intune configuration",
                         "id":  "06a5fe6d-c49d-46a7-b082-56b1b14103c7",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementServiceConfig.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the properties relating to the Microsoft Intune Role-Based Access Control (RBAC) settings, without a signed-in user.",
                         "displayName":  "Read Microsoft Intune RBAC settings",
                         "id":  "58ca0d9a-1575-47e1-a3cb-007ef2e4583b",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementRBAC.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the properties of devices managed by Microsoft Intune, without a signed-in user.",
                         "displayName":  "Read Microsoft Intune devices",
                         "id":  "2f51be20-0bb4-4fed-bf7b-db946066c75e",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementManagedDevices.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the properties, group assignments and status of apps, app configurations and app protection policies managed by Microsoft Intune, without a signed-in user.",
                         "displayName":  "Read Microsoft Intune apps",
                         "id":  "7a6ee1e7-141e-4cec-ae74-d9db155731ff",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementApps.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read properties of Microsoft Intune-managed device configuration and device compliance policies and their assignment to groups, without a signed-in user.",
                         "displayName":  "Read Microsoft Intune device configuration and policies",
                         "id":  "dc377aa6-52d8-4e23-b271-2a7ae04cedf3",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "DeviceManagementConfiguration.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read, update, delete and perform actions on access reviews, reviewers, decisions and settings in the organization for group and app memberships, without a signed-in user.",
                         "displayName":  "Manage access reviews for group and app memberships",
                         "id":  "18228521-a591-40f1-b215-5fad4488c117",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "AccessReview.ReadWrite.Membership"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allow the app to read or write items in all external datasets that the app is authorized to access",
                         "displayName":  "Read and write items in external datasets",
                         "id":  "38c3d6ee-69ee-422f-b954-e17819665354",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "ExternalItem.ReadWrite.All"
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
                         "description":  "Allows the app to read company places (conference rooms and room lists) for calendar events and other applications, without a signed-in user.",
                         "displayName":  "Read all company places",
                         "id":  "913b9306-0ce1-42b8-9137-6a7df690a760",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Place.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the organization and related resources, without a signed-in user.?Related resources include things like subscribed skus and tenant branding information.",
                         "displayName":  "Read organization information",
                         "id":  "498476ce-e0fe-48b0-b801-37ba7e2685c6",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Organization.Read.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and write the organization and related resources, without a signed-in user.?Related resources include things like subscribed skus and tenant branding information.",
                         "displayName":  "Read and write organization information",
                         "id":  "292d869f-3427-49a8-9dab-8c70152b74e9",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Organization.ReadWrite.All"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read the role-based access control (RBAC) settings for your company\u0027s directory, without a signed-in user.  This includes reading directory role templates, directory roles and memberships.",
                         "displayName":  "Read all directory RBAC settings",
                         "id":  "483bed4a-2ad3-4361-a73b-c83ccdbdc53c",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "RoleManagement.Read.Directory"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read and manage the role-based access control (RBAC) settings for your company\u0027s directory, without a signed-in user. This includes instantiating directory roles and managing directory role membership, and reading directory role templates, directory roles and memberships.",
                         "displayName":  "Read and write all directory RBAC settings",
                         "id":  "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "RoleManagement.ReadWrite.Directory"
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
                         "description":  "Allows the app to read and write feature rollout policies without a signed-in user. Includes abilities to assign and remove users and groups to rollout of a specific feature.",
                         "displayName":  "Read and write feature rollout policies",
                         "id":  "2044e4f1-e56c-435b-925c-44cd8f6ba89a",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Policy.ReadWrite.FeatureRollout"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read basic mail properties in all mailboxes without a signed-in user. Includes all properties except body, previewBody, attachments and any extended properties.",
                         "displayName":  "Read basic mail in all mailboxes",
                         "id":  "6be147d2-ea4f-4b5a-a3fa-3eab6f3c140a",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Mail.ReadBasic"
                     },
                     {
                         "allowedMemberTypes":  [
                                                    "Application"
                                                ],
                         "description":  "Allows the app to read basic mail properties in all mailboxes without a signed-in user. Includes all properties except body, previewBody, attachments and any extended properties.",
                         "displayName":  "Read basic mail in all mailboxes",
                         "id":  "693c5e45-0940-467d-9b8a-1022fb9d42ef",
                         "isEnabled":  true,
                         "origin":  "Application",
                         "value":  "Mail.ReadBasic.All"
                     }
                 ],
    "keyCredentials":  [

                       ],
    "passwordCredentials":  [

                            ]
}
'@ | ConvertFrom-JSON
