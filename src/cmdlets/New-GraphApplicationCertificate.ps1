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

. (import-script ../graphservice/ApplicationAPI)
. (import-script ../common/GraphApplicationCertificate)
. (import-script common/PermissionParameterCompleter)
. (import-script common/CommandContext)

function New-GraphApplicationCertificate {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='high', positionalbinding=$false)]
    param(
        [parameter(parametersetname='appId', position=0, mandatory=$true)]
        [parameter(parametersetname='appIdNewCloud', mandatory=$true)]
        [parameter(parametersetname='appIdNewPermissions', mandatory=$true)]
        [parameter(parametersetname='appIdExistingConnection', mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='objectId', mandatory=$true)]
        [parameter(parametersetname='objectIdNewCloud', mandatory=$true)]
        [parameter(parametersetname='objectIdNewPermissions', mandatory=$true)]
        [parameter(parametersetname='objectIdExistingConnection', mandatory=$true)]
        [Guid] $ObjectId,

        [parameter(parametersetname='app', mandatory=$true)]
        [parameter(parametersetname='appNewCloud', mandatory=$true)]
        [parameter(parametersetname='appNewPermissions', mandatory=$true)]
        [parameter(parametersetname='appIdExistingConnection', mandatory=$true)]
        $Application,

        $CertStoreLocation = 'cert:/currentuser/my',

        [parameter(parametersetname='appNewPermissions', mandatory=$true)]
        [parameter(parametersetname='appIdNewPermissions', mandatory=$true)]
        [parameter(parametersetname='objectIdNewPermissions', mandatory=$true)]
        $Permissions,

        [parameter(parametersetname='appNewCloud', mandatory=$true)]
        [parameter(parametersetname='appIdNewCloud', mandatory=$true)]
        [parameter(parametersetname='objectIdNewCloud', mandatory=$true)]
        [GraphCloud] $Cloud = [GraphCloud]::Public,

        [parameter(parametersetname='appExistingConnection', mandatory=$true)]
        [parameter(parametersetname='appIdExistingConnection', mandatory=$true)]
        [parameter(parametersetname='objectIdExistingConnection', mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [String] $Version = $null
    )

    $targetApp = $Application
    $targetObjectId = $ObjectId

    $commandContext = new-so CommandContext $connection $version $Permissions $Cloud $::.ApplicationAPI.DefaultApplicationApiVersion

    $appAPI = new-so ApplicationAPI $commandContext.connection $commandContext.version

    $targetApp = if ( $Application ) {
        $Application
    } elseif( $AppId ) {
        $appAPI |=> GetApplicationByAppId $AppId
    } elseif ( $ObjectId) {
        $appAPI |=> GetApplicationByObjectId $ObjectId
    }

    if ( ! $pscmdlet.shouldprocess("Application id=$($targetApp.AppId)", 'DESTRUCTIVE overwrite of existing certificates due to current defects in the Graph API') ) {
        return
    }

    $certificate = new-so GraphApplicationCertificate $targetApp.AppId $targetApp.displayName $CertStoreLocation
    $certificate |=> Create

    try {
        $appAPI |=> AddKeyCredentials $targetApp $certificate | out-null
    } catch {
        $certificate.X509Certificate | rm
        throw
    }

    $newKeyCredential = $::.ApplicationHelper |=> QueryApplications $targetApp.AppId $null $null $null $null $null $null $null $null keyCredentials |
      select -expandproperty keyCredentials |
      where customkeyIdentifier -eq $certificate.X509Certificate.thumbprint

    $::.ApplicationHelper |=> KeyCredentialToDisplayableObject $newKeyCredential $targetapp.AppId
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphApplicationCertificate Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))
