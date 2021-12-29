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

. (import-script ../graphservice/ApplicationAPI)
. (import-script ../graphservice/ApplicationObject)
. (import-script ../common/GraphApplicationCertificate)
. (import-script common/PermissionParameterCompleter)
. (import-script common/CommandContext)

<#
.SYNOPSIS
Creates a new Azure Active Directory (AAD) application in the organization.

.DESCRIPTION
To access Graph API resources (or even other APIs), an Azure Active Directory (AAD) application identity is required. The New-GraphApplication command creates an AAD application identity ("application" or "app"). The application is "homed" or owned by the AAD organization ("tenant") in which it is created, and its usage can be scoped to access resources within just that organization or for any organization (and even Microsoft Account resources such as Graph API resources not associated with any organization).

In addition to creating the identity, New-GraphApplication can also perform the following configuration operations for the newly created application:
* Configuraiton of application credentials: for "confidential client" applications that require a secret, the New-GraphApplication command can create a credential which will then be configured for use as the application's secret.
* Registration of the application in the organization, i.e. creation of the service principal for the application. This step generally occurs automatically the first time a sign-in is attempted for an application, but depending on the organization's configuration or the privileges of a user attempting a delegated sign-in, it may be necessary for someone with sufficient privileges to register the application before sign-in can occur. New-GraphApplication optionally automatically registers an application in its owning tenant. See the Register-GraphApplication command for ore information on the registration process.
* Consent configuration: as part of the registration step, New-GraphApplication also provisions consent in the form of OAuth2 permission grants for delegated sign-ins or app role assignments for application-only sign-in.

New-GraphApplication can create both "public client" / "native client" applications and "confidential client" applications. The default application for this module is a native client application, which means delegated sign-ins may occur on any device without any restrictions as to what application code is able to use the identity to access resources. Confidential client applications require a private key for both delegated and application-only sign-in, and therefore only application code with access to the private key may access Graph APIs.

By default, New-GraphApplication creates native client applications. This can be overriden by specifying the Confidential parameter so that the command creates a confidential client application.

Note that delegated sign-in, i.e. sign-in with a user identity delegated to the application, can be performed with either native or confidential applications, but for application-only sign-in a confidential application is required.

AAD applications created by New-GraphApplication may be used for any purpose; the command may also be used to provision a custom application identity for use with this module via the Connect-GraphApi and New-GraphConnection commands and profile settings. For more details on how to use custom AAD applications include those created by New-GraphApplication with this module, see the documentation for the Connect-GraphApi and New-GraphConnection commands.

Note that AAD applications have many properties -- the New-GraphApplication command allows configuration of these properties. For details on application properties, see the Graph API documentation for the application resource at https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/resources/application.

Note that New-GraphApplication's ability to both create an application and register its service principal is limited to use cases where the application resides in only one organization. Multi-organization ("multi-tenant") applications are applications that allow sign-in from any organization, not just the organization in which the application was created. For such applications, a service principal must be created in all organizations where sign-in is to occur, and New-GraphApplication can only create service principals within the organization in which the new application is being created. For more information about multi-organization scenarios, see the Register-GraphApplication documentation.

.NOTES
As described above, New-GraphApplication performs four different functions: application creation, application registration, certificate credential creation and configuration, and consent configuration. These capabilities are provided in a single command with the goal of enabling streamlined creation of applications such that once the application is created with a single invocation of New-GraphApplication, it can be immediately signed in and used. This is a usability affordance aimed at simplifying application creation so that users need not be aware of steps that may not apply to them and that there's a single command starting point for getting the application they require. Other commands can perform the same operations beyond application creation with more in-depth functionality if required.

.PARAMETER Name
The display name of the application -- this name will be shown to users when they sign in to the application and also to administrators approving consent for the application.

.PARAMETER RedirectUris
The OAuth2 redirect URIs that the application supports, also known as reply url's. By default, for native client applications the URI http://localhost will be configured if this parameter is not specified.

.PARAMETER InfoUrl
An informational URL that is associated with the application. This URL could refer to the application's documentation or public web site for instance. It may be presented as part of sign-in and / or consent user experiences.

.PARAMETER Tags
User-defined strings associated with the application to categorize its purpose, origin, or other important information. This can be useful when searching for applications by some category for instance.

