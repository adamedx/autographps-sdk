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

. (import-script ../REST/RequestLog)

<#
.SYNOPSIS
Sets options related to logging of the requests made by this module.

.DESCRIPTION
When a command such as Get-GraphItem or Invoke-GraphRequest issues a request to the Graph, the details of that request, including the
URI, http method, headers, along with details of the response are recorded as entries in a log. The Get-GraphLogOption command
returns information about the configfuration of the module's logging behavior.

* None: Specifies that no logging at all should occur.
* Error: Specifies that requests should only be logged if the request is unsuccessful.
* Basic: Logs all requests, but logged data does not include the request body.
* Full: Logs all requests and inlcudes the request body.

.OUTPUTS
Returns an object with the following properties:

* LogLevel: This is set to a string that represents the logging level. See the documentation for the
  Set-GraphLogOption command for valid values of this property

.EXAMPLE
PS> Get-GraphLogOption

Full

.LINK
Format-GraphLog
Set-GraphLogOption
Clear-GraphLog
Write-GraphLog
Get-GraphItem
Invoke-GraphRequest
#>
function Get-GraphLogOption {
    [cmdletbinding()]
    param()
    $logLevel = ( $::.RequestLog |=> GetDefault ).LogLevel
    [PSCustomObject] @{
        LogLevel = $logLevel
    }
}
