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


        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='autocert')]
        [string] $AppId = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='autocert')]
        [Switch] $NoninteractiveAppOnlyAuth,

        [string] $TenantId,

        [parameter(parametersetname='certpath', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [string] $CertificatePath,

        [parameter(parametersetname='cert', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate = $null,

        [switch] $Confidential,

        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [Switch] $Secret,

        [parameter(parametersetname='secret', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [SecureString] $Password,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='cloud', mandatory=$true)]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='autocert')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud = $null,

        [alias('ReplyUrl')]
        [Uri] $AppRedirectUri,

        [Switch] $NoBrowserSigninUI,

        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $AuthenticationEndpointUri = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $GraphResourceUri = $null,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='customendpoint')]
        [GraphAuthProtocol] $AuthProtocol = [GraphAuthProtocol]::Default,

        [parameter(parametersetname='aadgraph', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [switch] $AADGraph,

        [parameter(parametersetname='current')]
        [Switch] $Current,

        [parameter(parametersetname='existingconnection', mandatory=$true)]
        $Connection,

        [Switch] $AsObject
    )
    Enable-ScriptClassVerbosePreference

    $targetConnection = if ( $connection ) {
        $connection
    } elseif ( $Current.IsPresent ) {
        ($::.GraphContext |=> GetCurrent).connection
    } else {
        $connectionArguments = @{}

        # New-GraphConnection only allows specification of a resource uri if we also
        # specify an endpoint to which we will communicate. Iin this case, however,
        # we're not necessarily communicating with any particular endpoint,
        # just getting a token. So make the 'endpoint' the same as the resource uri if
        # one is specified as by default they are the same
        if ( $GraphResourceUri ) {
            $connectionArguments['GraphEndpointUri'] = $GraphResourceUri

            # Note that we do some things for UX that should theoretically be handled
            # with parameter sets. We customize the behavior here in order to keep the
            # parametersets identical to those for New-GraphConnection and Connect-Graph,
            # which makes it easy to maintain symmetry with those related commands.
            if ( ! $AuthenticationEndpointUri ) {
                # Add this automatically if it wasn't specified so callers don't need to
                # figure out the right value for this parameter
                $connectionArguments['AuthenticationEndpointUri'] = 'https://login.microsoftonline.com/common'
            }
        }

        if ( $AuthenticationEndpointUri -and ! $connectionArguments['GraphEndpoint'] ) {
            $connectionArguments['GraphEndpoint'] = 'https://graph.microsoft.com'
        }

        $psboundparameters.keys | where { $psboundparameters[$_] -and @('Current', 'Connection', 'AsObject') -notcontains $_ } | foreach {
            $connectionArguments[$_] = $psboundparameters[$_]
        }

        New-GraphConnection @connectionArguments
    }

    $targetConnection |=> Connect

    $tokenObject = $targetConnection.Identity.Token
    if ( $AsObject.IsPresent ) {
        $tokenObject
    } else {
        $tokenObject.AccessToken
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Get-GraphToken Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))
