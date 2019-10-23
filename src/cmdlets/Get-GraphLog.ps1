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

Entries are returned by this command in chronolgical order. The results of the command may be piped to other PowerShell commands such as
Sort-Object to provide other sort orders, filtering, projected properties, or formatting of the log entries.

The Clear-GraphLog command may be used to remove all entries from the log. The Set-GraphLogOption command may also be used
to disable logging altogether.

.PARAMETER Newest
The Newest parameter specifies the maximum number of log entries to return from the command, and that those entries must be
the newest such entries. This parameter may be specified as the first parameter without an explicit name, and its default
value is 20.

.PARAMETER Oldest
This parameter is similar to Newest, except that the oldest set of entries of the size specified by this parameter are returned.

.PARAMETER Skip
This specifies the number of entries to skip.

.PARAMETER All
To retrieve all of the entries in the log without needing to know how many entries exist, specify the parameter.

.OUTPUTS
A collection of log entries sorted chronologically where each entry contains request and response details.

.NOTES
The request log is currently implemented as a circular, in-memory log. The log is configured with a maximum log size that determines the
maximum number of log entries (one per request) stored in the log. This setting may be managed via the Get-GraphLogOption and
Set-GraphLogOption commands.

When the log has reached its maximum capacity, the next request that is logged will overwrite the earliest request in the log.

.EXAMPLE
Get-GraphLog

RequestTimestamp              StatusCode Method Uri
----------------              ---------- ------ ---
10/21/2019 9:50:11 PM -07:00         200 GET    https://graph.microsoft.com/ping
10/21/2019 9:51:33 PM -07:00         200 GET    https://graph.microsoft.com/v1.0/me
10/21/2019 9:54:18 PM -07:00         201 POST   https://graph.microsoft.com/beta/applications
10/21/2019 9:54:25 PM -07:00         204 PATCH  https://graph.microsoft.com/beta/applications/4b44df3-8248-4cc9-bfc6-2b9...
10/21/2019 9:54:29 PM -07:00         200 GET    https://graph.microsoft.com/beta/servicePrincipals?$select=id&$filter=app...
10/21/2019 10:14:31 PM -07:00        404 GET    https://graph.microsoft.com/v1.0/me/messages
10/21/2019 10:14:54 PM -07:00        200 GET    https://graph.microsoft.com/v1.0/users

This shows a sequence of the 20 most recent calls issued from AutoGraphPS. To see more than just the 20 most recent, use
the Oldest, Newest, or All options.

.EXAMPLE
Get-GraphLog -Newest 3

RequestTimestamp              StatusCode Method Uri
----------------              ---------- ------ ---
10/21/2019 10:14:11 PM -07:00        200 GET    https://graph.microsoft.com/ping
10/21/2019 10:14:31 PM -07:00        404 GET    https://graph.microsoft.com/v1.0/me/messages
10/21/2019 10:14:54 PM -07:00        200 GET    https://graph.microsoft.com/v1.0/users

This shows the newest 3 messages in the log.

.EXAMPLE
Get-GraphLog -Oldest 3 | Select  StatusCode, Method, ResourceUri

StatusCode Method ResourceUri
---------- ------ -----------
       200 GET    ping
       404 GET    me/messages
       200 GET    users

This shows the oldest 3 entries, and pipes the output to select to project specific fields

.LINK
Format-GraphLog
Set-GraphLogOption
Get-GraphLogOption
Clear-GraphLog
Get-GraphItem
Invoke-GraphRequest
Test-Graph
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

        $results | foreach {
            $_ |=> ToDisplayableObject
        }
    }
}
