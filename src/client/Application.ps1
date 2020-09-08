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

ScriptClass Application {
    static {
        const DefaultAppId (strict-val [Guid] '9825d80c-5aa0-42ef-bf13-61e12116704c')
        const DefaultRedirectUri 'https://login.microsoftonline.com/common/oauth2/nativeclient'
        $SupportsBrowserSignin = $PSVersionTable.PSEdition -eq 'Desktop'
    }
}
