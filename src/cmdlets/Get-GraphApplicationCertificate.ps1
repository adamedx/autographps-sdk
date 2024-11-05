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

. (import-script common/ApplicationHelper)

<#
.SYNOPSIS
Gets the certificates configured for use as credentials for an Entra ID application identity.

.DESCRIPTION
Certificate credential configuration on the application object allows running application code to obtain access tokens with the application's identity. Get-GraphApplicationCertificate retrieves the set of certificates configured as credentials for the application. Runtime code with access to the private key associated with a certificate configured for the application will be able to authenticate as the application.

The command supports specifying the application for which to retrieve certificates using either the application's application identifier through the AppId parameter or its Entra ID object identifier using the AppObjectId parameter.

By default, all certificates configured for the specified application are returned. The KeyId or Thumbprint parameters may be specified to return only a specific certificate that satisfies either of those criteria.

The output of Get-GraphApplicationCertificate contains details about public properties of the certificate including its thumbprint, subject name, friendly name, and validity window dates and can be useful in certificate management activities such as enumerating certificate nearing expiration, or finding certificates with a particular subject name or thumbprint. The results of Get-GraphApplicationCertificate may be piped to other commands that can perform further analysis or write operations such as removal of the certificate from the application configuration.

.PARAMETER AppId
The Entra ID application identifier of the application for which to retrieve certificates.

.PARAMETER AppObjectId
The object identifier of the application for which to retrieve certificates.

.PARAMETER KeyId
The identifier of the certificate to retrieve. For a given application, each configured certificate has a unique key id that is generated at the time the certificate is configured for the application.

.PARAMETER Thumbprint
The certificate thumbprint of the certificate to retrieve.

.PARAMETER Connection
Specify the Connection parameter to use as an alternative connection to the current connection.

.OUTPUTS
Get-GraphApplicationCertificate returns a collection of objects each of which describes a certificates configured for the application. The information provided for each certificate includes the certificate subject name, the certificate thumbprint, the friendly name, the application identifier it is configured for, the objectid of the application, and the date on which it started to be valid, and the date at which it expires. Each certificate also has a unique KeyId property that is unique for each certificate configured for the application.

.EXAMPLE
Get-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

   Application (client) ID: e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

Thumbprint          NotAfter      KeyId               Subject
----------          --------      -----               -------
4CE7BCB397ECE10A... 5/14/2023 ... 3fdc106f-5ee7-4e... CN=Mothership, CN=Internal, CN=dev, CN=Photo...
8835CF749938C3E1... 7/27/2023 ... 72e415a8-3433-47... CN=e4ab44d2-98ac-4a33-a010-e8fa2ac2e330, CN=...
ABA57B4E4DC7263D... 11/9/2023 ... ecc5e1b4-ffa2-43... CN=e4ab44d2-98ac-4a33-a010-e8fa2ac2e330, CN=...

This example demonstrates how to retrieve the certificates for an application by specifying its application identifier to the Get-GraphApplicationCertificate command. The default output is tabular and includes the expiration date for the certificate using the NotAfter property.

.EXAMPLE
Get-GraphApplicationCertificate -AppId e4ab44d2-98ac-4a33-a010-e8fa2ac2e330 -Thumbprint 4CE7BCB397ECE10A01F2FFE910E5C4D70AA954F1 |
    Format-List

   Application (client) ID: e4ab44d2-98ac-4a33-a010-e8fa2ac2e330

Thumbprint   : 4CE7BCB397ECE10A01F2FFE910E5C4D70AA954F1
AppId        : e4ab44d2-98ac-4a33-a010-e8fa2ac2e330
Subject      : CN=Mothership, CN=Internal, CN=dev, CN=PhotosApp
FriendlyName : Shared Photos Sync Application
NotBefore    : 4/15/2022 10:21:03 PM +00:00
NotAfter     : 5/15/2022 10:21:03 PM +00:00
KeyId        : 35af2207-c276-4416-b868-fc2003b0e032
AppObjectId  : ea8838e3-c301-4e50-a842-b44879bdd55a

