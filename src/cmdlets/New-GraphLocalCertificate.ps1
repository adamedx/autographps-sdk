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

. (import-script ../common/GraphApplicationCertificate)

function New-GraphLocalCertificate {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, mandatory=$true)]
        [Guid] $AppId,

        [parameter(position=1, mandatory=$true)]
        [string] $ApplicationName,

        [parameter(position=2)]
        [TimeSpan] $CertValidityTimeSpan,

        [DateTime] $CertValidityStart,

        $CertStoreLocation = 'cert:/currentuser/my'
    )
    Enable-ScriptClassVerbosePreference

    $certificate = new-so GraphApplicationCertificate $AppId $null $ApplicationName $CertValidityTimeSpan $CertValidityStart $CertStoreLocation

    $certificate |=> Create
    $certificate.X509Certificate
}
