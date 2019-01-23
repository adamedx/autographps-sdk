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

. (import-script New-GraphConnection)

function Get-GraphToken {
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

        [parameter(parametersetname='aadgraph', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [switch] $AADGraph,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud', mandatory=$true)]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='autocert')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='cert', mandatory=$true)]
        [parameter(parametersetname='certpath', mandatory=$true)]
        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [parameter(parametersetname='autocert', mandatory=$true)]
        $AppId = $null,

        [switch] $Confidential,

        [Uri] $AppRedirectUri,

        [parameter(parametersetname='msgraph')]
        [Switch] $NoBrowserSigninUI,

        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='cert', mandatory=$true)]
        [parameter(parametersetname='certpath', mandatory=$true)]
        [parameter(parametersetname='autocert', mandatory=$true)]
        [Switch] $NoninteractiveAppOnlyAuth,

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

        [String] $TenantId = $null,

        [parameter(parametersetname='current')]
        [Switch] $Current,

        [parameter(parametersetname='existingconnection', mandatory=$true)]
        $Connection
    )

    $targetConnection = if ( $connection ) {
        $connection
    } elseif ( $Current.IsPresent ) {
        ($::.GraphContext |=> GetCurrent).connection
    } else {
        $connectionArguments = @{}
        $psboundparameters.keys | foreach {
            $connectionArguments[$_] = $psboundparameters[$_]
        }

        New-GraphConnection @connectionArguments
    }

    $targetConnection |=> Connect

    $targetConnection.Identity.Token.AccessToken
}

$::.ParameterCompleter |=> RegisterParameterCompleter Get-GraphToken Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))
