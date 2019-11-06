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
    Error
    Basic
    FullRequest
    FullResponse
    Full
}

ScriptClass RequestLog {
    $maxEntries = 0
    $logPath = $null
    $logLevel = [RequestLogLevel]::Basic
    $requestIndex = $null
    $entries = @{}

    static {
        const MAX_ENTRIES_DEFAULT 131072
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
        $this |=> SetSize $this.scriptclass.MAX_ENTRIES_DEFAULT
    }

    function NewLogEntry(
        [PSTypeName('GraphConnection')] $connection,
        [PSTypeName('RESTRequest')] $request
    ) {
        if ( $this.LogLevel -eq 'None' ) {
            return
        }

        try {
            $newIndex = __GetNextLogIndex
            new-so RequestLogEntry $connection $request $this.loglevel
        } catch {
            $_ | write-debug
        }
    }

    function CommitLogEntry( [PSTypeName('RequestLogEntry')] $logEntry ) {
        if ( ! $logEntry -or ( $this.logLevel -eq 'Error' -and ! $logEntry.isError ) ) {
            return
        }

        $newIndex = __GetNextLogIndex
        $this.requestIndex = $newIndex
        $this.entries[$newIndex] = $logEntry
    }

    function GetLogEntries($start, $count, $startFromOldest, $allEntries, $errorFilter) {
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
            $currentEntry = $this.entries[$current]
            $emitEntry = $errorFilter -eq $null -or (
                ( $errorFilter -and $currentEntry.isError ) -or (
                    ! $errorFilter -and ! $currentEntry.isError )
            )

            if ( $emitEntry ) {
                $this.entries[$current]
            }

            $currentUnbounded = $current + $increment

            $current = if ( $currentUnbounded -lt 0 ) {
                $this.maxEntries - 1
            } elseif ( $currentUnbounded -ge $this.maxEntries ) {
                0
            } else {
                $currentUnbounded
            }
            $entryCount++
        }
    }

    function Clear {
        $this.requestIndex = -1
        $this.entries.clear()
    }

    function SetSize([uint32] $newSize) {
        $entriesToSave = [Math]::Min($this.entries.count, [int] $newSize)
        $entries = GetLogEntries 0 $this.entries.count $false $true
        $this.Clear()
        $this.maxEntries = [int] $newSize
        for ( $current = $entriesToSave - 1; $current -ge 0; $current-- ) {
             CommitLogEntry $entries[$current]
        }
    }

    function __GetNextLogIndex {
        ( $this.requestIndex + 1 ) % $this.maxEntries
    }

    function __GetOldestLogIndex {
        if ( $this.entries.count -eq 0 ) {
            -1
        } elseif ( $this.entries.count -eq $this.maxEntries ) {
            $this.requestCount % $this.maxEntries
        } else {
            0
        }
    }

    function __GetLatestLogIndex {
        $this.requestIndex
    }

    function __AdvanceIndex {
        $this.requestIndex = ($this.requestIndex + 1) % $this.maxEntries
    }
}
