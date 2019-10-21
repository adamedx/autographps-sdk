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
Retrieves a log of the all of the REST requests to the Graph and associated responses issued by this module in the PowerShell session.

.DESCRIPTION
When a command such as Get-GraphItem or Invoke-GraphRequest issues a request to the Graph, the details of that request, including the
URI, http method, headers, along with details of the response are recorded as entries in a log. The Get-GraphLog command returns a collection
of log entries, where each request is a log entry. This command is useful for troubleshooting / diagnosis, analyzing performance, or
simply exploring and understanding the Graph protocol.

.OUTPUTS
A collection of log entries where each entry contains request and response details.

.EXAMPLE
Get-GraphLog

.LINK
Format-GraphLog
Set-GraphLog
Clear-GraphLog
Write-GraphLog
Get-GraphItem
Invoke-GraphRequest
#>
function Get-GraphLog {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='newest')]
    [OutputType('GraphLogEntryDisplayType')]
    param(
        [parameter(position=0, parametersetname='newest')]
        $Newest = 20,

        [parameter(parametersetname='oldest', mandatory=$true)]
        $Oldest,

        [parameter(parametersetname='oldest')]
        [parameter(parametersetname='newest')]
        $Skip = 0,

        [parameter(parametersetname='all', mandatory=$true)]
        [switch] $All
    )
    $fromOldest = $Oldest -ne $null

    $count = if ( $fromOldest ) {
        [int] $Oldest
    } else {
        $Newest
    }

    $results = ($::.RequestLog |=> GetDefault) |=> GetLogEntries $Skip $count $fromOldest $All.IsPresent

    # Results are sorted in reverse chronological order if enumerating from newest -- reverse this
    # so that we always return results in chronological order as part of a standard ux convention
    if ( $results ) {
        if ( ! $fromOldest -and ( $results -is [object[]] ) ) {
            $start = 0
            $end = $results.length - 1
            while ( $start -lt $end ) {
                $current = $results[$start]
                $results[$start++] = $results[$end]
                $results[$end--] = $current
            }
        }

        $results
    }
}
