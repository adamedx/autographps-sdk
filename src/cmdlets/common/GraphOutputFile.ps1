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

ScriptClass GraphOutputFile {
    $baseName = $null
    $fileContent = $null
    $contentTypeData = $null

    function __initialize($baseName, $fileContent, $contentTypeData) {
        if ( ! $baseName ) {
            throw "A base file name must be specified."
        }

        $this.baseName = $baseName
        $this.fileContent = $fileContent
        $this.contentTypeData = $contentTypeData
    }

    function Save {
        $typeData = __GetTypeData

        $destinationPath = "$($this.baseName).$($typeData.Extension)"

        write-verbose "Saving result to file path = '$destinationPath'; isBinary=$($typeData.IsBinary); extension = '$($typeData.extension)'; encoding = '$($typeData.encoding)'"

        if ( $typeData.IsBinary ) {
            __SaveBinary $destinationPath
        } else {
            __SaveText $destinationPath $typeData.encoding
        }

        get-item $destinationPath
    }

    function __GetTypeData {
        $isBinary = $false
        $extension = '.dat'
        $encoding = 'Default'

        if ( $this.contentTypeData['application/json'] ) {
            $isBinary = $false
            $extension = 'json'
            $charset = $this.contentTypeData['charset']
            if ( $charset -eq 'utf-8') {
                $encoding = 'UTF8'
            } else {
                $encodig = 'Default'
            }
        } elseif ( $this.contentTypeData['image/jpeg'] ) {
            $isBinary = $true
            $extension = 'jpg'
            $encoding = 'Byte'
        }

        $result = @{Extension = $extension;IsBinary = $isBinary; Encoding = $encoding}

        [PSCustomObject] $result
    }

    function __SaveBinary($path) {
        $encodingArgument = if ( $PSVersionTable.PSEdition -eq 'Desktop' ) {
            @{Encoding='Byte'}
        } else {
            @{AsByteStream=(. {param([switch] $switchVal) $switchValval} -switchVal)}
        }

        set-content -path $path -value $this.fileContent @encodingArgument
    }

    function __SaveText($path, $encoding) {
        set-content -path $path -value $this.fileContent -Encoding $encoding
    }
}
