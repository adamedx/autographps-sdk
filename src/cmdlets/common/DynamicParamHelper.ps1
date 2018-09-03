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

function GetOptionalValidateSetParameter {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, mandatory=$true)]
        $ParameterName,

        [parameter(position=1, mandatory=$true)]
        $ValidateSet,

        $ParameterType = ([object]),

        [HashTable[]] $ParameterSets = @(),

        [Switch] $SkipValidation
    )

    $validAttributeArguments = @{parametersetname=[string];mandatory=[bool]; position=[int]}
    $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()

    $ParameterSets | foreach {
        $attributeArguments = $_
        if ( $attributeArguments ) {
            $attributeArguments.keys | foreach {
                if ( $_ -notin $validAttributeArguments.keys ) {
                    throw ("Attribute argument '{0}' was not in valid attribute argument set '{1}'" -f $_, $validAttributeArguments.keys)
                }

                if ( $attributeArguments[$_] -isnot $validAttributeArguments[$_] ) {
                    throw ("Attribute argument '{0}' was not of expected type '{1}'" -f $_, $validAttributeArguments[$_])
                }
            }
        }
        $parameterAttribute = [System.Management.Automation.ParameterAttribute]::new()

        $parameterSetName = $attributeArguments['parameterSetName']
            if ( $parameterSetName ) {
                $parameterAttribute.ParameterSetName = $parameterSetName
            }

        $position = $attributeArguments['position']
        if ( $position -ne $null ) {
            $parameterAttribute.position = $position
        }

        $parameterAttribute.Mandatory = $attributeArguments['mandatory'] -eq $true
        $attributeCollection.Add($parameterAttribute)
    }

    if ( ! $SkipValidation.IsPresent ) {
        $validateSetArgument = [System.Collections.ObjectModel.Collection[object]]::new()
        $ValidateSet | foreach {
            $validateSetArgument.Add($_)
        }
        $validateSetAttribute = [System.Management.Automation.ValidateSetAttribute]::new($validateSetArgument)
        $attributeCollection.Add($validateSetAttribute)
    }

    $runtimeParameter = [System.Management.Automation.RuntimeDefinedParameter]::new($parameterName, $parameterType, $AttributeCollection)
    $runtimeParameterList = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
    $runtimeParameterList.Add($parameterName, $runtimeParameter)
    $runtimeParameterList
}
