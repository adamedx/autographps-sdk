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

. (import-script ../client/GraphConnection)
. (import-script ../client/GraphContext)
. (import-script ../client/LogicalGraphManager)
. (import-script New-GraphConnection)
. (import-script common/DynamicParamHelper)
. (import-script ../common/ScopeHelper)
. (import-script common/PermissionParameterCompleter)

function Connect-GraphApi {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='msgraph')]
    param(
        [parameter(parametersetname='msgraphname', position=0, valuefrompipelinebypropertyname=$true, mandatory=$true)]
        [ArgumentCompleter({
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
                               $::.GraphConnection |=> GetNamedConnection | where Name -like "$($wordToComplete)*" | select-object -expandproperty Name
                           })]
        [Alias('Name')]
        [string] $ConnectionName,

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='msgraphname')]
        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='customendpoint')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [parameter(parametersetname='autocert')]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='current')]
        [String[]] $Permissions = $null,

        [parameter(parametersetname='cloud')]
        [parameter(parametersetname='msgraph')]
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

        [parameter(parametersetname='certpath')]
        [PSCredential] $CertCredential,

        [parameter(parametersetname='certpath')]
        [switch] $NoCertCredential,

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
        [Uri] $GraphEndpointUri = $null,

        [parameter(parametersetname='customendpoint', mandatory=$true)]
        [parameter(parametersetname='secret')]
        [parameter(parametersetname='cert')]
        [parameter(parametersetname='certpath')]
        [Uri] $AuthenticationEndpointUri = $null,

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
        [ValidateSet('v1', 'v2', 'Default')]
        [String] $AuthProtocol = 'Default',

        [parameter(parametersetname='msgraph')]
        [parameter(parametersetname='customendpoint')]
        [ValidateSet('Auto', 'AzureADOnly', 'AzureADAndPersonalMicrosoftAccount')]
        [string] $AccountType = 'Auto',

        [ValidateSet('Auto', 'Default', 'Session', 'Eventual')]
        [string] $ConsistencyLevel = 'Auto',

        [parameter(parametersetname='aadgraph', mandatory=$true)]
        [parameter(parametersetname='customendpoint')]
        [switch] $AADGraph,

        [string] $UserAgent = $null,

        [switch] $NoProfile,

        [parameter(parametersetname='reconnect', mandatory=$true)]
        [Switch] $Reconnect,

        [parameter(parametersetname='existingconnection',mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [parameter(parametersetname='currentconnection',mandatory=$true)]
        [switch] $Current
    )

    begin {
    }

    process {
        Enable-ScriptClassVerbosePreference

        if ( $CertificatePath ) {
            $existingCert = get-item $certificatePath -erroraction ignore

            if ( ! $existingCert ) {
                throw [ArgumentException]::new("The specified certificate path '$CertificatePath' is not accessible. Correct the path and retry the command")
            }

            if ( $existingCert -isnot [System.Security.Cryptography.X509Certificates.X509certificate2] ) {
                if ( ! $NoCertCredential.IsPresent -and ! $CertCredential ) {
                    throw [ArgumentException]::new("The CertCredential parameter or the NoCertCredential parameter must be specified because a file system path '$CertificatePath' was specified with the CertificatePath parameter. Alternatively, a path to a certificate in the PowerShell certificate drive may be specified if the certificate drive is supported on this platform.")
                }
            }
        }

        $validatedCloud = if ( $Cloud ) {
            [GraphCloud] $Cloud
        } else {
            ([GraphCloud]::Public)
        }

        $computedScopes = if ( $Permissions -ne $null ) {
            $Permissions
        } else {
            @('User.Read')
        }

        $context = $::.GraphContext |=> GetCurrent

        if ( ! $context ) {
            throw "No current session -- unable to connect it to Graph"
        }

        $targetConnection = if ( $connection ) {
            $connection
        } elseif ( $ConnectionName ) {
            $::.GraphConnection |=> GetNamedConnection $ConnectionName $true
        } elseif ( $Current.IsPresent -and $context.Connection ) {
            $context.Connection
        }

        $connectionResult = if ( $targetConnection ) {
            write-verbose "Explicit connection was specified"

            $newContext = $::.LogicalGraphManager |=> Get |=> NewContext $context $targetConnection

            $::.GraphContext |=> SetCurrentByName $newContext.name

            $targetConnection |=> Connect

            $targetConnection
        } else {
            write-verbose "Connecting context '$($context.name)'"
            $applicationId = if ( $AppId ) {
                [Guid] $AppId
            } else {
                $::.Application.DefaultAppId
            }

            $newConnection = if ( $Reconnect.IsPresent ) {
                write-verbose 'Reconnecting using the existing connection if it exists'
                if ( $Permissions -and $context.connection -and $context.connection.identity ) {
                    write-verbose 'Creating connection from existing connection but with new permissions'
                    $identity = new-so GraphIdentity $context.connection.identity.app $context.connection.graphEndpoint $context.connection.identity.tenantname
                    new-so GraphConnection $context.connection.graphEndpoint $identity $computedScopes $NoBrowserSigninUI.IsPresent
                } else {
                    write-verbose 'Just reconnecting the existing connection'
                    $context.connection
                }
            } else {
                write-verbose 'No reconnect -- creating a new connection for this context'

                # Get the arguments from the profile -- these will be overridden by
                # any parameters specified to this command
                $currentProfile = if ( ! $NoProfile.IsPresent ) {
                    $::.LocalProfile |=> GetCurrentProfile
                }

                $conditionalArguments = if ( $currentProfile ) {
                    $currentProfile |=> ToConnectionParameters
                } else {
                    @{}
                }

                $PSBoundParameters.keys | where { $_ -notin @('Connect', 'Reconnect', 'ErrorAction', 'ConnectionName', 'CertCredential', 'NoProfile', 'NoCertCredential') } | foreach {
                    $conditionalArguments[$_] = $PSBoundParameters[$_]
                }

                try {
                    new-graphconnection @conditionalArguments -erroraction stop
                } catch {
                    throw
                }
            }

            $certificatePassword = if ( ! $NoCertCredential.IsPresent -and $CertCredential ) {
                $CertCredential.Password
            }

            $context |=> UpdateConnection $newConnection $certificatePassword
            $newConnection
        }

        $::.GraphConnection |=> ToConnectionInfo $connectionResult
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Connect-GraphApi Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))
