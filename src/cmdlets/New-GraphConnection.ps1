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

Note that while New-GraphConnection creates a new object and returns it as output, it has no side effects, i.e. it does not perform any authentication operations or change local state such as the current connection. This makes it useful for automating the management of connections and providing a way to maintain multiple credentials with different levels of access to the Graph API, different AAD organizations, or even issue requests to Graph API endpoints from more than one cloud.

The parameters of New-GraphConnection can be grouped into the following categories:

    * Authorization: New-GraphConnection's parameters allow you to target a specific AAD organization using a particular AAD application with specific permissions (e.g. read permissions for AAD and write permissions for e-mail).
    * Client credentials: You can specify parameters that control where to find any secrets that may be required to authenticate the application, incuding certificates in some locally accessible confidential store or a symmetric key.
    * Request routing: Graph API requests must be issued against some REST API URI -- typically this is https://graph.microsoft.com for public cloud organizations. But there are other Graph API endpoints such as that for the Azure China Cloud, and for testing purposes you may even want to specify a URI that you control as a "proxy" for validating or logging Graph API requests. Requests for access tokens must also be directed to a REST URI that is trusted by the Graph API endpoint as a token issuer, so such token acquisition endpoints may be specified as part of request routing.
    * Request behavior: Behaviors include whether to specify a preference to the API for "eventual" vs. "session" consistency along with an override for the user agent header that should be used in every request, and whether to enable management of the connection through a human readable "Name" property.

By default, this module uses a connection that signs in with a specific 'AutoGraphPS' multi-tenant application with identifier ac70e3e2-a821-4d19-839c-b8af4515254b that is registered as a native public client application. When using New-GraphConnection, you can specify the AppId parameter to provide an application identifier of your choice to override the default application.

.PARAMETER Permissions
Specifies that the connection created by New-GraphConnection requires certain delegated permissions when it is used to sign-in interactively for accesss to the Graph API. By default when this parameter is not specified, commands that request access will not ask for permissions beyond those that have already been delegated to the connection's AAD application identity for the user who signs in. If these permissions are not sufficient for successful access to the particular APIs you intend to access using this module's commands through this connection, specify the Permissions parameter to request the additional required permissions at sign-in.

.PARAMETER AppId
The AAD application identifier to be used by the connection. If the AppId parameter is not specified, the application identifier specified in the connection settings of the current Graph profile is used. If no such profile configuration setting exists, the default identifier for the "AutoGraphPS" application will be used that supports only delegated authentication.

.PARAMETER TenantId
The organization (tenant) identifier of the organization to be accessed by the connection. The identifier can be specified using either the tenant's domain name (e.g. funkadelic.org) or it's unique identifier guid. This parameter is only required when the for application-only sign-in, but may be optionally specified for delegated sign-in to ensure that when using a multi-tenant application limit sign-in to the specified tenant. Otherwise, the tenant for sign-in will be determined as part of the user's interaction with the token endpoint.

.PARAMETER CertificatePath
Specifies the path in the file system or in the PowerShell cert: drive provider of a certificate with a private key to authenticate the application to the Graph API. This parameter is only valid if the Confidential parameter is specified.

.PARAMETER Certificate
Specifies a .NET X509Certificate2 certificate object that contains a private key to authenticate the application to the Graph API. Such an object may be obtained by using Get-Item on an item in the PowerShell cert: drive or from other software or commands that expose certificates using this structure. This parameter is only valid if the Confidential parameter is specified.

.PARAMETER Confidential
Specify this parameter if the connection's AAD application requires a client secret in order to successfully authenticate to the Graph API. When this parameter is specified, the actual client secret is specified using other parameters.

.PARAMETER Secret
Specify this when the Confidential parameter is specified and the secret to be used is a symmetric key rather than a certificate. Symmetric keys are more difficult to secure than certificates and should not be used in production environments.

.PARAMETER Password
When the Secret parameter is specified, specify the Password parameter as a SecureString to supply the symmetric key. Commands such as Get-Credential may be used to obtain the key and represent it as a SecureString.

.PARAMETER Cloud
Specifies the cloud to which requests that use the resulting connection should be sent. Both the Graph API endpoint and sign-in endpoints are determined by the cloud specified by this parameter. If this parameter is not specified, the Azure Public cloud endpoints for Graph and sign-in are used. Other supported clouds include the Azure China cloud and Azure Germany clouds.

