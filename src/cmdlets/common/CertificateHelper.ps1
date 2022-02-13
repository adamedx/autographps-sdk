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

. (import-script DisplayTypeFormatter)
. (import-script ../../graphservice/ApplicationAPI)
. (import-script ../../common/LocalCertificate)
. (import-script ../../common/Secret)
. (import-script ../../common/GraphApplicationCertificate)
. (import-script CommandContext)
. (import-script ../Set-GraphApplicationCertificate)

ScriptClass CertificateHelper {
    $appId = $null
    $objectId = $null
    $applicationName = $null
    $certValidityTimespan = $null
    $certValidityStart = $null
    $keyLength = $null
    $connection = $null
    $app = $null

    function __initialize($appId, $objectId, [string] $applicationName, $certValidityTimespan, $certValidityStart, $connection, $keyLength) {
        $this.appId = $appid
        $this.applicationName = $applicationName
        $this.certValidityTimespan = $certValidityTimespan
        $this.certValidityStart = $certValidityStart
        $this.keyLength = $keyLength
        $this.connection = $connection
        $this.app = $null
    }

    function NewCertificate([string] $certDirectory, $certStoreLocation, [PSCredential] $certCredential, [bool] $noCertCredential, [bool] $updateApplication, [string] $certificateFilePath, [int] $keyLength) {
        $targetCertCredential = __GetCertFileCredential $certDirectory $certificateFilePath $certCredential $noCertCredential

        if ( $updateApplication ) {
            __SyncApplication
        }

        $certificate = __NewLocalCertificate $certStoreLocation

        if ( $updateApplication ) {
            __UpdateApplication $certificate
        }

        $exportedCertLocation = if ( $certDirectory -or $certificateFilePath) {
            __ExportCertificate $certificate $targetCertCredential $certDirectory $certificateFilePath
        }

        [PSCustomObject] @{
            Certificate = $certificate
            ExportedLocation = $exportedCertLocation
        }
    }

    function __GetCertFileCredential([string] $certDirectory, [string] $certificateFilePath, [PSCredential] $certCredential, [bool] $noCertCredential) {
        $invalidPath = $certDirectory

        $targetDirectory = if ( $certDirectory ) {
            $certDirectory
        } elseif ( $certificateFilePath ) {
            $invalidPath = $certificateFilePath
            split-path -parent $certificateFilePath
        }

        if ( $targetDirectory ) {
            if ( ! (test-path -pathtype container $targetDirectory) ) {
                throw [ArgumentException]::new("The specified certificate output location '$invalidPath' is not a valid directory or is not contained in a valid directory")
            }

            if ( $certCredential ) {
                $certCredential
            } elseif ( ! $noCertCredential ) {
                $userName = if ( $env:user ) { $env:user } else { $env:username }
                Get-Credential -username $userName -Message "Enter password for certificate to be stored in output directory '$certDirectory'"
            }
        }
    }

    function __NewLocalCertificate($certStorelocation) {
        $certificate = new-so GraphApplicationCertificate $this.appId $null $this.applicationName $this.certValidityTimeSpan $this.certValidityStart $certStoreLocation $null $this.keyLength

        $certificate |=> Create

        $certificate
    }

    function __SyncApplication {
        if ( $this.app ) {
            throw 'The application has already been synchronized'
        }

        $commandContext = new-so CommandContext $this.connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

        $app = if ( $this.AppId ) {
            $appAPI |=> GetApplicationByAppId $this.appId
        } else {
            $appAPI |=> GetApplicationByObjectId $this.objectId
        }

        if ( ! $this.objectId ) {
            $this.objectId = $app.id
        } elseif ( $app.id -ne $this.objectId ) {
            throw "The object id '$($this.objectId)' specified for the application did not match the actual application object id '$($app.id)'"
        }

        if ( ! $this.appId ) {
            $this.appId = $app.appId
        } elseif ( $app.id -ne $this.objectId ) {
            throw "The app id '$($this.appId)' specified for the application did not match the actual application app id '$($app.appId)'"
        }

        if ( ! $this.applicationName ) {
            $this.applicationName = $app.displayName
        }

        $this.app = $app
    }

    function __UpdateApplication($certificate) {
        if ( ! $this.app ) {
            throw 'The application must be queried before performing this operation'
        }

        $connectionParameter = @{}

        if ( $this.connection ) {
            @{Connection = $this.connection}
        }

        Set-GraphApplicationCertificate -AppId $this.appId -ObjectId $this.objectId -Certificate $certificate.X509Certificate
    }

    function __ExportCertificate($certificate, [PSCredential] $exportedCertCredential, [string] $certOutputDirectory, [string] $certificateFilePath ) {
        $certpassword = if ( $exportedCertCredential ) {
            $exportedCertCredential.Password
        }

        $certificate |=> Export $certOutputDirectory $certificateFilePath $certPassword
    }

    static {
        const CERTIFICATE_DISPLAY_TYPE 'AutoGraph.Certificate'

        function __initialize {
            __RegisterDisplayType
        }

        function CertificateInfoToDisplayableObject($friendlyName, $subject, $graphKeyId, $appId, $appObjectId, $notBefore, $notAfter, $thumbprint, $certificatePath, $exportedCertificatePath) {
            $::.Secret |=> ToDisplayableSecretInfo Certificate $friendlyName $subject $graphKeyId $appId $appObjectId $notBefore $notAfter $thumbprint $certificatePath $CERTIFICATE_DISPLAY_TYPE $exportedCertificatePath
        }

        function CertificateToDisplayableObject($x509Certificate, $appId, $appObjectId, $certStorePath, $keyId, $certificateFilePath) {
            $notAfter = [DateTimeOffset]::new($x509Certificate.notAfter)
            $notBefore = [DateTimeOffset]::new($x509Certificate.notBefore)

            $targetPath = if ( $certStorePath ) {
                __NormalizeCertStorePath $certStorePath
            } else {
                $certificateFilePath
            }

            CertificateInfoToDisplayableObject $x509Certificate.FriendlyName $x509Certificate.Subject $null $appId $appObjectId $notBefore $notAfter $x509Certificate.Thumbprint $targetPath $certificateFilePath
        }

        function GetConnectionCertCredential($connection, [PSCredential] $certCredential, [boolean] $promptForCertCredentialIfNeeded, [boolean] $noCertCredential) {
            if ( ! $noCertCredential -and ( $certCredential -or $promptForCertCredentialIfNeeded ) ) {
                $targetCertificatePath = $connection |=> GetCertificatePath

                $targetCertCredential = if ( $promptForCertCredentialIfNeeded -and $targetCertificatePath ) {
                    $::.LocalCertificate |=> PromptForCertificateCredential $targetCertificatePath
                } else {
                    $certCredential
                }
                $targetCertCredential.Password
            }
        }

        function __RegisterDisplayType {
            $typeProperties = @(
                'Thumbprint'
                'AppId'
                'KeyId'
                'FriendlyName'
                'Subject'
                'NotAfter'
                'AppId'
                'KeyId'
                'CertificatePath'
                'NotBefore'
                'AppObjectId'
            )

            $::.DisplayTypeFormatter |=> RegisterDisplayType $CERTIFICATE_DISPLAY_TYPE $typeProperties $true
        }

        function __NormalizeCertStorePath([string] $certStorePath) {
            $driveAndPath = $certStorePath -split '::'

            if ( $driveAndPath.length -eq 2 ) {
                join-path -Path 'Cert:' -ChildPath $driveAndPath[1]
            } else {
                $certStorePath
            }
        }
    }
}

$::.CertificateHelper |=> __initialize
