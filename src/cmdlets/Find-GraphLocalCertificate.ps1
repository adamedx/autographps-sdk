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


<#
.SYNOPSIS
Finds certificates in the local operating system certificate store (Windows only) for use as Entra ID application credentials to access the Graph API.

.DESCRIPTION
Find-GraphLocalCertificate searches the operating system's certificate store for certificates that can be used as credentials for Entra ID application identities. When such a certificate is configured as an allowed credential for an Entra ID application that is enabled for Graph API access, they can be specified to commands like Connect-GraphApi, New-GraphConnection, or as part of profile settings configuration to allow the module's commands to issue requests to the Graph API. Currently the only operating system with a certificate store supported by Find-GraphLocalCertificate is Windows.

The command supports searching for the certificate by Entra ID application identifier, Entra ID object identifier, and as a partial match of the application's display name. The latter capability is not considered authoritative since application display names are user-defined and are not unique, but the ability to search by display name is offered as a user experience optimization for human interaction scenarios since operators often recognize applications and their purposes or importance by the application display name.

The command may also be executed without parameters, in which case it returns all certificates in the certificate store which it identifies as credentials used to access Entra ID applications targeting the Graph API.

Find-GraphLocalCertificate returns only those certificates in the certificate store that contain a given Entra ID application's application identifier or object identifer as part of the certificate's subject name or friendly name. Commands like New-GraphApplicationCertificate and New-GraphLocalCertificate create application credential certificates in the certificate store using just such a convention. Thus, Find-GraphLocalCertificate is optimized for management of certificates created by those commands. See the notes section for more details on how Find-GraphLocalCertificate associates an application with the certificate it requires to authenticate its identity.

The Find-GraphLocalCertificate command is useful in several situations:
   * The module's implicit and explicit sign-in functionality utilizes the naming convention described above for certificates created by New-GraphLocalCertificate and New-Graphcertificate to find the correct credential certificate for a given application identifier (or its Entra ID object identifier). You can use Find-GraphLocalCertificate to exercise the same search capability. If you need to troubleshoot why a sign-in appears not to use the correct certificate, Find-GraphLocalCertificate shows the certificates that the sign-in functionality is discovering so you can narrow down the the problem.
   * If you simply want to validate that there is a certificate for a given application present in the store, you can find it with Find-GraphLocalCertificate, and if necessary, explicitly specify its path to a command like Connect-GraphApi to be sure you're using the desired certificate for sign-in.
   * When you remove an application from Entra ID using a command like Remove-GraphApplication, if there are local certificates for that application on the current system they are not removed by Remove-GraphApplication. To remove them, you need to find the certificate and pass its path to Remove-Item. You can find the application for a given certificate using Find-GraphLocalCertificate.
   * If you need to clean up the certificate store, Find-GraphLocalCertificate can show all of the certificates created by the certificate creation commands, allowing you to assess whether they are still needed and to delete them if they are no longer useful.
   * You may need to inspect a certificate to inspect its properties to ensure that it will not expire soon or that it has key lengths that comply with your organization's most current standards. If you know the application identifier, object id, or even part of the application's name, Find-GraphLocalCertificate can find the certificate for you.
   * For general certificate management operations you may need to locate the certificate for an application (e.g. finding its public key to restore authorization on the application for instance).

.PARAMETER AppId
The Entra ID application identifier of the application for which to search for certificates. Specify this parameter to find certificates associated with the specified application identifier.

.PARAMETER Name
Specify the Name parameter to search for certificates by the application's display name (in Entra ID this corresponds to the application's displayName property, though the certificate will only be stamped with a snapshot of that property as it existed at the time the certificate was created). Any certificates with a FriendlyName field that contains a partial match of the value specified for Name will be returned by Find-GraphLocalCertificate.

.PARAMETER ObjectId
The Entra ID object identifier of the application, distinct from its application identifier, for which to search for certificates. Specify this parameter to find certificates associated with the application with the specified object identifier.

.PARAMETER CertStoreLocation
Specifies the path of a container in the certificate store in which the search for certificates should be conducted. The default value of the parameter is cert:/currentuser/my

