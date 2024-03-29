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

if ( ! ( & $psscriptroot/../../IsIntegrationTestRun.ps1 ) ) {
    return
}

Describe "The Get-GraphResource command executing unmocked" {

    Set-StrictMode -Version 2
    $erroractionpreference = 'stop'

    Context "when invoked for simple use cases" {
        BeforeAll {
            $currentConnection = Connect-GraphApi -Connection $global:__IntegrationTestGraphConnection
            $organizationId = $currentConnection.identity.tenantdisplayid
            $thisApplicationId = $currentconnection.identity.app.appid
        }

        It "should succeed when issuing a request for the organization object" {
            $actualOrganization = Get-GraphResource /organization
            $actualOrganization.Id | Should Be $organizationId
            $actualOrganization.displayName.Length | Should BeGreaterThan 0
        }

        It "should successfully apply a filter and return the result" {
            $currentApp = Get-GraphResource /applications -Filter "appId eq '$thisApplicationId'"
            $currentApp.AppId | Should Be $thisApplicationId
        }

        It "should return a result collection of empty size as null" {
            $currentApp = Get-GraphResource /applications -Filter "appId eq '$thisApplicationId'"
            Get-GraphResource /applications/$($currentapp.Id)/federatedIdentityCredentials | Should Be $null
        }
    }
}
