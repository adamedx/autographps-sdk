# Copyright 2019, Adam Edwards
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

enum SecretType {
    Certificate
    Password
}

ScriptClass Secret {
    $data = $null
    $type = $null

    function __initialize($secret) {

        if ( ! $secret ) {
            throw [ArgumentException]::new('Secret was null or an empty string')
        }

        if ( $secret -is [SecureString] ) {
            $this.type = ([SecretType]::Password)
            $this.data = $secret
        } else {
            $this.type = ([SecretType]::Certificate)
            $certificate = if ( $secret -is [System.Security.Cryptography.X509Certificates.X509Certificate2] ) {
                $secret
            } elseif ( $secret -is [string] ) {
                $certPath = if ( split-path -isabsolute $secret ) {
                    if ( (split-path -qualifier $secret ) -eq 'cert:' ) {
                        $secret
                    } else {
                        throw [ArgumentException]::new("Path '{0}' was not a valid absolute or relative path in the PowerShell cert: drive" -f $secret)
                    }
                } else {
                    join-path 'cert:\currentuser\my' $secret
                }

                gi $certPath
            } else {
                throw [ArgumentException]::new("Secret was of invalid type '{0}', it must be a [SecureString], [X509Certificate2], or [String] path to a certificate in the PowerShell certificate drive" -f $secret.gettype())
            }

            __ValidateCertificate $certificate
            $this.data = $certificate
        }
    }

    function GetSecretData {
        switch ( $this.type ) {
            ([SecretType]::Certificate) {
                $this.data
            }
            ([SecretType]::Password) {
                __DecryptSecureString $this.data
            }
            default {
                throw [ArgumentException]::("Unknown secret type '{0}'" -f $this.tostring())
            }
        }
    }

    function __DecryptSecureString( $secureString ) {
        $pscred = new-object PSCredential '.', $SecureString
        $pscred.GetNetworkCredential().Password
    }

    function __ValidateCertificate( $certificate ) {
        $certDescription = "thumbprint = {0}, subject = {1}" -f $certificate.thumbprint, $certificate.subject
        if ( ! $certificate.hasprivatekey ) {
            throw [ArgumentException]::new("The specified certificate '$certDescription' does not have a private key")
        }

        if ( ! $certificate.privatekey ) {
            $knownGoodProviders = @('Microsoft Enhanced RSA and AES Cryptographic Provider', 'Microsoft RSA SChannel Cryptographic Provider') -join "`n"
            throw [ArgumentException]::new("The specified certificate '$certDescription' is marked as having a private key, but no private key data is available through the [X509Certificate2] type. Try with a new certificate with a different cryptographic provider. If you use the 'New-SelfSignedCertificate' cmdlet, you can specify the provider through the '-provider' option. Providers known to be compatible with the [X509Certificate2] type include and are not limited to the following:`n$knownGoodProviders")
        }

        $currentTime = [DateTime]::Now

        if ( $certificate.NotAfter.CompareTo($currentTime) -lt 0 ) {
            throw [ArgumentException]::new(("The specified certificate '$certDescription' is expired -- current time is '{0}' and the certificate expiration time is '{1}'" -f $currentTime, $certificate.NotAfter))
        }

        if ( $certificate.NotBefore.CompareTo($currentTime) -gt 0 ) {
            write-warning ("Certificate '$certDescription': Current time is {0}, specified certificate is not valid before {1}" -f $currentTime, $certificate.NotBefore)
        }
    }
}
