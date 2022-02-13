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

if ( ! ( Get-Variable __IntegrationTestRoot -ErrorAction Ignore ) ) {
    return
}

Describe "When executing integration tests against live, non-mocked infrastructure" -Tag Integration {
    BeforeAll {
        if ( ! ( & $__IntegrationTestRoot/IsIntegrationTestRun.ps1 ) ) {
            throw "Attempting to execute integration test outside of a valid integration test context"
        }
    }

    Context "When invoking the Test-Graph command" {
        It "Should succeed with no parameters" {
            Test-Graph -OutVariable result | Should Not Be $null
            $result.TestUri | Should Be 'https://graph.microsoft.com/v1.0/$metadata'
        }
    }
}
