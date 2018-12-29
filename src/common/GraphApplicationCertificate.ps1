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

ScriptClass GraphApplicationCertificate {

    $AppId = $null
    $ObjectID = $null
    $DisplayName = $null
    $CertLocation = $null
    $X509Certificate = $null
    $NotBefore = $null
    $validityTimeSpan = $null

    static {
        const __AppCertificateSubjectParent 'CN=AutoGraphPS, CN=MicrosoftGraph'

        function FindAppCertificate(
            $AppId,
            $CertStoreLocation = 'cert:/currentuser/my',
            $Name,
            $ObjectId
        ) {
            $argCount = if ( $AppId ) { 1 } else { 0 }
            $argCount += if ( $ObjectId ) { 1 } else { 0 }
            $argCount += if ( $Name ) { 1 } else { 0 }

            if ( $argCount -gt 1 ) {
                throw "Only one of appid or name may be specified to search for certificates"
            }

            $certs = ls $CertStoreLocation

            if ( $AppId ) {
                $subject = __GetAppCertificateSubject $appId
                $certs | where subject -eq $subject
            } else {
                $searchTarget = if ( $ObjectId )  {
                    __GetAppCertificateObjectIdComponent $ObjectId
                } elseif ( $Name ) {
                    __GetAppCertificateDisplayNameComponent $Name
                }

                $subjectSuffix = $this.__AppCertificateSubjectParent
                $certs | where {
                    $_.subject.endswith($subjectSuffix) -and
                    ( ! $searchTarget -or ( $_.FriendlyName.tolower().contains($searchTarget.tolower()) ) )
                }
            }
        }

        function __GetAppCertificateSubject($appId) {
            "CN={0}, $($this.__AppCertificateSubjectParent)" -f $appId
        }

        function __GetAppCertificateDisplayNameComponent($name) {
            "name='$name'"
        }

        function __GetAppCertificateObjectIdComponent($objectId) {
            "objectId=$objectId"
        }

        function __GetAppCertificateFriendlyName($appId, $name, $objectId) {
            $nameComponent = __GetAppCertificateDisplayNameComponent $name
            $objectIdComponent = __GetAppCertificateObjectIdComponent $objectId
            "Credential for Microsoft Graph Azure Active Directory application $nameComponent, appId=$appId, $objectIdComponent"
        }
    }

    function __initialize($appId, $objectId, $displayName, $validityTimeSpan, $notBefore, $certStoreLocation = 'cert:/currentuser/my') {
        $this.ObjectId = $objectId
        $this.AppId = $appId
        $this.CertLocation = $certStoreLocation
        $this.DisplayName = $displayName
        $this.NotBefore = $NotBefore
        $this.validityTimeSpan = $validityTimeSpan
    }

    function Create {
        if ( $this.X509Certificate ) {
            throw 'Certificate already created'
        }

        $certStoreDestination = $this.CertLocation

        $description = $this.scriptclass |=> __GetAppCertificateFriendlyName $this.AppId $this.DisplayName $this.ObjectId
        $subject = $this.scriptclass |=> __GetAppCertificateSubject $this.AppId

        $notBefore = if ( $this.NotBefore ) {
            $this.NotBefore.ToLocalTime()
        } else {
            ([datetime]::Now - [TimeSpan]::FromMinutes(1)).ToLocalTime()
        }

        $validityTimeSpan = if ( $this.validityTimeSpan ) {
            $this.validityTimeSpan
        } else {
            [TimeSpan]::FromDays(365)
        }

        $notAfter = $notBefore + $validityTimeSpan

        write-verbose "Creating certificate with subject '$subject'"
        $this.X509Certificate = New-SelfSignedCertificate -Subject $subject -friendlyname $description -provider 'Microsoft Enhanced RSA and AES Cryptographic Provider' -CertStoreLocation $certStoreDestination -NotBefore $notBefore -NotAfter $notAfter
    }

    function GetEncodedPublicCertificate {
        $certBytes = $this.X509Certificate.GetRawCertData()
        [Convert]::ToBase64String($certBytes)
    }

    function GetEncodedCertificateThumbprint {
        [Convert]::ToBase64String($this.X509Certificate.thumbprint)
    }
}
