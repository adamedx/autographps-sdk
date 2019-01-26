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

ScriptClass DeviceCodeAuthenticator {
    static {
        $initialized = $false

        function Authenticate($authContext, $scopes) {
            if ( ! $this.initialized ) {
                . $psscriptroot/CompiledDeviceCodeAuthenticator.ps1
                $this.initialized = $true
            }

            $asyncResult = [CompiledDeviceCodeAuthenticator]::GetTokenWithCode($authContext, $scopes)

            # Need to sleep periodically otherwise console signals like SIG-INT / CTRL-C
            # won't work and you'll be hung if you want to cancel -- you'll have to terminate
            # the process :(.
            while ( ! $asyncResult.IsCompleted ) {
                start-sleep -milliseconds 500
            }

            $asyncResult
        }
    }
}
