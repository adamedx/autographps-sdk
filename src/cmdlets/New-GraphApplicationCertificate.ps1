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

. (import-script common/CertificateHelper)

<#
.SYNOPSIS
Creates a new certificate in the local certificate store and configures an Azure Active Directory (AAD) application to use the certificate as a credential (Windows platform only).

.DESCRIPTION
Certificate credential configuration on the application object allows running application code to obtain access tokens with the application's identity. New-GraphApplicationCertificate creates such a certificate in the local system's certificate store cert: drive and configures an application to use it using the Graph API.

Note that it is not a requirement to use this command to create application credential certificates, the command simply provides an optimized user experience for doing so. New-GraphLocalCertificate creates only self-signed certificates, so if you need certificates issued from a particular issuer, this command may not be used for that scenario.

New-GraphApplicationCertificate always adds the new certificate to the application's configuration; any certificates already configured for the application before invoking New-GraphApplicationCertificate remain configured even after it is invoked successfully and the new certificate is added to the application's configuration. To update an application's configuration with a new certificate and replace it, use the New-GraphLocalCertificate command followed by the Set-GraphApplicationCertificate command with the EditMode parameter set to Replace instead of using the New-GraphApplicationCertificate command.

To create a new certificate for an application in the certificate store without configuring the application itself, use the New-GraphLocalCertificate command instead. If you need to configure an application certificate immediately after creating the application, consider using New-GraphApplication with the NewCredential parameter to create the application along with its certificate using a single command.

To configure an application to use an existing certificate rather than creating a new certificate, use the Set-GraphApplicationCertificate command.

Because the cert: drive is implemented only for the Windows platform, both the New-GraphLocalCertificate and New-GraphApplicationCertificate commands are supported only on the Windows platform. For examples of how to create certificates for application credentials using tools such as openssl that are supported across a broader set of platforms, see the examples in the documentation for the New-GraphConnection command.

While the command creates the certificate in the system's certificate store, the command has options that will allow it to be exported from that store as a file in .pfx format for use with platforms or other tools that require file-based certificates or cannot access the certificate store.

The application to configure may be specified either by the application object's application identifier via the AppId parameter or by the application's directory object identifier through the ObjectId parameter.

See the documentation for the New-GraphLocalCertificate command for more information on the properties and cryptographic algorithms supported by the New-GraphApplicationCertificate command.

.PARAMETER AppId
The AAD application identifier of the application for which to create a certificate in the certificate store and configure the application to use that certificate as a credential

.PARAMETER CertValidityTimeSpan
The duration of the certificate's validity -- this is added to the CertValidityStart parameter's value to compute the expiration date / time of the certificate. If this is not specified, the duration is 365 days.

.PARAMETER CertValidityStart
The date and time at which the certificate starts to be valid. If this is not specified, then the start time is the current system time.

.PARAMETER CertKeyLength
The length of the certificate's private key. If this is not specified, the default is 4096 bits.

.PARAMETER ObjectId
The AAD object identifier of the application for which to create a certificate in the certificate store and configure the application to use that certificate as a credential

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

.PARAMETER Connection
Specify the Connection parameter to use as an alternative connection to the current connection when communicating with the Graph API.

.OUTPUTS
By default, the output is an object that represents the newly created certificate, with properties that include its location in the local certificate store, the application identifier of the application for which it is intended to be used, and the object identifier. If the AsX509Certificate option is specified, then a .Net object of type [System.Security.Cryptography.X509Certificates.X509Certificate2] that is the actual newly created certificate itself in X509 format rather than its path or other metadata concerning it.

.EXAMPLE
New-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

   Application (client) ID: e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

Thumbprint                               NotAfter                     KeyId Subject
----------                               --------                     ----- -------
A14AA744C84E978E761884132D62C6AB8DC1E204 12/27/2022 4:10:42 PM -08:00       e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

In this example a certificate is created in the local certificate store for the existing application with the application identifier specified by the AppId parameter and is then configured for the app.

.EXAMPLE
New-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -CertValidityTimeSpan ([TimeSpan]::new(180,0,0,0)) -CertKeyLength 8192

This example shows how to customize the lifetime and key length of the certificate. A TimeSpan object for 180 days specified for the CertValidityTimeSpan parameter is used to override the default duration of 1 year to 6 months instead. The CertKeyLength parameter overrides the default length of 4096 bits to a length of 8192 bits.

.EXAMPLE
New-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -CertOutputDirectory ~/cert | Select-Object ExportedCertificatePath

ExportedCertificatePath
-----------------------
~\cert\GraphApp-e4ab44d2-98ac-4a33-a010-e8fa2ac2e330.pfx

