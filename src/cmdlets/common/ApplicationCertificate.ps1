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
. (import-script ../../common/GraphApplicationCertificate)
. (import-script CommandContext)
. (import-script ../Set-GraphApplicationCertificate)

ScriptClass ApplicationCertificate {
    $appId = $null
    $objectId = $null
    $applicationName = $null
    $certValidityTimespan = $null
    $certValidityStart = $null
    $connection = $null
    $app = $null

    function __initialize($appId, $objectId, [string] $applicationName, $certValidityTimespan, $certValidityStart, $connection) {
        $this.appId = $appid
        $this.applicationName = $applicationName
        $this.certValidityTimespan = $certValidityTimespan
        $this.certValidityStart = $certValidityStart
        $this.connection = $connection
        $this.app = $null
    }

    function NewCertificate([string] $certDirectory, $certStoreLocation, [PSCredential] $certCredential, [bool] $noCertCredential, [bool] $updateApplication) {
        $targetCertCredential = __GetCertCredentialForDirectory $certDirectory $certCredential $noCertCredential

        if ( $updateApplication ) {
            __SyncApplication
        }

        $certificate = __NewLocalCertificate $certStoreLocation

        if ( $updateApplication ) {
            __UpdateApplication $certificate
        }

        $exportedCertLocation = if ( $certDirectory ) {
            __ExportCertificate $certificate $targetCertCredential $certDirectory
        }

        [PSCustomObject] @{
            Certificate = $certificate
            ExportedLocation = $exportedCertLocation
        }
    }

    function __GetCertCredentialForDirectory([string] $certDirectory, [PSCredential] $certCredential, [bool] $noCertCredential) {
        if ( $certDirectory ) {
            if (! (test-path -pathtype container $certDirectory) ) {
                throw [ArgumentException]::new("The specified certificate output directory '$certDirectory' is not a valid directory")
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
        $certificate = new-so GraphApplicationCertificate $this.appId $null $this.applicationName $this.certValidityTimeSpan $this.certValidityStart $certStoreLocation

        $certificate |=> Create

        $certificate
    }

    function __SyncApplication {
        if ( $this.app ) {
            throw 'The applicatio has already been synchronized'
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

    function __ExportCertificate($certificate, [PSCredential] $exportedCertCredential, [string] $certOutputDirectory) {
        $certpassword = if ( $exportedCertCredential ) {
            $exportedCertCredential.Password
        }

        $certificate |=> Export $CertOutputDirectory $certPassword
    }

    static {
        $certFormatter = $null

        function __initialize {
            $this.certFormatter = new-so DisplayTypeFormatter GraphAppCertDisplayType 'Thumbprint', 'NotAfter', 'AppId', 'CertificatePath'
        }

        function CertificateToDisplayableObject($x509Certificate, $appId, $appObjectId, $certificateFilePath) {
            $notAfter = [DateTimeOffset]::new($x509Certificate.notAfter)
            $notBefore = [DateTimeOffset]::new($x509Certificate.notBefore)

            $targetPath = if ( $certificateFilePath ) {
                $certificateFilePath
            } else {
                $certStorePath = $x509Certificate.PSPath -split '::'
                $components = $certStorePath -split '::'
                $componentCount = ( $components | measure-object ).count
                if ( $componentCount -gt 1) {
                    join-path 'cert:' ( $components[1..($componentCount - 1)] -join ( [System.IO.Path]::DirectorySeparatorChar ) )
                } else {
                    $cerStorePath
                }
            }

            $remappedObject = [PSCustomObject] @{
                AppObjectId = $appObjectId
                AppId = $appId
                Thumbprint = $x509Certificate.Thumbprint
                NotAfter = $notAfter
                NotBefore = $notBefore
                FriendlyName = $x509Certificate.FriendlyName
                CertificatePath = $targetPath
            }

            $this.certFormatter |=> DeserializedGraphObjectToDisplayableObject $remappedObject
        }

        function GetConnectionCertCredential($connection, [PSCredential] $certCredential, [boolean] $promptForCertCredentialIfNeeded, [boolean] $noCertCredential) {
            if ( ! $noCertCredential -and ( $certCredential -or $promptForCertCredentialIfNeeded ) ) {
                $targetCertificatePath = $connection |=> GetCertificatePath

                $targetCertCredential = if ( $promptForCertCredentialIfNeeded -and $targetCertificatePath ) {
                    $::.CertificateHelper |=> PromptForCertificateCredential $targetCertificatePath
                } else {
                    $certCredential
                }
                $targetCertCredential.Password
            }
        }
    }
}

$::.ApplicationCertificate |=> __initialize
