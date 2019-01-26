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

enum GraphCloud {
    Public
    ChinaCloud
    GermanyCloud
    USGovernmentCloud
    Custom
}

enum GraphType {
    MSGraph
    AADGraph
}

enum GraphAuthProtocol {
    Default
    v1
    v2
}

ScriptClass GraphEndpoint {
    static {
        const DefaultGraphAPIVersion 'v1.0'
        # Note: this hash table, as well as the nested hash tables,
        # Must be protected -- do *NOT* give references to them outside
        # the static methods of this class -- that includes preventing
        # instance methods from having access! If callers need access to,
        # the hash tables, clone them. Without that, callers can modify
        # this shared state! This is an issue for any objects that are not
        # treated by value. Strings and integers for instance are ok, any
        # object type is not, and must be handled with care.
        $MSGraphCloudEndpoints = @{
            [GraphCloud]::Public = @{
                Authentication='https://login.microsoftonline.com'
                Graph='https://graph.microsoft.com'
                AuthProtocol=[GraphAuthProtocol]::v2
            }
            [GraphCloud]::ChinaCloud = @{
                Authentication='https://login.chinacloudapi.cn'
                Graph='https://microsoftgraph.chinacloudapi.cn'
                AuthProtocol=[GraphAuthProtocol]::v1
            }
            [GraphCloud]::GermanyCloud = @{
                Authentication='https://login.microsoftonline.de'
                Graph='https://graph.microsoft.de'
                AuthProtocol=[GraphAuthProtocol]::v1
            }
            [GraphCloud]::USGovernmentCloud = @{
                Authentication='https://login.microsoftonline.us'
                Graph='https://graph.microsoft.us'
                AuthProtocol=[GraphAuthProtocol]::v1
            }
        }

        $AADGraphCloudEndpoints = @{
            Authentication = 'https://login.microsoftonline.com'
            Graph='https://graph.windows.net'
            AuthProtocol=[GraphAuthProtocol]::v1
        }

        function GetCloudEndpoint([GraphCloud] $cloud, [GraphType] $graphType) {
            # We *MUST* clone these -- otherwise callers have a reference to the
            # shared instance in the static class, and they can overwrite it!
            if ($graphType -eq [GraphType]::MSGraph) {
                $this.MSGraphCloudEndpoints[$cloud].Clone()
            } else {
                $this.AADGraphCloudEndpoints.Clone()
            }
        }

        function GetAuthProtocol($specifiedAuthProtocol, $cloud, $graphType) {
            if ( $specifiedAuthProtocol -eq $null ) {
                throw "Invalid auth protocol -- auth protocol must not be null"
            }

            $authProtocol = if ( $specifiedAuthProtocol -ne ([GraphAuthProtocol]::Default) ) {
                $specifiedAuthProtocol
            } else {
                $cloudEndpoint = GetCloudEndpoint $cloud $graphType
                if ( $cloudEndpoint ) {
                    $cloudEndpoint.AuthProtocol
                } else {
                    [GraphAuthProtocol]::v2
                }
            }

            $authProtocol
        }
    }

    $Authentication = $null
    $Graph = $null
    $Type = ([GraphType]::MSGraph)
    $Cloud = ([GraphCloud]::Custom)
    $AuthProtocol = $null

    function __initialize {
        [cmdletbinding()]
        param (
            [GraphCloud] $cloud,
            [GraphType] $graphType = [GraphType]::MSGraph,
            [Uri] $GraphEndpoint,
            [Uri] $AuthenticationEndpoint,
            $authProtocol = $null
        )

        $this.Type = $GraphType
        $this.Cloud = $cloud
        $endpointData = if ($GraphEndpoint -eq $null) {
            $cloudEndpoint = $this.scriptclass |=> GetCloudEndpoint $cloud $graphType
            if ( $authProtocol ) {
                $cloudEndpoint.AuthProtocol = $authProtocol
            }
            $cloudEndpoint
        } else {
            @{
                Graph=$GraphEndpoint
                Authentication=$AuthenticationEndpoint
                AuthProtocol=($this.scriptclass |=> GetAuthProtocol $authProtocol $cloud $graphType)
            }
        }

        $this.Authentication = new-object Uri $endpointData.Authentication
        $this.Graph = new-object Uri $endpointData.Graph
        $this.AuthProtocol = $endpointData.AuthProtocol
    }

    function GetAuthUri($tenantName) {
        $tenantSegment = if ( ! $TenantName ) {
            'common'
        } else {
            $tenantName
        }

        $components = @($this.Authentication.tostring().trimend('/'))
        if ( $tenantSegment ) {
            $components += $tenantSegment
        }

        $components -join '/'
    }
}
