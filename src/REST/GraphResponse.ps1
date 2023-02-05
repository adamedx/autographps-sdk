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

ScriptClass GraphResponse {
    $RestResponse = strict-val [PSCustomObject]
    $Entities = $null
    $ODataContext = strict-val [Uri]
    $NextLink = strict-val [Uri]
    $DeltaLink = strict-val [Uri]
    $Metadata = strict-val [HashTable] @{}
    $HasNonEmptyValueData = strict-val [bool]

    function __initialize ( $restResponse ) {
        $this.RestResponse = $restResponse

        $deserializedContent = $this.RestResponse |=> GetDeserializedContent
        $normalizedResponse = $this |=> __GetNormalizedResponse $deserializedContent

        $this.Metadata = $normalizedResponse.metadata
        $this.Entities = $normalizedResponse.entities
        $this.HasNonEmptyValueData = $normalizedResponse.hasNonEmptyValueData

        $this.ODataContext = $this.metadata['@odata.context']
        $this.NextLink = $this.metadata['@odata.nextLink']
        $this.DeltaLink = $this.metadata['@odata.deltaLink']
    }

    function Content {
        $this.restResponse.content
    }

    function __GetNormalizedResponse($deserializedContent) {
        $metadata = @{}
        $responseData = NormalizePSObject $deserializedContent

        $valueData = $null
        $hasNonEmptyValueData = $false

        $responseData.keys | foreach {
            if ( $_ -eq 'value' ) {
                $hasNonEmptyValueData = $hasNonEmptyValueData -or ( $valueData -ne $null )
                $valueData = $responseData[$_]
            } elseif ($_.startswith('@')) {
                try {
                    $metadata[$_] = $responseData[$_]
                } catch {
                }
            } else {
                $hasNonEmptyValueData = $true
            }
        }

        $entityData = if ( $valueData -ne $null -and $metadata.keys.count -gt 0 ) {
            $valueData
        } else {
            $responseData
        }

        $normalizedEntityData = if ( $entityData -isnot [Object[]] ) {
            @($entityData)
        } else {
            $entityData
        }

        @{
            entities=$entityData
            metadata=$metadata
            hasNonEmptyValueData = $hasNonEmptyValueData
        }
    }

    function NormalizePSObject([PSObject] $psobject) {
        $result = @{}

        if ( $psobject -ne $null ) {
            $psobject | gm -membertype properties | select -expandproperty name | foreach {
                $memberName = $_
                $memberValue = $psobject | select -expandproperty $memberName
                $normalizedValue = $memberValue
                $result[$memberName] = $normalizedValue
            }
        }
        $result
    }
}
