# Copyright 2018, Adam Edwards
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
            if ( $secret -is [System.Security.Cryptography.X509Certificates.X509Certificate2] ) {
                $this.data = $secret
            } elseif ( $secret -is [string] ) {
                $certPath = if ( split-path -isabsolutepath $secret ) {
                    if ( (split-path -qualifier $secret ) -eq 'cert:' ) {
                        $secret
                    }
                    throw [ArgumentException]::new("Path '{0}' was not a valid absolute or relative path in the PowerShell cert: drive")
                } else {
                    join-path 'cert:\currentuser\my' $secret
                }

                $this.data = gi $certPath
            } else {
                throw [ArgumentException]::new("Secret was of invalid type '{0}', it must be a [SecureString], [X509Certificate2], or [String] path to a certificate in the PowerShell certificate drive" -f $secret.gettype())
            }
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
}
