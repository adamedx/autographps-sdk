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

ScriptClass GraphApplicationCertificate {

    $AppId = $null
    $DisplayName = $null
    $CertLocation = $null
    $X509Certificate = $null

    static {
        const __AppCertificateSubjectParent 'CN=AutoGraphPS, CN=MicrosoftGraph'

        function FindAppCertificate(
            $AppId,
            $CertStoreLocation = 'cert:/currentuser/my',
            $Name
        ) {
            if ( $AppId -and $Name ) {
                throw "Only one of appid or name may be specified to search for certificates"
            }

            $certs = ls $CertStoreLocation

            if ( $AppId ) {
                $subject = __GetAppCertificateSubject $appId
                $certs | where subject -eq $subject
            } else {
                $subjectSuffix = $this.__AppCertificateSubjectParent
                $targetDisplayNameComponent = __GetAppCertificateDisplayNameComponent $Name
                $certs | where {
                    $_.subject.endswith($subjectSuffix) -and
                    ( ! $Name -or ( $_.FriendlyName.endswith($targetDisplayNameComponent ) ) )
                }
            }
        }

        function __GetAppCertificateSubject($appId) {
            "CN={0}, $($this.__AppCertificateSubjectParent)" -f $appId
        }

        function __GetAppCertificateDisplayNameComponent($name) {
            "name='$name'"
        }

        function __GetAppCertificateFriendlyName($appId, $name) {
            $nameComponent = __GetAppCertificateDisplayNameComponent $name
            "Credential for Microsoft Graph Azure Active Directory application id=$appId, $nameComponent"
        }
    }

    function __initialize($appId, $displayName, $certStoreLocation = 'cert:/currentuser/my') {
        $this.AppId = $appId
        $this.CertLocation = $certStoreLocation
        $this.DisplayName = $displayName
    }

    function Create {
        if ( $this.X509Certificate ) {
            throw 'Certificate already created'
        }

        $certStoreDestination = $this.CertLocation

        $description = $this.scriptclass |=> __GetAppCertificateFriendlyName $this.AppId $this.DisplayName
        $subject = $this.scriptclass |=> __GetAppCertificateSubject $this.AppId

        write-verbose "Creating certificate with subject '$subject'"
        $this.X509Certificate = New-SelfSignedCertificate -Subject $subject -friendlyname $description -provider 'Microsoft Enhanced RSA and AES Cryptographic Provider' -CertStoreLocation $certStoreDestination -NotBefore ([datetime]::UtcNow - [TimeSpan]::FromDays(1)) -notafter ([DateTime]::UtcNow + [TimeSpan]::fromdays(365))
    }

    function GetEncodedPublicCertificate {
        $certBytes = $this.X509Certificate.GetRawCertData()
        [Convert]::ToBase64String($certBytes)
    }

    function GetEncodedCertificateThumbprint {
        [Convert]::ToBase64String($this.X509Certificate.thumbprint)
    }
}
