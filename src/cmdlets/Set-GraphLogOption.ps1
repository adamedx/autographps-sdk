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
URI, http method, headers, along with details of the response are recorded as entries in a log. The Set-GraphLogOption command
configures the amount of detail recorded in the log according to the following levels:

* None: Specifies that no logging at all should occur.
* Error: Specifies that requests should only be logged if the request is unsuccessful.
* Basic: Logs all requests, but logged data does not include the request body.
* Full: Logs all requests and inlcudes the request body.

.OUTPUTS
None.

.EXAMPLE
Set-GraphLogOption Error

.LINK
Format-GraphLog
Get-GraphLogOption
Clear-GraphLog
Write-GraphLog
Get-GraphItem
Invoke-GraphRequest
#>
function Set-GraphLogOption {
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true)]
        [ValidateSet('None', 'Error', 'Basic', 'Full')]
        $LogLevel
    )
    ( $::.RequestLog |=> GetDefault ).LogLevel = $LogLevel
}
