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

. (import-script ../REST/RequestLog)

<#
.SYNOPSIS
Formats the output of the Get-GraphLog command for readability and focus.

.DESCRIPTION
When a command such as Get-GraphItem or Invoke-GraphRequest issues a request to the Graph, the details of that request, including the
URI, http method, headers, along with details of the response are recorded as entries in a log. The Format-GraphLog command displays
output returned by Get-GraphLog with additional columns optimized for relevance and readability by default. It also performs
some formatting on fields that are difficult to read in a tabular format in their native representation.

.OUTPUTS
This command emits output using the Format-Table command -- see the Format-Table command's 'OUTPUTS' section which also describes
the output of Format-GraphLog.

.EXAMPLE
Get-GraphLog | Format-GraphLog

.LINK
Format-GraphLog
Set-GraphLog
Clear-GraphLog
Write-GraphLog
Get-GraphItem
Invoke-GraphRequest
Format-Table
#>
function Format-GraphLog {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(valuefrompipeline=$true, mandatory=$true)]
        [object] $InputObject,

        [parameter(position=0)]
        [ArgumentCompleter({
                               param ( $commandName,
                                       $parameterName,
                                       $wordToComplete,
                                       $commandAst,
                                       $fakeBoundParameters )
                               $possiblePropertyValues = ($::.RequestLogEntry |=> GetExtendedPropertySet)
                               $lowerWordToComplete = $wordToComplete.tolower()
                               $possiblePropertyValues | where {
                                   $_.tolower().StartsWith($lowerWordToComplete)
                               }
                           })]
        [string[]] $Property,

        [switch] $DisplayError,

        [switch] $Expand,

        [switch] $Force,

        [object] $GroupBy,

        [switch] $ShowError,

        [string] $View,

        [string] $Wrap,

        [switch] $HideTableHeaders,

        [switch] $AutoSize
    )
    begin {
        $simpleErrorMessageField = 'ErrorMessage'

        $targetProperties = if ( $Property ) {
            $property
        } else {
            @(
                'RequestTimestamp'
                'StatusCode'
                'Method'
                'Version'
                'ResourceUri'
                $simpleErrorMessageField
            )
        }

        $errorSimpleIncluded = $targetProperties -contains $simpleErrorMessageField

        $formatParameters = @{}

        $PSBoundParameters.keys | foreach {
            $formatParameters[$_] = $PSBoundParameters[$_]
        }

        $formatParameters['Property'] = $targetProperties

        $augmentedInput = @()
    }

    process {
        $propertyMap = @{}

        $targetProperties | foreach {
            if ( $_ -ne $simpleErrorMessageField ) {
                $propertyMap[$_] = $InputObject | select -expandproperty $_
            }
        }

        $errorMessage = if ( $InputObject | gm $::.RequestLogEntry.ERROR_RESPONSE_FIELD -erroraction ignore ) {
            $InputObject.$($::.RequestLogEntry.ERROR_RESPONSE_FIELD)
        }

        if ( $errorSimpleIncluded -and $errorMessage ) {
            $errorAsObject = $errorMessage | convertfrom-json -erroraction ignore

            $simpleErrorMessage = if ( $errorAsObject ) {
                $errorMember = if ( $errorAsObject | gm error -erroraction ignore ) {
                    $errorAsObject.error
                }

                if ( $errorMember -and ( $errorMember | gm message -erroraction ignore ) ) {
                    $errorMember.message
                }
            }

            $propertyMap[$simpleErrorMessageField] = if ( $simpleErrorMessage ) {
                $simpleErrorMessage
            } else {
                $errorMessage
            }
        }

        $augmentedInput += [PSCustomObject] $propertyMap
    }

    end {
        $augmentedInput | format-table @formatParameters
    }
}
