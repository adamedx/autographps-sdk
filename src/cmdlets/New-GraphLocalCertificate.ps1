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

. (import-script ../common/GraphApplicationCertificate)

<#
.SYNOPSIS
Creates a new certificate in the local certificate store for use as an Entra ID application credential (Windows platform only).

.DESCRIPTION
Certificate credential configuration on the application object allows running application code to obtain access tokens with the application's identity. New-GraphLocalCertificate creates such a certificate in the local system's certificate store cert: drive. New-GraphLocalCertificate *does not*, however, configure the certificate on the application. A subsequent Graph API request to configure the application to use the certificate created by New-GraphLocalCertificate must be issued to allow sign-in to the application through the certificate. The Set-GraphApplicationCertificate command may be used to issue such a request to configure the application.

To create a new certificate for an application AND also configure the application to use it with a single command rather than using both New-GraphLocalCertificate and Set-GraphApplicationCertificate to do so, use the New-GraphApplicationCertificate command instead. Applications may also be configured with certificates at app creation time using the New-GraphApplication command with the NewCredential parameter. See the documentation for New-GraphApplication, New-GraphApplicationCertificate, and Set-GraphApplicationCertificate for more details on application certificate configuration.

Note that it is not a requirement to use this command or New-GraphApplicationCertificate to create application credential certificates, these commands simply provide an optimized user experience for doing so. This command creates only self-signed certificates, so if you need certificates issued from a particular issuer, this command may not be used for that scenario.

Because the cert: drive is implemented only for the Windows platform, both the New-GraphLocalCertificate and New-GraphApplicationCertificate commands are supported only on the Windows platform. For examples of how to create certificates for application credentials using tools such as openssl that are supported across a broader set of platforms, see the examples in the documentation for the New-GraphConnection command.

While the command creates the certificate in the system's certificate store, the command has options that will allow it to be exported from that store as a file in .pfx format for use with platforms or other tools that require file-based certificates or cannot access the certificate store.

Note that although the command makes no changes to the directory and in general does not performan any write operations via the Graph API, it does read application state to obtain information about the object id or application id of the application depending on which of these identifiers you supply to the command; thus New-GraphLocalCertificate requires read (but not write) access to application objects using the Graph API despite making no changes to the applications themselves.

The application for which to create a certificate may be specified either by the application object's application identifier via the AppId parameter or by the application's directory object identifier through the ObjectId parameter.

The command allows for the certificate start and end times to be configured, as well as the key length. The current cryptographic provider for the certificates is the "Microsoft Enhanced RSA and AES Cryptographic Provider". Customization beyond the command's current support for specific certificate properties or cryptographic algorithms requires the use of an alternative tool for the use case.

.PARAMETER AppId
The Entra ID application identifier of the application for which to create a certificate in the certificate store

.PARAMETER ObjectId
The Entra ID object identifier of the application for which to create a certificate in the certificate store

.PARAMETER ApplicationName
Optional parameter used to add a human-friendly description of the application for which the certificate is being created.

.PARAMETER CertValidityTimeSpan
The duration of the certificate's validity -- this is added to the CertValidityStart parameter's value to compute the expiration date / time of the certificate. If this is not specified, the duration is 365 days.

.PARAMETER CertValidityStart
The date and time at which the certificate starts to be valid. If this is not specified, then the start time is the current system time.

.PARAMETER CertKeyLength
The length of the certificate's private key. If this is not specified, the default is 4096 bits.

.PARAMETER CertStoreLocation
Specifies the location in the certificate store in which to lookup certificates specified by the Thumbprint parameter. By default, this location is 'cert:/currentuser/my'. The CertStoreLocation parameter only applies on the Windows platform because the certificate store is currently implemented only for Windows.

.PARAMETER CertOutputDirectory
Specifies that the newly created certificate must be exported as a file to the directory path location specified to the parameter. The name of the certificate file in that directory will be generated automatically by the command and available in the command output via the ExportedCertificatePath property. Note that the export occurs in addition to creation of the certificate in the certificate store, i.e. the certificate will still be present in the certificate store if you specify this parameter.

