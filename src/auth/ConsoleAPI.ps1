# Copyright 2024, Adam Edwards
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

ScriptClass ConsoleAPI {
    static {
        $initialized = $false

        function GetConsoleWindow {
            $currentOSPlatform = [System.Environment]::OSVersion.Platform

            if ( $currentOSPlatform -ne 'Win32NT' ) {
                throw [NotSupportedException]::new("Attempt to invoke a Windows API function on the non-Windows platform '$currentOSPlatform' which does not support the function.")
            }

            if ( ! $this.initialized ) {
                . $psscriptroot/CompiledConsoleAPI.ps1
                $this.initialized = $true
            }

            [Console.Window+CompiledConsoleAPI]::GetConsoleWindowFunc()
        }
    }
}