.PARAMETER AppRedirectUri
Specifies the OAuth2 protocol redirect URI (also known as reply url) to be used during any sign-ins required by this connection. Since this module's default application identifier is registered as a native, public client application, the default for the AppRedirectUri parameter is http://localhost. If the application specified by the AppId or by the profile settings is not configured to include http://localhost in its list of allowed redirect URI's, then the AppRedirectUri must be specified to New-GraphConnection for subsequent sign-ins using this created connection to be successful.

.PARAMETER NoBrowserSigninUI
Specifies that this connection must not rely on a web browser for any interactive sign-in flows -- by default, interactive sign-in flows will use a web browser on the local system.

.PARAMETER GraphEndpointUri
Specifies the Graph API endpoint. If this is not specified and the Cloud parameter is not specified, the default is https://graph.microsoft.com.

.PARAMETER AuthenticationEndpointUri
Specifies the sign-in (login) endpoint. If this is not specified and the Cloud parameter is not specified, the default is https://login.microsoftonline.com.

.PARAMETER GraphResourceUri
Specifies the Graph API OAuth2 protocol resource for which to request access. If this is not specified and the Cloud parameter is not specified, the default is https://graph.microsoft.com.

.PARAMETER AccountType
Specifies what kind of account to use when signing in to the application for Graph API access. This can be AzureADOnly, in which case the conneciton will only support signing in to an AAD organization. If it is 'AzureADAndPersonalMicrosoftAccount', then the connection may be used to sign in to either an AAD organization or a personal Microsoft Account such as an outlook.com account. The default setting is 'Auto', which is the same as 'AzureADAndPersonalMicrosoftAccount' when the default AutoGraphPS application is used; otherwise it is AzureADOnly.

.PARAMETER Name
Specifies the unique friendly name to use for this connection. By default, the GraphConnection object returned by New-GraphConnection has a unique guid identifier but no friendly name. By specifing a name, the connection may also be specified using the name to commands such as Connect-GraphAPI or Get-GraphConnection, and the connection will also show up in a list of named connections that makes it easy to maintain a set of useful connections that may be used as needed within the PowerShell session.

.PARAMETER ConsistencyLevel
Specify this parameter so that Graph API requests made using this connection use specific consistency semantics for APIs that support them. The Graph API supports Session and Eventual semantics, and those names may be specified for this parameter to achieve their behaviors. Currently the Graph API defaults to Session semantics, but some Graph APIs support the Eventual consistency which provides advanced query capabilities not present with Session semantics.

The default value for the ConsistencyLevel parameter is 'Auto', which means that consistency semantics are taken from the current Graph settings profile if the ConsistencyLevel property is specified there.

You may also specify 'Default', which means that API requests do not specify consistency semantics, in which case the consistency semantics are completely dependent upon the particular API's default behavior -- consult the documentation for that API for details.

For more information about the advanced queries capable using the Eventual consistency level, see the Graph API advanced query documentation: https://docs.microsoft.com/en-us/graph/aad-advanced-queries. For more information on the tradeoffs for the Eventual consistency level, see the command documentation for the Invoke-GraphApi command in this module.

.PARAMETER AADGraph
Deprecated.

.PARAMETER UserAgent
Specifies the HTTP 'User-Agent' request header value to use for every request to the Graph API. By default, the module uses its own specific user agent string for this header on every request. To override that default value, specify a new value using the UserAgent parameter.

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

Invoke New-GraphConnection with no parameters to create a new connection with default properties. Here the connection is assigned to a variable so the connection can be used as a parameter to subsequent commands, and it is also output to the console for visual inspection. If no profile settings configuration overrides these defaults, then the connection will have the properties shown in this example. These defaults include Endpoint and AuthEndpoint properties that target the Azure public cloud Graph API service instance and the use of user delegated authentication at sign-in which requires the user to sign in. The Id property is a read-only value assigned automatically by New-GraphConnection and used by the moduel's internal connection management. The Connected property is true when a successful sign-in has occurred for the connection and it can then be used to make requests to Graph. The AllowMSA output indicates that the Connection allows sign-in using a Microsoft Account, and not just an AAD account. In general, many of the property names for the Connection object correspond to parameter names for New-GraphConnection, so consulting the parameter documentation of the command provides information about the default values for these properties.

.EXAMPLE
$mailConnection = New-GraphConnection -Permissions Mail.ReadWrite -AppId c2711e92-9f7b-4553-b2df-5ce15ac613e4
Get-GraphResource me/messages -Connection $mailConnection -First 1 |
    Select-Object @{label='From';expression={$_.from.emailAddress.address}}, receivedDateTime, subject

