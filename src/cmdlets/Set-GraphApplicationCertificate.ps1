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
. (import-script ../common/LocalCertificate)
. (import-script common/CommandContext)

<#
.SYNOPSIS
Sets the certificates configured for use as credentials for an Entra ID application identity.

.DESCRIPTION
Certificate credential configuration on the application object allows running application code to obtain access tokens with the application's identity. Set-GraphApplicationCertificate configures the set of certificates used as credentials for the application. Runtime code with access to the private key associated with a certificate configured for the application will be able to authenticate as the application.

The application to modify may be specified either by the application object's application identifier via the AppId parameter or by the application's directory object identifier through the AppObjectId parameter.

There are four ways to specify the certificates to configure for the application:
    * The AppId parameter along with the optionally specified CertStoreLocation parameter allows the command to search for a certificate in the certificate store that is marked as supporting that application identifier -- if only one such matching certificate exists, then that certificate is used to configure the application. This capability is supported only on the Windows platform since it requires the PowerShell cert: drive.
    * Specify an array of string representations of the certificates' thumbprints via the Thumbprint parameter. This thumbprints must be thumbprints of certificates located under a certain path of the Windows certificate store. This path is configured by the CertStoreLocation parameter, which defaults to the path 'cert:/currentuser/my'. The Thumbprint parameter is currently only valid for the Windows platform.
    * Specify a string array of paths to certificates using the CertificatePath parameter. These paths may be paths to certificates in the Windows certificate store or file system paths to supported serialized public key certificates. Supported file formats for certificates stored in the file system include .cer, .crt, and .pfx. On Windows, both certificate store paths (those starting with 'cert:/') and file system paths are supported. On non-Windows operating systems, the path must be a file system path to a supported certificate file format.
    * Use the Certificate parameter to supply an array of System.Security.Cryptography.X509Certificate.X509Certificate2 public key certificates objects. This capability is useful when already have access to certificates in serialized formats, especially when they are obtained from a certificate authority. See the parameter documentation for the Certificate parameter for more details on ways to obtain certificates in this representation.

By default, Set-GraphApplicationCertificate will attempt to add the specified certificates to the application configuration; certificates that are already configured for the application will still be configured after Set-GraphApplicationCertificate completes the add operation. The EditMode parameter may be specified to override this behavior so that the set of certificates for the application is overwritten by the set specified to the command. When EditMode is specified as 'Replace', any certificates that are configured for the application before Set-GraphApplicationCertificate is invoked will no longer be configured after the command completes unless those certificates were specified as parameters to the command.

.PARAMETER AppId
The Entra ID application identifier of the application for which to configure certificates.

.PARAMETER AppObjectId
The object identifier of the application for which to configure certificates.

.PARAMETER CertificatePath
Specifies an array of paths in the file system or in the PowerShell cert: drive provider for a certificate to be configured as a credential for the application to access the Graph API.

.PARAMETER EditMode
Specifies whether to add the certificates specified to the command to the application's certificate configuration, preserving any certificates that already exist in the configuration. The default value of Add conforms to this behavior. Specify a value of Replace so that only the certificates specified to the command are present in the configuration after the command is complete, 'replacing' the set of existing certificates.

.PARAMETER Thumbprint
Enables specifcation of certificates using Thumbprints of certificates in the 'cert:' drive (i.e. the Windows certificate store). The thumbprints must refer to certificates found in the location specified by the CertStoreLocation parameter. The Thumbprint parameter is currently only valid on the Windows platform.

.PARAMETER CertStoreLocation
Specifies the location in the certificate store in which to lookup certificates specified by the Thumbprint parameter. By default, this location is 'cert:/currentuser/my'. The CertStoreLocation parameter only applies on the Windows platform because the certificate store is currently implemented only for Windows.

.PARAMETER Certificate
Specifies an array of System.Security.Cryptography.X509Certificate.X509Certificate2 public key certificate objects to be configured for the application. Objects of this type are obtained from certificate management commands like Find-GraphLocalCertificate and New-SelfSignedCertificate or by enumerating certificates in the Windows certificate store using a command such as 'Get-ChildItem cert:/currentuser/my'. The .NET framework classes including X509Certificate2 support constructors and methods for creating certificate objects from serialized formats retreived over network protocols or file systems.

.PARAMETER CertCredential
Specifies an array of PSCredential objects that can be obtained through commands such as Get-Credential. These credential objects are used to access a file-system certificate if that certificate contains a private key. The element at a given index of the array must correspond to the credential required to access the certificate at the same array index of the certificate array specified by the CertificatePath parameter. This parameter is only required if you specify a file system certificate with a private key -- note that in this case as in all cases the application will be configured only using the public key and the command does not use the private key at all, it simply may need the credential to access the public part of the certificate since the entire certificate is protected with a credential.

