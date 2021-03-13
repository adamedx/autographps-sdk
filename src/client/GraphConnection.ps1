# Copyright 2020, Adam Edwards
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

    function __initialize([PSCustomObject] $graphEndpoint, [PSCustomObject] $Identity, [Object[]]$Scopes, $noBrowserUI = $false, $userAgent = $null, [string] $name) {
        $this.Id = new-guid
        $this.GraphEndpoint = $graphEndpoint
        $this.Identity = $Identity
        $this.Connected = $false
        $this.Status = [GraphConnectionStatus]::Online
        $this.UserAgent = $userAgent
        $this.Name = $name

        $isRemotePSSession = (get-variable PSSenderInfo -erroraction ignore) -ne $null
        write-verbose ("Browser supported: {0}, NoBrowserUISpecified {1}, IsRemotePSSession: {2}" -f $::.Application.SupportsBrowserSignin, $noBrowserUI, $isRemotePSSession)

        $this.NoBrowserUI = ! $::.Application.SupportsBrowserSignin -or $noBrowserUI -or $isRemotePSSession

        if ( $this.GraphEndpoint.Type -eq 'MSGraph') {
            if ( $Identity -and ! $scopes ) {
                throw "No scopes were specified, at least one scope must be specified"
            }
            $this.Scopes = $Scopes
        }

        if ( $name ) {
            $this.scriptclass |=> AddNamedConnection $name $this
        }
    }

    function Connect {
        write-verbose ( 'Request to connect connection id {0}' -f $this.id )
        if ( ($this.Status -eq [GraphConnectionStatus]::Online) -and (! $this.connected) ) {
            if ($this.Identity) {
                $this.Identity |=> Authenticate $this.Scopes $this.NoBrowserUI $this.id
            }
            $this.connected = $true
        }
    }

    function GetToken {
        if (! $this.Identity) {
            throw [ArgumentException]::new('Cannot obtain a token for this connection because the connection is anonymous')
        }

        if ( $this.Status -eq [GraphConnectionStatus]::Online ) {
            if ( $this.GraphEndpoint.Type -eq 'MSGraph' ) {
                # Trust the library's token cache to get a new token if necessary
                $this.Identity |=> Authenticate $this.Scopes $this.NoBrowserUI $this.id
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

        function NewSimpleConnection([string] $graphType = 'MSGraph', [string] $cloud = 'Public', [String[]] $ScopeNames, $anonymous = $false, $tenantName = $null, $authProtocol = $null, $userAgent = $null, $allowMSA = $true, $name ) {
            $endpoint = new-so GraphEndpoint $cloud $graphType $null $null $authProtocol
            $app = new-so GraphApplication $::.Application.DefaultAppId
            $identity = if ( ! $anonymous ) {
                new-so GraphIdentity $app $endpoint $tenantName $allowMSA
            }

            new-so GraphConnection $endpoint $identity $ScopeNames $false $userAgent $name
        }

        function ToConnectionInfo([PSCustomObject] $connection) {
            [PSCustomObject] @{
                Id = $connection.id
                Name = $connection.Name
                AppId = $connection.identity.app.appid
                Endpoint = $connection.graphendpoint.graph
                Tenant = $connection.identity.GetTenantId()
                User = $connection.identity.GetUserInformation().UserId
                Status = $connection.getstatus()
                Connection = $connection
            }
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
