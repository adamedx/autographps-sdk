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

ScriptClass DisplayTypeFormatter {
    $displayTypeName = $null

    static {
        function RegisterDisplayType($displayTypeName, $displayProperties, [boolean] $registerAsMembers) {
            remove-typedata -typename $displayTypeName -erroraction ignore

            $DisplayTypeArguments = @{
                TypeName    = $displayTypeName
                DefaultDisplayPropertySet = $displayProperties
            }

            Update-TypeData -force @DisplayTypeArguments

            if ( $registerAsMembers ) {
                $displayProperties | foreach {
                    $memberArgs = @{
                        TypeName = $displayTypeName
                        MemberType = 'NoteProperty'
                        MemberName = $_
                        Value = $null
                    }

                    Update-typedata @memberArgs -force
                }
            }
        }

        function UtcTimeStringToDateTimeOffset($utcTimeString, $fallback = $false) {
            try {
                [DateTimeOffset]::Parse($utcTimeString)
            } catch {
                if ( ! $fallback ) {
                    throw
                }
                $utcTimeString
            }
        }
    }

    function __initialize($displayTypeName, $displayProperties) {
        $this.displayTypeName = $displayTypeName
        $this.scriptclass |=> RegisterDisplayType $displayTypeName $displayProperties
    }

    function DeserializedGraphObjectToDisplayableObject($object) {
        # This method creates shallow object copies -- it assumes that these objects
        # were originally deserialized from the Graph service by this module, and
        # thus that the object's members include only noteproperty and scriptmethod
        # members. Only these member types will be copied.

        # Copy the noteproperty members by transforming to a hash table
        # and then typecasting
        $resultObject = [PSCustomObject] (__ToHashtable $object)

        # Now copy over all the scriptmethods -- this module adds some
        # script methods to objects deserialized from Graph, and those
        # must be preserved in order to retain module functionality that
        # relies on them (e.g. '__ItemContext' method)
        $object | gm -membertype ScriptMethod | foreach {
            $method = $object.psobject.methods | where name -eq $_.name | select -ExpandProperty value
            if ( $method ) {
                $resultObject | add-member -name $method.name -membertype ScriptMethod -value $method.script
            }
        }

        $resultObject
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

