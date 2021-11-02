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

Describe 'GraphContext class' {
    Context 'When updating a context to have a new connection' {
        $expectedUserPrincipalName = 'searchman@megarock.org'
        $meResponseDataExpected = '"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/$entity","businessPhones":[],"displayName":"Search Man","givenName":null,"jobTitle":"Administrator","mail":null,"mobilePhone":null,"officeLocation":null,"preferredLanguage":null,"surname":null,"userPrincipalName":"{0}","id":"012345567-89ab-cdef-0123-0123456789ab"' -f $expectedUserPrincipalName
        $meResponseExpected = "{$meResponseDataExpected}"

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

        ScriptClass MockToken {
            $TenantId = 'mocktenant'
            $expireson = ([DateTime]::now + [TimeSpan]::new(1,0,0,0))
            $Account = @{username='user@mocktenant'}
            $Scopes = @()
            $Uniqueid = 'user@mocktenant'
            function CreateAuthorizationHeader {
                'mockjwt'
            }
        }

        $mockAuthResult = @{
            Status ='Succeeded'
            Result = $null
            IsFaulted = $false
        }

        $mockData = @{
            mockAuthResult = $mockAuthResult
            InitialConnectionId = $null
            InitialProtocolContext = $null
        }

        # Need to handle this case for PowerShell Core -- here at least
        # we don't need to work around the scriptclass bug and can
        # directly use mockcontext
        Mock-ScriptClassMethod DeviceCodeAuthenticator Authenticate -static {
            $mockAuthResult = $mockContext.mockAuthResult
            $newToken = new-so MockToken
            $mockAuthResult.Result = $newToken
            $mockAuthResult
        } -MockContext $mockData

        # Since the scriptclass mockcontext defect does not occur
        # when mocking via class as we are here (rather than object)
        # we can save the mockcontext in the authcontext so that it can
        # be used later in a scenario where we've mocked. See further comments
        # on the scriptclass defect.
        # TODO: Another scriptclass defect: apparently, Mock-ScriptClassMethod
        # for an instance method of a class resets the state of the classes static properties! So
        # we must invoke Mock-ScriptClassMethod before doing anything the state is changed from
        # the initial state, and we do that here. Not good.
        Mock-ScriptClassMethod AuthProvider GetAuthContext {
            param($app, $graphEndpointUri, $authUri, $groupId)
            $result = [PSCustomObject]@{
                App = $app
                GraphEndpointUri = $graphEndpointUri
                ProtocolContext = $this.provider |=> GetAuthContext $app $authUri $groupId
                GroupId = $groupId
                _mockContext = $mockContext
            }

            if ( ! $mockContext.InitialProtocolContext ) {
                $mockContext.InitialProtocolContext = $result.protocolContext
                $mockContext.InitialConnectionId = $groupId
            } elseif ( $mockContext.InitialConnectionId -ne $groupId ) {
                if ( $mockContext.InitialProtocolContext.gethashcode() -eq $result.protocolContext.gethashcode() ) {
                    throw "Protocol context for group id '$groupid' was used by previous connection '$($mockContext.InitialConnectionId)'; it should be a new connection not used by previous connections"
                }
            }

            $result
        } -mockcontext $mockData

        # TODO: Remove this complexity as providers are no longer emulations
        # of derived classes
        $v2AuthProvider = ($::.AuthProvider |=> GetProviderInstance).provider

        # We have to do some strange things to work around a bug in scriptclass
        # where mockcontext is not passed on mocking an object rather than a
        # class
        Mock-ScriptClassMethod $v2AuthProvider __AcquireTokenInteractive {
            param($authContext, $scopes)
            $newToken = new-so MockToken
            $mockAuthResult = $authContext._mockContext.mockAuthResult
            $mockAuthResult.Result = $newToken
            $mockAuthResult
        }

        Mock-ScriptClassMethod $v2AuthProvider __RemoveCachedToken {}

        It 'Should clear the authentication token from the original connection and not the new connection' {
            # This will get an auth token
            Invoke-GraphApiRequest me | out-null

            $firstConnection = (Get-GraphCurrentConnection).connection
            $firstResult = $mockAuthResult.Result

            # This will reconnect and should get a different token
            # rather than reusing the earlier token.
            { connect-graphapi -Permissions user.read | out-null } | Should Not Throw

            Assert-VerifiableMock

            $secondConnection = (Get-GraphCurrentConnection)
            $secondResult = $mockAuthResult.Result

            # Make sure that when reconnecting, we obtained a new token for the second
            # connection, and invalidated the first
            $secondConnection.Identity.Token | Should Not Be $null
            $firstConnection.Identity.Token | Should Be $null

            # Make sure have distinct tokens from the first and second instances
            $firstResult.GetScriptObjectHashCode() | Should Not Be $secondResult.GetScriptObjectHashCode()
        }
    }
}

