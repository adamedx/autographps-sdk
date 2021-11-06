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

. (import-script ../client/GraphConnection)
. (import-script ../client/GraphContext)
. (import-script ../client/LogicalGraphManager)
. (import-script New-GraphConnection)
. (import-script common/DynamicParamHelper)
. (import-script ../common/ScopeHelper)
. (import-script common/CertificateHelper)
. (import-script common/PermissionParameterCompleter)

<#
.SYNOPSIS
Establishes a communication channel to the Graph API and sets it as the default channel for subsequent commands that issue Graph API requests.

.DESCRIPTION
Connect-GraphApi performs an Azure Active Directory sign-in to obtain access to the Graph API. If the sign-in is successful, the resulting connection object which encapsulates the Graph API service endpoint as well as the access token may be used to implicitly or explicitly by commands that access the Graph API such as Get-GraphResource and Invoke-GraphAPIRequest.

For the most common interactive cases, the Connect-GraphApi command is sufficient for enabling access to the Graph API; the New-GraphConnection enables more advanced connection management and automation scenarios.

When the module is loaded, there is a default current connection, but it is not signed in to. By default, commands will implicitly use this default connection and if it has not been signed in a sign-in will be invoked. Connect-GraphApi explicitly invokes the sign-in for a connection, whether that connection is currently the default or not.

Any connection that has been signed in implicitly or through Connect-GraphApi can be signed out using the Disconnect-GraphApi.

There are three ways to create connections (which may then be used to access the Graph API after a successful sign-in):

* Connect-GraphApi: This command can create new connection and also sign-in to the new connection or an existing one
* New-GraphConnection: This command creates new connections, including named connections (see further discussion in this documentation), but does not perform a sign-in. This can be used in an ad-hoc way when you need to use multiple connections for your PowerShell session for instance without having to sign in each time you switch back and forth.
* Profile settings: The profile settings file that is processed at startup can create named connections just like New-GraphConnection -- this is useful for removing the need to manually create the reusable named connections. For details on the format and usage of the settings file, see the documentation at https://github.com/adamedx/autographps-sdk/tree/main/docs/settings.

Connect-GraphApi's capabilities can be decomposed into three key areas:

    * Connection creation: Connect-GraphApi can create a new connection, though this step is skipped if an existing connection is supplied using the ConnectionName or Connection parameters. The parameters to create the new connection are the same as those for New-GraphConnection -- New-GraphConnection can be used instead of Connect-GraphApi to create a new connection, with a key difference that New-GraphConnection does not perform a sign-in for the newly created application and New-GraphConnection is not influenced by profile settings, while Connect-GraphApi parmameters not explicitly specified may take on values from the profile unless the NoProfile parameter is specified.
    * Connection sign-in: Invocation of Connect-GraphApi always result in a sign-in -- if the sign-in is unsuccessful, the command fails and no further functionality forthe command is executed.
    * Setting the current connection: Commands in this module use the concept of a current connection to use for issuing Graph API requests. Unless the NoSetCurrentConnection parameter specified, Connect-GraphApi will set the current connection to the connection that it signed-in. Commands that issue Graph API requests will use this connection by default unless an override connection is specified -- some commands allow for the specification of an explicit connection, but many do not. The Select-GraphConnection command can be used to set the current connection without either of the connection creation or sign-in steps of Connect-GraphApi.

By default, Connect-GraphApi signs in to a specific 'AutoGraphPS' multi-tenant application with identifier ac70e3e2-a821-4d19-839c-b8af4515254b that is registered as a native public client application. When using ConnectGraphApi or New-GraphConnection, you can specify the AppId parameter to provide an application identifier of your choice to override the default application.

When you specify your own AAD application's identifier for the AppId parameter, Connect-GraphApi supports the use of client secrets in order to sign in with an AAD application identity that requires a pre-configured client secret (as opposed to one that only requires the current credentials of a user). For such applications, you must supply Connect-GraphApi with the client secret in order to sign in. The parameters used to do so are the same as those for New-GraphConnection -- consult the New-GraphConnection documentation for additional guidance on options for supplying the client secret credentials.

.PARAMETER ConnectionName
Specifies the unique friendly name of a connection created by the New-GraphConnection command or through profile settings. The connection with that name is signed-in and then set to be the current connection. This is similar to specifying the named connection's connection object as the Connection parameter, which signs in a connection specified by its object rather than its friendly name. Note that the parameter is the first positional parameter, so the parameter name itself is optional as in this example.

