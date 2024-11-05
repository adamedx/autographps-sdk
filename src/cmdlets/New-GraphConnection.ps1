# Copyright 2021, Adam Edwards
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

. (import-script ../graphservice/GraphEndpoint)
. (import-script ../client/GraphIdentity)
. (import-script ../common/GraphApplicationCertificate)
. (import-script ../client/GraphConnection)
. (import-script common/DynamicParamHelper)
. (import-script ../common/ScopeHelper)
. (import-script common/PermissionParameterCompleter)

<#
.SYNOPSIS
Creates a Graph GraphConnection object that controls where, with what Azure Active Directory identity, and with what behaviors commands issue Graph API requests.

.DESCRIPTION
New-GraphConnection creates a GraphConnection object that encapsulates the Graph API endpoints used to make requests, as well as characteristics of the Azure Active Directory (AAD) application identity used to issue requests against the API. The resulting object may also contain information about request behaviors such as eventual consistency which can enable advanced queries at the expense of certain semantic tradeoffs. You can use this command to specify an alternative identity and endpoints in place of those specified by the "current" connection that commands used by default. The current connection itself can be updated to a connection returned by New-GraphConnection, and many commands include a 'Connection' parameter that may be used to issue API requests using the alternative connection without changing the current connection.

With the exception of the ConsistencyLevel parameter, the functionality of New-GraphConnection is not influenced by profile settings.

For the most common interactive cases, the Connect-GraphApi command is sufficient for enabling access to the Graph API; the New-GraphConnection enables more advanced connection management and automation scenarios.

There are three ways to create connections (which may then be used to access the Graph API after a successful sign-in):

* Connect-GraphApi: This command can create new connection and also sign-in to the new connection or an existing one
* New-GraphConnection: This command creates new connections, including named connections (see further discussion in this documentation), but does not perform a sign-in. This can be used in an ad-hoc way when you need to use multiple connections for your PowerShell session for instance without having to sign in each time you switch back and forth.
* Profile settings: The profile settings file that is processed at startup can create named connections just like New-GraphConnection -- this is useful for removing the need to manually create the reusable named connections. For details on the format and usage of the settings file, see the documentation at https://github.com/adamedx/autographps-sdk/tree/main/docs/settings.

As mentioned above, New-GraphConnection creates a new object and returns it as output, and has no side effects, i.e. it does not perform any authentication / sign-in operations or change local state such as the current connection. This makes it useful for automating the management of connections and providing a way to maintain multiple credentials with different levels of access to the Graph API, different AAD organizations, or even issue requests to Graph API endpoints from more than one cloud.

To sign in to a connection created by New-GraphConnection so that it may be used to access the Graph API, issue the Connect-GraphApi command to invoke an explicit sign-in, or specify the connection as a parameter to a command that provides a Connection parameter; such commands will implictly perform the sign-in if the supplied connection is not already signed-in.

By default, this module uses a connection that signs in with a specific 'AutoGraphPS' multi-tenant application with identifier ac70e3e2-a821-4d19-839c-b8af4515254b that is registered as a native public client application -- it requires only your user credentials for sign-in, no application secret is required or accepted. When using New-GraphConnection, you can specify the AppId parameter to provide an application identifier of your choice to override the default application.

When you specify your own AAD application's identifier for the AppId parameter, New-GraphConnection supports the use of client secrets in order to sign in with an AAD application identity that requires a pre-configured client secret (as opposed to one that only requires the current credentials of a user). For such applications, you must supply New-GraphConnection with the client secret in order to sign in; New-GraphConnection provides the following mechanisms to allow you to do that -- these mechanisms and parameters are also applicable to the Connect-GraphApi command:

    * You MUST supply a client secret whenever you specify the Confidential or NoninteractiveAppOnlyAuth parameters
    * On Windows only, if the required secret for the application specified by the AppId parameter is a certificate created by the New-GraphApplication, New-GraphCertificate, or New-GraphLocalCertificate commands and that certificate is present in the Windows certificate store, New-GraphConnection will automatically find the certificate for you -- you do not need to specify any additional parameters for New-GraphConnection to bind to the certificate you need to authenticate as the application. For more information about the certificate lookup functionality, see the documentation for Find-GraphLocalCertificate.
    * Alternatively, on all platforms you can always explicitly specify the certificate or the location of the certificate through the Certificate and CertificatePath parameters. In particular the CertificatePath parameter supports both file system paths (especially useful for non-Windows systems where certificates are typically stored as files) and Windows certificate store paths (e.g. cert:/currentuser/my/3EADBAB88E2FEC2851030338D00A2DC17A322732), so as long as the certificate exists on the local system, there is a way for you to supply it to New-GraphConnection
    * Instead of using a certificate, a symmetric key may be specified as the application credential. Use the Secret and Password parameters to specify a symmetric key as a [System.Security.SecureString] object. For example, the Get-Credential command allows you to interactively supply a symmetric key in the form of a password and returns an object that can render a [SecureString] object. You may also use other PowerShell commands and scripts or other system software to securely retrieve the symmetric key as a [SecureString]. Note that symmetric keys are much less robust as a security mechanism than certificates, so your use of them should be limited to non-production environments for testing or other scenarios where a disclosure of the key is not critical.

