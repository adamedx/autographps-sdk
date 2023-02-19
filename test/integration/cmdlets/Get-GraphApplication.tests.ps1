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

Describe "The Get-GraphApplication command executing unmocked" {

    Set-StrictMode -Version 2

    function RemoveTestApp {
        param(
            [parameter(mandatory=$true)]
            $AppObjectId
        )
        Invoke-GraphApiRequest -Method DELETE -Uri /applications/$AppObjectId | out-null
    }

    Context "When getting applications" {
        BeforeAll {
            Connect-GraphApi -Connection $global:__IntegrationTestGraphConnection | out-null
            $thisTestInstanceId = New-Guid | select -expandproperty guid

            $appTags = $global:__IntegrationTestInfo.TestRunId, $thisTestInstanceId, '__IntegrationTest__'

            $testAppName = 'SimpleTestAppRead' + $thisTestInstanceId
            $testApp = New-GraphApplication -Name $testAppName -Tags $appTags
        }

        It "should successfully read the application with expected properties when the appid parameter is used" {
            $app = Get-GraphApplication $testApp.AppId
            $app.AppId | Should Be $testApp.AppId
            $app.Id | Should Be $testApp.Id
            $app.DisplayName | Should Be $testAppName
        }

        It "should successfully read the application with expected properties when the objectid parameter is used" {
            $app = Get-GraphApplication $testApp.AppId
            $app.AppId | Should Be $testApp.AppId
            $app.Id | Should Be $testApp.Id
            $app.DisplayName | Should Be $testAppName
        }

        It "should throw an exception if a nonexistent objectid parameter is specified" {
            { Get-GraphApplication -ObjectId (new-guid).guid -erroraction stop | out-null } | Should Throw
        }

        It "should throw an exception if a nonexistent appid parameter is specified" {
            { Get-GraphApplication (new-guid).guid -erroraction stop } | Should Throw
        }

        AfterAll {
            foreach ( $app in ( Get-GraphApplication -Tags $thisTestInstanceId ) ) {
                RemoveTestApp $app.id
            }
        }
    }
}
