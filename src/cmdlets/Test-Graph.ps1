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

. (import-script ../REST/RESTRequest)
. (import-script ../graphservice/GraphEndpoint)
. (import-script ../client/GraphConnection)
. (import-script ../client/GraphContext)

<#
.SYNOPSIS
Determines without authentication whether a Graph endpoint is accessible over the network.

.DESCRIPTION
The Test-Graph command makes a request to an arbitrary URL of a target Graph endpoint. If a response is received, HTTP headers containing diagnostic information typically returned by Graph is converted to a human-readable representation by the command.

.PARAMETER Cloud
Specifies that the target Graph endpoint to test is the Graph endpoint associated with cloud environment indicated by the parameter. By default, Test-Graph makes a request against the current connection, which itself defaults to https://graph.microsoft.com, so this parameter allows the default to be overridden.

.PARAMETER Connection
Specifies a Connection object returned by the New-GraphConnection command whose Graph endpoint will be accessed when making Graph requests with this Connection object.

.PARAMETER EndpointUri
Specifies an arbitrary URI as the Graph endpoint -- the URI must be an absolute URI, e.g. https://graph.microsoft.com.

.PARAMETER RawContent
By default, the output of the cmdlet is deserialized PowerShell objects. If this switch is specified, the output is an object whose properties names correspond to specific HTTP header names returned by Graph. The values of the properties are then the values of the corresponding returned headers.

.OUTPUTS
If successful, this cmdlet returns non-null, non-empty output. If it is not successful, an HTTP status code or other error will be surfaced as an exeption. Note that the exact structure of successful output is NOT a contract as it is based on undocumented aspects of the Graph protocol -- the output structure can change at any time (and has changed in the past). However, the output will usually be deserialized PowerShell objects that provide diagnostic information about the Graph endpoint such as the name of the datacenter that served the request, the time of the request as seen by the system that served the response, and the host name of the system that served the response. The output may be piped to other commands including Select-Object to project specific fields or perform other additional processing.

.EXAMPLE
Test-Graph

TestUri                : https://graph.microsoft.com/test
ServerTimestamp        : 09/20/2021 10:21:07 +00:00
ClientElapsedTime (ms) : 12.0889
RequestId              : fa0113c3-c0ab-4f47-8571-d3bc6b891686
DataCenter             : West US 2
Ring                   : 1
RoleInstance           : MW2PEPF000031CC
ScaleUnit              : 001
Slice                  : E
NonfatalStatus         : 405

When no parameters are specified, the command targets the Graph endpoint of the current connection, in this case https://graph.microsoft.com, and outputs diagnostic information.

.EXAMPLE
Test-Graph -Cloud ChinaCloud

TestUri                : https://microsoftgraph.chinacloudapi.cn/test
ServerTimestamp        : 9/19/2021 2:21:03 AM +00:00
ClientElapsedTime (ms) : 19.0889
RequestId              : 6150c057-020f-4f5d-b2c3-cc208570ae6b
DataCenter             : China East
Ring                   : 6
RoleInstance           : SH1NEPF00000388
ScaleUnit              : 001
Slice                  : E
NonfatalStatus         : 405

This command targets the Graph endpoint for the China cloud, https://microsoftgraph.chinacloudapi.cn, and outputs its diagnostic information.

.EXAMPLE
Test-Graph -RawContent

Date                          request-id                           x-ms-ags-diagnostic
----                          ----------                           -------------------
Tue, 21 Sep 2021 13:27:44 GMT 66a3c612-6887-4533-bc25-c4e7a226b85e @{ServerInfo=}

This command returns the same information as in the first example, but by specifying the RawContent parameter the command is directed not to output the response as deserialized structured objects, but as an object that contains the headers returned by Graph in response to the test request. Note that RawContent's output does not correspond exactly to the output returned when RawContent is not specified as the latter performs interpretation of the Graph response with context about local state such as the local system's time. In contrast, when RawContent is specified no interpretation is made of the results, they are simply returned as-is.