.PARAMETER Permissions
Specifies that the connection created by New-GraphConnection requires certain delegated permissions when it is used to sign-in interactively for accesss to the Graph API. By default when this parameter is not specified, commands that request access will not ask for permissions beyond those that have already been delegated to the connection's AAD application identity for the user who signs in. If these permissions are not sufficient for successful access to the particular APIs you intend to access using this module's commands through this connection, specify the Permissions parameter to request the additional required permissions at sign-in.

.PARAMETER AppId
The AAD application identifier to be used by the connection. If the AppId parameter is not specified, the default identifier for the "AutoGraphPS" application will be used that supports only delegated authentication.

.PARAMETER TenantId
The organization (tenant) identifier of the organization to be accessed by the connection. The identifier can be specified using either the tenant's domain name (e.g. funkadelic.org) or it's unique identifier guid. This parameter is only required for application-only sign-in, but may be optionally specified for delegated sign-in to ensure that when using a multi-tenant application limit sign-in to the specified tenant. Otherwise, the tenant for sign-in will be determined as part of the user's interaction with the token endpoint.

.PARAMETER NoninteractiveAppOnlyAuth
By default, connections created by New-GraphConnnection will sign in using an interactive, delegated flow that requires the credentials of a user and therefore also requires user interaction. Specify NoninteractiveAppOnlyAuth to override this behavior and sign-in without user credentials, just application credentials. Such credentials can be specified in the form of certificates or symmetric keys using other parameters of this command. Because such a sign-in does not involve user credentials, no user interaction is required and this sign-in is most useful for unattended execution such as scheduled or triggered automation / batch jobs.

If no parameters are used to specify the application credentials, then on Windows, if no secret is specified, New-GraphConnection will search the certificate store for a certificate that can be used as the credential. If you're not running this command on Windows, or if New-GraphConnection cannot find a certificate for the appplication or if more than one certificate is found to be a possible match, you must specify the credentials using one of the certificate or secret parameters of this command.

.PARAMETER UseBroker
By default, sign-ins for connections created by New-GraphConnection will utilize protocol sequences exchanged directly between the PowerShell process hosting the command and the Entra ID security token service (STS). When UseBroker is specified, an intermediary "broker" OS component intercepts communication between the application and the STS to provide enhanced security. This capability is only supported on newer versions of the Windows operating system. For more information on how to use this capability, see the Entra documentation for the Web Account Manager (WAM): https://learn.microsoft.com/en-us/entra/msal/dotnet/acquiring-tokens/desktop-mobile/wam.

.PARAMETER CertificatePath
Specifies the path in the file system or in the PowerShell cert: drive provider of a certificate with a private key to authenticate the application to the Graph API. This parameter is only valid if the Confidential parameter is specified.

.PARAMETER Certificate
Specifies a .NET X509Certificate2 certificate object that contains a private key to authenticate the application to the Graph API. Such an object may be obtained by using Get-Item on an item in the PowerShell cert: drive or from other software or commands that expose certificates using this structure. This parameter is only valid if the Confidential parameter is specified.

.PARAMETER Confidential
Specify this parameter if the connection's AAD application requires a client secret in order to successfully authenticate to the Graph API. When this parameter is specified, the actual client secret is specified using other parameters. If no parameters are used to specify the secret, then on Windows, if no secret is specified, New-GraphConnection will search the certificate store for a certificate that can be used as the credential. If you're not running this command on Windows, or if New-GraphConnection cannot find a certificate for the appplication or if more than one certificate is found to be a possible match, you must specify the credentials using one of the certificate or secret parameters of this command.

.PARAMETER Secret
Specify this when the Confidential parameter is specified and the secret to be used is a symmetric key rather than a certificate. Symmetric keys are more difficult to secure than certificates and should not be used in production environments.