.PARAMETER Permissions
Specifies that the connection created by Connect-GraphApi requires certain delegated permissions when it is used to sign-in interactively for accesss to the Graph API. By default when this parameter is not specified, commands that request access will not ask for permissions beyond those that have already been delegated to the connection's AAD application identity for the user who signs in. If these permissions are not sufficient for successful access to the particular APIs you intend to access using this module's commands through this connection, specify the Permissions parameter to request the additional required permissions at sign-in.

.PARAMETER AppId
The AAD application identifier to be used by the connection. If the AppId parameter is not specified, the application identifier specified in the connection settings of the current Graph profile is used. If no such profile configuration setting exists, the default identifier for the "AutoGraphPS" application will be used that supports only delegated authentication.

.PARAMETER TenantId
The organization (tenant) identifier of the organization to be accessed by the connection. The identifier can be specified using either the tenant's domain name (e.g. funkadelic.org) or it's unique identifier guid. This parameter is only required for application-only sign-in, but may be optionally specified for delegated sign-in to ensure that when using a multi-tenant application limit sign-in to the specified tenant. Otherwise, the tenant for sign-in will be determined as part of the user's interaction with the token endpoint.

.PARAMETER NoninteractiveAppOnlyAuth
By default, connections created by Connect-GraphApi will sign in using an interactive, delegated flow that requires the credentials of a user and therefore also requires user interaction. Specify NoninteractiveAppOnlyAuth to override this behavior and sign-in without user credentials, just application credentials. Such credentials can be specified in the form of certificates or symmetric keys using other parameters of this command. Because such a sign-in does not involve user credentials, no user interaction is required and this sign-in is most useful for unattended execution such as scheduled or triggered automation / batch jobs.

If no parameters are used to specify the application credentials, then on Windows, if no secret is specified, Connect-GraphApi will search the certificate store for a certificate that can be used as the credential. If you're not running this command on Windows, or if the command cannot find a certificate for the appplication or if more than one certificate is found to be a possible match, you must specify the credentials using one of the certificate or secret parameters of this command.

.PARAMETER ExistingPermissionsOnly
By default, Connect-GraphApi always requests the permission User.Read at sign-in because it provides a minimal but useful amount of access to Graph API resources that help users maintain awareness of what identity they used for signing in. However the permission is not strictly necessary so to avoid the need to consent to that permission, and in particular to ensure that legacy AAD applications that support only static request and fail any sign-ins where additional permissions are requested, specify this parameter.

.PARAMETER CertificatePath
Specifies the path in the file system or in the PowerShell cert: drive provider of a certificate with a private key to authenticate the application to the Graph API. This parameter is only valid if the Confidential parameter is specified.

.PARAMETER Certificate
Specifies a .NET X509Certificate2 certificate object that contains a private key to authenticate the application to the Graph API. Such an object may be obtained by using Get-Item on an item in the PowerShell cert: drive or from other software or commands that expose certificates using this structure. This parameter is only valid if the Confidential parameter is specified.

.PARAMETER Confidential
Specify this parameter if the connection's AAD application requires a client secret in order to successfully authenticate to the Graph API. When this parameter is specified, the actual client secret is specified using other parameters. If no parameters are used to specify the secret, then on Windows, if no secret is specified, Connect-GraphApi will search the certificate store for a certificate that can be used as the credential. If you're not running this command on Windows, or if Connect-GraphApi cannot find a certificate for the appplication or if more than one certificate is found to be a possible match, you must specify the credentials using one of the certificate or secret parameters of this command.

.PARAMETER Secret
Specify this when the Confidential parameter is specified and the secret to be used is a symmetric key rather than a certificate. Symmetric keys are more difficult to secure than certificates and should not be used in production environments.

.PARAMETER Password
When the Secret parameter is specified, specify the Password parameter as a SecureString to supply the symmetric key. Commands such as Get-Credential may be used to obtain the key and represent it as a SecureString.

.PARAMETER Cloud
Specifies the cloud to which requests that use the resulting connection should be sent. Both the Graph API endpoint and sign-in endpoints are determined by the cloud specified by this parameter. If this parameter is not specified, the Azure Public cloud endpoints for Graph and sign-in are used. Other supported clouds include the Azure China cloud and Azure Germany clouds.

