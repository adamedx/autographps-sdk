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

enum GraphCloud {
    Public
    ChinaCloud
    GermanyCloud
    USGovernmentCloud
    Unknown
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
        $MSGraphCloudEndpoints = @{
            [GraphCloud]::Public = @{
                Authentication='https://login.microsoftonline.com/common'
                Graph='https://graph.microsoft.com'
                AuthProtocol=[GraphAuthProtocol]::v2
            }
            [GraphCloud]::ChinaCloud = @{
                Authentication='https://login.chinacloudapi.cn'
                Graph='https://microsoftgraph.chinacloudapi.cn'
                AuthProtocol=[GraphAuthProtocol]::v1
            }
            [GraphCloud]::GermanyCloud = @{
                Authentication='https://login.microsoftonline.de/common'
                Graph='https://graph.microsoft.de'
                AuthProtocol=[GraphAuthProtocol]::v2
            }
            [GraphCloud]::USGovernmentCloud = @{
                Authentication='https://login.microsoftonline.us/common'
                Graph='https://graph.microsoft.us'
                AuthProtocol=[GraphAuthProtocol]::v1
            }
        }

        $AADGraphCloudEndpoints = @{
            Authentication = 'https://login.microsoftonline.com/common'
            Graph='https://graph.windows.net'
            AuthProtocol=[GraphAuthProtocol]::v1
        }
    }

    $Authentication = $null
    $Graph = $null
    $Type = ([GraphType]::MSGraph)
    $Cloud = ([GraphCloud]::Unknown)
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
            if ($graphType -eq [GraphType]::MSGraph) {
                $this.scriptclass.MSGraphCloudEndpoints[$cloud]
            } else {
                $this.scriptclass.AADGraphCloudEndpoints
            }
        } else {
            @{
                Graph=$GraphEndpoint
                Authentication=$AuthenticationEndpoint
                AuthProtocol=if ($authProtocol ) { $authProtocol } else { [GraphAuthProtocol]::v2 }
            }
        }

        $this.Authentication = new-object Uri $endpointData.Authentication
        $this.Graph = new-object Uri $endpointData.Graph
        $this.AuthProtocol = $endpointData.authProtocol
    }
}
