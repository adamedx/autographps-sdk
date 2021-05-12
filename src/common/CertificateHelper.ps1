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

ScriptClass CertificateHelper {
    static {
        function GetCertificateFromFile([string] $certificatePath, [bool] $private, [PSCredential] $certPassword) {
            if ( $certificatePath -notlike '*.pfx' -and $private ) {
                throw "A certificate with private data is required, but the specified certificate path '$certificatePath' is not a '.pfx' file"
            }

            if ( $certPassword ) {
                [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certificatePath, $certPassword)
            } else {
                [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certificatePath)
            }
        }

        function GetEncodedPublicCertificateData([System.Security.Cryptography.X509Certificates.X509Certificate2] $certificate) {
            $certBytes = $certificate.GetRawCertData()
            [Convert]::ToBase64String($certBytes)
        }

        function GetEncodedCertificateThumbprint([System.Security.Cryptography.X509Certificates.X509Certificate2] $certificate) {
            [Convert]::ToBase64String($certificate.thumbprint)
        }

        function GetCertificateItemFromPath([string] $certificatePath, [string] $certStoreLocation) {
            $useCertStore = $null
            $certificatePath, $certStoreLocation | foreach {
                $targetPath = $_
                if ( $targetPath ) {
                    $isCertStorePath = $targetPath -like 'cert:*'

                    if ( $useCertStore -ne $null ) {
                        if ( $useCertStore -ne $isCertStorePath ) {
                            throw "The specified set of certificates contains a mix of certificates stored in the file system and in the certificate store -- the set must contain certificates from only one of these locations"
                        }
                    } else {
                        $useCertStore = $isCertStorePath
                    }

                    if ( $isCertStorePath -and [System.Environment]::OSversion.Platform -ne 'Win32NT' ) {
                        throw "The Windows certificate store path '$targetPath' is only valid on the Windows platform, and this session is hosted on the $($[System.Environment]::OSVersion.Platform). Instead, specify a path to a certificate file stored in the file system which is supported on all platforms."
                    }
                }
            }

            $pathPrefix = if ( $certStoreLocation ) {
                $certStoreLocation
            }

            $targetPath = if ( $pathPrefix ) {
                join-path $pathPrefix $certificatePath
            } else {
                $certificatePath
            }

            if ( ! ( test-path $targetPath ) ) {
                throw "The specified path '$targetPath' could not be found."
            }

            get-item $targetPath
        }

        function GetCertificateFromPath([string] $certificatePath, [string] $certStoreLocation, [bool] $private, [PSCredential] $certPassword) {
            $targetItem = GetCertificateItemFromPath $certificatePath $certStoreLocation $private $certPassword

            if ( $targetItem -is [System.Security.Cryptography.X509Certificates.X509Certificate2] ) {
                $targetItem
            } else {
                GetCertificateFromFile $targetItem.FullName
            }
        }
    }
}
