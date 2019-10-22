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

$Views = @{
    Status = @(
        'RequestTimestamp'
        'StatusCode'
        'Method'
        'Version'
        'ResourceUri'
        $::.RequestLogEntry.ERROR_MESSAGE_EXTENDED_FIELD
    )
    Timing = @(
        'RequestTimestamp'
        'ClientElapsedTime'
        'StatusCode'
        'Method'
        'ResourceUri'
        'ResponseTimestamp'
    )
    Authentication = @(
        'RequestTimestamp'
        'AppId'
        'UserUpn'
        'UserObjectId'
        'StatusCode'
        'Method'
        'ResourceUri'
        'Scopes'
    )
    Debug = @(
        'RequestTimestamp'
        'ClientRequestId'
        'StatusCode'
        'Method'
        'Version'
        'ResourceUri'
        'Query'
        'HasRequestBody'
        $::.RequestLogEntry.ERROR_MESSAGE_EXTENDED_FIELD
    )
}

<#
.SYNOPSIS
Formats the output of the Get-GraphLog command for readability and focus.

.DESCRIPTION
When a command such as Get-GraphItem or Invoke-GraphRequest issues a request to the Graph, the details of that request, including the
URI, http method, headers, along with details of the response are recorded as entries in a log. The Format-GraphLog command displays
output returned by Get-GraphLog with additional columns optimized for relevance and readability by default. It also performs
some formatting on fields that are difficult to read in a tabular format in their native representation.

.PARAMETER InputObject
The object to be displayed by the command

.PARAMETER Property
A list of properties of the InputObject to display as columns of the table

.PARMETER  DisplayError
This parameter follows the behavior of the same parameter of Format-Table.

.PARAMETER Expand
This parameter follows the behavior of the same parameter of Format-Table.

.PARAMETER Force
This parameter follows the behavior of the same parameter of Format-Table.

.PARAMETER GroupBy
This parameter follows the behavior of the same parameter of Format-Table.

.PARAMETER ShowError
This parameter follows the behavior of the same parameter of Format-Table.

.PARAMETER View
The View parameter determines a predefined set of columns optimized for particular scenarios:
* Status: This is a more compact view that focuses on essential status. If neither the View parameter nor the Property parameter
  are specified, the resulting view is the same as explicitly specifying this 'Status' value for View
* Debug: This set of columns is optimized for debugging and includes the client request id
* Timing: This set of columns is optimized for analyzing timing characteristics of the requests and responses
* Authentication: Provides details of the application, user identity, and permissions used to make the request

.PARAMETER Wrap
This parameter follows the behavior of the same parameter of Format-Table.

.PARAMETER HideTableHeaders
This parameter follows the behavior of the same parameter of Format-Table.

.PARAMETER AutoSize
This parameter follows the behavior of the same parameter of Format-Table.

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
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='specificcolumns')]
    param(
        [parameter(valuefrompipeline=$true, mandatory=$true)]
        [object] $InputObject,

        [parameter(position=0, parametersetname='specificcolumns')]
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

        [parameter(parametersetname='fixedcolumns', mandatory=$true)]
        [ValidateSet('Status', 'Timing', 'Authentication', 'Debug')]
        $View,

        [switch] $DisplayError,

        [switch] $Expand,

        [switch] $Force,

        [object] $GroupBy,

        [switch] $ShowError,

        [string] $Wrap,

        [switch] $HideTableHeaders,

        [switch] $AutoSize
    )
    begin {
        $targetProperties = if ( $View ) {
            $Views[$View]
        } elseif ( $Property ) {
            $property
        } else {
            $Views['Status']
        }

        $errorSimpleIncluded = $targetProperties -contains $::.RequestLogEntry.ERROR_MESSAGE_EXTENDED_FIELD

        $formatParameters = @{}

        $PSBoundParameters.keys | where { @('View') -notcontains $_ } | foreach {
            $formatParameters[$_] = $PSBoundParameters[$_]
        }

        $formatParameters['Property'] = $targetProperties

        $augmentedInput = @()
    }

    process {
        $propertyMap = @{}

        $targetProperties | foreach {
            if ( $_ -ne $::.RequestLogEntry.ERROR_MESSAGE_EXTENDED_FIELD ) {
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

            $propertyMap[$::.RequestLogEntry.ERROR_MESSAGE_EXTENDED_FIELD] = if ( $simpleErrorMessage ) {
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
