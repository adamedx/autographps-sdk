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

. (import-script New-GraphConnection)
. (import-script Connect-GraphApi)

<#
.SYNOPSIS
Gets an access token from the authentication / authorization service endpoint that may be used to access the Graph API.

.DESCRIPTION
Get-GraphToken performs an application sign-in to obtain an access token for the Microsoft Graph API. The token may be used in the authorization header to make a request to the Graph API.

The Get-GraphToken command is useful when there is a need to utilize Graph API tools other than the commands in this module. For example, if you use a REST debugging tool with the Graph API you'll need an access token in order to make requests using that debugger. Use Get-GraphToken to obtain the access token for use with these and other tools.

The command is very much similar to the Connect-GraphApi command in that they share mostly the same parameters and they both result in a sign-in. The difference is that Get-GraphToken intentionally exposes the access token, while Connect-GraphApi abstracts it in the connection object and manages its lifetime.

.PARAMETER Permissions
Specifies that the access token returned by the command requires certain delegated permissions. By default when this parameter is not specified, the granted token will have whatever permissions were previously requested.

.PARAMETER AppId
The AAD application identifier to be associated with the granted access token. If the AppId parameter is not specified, the default identifier for the "AutoGraphPS" application will be used that supports only delegated authentication.

.PARAMETER TenantId
The organization (tenant) identifier of the organization for which access must be granted. The identifier can be specified using either the tenant's domain name (e.g. funkadelic.org) or it's unique identifier guid. This parameter is only required for application-only sign-in, but may be optionally specified for delegated sign-in to ensure that when using a multi-tenant application limit sign-in to the specified tenant. Otherwise, the tenant for sign-in will be determined as part of the user's interaction with the token endpoint.

.PARAMETER NoninteractiveAppOnlyAuth
By default, access tokens returned by Get-GraphToken require sign in using an interactive, delegated flow that requires the credentials of a user and therefore also requires user interaction. Specify NoninteractiveAppOnlyAuth to override this behavior and sign-in without user credentials, just application credentials. Such credentials can be specified in the form of certificates or symmetric keys using other parameters of this command. Because such a sign-in does not involve user credentials, no user interaction is required and this sign-in is most useful for unattended execution such as scheduled or triggered automation / batch jobs.

If no parameters are used to specify the application credentials, then on Windows, if no secret is specified, Get-GraphToken will search the certificate store for a certificate that can be used as the credential. If you're not running this command on Windows, or if the command cannot find a certificate for the appplication or if more than one certificate is found to be a possible match, you must specify the credentials using one of the certificate or secret parameters of this command.

.PARAMETER ExistingPermissionsOnly
By default, Get-GraphToken always requests the permission User.Read at sign-in because it provides a minimal but useful amount of access to Graph API resources that help users maintain awareness of what identity they used for signing in. However the permission is not strictly necessary so to avoid the need to consent to that permission, and in particular to ensure that legacy AAD applications that support only static request and fail any sign-ins where additional permissions are requested, specify this parameter.

.PARAMETER CertificatePath
Specifies the path in the file system or in the PowerShell cert: drive provider of a certificate with a private key to authenticate the application to the Graph API. This parameter is only valid if the Confidential parameter is specified.

.PARAMETER Certificate
Specifies a .NET X509Certificate2 certificate object that contains a private key to authenticate the application to the Graph API. Such an object may be obtained by using Get-Item on an item in the PowerShell cert: drive or from other software or commands that expose certificates using this structure. This parameter is only valid if the Confidential parameter is specified.

.PARAMETER Confidential
Specify this parameter if the AAD application specified by the AppId parmaeter requires a client secret in order to successfully authenticate to the Graph API. When this parameter is specified, the actual client secret is specified using other parameters. If no parameters are used to specify the secret, then on Windows, if no secret is specified, the command will search the certificate store for a certificate that can be used as the credential. If you're not running this command on Windows, or if the command scannot find a certificate for the appplication or if more than one certificate is found to be a possible match, you must specify the credentials using one of the certificate or secret parameters of this command.

.PARAMETER Secret
Specify this when the Confidential parameter is specified and the secret to be used is a symmetric key rather than a certificate. Symmetric keys are more difficult to secure than certificates and should not be used in production environments.

.PARAMETER Password
When the Secret parameter is specified, specify the Password parameter as a SecureString to supply the symmetric key. Commands such as Get-Credential may be used to obtain the key and represent it as a SecureString.

.PARAMETER Cloud
Specifies the cloud for which an access token to that clouds Graph API service endpoint must be returned. Both the Graph API endpoint and sign-in endpoints are determined by the cloud specified by this parameter. If this parameter is not specified, the Azure Public cloud endpoints for Graph and sign-in are used. Other supported clouds include the Azure China cloud and Azure Germany clouds.

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

.PARAMETER PromptForCertCredential
Specifies that the command should request secure user input to obtain a credential for reading a certificate specified by other parameters of this command or required by an existing connection in order to authenticate at sign-in. This is only needed when the certificate is protected by a password credential for instance.

