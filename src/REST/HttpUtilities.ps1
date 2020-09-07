# Copyright 2020, Adam Edwards
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

ScriptClass HttpUtilities {
    static {
        function NormalizeHeaders($headers) {
            # See if this is a HashTable-like object by looking for a 'keys' member
            if ( $headers | gm keys -erroraction ignore ) {
                # It looks like a HashTable, so just return it as-is since HashTable
                # is the desired output format
                $headers
            } else {
                # For PowerShell 7, instead of representing headers using an object with
                # an interface similar to HashTable, sometimes a different type may be emitted,
                # Particularly for error responses. Convert this to an actual [HashTable]
                # to ensure a consistent interace in all cases.
                $headerTable = @{}
                $headers | foreach {
                    $headerTable.Add($_.key, $_.value)
                }
                $headerTable
            }
        }
    }
}
