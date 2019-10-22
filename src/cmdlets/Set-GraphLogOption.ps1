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
* Basic: Logs all requests, but logged data does not include the request body or the response content.
* FullRequest: Logs all requests and also log the request body, but does not log the response content.
* FullResponse: Logs all requests, and inlcudes the response content, but does not log the request body.
* Full: Logs all request, and includes both the request body and response content.

Note that previously logged entries that do not conform to the setting specified by this command prior to its invocation will
not be removved; the command only affects how new entries will be logged after it is executed.

.OUTPUTS
None.

.EXAMPLE
Set-GraphLogOption Error

This sets the log to only log errors.

.EXAMPLE
Set-GraphLogOption Full
Get-GraphItem organization -Select createdDateTime
Get-GraphLog | Select -Last 1 -ExpandProperty ReponseContent

{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#organization(createdDateTime)","value":[{"createdDateTime":"2018-98-04T19:03:11Z"}]}

This use of Set-GraphLogOption to 'Full' enables logging of the request body and response content. Subsequent requests will ahve
this information logged, and it can be retrieved from Get-GraphLog for use cases such as debugging or replaying requests.

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
        [ValidateSet('None', 'Error', 'Basic', 'FullRequest', 'FullResponse', 'Full')]
        $LogLevel
    )
    ( $::.RequestLog |=> GetDefault ).LogLevel = $LogLevel
}
