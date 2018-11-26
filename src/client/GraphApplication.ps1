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

. (import-script Application)
. (import-script ../common/Secret)

enum GraphAppAuthType {
    Delegated
    AppOnly
}

ScriptClass GraphApplication {
    $AppId = strict-val [Guid]
    $Secret = $null
    $AuthType = ([GraphAppAuthType]::Delegated)
    $RedirectUri = $null

    function __initialize($appId = $null, $RedirectUri = $null, $secret = $null) {
        $this.AppId = if ( $appId -ne $null ) {
            $appId
        }

        if ( $secret ) {
            $this.secret = new-so Secret $secret
            $this.AuthType = ([GraphAppAuthType]::AppOnly)
        }

        $this.RedirectUri = if ( $RedirectUri ) {
            $RedirectUri
        } else {
            __GetDefaultRedirectUri $this.AppId
        }
    }

    function __GetDefaultRedirectUri($appId) {
        'msal{0}://auth' -f $appId
    }

    function IsConfidential {
        $this.Secret -ne $null
    }
}