.PARAMETER AdditionalProperties
Specify AdditionalProperties to configure any documented properties of the AAD application resource. This can be specified as a hash table or object. The documentation of these properties can be found here: https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/resources/application.

.PARAMETER Tenancy
Specifies the organizational scope for which the application may be used. By default, this has the value Auto, which is currently equivalent of the value SingleTenant, which means that the application may be signed-in only within its owning tenant. The value MultiTenant means that the application allows sign-in from any organization (subject to configured restrictions in place within a given organization managed by that organization's adminstrators) as well as delegated sign-ins by Microsoft Account (MSA) users.

.PARAMETER DelegatedPermissions
The delegated permissions to be configured for the application and (optionally) consented to the application. Specifying these permissions configures them as "required permissions" for the application. And as long as the NoConsent parameter is not specified, the consent is also configured using these permissions. The consent is configured as oauth2PermissionGrant resources documented as part of the Graph API. If the PrincipalIdToConsent parameter is not specified then the the permissions are automatically consented to the user associated with the Graph connection in use by the command. If the command is executing with app-only context, i.e. with no signed in user, then the command will fail unless PrincipalIdToConsent or ConsentForAllPrincipals is specified. If you don't specify this parameter, then by default, the offline permission is consented for the application.

.PARAMETER ApplicationPermissions
The application permissions to be consented to the application. The consent is actually configured as app role assignments described by the appRoleAssignment resource documented as part of the Graph API.

.PARAMETER Confidential
Specify this parameter if AAD application requires a client secret in order to successfully authenticate to the Graph API. Specifying this parameter does not configure the secret -- secret configuration only occurs with this command if the NewCredential parameter is specified.

.PARAMETER AllowMSAAccounts
Specifies that delegated sign-ins to this application by Microsoft Account (MSA) users are allowed. By default such sign-ins are not allowed and only users that are part of an AAD organization may sign-in -- specifying this parameter overrides that behavior and allows MSA users to sign-in to the application. Note that when this parameter is specified, AAD users from any organization are also allowed to sign in to the application (subject to restrictions in those organizations).

.PARAMETER NewCredential
The NewCredential parameter may be specified if Confidential is specified. Specifying this parameter causes the command to create a certificate credential for the application and configure the application to use it for sign-in. The parameter is supported only on Windows since it requires the Windows certificate store (see the documentation for the Connect-GraphApi command for examples of how to create certificate credentials on non-Windows systems for use with this module's AAD applicaiton or any AAD application). Other parameters for this command allow customization of the certificate created by this command. Additionally, commands such as Set-GraphApplicationCertificate and New-GraphApplicationCertificate may also be used to configure create and / or configure application certificates.

.PARAMETER SuppressCredentialWarning
If this parameter is not specified and Confidential is specified, the command generates a warning to communicate the fact that the created application does not have a secret configured and thus sign-in cannot occur after the command completes without additional configuration such as through commands like New-GraphApplicationCertificate or Set-GraphApplicationCertificate. Specify this parameter to suppress the warning when it is expected.

.PARAMETER ConsentForAllPrincpals
Specify ConsentForAllPrincipals to grant consent for the permissions specified by the DelegatedPermissions parameter to all principals (including users) in the organization.

.PARAMETER NoConsent
Specifies that there should be no consent granted -- this overrides any default consent (i.e. the 'offline' delegated permissions) that the command configures when no permissions are specified and also means that the DelegatedPermissions

.PARAMETER SkipTenantRegistration
If this parameter is not specified, then the application is registered (i.e. the service principal is created) in the current organization and any permission consent is configured. Specify this flag to skip both the registration and consent grant configuration.

.PARAMETER SkipPermissionNameCheck
By default, permission names are validated before issuing a request to configure a request. Since it is possible that the permissions you want to use may not (yet) be known to the module, specify this parameter to instruct the command not to fail if it can't determine the validity of the permissions.

.PARAMETER CertStoreLocation
Specifies the location in the certificate store in which to create the application credential certificate if the NewCredential parameter is specified. By default, this location is 'cert:/currentuser/my'. The CertStoreLocation parameter only applies on the Windows platform because the certificate store is currently implemented only for Windows.

.PARAMETER CertKeyLength
The length of the application credential certificate's private key. If this is not specified, the default is 4096 bits. This is only valid if the NewCredential parameter is specified.

.PARAMETER CertValidityTimeSpan
The duration of the application credential certificate's validity -- this is added to the CertValidityStart parameter's value to compute the expiration date / time of the certificate. If this is not specified, the duration is 365 days. This is only valid if the NewCredential parameter is specified.

.PARAMETER CertValidityStart
The date and time at which the application credential certificate starts to be valid. If this is not specified, then the start time is the current system time. This is only valid if the NewCredential parameter is specified.

.PARAMETER CertOutputDirectory
Specifies that the newly created certificate must be exported as a file to the directory path location specified to the parameter. This parameter only applies if the NewCredential parameter is specified. The name of the certificate file in that directory will be generated automatically by the command and available in the command output via the ExportedCertificatePath property. Note that the export occurs in addition to creation of the certificate in the certificate store, i.e. the certificate will still be present in the certificate store if you specify this parameter.

.PARAMETER CertCredential
Specifies the credential used to protect the private key of the certificate if the certificate is exported from the certificate store as a file due to specification of the CertOutputDirectory parameter. A command such as Get-Credential can be used to create an object that may be specified to the CertCredential parameter.

.PARAMETER NoCertCredential
If the CertOutputDirectory parameter is specified, specify the NoCertCredential parameter to specify that no credential is required on the resulting exported certificate file to access the private key of the certificate. Otherwise, if NoCertCredential is not specified, the CertCredential parameter must be specified (and if it isn't then an interactive prompt will be invoked to request the user to input a credential).

.PARAMETER PrincipalIdToConsent
Use the PrincipalIdToConsent parameter to specify a principal such as a user to which the specified delegated permissions should be granted when signed in to the application. If neither this parameter nor the AllPermissions parameter is specified, then if the command is executing using a delegated identity, that identity is granted consent for delegated permissions. If that case is modified so that the command is executing using an application-only identity, then the command will fail if neither ConsentForAllPrincipals or PrincipalIdToConsent is specified. When specifying this parameter, it must be the AAD object identifier guid of the user to which to grant consent.

.PARAMETER Connection
Specify the Connection parameter to use as an alternative connection to the current connection when communicating with the Graph API.

.EXAMPLE
New-GraphApplication 'Custom Graph Scripting Application'

AppId         DisplayName      CreatedDateTime        Id            PublisherDomain
-----         -----------      ---------------        --            ---------------
54dfa095-0... 'Custom Graph... 12/28/2021 10:18:09 PM 25650e01-4... kuumba.org

The simplest case of application creation requires only the name parameter to be specified to the command. The created application is a public client application which means it can be signed-in on any device running any application code. By default, it is configured only with the permission 'offline', so it has no permission to make requests to the Graph API -- application code will need to request additional permissions at runtime or other commands such as Set-GraphApplicationConsent will need to be executed to configure consent. This application created by this command is valid only in the organization in which it was created. The application's redirect URL is configured as 'http://localhost' since the RedirectUris parameter was not specified.

.EXAMPLE
$scriptApp = New-GraphApplication 'Custom Graph Scripting Application'
Connect-GraphApi -AppId $scriptApp.AppId -Permissions User.Read, Mail.Read
Get-GraphResource /me | Select-Object id, displayName

id                                   displayName
--                                   -----------
c206a2a7-c458-4263-afea-173fa4c266fb b hooks

This example shows how a native client application created by New-GraphApplication may be used with commands such as Connect-GraphApi and New-GraphConnection to issue graph requests from this module using an application identity of your own creation instead of the module's default application identity. After a successful sign-in with Connect-GraphApi, the Get-GraphResource command executes successfully since the permission required for '/me', 'User.Read', was requested by Connect-GraphApi.

.EXAMPLE
$graphApp = New-GraphApplication 'Shared Graph Scripting App' -Permissions Group.Read.All, Application.Read.All -ConsentForAllPrincipals

This example shows how to create a native client application with specific permissions consented to all users in the organization by using the ConsentForAllPrincipals parameter. Alternatively, the PrincipalIdToConsent parameter may be used to grant consent to a specific principal rather than all principals.

.EXAMPLE
$multiApp = New-GraphApplication 'Cross-Org test app' -Tenancy MultiTenant -DelegatedPermissions User.Read

In this example a multi-organization application is created and specific delegated permissions are consented for the user executing the command.

.EXAMPLE
$commonApp = New-GraphApplication 'Mail App' -AllowMsaAccounts

This example uses the AllowMSAAccounts parameter to allow Microsoft Account users to sign in to the newly created application.

.EXAMPLE
$confidentialApp = New-GraphApplication 'Access Portal' -Confidential

Simply adding the Confidential parameter means the application will require a credential for sign-in to succeed. In this case a warning will be generated since the new application does not have a credential configured and there for no sign-in can occur without additional configuration steps. When Confidential is specified by NewCredential is not so that the application has no credential, then you can specify SuppressCredentialWarning to avoid the message when this situation is expected.

.EXAMPLE
$privateScriptApp = New-GraphApplication 'Kya personal scripting' -Confidential -NewCredential -DelegatedPermissions User.Read, Mail.ReadWrite
Connect-GraphApi -AppId $privateScriptApp.AppId
Get-GraphResource /me | Select-Object id, displayName

id                                   displayName
--                                   -----------
c206a2a7-c458-4263-afea-173fa4c266fb b hooks

In this example, a confidential client application is created, and then used to create a new connection for the module to the Graph API which is used by subsequent commands including the invocation of Get-GraphResource. The NewCredential parameter of New-GraphApplication causes a credential to be created in the local certificate store and configured on the application itself. Because this application is confidential and its key only exists on the system on which the New-GraphApplication command was invoked, this system is the only place where this application may be used -- a user on some other system who happens to know the application's identifier will be unable to sign-in. The Connect-GraphApi invocation is given the newly created application's appid and because the Confidential parameter is also supplied, Connect-GraphApi searches the local certificate store for a credential for the application and in this case finds the newly created certificate. This will prompt a sign-in for a user, and assuming a successful sign-in the Get-GraphResource command is executed to access the '/me' URI. Note that no permissions were specified for the sign-in via Connect-GraphApi since the necessary permissions had already been implicitly consented to the user invoking the commands via New-GraphApplication.

.EXAMPLE
$groupSyncApp = New-GraphApplication 'Group Sync App' -Confidential -NewCredential -ApplicationPermissions Group.Read.All, Organization.Read.All
$syncConnection = New-GraphConnection -AppId $groupSyncApp.AppId -NoninteractiveAppOnlyAuth
Get-GraphResource /groups -count -Connection $syncConnection -ConsistencyLevel Eventual

52

This demonstrates how to create an application for use in app-only scenarios where no user signs in. To create such an application with New-GraphApplication, simply specify the Confidential parameter. In this case, the NewCredential parameter is included to create the credential for the application in the certificate store (a credential of some sort is a requirement for application-only sign-in) and permissions are assigned to it using the ApplicationPermissions parameter since application permissions cannot be requested at runtime. To demonstrate the usage of such an application, a non-interactive Graph API connection is created with New-GraphConnection by specifying the new application's application identifier and adding the NoninteractiveAppOnlyAuth parameter to request a non-interactive sign-in when a subsequent sign-in occurs. The connection is then used by Get-GraphResource to get a count of AAD groups returned by the '/groups' API -- Get-GraphResource implicitly signs in using the credential created by New-GraphApplication (it looks like up in the local certificate store). I
t returns the count of 52 groups.

.EXAMPLE
$basicApp = New-GraphApplication 'Basic Application' -SkipTenantRegistration

In this example, an application is created but the application is not registered, i.e. no service principal is created in the organization, and therefore no consent is granted either.

.EXAMPLE
$noconsent = New-GraphApplication 'Registered without consent' -DelegatedPermissions User.Read, Mail.Read -NoConsent

This example shows how to create an application that has its service principal registered but no permissions are consented. The permissions specified via the DelegatedPermissions parameter are not consented, but they are configured on the application as required permissions.

.EXAMPLE
$customizedApp = New-GraphApplication 'Custom Native App' -AdditionalProperties @{defaultRedirectUri='http://localhost'}

This example shows how to use the AdditionalProperties parameter to set arbitrary properties of the application by specifying a hash table or object that represents the properties (including their nesting levels). In this case, the defaultRedirectUri property of the application is set. Care should be taken since it is possible that properties set by other functionality of the command could be overwritten by properties specified here (there is no "deep merge" functionality for those properties and those properties specified by AdditionalProperties). The properties of the application object are documented at https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/resources/application.

.EXAMPLE
New-GraphApplication 'Confidential App' -Confidential -SkipTenantRegistration -OutVariable confidentialApp -SuppressCredentialWarning | New-GraphApplicationCertificate | Register-GraphApplication | Set-GraphApplicationConsent -ApplicationPermissions Group.Read.All
$confidentialApp | Get-GraphApplicationConsent

   AppId: e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

PermissionType ServicePrincipalId                   Permission     GrantedTo
-------------- ------------------                   ----------     ---------
Application    ad29424b-d716-48fe-8555-6985e07a821b Group.Read.All ad29424b-d716-48fe-8555-6985e07a821b

This example demonstrates that the functionality beyond application creation that is present in New-GraphApplication may be skipped and instead accomplished with other commands. In this example, New-GraphApplication for a confidential client application is invoked without creating a credential since NewCredential is not specified when Confidential was specified. Tenant registration and consent are skipped since the SkipTenantRegistration parameter was specified. This output is then piped to New-GraphApplicationCertificate, which creates the credential for the application, and that output, which contains an application identifier, is piped to Register-GraphApplication, which register the specified application identifier but does not set permissions. Finally, that output itself, which also contains an application identifier, is piped to Set-GraphApplicationConsent, which configures the application permissions. Since OutVariable was specified for New-GraphApplication, we can use the variable it created ($confidentialApp) to retrieve the current application configuration using Get-GraphApplicationConsent, which shows that not only does the application exist, but it is registered and has the permissions configured by the last command. This shows that New-GraphApplication combines the core functinonlity of four different commands into one command to enable simple, quick creation of AAD applications.


.LINK
Get-GraphApplication
Register-GraphApplication
Unregister-GraphApplication
Set-GraphApplicationConsent
New-GraphApplicationCertifiate
Get-GraphApplicationServicePrincipal
#>
function New-GraphApplication {
    [cmdletbinding(defaultparametersetname='publicapp', positionalbinding=$false)]
    [OutputType('AutoGraph.Application')]
    param(
        [parameter(position=0, mandatory=$true)]
        [string] $Name,

        [string[]] $RedirectUris = $null,

        [Uri] $InfoUrl,

        [string[]] $Tags,

        $AdditionalProperties,

        [AppTenancy] $Tenancy = ([AppTenancy]::Auto),

        [String[]] $DelegatedUserPermissions,

        [String[]] $ApplicationPermissions,

        [parameter(parametersetname='confidentialapp', mandatory=$true)]
        [parameter(parametersetname='confidentialappnewcert', mandatory=$true)]
        [parameter(parametersetname='confidentialappnewcertexport', mandatory=$true)]
        [switch] $Confidential,

        [parameter(parametersetname='publicapp')]
        [switch] $AllowMSAAccounts,

        [parameter(parametersetname='confidentialappnewcert', mandatory=$true)]
        [parameter(parametersetname='confidentialappnewcertexport', mandatory=$true)]
        [switch] $NewCredential,

        [parameter(parametersetname='confidentialapp')]
        [switch] $SuppressCredentialWarning,

        [switch] $ConsentForAllPrincipals,

        [switch] $NoConsent,

        [switch] $SkipTenantRegistration,

        [switch] $SkipPermissionNameCheck,

        [parameter(parametersetname='confidentialappnewcert')]
        [parameter(parametersetname='confidentialappnewcertexport')]
        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='confidentialappnewcert')]
        [parameter(parametersetname='confidentialappnewcertexport')]
        [int] $CertKeyLength = 4096,

        [parameter(parametersetname='confidentialappnewcert')]
        [parameter(parametersetname='confidentialappnewcertexport')]
        [TimeSpan] $CertValidityTimeSpan,

        [parameter(parametersetname='confidentialappnewcert')]
        [parameter(parametersetname='confidentialappnewcertexport')]
        [DateTime] $CertValidityStart,

        [parameter(parametersetname='confidentialappnewcertexport', mandatory=$true)]
        [string] $CertOutputDirectory,

        [parameter(parametersetname='confidentialappnewcertexport')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='confidentialappnewcertexport')]
        [switch] $NoCertCredential,

        [string] $PrincipalIdToConsent,

        [PSCustomObject] $Connection = $null
    )
    Enable-ScriptClassVerbosePreference

    if ( $SkipTenantRegistration.IsPresent ) {
        if ( $PrincipalIdToConsent -or $ConsentForAllPrincipals.IsPresent ) {
            throw [ArgumentException]::new("'SkipTenantRegistration' may not be specified if 'PrincipalIdToConsent' or 'ConsentForAllPrincipals' is specified")
        }
    }

    if ( $NewCredential.IsPresent ) {
        $::.LocalCertificate |=> ValidateCertificateCreationCapability
    }

    $commandContext = new-so CommandContext $Connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

    $::.ScopeHelper |=> ValidatePermissions $ApplicationPermissions $true $SkipPermissionNameCheck.IsPresent $commandContext.connection
    $::.ScopeHelper |=> ValidatePermissions $DelegatedUserPermissions $false $SkipPermissionNameCheck.IsPresent $commandContext.connection

    $appOnlyPermissions = $::.ScopeHelper |=> GetAppOnlyResourceAccessPermissions $ApplicationPermissions $commandContext.Connection
    $delegatedPermissions = $::.ScopeHelper |=> GetDelegatedResourceAccessPermissions $DelegatedUserPermissions $commandContext.Connection

    $computedTenancy = if ( $Tenancy -ne ([AppTenancy]::Auto) ) {
        $Tenancy
    } else {
        [AppTenancy]::SingleTenant
    }

    $appAPI = new-so ApplicationAPI $commandContext.Connection $commandContext.Version

    $propertyTable = if ( $AdditionalProperties ) {
        if ( $AdditionalProperties -is [Hashtable] -or $AdditionalProperties -is [PSCustomObject] ) {
            $AdditionalProperties
        } elseif ( $AdditonalProperties -is [string] ) {
            $AdditionalProperties | ConvertFrom-JSON
        }
    }

    $newAppRegistration = new-so ApplicationObject $appAPI $Name $InfoUrl $Tags $computedTenancy ( ! $AllowMSAAccounts.IsPresent ) $appOnlyPermissions $delegatedPermissions $Confidential.IsPresent $RedirectUris $propertyTable

    $newApp = $newAppRegistration |=> CreateNewApp

    if ( $Confidential.IsPresent ) {
        if ( $NewCredential.IsPresent ) {
            $newCertificateParameters = @{
                AppId = $newApp.appId
                ObjectId = $newApp.Id
            }

            'CertCredential',
            'CertValidityTimeSpan',
            'CertValidityStart',
            'CertStoreLocation',
            'CertOutputDirectory',
            'CertKeyLength',
            'NoCertCredential'| foreach {
                $parameterValue = $PSBoundParameters[$_]
                if ( $parameterValue -ne $null ) {
                    $newCertificateParameters.Add($_, $parameterValue)
                }
            }

            try {
                New-GraphApplicationCertificate @newCertificateParameters | out-null
            } catch {
                $::.GraphApplicationCertificate |=> FindAppCertificate $newApp.appId | remove-item -erroraction ignore
                $appAPI |=> RemoveApplicationByObjectId $newApp.Id ignore
                throw
            }
        } elseif ( ! $SuppressCredentialWarning.IsPresent ) {
            write-warning "The 'NewCredential' parameter was not specified to the New-GraphApplication command, so this Confidential application cannot sign in until you use issue a subsequent command such as New-GraphApplicationCertificate, Set-GraphApplicationCertificate, or some other method of configuring this application's sign in credential. You can use the 'SuppressCredentialWarning' parameter of New-GraphApplication to silence this warning message."
        }
    }

    if ( ! $SkipTenantRegistration.IsPresent ) {
        $newAppRegistration |=> Register $true (! $NoConsent.IsPresent) $PrincipalIdToConsent $ConsentForAllPrincipals.IsPresent $DelegatedUserPermissions $ApplicationPermissions | out-null
    }

    $::.ApplicationHelper |=> ToDisplayableObject $newApp
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication DelegatedUserPermissions (new-so PermissionParameterCompleter DelegatedPermission)

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplication ApplicationPermissions (new-so PermissionParameterCompleter AppOnlyPermission)