.PARAMETER PromptForCertCredential
By default, if a certificate supplied by the CertificatePath parameter requires a credential but none is specified by the CertCredential parameter, the command will simply fail. To instruct the command to query the user invoking it for the credential, specify the PromptForCertCredential parameter. When a missing credential is encountered, the command will prompt for secure user input to obtain the credential. This means the PromptForCertCredential parameter is not suitable for unattended scenarios since it will block execution waiting for user input.

.PARAMETER Connection
Specify the Connection parameter to use as an alternative connection to the current connection.

.OUTPUTS
The command produces no output.

.EXAMPLE
Set-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -Thumbprint D152B20A07EFD6E5973AFAD1631069CACDDF0297

This example demonstrates how to specify the certificate to configure using the Thumbprint parameter of Set-GraphApplicationCertificate.

.EXAMPLE
Set-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -Thumbprint D152B20A07EFD6E5973AFAD1631069CACDDF0297, F8FFD55CDC95F8BDBAAEB87916C3301348F8D43B -EditMode Replace

This example demonstrates how multiple certificates may be configured using a single command invocation. Here multiple certificates in the local certificate store are specified by suppling their values as an array to the Thumbprint parameter. The Set-GraphApplicationCertificate command will configure those certificates using a single Graph API request -- since the EditMode parameter is set to Replace, only those certificates specified to the command will remain configured after it is finished. The command also supports the default EditMode of Add in those where multiple certificates are specified.

.EXAMPLE
Set-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -CertificatePath Cert:\LocalMachine\My\A152B20A07EFD6E5973AFA91631069CACDDF0298

Here the certificate to configure additively on the application is specified by path using a certificate store 'cert:' path, rather than thumbprint.

.EXAMPLE
Set-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -CertificatePath ~/protectedcerts/$($certFilename).pfx -PromptForCertCredential

This example demonstrates the use of a certificate path in the file system to specify the certificate to configure for the application. This is useful on non-Windows systems such as Linux which do not support the PowerShell certificate store.

.EXAMPLE
New-GraphLocalCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330
Set-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

In this example a new certificate is created with the New-GraphApplication command, and then Set-GraphApplication is used to configure the application to use it. Note that the certificate does not need to be explicitly specified here, as the Set-GraphApplicationCertificate looks up the certificate by the application's application identifier in the local certificate store, and if it finds exactly one such certificate, it uses that certificate's public key to configure the application in the directory. Note that this implicit specification will not work if there is more than one certificate in the local certificate store with a matching application identifier.

.EXAMPLE
New-GraphLocalCertficate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 | Set-GraphApplicationCertificate
Connect-GraphApi -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -Confidential -NoninteractiveAppOnlyAuth

In this example, a new certificate for a specific application is created locally in the system's certificate store and then passed to Set-GraphApplicationCertificate via the pipeline, which addds the certificate to that application's configuration in the directory. The Connect-GraphApi command is then used to connect to the application -- it will use the newly created certificate if it is the only certificate configured for that application to authenticate. Note that there may be a delay between the use of Set-GraphApplicationCertificate and Connect-GraphApi's ability to successfully authenticate -- waiting for a few seconds or minutes to retry invocation of Connect-GraphApi should resolve such delays.

.EXAMPLE
New-GraphLocalCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -OutVariable newCert | Set-GraphApplicationCertificate -EditMode Replace
$connection = New-GraphConnection -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -CertificatePath $newCert.CertificatePath -NoninteractiveAppOnlyAuth
Get-GraphResource /organization -Connection $connection

This example is similar to the previous case, except the newly created certificate is also stored in the $newCert variable using the OutVariable parameter of New-GraphLocalCertificate before it is also piped to Set-GraphApplicationCertificate to configure the application. Then, instead of using Connect-GraphApi, New-GraphConnection is used to create a connnection using the CertificatePath property from $newCert to specify the CertificatePath property. Then Get-GraphResource uses the explicitly specified new connection to issue a request to the Graph API.

.EXAMPLE
New-GraphApplication 'Stats application' -ApplicationPermissions Organization.Read.All -Confidential -OutVariable statsApp -SuppressCredentialWarning |
    New-GraphLocalCertificate | Set-GraphApplicationCertificate

