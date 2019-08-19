# Copyright 2019, Adam Edwards
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

. (import-script ../graphservice/GraphEndpoint)
. (import-script ../client/GraphIdentity)
. (import-script ../client/GraphConnection)
. (import-script common/DynamicParamHelper)
. (import-script ../common/ScopeHelper)
. (import-script common/PermissionParameterCompleter)

function New-GraphConnection {
    [cmdletbinding(positionalbinding=$false, DefaultParameterSetName='msgraph')]
    param(
        [parameter(parametersetname='msgraph', position=0)]
        [parameter(parametersetname='cloud', position=0)]
        [parameter(parametersetname='customendpoint', position=0)]
        [parameter(parametersetname='cert', position=0)]
        [parameter(parametersetname='certpath', position=0)]
        [parameter(parametersetname='autocert', position=0)]
        [parameter(parametersetname='secret', position=0)]
        [String[]] $Permissions = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='cert', mandatory=$true)]
        [parameter(parametersetname='certpath', mandatory=$true)]
        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='autocert', mandatory=$true)]
        $AppId = $null,

        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='cert', mandatory=$true)]
        [parameter(parametersetname='certpath', mandatory=$true)]
        [parameter(parametersetname='autocert', mandatory=$true)]
        [Switch] $NoninteractiveAppOnlyAuth,

        [String] $TenantId = $null,

        [parameter(parametersetname='certpath', mandatory=$true)]
        [string] $CertificatePath = $null,

        [parameter(parametersetname='cert', mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate = $null,

        [switch] $Confidential,

        [parameter(parametersetname='secret', mandatory=$true)]
        [Switch] $Secret,

        [parameter(parametersetname='secret', mandatory=$true)]
        [SecureString] $Password,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud', mandatory=$true)]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='autocert')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [Uri] $AppRedirectUri,

        [parameter(parametersetname='msgraph')]
        [Switch] $NoBrowserSigninUI,

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

        [parameter(parametersetname='aadgraph', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [switch] $AADGraph
    )

    begin {
    }

    process {
        Enable-ScriptClassVerbosePreference

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

        $specifiedScopes = if ( $Permissions ) {
            if ( $Secret.IsPresent -or $Certificate -or $CertificatePath ) {
                throw 'Permissions may not be specified for app authentication'
            }
            $Permissions
        } else {
            @('User.Read')
        }

        $computedAuthProtocol = $::.GraphEndpoint |=> GetAuthProtocol $AuthProtocol $validatedCloud $GraphType

        if ( $GraphEndpointUri -eq $null -and $AuthenticationEndpointUri -eq $null -and $specifiedAuthProtocol -and $appId -eq $null ) {
            write-verbose 'Simple connection specified with no custom uri, auth protocol, or app id'
            $::.GraphConnection |=> NewSimpleConnection $graphType $validatedCloud $specifiedScopes $false $TenantId $computedAuthProtocol
        } else {
            $graphEndpoint = if ( $GraphEndpointUri -eq $null ) {
                write-verbose 'Custom endpoint data required, no graph endpoint URI was specified, using URI based on cloud'
                write-verbose ("Creating endpoint with cloud '{0}', auth protocol '{1}'" -f $validatedCloud, $computedAuthProtocol)
                new-so GraphEndpoint $validatedCloud $graphType $null $null $computedAuthProtocol
            } else {
                write-verbose ("Custom endpoint data required and graph endpoint URI was specified, using specified endpoint URI and auth protocol {0}'" -f $computedAuthProtocol)
                new-so GraphEndpoint ([GraphCloud]::Custom) ([GraphType]::MSGraph) $GraphEndpointUri $AuthenticationEndpointUri $computedAuthProtocol
            }

            $adjustedTenantId = $TenantId

            $appSecret = if ( $Confidential.IsPresent -or $NoninteractiveAppOnlyAuth.IsPresent ) {
                if ( $Password ) {
                    $Password
                } elseif ( $Certificate ) {
                    $Certificate
                } elseif ( $CertificatePath ) {
                    $CertificatePath
                } else {
                    $appCertificate = $::.GraphApplicationCertificate |=> FindAppCertificate $AppId
                    if ( ! $appCertificate ) {
                        throw "NoninteractiveAppOnlyAuth or Confidential was specified, but no password or certificate was specified, and no certificate with the appId '$AppId' in the subject name could be found in the default certificate store location. Specify an explicit certificate or password and retry."
                    } elseif ( ($appCertificate | gm length -erroraction silentlycontinue) -and $appCertificate.length -gt 1 ) {
                        throw "NoninteractiveAppOnlyAuth or Confidential was specified, and more than one certificate with the appId '$AppId' in the subject name could be found in the default certificate store location. Specify an explicity certificate or password and retry."
                    }
                    $appCertificate
                }

                if ( ! $TenantId ) {
                    write-verbose "No tenant id was specified and app is non-interactive, attempting to get tenant id from current token"
                    $inferredTenantId = ('GraphContext' |::> GetConnection).Identity |=> GetTenantId

                    if ( ! $inferredTenantId ) {
                        throw [ArgumentException]::new("No tenant was specified for app-only auth, and a tenant could not be inferred from the current token -- specify a tenant id with the -TenantId parameter and retry the command.")
                    }

                    $adjustedTenantId = $inferredTenantId
                }
            }

            $newAppId = if ( $appId ) {
                $appId
            } else {
                $::.Application.DefaultAppId
            }

            $app = new-so GraphApplication $newAppId $AppRedirectUri $appSecret $NoninteractiveAppOnlyAuth.IsPresent
            $identity = new-so GraphIdentity $app $graphEndpoint $adjustedTenantId
            new-so GraphConnection $graphEndpoint $identity $specifiedScopes $NoBrowserSigninUI.IsPresent
        }
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter New-GraphConnection Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))
