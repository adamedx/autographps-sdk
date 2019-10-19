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

ScriptClass RequestLogEntry {
    $requestIndex = 0
    $displayProperties = $null
    $logLevel = $null

    static {
        $logFormatter = new-so DisplayTypeFormatter GraphLogEntryDisplayType 'RequestTimestamp', 'Uri', 'Method', 'StatusCode'
    }

    function __initialize($requestIndex, $connection, $restRequest, $logLevel) {
        $userInfo = if ( $connection ) { $connection.identity.GetUserInformation() }
        $scrubbedRequestHeaders = __GetScrubbedHeaders $restRequest.headers

        $requestBody = if ( $loglevel -eq 'Full' ) { $restRequest.body }
        $appId = if ( $connection ) { $connection.identity.app.appid }
        $authType = if ( $connection ) { $connection.identity.app.authtype }
        $userObjectId = if ( $userInfo ) { $userInfo.userObjectId }
        $userUpn = if ( $userInfo ) { $userInfo.userId }
        $tenantId = if ( $connection ) { $connection.identity.tenantdisplayid }
        $scopes = if ( $connection ) { $connection.scopes }
        $version = if ( $restRequest.Uri.segments.length -ge 3 ) { $restRequest.Uri.segments[1].trimend('/') }
        $query = $restRequest.Uri.query

        $pathSegments = @()
        $segmentCount = $restRequest.Uri.segments.length
        for ( $segmentIndex = 1; $segmentIndex -lt $segmentCount; $segmentIndex++ ) {
            if ( $segmentIndex -gt 1 -or ! $version ) {
                $pathSegments += $restRequest.Uri.segments[$segmentIndex]
            }
        }

        $resourceUri = $pathSegments -join ''

        $this.logLevel = $logLevel
        $this.requestIndex = $requestIndex
        $this.displayProperties = if ( $logLevel -ne 'None' ) {
            [ordered] @{
                RequestTimestamp = $null
                Uri = $restRequest.uri
                Method = $restRequest.method
                ClientRequestId = $restRequest.headers['client-request-id']
                RequestHeaders = $scrubbedRequestHeaders
                RequestBody = $requestBody
                HasRequestBody = $restRequest.body -ne $null
                AppId = $appId
                AuthType = $authType
                UserObjectId = $userObjectId
                UserUpn = $userUpn
                TenantId = $tenantId
                Scopes = $scopes
                ResourceUri = $resourceUri
                Query = $query
                Version = $version
                StatusCode = 0
                ResponseTimestamp = $null
                ErrorMessage = $null
                ResponseClientRequestId = $null
                ResponseHeaders = $null
                ResponseBody = $null
                ClientElapsedTime = $null
                LogLevel = $logLevel
            }
        }
    }

    function LogRequestStart {
        $this.displayProperties.RequestTimestamp = [DateTimeOffset]::now
    }

    function LogSuccess([PSTypeName('RESTResponse')] $response) {
        try {
            $responseTimeStamp = [DateTimeOffset]::now
            $scrubbedHeaders = __GetScrubbedHeaders $response.headers

            if ( $this.logLevel -ne 'None' ) {
                $this.displayProperties.StatusCode = $response.statuscode
                $this.displayProperties.ResponseTimestamp = [DateTimeOffset]::now
                $this.displayProperties.ResponseTimestamp = $responseTimestamp
                $this.displayProperties.ClientRequestId = $scrubbedHeaders['client-request-id']
                $this.displayProperties.ResponseHeaders = $scrubbedHeaders
                $this.displayProperties.ClientElapsedTime = $responseTimestamp - $this.displayProperties.RequestTimestamp
            }
        } catch {
            $_ | write-debug
        }
    }

    function LogError([System.Net.WebResponse] $response, $responseMessage ) {
        try {
            $responseTimeStamp = [DateTimeOffset]::now
            $this.displayProperties.StatusCode = $response.statuscode.value__
            $this.displayProperties.ResponseClientRequestId = $response.headers['client-request-id']
            $this.displayProperties.Headers = $response.headers
            $this.displayProperties.ResponseTimestamp = $responseTimestamp
            $this.displayProperties.ErrorMessage = $responseMessage
            $this.displayProperties.ClientElapsedTime = $responseTimestamp - $this.displayProperties.RequestTimestamp
        } catch {
            $_ | write-debug
        }
    }

    function ToDisplayableObject {
        if ( $this.displayProperties ) {
            try {
                $this.scriptclass.logFormatter |=> DeserializedGraphObjectToDisplayableObject ([PSCustomObject] $this.displayProperties)
            } catch {
                $_ | write-debug
            }
        }
    }

    function __GetScrubbedHeaders([HashTable] $headers) {
        $scrubbedHeaders = $headers.clone()
        'Authorization', 'Workload-Authorization' | foreach {
            $scrubbedHeaders[$_] = '<redacted>'
        }
        $scrubbedHeaders
    }
}
