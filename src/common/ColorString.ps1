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
    static {
        const ALLOWED_COLOR_MODES 2bit, 4bit
        const ESCAPE_CHAR "$([char]0x1b)"
        const END_COLOR "$($ESCAPE_CHAR)[0m"

        $supportsColor = $host.ui.SupportsVirtualTerminal

        $standardColorings = @('Emphasis1', 'Emphasis2', 'Containment', 'EnabledState', 'Error1', 'Error2', 'Contrast')

        $standardMapping = @{
            '2Bit' = @{}
            '4bit' = @{
                Emphasis1 = 11
                Emphasis2 = 14
                Containment = 6
                Disabled = 8
                Enabled = 10
                Error1 = 1
                Error2 = 9
                Contrast = @(14, 12, 13)
            }
        }

        function ToStandardColorString([string] $text, [string] $coloring, [string[]] $highlightedValues, [string] $disabledValue) {

            if ( $this.standardColorings -notcontains $coloring ) {
                $text
                return
            }

            $colorMode = GetColorMode

            $colorMapping = $this.standardMapping[$colorMode]

            $standardColor = switch ( $coloring ) {
                'Emphasis1' {
                    $colorMapping['Emphasis1']
                }
                'Emphasis2' {
                    $colorMapping['Emphasis2']
                }
                'Containment' {
                    $colorMapping['Containment']
                }
                'EnabledState' {
                    if ( $text -eq $disabledValue ) {
                        $colorMapping['Disabled']
                    } elseif ( $text -in $highlightedValues ) {
                        $colorMapping['Enabled']
                    }
                }
                'Error1' {
                    $colorMapping['Error1']
                }
                'Error2' {
                    $colorMapping['Error2']
                }
                'Contrast' {
                    if ( $text -eq $disabledValue ) {
                        $colorMapping['Disabled']
                    } elseif ( $highlightedValues ) {
                        $valueIndex = $highlightedValues.IndexOf($text)
                        if ( $valueIndex -ge 0 ) {
                            $colorVector[$valueIndex % $colorVector.Length]
                        }
                    }
                }
            }

            if ( ! $standardColor ) {
                $text
                return
            }

            $foregroundColor = $null
            $backgroundColor = $null

            if ( $coloring -eq 'Containment' ) {
                $backgroundColor = $standardColor
            } else {
                $foregroundColor = $standardColor
            }

            ToColorString $text $foregroundColor $backgroundColor
        }

        function ToColorString([string] $text, $foreColor, $backColor) {
            $colorMode = GetColorMode

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

        function GetColorMode {
            if ( $this.supportsColor ) {
                $colorVar = get-variable AutoGraphColorModePreference -value -erroraction ignore

                if ( $colorVar -eq '4bit' ) {
                    '4bit'
                }
            } else {
                '2bit'
            }
        }
    }
}