.PARAMETER AppRedirectUri
Specifies the OAuth2 protocol redirect URI (also known as reply url) to be used during any sign-ins required by this connection. Since this module's default application identifier is registered as a native, public client application, the default for the AppRedirectUri parameter is http://localhost. If the application specified by the AppId or by the profile settings is not configured to include http://localhost in its list of allowed redirect URI's, then the AppRedirectUri must be specified to Connect-GraphApi for the sign-in to be successful.

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

.PARAMETER ConsistencyLevel
Specify this parameter so that Graph API requests made using this connection use specific consistency semantics for APIs that support them. The Graph API supports Session and Eventual semantics, and those names may be specified for this parameter to achieve their behaviors. Currently the Graph API defaults to Session semantics, but some Graph APIs support the Eventual consistency which provides advanced query capabilities not present with Session semantics.

The default value for the ConsistencyLevel parameter is 'Auto', which means that consistency semantics are taken from the current Graph settings profile if the ConsistencyLevel property is specified there.

You may also specify 'Default', which means that API requests do not specify consistency semantics, in which case the consistency semantics are completely dependent upon the particular API's default behavior -- consult the documentation for that API for details.

For more information about the advanced queries capable using the Eventual consistency level, see the Graph API advanced query documentation: https://docs.microsoft.com/en-us/graph/aad-advanced-queries. For more information on the tradeoffs for the Eventual consistency level, see the command documentation for the Invoke-GraphApi command in this module.

.PARAMETER UserAgent
Specifies the HTTP 'User-Agent' request header value to use for every request to the Graph API. By default, the module uses its own specific user agent string for this header on every request. To override that default value, specify a new value using the UserAgent parameter.

.PARAMETER NoProfile
By default, connections created by Connect-GraphApi inherit properties such as the AAD application identifier, redirect URI's, and several other settings from the profile configuration settings if any are present. To remove any influence of profile settings for any connections created by this command, specify the NoProfile parameter. Alternatively, the AUTOGRAPH_BYPASS_SETTINGS environment variable may be set to globally disable profile settings before the module is loaded.

.PARAMETER Reconnect
Invokes a sign-in for the current connecton even if the connection has already signed in. This is useful in case consent has been granted out-of-band since a new sign-in will result in a new access token with any additionally consented permissions.

.PARAMETER PromptForCertCredential
Specifies that the command should request secure user input to obtain a credential for reading a certificate specified by other parameters of this command or required by an existing connection in order to authenticate at sign-in. This is only needed when the certificate is protected by a password credential for instance.

.PARAMETER Connection
Given an exisitng connection such as one created by the New-GraphConnection or Connect-GraphApi commands or returned by connection management commands such as Get-GraphConnection, the Connection parameter instructs Connect-GraphApi not to create a new connection -- it simply signs in to the connection supplied as to Connection parameter and then sets it to be the current connection. This is useful if the connection was created by a command like New-GraphConnection since that command does not perform sign-in. A use case may be to create a group of connection objects with different application identities or connections to different Graph API instances; the invocations of New-GraphConnection can be done as a group without noticeable user interaction because they do not involve sign-in, and sign-in to any particular connection can be deferred until the user actually needs it, as opposed to requiring up front sign-in of multiple connections even if only one of themis used.

.PARAMETER NoSetCurrentConnection
By default, after Connect-GraphApi signs in to a connection, either one that it created or one that already existed and was specified using the ConnectionName or Connection parameters, that connection will become the current connection. To leave the current connection unaltered and only perform the sign-in, specify the NoSetCurrentConnection parameter.

.PARAMETER Current
Specify this parameter to sign in to the current connection instead of creating a new one. This is useful when making use of connections created by New-GraphConnection as it allows complete control over when sign-in occurs.

.OUTPUTS
The output is the GraphConnection object for which the sign-in occurred. If the Connect-GraphApi was invoked by specifying an existing connection, the output will just be that existing object; otherwise the output is a connection object created as part of the command invocation. The object may be used with commands that accept a "Connection" parameter to control routing, authorization, authentication, and other behaviors for communication of Graph API requests. The objects may also be specified to Disconnect-GraphApi, Get-GraphConnection, and Select-GraphConnection to manage the current connection.

.EXAMPLE
Connect-GraphApi

