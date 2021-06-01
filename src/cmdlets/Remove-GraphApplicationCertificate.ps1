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
. (import-script common/CommandContext)

function Remove-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='High', positionalbinding=$false)]
    param(
        [parameter(parametersetname='AppIdFromUniqueId', position=0, mandatory=$true)]
        [parameter(parametersetname='AppIdFromThumbprint', position=0, mandatory=$true)]
        [parameter(parametersetname='AppIdAllCertificates', position=0, mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='ObjectIdFromUniqueId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='ObjectIdFromThumbprint', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='ObjectIdAllCertificates', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        [Guid] $AppObjectId,

        [parameter(parametersetname='AppIdFromUniqueId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='ObjectIdFromUniqueId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $KeyId,

        [parameter(parametersetname='AppIdFromThumbprint', position=1, mandatory=$true)]
        [parameter(parametersetname='ObjectIdFromThumbprint', position=1, mandatory=$true)]
        $Thumbprint = $null,

        [parameter(parametersetname='AppIdAllCertificates', mandatory=$true)]
        [parameter(parametersetname='ObjectIdAllCertificates', mandatory=$true)]
        [switch] $AllCertificates,

        [PSCustomObject] $Connection = $null
    )

    begin {
        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
        $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version
        $appToCredentials = @{}
    }

    process {
        Enable-ScriptClassVerbosePreference

        $remainingCredentials = $null

        $targetObjectId = if ( $AppObjectId ) {
            $AppObjectId
        } elseif ($AppId ) {
            $appAPI |=> GetApplicationByAppId $AppId | select -expandproperty id
        } else {
            throw "Unexpected argument -- an app id or object id must be specified"
        }

        $keyClientFilter = if ( $AllCertificates.IsPresent ) {
            { $true }
        } elseif ( $KeyId ) {
            { $_.KeyId -eq $KeyId }
        } elseif ( $Thumbprint ) {
            { $_.CustomKeyIdentifier -eq $Thumbprint }
        } else {
            throw [ArgumentException]::new("An AppId with Thumbprint or KeyId was not specified or AllCertificates was not specified")
        }

        # This returns ALL credentials, not just certificates. If it didn't, the naive API used to add certificates
        # (or just replace only the certs and leave other credential types alone) would remove anything that wasn't
        # a certificate.
        $keyCredentials = $::.ApplicationHelper |=> QueryApplications $null $targetObjectId $null $null $null $commandContext.version $null null $commandContext.connection keyCredentials |
          select -expandproperty keyCredentials

        $certToRemove = if ( ! $keyCredentials -and ! ($keyCredentials | gm id -erroraction ignore ) ) {
            throw [ArgumentException]::new("No certificates could be found for application with object identifier '$targetObjectId'")
        } else {
            # Limit the removal to only the certificates with a filter on credential type
            $keyCredentials | where $keyClientFilter | where type -eq 'AsymmetricX509Cert'
        }

        if ( ! $certToRemove ) {
            throw [ArgumentException]::new("The specified certificate could not be found for the application with object identifier '$targetObjectId'")
        }

        # Excise the certs to be removed from the set of all credentials -- this leaves
        # all the non-certificates and any certificates not targeted by this command
        $remainingCredentials = $keyCredentials | where KeyId -notin $certToRemove.keyId

        # Now group all the apps together with a dictionary to avoid duplicates.
        # Within each app's dictionary entry, include all the remaining credentials
        # within a nested hash table that again prevents duplicates. Duplicates can happen
        # when the same application is specified in the pipeline with a different cert, quite
        # possibly due to a certificate object being supplied to the command with the parameters
        # for the application's object id and key id being bound as parameters for instance.

        if ( $remainingCredentials -eq $null ) {
            $remainingCredentials = @()
        }

        $newApp = $false
        $currentAppCredentials = $appToCredentials[$targetObjectId]

        if ( ! $currentAppCredentials ) {
            $newApp = $true
            $currentAppCredentials = @{
                AppObjectId = $targetObjectId
                RemainingCredentials = @{}
            }
        }

        foreach ( $remainingCert in $remainingCredentials ) {
            $currentAppCredentials.RemainingCredentials[$remainingCert.KeyId] = $remainingCert
        }

        if ( $newApp ) {
            $appToCredentials[$targetObjectId] = $currentAppCredentials
        }
    }

    end {
        # Now for each app, update the credentials according to the remaining credentials
        foreach ( $appCredentials in $appToCredentials.Values ) {
            $appAPI |=> SetKeyCredentials $appCredentials.AppObjectId $appCredential.RemainingCredentials.Values
        }
    }
}

