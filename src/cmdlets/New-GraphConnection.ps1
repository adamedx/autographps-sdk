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
. (import-script common/DynamicParamHelper)
. (import-script ../common/ScopeHelper)

function New-GraphConnection {
    [cmdletbinding(positionalbinding=$false, DefaultParameterSetName='msgraph')]
    param(
        [parameter(parametersetname='aadgraph', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [switch] $AADGraph,

        <#
        This is implemented as a DynamicParam -- see below
        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='customendpoint')]
        [String[]] $Scopes = $null,
        #>

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='customendpoint')]
        [Switch] $SkipScopeValidation,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud', mandatory=$true)]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='secret')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='cert', mandatory=$true)]
        [parameter(parametersetname='certpath', mandatory=$true)]
        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='customendpoint', mandatory=$true)]
        $AppId = $null,

        [Uri] $AppRedirectUri,

        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='cert', mandatory=$true)]
        [parameter(parametersetname='certpath', mandatory=$true)]
        [Switch] $NoninteractiveAppAuth,

        [parameter(parametersetname='secret', mandatory=$true)]
        [Switch] $Secret,

        [parameter(parametersetname='secret', mandatory=$true)]
        [SecureString] $Password,

        [parameter(parametersetname='certpath', mandatory=$true)]
        [string] $CertificatePath = $null,

        [parameter(parametersetname='cert', mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate = $null,

        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $GraphEndpointUri = $null,

        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $AuthenticationEndpointUri = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='customendpoint')]
        [GraphAuthProtocol] $AuthProtocol = [GraphAuthProtocol]::Default,

        [String] $TenantName = $null
    )

    DynamicParam {
        Get-DynamicValidateSetParameter Scopes ($::.ScopeHelper |=> GetKnownScopes) -ParameterType ([String[]]) -SkipValidation:$SkipScopeValidation.IsPresent -ParameterSets @(
            @{
                ParameterSetName = 'msgraph'
            }
            @{
                ParameterSetName = 'cloud'
            },
            @{
                ParameterSetName = 'customendpoint'
            }
        )
    }

    begin {
        <# Make a friendly local variable name for the parameter
        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='customendpoint')]
        [String[]] $Scopes = $null,
        #>
        $Scopes = $PsBoundParameters['Scopes']
    }

    process {
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

        $specifiedAuthProtocol = if ( $AuthProtocol -ne ([GraphAuthProtocol]::Default) ) {
            $AuthProtocol
        }

        $specifiedScopes = if ( $Scopes ) {
            if ( $Secret.IsPresent -or $Certificate -or $CertificatePath ) {
                throw 'Scopes may not be specified for app authentication'
            }
            $scopes
        } else {
            @('User.Read')
        }

        $computedAuthProtocol = $::.GraphEndpoint |=> GetAuthProtocol $AuthProtocol $validatedCloud $GraphType

        if ( $GraphEndpointUri -eq $null -and $AuthenticationEndpointUri -eq $null -and $specifiedAuthProtocol -and $appId -eq $null ) {
            write-verbose 'Simple connection specified with no custom uri, auth protocol, or app id'
            $::.GraphConnection |=> NewSimpleConnection $graphType $validatedCloud $specifiedScopes $false $tenantName $computedAuthProtocol
        } else {
            $graphEndpoint = if ( $GraphEndpointUri -eq $null ) {
                write-verbose 'Custom endpoint data required, no graph endpoint URI was specified, using URI based on cloud'
                write-verbose ("Creating endpoint with cloud '{0}', auth protocol '{1}'" -f $validatedCloud, $computedAuthProtocol)
                new-so GraphEndpoint $validatedCloud $graphType $null $null $computedAuthProtocol
            } else {
                write-verbose ("Custom endpoint data required and graph endpoint URI was specified, using specified endpoint URI and auth protocol {0}'" -f $computedAuthProtocol)
                new-so GraphEndpoint ([GraphCloud]::Custom) ([GraphType]::MSGraph) $GraphEndpointUri $AuthenticationEndpointUri $computedAuthProtocol
            }

            $appSecret = if ( $Password ) {
                $Password
            } elseif ( $Certificate ) {
                $Certificate
            } else {
                $CertificatePath
            }

            $app = new-so GraphApplication $AppId $AppRedirectUri $appSecret
            $identity = new-so GraphIdentity $app $graphEndpoint $TenantName
            new-so GraphConnection $graphEndpoint $identity $specifiedScopes
        }
    }
}