.PARAMETER Password
When the Secret parameter is specified, specify the Password parameter as a SecureString to supply the symmetric key. Commands such as Get-Credential may be used to obtain the key and represent it as a SecureString.

.PARAMETER Cloud
Specifies the cloud to which requests that use the resulting connection should be sent. Both the Graph API endpoint and sign-in endpoints are determined by the cloud specified by this parameter. If this parameter is not specified, the Azure Public cloud endpoints for Graph and sign-in are used. Other supported clouds include the Azure China cloud and Azure Germany clouds.

.PARAMETER AppRedirectUri
Specifies the OAuth2 protocol redirect URI (also known as reply url) to be used during any sign-ins required by this connection. Since this module's default application identifier is registered as a native, public client application, the default for the AppRedirectUri parameter is http://localhost. If the application specified by the AppId parameter is not configured to include http://localhost in its list of allowed redirect URI's, then the AppRedirectUri must be specified to New-GraphConnection for subsequent sign-ins using this created connection to be successful.

.PARAMETER NoBrowserSigninUI
Specifies that this connection must not rely on a web browser for any interactive sign-in flows -- by default, interactive sign-in flows will use a web browser on the local system.

.PARAMETER GraphEndpointUri
Specifies the Graph API endpoint. If this is not specified and the Cloud parameter is not specified, the default is https://graph.microsoft.com.

.PARAMETER AuthenticationEndpointUri
Specifies the sign-in (login) endpoint. If this is not specified and the Cloud parameter is not specified, the default is https://login.microsoftonline.com.

.PARAMETER GraphResourceUri
Specifies the Graph API OAuth2 protocol resource for which to request access. If this is not specified and the Cloud parameter is not specified, the default is https://graph.microsoft.com.

.PARAMETER AccountType
Specifies what kind of account to use when signing in to the application for Graph API access. This can be AzureADOnly, in which case the connection will only support signing in to an AAD organization. If it is 'AzureADAndPersonalMicrosoftAccount', then the connection may be used to sign in to either an AAD organization or a personal Microsoft Account such as an outlook.com account. The default setting is 'Auto', which is the same as 'AzureADAndPersonalMicrosoftAccount' when the default AutoGraphPS application is used; otherwise it is AzureADOnly.

.PARAMETER Name
Specifies the unique friendly name to use for this connection. By default, the GraphConnection object returned by New-GraphConnection has a unique guid identifier but no friendly name. By specifing a name, the connection may also be specified using the name to commands such as Connect-GraphApi or Get-GraphConnection, and the connection will also show up in a list of named connections that makes it easy to maintain a set of useful connections that may be used as needed within the PowerShell session. A named connection can be removed from the list of named connections using the Remove-GraphConnection API.

.PARAMETER ConsistencyLevel
Specify this parameter so that Graph API requests made using this connection use specific consistency semantics for APIs that support them. The Graph API supports Session and Eventual semantics, and those names may be specified for this parameter to achieve their behaviors. Currently the Graph API defaults to Session semantics, but some Graph APIs support the Eventual consistency which provides advanced query capabilities not present with Session semantics.

The default value for the ConsistencyLevel parameter is 'Default', which means that API requests do not specify consistency semantics, in which case the consistency semantics are completely dependent upon the particular API's default behavior -- consult the documentation for that API for details.

Specify 'Auto' to mean that consistency semantics are taken from the current Graph settings profile if the ConsistencyLevel property is specified there.

For more information about the advanced queries capable using the Eventual consistency level, see the Graph API advanced query documentation: https://docs.microsoft.com/en-us/graph/aad-advanced-queries. For more information on the tradeoffs for the Eventual consistency level, see the command documentation for the Invoke-GraphApi command in this module.

.PARAMETER UserAgent
Specifies the HTTP 'User-Agent' request header value to use for every request to the Graph API. By default, the module uses its own specific user agent string for this header on every request. To override that default value, specify a new value using the UserAgent parameter.

