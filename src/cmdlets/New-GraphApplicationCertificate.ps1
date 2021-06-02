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

. (import-script common/CertificateHelper)

function New-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='high', positionalbinding=$false)]
    [OutputType('AutoGraph.Certificate')]
    param(
        [parameter(position=0, parametersetname='app', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='appexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='appid', mandatory=$true)]
        [parameter(position=0, parametersetname='appidexport', mandatory=$true)]
        [Guid] $AppId,

        [parameter(position=1)]
        [TimeSpan] $CertValidityTimeSpan,

        [DateTime] $CertValidityStart,

        # Note that since this creates a new certificate, we want to ensure that only app objects are piped in,
        # not certificate objects -- those do not have an objectid property, so we make the objectid mandatory
        [parameter(parametersetname='app', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='appexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='objectid', mandatory=$true)]
        [parameter(parametersetname='objectidexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        [Guid] $ObjectId,

        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='appexport', mandatory=$true)]
        [parameter(parametersetname='appidexport', mandatory=$true)]
        [parameter(parametersetname='objectidexport', mandatory=$true)]
        [string] $CertOutputDirectory,

        [parameter(parametersetname='appexport')]
        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='appexport')]
        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [switch] $NoCertCredential,

        [switch] $AsX509Certificate,

        [Alias('Connection')]
        [PSCustomObject] $ConnectionInfo = $null
    )
    Enable-ScriptClassVerbosePreference

    $Connection = if ( $ConnectionInfo ) {
        $ConnectionInfo.Connection
    }

    $::.LocalCertificate |=> ValidateCertificateCreationCapability

    $certHelper = new-so CertificateHelper $AppId $ObjectId $null $CertValidityTimespan $CertValidityStart

    $certificateResult = $certHelper |=> NewCertificate $CertOutputDirectory $CertStoreLocation $CertCredential $NoCertCredential.IsPresent $true
    $X509Certificate = $certificateResult.Certificate.X509Certificate

    if ( ! $AsX509Certificate.IsPresent ) {
        $::.CertificateHelper |=> CertificateToDisplayableObject $X509Certificate $certHelper.appId $certHelper.objectId $certificateResult.ExportedLocation
    } else {
        $X509Certificate
    }
}