AppId                                ConnectionName Organization                         AuthType
-----                                -------------- ------------                         --------
ac70e3e2-a821-4d19-839c-b8af4515254b (Unnamed)      fe4ce618-28d6-4fe9-b49e-e4e8f615998b Delegated

Invoke Connect-GraphApi with no parameters in order to create a new connection with default properties, sign-in to the new connection, and set it as the current connection for use with any subsequent commands that access the Graph API. The default properties may be subject to additional customization from any profile settings that are configured. After invoking Connect-GraphApi, all other commands in the module that access the Graph API will use this connection.

.EXAMPLE
Connect-GraphApi -Permissions Mail.ReadWrite
Get-GraphResource me/messages -First 1 |
    Select-Object @{label='From';expression={$_.from.emailAddress.address}}, receivedDateTime, subject

From              receivedDateTime     subject
----              ----------------     -------
news@defender.org 2021-10-06T05:27:00Z Support local journalism!

In this example, Connect-GraphApi creates a new connection that explicitly requests the Mail.ReadWrite connection at sign-in so that subsequent commands can successfully issue requests that require that permission. After the succesful sign-in, Get-GraphResource is used to obtain mail messages and display the most recent one, an operation that requires the Mail.ReadWrite permission that was requested through Connect-GraphApi in order to succeed. Note that any additional sign-ins using Connect-GraphApi do not need to specify the Mail.ReadWrite permission as AAD records permission consent grants and honors the consent in all future sign-ins until the consent is revoked by the user by administrators. There is no harm in requesting the permission even if it has already been consented, so as a best practice if an isolated script or sequence of commands includes an invocation of Connect-GraphApi the Permissions parameter should be used to explicitly request any permissions required for the script's subsequent commands that access the Graph API.

.EXAMPLE
New-GraphConnection -Name MailConnection -Permissions Mail.ReadWrite -AppId c2711e92-9f7b-4553-b2df-5ce15ac613e4
Connect-GraphApi MailConnection

AppId                                ConnectionName Organization                         AuthType
-----                                -------------- ------------                         --------
ac70e3e2-a821-4d19-839c-b8af4515254b MailConnection 10217ae4-f953-446c-9c50-d70052b85369 Delegated

Connect-GraphApi MailConnection
$messages = Get-GraphResource me/messages

Here an existing named connection called "MailConnection" is signed in if it hasn't been already and then set to the current connection. The subsequent invocation of Get-GraphResource used to obtain email messages uses this current connection.

.EXAMPLE
$work = Get-GraphConnection -Current
$personal = New-GraphConnection -AccountType AzureADAndPersonalMicrosoftAccount -Permissions Contacts.Read

Connect-GraphApi -Connection $personal

$contacts = Get-GraphResource /me/contacts

Connect-GraphApi -Connection $work

This example shows how to use the Connection parameter to switch between connections. In this case, the user starts with the current connection used for work, and so retrives it with the Get-GraphConnection command using the -Current parameter and assigns it to a variable $work -- this is the user's connection accessing the Graph API for work. Next, the user creates a new connection using New-GraphConnection and assigns it to the $personal variable. The parameters passed to New-GraphConnection allow the user to sign in to a personal Microsoft Account. The Connect-GraphApi command is then used with the $personal connection specified to the Connection parameter to sign in to the Graph API using that personal connection. The user and subsequently retrieves their personal contacts using Get-GraphResource and stores them in a variable. The user then switches back to work context with another use of the Connection parameter when invoking Connect-GraphApi, this time specifying the $work connection saved earlier -- now the user can resume invoking commands that use the work connection. Since the connection is already signed in, invoking Connect-GraphApi this time does not cause another sign-in, it only causes the current connection to be changed. Because both connections are saved in variables, Connect-GraphApi with the Connection may continue to be used to switch back and forth between them, and only the first use of each connection results in an interactive sign-in regardless how many times the user switches between connections.

.EXAMPLE
Connect-GraphApi -AppId 43b49b9c-e886-451d-9686-c5d73bdd3d25 -AppRedirectUri https://devops.mothership.org

This example shows how Connect-GraphApi allows the command to override the default application redirect URI (also known as reply URL) that it submits during sign-in. At sign-in the connection's AppRedirectUri property must match one of the application's configured redirect URI's or authentication will fail. By default, the module's sign-in functionality uses 'http://localhost' for the redirect URI. If that URI is not configured for the application, you must specify the AppRedirectUri parameter when using Connect-GraphApi for that application so that sign-in can be successful

