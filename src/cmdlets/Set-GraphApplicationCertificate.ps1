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
. (import-script ../common/LocalCertificate)
. (import-script common/CommandContext)

function Set-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='high', positionalbinding=$false)]
    param(
        [parameter(position=0, parametersetname='appid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=0, parametersetname='appidcert', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='objectid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='objectidcert', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='appid', valuefrompipelinebypropertyname=$true)]
        [parameter(parametersetname='appidcert', valuefrompipelinebypropertyname=$true)]
        [Alias('Id')]
        [Guid] $ObjectId,

        [parameter(position=1, parametersetname='appid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(position=1, parametersetname='objectid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [string[]] $CertificatePath,

        [parameter(position=2)]
        [ValidateSet('Add', 'Replace')]
        $EditMode = 'Add',

        [parameter(parametersetname='appidcert', mandatory=$true)]
        [parameter(parametersetname='objectidcert', mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2[]] $Certificate,

        [parameter(parametersetname='appid')]
        [parameter(parametersetname='objectid')]
        [PSCredential[]] $CertCredential,

        [parameter(parametersetname='appid')]
        [parameter(parametersetname='objectid')]
        [Switch] $PromptForCertCredential,

        [PSCustomObject] $Connection = $null
    )

    begin {
        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version
    }

    process {
        $targetObjectId = $ObjectId
        $targetAppId = $AppId

        $targetObject = if ( ! $targetObjectId -or $EditMode -eq 'Add' ) {
            $application = $appAPI |=> GetApplicationByObjectIdOrAppId $targetObjectId $targetAppId
            $targetObjectId = $application.id
            $targetAppId = $application.appId
            $application
        } else {
            [PSCustomObject] @{id=$targetObjectId}
        }

        $targetCertificates = if ( $Certificate ) {
            $Certificate
        } else {
            $certCredentialCount = ( $CertCredential | Measure-Object ).Count
            $certCount = ( $CertificatePath | Measure-Object ).Count

            $hasMultipleCertCredentials = $certCredentialCount -gt 1

            if ( $hasMultipleCertCredentials -and ( $certCredentialCount -ne $certCount ) ) {
                throw "More than one certificate credentials was specified, but their count ($certCredentialCount) was different than the number of certificate files ($certCount) specified. Specify exactly one credential to be used for all certificates, or specify exaclty one for each certificate file path specified"
            }

            $certIndex = 0

            foreach ( $certificatePathElement in $CertificatePath ) {
                $targetCertCredential = if ( $CertCredential ) {
                    if ( $hasMultipleCertCredentials ) {
                        $CertCredential | select -index $certIndex++
                    } else {
                        $CertCredential
                    }
                } elseif ( $PromptForCertCredential.IsPresent ) {
                    $::.LocalCertificate |=> PromptForCertificateCredential $certificatePathElement
                }

                $::.GraphApplicationCertificate |=> LoadFrom $targetAppId $targetObjectId $certificatePathElement $null $targetCertCredential
            }
        }

        $preserveExisting = $EditMode -ne 'Replace'

        if ( ! $preserveExisting ) {
            if ( ! $pscmdlet.shouldprocess("Object id=$($targetObjectId) for application id=$($targetAppId)", 'Existing certificates will be REPLACED and not added to by the specified certificates') ) {
                return
            }
        }

        $appAPI |=> AddKeyCredentials $targetObject.id $targetObject.keyCredentials $targetCertificates $preserveExisting $false
    }

    end {
    }
}