.NOTES
The parameters of New-GraphConnection can be grouped into the following categories:

    * Authorization: New-GraphConnection's parameters allow you to target a specific AAD organization using a particular AAD application with specific permissions (e.g. read permissions for AAD and write permissions for e-mail).
    * Client credentials: You can specify parameters that control where to find any secrets that may be required to authenticate the application, incuding certificates in some locally accessible confidential store or a symmetric key.
    * Request routing: Graph API requests must be issued against some REST API URI -- typically this is https://graph.microsoft.com for public cloud organizations. But there are other Graph API endpoints such as that for the Azure China Cloud, and for testing purposes you may even want to specify a URI that you control as a "proxy" for validating or logging Graph API requests. Requests for access tokens must also be directed to a REST URI that is trusted by the Graph API endpoint as a token issuer, so such token acquisition endpoints may be specified as part of request routing.
    * Request behavior: Behaviors include whether to specify a preference to the API for "eventual" vs. "session" consistency along with an override for the user agent header that should be used in every request, and whether to enable management of the connection through a human readable "Name" property.

.OUTPUTS
The output is a GraphConnection object which may be used with commands that accept a "Connection" parameter to control routing, authorization, authentication, and other behaviors for communication of Graph API requests. The objects may also be specified to commands like Connect-GraphAPI or Select-GraphConnection to change the current connection that commands use when no explicit connection is specified.

.EXAMPLE
$connection = New-GraphConnection
$connection | Format-List

Id               : d86760d1-ea4b-4a97-b83e-552279034cca
Name             : (Unnamed)
Status           : Online
Connected        : False
AppID            : ac70e3e2-a821-4d19-839c-b8af4515254b
AuthType         : Delegated
AllowMSA         : True
ConsistencyLevel : Auto
Endpoint         : https://graph.microsoft.com/
Endpoint         : https://graph.microsoft.com/
AuthEndpoint     : https://login.microsoftonline.com/

Invoke New-GraphConnection with no parameters to create a new connection with default properties. Here the connection is assigned to a variable so the connection can be used as a parameter to subsequent commands, and it is also output to the console for visual inspection. These default properties include GraphEndpointUri and AuthEndpointURi properties that target the Azure public cloud Graph API service instance and the use of user delegated authentication at sign-in which requires the user to sign in. The Id property is a read-only value assigned automatically by New-GraphConnection and used by the moduel's internal connection management. The Connected property is true when a successful sign-in has occurred for the connection and it can then be used to make requests to Graph. The AllowMSA output indicates that the Connection allows sign-in using a Microsoft Account, and not just an AAD account. In general, many of the property names for the Connection object correspond to parameter names for New-GraphConnection, so consulting the parameter documentation of the command provides information about the default values for these properties.

.EXAMPLE
$mailConnection = New-GraphConnection -Permissions Mail.ReadWrite -AppId c2711e92-9f7b-4553-b2df-5ce15ac613e4
Get-GraphResource /me/messages -Connection $mailConnection -First 1 |
    Select-Object @{label='From';expression={$_.from.emailAddress.address}}, receivedDateTime, subject

From              receivedDateTime     subject
----              ----------------     -------
news@defender.org 2021-10-06T05:27:00Z Support local journalism!

In this example, New-GraphConnection is used to create a connection for accessing email by specifying a dedicated AAD application through the AppId parameter as well as requesting permisions for mail access via the Permissions parameter. The output of the command is then assigned to the $mailConneciton variable. The connection variable is then specified as the Connection parameter for Get-GraphResource, which uses that connection instead of the module's current connection to make a Graph API request to read mail messages. While the invocation of Get-GraphResource will trigger an interactive sign-in when the profile specifies a delegated sign-in (the module's default behavior), any subsequent command invocations for which the variable is specified through the Connection parameter will require no interaction. This manner of using New-GraphConnection and the common Connection parameter makes it easy to maintain a "default".

Note that it is not at all necessary to use a different AAD application when new permissions are required, but it can be useful if you have a desired to limit the permissions consented to the default application used with the module or in cases where AAD policies actually enforce such restrictions by denying ability to consent additional permissions to the default application.

Finally, the Permissions parameter only needs to be specified if the application does not already have consent for the permission. If you've signed using the application in the past and granted the permission, AAD remembers the grant and you do not need to request it again for that application unless you or an administrators revokes the permission.

.EXAMPLE
New-GraphConnection -Name MailConnection -Permissions Mail.ReadWrite -AppId c2711e92-9f7b-4553-b2df-5ce15ac613e4

AppId                                ConnectionName Organization                         AuthType
-----                                -------------- ------------                         --------
c2711e92-9f7b-4553-b2df-5ce15ac613e4 MailConnection 10217ae4-f953-446c-9c50-d70052b85369 Delegated

Connect-GraphApi MailConnection
$messages = Get-GraphResource /me/messages

