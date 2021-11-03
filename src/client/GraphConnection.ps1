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

. (import-script ../graphservice/GraphEndpoint)
. (import-script GraphIdentity)

enum GraphConnectionStatus {
    Online
    Offline
}

ScriptClass GraphConnection {
    $Id = $null
    $Identity = $null
    $GraphEndpoint = $null
    $Scopes = $null
    $Connected = $false
    $Status = [GraphConnectionStatus]::Online
    $NoBrowserUI = $false
    $UserAgent = $null
    $Name = $null
    $ConsistencyLevel = $null

    function __initialize([PSCustomObject] $graphEndpoint, [PSCustomObject] $Identity, [Object[]]$Scopes, $noBrowserUI = $false, $userAgent = $null, [string] $name, [string] $consistencyLevel = 'Auto' ) {
        $this.Id = new-guid
        $this.GraphEndpoint = $graphEndpoint
        $this.Identity = $Identity
        $this.Connected = $false
        $this.Status = [GraphConnectionStatus]::Online
        $this.UserAgent = $userAgent
        $this.Name = $name

        $isRemotePSSession = (get-variable PSSenderInfo -erroraction ignore) -ne $null
        write-verbose ("Browser supported: {0}, NoBrowserUISpecified {1}, IsRemotePSSession: {2}" -f $::.Application.SupportsBrowserSignin, $noBrowserUI, $isRemotePSSession)

        $this.consistencyLevel = if ( $consistencyLevel ) {
            if ( $consistencyLevel -notin 'Auto', 'Default', 'Session', 'Eventual' ) {
                throw "The specified consistency level of '$consistencyLevel' is not valid -- it must be one of 'Auto', 'Default', 'Session', or 'Eventual'"
            }
            if ( $consistencyLevel -notin 'Auto', 'Default' ) {
                $consistencyLevel
            }
        }

        $this.NoBrowserUI = ! $::.Application.SupportsBrowserSignin -or $noBrowserUI -or $isRemotePSSession

        if ( $this.GraphEndpoint.Type -eq 'MSGraph') {
            $this.Scopes = $Scopes
        }

        if ( $name ) {
            $this.scriptclass |=> AddNamedConnection $name $this
        }
    }

    function Connect([securestring] $certificatePassword) {
        write-verbose ( 'Request to connect connection id {0}' -f $this.id )
        if ( ($this.Status -eq [GraphConnectionStatus]::Online) -and (! $this.connected) ) {
            if ($this.Identity) {
                $this.Identity |=> Authenticate $this.Scopes $this.NoBrowserUI $this.id $certificatePassword
            }
            $this.connected = $true
        }
    }

    function GetToken([securestring] $certificatePassword) {
        if (! $this.Identity) {
            throw [ArgumentException]::new('Cannot obtain a token for this connection because the connection is anonymous')
        }

        if ( $this.Status -eq [GraphConnectionStatus]::Online ) {
            if ( ! $this.connected -and ( ! $this.scriptclass.AutoConnectAllowed() ) ) {
                $errorOutput =  "The current context is disconnected and AutoConnect is disabled -- invoke 'Connect-GraphApi -Current' before retrying this or any other commands that access the Graph API"
                write-warning $errorOutput
                write-error $errorOutput -erroraction stop
            }
            if ( $this.GraphEndpoint.Type -eq 'MSGraph' ) {
                # Trust the library's token cache to get a new token if necessary
                $this.Identity |=> Authenticate $this.Scopes $this.NoBrowserUI $this.id $certificatePassword
                $this.connected = $true
            } else {
                Connect
            }
        }

        $this.Identity.Token
    }

    function SetStatus( [GraphConnectionStatus] $status ) {
        $this.Status = $status
    }

    function GetStatus() {
        $this.Status
    }

    function GetCertificatePath {
        if ( $this.identity -and $this.identity.app ) {
            $this.identity.app.secret |=> GetCertificatePath
        }
    }

    function Disconnect {
        write-verbose ( 'Request to disconnect connection id {0}' -f $this.id )
        if ( $this.connected ) {
            if ( $this.identity ) {
                $this.identity |=> ClearAuthentication $this.id
            }
            $this.connected = $false
        } else {
            throw "Cannot disconnect from Graph because connection is already disconnected."
        }
    }

    function IsConnected {
        $this.connected
    }

    static {
        $connections = $null
        function __initialize {
            $this.connections = @{}
        }

        function AutoConnectAllowed {
            $currentProfile = $::.LocalProfile |=> GetCurrentProfile

            if ( $currentProfile ) {
                $currentProfile.GetSetting('autoConnect') -ne $false
            } else {
                $true
            }
        }

        function NewSimpleConnection([string] $graphType = 'MSGraph', [string] $cloud = 'Public', [String[]] $ScopeNames, $anonymous = $false, $tenantName = $null, $userAgent = $null, $allowMSA = $true, $name, [string] $consistencyLevel ) {
            $endpoint = new-so GraphEndpoint $cloud $graphType $null $null $null
            $app = new-so GraphApplication $::.Application.DefaultAppId
            $identity = if ( ! $anonymous ) {
                new-so GraphIdentity $app $endpoint $tenantName $allowMSA
            }

            new-so GraphConnection $endpoint $identity $ScopeNames $false $userAgent $name $consistencyLevel
        }

        # TODO: This is not currently used, was originally a way to wrap the connection object into something user-friendly.
        # Reality is that PowerShell type formatting in ps1xml can make GraphConnection user-consumable AND satisfy the
        # need to allow GraphConnection to be used as an output and input to commands without the overhead of a 'wrapper.'
        # There are still some benefits to the wrapper, namely the desired properties can be easily selected with auto-complete
        # and accessed without dereferencing properties of undocumented objects referenced at the root of GraphConnection, so
        # there may be value in restoring this approach in the future.
        function ToConnectionInfo([PSCustomObject] $connection) {
            $consistencyLevel = if ( $connection.consistencyLevel ) { $connection.consistencyLevel } else { 'Auto' }

            $info = [PSCustomObject] @{
                Id = $connection.id
                Name = $connection.Name
                AppId = $connection.identity.app.appid
                OrganizationName = $connection.identity.TenantDisplayName
                Endpoint = $connection.graphendpoint.graph
                AuthType = $connection.identity.app.authtype
                Tenant = $connection.identity.GetTenantId()
                User = $connection.identity.GetUserInformation().UserId
                Connected = $connection.connected
                Status = $connection.getstatus()
                ConsistencyLevel = $consistencyLevel
                Connection = $connection
            }

            $info.pstypenames.insert(0, 'GraphConnectionInfo')

            $info
        }

        function AddNamedConnection([string] $name, $connection) {
            $this.connections.Add($name, $connection)
        }

        function GetNamedConnection([string] $name, [boolean] $failOnNotExists) {
            $connections = if ( $name ) {
                $this.connections[$name]
            } else {
                $this.connections.values | sort-object Name
            }

            if ( $name -and ( ! $connections -and $failOnNotExists ) ) {
                throw "No connection with the name '$name' exists."
            }

            if ( $connections ) {
                $connections
            }
        }

        function RemoveNamedConnection([string] $name, [boolean] $failOnNotExists) {
            $connection = GetNamedConnection $name $failOnNotExists

            if ( $connection ) {
                $this.connections.Remove($name)
            }
        }
    }
}

$::.GraphConnection |=> __initialize
