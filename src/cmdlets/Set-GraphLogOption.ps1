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
When a command such as Get-GraphResource or Invoke-GraphRequest issues a request to the Graph, the details of that request, including the
URI, http method, headers, along with details of the response are recorded as entries in a log. The Set-GraphLogOption command
configures the the log's settings such as the amount of detail logged for each request and the size of the log.

.PARAMETER LogLevel

The LogLevel parameter sets a value that controls which kinds of requests are logged and the level of detail logged for each entry.
It may take on the following values:

   * None: Specifies that no logging at all should occur.
   * Error: Specifies that requests should only be logged if the request is unsuccessful.
   * Basic: Logs all requests, but logged data does not include the request body or the response content.
   * FullRequest: Logs all requests and also log the request body, but does not log the response content.
   * FullResponse: Logs all requests, and inlcudes the response content, but does not log the request body.
   * Full: Logs all request, and includes both the request body and response content.

Note that previously logged entries that do not conform to the LogLevel parameter specified by this command prior to its invocation will
not be removed; the command only affects how new entries will be logged after it is executed.

For more details on how the log functions, see the Get-GraphLog command.

.PARAMETER MaximumSize

The MaximumSize parameter allows you to change the number of entries retained by the log. As new requests are made after the maximum size is reached, the oldest entries are removed so that the new entries can be added. To adjust the resources consumed by the log or to manage the risk of privacy issues, the size of the log may be configured by this parameter.

Note that if the size is decreased from OLDSIZE to NEWSIZE, the oldest OLDSIZE - NEWSIZE records will be lost. If the size is increased, existing records will be preserved.

.OUTPUTS
None.

.EXAMPLE
Set-GraphLogOption -LogLevel Error

This sets the log to only log errors.

.EXAMPLE
Set-GraphLogOption -LogLevel None

In this example logging is completely disabled by specifying the LogLevel parameter with a value of None; no logging will occur.
If logging is subsequently re-enabled by invoking Set-GraphLogOption with a different value for the LogLevel parameter,
logging will resume, but none of the requests logged while the setting was set to 'None' will be found in the log as the logger
ignores all updates while the LogLevel value of None is in effect. This capability can be useful of minimizing the risk
of privacy issues that could be caused by retaining personally identifiable information (PII) included in requests made
by this module.

.EXAMPLE
Set-GraphLogOption -LogLevel Full
Get-GraphResource organization -Select createdDateTime
Get-GraphLog | Select -Last 1 -ExpandProperty ReponseContent

{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#organization(createdDateTime)","value":[{"createdDateTime":"2018-98-04T19:03:11Z"}]}

This use of Set-GraphLogOption to 'Full' enables logging of the request body and response content. Subsequent requests will ahve
this information logged, and it can be retrieved from Get-GraphLog for use cases such as debugging or replaying requests.

.EXAMPLE
Set-GraphLogOption -MaximumSize 10

In this example, the maximum log size is set to 10 -- the latest 10 log entries are preserved, any others are no longer available.

.LINK
Get-GraphLog
Get-GraphLogOption
Clear-GraphLog
Get-GraphResource
Invoke-GraphRequest
#>
function Set-GraphLogOption {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [ValidateSet('None', 'Error', 'Basic', 'FullRequest', 'FullResponse', 'Full')]
        $LogLevel,

        $MaximumSize
    )
    $logger = $::.RequestLog |=> GetDefault

    if ( $MaximumSize -ne $null ) {
        $logger |=> SetSize $MaximumSize
    }

    if ( $logLevel ) {
        $logger.LogLevel = $LogLevel
    }
}