Here the CertOutputDirectory parameter is used to export the certificate configured on the application to the file system -- this is useful for interoperation with platforms and tools that do not utilize the Windows certificate store.

.EXAMPLE
New-GraphApplication "Dev app" -OutVariable newApp -SuppressCredentialWarning | New-GraphApplicationCertificate

   Application (client) ID: e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

Thumbprint              : A14AA744C84E978E761884132D62C6AB8DC1E203
AppId                   : e4ab44d2-98ac-4a33-a010-e8fa2ac2e330
Subject                 : CN=e4ab44d2-98ac-4a33-a010-e8fa2ac2e330, CN=AutoGraphPS, CN=MicrosoftGraph
FriendlyName            : Credential for Microsoft Graph Azure Active Directory application name='AutoGraphPS Application',
                          appId=e4ab44d2-98ac-4a33-a010-e8fa2ac2e330, objectId=
NotBefore               : 12/27/2021 4:10:42 PM -08:00
NotAfter                : 12/27/2022 4:10:42 PM -08:00
CertificatePath         : Cert:\CurrentUser\my\A14AA744C84E978E761884132D62C6AB8DC1E203

This example shows how the output of the New-GraphApplication command which creates a new application may be piped to New-GraphApplicationCertificate to create a local certificate and configure it for the newly created application. Note that this is equivalent to just specifying New-GraphAppication with the NewCredential parameter. One key difference is the output -- with NewCredential, New-GraphApplication returns only the application that was created, not the credential; if you need to access the actual credential, you must issue an additional invocation of the Find-GraphLocalCertificate command. If instead you pipe the output of New-GraphApplication to New-GraphApplicationcertificate as in this example, the resulting output is the certificate, so there's no need to use Find-GraphLocalCertificate.

.LINK
New-GraphLocalCertificate
Set-GraphApplicationCertificate
Get-GraphApplicationCertificate
Remove-GraphApplicationCertificate
Find-GraphLocalCertificate
Connect-GraphApi
New-GraphConnection
#>
function New-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='high', positionalbinding=$false)]
    [OutputType('AutoGraph.Certificate')]
    param(
        [parameter(position=0, parametersetname='app', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='appexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='appexportpath', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='appid', mandatory=$true)]
        [parameter(position=0, parametersetname='appidexport', mandatory=$true)]
        [parameter(position=0, parametersetname='appidexportpath', mandatory=$true)]
        [Guid] $AppId,

        [parameter(position=1)]
        [TimeSpan] $CertValidityTimeSpan,

        [DateTime] $CertValidityStart,

        [int] $CertKeyLength = 4096,

        # Note that since this creates a new certificate, we want to ensure that only app objects are piped in,
        # not certificate objects -- those do not have an objectid property, so we make the objectid mandatory
        [parameter(parametersetname='app', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='appexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='appexportpath', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='objectid', mandatory=$true)]
        [parameter(parametersetname='objectidexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='objectidexportpath', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        [Guid] $ObjectId,

        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='appexport', mandatory=$true)]
        [parameter(parametersetname='appidexport', mandatory=$true)]
        [parameter(parametersetname='objectidexport', mandatory=$true)]
        [string] $CertOutputDirectory,


        [parameter(parametersetname='appexportpath', mandatory=$true)]
        [parameter(parametersetname='appidexportpath', mandatory=$true)]
        [parameter(parametersetname='objectidexportpath', mandatory=$true)]
        [string] $CertificateFilePath,

        [parameter(parametersetname='appexport')]
        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [parameter(parametersetname='appexportpath')]
        [parameter(parametersetname='appidexportpath')]
        [parameter(parametersetname='objectidexportpath')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='appexportpath')]
        [parameter(parametersetname='appidexportpath')]
        [parameter(parametersetname='objectidexportpath')]
        [parameter(parametersetname='appexport')]
        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [switch] $NoCertCredential,

        [switch] $AsX509Certificate,

        [PSCustomObject] $Connection = $null
    )
    Enable-ScriptClassVerbosePreference

    $::.LocalCertificate |=> ValidateCertificateCreationCapability

    $certHelper = new-so CertificateHelper $AppId $ObjectId $null $CertValidityTimespan $CertValidityStart $null $CertKeyLength

    $certificateResult = $certHelper |=> NewCertificate $CertOutputDirectory $CertStoreLocation $CertCredential $NoCertCredential.IsPresent $true $CertificateFilePath
    $X509Certificate = $certificateResult.Certificate.X509Certificate

    if ( ! $AsX509Certificate.IsPresent ) {
        $::.CertificateHelper |=> CertificateToDisplayableObject $X509Certificate $certHelper.appId $certHelper.objectId $X509Certificate.PSPath $null $certificateResult.ExportedLocation
    } else {
        $X509Certificate
    }
}