This use case for creating an alternate "mail" connection is the same as that of the previous example, but here the Name parameter of New-GraphConnection is used to assign a name to the connection. The name may then be specified to commands like Connect-GraphApi that accept connection names to identify connections just like other commands accept actual connection objects. Use of Connect-GraphApi will initiate a sign-in and set the current connection to the named connection "MailConnection". Subsequent commands will use this connection by default so that the Connection parameter is not needed to use the new connection as in the invocation of Get-GraphResource in this example. The assignment of names to connections and ability to use those names with Connect-GraphApi and Select-GraphConnection makes it convenient to use different connections at different times without the need to explicitly pass the Connection parameter to every single command invocation.

.EXAMPLE
$appConnection = New-GraphConnection -AppId 43b49b9c-e886-451d-9686-c5d73bdd3d25 -AppRedirectUri https://devops.mothership.org

This example shows how New-GraphConnection allows the module to override the default application redirect URI (also known as reply URL) that it submits during sign-in. When the connection is used for sign-in, the connection's AppRedirectUri property must match one of the application's configured redirect URI's or authentication will fail. By default, the module's sign-in functionality uses 'http://localhost' for the redirect URI. If that URI is not configured for the application, you must specify the AppRedirectUri parameter when using New-GraphConnection for that application so that sign-in can be successful

.EXAMPLE
$china = New-GraphConnection -Cloud ChinaCloud -AppId 1d4df069-3bc5-4730-bb56-3d4a6c414b91

This example demonstrates the creation of a connection to the Microsoft Graph API endpoint in the Azure China cloud. Note that in the China cloud specifically the module's default application identifier may not be valid, so the application of an application created by some user in the organization or available in some China cloud tenant is used. You may need to create a new application in a China cloud Azure subscription through the Azure portal or other tools so that you can specify that application's identifier to this command.

.EXAMPLE
$newApp = New-GraphApplication -Name OrgMonitor -ApplicationPermissions Organization.Read.All -NewCredential
$newCon = New-GraphConnection -AppId $newApp.appId -NoninteractiveAppOnlyAuth -TenantId c8addc00-b475-43dc-b7a7-420e5db30281
Get-GraphResource /organization -Connection $newCon | Select-Object id, displayName, directorySizeQuota

id                                   displayName directorySizeQuota
--                                   ----------- ------------------
c8addc00-b475-43dc-b7a7-420e5db30281 BubbleStar  @{used=1547; total=50000}

In this example a new application is created with New-GraphApplication with permissions to read the tenant's organization object and a client credential in the local certificate store. Then New-GraphConnection is used to create a connection that implicitly uses the application's client credential from the certificate store to enable application-only sign-in with no user interaction required. Finally, the newly created connection is specified for the Connection parameter for the Get-GraphResource command  to make a request to the Graph API to read the organization object. The response output is piped to the Select-Object to display the id, displayName, and directorySizeQuota properties of the organization. This entire sequence of commands requires no sign-in and can run as part of an automated script -- provided of course that some connection to the desired organization is already established before running the first command.

.EXAMPLE
$certFileName=OrgMonClientCertFile

# Use openssl to create a cert -- this works for Linux and Windows and any other platforms supported by the openssl tools
openssl req -newkey rsa:4096 -x509 -days 365 -keyout ~/protectedcerts/$($certFileName)-pri.key -out ~/protectedcerts/$($certFileName)-pub.crt -subj '/CN=OrgMon/CN=Internal/CN=BubbleStar'
openssl pkcs12 -export -inkey ~/protectedcerts/$($certFilename)-pri.key -in ~/protectedcerts/$($certFilename)-pub.crt -out ~/protectedcerts/$($certFilename).pfx

$orgMonApp = New-GraphApplication -Name OrgMon -ApplicationPermissions Organization.Read.All
$orgMonApp | Set-GraphApplicationCertificate -CertificatePath ~/protectedcerts/$($certFilename).pfx -PromptForCertCredential

$newCon = New-GraphConnection -AppId $OrgMonApp.AppId -NoninteractiveAppOnlyAuth -Certificatepath ~/protectedcerts/$($certFilename).pfx -TenantId c8addc00-b475-43dc-b7a7-420e5db30281
Connect-GraphApi -Connection $newCon -NoSetCurrentConnection -PromptForCertCredential

Get-GraphResource /organization -Connection $newCon | Select-Object id, displayName, directorySizeQuota

id                                   displayName directorySizeQuota
--                                   ----------- ------------------
c8addc00-b475-43dc-b7a7-420e5db30281 BubbleStar  @{used=1547; total=50000}

