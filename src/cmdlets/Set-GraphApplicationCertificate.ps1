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
. (import-script ../common/CertificateHelper)
. (import-script common/CommandContext)

function Set-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='high', positionalbinding=$false)]
    param(
        [parameter(position=0, parametersetname='appidcertpath', mandatory=$true)]
        [parameter(position=0, parametersetname='appidcert', mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='objectidcertpath', mandatory=$true)]
        [parameter(parametersetname='objectidcert', mandatory=$true)]
        [Alias('Id')]
        [Guid] $ObjectId,

        [parameter(position=1, parametersetname='appidcertpath', mandatory=$true)]
        [parameter(parametersetname='objectidcertpath', mandatory=$true)]
        [string[]] $CertPath,

        [parameter(position=2)]
        [ValidateSet('Add', 'Replace')]
        $EditMode = 'Add',

        [parameter(parametersetname='appidcert', valuefrompipeline=$true, mandatory=$true)]
        [parameter(parametersetname='objectidcert', valuefrompipeline=$true, mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2[]] $Certificate,

        [parameter(parametersetname='appidcertpath')]
        [parameter(parametersetname='objectidcertpath')]
        $CertLocation = $null,

        [PSCredential] $CertCredential,

        [PSCustomObject] $Connection = $null
    )

    $targetObjectId = $ObjectId
    $targetAppId = $AppId

    $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
    $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

    $targetObject = if ( ! $targetObjectId -or $EditMode -eq 'Add' ) {
        $application = $appAPI |=> GetApplicationByObjectIdOrAppId $ObjectId $AppId # $true
        $targetObjectId = $application.id
        $targetAppId = $application.appId
        $application
    } else {
        [PSCustomObject] @{id=$targetObjectId}
    }

    $targetCertificates = if ( $Certificate ) {
        $Certificate
    } else {
        foreach ( $certificatePath in $CertPath ) {
            $::.GraphApplicationCertificate |=> LoadFrom $targetAppId $targetObjectId $certificatePath
        }
    }

    $preserveExisting = $EditMode -ne 'Replace'

    if ( ! $preserveExisting ) {
        if ( ! $pscmdlet.shouldprocess("Object id=$($targetObject.id) for application id=$($targetObject.AppId)", 'Existing certificates will be REPLACED and not added to by the specified certificates') ) {
            return
        }
    }

    $appAPI |=> AddKeyCredentials $targetObject $targetCertificates $preserveExisting $false | out-null
}