From              receivedDateTime     subject
----              ----------------     -------
news@defender.org 2021-10-06T05:27:00Z Support local journalism!

In this example, New-GraphConnection is used to create a connection for accessing email by specifying a dedicated AAD application through the AppId parameter as well as requesting permisions for mail access via the Permissions parameter. The output of the command is then assigned to the $mailConneciton variable. The connection variable is then specified as the Connection parameter for Get-GraphResource, which uses that connection instead of the module's current connection to make a Graph API request to read mail messages. While the invocation of Get-GraphResource will trigger an interactive sign-in when the profile specifies a delegated sign-in (the module's default behavior), any subsequent command invocations for which the variable is specified through the Connection parameter will require no interaction. This manner of using New-GraphConnection and the common Connection parameter makes it easy to maintain a "default".

Note that it is not at all necessary to use a different AAD application when new permissions are required, but it can be useful if you have a desired to limit the permissions consented to the default application used with the module or in cases where AAD policies actually enforce such restrictions by denying ability to consent additional permissions to the default application.

Finally, the Permissions parameter only needs to be specified if the application does not already have consent for the permission. If you've signed using the application in the past and granted the permission, AAD remembers the grant and you do not need to request it again for that application unless you or an administrators revokes the permission.

.EXAMPLE
New-GraphConnection -Name MailConnection -Permissions Mail.ReadWrite -AppId c2711e92-9f7b-4553-b2df-5ce15ac613e4

AppId                                ConnectionName Organization AuthType
-----                                -------------- ------------ --------
ac70e3e2-a821-4d19-839c-b8af4515254b MailConnection              Delegated

Connect-GraphApi MailConnection
$messages = Get-GraphResource me/messages

This use case for creating an alternate "mail" connection is the same as that of the previous example, but here the Name parameter of New-GraphConnection is used to assign a name to the connection. The name may then be specified to commands like Connect-GraphApi that accept connection names to identify connections just like other commands accept actual connection objects. Use of Connect-GraphApi will initiate a sign-in and set the current connection to the named connection "MailConnection". Subsequent commands will use this connection by default so that the Connection parameter is not needed to use the new connection as in the invocation of Get-GraphResource in this example. The assignment of names to connections and ability to use those names with Connect-GraphApi and Select-GraphConnection makes it convenient to use different connections at different times without the need to explicitly pass the Connection parameter to every single command invocation.

.EXAMPLE
$appConnection = New-GraphConnection -AppId 43b49b9c-e886-451d-9686-c5d73bdd3d25 -AppRedirectUri https://devops.mothership.org

This example shows how New-GraphConnection allows the module to override the default application redirect URI (also known as reply URL) that it sibumits during sign-in. When the connection is used for sign-in, the connection's AppRedirectUri property must match one of the application's configured redirect URI's or authentication will fail. By default, the module's sign-in functionality uses 'http://localhost' for the redirect URI. If that URI is not configured for the application, you must specify the AppRedirectUri parameter when using New-GraphConnection for that application so that sign-in can be successful

.EXAMPLE
$china = New-GraphConnection -Cloud ChinaCloud -AppId 1d4df069-3bc5-4730-bb56-3d4a6c414b91

This example demonstrates the creation of a connection to the Microsoft Graph API endpoint in the Azure China cloud. Note that in the China cloud specifically the module's default application identifier may not be valid, so the application of an application created by some user in the organization or available in some China cloud tenant is used. You may need to create a new application in a China cloud Azure subscription through the Azure portal or other tools so that you can specify that application's identifier to this command.

.EXAMPLE
$newApp = New-GraphApplication -Name "OrgMonitor" -ApplicationPermissions Organization.Read.All -NewCredential
$newCon = New-GraphConnection -AppId $newApp.appId -NoninteractiveAppOnlyAuth -TenantId c8addc00-b475-43dc-b7a7-420e5db30281
Get-GraphResource /organization -Connection $newCon | Select-Object id, displayName, directorySizeQuota

id                                   displayName directorySizeQuota
--                                   ----------- ------------------
c8addc00-b475-43dc-b7a7-420e5db30281 BubbleStar  @{used=1547; total=50000}