.PARAMETER CertificateFilePath
Specifies that the newly created certificate must be exported as a file to the file path location specified to the parameter. The ExportedCertificatePath property of the command's output will be set to the value of this parameter as well. Note that the export occurs in addition to creation of the certificate in the certificate store, i.e. the certificate will still be present in the certificate store if you specify this parameter.

.PARAMETER CertCredential
Specifies the credential used to protect the private key of the certificate if the certificate is exported from the certificate store as a file due to specification of the CertOutputDirectory or CertificateFilePath parameters. A command such as Get-Credential can be used to create an object that may be specified to the CertCredential parameter.

.PARAMETER NoCertCredential
If the CertOutputDirectory or CertificateFilePath parameters are specified, specify the NoCertCredential parameter to specify that no credential is required on the resulting exported certificate file to access the private key of the certificate. Otherwise, if NoCertCredential is not specified, the CertCredential parameter must be specified (and if it isn't then an interactive prompt will be invoked to request the user to input a credential).

.PARAMETER AsX509Certificate
By default, the output of the command is an object that describes the newly created certificate. To return the newly created certificate itself in X509 format instead, specify the AsX509Certificate parameter

.NOTES
Both New-GraphApplication and New-GraphApplicationCertificate offer the same ability to create and customize certificates as the New-GraphLocalCertificate command. New-GraphLocalCertificate is preferable to those commands in situations like the following:
* You need to create certificates but then perform processing on them prior to configuring them on the application (such as exporting them to another system
* You need to generate multiple new certificates and want to configure them once with a single Graph API request. For example, New-GraphLocalCertificate can be used multiple times to create multiple certificates, and (Set-GraphApplicationCertificate can be specified once with all those certificates as input and will issue just one Graph API request to configure the application.
* You want to create an new certificate and replace, rather than add to, any existing certificates on the application. The New-GraphApplicationCertificate command can only perform the additive update -- use of Set-GraphApplicationCertificate with EditMode set ot replace after using New-GraphLocalCertificate to create the certificate accomplishes the replacement scenario.

.OUTPUTS
By default, the output is an object that represents the newly created certificate, with properties that include its location in the local certificate store, the application identifier of the application for which it is intended to be used, and the object identifier. If the AsX509Certificate option is specified, then a .Net object of type [System.Security.Cryptography.X509Certificates.X509Certificate2] that is the actual newly created certificate itself in X509 format rather than its path or other metadata concerning it.

.EXAMPLE
New-GraphLocalCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

   Application (client) ID: e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

Thumbprint                               NotAfter                     KeyId Subject
----------                               --------                     ----- -------
A14AA744C84E978E761884132D62C6AB8DC1E204 12/27/2022 4:10:42 PM -08:00       e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

In this example a certificate is created in the local certificate store for the application with the appplication identifier specified by the AppId parameter.

.EXAMPLE
$newCert = New-GraphLocalCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -CertValidityTimeSpan ([TimeSpan]::new(180,0,0,0)) -CertKeyLength 8192

This example shows how to customize the lifetime and key length of the certificate. A TimeSpan object for 180 days specified for the CertValidityTimeSpan parameter is used to override the default duration of 1 year to 6 months instead. The CertKeyLength parameter overrides the default length of 4096 bits to a length of 8192 bits.

.EXAMPLE
New-GraphApplication "Dev app" -OutVariable newApp | New-GraphLocalCertificate -CertOutputDirectory ~/cert

   Application (client) ID: e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

Thumbprint              : A14AA744C84E978E761884132D62C6AB8DC1E203
AppId                   : e4ab44d2-98ac-4a33-a010-e8fa2ac2e330
Subject                 : CN=e4ab44d2-98ac-4a33-a010-e8fa2ac2e330, CN=AutoGraphPS, CN=MicrosoftGraph
FriendlyName            : Credential for Microsoft Graph Entra ID application name='AutoGraphPS Application',
                          appId=e4ab44d2-98ac-4a33-a010-e8fa2ac2e330, objectId=
NotBefore               : 12/27/2021 4:10:42 PM -08:00
NotAfter                : 12/27/2022 4:10:42 PM -08:00
CertificatePath         : Cert:\CurrentUser\my\A14AA744C84E978E761884132D62C6AB8DC1E203
ExportedCertificatePath : ~\cert\GraphApp-e4ab44d2-98ac-4a33-a010-e8fa2ac2e330.pfx

This example shows how the output of the New-GraphApplication command which creates a new application may be piped to New-GraphLocalCertificate to create a local certificate that is present only locally and not yet configured for the application. Since the CertOutputDirectory parameter was specified, a file was created in the directory specified for that parameter and the full path to that file with it's auto-generated name is availabled through the ExportedCertificatePath property. Note that since NoCertCredential was not specified invocation of this command also prompted for secure user input to provide a credential to protect the public key.

.EXAMPLE
New-GraphLocalCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -OutVariable newCert | Set-GraphApplicationCertificate -EditMode Replace

This example shows how a new certificate may be created for an existing application using New-GraphLocalCertificate, and then replace all certificates configured for that application. While New-GraphApplicationCertificate can also update an application's certificate configuration with a new certificate, it performs only an additive updated equivalent to the Add value of the EditMode parameter of Set-GraphApplication; New-GraphApplicationCertificate cannot perform the replacement.

.LINK
New-GraphApplication
Set-GraphApplicationCertificate
Get-GraphApplicationCertificate
Remove-GraphApplicationCertificate
Find-GraphLocalCertificate
Connect-GraphApi
New-GraphConnection
#>
function New-GraphLocalCertificate {
    [cmdletbinding(positionalbinding=$false)]
    [OutputType('AutoGraph.Certificate')]
    param(
        [parameter(parametersetname='pipeline', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='pipelineexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='pipelineexportpath', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='appid', mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='pipeline', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='pipelineexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='pipelineexportpath', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='objectid', mandatory=$true)]
        [Alias('Id')]
        [Guid] $ObjectId,

        [parameter(position=1)]
        [Alias('Name')]
        [string] $ApplicationName = 'AutoGraphPS Application',

        [TimeSpan] $CertValidityTimeSpan,

        [DateTime] $CertValidityStart,

        [int] $CertKeyLength = 4096,

        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='pipelineexport', mandatory=$true)]
        [parameter(parametersetname='appidexport', mandatory=$true)]
        [parameter(parametersetname='objectidexport', mandatory=$true)]
        [string] $CertOutputDirectory,

        [parameter(parametersetname='pipelineexportpath', mandatory=$true)]
        [parameter(parametersetname='appidexportpath', mandatory=$true)]
        [parameter(parametersetname='objectidexportpath', mandatory=$true)]
        [string] $CertificateFilePath,

        [parameter(parametersetname='pipelineexport')]
        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [parameter(parametersetname='pipelineexportpath')]
        [parameter(parametersetname='appidexportpath')]
        [parameter(parametersetname='objectidexportpath')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='pipelineexport')]
        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [parameter(parametersetname='pipelineexportpath')]
        [parameter(parametersetname='appidexportpath')]
        [parameter(parametersetname='objectidexportpath')]
        [switch] $NoCertCredential,

        [switch] $AsX509Certificate
    )
    Enable-ScriptClassVerbosePreference

    $::.LocalCertificate |=> ValidateCertificateCreationCapability

    $certHelper = new-so CertificateHelper $AppId $ObjectId $ApplicationName $CertValidityTimespan $CertValidityStart $null $CertKeyLength

    $certificateResult = $certHelper |=> NewCertificate $CertOutputDirectory $CertStoreLocation $CertCredential $NoCertCredential.IsPresent $false $CertificateFilePath
    $X509Certificate = $certificateResult.Certificate.X509Certificate

    if ( ! $AsX509Certificate.IsPresent ) {
        $::.CertificateHelper |=> CertificateToDisplayableObject $X509Certificate $certHelper.appId $certHelper.objectId $X509Certificate.PSPath $null $certificateResult.ExportedLocation
    } else {
        $X509Certificate
    }
}
