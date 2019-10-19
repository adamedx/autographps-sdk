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

. (import-script ../client/GraphConnection)
. (import-script RESTRequest)
. (import-script RESTResponse)
. (import-script RequestLogEntry)

enum RequestLogLevel {
    None
    Basic
    Full
}

ScriptClass RequestLog {
    const MAX_ENTRIES 131072
    $logPath = $null
    $logLevel = [RequestLogLevel]::Basic
    $requestIndex = -1
    $entries = @{}

    static {
        $defaultLogger = $null
        function GetDefault {
            if ( ! $this.defaultLogger ) {
                $this.defaultLogger = new-so RequestLog
            }

            $this.defaultLogger
        }

        function SetDefault([RequestLogLevel] $logLevel = [RequestLogLevel]::Basic, [string] $logPath) {
            $this.defaultLogger = new-so RequestLog $logLevel $logPath
        }
    }

    function __initialize([RequestLogLevel] $logLevel = [RequestLogLevel]::Basic, [string] $logPath) {
        $this.logPath = $logPath
        $this.logLevel = $logLevel
    }

    function NewLogEntry(
        [PSTypeName('GraphConnection')] $connection,
        [PSTypeName('RESTRequest')] $request
    ) {
        try {
            $newIndex = __GetNextLogIndex
            $newEntry = new-so RequestLogEntry $newIndex $connection $request $this.loglevel
            $this.requestIndex = $newIndex
            $this.entries[$newIndex] = $newEntry
            $newEntry
        } catch {
            $_ | write-debug
        }
    }

    function GetLogEntries($start, $count, $startFromOldest, $allEntries) {
        $startIndex = 0;
        $endIndex = 0;

        $increment = if ( $startFromOldest ) {
            $startIndex = __GetOldestLogIndex
            1
        } else {
            $startIndex = __GetLatestLogIndex
            -1
        }

        $entryCount = 0

        $current = $startIndex

        $targetCount = if ( $allEntries ) {
            $this.entries.count
        } else {
            $count
        }

        while ( $entryCount -lt $targetCount -and $entryCount -lt $this.entries.count ) {
            $this.entries[$current] |=> ToDisplayableObject

            $currentUnbounded = $current + $increment

            $current = if ( $currentUnbounded -lt 0 ) {
                $this.MAX_ENTRIES - 1
            } elseif ( $currentUnbounded -ge $this.MAX_ENTRIES ) {
                0
            } else {
                $currentUnbounded
            }
            $entryCount++
        }
    }

    function WriteLogEntry([PSTypeName('RESTResponse')] $response) {
    }

    function __GetNextLogIndex {
        ( $this.requestIndex + 1 ) % $this.MAX_ENTRIES
    }

    function __GetOldestLogIndex {
        if ( $this.entries.count -eq 0 ) {
            -1
        } elseif ( $this.entries.count -eq $this.MAX_ENTRIES ) {
            $this.requestCount % $this.MAX_ENTRIES
        } else {
            0
        }
    }

    function __GetLatestLogIndex {
        $this.requestIndex
    }

    function __AdvanceIndex {
        $this.requestIndex = ($this.requestIndex + 1) % $this.MAX_ENTRIES
    }
}