In this example, the Thumbprint parameter is specified to return a specific certificate configured for the application. The result is piped to the Format-List parameter to demonstrate the information that is displayed in the list format.

.EXAMPLE
$backupAppCerts = Get-GraphApplication -Name 'Backup application' | Get-GraphApplicationCertificate

This example shows how the output of Get-GraphApplication may be piped to Get-GraphApplicationCertificate. Here the Get-GraphApplication command is used to find the target application by name rather than application identifier, and the result is piped to Get-GraphApplicationCertificate to retrieve the information for those certificates and store it in a variable.

.EXAMPLE
Get-GraphApplicationCertificate 9a89159c-2abb-4faf-9435-269657931e1e |
    Where-Object NotAfter -lt ([DateTime]::now) |
    Remove-GraphApplicationCertificate

This example demonstrates one way to remove expired certificates. The Get-GraphApplicationCertificate command is used to retrieve the certificates from an application, and the results filtered through Where-Object on the NotAfter property. Only certificates with a NotAfter time less than the current time, i.e. those where the NotAfter time is already in the past, will be returned. These expired certificates are then piped to Remove-GraphApplicationCertificate which removes them from the application.

.LINK
Set-GraphApplicationCertificate
Remove-GraphApplicationCertificate
New-GraphApplication
Find-GraphApplicationLocalCertificate
Connect-GraphApi
#>
Function Get-GraphApplicationCertificate {
    [cmdletbinding(defaultparametersetname='appid', positionalbinding=$false)]
    [OutputType('AutoGraph.Certificate')]
    param (
        [parameter(parametersetname='appid', position=0, mandatory=$true)]
        [parameter(parametersetname='objectid', position=0, valuefrompipelinebypropertyname=$true)]
        [parameter(parametersetname='appidkeyId', position=0, mandatory=$true)]
        [parameter(parametersetname='objectidkeyId', position=0, valuefrompipelinebypropertyname=$true)]
        $AppId,

        [parameter(parametersetname='appid', valuefrompipelinebypropertyname=$true)]
        [parameter(parametersetname='objectid', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='appidkeyId', valuefrompipelinebypropertyname=$true)]
        [parameter(parametersetname='objectidkeyId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Alias('Id')]
        $AppObjectId,

        [parameter(parametersetname='appidkeyId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [parameter(parametersetname='objectidkeyId', valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [Guid] $KeyId,

        [string] $Thumbprint = $null,

        [PSCustomObject] $Connection = $null
    )

    begin {
        $commandContext = new-so CommandContext $connection $null $null $null $::.ApplicationAPI.DefaultApplicationApiVersion
    }

    process {
        Enable-ScriptClassVerbosePreference

        $targetAppId = $AppId
        $targetObjectId = if ( $AppObjectId ) {
            $targetAppId = $null
            $AppObjectId
        }

        if ( ! $targetAppID -and ! $targetObjectId ) {
            Write-Error "Unexpected argument -- an app id or object id must be specified"
        }

        $app = $::.ApplicationHelper |=> QueryApplications $targetAppId $targetObjectId $null $null $null $null $null $null $commandContext.connection id, appId, keyCredentials

        $keyCredentials = if ( $app ) {
            $targetAppId = $app.appId
            $targetObjectId = $app.id
            $app | select -expandproperty KeyCredentials -erroraction ignore
        }

        $keyCredentials | where type -eq 'AsymmetricX509Cert' | foreach {
            if ( ! $KeyId -or $_.keyId -eq $KeyId ) {
                if ( ! $Thumbprint -or $_.customKeyIdentifier -eq $Thumbprint ) {
                    $::.ApplicationHelper |=> KeyCredentialToDisplayableObject $_ $targetAppId $targetObjectId
                }
            }
        } | sort-object NotAfter
    }

    end {}
}

