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

. (import-script ../Client/GraphConnection)
. (import-script ../Client/LogicalGraphManager)

ScriptClass GraphContext {
    $connection = $null
    $version = $null
    $name = $null
    $location = $null
    $state = $null

    function __initialize($connection, $apiversion, $name) {
        if ( ! $name ) {
            throw "Graph name must be specified"
        }

        $this.state = @{}

        $graphVersion = if ( $apiVersion ) { $apiVersion } else { $this.scriptclass |=> GetDefaultVersion }

        $this.connection = if ( $connection ) { $connection } else { $this.scriptclass |=> GetConnection }
        $this.version = $graphVersion
        $this.name = $name
        $this.location = $this.scriptclass |=> GetDefaultLocation
    }

    function GetState($stateKey) {
        $this.state[$stateKey]
    }

    function AddState($stateKey, $value) {
        $this.state.Add($stateKey, $value)
    }

    function UpdateState($stateKey, $value) {
        if ( ! $this.state.ContainsKey($stateKey) ) {
            throw "State '$stateKey' does not exist"
        }
        $this.state[$stateKey] = $value
    }

    function GetEndpoint {
        $this.connection.GraphEndpoint.Graph
    }

    function UpdateConnection($connection) {
        $newConnection = if ( $connection ) {
            write-verbose 'Connection specified to UpdateConnection'
            $connection
        } else {
            write-verbose 'No connection specified to UpdateConnection'
            $this.scriptclass |=> GetConnection
        }

        write-verbose 'Connecting...'

        $newConnection |=> Connect

        write-verbose 'Connection succeeded.'

        if ( $this.connection |=> IsConnected ) {
            write-verbose 'Disconnecting existing context connection'
            $this.connection |=> Disconnect
        } else {
            write-verbose 'Skipping disconnect as existing context connection is not connected'
        }

        $this.connection = $newConnection
    }

    function SetLocation([PSCustomObject] $location) {
        $this.location = $location
    }

    static {
        $current = $null
        $defaultContextName = 'v1.0'
        $defaultLocation = $null

        function __initialize {
            $::.LogicalGraphManager |=> __initialize
            $currentContext = $::.LogicalGraphManager |=> Get |=> NewContext $null ($::.GraphConnection |=> NewSimpleConnection ([GraphType]::MSGraph) Public @('User.Read')) (GetDefaultVersion) $this.defaultContextName
            $this.current = $currentContext.Name
        }

        function GetDefaultLocation {
            $this.defaultLocation
        }

        function SetDefaultLocation($location) {
            $this.defaultLocation = $location
        }

        function FindContext($endpoint, $apiVersion) {
            $::.LogicalGraphManager |=> Get |=> FindContext $endpoint $apiVersion
        }

        function GetCurrent  {
            if ( $this.current ) {
                write-verbose "Attempt to get current context -- current context is set to '$($this.current)'"
                $manager = $::.LogicalGraphManager |=> Get
                $manager |=> GetContext $this.current
            } else {
                write-verbose "Attempt to get current context -- no context is currently set"
            }
        }

        function SetCurrentByName($name) {
            if ( ! ($::.LogicalGraphManager |=> Get |=> GetContext $name) ) {
                throw "No such context: '$name'"
            }

            write-verbose "Setting current context to '$name'"
            $this.current = $name
        }

        function GetCurrentConnection {
            $context = GetCurrent
            if ( $context ) {
                $context.connection
            }
        }

        function DisconnectCurrentConnection {
            $context = GetCurrent
            if ( $context ) {
                if ($context.connection ) {
                    $context.connection |=> Disconnect
                }
            } else {
                throw "Cannot disconnect the current context from Graph because there is no current context."
            }
        }

        function GetDefaultVersion {
            $::.GraphEndpoint.DefaultGraphAPIVersion
        }

        function __IsContextConnected($context) {
            $context -and ($context.connection |=> IsConnected)
        }

        function GetConnection($connection = $null, $context = $null, $cloud = $null, [String[]] $scopenames = $null, $anonymous = $null) {
            $currentContext = GetCurrent
            $chosenContext = $null

            $existingConnection = if ( $connection ) {
                write-verbose "Using supplied connection"
                $connection
            } elseif ( $context ) {
                write-verbose "Using connection from supplied context '$($context.name)'"
                $chosenContext = $context
                $context.connection
            } elseif ( $currentContext ) {
                write-verbose "Found existing connection from current context '$($currentcontext.name)'"
                if ( ( ! $cloud -or $currentContext.cloud -eq $cloud) -and
                     (!$scopenames -or ($scopenames -is [String] -and $scopenames -eq 'User.Read') -or ($scopenames -is [String[]] -and $scopenames.length -eq 1 -and $scopenames[0] -eq 'User.Read' )) -and
                     ! $anonymous
                   ) {
                       write-verbose "Current context is compatible with supplied arguments, will use it"
                       $chosenContext = $currentContext
                       $currentContext.connection
                   } else {
                       write-verbose "Current context is not compatible with supplied arguments, new connection required"
                   }
            }

            $connectionScopes = if ( $scopeNames ) {
                $scopeNames
            } else {
                write-verbose "Scopes were not specified, adding default User.Read scope"
                @('User.Read')
            }

            if ( $existingConnection ) {
                write-verbose "Using an existing connection supplied directly or obtained through a context"
                $existingConnection
            } else {
                write-verbose "No connection supplied and no compatible connection found from a context"
                $namedArguments=@{Anonymous=($anonymous -eq $true)}
                if ( $cloud ) { $namedArguments['Cloud'] = $cloud }
                $namedArguments['ScopeNames'] = $connectionScopes

                write-verbose "Custom arguments or no current context -- getting a new connection"
                $newConnection = $::.GraphConnection |=> NewSimpleConnection ([GraphType]::MSGraph) @namedArguments
                if ( $chosenContext ) {
                    write-verbose ("Adding new connection to context '{0}'" -f $chosenContext.name)
                    $chosenContext.connection = $newConnection
                } else {
                    write-verbose 'New connection not associated with a context, not connecting it'
                }
                $newConnection
            }
        }
    }
}

$::.GraphContext |=> __initialize