.NOTES
The Find-GraphLocalCertificate command examines certificate metadata to find certificates with particular properties that link the certificate to an Entra ID application configured to accept the certificate as proof of the the application's identity. The format of these properties constitutes an application - certificate binding convention maintained between the consumers of certificates and the creators of the certificates:
    * Certificate Consumers: The Find-GraphLocalCertificate command and any command in this module that directly or indirectly signs-in to the Graph API including Connect-GraphApi, New-GraphConnection. The latter two commands explicitly utilize the binding convention, and commands such as Invoke-GraphRequest, Get-GraphRequest, and all other commands that issue GraphApi requests (e.g. Get-GraphApplication, New-GraphApplication, et. al.) also depend on this convention since all commands in this module initiate sign-ins for the connections they use when Graph API access is required when that connection is not already signed-in. This also means any commands or scripts outside of this module that depend on commands in this module also depend on the convention indirectly.
    * Certificate Creators: The supported certificate creators are all of the commands implemented in this module that support the creation of certificates in the operating system certificate store, specifically New-GraphApplication (when specified with the NewCredential command), New-GraphApplicationCertificate, and New-GraphLocalCertificate. All of these commands follow the convention that the certificate must have certain metadata properties so that they can be found by Find-GraphLocalCertificate and other certificate consumers.

