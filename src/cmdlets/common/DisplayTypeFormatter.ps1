# Copyright 2018, Adam Edwards
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

ScriptClass DisplayTypeFormatter {
    $displayTypeName = $null

    static {
        function __RegisterDisplayType($displayTypeName, $displayProperties) {
            remove-typedata -typename $displayTypeName -erroraction silentlycontinue

            $DisplayTypeArguments = @{
                TypeName    = $displayTypeName
                DefaultDisplayPropertySet = $displayProperties
            }

            Update-TypeData -force @DisplayTypeArguments
        }
    }

    function __initialize($displayTypeName, $displayProperties) {
        $this.displayTypeName = $displayTypeName
        $this.scriptclass |=> __RegisterDisplayType $displayTypeName $displayProperties
    }

    function ToDisplayableObject($object) {
        [PSCustomObject] (__ToHashtable $object)
    }

    function __ToHashtable($object) {
        $result = @{}
        $object | gm -membertype noteproperty | foreach {
            $value = $object | select -expandproperty $_.name
            $result.add($_.name, $value)
        }
        $result['PSTypeName'] = $this.displayTypeName
        $result
    }
}

