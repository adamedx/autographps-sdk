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

. (import-script ../GraphService/GraphEndpoint)
. (import-script ../Client/GraphIdentity)
. (import-script ../Client/GraphConnection)

function New-GraphConnection {
    [cmdletbinding(positionalbinding=$false, DefaultParameterSetName='msgraph')]
    param(
        [parameter(parametersetname='aadgraph', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [switch] $AADGraph,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom')]
        [parameter(parametersetname='customsecret')]
        [parameter(parametersetname='customendpoint')]
        [String[]] $ScopeNames = @('User.Read'),

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom', mandatory=$true)]
        [parameter(parametersetname='customsecret', mandatory=$true)]
        [parameter(parametersetname='customcertname', mandatory=$true)]
        [parameter(parametersetname='customcert', mandatory=$true)]
        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [Guid] $AppId,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom')]
        [parameter(parametersetname='customsecret')]
        [parameter(parametersetname='customendpoint')]
        [Uri] $AppRedirectUri,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom')]
        [parameter(parametersetname='customsecret', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
#        [SecureString] $AppSecret = $null,
        [String] $AppSecret = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom')]
        [parameter(parametersetname='customcertname', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [string] $AppCertificatePath = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom')]
        [parameter(parametersetname='customcert', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $AppCertificate = $null,

        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [Uri] $GraphEndpointUri = $null,

        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [Uri] $AuthenticationEndpointUri = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom')]
        [parameter(parametersetname='customsecret')]
        [parameter(parametersetname='customcertname')]
        [parameter(parametersetname='customcert')]
        [parameter(parametersetname='customendpoint')]
        [GraphAuthProtocol] $GraphAuthProtocol = [GraphAuthProtocol]::Default,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='custom')]
        [parameter(parametersetname='customsecret')]
        [parameter(parametersetname='customcertname')]
        [parameter(parametersetname='customcert')]
        [parameter(parametersetname='customendpoint')]
        [String] $TenantName = $null
    )

    if ( $AppCertificate ) {
        throw [NotImplementedException]::new("The -AppCertificate option is not yet implemented")
    }

    if ( $AppCertificatePath ) {
        throw [NotImplementedException]::new("The -AppCertificatePath option is not yet implemented")
    }

    $validatedCloud = if ( $Cloud ) {
        [GraphCloud] $Cloud
    } else {
        ([GraphCloud]::Public)
    }

    $graphType = if ( $AADGraph.ispresent ) {
        ([GraphType]::AADGraph)
    } else {
        ([GraphType]::MSGraph)
    }

    $specifiedAuthProtocol = if ( $GraphAuthProtocol -ne ([GraphAuthProtocol]::Default) ) {
        $GraphAuthProtocol
    }

    if ( $GraphEndpointUri -eq $null -and $AuthenticationEndpointUri -eq $null -and $specifiedAuthProtocol) {
        $::.GraphConnection |=> NewSimpleConnection $graphType $validatedCloud $ScopeNames
    } else {
        $computedAuthProtocol = $::.GraphEndpoint |=> GetAuthProtocol $GraphAuthProtocol $validatedCloud $GraphType

        $graphEndpoint = if ( $GraphEndpointUri -eq $null ) {
            new-so GraphEndpoint $validatedCloud $graphType $null $null $computedAuthProtocol
        } else {
            new-so GraphEndpoint ([GraphCloud]::Custom) ([GraphType]::MSGraph) $GraphEndpointUri $AuthenticationEndpointUri $computedAuthProtocol
        }

        $secret = if ( $AppSecret ) {
            $AppSecret
        } elseif ( $AppCertificate ) {
            $AppCertificate
        } else {
            $AppCertificatePath
        }

        $app = new-so GraphApplication $AppId $AppRedirectUri $secret
        $identity = new-so GraphIdentity $app $graphEndpoint $TenantName
        new-so GraphConnection $graphEndpoint $identity $ScopeNames
    }
}