The convention that is to identify a certificate as being bound to an Entra ID application identity is as follows:
   * The certificate must be present in the local operating system certificate store. Currently this is only supported on Windows, so this convention as a whole does not apply to non-Windows systems running this module.
   * By default the certificate's location in the certificate store must be cert:/currentuser/my, but consuming commands may specify alternate search paths within the certificate store so that certificates located on other parts of the store may be considered
   * The certificate's Subject property must have the format 'CN=<appid>, CN=AutoGraphPS, CN=MicrosoftGraph` where <appid> is the Entra ID application identifier guid for the application
   * To find the application based on its application identifier, the <appid> component of the Subject property must match the applicatoin identifier
   * To find the application based on its Entra ID object id identifier, the above requirement on the format of the Subject property still holds, but the application identifier constraint is not evaluated. Instead, an additional requirement is that the FriendlyName property must contain the application's Entra ID object identifier as a substring.
   * To find the application based on its name, matching is performed as in the case for the object identifier, except instead of matching the object identifier in the FriendlyName field the application name in single quites is matched as a substring. This particular approach is less reliable as multiple distinct applications may share the same display name, but still useful in visualizating the set of local certificates for human operators.

An example of a certificate generated by New-GraphApplicationCertificate is given below:

    Find-GraphLocalCertificate df957ed2-cfc3-4680-8e8b-fb517c1e3437 | Format-List

    Subject      : CN=df957ed2-cfc3-4680-8e8b-fb517c1e3437, CN=AutoGraphPS, CN=MicrosoftGraph
    Issuer       : CN=df957ed2-cfc3-4680-8e8b-fb517c1e3437, CN=AutoGraphPS, CN=MicrosoftGraph
    Thumbprint   : 83B2BAB88E2FEC28510302D1D00A2DC17A322772
    FriendlyName : Credential for Microsoft Graph Entra ID application name='ImageBackup',
                   appId=df957ed2-cfc3-4680-8e8b-fb517c1e3437, objectId=87b973cd-b78c-4033-9fcb-68fd61b117ef
    NotBefore    : 9/20/2021 13:27:03 AM
    NotAfter     : 9/20/2022 13:27:03 AM

It should also be noted that in general the module supports using certificates that to not follow this convention. The module's certificate creation commands do not currently integrate with certificate issuers, so if you follow the safest practices of using your organization's certificate issuance infrastructure instead of using the self-signed certificates created by commands of this module, the you will most likely have certificates that do not follow the convention. The sign-in and application credential management commands of this module all support the use of certificates that do not follow this convention, simply use the parameters of the relevant commands to specify the path to the certificate or its actual content. The only drawback of the convention not being followed is usability -- rather than consuming commands like Connect-GraphApi automatically finding the certificate, you'll need to specify its location.

.OUTPUTS
The output is a collection of .Net [System.Security.Cryptography.X509Certificates.X509Certificate2] objects that represent each certificate that matched the specified application search criteria. This is the same data type as that returned by enumerating objects in the certificate store drive 'cert:' using command sequences such as Get-ChildItem cert://currentuser/my. Commands in this module such as New-GraphApplication, Set-GraphApplicationCertificate, Connect-GraphApi and New-GraphConnection accept this data type as an input for configuring Entra ID applications or sign-ins to Entra ID applications.

If no match is found then the command returns no output, it does not terminate with an error.

.EXAMPLE
Find-GraphLocalCertificate b453eb6f-5152-485c-b532-41f1a0f4002b

   PSParentPath: Microsoft.PowerShell.Security\Certificate::currentuser\my

Thumbprint                                Subject
----------                                -------
93ADBAB88E2FEC285189C28D00A2DC17A3227E2  CN=b453eb6f-5152-485c-b532-41f1a0f4002b, CN=AutoGraphPS, CN=MicrosoftGraph

In this example, an Entra ID application identifier is specified using the AppId parameter, which is specified here without the parameter name since it is also the first positional parameter. The single match is output to the console.

.EXAMPLE
Find-GraphLocalCertificate | Measure-Object | Select-Object Count

Count
-----
    4

Here Find-GraphLocalCertificate is specified without any parameters, so it returns all certificates that appear to be associated withy any Entra ID application that are found under the default search path cert:/currentuser/my. The results are piped to Measure-Object and Select-Object parameters to emit the number of such certificates to the console.

.EXAMPLE
Find-GraphLocalCertificate 4fe0f58d-457a-4f84-8658-3b29f14d4723 | Remove-Item

When a certificate for an application is no longer needed, such as in the situation where the Entra ID application is deleted from Entra ID entirely, Find-GraphLocalCertificate can be used to find its certificate in the certificate store. In this example, the result of such an invocation of Find-GraphLocation is piped to the standard PowerShell command Remove-Item which deletes it from the certificate store.

.EXAMPLE
Find-GraphApplication -Name ImageBackup | Select-Objet NotAfter

NotAfter
--------
10/7/2022 10:25:20 PM

This example demonstrates how to search using the application name. The Select-Object command is used to show only the expiration time of the certificate.

.EXAMPLE
Find-GraphLocalCertificate -ObjectId 12a83c83-e6ab-46a0-863c-0ca98a5dc424

This example shows how the command may be used to find an application's certificate based on the application's Entra ID object identifier rather than the application identifier.

.EXAMPLE
Find-GraphLocalCertificate -CertStoreLocation cert:/LocalMachine/My |
   Where-Object NotAfter -lt ([DateTime]::now + [TimeSpan]::new(90, 0, 0, 0)) |
   Sort-Object NotAfter |
   Select-Object Subject, NotAfter, FriendlyName

Subject                                                                    NotAfter              FriendlyName
-------                                                                    --------              ------------
CN=eb227772-c904-43bb-8320-eaa119e537e3, CN=AutoGraphPS, CN=MicrosoftGraph 9/20/2021 8:40:43 PM  Credential for Micros...
CN=972dc696-c1a4-47ce-ac10-b73933486841, CN=AutoGraphPS, CN=MicrosoftGraph 10/7/2021 10:24:55 PM Credential for Micros...
CN=70ed1fbd-b419-4972-88c3-cced4a21330f, CN=AutoGraphPS, CN=MicrosoftGraph 10/8/2021 8:29:03 PM  Credential for Micros...

This example shows how the CertStoreLocation parameter can be used to enable searches outside of the default location of cert:/currentuser/my -- the certificate creation commands create certificates there by default but provide parameters that can override the output location of any newly created certificate to any valid certificate store location such as cert:/LocalMachine/My.

In this scenario the user is looking for certificates that are going to expire in the next 90 days under cert:/LocalMachine/My. Because no parameters other than CertStoreLocation are supplied to Find-GraphLocalCertificate, all certificates under cert:/LocalMachine/My that appear to be associated with an Entra ID application are returned. To limit the results to just those certificates that are expiring in less than 90 days, the output of Find-GraphLocation is piped to Where-Object to filter based on the NotAfter field which is the expiration time. This filtered result is piped to Sort-Object which sorts it using that same NotAfter field so that the certificates are listed in temporal order of expiration. Finally, Select-Object projects a subset of the fields to highlight the most actionable fields for this particular user's situation.

.LINK
Connect-GraphApi
Disconnect-GraphApi
Get-GraphConnection
Remove-GraphConnection
Select-GraphConnection
Get-GraphAccessToken
#>
function Find-GraphLocalCertificate {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='appid')]
    [OutputType('System.Security.Cryptography.X509Certificates.X509Certificate2')]
    param(
        [parameter(position=0, parametersetname='appid', valuefrompipelinebypropertyname=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='byname', mandatory=$true)]
        $Name,

        [parameter(parametersetname='byobjectid', mandatory=$true)]
        [Guid] $ObjectId,

        $CertStoreLocation = 'Cert:/currentuser/my'
    )

    begin {}

    process {
        Enable-ScriptClassVerbosePreference

        $::.GraphApplicationCertificate |=> FindAppCertificate $AppId $CertStoreLocation $Name $ObjectId
    }

    end {}
}
