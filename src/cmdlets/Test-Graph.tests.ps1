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

Describe "The Test-Graph command" {
    Context "when receiving a successful response from Graph" {
        BeforeEach {
            $endpointBehavior['ExpectedStatus'] = 477
        }

        $endpointBehavior = @{}

        Add-MockInScriptClassScope RESTRequest Invoke-WebRequest -MockContext $endpointBehavior {
            class AutoGraphHttpResponseException : Exception {
                $Response = [PSCustomObject] @{
                    Headers = $null
                    StatusCode = $MockContext.ExpectedStatus
                }
            }

            $headers = @{
                'x-ms-ags-diagnostic' = '{"ServerInfo":{"DataCenter":"West US 2","Slice":"E","Ring":"1","ScaleUnit":"001","RoleInstance":"MW2PEPF000031DA"}}'
                Date = '9/19/2021 5:53:33 AM +00:00'
                'request-id' = 'b2c212c9-bf31-49cb-af50-5cd93948c85f'
            }

            if ( $MockContext.ExpectedStatus -lt 200 -or $MockContext.ExpectedStatus -ge 400 ) {
                # Note -- the AutoGraph REST layer only fully handles certain exception types.
                # In addition to specific exception types, any exception type name with the
                # pattern AutoGraph*HttpResponseException will be handled
                $exceptionObject = [AutoGraphHttpResponseException]::new()
                $exceptionObject.Response.Headers = $headers

                throw $exceptionObject
            } else {
                New-ScriptObjectMock RESTResponse -PropertyValues @{
                    statusCode = 200
                    statusDescription = 'OK'
                    rawContent = ''
                    rawContentLength = 0
                    headers = $headers
                    content = [PSCustomObject] @{}
                }
            }
        }

        It "should succeed when given no parameters" {
            { Test-Graph | out-null } | Should Not Throw
        }

        It "should succeed when the service endpoint returns a 200 instead of a failure status" {
            $endpointBehavior.ExpectedStatus = 200
            { Test-Graph | out-null } | Should Not Throw
        }

        It "should succeed when given a cloud parameter" {
            { Test-Graph -cloud Public | out-null } | Should Not Throw
            { Test-Graph -cloud ChinaCloud | out-null } | Should Not Throw
            { Test-Graph -cloud USGovernmentCloud | out-null } | Should Not Throw
        }

        It "should succeed when given a custom graph URI parameter" {
            { Test-Graph -endpointuri 'https://graph.microsoft.com' | out-null } | Should Not Throw
        }

        It "should succeed when given a verbose parameter" {
            { Test-Graph -verbose *> $null } | Should Not Throw
        }

        It "should return a result with expected members" {
            $testResult = Test-Graph
            $testResult.NonfatalStatus | Should Be $endpointBehavior.ExpectedStatus
            $testResult.ServerTimestamp.ToString() | Should Be '9/19/2021 5:53:33 AM +00:00'
            ($testResult.ClientRequestTimestamp.GetType()) | Should BeExactly ([DateTimeOffset])
            ($testResult.ClientResponseTimestamp.GetType()) | Should BeExactly ([DateTimeOffset])
            $testResult.RequestId | Should Be 'b2c212c9-bf31-49cb-af50-5cd93948c85f'
            ($testResult.ClientElapsedTime.Gettype()) | Should BeExactly ([TimeSpan])
            ($testResult.Slice).gettype() | Should BeExactly ([string])
            ($testResult.Ring).gettype() | Should BeExactly ([string])
            ($testResult.ScaleUnit).gettype() | Should BeExactly ([string])
            $testResult.TestUri | Should Be 'https://graph.microsoft.com/v1.0/$metadata'
            ($testResult.DataCenter).gettype() | Should BeExactly ([string])
        }

        It "should return a result with expected members when the service endpoint returns a 200 instead of a failure status" {
            $endpointBehavior.ExpectedStatus = 200
            $testResult = Test-Graph
            $testResult.NonfatalStatus | Should Be $endpointBehavior.ExpectedStatus
            $testResult.ServerTimestamp.ToString() | Should Be '9/19/2021 5:53:33 AM +00:00'
            ($testResult.ClientRequestTimestamp.GetType()) | Should BeExactly ([DateTimeOffset])
            ($testResult.ClientResponseTimestamp.GetType()) | Should BeExactly ([DateTimeOffset])
            $testResult.RequestId | Should Be 'b2c212c9-bf31-49cb-af50-5cd93948c85f'
            ($testResult.ClientElapsedTime.Gettype()) | Should BeExactly ([TimeSpan])
            ($testResult.Slice).gettype() | Should BeExactly ([string])
            ($testResult.Ring).gettype() | Should BeExactly ([string])
            ($testResult.ScaleUnit).gettype() | Should BeExactly ([string])
            $testResult.TestUri | Should Be 'https://graph.microsoft.com/v1.0/$metadata'
            ($testResult.DataCenter).gettype() | Should BeExactly ([string])
        }
    }
}
