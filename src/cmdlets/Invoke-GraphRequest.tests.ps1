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

Describe 'Invoke-GraphApiRequest cmdlet' {
    $expectedUserPrincipalName = 'searchman@megarock.org'
    $meResponseDataExpected = '"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/$entity","businessPhones":[],"displayName":"Search Man","givenName":null,"jobTitle":"Administrator","mail":null,"mobilePhone":null,"officeLocation":null,"preferredLanguage":null,"surname":null,"userPrincipalName":"{0}","id":"012345567-89ab-cdef-0123-0123456789ab"' -f $expectedUserPrincipalName
    $meResponseExpected = "{$meResponseDataExpected}"

    Context 'When making REST method calls to Graph' {
        ScriptClass MockToken {
            function CreateAuthorizationHeader {}
        }

        Mock-ScriptClassMethod GraphConnection GetToken {new-so MockToken}

        Add-MockInScriptClassScope RESTRequest Invoke-WebRequest -MockContext @{
            expectedUserPrincipalName = $expectedUserPrincipalName
            meResponseDataExpected = $meResponseDataExpected
            meResponseExpected = $meResponseExpected
        } {
            [PSCustomObject] @{
                RawContent = $MockContext.meResponseExpected
                RawContentLength = $MockContext.meResponseExpected.length
                Content = $MockContext.meResponseExpected
                StatusCode = 200
                StatusDescription = 'OK'
                Headers = @{'Content-Type'='application/json'}
            }
        }

        It 'Should return an object with the expected user principal name' {
            $meResponse = Invoke-GraphApiRequest me
            $meResponse.userPrincipalName | Should Be $expectedUserPrincipalName
        }
    }
}

