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

. (import-script PreferenceHelper)

ScriptClass ColorString {
    $value = $null
    $colorMode = $null

    function __initialize([string] $initialValue, $colorMode) {
        $this.value = if ( $initialValue ) {
            $initialValue
        } else {
            ''
        }

        $targetColorMode = if ( $colorMode ) {
            if ( $colorMode -notin $this.scriptclass.ALLOWED_COLORMODES ) {
                throw ( "Unkown color mode '$colorMode' -- the value must be one of {0}" -f (
                            $this.scriptclass.ALLOWED_COLORMODES -join ',' ) )
            }
            $colorMode
        } else {
            $AutoGraphColorModePreference
        }

        $this.colorMode = $colorMode
    }

    function WriteColor([string] $value, $colorValue) {
    }

    function ToColorString {
    }

    static {
        const ALLOWED_COLOR_MODES 2bit, 4bit
        const ESCAPE_CHAR "$([char]0x1b)"
        const END_COLOR "$($ESCAPE_CHAR)[0m"

        $supportsColor = $host.ui.SupportsVirtualTerminal

        function ToColorString([string] $text, $foreColor, $backColor) {
            $colorMode = if ( $this.supportsColor ) {
                $colorVar = get-variable AutoGraphColorModePreference -value -erroraction ignore

                if ( $colorVar -eq '4bit' ) {
                    '4bit'
                }
            }

            if ( ! $colorMode -or $colorMode -eq '2bit' ) {
                $text
                return
            }

            $colorString = GetColorStringFromIndex $foreColor $backColor

            if ( $colorString ) {
                "$colorString$($text)$END_COLOR"
            } else {
                $text
            }
        }

        function GetColorStringFromIndex($foreColor, $backColor) {
            $hasColor = $false
            $hasBoth = $false

            $backValue = 0

            if ( $backColor -ne $null ) {
                $backOffset = RemapColorIndex $backColor
                if ( $backOffset -ne $null ) {
                    $hasColor = $true
                    $backValue = 40 + $backOffset
                }
            }

            $foreValue = 0

            if ( $foreColor -ne $null ) {
                $frontOffset = RemapColorIndex $foreColor
                if ( $frontOffset -ne $null ) {
                    $hasBoth = $hasColor
                    $hasColor = $true
                    $foreValue = 30 + $frontOffset
                }
            }

            if ( $hasColor ) {
                $colorString = "$ESCAPE_CHAR["

                if ( $foreColor -ne $null ) {
                    $colorString += "$foreValue"
                }

                if ( $hasBoth ) {
                    $colorString += ";"
                }

                if ( $backColor -ne $null ) {
                    $colorString += "$backValue"
                }

                "$($colorString)m"
            }
        }

        function RemapColorIndex([int32] $index) {
            if ( $index -lt 8 ) {
                $index
            } elseif ( $index -lt 16 ) {
                $index - 8 + 60
            }
        }

        function FormatColorString([string] $format, [HashTable] $colorMap) {
        }

        function __GetCompletedString([string] $possiblyIncompleteString) {
        }
    }
}
