# Copyright 2023, Adam Edwards
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

if ( ! ( & $psscriptroot/../../IsIntegrationTestRun.ps1 ) ) {
    return
}

Describe "The New-GraphApplication command executing unmocked" {

    Set-StrictMode -Version 2

    function RemoveTestApp {
        param(
            [parameter(mandatory=$true)]
            $AppObjectId
        )
        Invoke-GraphApiRequest -Method DELETE -Uri /applications/$AppObjectId -erroraction stop | out-null
    }

    Context "When creating applications" {
        BeforeAll {
            Connect-GraphApi -Connection $global:__IntegrationTestGraphConnection | out-null
            $thisTestInstanceId = New-Guid | select -expandproperty guid

            $appTags = $global:__IntegrationTestInfo.TestRunId, $thisTestInstanceId, '__IntegrationTest__'
        }

        It "should succeed when creating a new public client application" {
            $testAppName = 'SimpleTestApp' + $thisTestInstanceId
            $newApp = New-GraphApplication -Name $testAppName -Tags $appTags
            $newApp.DisplayName | Should Be $testAppName
            { RemoveTestApp $newApp.Id } | Should Not Throw
        }

        AfterAll {
            foreach ( $app in ( Get-GraphApplication -Tags $thisTestInstanceId ) ) {
                RemoveTestApp $app.id
            }
        }
    }
}
