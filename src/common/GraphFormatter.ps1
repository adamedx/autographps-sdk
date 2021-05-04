# Copyright 2021, Adam Edwards
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

. (import-script ColorScheme)
. (import-script ColorString)

ScriptClass GraphFormatter {
    static {
        function __initialize {
            $::.ColorScheme.RegisterColorNames(
                @(
                    'Success'
                    'Warning'
                    'Error1'
                    'Error2'
                    'REST-Method-POST'
                    'REST-Method-PUT'
                    'REST-Method-GET'
                    'REST-Method-DELETE'
                    'REST-Method-PATCH'
                    'Time-Elapsed-Normal'
                    'Time-Elapsed-Slow'
                    'Time-Elapsed-ExtraSlow'
                ),
                'autographps-sdk'
            )

            $colorInfo = [PSCustomObject] @{
                colorMode = '4bit'
                colors = [PSCustomObject] @{
                    'Success' = 10
                    'Warning' = 11
                    'Error1' = 1
                    'Error2' = 9
                    'REST-Method-POST' = 13
                    'REST-Method-PUT' = 5
                    'REST-Method-GET' = 12
                    'REST-Method-DELETE' = 11
                    'REST-Method-PATCH' = 3
                    'Time-Elapsed-Normal' = 10
                    'Time-Elapsed-Slow' = 11
                    'Time-Elapsed-ExtraSlow' = 9
                }
            }

            $::.ColorString.UpdateColorScheme(@($colorInfo))
        }

        function StatusCode($statusValue) {
            $foreGround = $null
            $background = $null

            $status = try {
                [int] $statusValue
            } catch {
                break
            }

            $coloring = if ( $status -ne $null ) {
                if ( $status -ge 200 -and $status -lt 300 ) {
                    'Success'
                } elseif ($status -eq 401 -or $status -eq 403 ) {
                    'Error3'
                } elseif( $status -ge 300 -and $status -lt 500 ) {
                    'Error2'
                } else {
                    'Error1'
                }
            }

            $colors = $::.ColorString.GetStandardColors($coloring, $null, $null, $null)

            $::.ColorString.ToColorString($statusValue, $colors[0], $colors[1])
        }

        function RestMethod($method) {
            $foreGround = $null
            $background = $null

            $colorName = switch ( $method ) {
                'POST' { 'REST-Method-POST' }
                'PUT' { 'REST-Method-PUT' }
                'GET' { 'REST-Method-GET' }
                'DELETE' { 'REST-Method-DELETE' }
                'PATCH' { 'REST-Method-PATCH' }
                default {}
            }

            $::.ColorString.ToStandardColorString($method, 'Scheme', $colorName, $null, $null)
        }

        function ResponseElapsedTime([TimeSpan] $elapsed) {
            $colorName = if ( $elapsed.TotalSeconds -lt 1 ) {
                'Time-Elapsed-Normal'
            } elseif ( $elapsed.TotalSeconds -lt 2 ) {
                'Time-Elapsed-Slow'
            } else {
                'Time-Elapsed-ExtraSlow'
            }
            $::.ColorString.ToStandardColorString($elapsed.ToString(), 'Scheme', $colorName, $null, $null)
        }
    }
}

$::.GraphFormatter |=> __initialize