.EXAMPLE
Connect-GraphApi -Cloud ChinaCloud -AppId 1d4df069-3bc5-4730-bb56-3d4a6c414b91

This example demonstrates the establishment of a connection to the Microsoft Graph API endpoint in the Azure China cloud. Note that in the China cloud specifically the module's default application identifier may not be valid, so the application of an application created by some user in the organization or available in some China cloud tenant is used. You may need to create a new application in a China cloud Azure subscription through the Azure portal or other tools so that you can specify that application's identifier to this command.

.EXAMPLE
$newApp = New-GraphApplication -Name OrgMonitor -ApplicationPermissions Organization.Read.All -NewCredential
Connect-GraphApi -AppId $newApp.appId -NoninteractiveAppOnlyAuth -TenantId c8addc00-b475-43dc-b7a7-420e5db30281
Get-GraphResource /organization | Select-Object id, displayName, directorySizeQuota

id                                   displayName directorySizeQuota
--                                   ----------- ------------------
c8addc00-b475-43dc-b7a7-420e5db30281 BubbleStar  @{used=1547; total=50000}

In this example a new application is created with New-GraphApplication with permissions to read the tenant's organization object and a client credential in the local certificate store. Then Connect-GraphApi is used to create a connection that implicitly uses the application's client credential from the certificate store and signs in with that crecential without any user interaction. Finally, Get-GraphResource command is invoked to make a request to the Graph API to read the organization object -- it will use the newly created current connection to do so. The response output is piped to the Select-Object to display the id, displayName, and directorySizeQuota properties of the organization. This entire sequence of commands requires no sign-in and can run as part of an automated script -- provided of course that some connection to the desired organization is already established before running the first command.

.EXAMPLE
$certFileName=OrgMonClientCertFile

# Use openssl to create a cert -- this works Linux and Windows and any other platforms supported by the openssl tools
openssl req -newkey rsa:4096 -x509 -days 365 -keyout ~/protectedcerts/$($certFileName)-pri.key -out ~/protectedcerts/$($certFileName)-pub.crt -subj '/CN=OrgMon/CN=Internal/CN=BubbleStar'
openssl pkcs12 -export -inkey ~/protectedcerts/$($certFilename)-pri.key -in ~/protectedcerts/$($certFilename)-pub.crt -out ~/protectedcerts/$($certFilename).pfx

$orgMonApp = New-GraphApplication -ApplicationPermissions Organization.Read.All
$orgMonApp | Set-GraphApplicationCertificate -CertificatePath ~/protectedcerts/$($certFilename).pfx -PromptForCertCredential

Connect-GraphApi -AppId $OrgMonApp.AppId -NoninteractiveAppOnlyAuth -Certificatepath ~/protectedcerts/$($certFilename).pfx -TenantId c8addc00-b475-43dc-b7a7-420e5db30281 -PromptForCertCredential

Get-GraphResource /organization | Select-Object id, displayName, directorySizeQuota

id                                   displayName directorySizeQuota
--                                   ----------- ------------------
c8addc00-b475-43dc-b7a7-420e5db30281 BubbleStar  @{used=1547; total=50000}

This is example is similar to the previous one in that a new application is created and a connection created that can use its client certificate for non-interactive signin. The main difference is that in this case Connect-GraphApi references a certificate file system path rather than looking up a certificate for the application in the local certificate store. This example actually starts with the creation of the file system certificate using the openssl command-line tool before proceeding to use commands from this module to create the new application with New-GraphApplication, configure the certificate credentials with Set-GraphApplicationCertificate, and then use those credentials to create the connection with Connect-GraphApi.

Note that in this case the PromptForCredential parameter of Connect-GraphApi must also be supplied since user interaction to obtain the certificate's password is required.

.EXAMPLE
$appCert = Get-ChildItem Cert:\CurrentUser\my | where FriendlyName -like *UnattendedApp* | Select-Object -First 1
Connect-GraphApi -AppId 02a940be-2aba-47a4-aee9-ae66b9d94021 -Certificate $appCert -NoninteractiveAppOnlyAuth
$allUsers = Get-GraphResource /organization