This is example is similar to the previous one in that a new application is created and a connection created that can use its client certificate for non-interactive signin. The main difference is that in this case New-GraphConnection references a certificate file system path rather than looking up a certificate for the application in the local certificate store. This example actually starts with the creation of the file system certificate using the openssl command-line tool before proceeding to use commands from this module to create the new application with New-GraphApplication, configure the certificate credentials with Set-GraphApplicationCertificate, and then use those credentials to create the connection with New-GraphConnection.

Note that in this case before supplying the connection to the Get-GraphResource command via the Connection parameter, the sign-in must be invoked using Connect-GraphApi with the PromptForCredential parameter. This is because the certificate created by the openssl commands in this case uses a passsword to protect the private key, and this password is required at sign-in time for the module to be able to access the key. Since Get-GraphResource does not automatically prompt the user for the key and has no parameter to specify that a password should be obtained before attempting a sign-in, the sign-in must occur before the connection is used with Get-GraphResource. To initiate the sign-in, new connection is specified as the Connection parameter for Connect-GraphApi along with the PromptForCertCredential -- the latter parameter prompts the user to enter the certificate password, allowing Connect-GraphApi to complete the sign-in. The connection is then in a signed-in state and can be used with Get-GraphResource to communicate with the Graph API.

.EXAMPLE
$appCert = Get-ChildItem Cert:\CurrentUser\my | where FriendlyName -like *UnattendedApp* | Select-Object -First 1
$unattendedConnection = New-GraphConnection -AppId 02a940be-2aba-47a4-aee9-ae66b9d94021 -Certificate $appCert -NoninteractiveAppOnlyAuth
$allUsers = Get-GraphResource /organization -Connection $unattendedConnection

In this example the Windows certificate store is traversed with Get-GraphChildItem to find the cert for an application based on the certificate's friendly name property and assign it to a variable. The assigned value is actually a .NET object of type [System.Security.Cryptography.X509Certificates.X509Certificate2], and so it be specified as the value of the Certificate parameter of the New-GraphConnection command to create a connection using that certificate's private key. Finally, the new connection is specified for the Connection parameter of Get-GraphResource to issue a GET request using the connection's application identity.

.EXAMPLE
New-GraphConnection -Name Personal -AccountType AzureADAndPersonalMicrosoftAccount -Permissions Contacts.Read
Connect-GraphApi Personal
$contacts = Get-GraphResource /me/contacts
Connect-GraphApi Work

In this case, Connect-GraphApi is used to switch between named "work" and "personal" connections. First, New-GraphConnection is used with the AccountType parameter specified as AzureADAndPersonalMicrosoftAccount to allow sign-in using a personal Microsoft account; if that account type is not specified, Connect-GraphApi's behavior is to disallow the use of a personal account at sign-in unless the module's default application is in use which is known to be configured to allow personal account sign-ins. Once the named connection "personal" is created, Connect-GraphApi is invoked with "personal" for the name parameter to set the current connection. At ths point commands like Get-GraphResource may be used to access the personal account. In this example there is also a named connection called "work," and the user issues another invocation of Connect-GraphApi can then switch the current connection to the named "work" connection. Since the connection is already signed in, invoking Connect-GraphApi this time does not cause another sign-in, it simply causes the current connection to be changed. Only the first use of each connection results in an interactive sign-in regardless how many times the user switches between connections.

.EXAMPLE
$confidentialApp = New-GraphApplication -Confidential -DelegatedUserPermissions Directory.Read.All -name AdminWorkstationApp -NewCredential
$confidentialConnection = New-GraphConnection -AppId $confidentialApp.appId -Confidential
$groups = Get-GraphResource /groups -Connection $confidentialConnection

New-GraphConnection is used here to establish a confidential connection, i.e. one that requires a locally available client certificate. When the Confidential paramter is specified, on Windows New-GraphConnection will search the local certificate store for a certificate with metadata that indicates it can be used to authenticate as the specified AppId when the Certificate and CertificatePath parameters are omitted. This heuristic search does not apply if a path to a certificate in the file system or the Windows certificate store drive is specified through the CertificatePath parameter, or if the Certificate parameter is specified. The connection is specified by the Connection parameter to an invocation of Get-GraphResource. Note that if the Confidential parameter is not specified to New-GraphConnection, it will succeed, but the use of the connection by Get-GraphResource will fail since the application in this example requires a client secret and such a secret cannot be accessed by a connection created without specifying the Confidential parameter.

