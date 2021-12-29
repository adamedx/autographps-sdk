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

enum GraphCloud {
    Public
    ChinaCloud
    GermanyCloud
    USGovernmentCloud
    Custom
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
            }
            [GraphCloud]::ChinaCloud = @{
                Authentication='https://login.chinacloudapi.cn'
                Graph='https://microsoftgraph.chinacloudapi.cn'
            }
            [GraphCloud]::GermanyCloud = @{
                Authentication='https://login.microsoftonline.de'
                Graph='https://graph.microsoft.de'
            }
            [GraphCloud]::USGovernmentCloud = @{
                Authentication='https://login.microsoftonline.us'
                Graph='https://graph.microsoft.us'
            }
        }

        function GetCloudEndpoint([GraphCloud] $cloud) {
            # We *MUST* clone these -- otherwise callers have a reference to the
            # shared instance in the static class, and they can overwrite it!
            $this.MSGraphCloudEndpoints[$cloud].Clone()
        }

        function IsWellKnownCloud([string] $cloud) {
            $cloud -ne 'Custom' -and ( $cloud -in [GraphCloud]::GetNames([GraphCloud]) )
        }
    }

    $Authentication = $null
    $Graph = $null
    $Cloud = ([GraphCloud]::Custom)
    $GraphResourceUri = $null

    function __initialize {
        [cmdletbinding()]
        param (
            [GraphCloud] $cloud,
            [Uri] $GraphEndpoint,
            [Uri] $AuthenticationEndpoint,
            [Uri] $graphResourceUri
        )

        $this.Cloud = $cloud
        $endpointData = if ($GraphEndpoint -eq $null) {
            $cloudEndpoint = $this.scriptclass |=> GetCloudEndpoint $cloud
            $cloudEndpoint
        } else {
            @{
                Graph=$GraphEndpoint
                Authentication=$AuthenticationEndpoint
            }
        }

        $this.Authentication = new-object Uri $endpointData.Authentication
        $this.Graph = new-object Uri $endpointData.Graph
        $this.GraphResourceUri = if ( $graphResourceUri ) { $graphResourceUri } else { $this.Graph }
    }

    function GetAuthUri($tenantName, $allowMSA) {
        $tenantSegment = if ( $allowMSA -and ! $tenantName ) {
            'common'
        } elseif ( $tenantName ) {
            $tenantName
        } else {
            'organizations'
        }

        $components = @($this.Authentication.tostring().trimend('/'))
        if ( $tenantSegment ) {
            $components += $tenantSegment
        }

        $components -join '/'
    }
}
