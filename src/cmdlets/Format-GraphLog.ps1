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
        'Permissions'
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
When a command such as Get-GraphResource or Invoke-GraphApiRequest issues a request to the Graph, the details of that request, including the
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

RequestTimestamp      StatusCode Method Version ResourceUri   ErrorMessage
----------------      ---------- ------ ------- -----------   ------------
10/22/2019 8:07:06 PM        200 GET            ping
10/22/2019 8:07:50 PM        200 GET    v1.0    me
10/22/2019 8:07:53 PM        200 GET            ping
10/22/2019 8:08:42 PM        200 GET    beta    organization
10/22/2019 8:08:47 PM        400 GET    v1.0    me/drive/root Tenant does not have a SPO license.
10/22/2019 8:12:28 PM        200 GET            ping

In this example, the default view, Status, is used to view the log.

.EXAMPLE
Get-GraphLog | Format-GraphLog ResponseTimestamp, StatusCode, AppId, ResourceUri

ResponseTimestamp     StatusCode AppId                                ResourceUri
-----------------     ---------- -----                                -----------
10/22/2019 8:07:06 PM        200                                      ping
10/22/2019 8:07:50 PM        200 9825d80c-5aa0-42ef-bf13-61e12116704c me
10/22/2019 8:07:53 PM        200                                      ping
10/22/2019 8:08:42 PM        200 9825d80c-5aa0-42ef-bf13-61e12116704c organization
10/22/2019 8:08:47 PM        400 9825d80c-5aa0-42ef-bf13-61e12116704c me/drive/root
10/22/2019 8:12:29 PM        200                                      ping

In this example, the log entries are shown, but this time the specific fields to display are specified to the
Format-GraphLog command via the Property argument (which is unnamed since it is the first positional parameter).

.EXAMPLE
Get-GraphLog | Format-GraphLog Vview Debug

RequestTimestamp      ClientRequestId                      StatusCode Method Version ResourceUri   Query HasRequestBody ErrorMessage
----------------      ---------------                      ---------- ------ ------- -----------   ----- -------------- ------------
10/22/2019 8:07:06 PM 2fdf8f02-0b28-450c-b906-2f9d68d93e38        200 GET            ping                         False
10/22/2019 8:07:50 PM 441d4546-db3a-43ae-b11f-7a81cf4b8a67        200 GET    v1.0    me                            True
10/22/2019 8:07:53 PM d3654d3c-324b-49c7-b3ba-c3df6e6f900d        200 GET            ping                         False
10/22/2019 8:08:42 PM 1495925b-932b-44b9-97e6-7d85e56f1ffd        200 GET    v1.0    organization                  True
10/22/2019 8:08:47 PM 6af416ec-1b64-4a5e-9e84-38a0080d4f0a        400 GET    v1.0    me/drive/root                 True Tenant does not have a SPO license.
10/22/2019 8:12:28 PM f37f5954-c2ac-44cd-ae13-7a7fc5652e78        200 GET            ping                         False

In this example, the View option is specified with the value Debug. The resulting view displays the ClientRequestId submitted
with the request which can be used when obtaining support from the Graph Service team.

.LINK
Format-GraphLog
Set-GraphLogOption
Clear-GraphLog
Get-GraphResource
Invoke-GraphApiRequest
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

        [switch] $Wrap,

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

        foreach ( $targetProperty in $targetProperties ) {
            if ( $targetProperty -ne $::.RequestLogEntry.ERROR_MESSAGE_EXTENDED_FIELD ) {
                $propertyValue = if ( $InputObject | gm  $targetProperty ) {
                    $InputObject | select -expandproperty $targetProperty
                }

                $augmentedValue = if ( $propertyValue -is [DateTimeOffset] ) {
                    # DateTimeOffset has a very long format that includes the time
                    # zone offset -- use something shorter to save display space
                    $propertyValue.ToString('G') # i.e. 10/22/2019 9:22:48 PM
                } else {
                    $propertyValue
                }
                $propertyMap[$targetProperty] = $augmentedValue
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