In this example a new application is created with New-GraphApplication with permissions to read the tenant's organization object and a client credential in the local certificate store. Then New-GraphConnection is used to create a connection that implicitly uses the application's client credential from the certificate store to enable application-only sign-in with no user interaction required. Finally, the newly created connection is specified for the Connection parameter for the Get-GraphResource command  to make a request to the Graph API to read the organization object. The response output is piped to the Select-Object to display the id, displayName, and directorySizeQuota properties of the organization. This entire sequence of commands requires no sign-in and can run as part of an automated script -- provided of course that some connection to the desired organization is already established before running the first command.

.EXAMPLE
$certFileName=OrgMonClientCertFile

# Use openssl to create a cert -- this works Linux and Windows and any other platforms supported by the openssl tools
openssl req -newkey rsa:4096 -x509 -days 365 -keyout ~/protectedcerts/$($certFileName)-pri.key -out ~/protectedcerts/$($certFileName)-pub.crt -subj '/CN=OrgMon/CN=Internal/CN=BubbleStar'
openssl pkcs12 -export -inkey ~/protectedcerts/$($certFilename)-pri.key -in ~/protectedcerts/$($certFilename)-pub.crt -out ~/protectedcerts/$($certFilename).pfx

$orgMonApp = New-GraphApplication -Name OrgMon -ApplicationPermissions Organization.Read.All
$orgMonApp | Set-GraphApplicationCertificate -CertificatePath ~/protectedcerts/$($certFilename).pfx -PromptForCertCredential

$newCon = New-GraphConnection -Name OrgMonAccess -AppId $OrgMonApp.AppId -NoninteractiveAppOnlyAuth -Certificatepath ~/protectedcerts/$($certFilename).pfx -TenantId c8addc00-b475-43dc-b7a7-420e5db30281
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
$contacts = Get-GraphResource me/contacts
Connect-GraphApi Work

In this case, Connect-GraphApi is used to switch between named "work" and "personal" connections. First, New-GraphConnection is used with the AccountType parameter specified as AzureADAndPersonalMicrosoftAccount to allow sign-in using a personal Microsoft account; if that account type is not specified, Connect-GraphApi's behavior is to disallow the use of a personal account at sign-in unless the module's default application is in use which is known to be configured to allow personal account sign-ins. Once the named connection "personal" is created, Connect-GraphApi is invoked with "personal" for the name parameter to set the current connection. At ths point commands like Get-GraphResource may be used to access the personal account. In this example there is also a named connection called "work," and the user issues another invocation of Connect-GraphApi can then switch the current connection to the named "work" connection.

.EXAMPLE
$confidentialApp = New-GraphApplication -Confidential -DelegatedUserPermissions Directory.Read.All -name AdminWorkstationApp -NewCredential
$confidentialConnection = New-GraphConnection -appid $newconfdelegated.appId -Confidential
$groups = Get-GraphResource /groups -Connection $confidentialConnection

New-GraphConnection is used here to establish a confidential connection, i.e. one that requires a locally available client certificate. When the Confidential paramter is specified, on Windows New-GraphConnection will search the local certificate store for a certificate with metadata that indicates it can be used to authenticate as the specified AppId when the Certificate and CertificatePath parameters are omitted. This heuristic search does not occur if a path to a certificate in the file system or the Windows certificate store drive is specified through the CertificatePath parameter, or if the Certificate parameter is specified. The connection is specified by the Connection parameter to an invocation of Get-GraphResource. Note that if the Confidential parameter is not specified to New-GraphConnection, it will succeed, but the use of the connection by Get-GraphResource will fail since the application in this example requires a client secret and such a secret cannot be accessed by a conection created without specifying the Confidential parameter.

.EXAMPLE
$symmetricKeyCredential = Get-Credential
$confidentialConnection = New-GraphConnection -AppId addb2b45-e3ca-47ba-a5ab-41c722ba13a1 -Confidential -Secret -Password $symmetricKeyCredential.GetNetworkCredential().SecurePassword -Permissions Application.Read.All
$applications = Get-GraphResource /applications -Connection $confidentialConnection

This example is similar to the previous one in that a connection using delegated permission and a client secret is used to perform an interactive sign-in and access the directory. However, in this case the application is configured to to require the submission of a symmetric key rather than verifying the caller's possession of a certificate's private key. The symmetric key is obtained through the Get-Credential command, which prompts the user for a username (which will be ignored) and a password. The user can enter the application's symmetric key through the password field, and an object that enables access to the key will be assigned to the $symmetricKeyCredential variable. New-GraphConnection can then use the key: along with the Confidential parameter, the Secret parameter must be specified AND the Password parameter must be supplied with the symmetric key. The password parameter must be a [SecureString] type, and that can be obtained $symmetricKeyCredential variable with the expression $symmetricKeyCredential.GetNetworkCredential().SecurePassword. The resulting connection may be specified to Get-GraphResource to access the Graph API.

