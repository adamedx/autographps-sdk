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

ScriptClass ColorScheme {
    $colorMaps = $null

    function __initialize([PSCustomObject[]] $colorMaps) {
        $this.colorMaps = @{
            '2bit' = @{}
            '4bit' = @{}
        }

        foreach ( $colorMap in $colorMaps ) {
            $colors = if ( $colorMap | gm Colors -erroraction ignore ) {
                $colorMap.Colors
            } else {
                continue
            }

            $colorMode = if ( $colorMap | gm colorMode -erroraction ignore ) {
                $colorMap.colorMode
            } else {
                '4bit'
            }

            if ( $this.colorMaps.ContainsKey($colorMode) -and $this.colorMaps[$colorMode].Count -eq 0 ) {
                foreach ( $colorName in $this.scriptclass.colorNames.keys ) {
                    if ( $colors | gm $colorName -erroraction ignore ) {
                        if ( ! $this.colorMaps[$colorMode][$colorName] ) {
                            $this.colorMaps[$colorMode].Add($colorName, $colors.$colorName)
                        }
                    }
                }
            }
        }
    }

    function GetColorMap([string] $colorMode) {
        if ( $colorMode -notin $this.colorMaps.keys ) {
            throw "The specified color mode '$colorMode' is not a valid color mode."
        }

        $this.colorMaps[$colorMode]
    }

    static {
        $colorNames = @{}

        function RegisterColorNames([string[]] $colorNames, [string] $source) {
            if ( ! $source ) {
                throw "A source for the color names must be specified"
            }

            foreach ( $colorName in $colorNames ) {
                if ( ! $this.colorNames[$colorName] ) {
                    $this.colorNames.Add($colorName, $source)
                }
            }
        }
    }
}

