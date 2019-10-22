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
Clears the log maintained by this module of requests to and responses from the Graph.

.DESCRIPTION
When a command such as Get-GraphItem or Invoke-GraphRequest issues a request to the Graph, the details of that request, including the
URI, http method, headers, along with details of the response are recorded as entries in a log. To clear this data from the log
so that it is no longer accessible from the Get-GraphLog command, invoke Clear-GraphLog.

.OUTPUTS
This command produces no output.

.EXAMPLE
Clear-GraphLog

This clears all entries from the log. A subsequent invocation of Get-GraphLog will then return nothing.

.LINK
Format-GraphLog
Set-GraphLog
Write-GraphLog
Get-GraphItem
Invoke-GraphRequest
#>
function Clear-GraphLog {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='newest')]
    param()
    $::.RequestLog |=> GetDefault |=> Clear
}