.LINK
Get-GraphCurrentConnection
New-GraphConnection
Connect-GraphApi
#>
function Test-Graph {
    [cmdletbinding(defaultparametersetname='currentconnection')]
    param(
        [parameter(parametersetname='KnownClouds')]
        [validateset("Public", "ChinaCloud", "USGovernmentCloud")]
        [string] $Cloud,

        [parameter(parametersetname='Connection', mandatory=$true)]
        [PSCustomObject] $Connection,

        [parameter(parametersetname='CustomEndpoint', mandatory=$true)]
        [Uri] $EndpointUri,

        [switch] $RawContent
    )
    Enable-ScriptClassVerbosePreference

    $logger = $::.RequestLog |=> GetDefault

    $graphEndpointUri = if ( $Connection ) {
        $Connection.GraphEndpoint.Graph
    } elseif ( $Cloud ) {
        (new-so GraphEndpoint $Cloud).Graph
    } elseif ( $endpointUri ) {
        $endpointUri
    } else {
        ($::.GraphContext |=> GetConnection).GraphEndpoint.Graph
    }

    $pingUri = [Uri]::new($graphEndpointUri, 'test')
    $request = new-so RESTRequest $pingUri HEAD
    $logEntry = if ( $logger ) { $logger |=> NewLogEntry $null $request }
    $responseException = $null
    $responseStatus = 0

    $response = try {
        $successfulResponse = $request |=> Invoke -logEntry $logEntry
        $successfulResponse
    } catch {
        $responseException = $_.Exception.InnerException.InnerException
        $responseException.Response
    } finally {
        if ( $logEntry ) { $logger |=> CommitLogEntry $logEntry }
    }

    $dateHeader = $null
    $requestId = $null

    $diagnosticHeaderName = 'x-ms-ags-diagnostic'

    $diagnosticInfo = if ( $response | get-member Headers -erroraction ignore ) {
        $dateHeader = $response.Headers['Date']
        $requestId = $response.Headers['request-id']
        $response.Headers[$diagnosticHeaderName]
    }

    $serverTime = if ( $dateHeader ) {
        $dateTime = [DateTimeOffset]::Now
        if ( [DateTimeOffset]::TryParse($dateHeader, [ref] $dateTime) ) {
            $dateTime
        } else {
            $dateHeader
        }
    }

    $logData = $logEntry.ToDisplayableObject()
    $responseStatus = $logData.Status
    $clientRequestTime = $logData.RequestTimestamp
    $clientResponseTime = $logData.ResponseTimestamp
    $clientElapsedTime = $clientResponseTime - $clientRequestTime

    if ( ! $diagnosticInfo ) {
        if ( $responseException ) {
            throw $responseException
        } else {
            throw "Graph URI '$graphEndpointUri' was unreachable or returned an unexpected response"
        }
    } elseif ( ! $RawContent.ispresent ) {
        # The [ordered] type adapter will ensure that enumeration of items in a hashtable
        # is sorted by insertion order
        $result = [ordered] @{
            TestUri = ($pingUri.ToString())
            ServerTimestamp = $serverTime
            ClientRequestTimestamp = $clientRequestTime
            ClientResponseTimestamp = $clientResponseTime
            ClientElapsedTime = $clientElapsedTime
            RequestId = $requestId
        }

        $content = $diagnosticInfo | convertfrom-json | select-object -ExpandProperty ServerInfo

        # Sort by name to get consistent sort formatting
        $content | gm -membertype noteproperty | sort-object name | foreach {
            $value = ($content | select -expandproperty $_.name)
            $result[$_.name] = $value
        }

        $result['NonfatalStatus'] = $responseStatus

        $asObject = [PSCustomObject] $result
        $asObject.pstypenames.insert(0, 'GraphEndpointTest')
        $asObject
    } else {
        [PSCustomObject] (
            [ordered] @{
                Date = $dateHeader
                'request-id' = $requestId
                $diagnosticHeaderName = $diagnosticInfo | ConvertFrom-Json
            }
        )
    }
}