.PARAMETER RefreshFromConnection
Given an exisitng connection such as one created by the New-GraphConnection or Connect-GraphApi commands or returned by connection management commands such as Get-GraphConnection, the Connection parameter instructs Connect-GraphApi not to create a new connection -- it simply signs in to the connection supplied as to Connection parameter and then sets it to be the current connection. This is useful if the connection was created by a command like New-GraphConnection since that command does not perform sign-in. A use case may be to create a group of connection objects with different application identities or connections to different Graph API instances; the invocations of New-GraphConnection can be done as a group without noticeable user interaction because they do not involve sign-in, and sign-in to any particular connection can be deferred until the user actually needs it, as opposed to requiring up front sign-in of multiple connections even if only one of themis used.

.PARAMETER Current
Specify this parameter to sign in to the current connection instead of creating a new one. This is useful when making use of connections created by New-GraphConnection as it allows complete control over when sign-in occurs.

.OUTPUTS
If the AsObject parameter is not specified, the command returns an access token as a string data type. This string value may be set as the Authorization header value for a request to the Graph API. If AsObject is specified, a token object is returned instead. The type of this object depends on the underlying authentication library used by the module. Currently the library is Microsoft Authentication Library (https://github.com/AzureAD/microsoft-authentication-library-for-dotnet) and the type it returns is Microsoft.Identity.Client.Authenticationresult. More details on that type can be found here: https://docs.microsoft.com/en-us/dotnet/api/microsoft.identity.client.authenticationresult?view=azure-dotnet.

.EXAMPLE
$accessToken = Get-GraphToken -Permissions Organization.Read

Invoke-WebRequest -UseBasicParsing https://graph.microsoft.com/v1.0/organization -Headers @{
    Authorization=$accesToken;'Content-Type'='application/json' } |
    Select-Object -ExpandProperty Content | ConvertFrom-Json |
    Select-Object -ExpandProperty Value | Select-Object id, displayName, createdDateTime

id                                   displayName  createdDateTime
--                                   -----------  ---------------
7632788a-8d81-46ef-85b4-1a9f7ab373fb Cabbage Corp 2012-08-08T00:23:26Z

This example uses Get-GraphToken to obtain an access token with the Organization.Read permission and stores the result in a variable. Then the variable is used to specify the access token as the Authorization header value for an HTTP request to the Graph API issued by the Invoke-WebRequest command. The JSON output of the resulting response from the Graph API is deserialized and specific fields are projected as output.

.EXAMPLE
$accessToken = Get-GraphToken -AppId 35b1a30e-b109-4f45-b1e9-4442da9579b5

In this example an access token is obtained for a specific application id

.EXAMPLE
$currentAccessToken = Get-GraphToken -Current

Here Get-GraphToken is used to obtain the access token of the current connection. If the current connection has already signed in, then this command is non-interactive; the current token is refreshed if it is near expiration but does not require a sign-in. This is useful when integrating commands from this module with another application as a way of ensuring the module and that application share the same authentication context.

.EXAMPLE
$connection = Connect-GraphApi

while ( $true ) {
    $refreshedToken = Get-GraphToken -RefreshFromConnection $connection
    Invoke-WebRequest -UseBasicParsing 'https://graph.microsoft.com/v1.0/users/$count' -Headers @{
        Authorization=$token;'Content-Type'='application/json';'ConsistencyLevel'='Eventual'} |
        Select-Object -ExpandProperty Content
    Start-Sleep -Seconds 3600
}

This example executes an infinitely repeating loop to get the count of users in the organization using Invoke-WebRequest instead of using more convenient commands from this module. At the beginning of the loop, Get-GraphToken is used to obtain a token which it refreshes if needed. If the access token were obtained outside the loop, the invocation of Invoke-WebRequest would eventually fail once the token expired. Invoke-WebRequest is used here only to demonstrate that any tool that makes requests to the Graph API and accepts a token as an input value for the request can be utilized in this way.

.LINK
Connect-GraphApi
New-GraphConnection
#>
function Get-GraphToken {
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

        [parameter(parametersetname='certpath', mandatory=$true)]
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
        [Uri] $AuthenticationEndpointUri = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $GraphResourceUri = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='customendpoint')]
        [ValidateSet('Auto', 'AzureADOnly', 'AzureADAndPersonalMicrosoftAccount')]
        [string] $AccountType = 'Auto',

        [Switch] $PromptForCertCredential,

        [parameter(parametersetname='current')]
        [Switch] $Current,

        [parameter(parametersetname='existingconnection', mandatory=$true)]
        $RefreshFromConnection,

        [Switch] $AsObject
    )
    Enable-ScriptClassVerbosePreference

    $connectionArguments = @{}

    $psboundparameters.keys | where { $psboundparameters[$_] -and @('AsObject', 'ErrorAction', 'RefreshFromConnection' ) -notcontains $_ } | foreach {
        $connectionArguments[$_] = $psboundparameters[$_]
    }

    $targetConnection = if ( $Current.IsPresent ) {
        Connect-GraphApi -Current
    } elseif ( $RefreshFromConnection ) {
        Connect-GraphApi -Connection $RefreshFromConnection
    } else {
        $newConnection = New-GraphConnection @connectionArguments
        Connect-GraphApi -Connection $newConnection -NoProfile -NoSetCurrentConnection
    }

    $tokenObject = $targetConnection.Identity.Token
    if ( $AsObject.IsPresent ) {
        $tokenObject
    } else {
        $tokenObject.AccessToken
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Get-GraphToken Permissions (new-so PermissionParameterCompleter DelegatedPermission)

