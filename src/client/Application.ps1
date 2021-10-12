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

ScriptClass Application {
    static {
        const DefaultAppId (strict-val [Guid] 'ac70e3e2-a821-4d19-839c-b8af4515254b')
        const DefaultRedirectUri 'http://localhost' # Need to use localhost, otherwise web browser sign-in for MSAL on PS Core is not supported

        # Note that $PSVersionTable.Platform does not exist for Desktop edition
        $SupportsBrowserSignin = ( $PSVersionTable.PSEdition -eq 'Desktop' ) -or `
          ( $PSVersionTable.Platform -eq 'Win32NT' ) # Originally not supported on core for any platform, but now MSAL on Windows only supports it
    }
}
