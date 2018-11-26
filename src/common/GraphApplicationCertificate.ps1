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
    $CertLocation = $null
    $X509Certificate = $null

    static {
        function GetAppCertificateSubjectParent {
            'CN=AutoGraphPS, CN=MicrosoftGraph'
        }
    }

    function __initialize($appId, $certStoreLocation = 'cert:/currentuser/my') {
        $this.AppId = $appId
        $this.CertLocation = $certStoreLocation
    }

    function GetAppCertificateSubject {
        "CN={0}, $($this.scriptclass |=> GetAppCertificateSubjectParent)" -f $this.AppId
    }

    function __GetAppCertificateSubjectParent {
        'CN=AutoGraphPS, CN=MicrosoftGraph'
    }

    function Create {
        if ( $this.X509Certificate ) {
            throw 'Certificate already created'
        }

        $certStoreDestination = $this.CertLocation

        $description = "Credential for Microsoft Graph Azure Active Directory application id=$($this.appId)"
        $subject = GetAppCertificateSubject $this.AppId

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