In this example the Windows certificate store is traversed with Get-GraphChildItem to find the cert for an application based on the certificate's friendly name property and assign it to a variable. The assigned value is actually a .NET object of type [System.Security.Cryptography.X509Certificates.X509Certificate2], and so it be specified as the value of the Certificate parameter of the Connect-GraphApi command to create a connection using that certificate's private key and set the new connection as the current connection. Finally, Get-GraphResource is invoked to issue a GET request using the newly configured current connection's application identity.

.EXAMPLE
Connect-GraphApi -AccountType AzureADAndPersonalMicrosoftAccount -Permissions Contacts.Read
$contacts = Get-GraphResource me/contacts

In this case, Connect-GraphApi is used to sign in to a Microsoft Account such as an outlook.com or live.com account. Connect-GrahApi is invoked with the AccountType parameter specified as AzureADAndPersonalMicrosoftAccount to allow sign-in using a personal Microsoft account; if that account type is not specified, Connect-GraphApi's behavior is to disallow the use of a personal account at sign-in unless the module's default application is in use which is known to be configured to allow personal account sign-ins. The Permissions parameter includes a request for Contacts.Read since that will be required for future commands. After successful sign-in, Get-GraphResource is used to access the personal account and read the signed-in users's contacts.

.EXAMPLE
Connect-GraphApi -AppId c7de6c6e-53c7-4651-92b5-81249d569f24 -ExistingPermissionsOnly

This example illustrates how to enable support for Connect-GraphApi to sign in to a legacy AAD application that does not support requests for new permissions. Such applications are no longer created by AAD APIs but in earlier iterations of AAD applications could only be configurd with static consent. Attempts to request the additional permissions for those applications will fail if any additional permissions are specified, and since Connect-GraphApi always requests User.Read permission for usability reasons on every sign-in, the Connect-GraphApi will fail with this default behavior. To work around this problem, or to avoid granting User.Read to applications used by this module, specify the ExistingPermissionsOnly property. Sign-ins to any applications that require static configuration will succeed with valid credentials, though their ability to succesfully invoke any Graph APIs accessed by subsequent commands using the connection will depend on whether the static permissions are configured to allow the access.

.EXAMPLE
$confidentialApp = New-GraphApplication -Confidential -DelegatedUserPermissions Directory.Read.All -name AdminWorkstationApp -NewCredential
Connect-GraphApi -AppId $newconfdelegated.appId -Confidential
$groups = Get-GraphResource /groups

Connect-GraphAPI is used here to establish a confidential connection, i.e. one that requires a locally available client certificate. When the Confidential paramter is specified, on Windows Connect-GraphApi will search the local certificate store for a certificate with metadata that indicates it can be used to authenticate as the specified AppId when the Certificate and CertificatePath parameters are omitted. This heuristic search does not apply if a path to a certificate in the file system or the Windows certificate store drive is specified through the CertificatePath parameter, or if the Certificate parameter is specified. Successful sign-in also means the current connection is now configured with the requested identity and authorization, so Get-GraphResource uses it in the request to read groups. on of Get-GraphResource. Note that if the Confidential parameter is not specified to Connect-GraphApi, it will fail sign-in since the application in this example requires a client secret and such a secret cannot be accessed by a connection created without specifying the Confidential parameter.

.EXAMPLE
$symmetricKeyCredential = Get-Credential
Connect-GraphApi -AppId addb2b45-e3ca-47ba-a5ab-41c722ba13a1 -Confidential -Secret -Password $symmetricKeyCredential.GetNetworkCredential().SecurePassword -Permissions Application.Read.All
$applications = Get-GraphResource /applications

This example is similar to the previous one in that a connection using delegated permission and a client secret is used to perform an interactive sign-in and access the directory. However, in this case the application is configured to require the submission of a symmetric key rather than verifying the caller's possession of a certificate's private key. The symmetric key is obtained through the Get-Credential command, which prompts the user for a username (which will be ignored) and a password. The user can enter the application's symmetric key through the password field, and an object that enables access to the key will be assigned to the $symmetricKeyCredential variable. Connect-GraphApi can then use the key: along with the Confidential parameter, the Secret parameter must be specified AND the Password parameter must be supplied with the symmetric key. The password parameter must be a [SecureString] type, and that can be obtained $symmetricKeyCredential variable with the expression $symmetricKeyCredential.GetNetworkCredential().SecurePassword. The resulting current connection is then utilized by Get-GraphResource to access the Graph API.

