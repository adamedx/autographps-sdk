# Copyright 2022, Adam Edwards
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

@{
    Title = 'Common AutoGraph commands'
    Description = 'These samples demonstrate simple use cases of the most commonly used AutoGraph commands.'
    BeforeAll = {
        param([HashTable] $setupParams, [HashTable] $setupState, [HashTable] $TestContext)
        Connect-GraphApi -Connection $global:__IntegrationTestGraphConnection | out-null

        $testInfo = & $setupParams['TestInfoCommand']
        $TestContext.Add('TestInfo', $testInfo)
        $TestContext.Add('TenantId', $testInfo.TestAppTenant)
    }
    AfterAll = {param([HashTable] $setupState)}
    BeforeEach = {param([HashTable] $setupParams, [HashTable] $setupState, [HashTable] $TestContext)}
    AfterEach = {param([HashTable] $setupState)}
    TestSetupParams = @{
        TestInfoCommand = ( Get-Item "$psscriptroot/../../test/Get-IntegrationTestStatus.ps1" ).FullName
    }
    Samples = @(
        @{
            Name = 'Hello world'
            Description = 'Check to see if you have connectivity to the default Graph API endpoint'
            TestParameters = @()
            SampleGenerator = {
                param()
                "Test-Graph"
            }
        }

        @{
            Name = 'Test-Graph with params'
            Description = 'Check to see if you have connectivity to the specific China Graph API endpoint'
            TestParameters = @('ChinaCloud')
            SampleGenerator = {
                param($Cloud='ChinaCloud')
                "Test-Graph -Cloud $Cloud"
            }
        }

        @{
            Name = 'Get-GraphResource for /organization'
            Description = 'Read the organization object'
            TestParameters = @()
            SampleGenerator = {
                param()
                "Get-GraphResource /organization"
            }
            Test = {
                $organizationId = (get-graphconnection -current).identity.tenantdisplayid
                $testResult.Id | Should Be $organizationId
                $testResult.displayName.Length | Should BeGreaterThan 0
            }
        }

        @{
            Name = 'Get-GraphResource for /me'
            Description = 'Read the current signed-in user'
            TestParameters = @()
            SampleGenerator = {
                param()
                "Get-GraphResource /me"
            }
            ExpectedExceptionSubstring = 'Request'
        }
    )
}

