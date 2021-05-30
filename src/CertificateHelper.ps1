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
        function GetCertificateFromFile([string] $certificatePath, [bool] $private, [SecureString] $certPassword) {
            if ( $certificatePath -notlike '*.pfx' -and $certificatePath -and $private ) {
                write-warning "A certificate with private data is required, but the specified certificate path '$certificatePath' is not a '.pfx' or '.pfx' file"
            }

            if ( $certPassword ) {
                $pscred = new-object PSCredential '.', $certPassword
                $decryptedPassword = $pscred.GetNetworkCredential().Password

                [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certificatePath, $decryptedPassword)
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

        function GetCertificateItemFromPath([string] $certificatePath, [string] $certStoreLocation, [string] $fileSystemLocation) {
            $parentPath = if ( ! ( split-path -isabsolute $certificatePath ) ) {
                if ( $certStoreLocation -and ! $certificatePath.Contains('.') ) {
                    $certStoreLocation
                } elseif ( $fileSystemLocation ) {
                    $fileSystemLocation
                }
            }

            $targetPath = if ( $parentPath ) {
                join-path $certStoreLocation $certificatePath
            } else {
                $certificatePath
            }

            $isCertStorePath = IsCertStorePath $targetPath

            if ( $isCertStorePath -and [System.Environment]::OSversion.Platform -ne 'Win32NT' ) {
                throw [ArgumentException]::new("The Windows certificate store path '$targetPath' is only valid on the Windows platform, and this session is hosted on the $($[System.Environment]::OSVersion.Platform). Instead, specify a path to a certificate file stored in the file system which is supported on all platforms.")
            }

            if ( ! ( test-path $targetPath ) ) {
                throw "The specified path '$targetPath' for the certificate is not a valid file system path or secret store path and could not be found."
            }

            get-item $targetPath
        }

        function GetCertificateFromPath([string] $certificatePath, [string] $certStoreLocation, [bool] $private, [SecureString] $certPassword) {
            $targetItem = GetCertificateItemFromPath $certificatePath $certStoreLocation

            if ( $targetItem -is [System.Security.Cryptography.X509Certificates.X509Certificate2] ) {
                $targetItem
            } else {
                GetCertificateFromFile $targetItem.FullName $private $certPassword
            }
        }

        function PromptForCertificateCredential($certificatePath, $promptMessage, $userName) {
            if ( ! ( IsCertStorePath $certificatePath ) ) {
                $targetUser = if ( $userName ) {
                    $userName
                } else {
                    if ( $env:user ) {
                        $env:user
                    } elseif ( $env:username ) {
                        $env:username
                    } elseif ( $env:USER ) {
                        $env:USER
                    } else {
                        'User'
                    }
                }

                $targetPromptMessage = if ( $promptMessage ) {
                    $promptMessage
                } else {
                    "Enter the password for the certificate at '$certificatePath' or enter nothing if there is no password"
                }

                Get-Credential -username $targetUser -Message $targetPromptMessage
            }
        }

        function IsCertStorePath($certificatePath) {
            $isCertStorePath = ( split-path -qualifier $certificatePath ) -eq 'cert:'
        }
    }
}