.EXAMPLE
$symmetricKeyCredential = Get-Credential
$confidentialConnection = New-GraphConnection -AppId addb2b45-e3ca-47ba-a5ab-41c722ba13a1 -Confidential -Secret -Password $symmetricKeyCredential.GetNetworkCredential().SecurePassword -Permissions Application.Read.All
$applications = Get-GraphResource /applications -Connection $confidentialConnection

This example is similar to the previous one in that a connection using delegated permission and a client secret is used to perform an interactive sign-in and access the directory. However, in this case the application is configured to require the submission of a symmetric key rather than verifying the caller's possession of a certificate's private key. The symmetric key is obtained through the Get-Credential command, which prompts the user for a username (which will be ignored) and a password. The user can enter the application's symmetric key through the password field, and an object that enables access to the key will be assigned to the $symmetricKeyCredential variable. New-GraphConnection can then use the key: along with the Confidential parameter, the Secret parameter must be specified AND the Password parameter must be supplied with the symmetric key. The password parameter must be a [SecureString] type, and that can be obtained $symmetricKeyCredential variable with the expression $symmetricKeyCredential.GetNetworkCredential().SecurePassword. The resulting connection may be specified to Get-GraphResource to access the Graph API.

.EXAMPLE
$graphConnection = New-GraphConnection -GraphEndpointUri https://graph.microsoft.com -GraphResourceUri https://graph.microsoft.com -AuthenticationEndpointUri https://login.microsoftonline.com
Get-GraphResource /me -Connection $graphConnection

This example shows how to create a customized connection that uses arbitrary URI's to describe the two required endpoints, the Graph API endpoint and the authentication endpoint used for obtaining access tokens. The GraphEndpointUri and AuthenticationEndpointUri parameters respectively specify this configuration. Another parameter, GraphResourceUri, is used to specify the resource for which to request access. Note that in this use case, all three parameters have the default value for the Azure public cloud instance of the Graph API which is what the module users by default. Other values may be used however, which could be useful if you've implemented a proxy for instance for one of the endpoints. Also, in the future if there are new Graph API service or login endpoints, or alternative resource URI's are offered for the Graph API resource, New-GraphConnection can be used to specify these alternative or proxy endpoints so that commands may communicate to the targeted Graph API service.

