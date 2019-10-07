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

. (import-script ../REST/RESTRequest)
. (import-script ../graphservice/GraphEndpoint)
. (import-script ../client/GraphConnection)
. (import-script ../client/GraphContext)

$AlternatePropertyMapping = @{
    'Time-Local'=@('TimeLocal', {param($val) [DateTime] $val})
    'Time-UTC'=@('TimeUtc', {param($val) [DateTime]::new(([DateTime] $val).ticks, [DateTimeKind]::Utc)})
}

<#
.SYNOPSIS
Determines without authentication whether a Graph endpoint is accessible over the network.

.DESCRIPTION
The Test-Graph cmdlet makes a simple GET request to a specified Graph endpoint's 'ping' URL. If a successful (HTTP status code 200) response is received, parameters of the response are returned by the cmdlet.

.PARAMETER Cloud
Specifies that the target Graph endpoint to test is the Graph endpoint associated with cloud environment indicated by the parameter. By default, Test-Graph makes a request against the current connection, which itself defaults to https://graph.microsoft.com, so this parameter allows the default to be overridden.

.PARAMETER Connection
Specifies a Connection object returned by the New-GraphConnection command whose Graph endpoint will be accessed when making Graph requests with this Connection object.

.PARAMETER EndpointUri
Specifies an arbitrary URI as the Graph endpoint -- the URI must be an absolute URI, e.g. https://graph.microsoft.com.

.PARAMETER RawContent
By default, the output of the cmdlet is deserialized PowerShell objects. If this switch is specified, the output is the response JSON formatted value returned by the Graph endpoint without deserialization.

.OUTPUTS
If successful, this cmdlet returns deserialized PowerShell objects that provide diagnostic information about the Graph endpoint such as the name of the datacenter that served the request, the time of the request as seen by the system that served the response, and the host name of the system that served the response. The output may be piped to other commands including Select-Object to project specific fields or perform other additional processing.
If the command is not successful, an HTTP status code will be surfaced in an exception. Failure indicates that the Graph endpoint may not be reachable from the system on which this cmdlet was executed, or that the Graph service is being disrupted.

.EXAMPLE
Test-Graph

ADSiteName : wus
Build      : 1.0.9954.5
DataCenter : west us
Host       : agsfe_in_38
PingUri    : https://graph.microsoft.com/ping
Ring       : 5
ScaleUnit  : 002
Slice      : slicec
TimeLocal  : 1/24/2019 6:54:13 AM
TimeUtc    : 1/24/2019 6:54:13 AM

When no parameters are specified, the command targets the Graph endpoint of the current connection, in this case https://graph.microsoft.com, and outputs diagnostic information.

.EXAMPLE
Test-Graph -Cloud GermanyCloud

ADSiteName : dne
Build      : 1.0.9954.4
DataCenter : germany northeast
Host       : agsfe_in_3
PingUri    : https://graph.microsoft.de/ping
Ring       : 4
ScaleUnit  : 000
Slice      : slicec
TimeLocal  : 1/24/2019 7:04:06 AM
TimeUtc    : 1/24/2019 7:04:06 AM

This command targets the Graph endpoint for the Germany cloud, https://graph.microsoft.de, ando outputs its diagnostic information.

.EXAMPLE
Test-Graph -RawContent

{"Time-Local":"1/24/2019 7:06:20 AM","Time-UTC":"1/24/2019 7:06:20 AM","Build":"1.0.9954.5","DataCenter":"west us","Slice":"slicec","Ring":"5","ScaleUnit":"001","Host":"agsfe_in_0","ADSiteName":"wus"}

This command returns the same information as in the first example, but by specifying the RawContent parameter the command is directed not to output the response as deserialized structured objects, but in the exact format in which it was returned by Graph, in this case JSON.

.LINK
Get-GraphConnectionInfo
New-GraphConnection
Connect-Graph
#>
function Test-Graph {
    [cmdletbinding(defaultparametersetname='currentconnection')]
    param(
        [parameter(parametersetname='KnownClouds')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud,

        [parameter(parametersetname='Connection', mandatory=$true)]
        [PSCustomObject] $Connection,

        [parameter(parametersetname='CustomEndpoint', mandatory=$true)]
        [Uri] $EndpointUri,

        [switch] $RawContent
    )
    Enable-ScriptClassVerbosePreference

    $graphEndpointUri = if ( $Connection ) {
        $Connection.GraphEndpoint.Graph
    } elseif ( $Cloud ) {
        (new-so GraphEndpoint $Cloud).Graph
    } elseif ( $endpointUri ) {
        $endpointUri
    } else {
        ($::.GraphContext |=> GetConnection).GraphEndpoint.Graph
    }

    $pingUri = [Uri]::new($graphEndpointUri, 'ping')
    $request = new-so RESTRequest $pingUri
    $response = $request |=> Invoke

    if ( ! $RawContent.ispresent ) {
        # The [ordered] type adapter will ensure that enumeration of items in a hashtable
        # is sorted by insertion order
        $result = [ordered] @{}

        $content = $response.content | convertfrom-json
        $content | add-member -notepropertyname PingUri -notepropertyvalue $pinguri

        # Sort by name to get consistent sort formatting
        $content | gm -membertype noteproperty | sort-object name | foreach {
            $value = ($content | select -expandproperty $_.name)
            $mapping = $alternatePropertyMapping[$_.name]

            $destination = if ($mapping -eq $null) {
                $_.name
            } else {
                $value = invoke-command -scriptblock $mapping[1] -argumentlist $value
                $mapping[0]
            }

            $result[$destination] = $value
        }

        [PSCustomObject] $result
    } else {
        $response.content
    }
}
