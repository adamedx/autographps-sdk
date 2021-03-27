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

. (import-script ../graphservice/ApplicationAPI)
. (import-script ../common/GraphApplicationCertificate)
. (import-script common/CommandContext)

function New-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='high', positionalbinding=$false)]
    param(
        [parameter(parametersetname='appid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='appidexport', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $AppId,

        [parameter(position=1)]
        [TimeSpan] $CertValidityTimeSpan,

        [DateTime] $CertValidityStart,

        [parameter(parametersetname='objectid', mandatory=$true)]
        [parameter(parametersetname='objectidexport', mandatory=$true)]
        [Guid] $ObjectId,

        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='appidexport', mandatory=$true)]
        [parameter(parametersetname='objectidexport', mandatory=$true)]
        [string] $CertOutputDirectory,

        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='appidexport')]
        [parameter(parametersetname='objectidexport')]
        [switch] $NoCertCredential,


        [PSCustomObject] $Connection = $null,

        [switch] $SkipApplicationUpdate
    )
    Enable-ScriptClassVerbosePreference

    $exportedCertCredential = if ( $CertOutputDirectory ) {
        if (! (test-path -pathtype container $CertOutputDirectory) ) {
            throw [ArgumentException]::new("The CertOutputDirectory parameter value '$CertOutputDirectory' is not a valid directory")
        }

        if ( $CertCredential ) {
            $CertCredential
        } elseif ( ! $NoCertCredential.IsPresent ) {
            $userName = if ( $env:user ) { $env:user } else { $env:username }
            Get-Credential -username $userName
        }
    }

    $targetObjectId = $ObjectId

    $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion

    $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

    $targetApp = if( $AppId ) {
        $appAPI |=> GetApplicationByAppId $AppId
    } else {
        $appAPI |=> GetApplicationByObjectId $ObjectId
    }

    if ( ! $pscmdlet.shouldprocess("Application id=$($targetApp.AppId)", 'DESTRUCTIVE overwrite of existing certificates due to current defects in the Graph API') ) {
        return
    }

    $certificate = new-so GraphApplicationCertificate $targetApp.AppId $ObjectId $targetApp.displayName $CertValidityTimeSpan $CertValidityStart $CertStoreLocation
    $certificate |=> Create

    try {
        $appAPI |=> AddKeyCredentials $targetApp $certificate | out-null
    } catch {
        $certificate.X509Certificate | rm
        throw
    }

    if ( $CertOutputDirectory ) {
        $certpassword = if ( $CertCredential ) {
            $CertCredential.Password
        }

        $certificate |=> Export $CertOutputDirectory $certPassword
    }

    $certificate.X509Certificate
}