.LINK
Connect-GraphApi
Disconnect-GraphApi
Get-GraphConnection
Remove-GraphConnection
Select-GraphConnection
Get-GraphAccessToken
#>
function New-GraphConnection {
    [cmdletbinding(positionalbinding=$false, DefaultParameterSetName='msgraph')]
    param(
        [parameter(parametersetname='msgraph', position=0)]
        [parameter(parametersetname='cloud', position=0)]
        [parameter(parametersetname='customendpoint', position=0)]
        [parameter(parametersetname='cert', position=0)]
        [parameter(parametersetname='certpath', position=0)]
        [parameter(parametersetname='autocert', position=0)]
        [parameter(parametersetname='secret', position=0)]
        [String[]] $Permissions = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='autocert')]
        $AppId = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='autocert')]
        [parameter(parametersetname='customendpoint')]
        [Switch] $NoninteractiveAppOnlyAuth,

        [Switch] $UseBroker,

        [String] $TenantId = $null,

        [parameter(parametersetname='certpath', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [string] $CertificatePath = $null,

        [parameter(parametersetname='cert', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate = $null,

        [switch] $Confidential,

        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [Switch] $Secret,

        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [SecureString] $Password,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud', mandatory=$true)]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='autocert')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [alias('ReplyUrl')]
        [Uri] $AppRedirectUri,

        [Switch] $NoBrowserSigninUI,

        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $GraphEndpointUri = $null,

        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $AuthenticationEndpointUri = $null,

        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $GraphResourceUri = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='customendpoint')]
        [ValidateSet('Auto', 'AzureADOnly', 'AzureADAndPersonalMicrosoftAccount')]
        [string] $AccountType = 'Auto',

        [string] $Name = $null,

        [ValidateSet('Auto', 'Default', 'Session', 'Eventual')]
        [string] $ConsistencyLevel = 'Default',

        [String] $UserAgent = $null
    )

    begin {
    }

    process {
        Enable-ScriptClassVerbosePreference

        $validatedCloud = if ( $Cloud ) {
            [GraphCloud] $Cloud
        } else {
            ([GraphCloud]::Public)
        }

        if ( $UseBroker.IsPresent ) {
            if ( $NoninteractiveAppOnlyAuth.IsPresent ) {
                throw [ArgumentException]::new("The UseBroker parameter may not be specified when NoninteractiveAppOnlyAuth")
            }

            $currentOS = [System.Environment]::OSVersion.Platform
            if ( $currentOS -ne 'Win32NT' ) {
                throw [System.NotSupportedException]::new("The UseBroker authentication broker option was specified, but the current OS platform '$currentOS' does not support brokers. This capability is supported only on the Windows OS platform")
            }
        }

        $specifiedScopes = if ( $Permissions ) {
            if ( $Secret.IsPresent -or $Certificate -or $CertificatePath ) {
                throw 'Permissions may not be specified at runtime for app-only authentication since they originate from the static application configuration'
            }
            $Permissions
        }

        $noAppSpecified = $false

        $targetAppId = if ( $appId ) {
            $appId
        } else {
            $noAppSpecified = $true
            $::.Application.DefaultAppId
        }

        $allowMSA = $AccountType -eq 'AzureADAndPersonalMicrosoftAccount'

        if ( ! $allowMSA -and $AccountType -eq 'Auto' ) {
            # The default app supports MSA
            $allowMSA = $noAppSpecified
        }

        if ( $GraphEndpointUri -eq $null -and $AuthenticationEndpointUri -eq $null -and $appId -eq $null ) {
            write-verbose 'Simple connection specified with no custom uri or app id'
            $::.GraphConnection |=> NewSimpleConnection $validatedCloud $specifiedScopes $false $TenantId -useragent $UserAgent -allowMSA $allowMSA -ConsistencyLevel $ConsistencyLevel -Name $Name -useBroker $UseBroker.IsPresent
        } else {
            $graphEndpoint = if ( $GraphEndpointUri -eq $null ) {
                write-verbose 'Custom endpoint data required, no graph endpoint URI was specified, using URI based on cloud'
                write-verbose ("Creating endpoint with cloud '{0}'" -f $validatedCloud)
                new-so GraphEndpoint $validatedCloud $null $null $GraphResourceUri
            } else {
                write-verbose "Custom endpoint data required and graph endpoint URI was specified, using specified endpoint URI'"
                new-so GraphEndpoint ([GraphCloud]::Custom) $GraphEndpointUri $AuthenticationEndpointUri $GraphResourceUri
            }

            $adjustedTenantId = $TenantId

            $appSecret = if ( $Confidential.IsPresent -or $NoninteractiveAppOnlyAuth.IsPresent ) {
                if ( $Password ) {
                    $Password
                } elseif ( $Certificate ) {
                    $Certificate
                } elseif ( $CertificatePath ) {
                    $CertificatePath
                } else {
                    $appCertificate = $::.GraphApplicationCertificate |=> FindAppCertificate $targetAppId
                    if ( ! $appCertificate ) {
                        throw "NoninteractiveAppOnlyAuth or Confidential was specified, but no password or certificate was specified, and no certificate with the appId '$targetAppId' in the subject name could be found in the default certificate store location. Specify an explicit certificate or password and retry."
                    } elseif ( ($appCertificate -is [object[]] ) -and $appCertificate.length -gt 1 ) {
                        throw "NoninteractiveAppOnlyAuth or Confidential was specified, and more than one certificate with the appId '$targetAppId' in the subject name could be found in the default certificate store location. Specify an explicit certificate or password and retry. `n$($appCertificate.PSPath)`n"
                    }
                    $appCertificate
                }

                if ( ! $TenantId ) {
                    write-verbose "No tenant id was specified and app is non-interactive, attempting to get tenant id from current token"
                    $inferredTenantId = ('GraphContext' |::> GetConnection).Identity |=> GetTenantId

                    if ( ! $inferredTenantId ) {
                        throw [ArgumentException]::new("No tenant was specified for app-only auth, and a tenant could not be inferred from the current token -- specify a tenant id with the -TenantId parameter and retry the command.")
                    }

                    $adjustedTenantId = $inferredTenantId
                }
            }

            $app = new-so GraphApplication $targetAppId $AppRedirectUri $appSecret $NoninteractiveAppOnlyAuth.IsPresent
            $identity = new-so GraphIdentity $app $graphEndpoint $adjustedTenantId $allowMSA
            new-so GraphConnection $graphEndpoint $identity $specifiedScopes $NoBrowserSigninUI.IsPresent $userAgent $Name $ConsistencyLevel $UseBroker.IsPresent
        }
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphConnection Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))