.EXAMPLE
Connect-GraphApi -GraphEndpointUri https://graph.microsoft.com -GraphResourceUri https://graph.microsoft.com -AuthenticationEndpointUri https://login.microsoftonline.com
Get-GraphResource /me

This example shows how to create a customized connection that uses arbitrary URI's to describe the two required endpoints, the Graph API endpoint and the authentication endpoint used for obtaining access tokens. The GraphEndpointUri and AuthenticationEndpointUri parameters respectively specify this configuration. Another parameter, GraphResourceUri, is used to specify the resource for which to request access. Note that in this use case, all three parameters have the default value for the Azure public cloud instance of the Graph API which is what the module users by default. Other values may be used however, which could be useful if you've implemented a proxy for instance for one of the endpoints. Also, in the future if there are new Graph API service or login endpoints, or alternative resource URI's are offered for the Graph API resource, Connect-GraphApi can be used to specify these alternative or proxy endpoints so that commands may communicate to the targeted Graph API service.

.LINK
New-GraphConnection
Get-GraphConnection
Select-GraphProfile
Remove-GraphConnection
Select-GraphConnection
Get-GraphAccessToken
#>
function Connect-GraphApi {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='msgraph')]
    param(
        [parameter(parametersetname='msgraphname', position=0, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [ArgumentCompleter({
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
                               $::.GraphConnection |=> GetNamedConnection | where Name -like "$($wordToComplete)*" | select-object -expandproperty Name
                           })]
        [Alias('Name')]
        [string] $ConnectionName,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='msgraphname')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='autocert')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='current')]
        [String[]] $Permissions = $null,

        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='autocert')]
        [string] $AppId = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='autocert')]
        [Switch] $NoninteractiveAppOnlyAuth,

        [Switch] $ExistingPermissionsOnly,

        [string] $TenantId,

        [parameter(parametersetname='certpath', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [string] $CertificatePath,

        [parameter(parametersetname='certpath')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='certpath')]
        [switch] $NoCertCredential,

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

        [ValidateSet('Auto', 'Default', 'Session', 'Eventual')]
        [string] $ConsistencyLevel = 'Auto',

        [string] $UserAgent = $null,

        [switch] $NoProfile,

        [parameter(parametersetname='reconnect', mandatory=$true)]
        [Switch] $Reconnect,

        [parameter(parametersetname='existingconnection',mandatory=$true)]
        [parameter(parametersetname='noupdatecurrent',mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [parameter(parametersetname='noupdatecurrent',mandatory=$true)]
        [switch] $NoSetCurrentConnection,

        [Switch] $PromptForCertCredential,

        [parameter(parametersetname='currentconnection',mandatory=$true)]
        [switch] $Current
    )

    begin {
    }

    process {
        Enable-ScriptClassVerbosePreference

        if ( $Permissions -and $ExistingPermissionsOnly.IsPresent ) {
            throw [ArgumentException]::new("The 'ExistingPermissionsOnly' and 'Permissions' parameters may not both be specified ")
        }

        if ( $CertificatePath ) {
            $existingCert = get-item $certificatePath -erroraction ignore

            if ( ! $existingCert ) {
                throw [ArgumentException]::new("The specified certificate path '$CertificatePath' is not accessible. Correct the path and retry the command")
            }

            if ( $existingCert -isnot [System.Security.Cryptography.X509Certificates.X509certificate2] ) {
                if ( ! $NoCertCredential.IsPresent -and ! $CertCredential -and ! $PromptForCertCredential.IsPresent ) {
                    throw [ArgumentException]::new("One of the CertCredential, NoCertCredential, or PromptForCertCredential parameters must be specified because a file system path '$CertificatePath' was specified with the CertificatePath parameter. Alternatively, a path to a certificate in the PowerShell certificate drive may be specified if the certificate drive is supported on this platform.")
                }
            }
        }

        $validatedCloud = if ( $Cloud ) {
            [GraphCloud] $Cloud
        } else {
            ([GraphCloud]::Public)
        }

        # PS language note: comparison against null only works
        # in the general case if the variable is on the right hand side of
        # the comparison operator. Specifically the expression
        # @() -ne $null actually evaluates to @(), i.e. an empty array,
        # rather than the expected value of $true, stating that an
        # empty array of type [object[]] is not equal to $null which
        # has no type. Placing the $null on the LHS and variable on RHS
        # restores the expected behavior.
        $normalizedPermissions = if ( $null -ne $Permissions ) {
            # If they explicitly specify @() for $Permissions, we want to honor
            # this by not requesting any permissions at all
            $Permissions
        } elseif ( ! $ExistingPermissionsOnly.IsPresent ) {
            # They did not specify permissions at all, whether empty or non-empty,
            # and they did not specify the 'ExistingPermissionsOnly' parameter,
            # so as a user experience enhancement, we'll ask for 'User.Read' in case
            # they don't already have it, which ensures that the basic scenario of
            # '/me' requests are functional and avoids user confusion when newly
            # created apps seem to "fail" for what many users would view as the
            # "Hello World" scenario for a graph request.
            @('User.Read')
        }

        $context = $::.GraphContext |=> GetCurrent

        if ( ! $context -and ! $NoSetCurrentConnection.IsPresent ) {
            throw "No current session -- unable to connect it to Graph"
        }

        $targetConnection = if ( $connection ) {
            $connection
        } elseif ( $ConnectionName ) {
            $::.GraphConnection |=> GetNamedConnection $ConnectionName $true
        } elseif ( $Current.IsPresent -and $context.Connection ) {
            $context.Connection
        }

        if ( $targetConnection ) {
            write-verbose "Explicit connection was specified"

            if ( ! $NoSetCurrentConnection.IsPresent ) {
                $newContext = $::.LogicalGraphManager |=> Get |=> NewContext $context $targetConnection
                $::.GraphContext |=> SetCurrentByName $newContext.name
            }

            $certificatePassword = $::.CertificateHelper |=> GetConnectionCertCredential $targetConnection $CertCredential $PromptForCertCredential.IsPresent $NoCertCredential.IsPresent

            $targetConnection |=> Connect $certificatePassword

            $targetConnection
        } else {
            write-verbose "Connecting context '$($context.name)'"
            $applicationId = if ( $AppId ) {
                [Guid] $AppId
            } else {
                $::.Application.DefaultAppId
            }

            $newConnection = if ( $Reconnect.IsPresent ) {
                write-verbose 'Reconnecting using the existing connection if it exists'
                if ( $Permissions -and $context.connection -and $context.connection.identity ) {
                    write-verbose 'Creating connection from existing connection but with new permissions'
                    $identity = new-so GraphIdentity $context.connection.identity.app $context.connection.graphEndpoint $context.connection.identity.tenantname
                    new-so GraphConnection $context.connection.graphEndpoint $identity $::.ScopeHelper.DefaultScope $NoBrowserSigninUI.IsPresent
                } else {
                    write-verbose 'Just reconnecting the existing connection'
                    $context.connection
                }
            } else {
                write-verbose 'No reconnect -- creating a new connection for this context'

                # Get the arguments from the profile -- these will be overridden by
                # any parameters specified to this command
                $currentProfile = if ( ! $NoProfile.IsPresent ) {
                    $::.LocalProfile |=> GetCurrentProfile
                }

                $conditionalArguments = if ( $currentProfile ) {
                    $currentProfile |=> ToConnectionParameters
                } else {
                    @{}
                }

                # Configure parameters compatible with forwarding to the underlying command
                $PSBoundParameters.keys | where { $_ -notin @(
                                                      'CertCredential'
                                                      'Connect'
                                                      'ConnectionName'
                                                      'ErrorAction'
                                                      'ExistingPermissionsOnly'
                                                      'NoCertCredential'
                                                      'NoProfile'
                                                      'PromptForCertCredential'
                                                      'Reconnect'
                                                  ) } | foreach {
                    $conditionalArguments[$_] = $PSBoundParameters[$_]
                    $conditionalArguments['Permissions'] = $normalizedPermissions
                }

                try {
                    new-graphconnection @conditionalArguments -erroraction stop
                } catch {
                    throw
                }
            }

            $certificatePassword = $::.CertificateHelper |=> GetConnectionCertCredential $newConnection $CertCredential $PromptForCertCredential.IsPresent $NoCertCredential.IsPresent

            $context |=> UpdateConnection $newConnection $certificatePassword
            $newConnection
        }
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Connect-GraphApi Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))
