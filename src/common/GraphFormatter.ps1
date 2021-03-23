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

. (import-script ColorString)

ScriptClass GraphFormatter {
    static {
        function StatusCode($statusValue) {
            $foreGround = $null
            $background = $null

            $status = try {
                [int] $statusValue
            } catch {
                break
            }

            if ($status -ne $null ) {
                if ( $status -ge 200 -and $status -lt 300 ) {
                    $foreGround = 10
                } elseif ($status -eq 401 -or $status -eq 403 ) {
                    $foreground = 1
                } elseif( $status -ge 300 -and $status -lt 500 ) {
                    $foreGround = 9
                } else {
                    $foreGround = 0
                    $backGround = 9
                }
            }

            $::.ColorString.ToColorString($statusValue, $foreGround, $backGround)
        }

        function RestMethod($method) {
            $foreGround = $null
            $background = $null

            switch ( $method ) {
                'POST' { $foreGround = 13 }
                'PUT' { $foreGround = 5 }
                'GET' { $foreGround = 12 }
                'DELETE' { $foreGround = 11 }
                'PATCH' { $foreGround = 3 }
                default {}
            }

            $::.ColorString.ToColorString($method, $foreGround, $backGround)
        }

        function ResponseElapsedTime([TimeSpan] $elapsed) {
            $forecolor = if ( $elapsed.TotalSeconds -lt 1 ) {
                10
            } elseif ( $elapsed.TotalSeconds -lt 2 ) {
                11
            } else {
                9
            }

            $::.ColorString.ToColorString($elapsed.ToString(), $foreColor, $null)
        }
    }
}
