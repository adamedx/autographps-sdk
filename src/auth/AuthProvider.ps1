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

ScriptClass AuthProvider {
    $provider = $null

    function __initialize {
        $this.provider = new-so V2AuthProvider
    }

    function GetAuthContext($app, $graphEndpointUri, $authUri, $groupId, $certificatePassword, [bool] $useBroker = $false) {
        write-verbose ( 'Auth context requested for auth uri {0}, resource uri {1} appid {2}, groupid {3}, useBroker {4}' -f $authUri, $graphEndpointUri, $app.appid, $groupId, $useBroker )
        $result = [PSCustomObject]@{
            App = $app
            GraphEndpointUri = $graphEndpointUri
            ProtocolContext = $this.provider |=> GetAuthContext $app $authUri $groupId $certificatePassword $useBroker
            GroupId = $groupId
        }

        write-verbose ( 'Returning auth context with hash code {0}' -f $result.ProtocolContext.GetHashCode() )
        $result
    }

    function GetUserInformation($token) {
        $this.provider |=> GetUserInformation $token
    }

    function AcquireFirstUserToken($authContext, $scopes, $useDeviceCodeUI) {
        if ( $useDeviceCodeUI ) {
            $this.provider |=> AcquireFirstUserTokenFromDeviceCode $authContext $scopes
        } else {
            $this.provider |=> AcquireFirstUserToken $authContext $scopes
        }
    }

    function AcquireFirstUserTokenConfidential($authContext, $scopes) {
        if ( ! ($authContext.app |=> IsConfidential) ) {
            throw [ArgumentException]::new("Cannot obtain confidential token using an application that does not support confidential client")
        }
        $this.provider |=> AcquireFirstUserTokenConfidential $authContext $scopes
    }

    function AcquireFirstAppToken($authContext, [securestring] $certificatePassowrd) {
        $this.provider |=> AcquireFirstAppToken $authContext
    }

    function AcquireRefreshedToken($authContext, $token) {
        $this.provider |=> AcquireRefreshedToken $authContext $token
    }

    function ClearToken($authContext, $token) {
        $this.provider |=> ClearToken $authContext $token
    }

    static {
        $instance = $null

        function GetProviderInstance {
            if ( ! $this.instance ) {
                $this.instance = new-so AuthProvider
            }

            $this.instance
        }
    }
}
