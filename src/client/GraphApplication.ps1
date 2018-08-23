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

enum GraphAppAuthType {
    Delegated
    AppOnly
}

ScriptClass GraphApplication {
    $AppId = strict-val [Guid]
    $Secret = $null
    $AuthType = ([GraphAppAuthType]::Delegated)
    $RedirectUri = $null

    function __initialize($appId = $null, $RedirectUri = $null) {
        $this.AppId = if ( $appId -ne $null ) {
            $appId
        } else {
            if ( $RedirectUri ) {
                throw [ArgumentException]::new("Redirect Uri must '$RedirectUri', it must be `$null since no AppId was specified")
            }

            $::.Application.AppId
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
}