This example shows how the pipeline may be used to emulate the behavior of New-GraphApplication's NewCredential parameter. By default, applications created by New-GraphApplication don't have any configured credential, though the NewCredential parameter may be specified to create a local certificate and configure it for the application. Here the same result is accomplished without the NewCredential parameter by piping the result of New-GraphApplication to New-GraphLocalCertificate, which creates a local certificate for that application. The application is still not configured in the directory until the result of New-GraphLocalCertificate is piped to Set-GraphApplicationCertificate, which configures the application with the newly created certificate. The SuppressCredentialWarning option is used to avoid the warning message that is displayed when no credential is specified for New-GraphApplication, and OutVariable captures the output of New-GraphApplication while still allowing it to be piped to New-GraphLocalCertificate so that the user has a way to reference the newly created application for use in creating connections or maintaining a list of applications.

.LINK
New-GraphApplication
New-GraphLocalCertificate
Get-GraphApplicationCertificate
Remove-GraphApplicationCertificate
Find-GraphLocalCertificate
Connect-GraphApi
New-GraphConnection
#>
function Set-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='high', positionalbinding=$false)]
    param(
        [parameter(position=0, valuefrompipelinebypropertyname=$true)]
        [Guid] $AppId,

        [Alias('Id')]
        [Alias('ObjectId')]
        [string] $AppObjectId,

        [parameter(position=1, parametersetname='path', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [string[]] $CertificatePath,

        [parameter(position=2)]
        [ValidateSet('Add', 'Replace')]
        $EditMode = 'Add',

        [parameter(parametersetname='thumb', mandatory=$true)]
        [string[]] $Thumbprint,

        [parameter(parametersetname='path')]
        [parameter(parametersetname='thumb')]
        [string] $CertStoreLocation = 'Cert:/currentuser/my',

        [parameter(parametersetname='cert', mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2[]] $Certificate,

        [parameter(parametersetname='path')]
        [PSCredential[]] $CertCredential,

        [parameter(parametersetname='path')]
        [Switch] $PromptForCertCredential,

        [PSCustomObject] $Connection = $null
    )

    begin {
        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version
    }

    process {
        if ( ! $AppObjectId -and ! $AppId ) {
            throw "Either a valid value for AppId or AppObjectId must be specified"
        }

        $targetObjectId = $AppObjectId
        $targetAppId = $AppId

        $targetObject = if ( ! $targetObjectId -or $EditMode -eq 'Add' ) {
            $application = $appAPI |=> GetApplicationByObjectIdOrAppId $targetObjectId $targetAppId
            $targetObjectId = $application.id
            $targetAppId = $application.appId
            $application
        } else {
            [PSCustomObject] @{id=$targetObjectId}
        }

        $targetCertificates = if ( $Certificate ) {
            $Certificate
        } elseif ( $Thumbprint ) {
            $storePaths = foreach ( $thumbprintItem in $Thumbprint ) {
                join-path -Path $CertStoreLocation -ChildPath $thumbprintItem
            }

            $storePaths | get-item
        } else {
            $certCredentialCount = ( $CertCredential | Measure-Object ).Count
            $certCount = ( $CertificatePath | Measure-Object ).Count

            $hasMultipleCertCredentials = $certCredentialCount -gt 1

            if ( $hasMultipleCertCredentials -and ( $certCredentialCount -ne $certCount ) ) {
                Write-Error "More than one certificate credential was specified, but their count ($certCredentialCount) was different than the number of certificate files ($certCount) specified. Specify exactly one credential to be used for all certificates, or specify exactly one for each certificate file path specified"
            }

            $certIndex = 0

            foreach ( $certificatePathElement in $CertificatePath ) {
                $targetCertCredential = if ( $CertCredential ) {
                    if ( $hasMultipleCertCredentials ) {
                        $CertCredential | select -index $certIndex++
                    } else {
                        $CertCredential
                    }
                } elseif ( $PromptForCertCredential.IsPresent ) {
                    $::.LocalCertificate |=> PromptForCertificateCredential $certificatePathElement
                }

                $::.GraphApplicationCertificate |=> LoadFrom $targetAppId $targetObjectId $certificatePathElement $null $targetCertCredential
            }
        }

        $preserveExisting = $EditMode -ne 'Replace'

        if ( ! $preserveExisting ) {
            if ( ! $pscmdlet.shouldprocess("Object id=$($targetObjectId) for application id=$($targetAppId)", 'Existing certificates will be REPLACED and not added to by the specified certificates') ) {
                return
            }
        }

        $appAPI |=> AddKeyCredentials $targetObject.id $targetObject.keyCredentials $targetCertificates $preserveExisting $false
    }

    end {
    }
}
