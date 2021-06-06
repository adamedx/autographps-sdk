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

. (import-script ../common/GraphApplicationCertificate)

function New-GraphLocalCertificate {
    [cmdletbinding(positionalbinding=$false)]
    [OutputType('AutoGraph.Certificate')]
    param(
        [parameter(parametersetname='pipeline', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='pipelineexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='pipelineexportpath', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='appid', mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='pipeline', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='pipelineexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='pipelineexportpath', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='objectid', mandatory=$true)]
        [Alias('Id')]
        [Guid] $ObjectId,

        [parameter(position=1)]
        [Alias('Name')]
        [string] $ApplicationName = 'AutoGraphPS Application',

        [TimeSpan] $CertValidityTimeSpan,

        [DateTime] $CertValidityStart,

        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='pipelineexport', mandatory=$true)]
        [parameter(parametersetname='appidexport', mandatory=$true)]
        [parameter(parametersetname='objectidexport', mandatory=$true)]
        [string] $CertOutputDirectory,

        [parameter(parametersetname='pipelineexportpath', mandatory=$true)]
        [parameter(parametersetname='appidexportpath', mandatory=$true)]
        [parameter(parametersetname='objectidexportpath', mandatory=$true)]
        [string] $CertificateFilePath,

        [parameter(parametersetname='pipelineexport')]
        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [parameter(parametersetname='pipelineexportpath')]
        [parameter(parametersetname='appidexportpath')]
        [parameter(parametersetname='objectidexportpath')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='pipelineexport')]
        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [parameter(parametersetname='pipelineexportpath')]
        [parameter(parametersetname='appidexportpath')]
        [parameter(parametersetname='objectidexportpath')]
        [switch] $NoCertCredential,

        [switch] $AsX509Certificate
    )
    Enable-ScriptClassVerbosePreference

    $::.LocalCertificate |=> ValidateCertificateCreationCapability

    $certHelper = new-so CertificateHelper $AppId $ObjectId $ApplicationName $CertValidityTimespan $CertValidityStart

    $certificateResult = $certHelper |=> NewCertificate $CertOutputDirectory $CertStoreLocation $CertCredential $NoCertCredential.IsPresent $false $CertificateFilePath
    $X509Certificate = $certificateResult.Certificate.X509Certificate

    if ( ! $AsX509Certificate.IsPresent ) {
        $::.CertificateHelper |=> CertificateToDisplayableObject $X509Certificate $certHelper.appId $certHelper.objectId $X509Certificate.PSPath $null $certificateResult.ExportedLocation
    } else {
        $X509Certificate
    }
}