.EXAMPLE
$graphConnection = New-GraphConnection -GraphEndpointUri https://graph.microsoft.com -GraphResourceUri https://graph.microsoft.com -AuthenticationEndpointUri https://login.microsoftonline.com
Get-GraphResource /me -Connection $graphConnection

This example shows how to create a customized connection that uses arbitrary URI's to describe the two required endpoints, the Graph API endpoint and the authentication endpoint used for obtaining access tokens. The GraphEndpointUri and AuthenticationEndpointUri parameters respectively specify this configuration. Another parameter, GraphResourceUri, is used to specify the resource for which to request access. Note that in this use case, all three parameters have the default value for the Azure public cloud instance of the Graph API which is what the module users by default. Other values may be used however, which could be useful if you've implemented a proxy for instance for one of the endpoints. Also, in the future if there are new Graph API service or login endpoints, or alternative resource URI's are offered for the Graph API resource, New-GraphConnection can be used to specify these alternative or proxy endpoints so that commands may communicate to the targeted Graph API service.

.LINK
Connect-GraphApi
Get-GraphConnection
Select-GraphProfile
Remove-GraphConnection
Select-GraphConnection
Get-GraphToken
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
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='customendpoint')]
        [ValidateSet('Default', 'v1', 'v2')]
        [string] $AuthProtocol = 'Default',

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='customendpoint')]
        [ValidateSet('Auto', 'AzureADOnly', 'AzureADAndPersonalMicrosoftAccount')]
        [string] $AccountType = 'Auto',

        [string] $Name = $null,

        [ValidateSet('Auto', 'Default', 'Session', 'Eventual')]
        [string] $ConsistencyLevel = 'Auto',

        [parameter(parametersetname='aadgraph', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [switch] $AADGraph,

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

        $graphType = if ( $AADGraph.ispresent ) {
            ([GraphType]::AADGraph)
        } else {
            ([GraphType]::MSGraph)
        }

        $specifiedAuthProtocol = if ( $AuthProtocol -ne ([GraphAuthProtocol]::Default) ) {
            $AuthProtocol
        }

        $specifiedScopes = if ( $Permissions ) {
            if ( $Secret.IsPresent -or $Certificate -or $CertificatePath ) {
                throw 'Permissions may not be specified at runtime for app-only authentication since they originate from the static application configuration'
            }
            $Permissions
        }

        $computedAuthProtocol = $::.GraphEndpoint |=> GetAuthProtocol $AuthProtocol $validatedCloud $GraphType

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

        if ( $GraphEndpointUri -eq $null -and $AuthenticationEndpointUri -eq $null -and $specifiedAuthProtocol -and $appId -eq $null ) {
            write-verbose 'Simple connection specified with no custom uri, auth protocol, or app id'
            $::.GraphConnection |=> NewSimpleConnection $graphType $validatedCloud $specifiedScopes $false $TenantId $computedAuthProtocol -useragent $UserAgent -allowMSA $allowMSA $ConsistencyLevel
        } else {
            $graphEndpoint = if ( $GraphEndpointUri -eq $null ) {
                write-verbose 'Custom endpoint data required, no graph endpoint URI was specified, using URI based on cloud'
                write-verbose ("Creating endpoint with cloud '{0}', auth protocol '{1}'" -f $validatedCloud, $computedAuthProtocol)
                new-so GraphEndpoint $validatedCloud $graphType $null $null $computedAuthProtocol $GraphResourceUri
            } else {
                write-verbose ("Custom endpoint data required and graph endpoint URI was specified, using specified endpoint URI and auth protocol {0}'" -f $computedAuthProtocol)
                new-so GraphEndpoint ([GraphCloud]::Custom) ([GraphType]::MSGraph) $GraphEndpointUri $AuthenticationEndpointUri $computedAuthProtocol $GraphResourceUri
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
            new-so GraphConnection $graphEndpoint $identity $specifiedScopes $NoBrowserSigninUI.IsPresent $userAgent $Name $ConsistencyLevel
        }
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphConnection Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))
