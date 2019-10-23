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
returns information about the configfuration of the module's logging behavior including the level of logging and the maximum number
of entries to record in the log.

.OUTPUTS
Returns an object with the following properties:

* LogLevel: This is set to a string that represents the logging level. See the documentation for the
  Set-GraphLogOption command for valid values of this property
* MaximumSize: Gets the currently configured maximum number of log entries that will be stored in the log.

.EXAMPLE
PS> Get-GraphLogOption

LogLevel MaximumSize
-------- -----------
   Basic       32767

This example shows how the logging configuration as an object is displayed.

.LINK
Get-GraphLog
Set-GraphLogOption
Clear-GraphLog
Get-GraphItem
Invoke-GraphRequest
#>
function Get-GraphLogOption {
    [cmdletbinding()]
    param()
    $log = $::.RequestLog |=> GetDefault
    $logLevel = $log.LogLevel
    $maximumSize = $log.maxEntries
    [PSCustomObject] @{
        LogLevel = $logLevel
        MaximumSize = $maximumSize
    }
}
