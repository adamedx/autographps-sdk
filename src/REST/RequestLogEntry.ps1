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

. (import-script ../cmdlets/common/DisplayTypeFormatter)
. (import-script HttpUtilities)

ScriptClass RequestLogEntry {
    $displayProperties = $null
    $logLevel = $null
    $isError = $false

    static {
        const ERROR_RESPONSE_FIELD 'ErrorResponse'
        const LOG_ENTRY_DISPLAY_TYPE 'GraphLogEntryDisplayType'
        const ERROR_MESSAGE_EXTENDED_FIELD 'ErrorMessage'
        const EXTENDED_PROPERTIES @($ERROR_MESSAGE_EXTENDED_FIELD)

        $::.DisplayTypeFormatter |=> RegisterDisplayType $LOG_ENTRY_DISPLAY_TYPE 'RequestTimestamp', 'Status', 'Method', 'Uri'

        $ExtendedPropertySet = $null

        function GetExtendedPropertySet {
            $this.ExtendedPropertySet
        }

        function GetExtendedProperties {
            $this.EXTENDED_PROPERTIES
        }

        function __NewDisplayProperties($restRequest, $logLevel, $scrubbedRequestHeaders, $requestBody, $appId, $authType, $userObjectId, $userUpn, $tenantId, $scopes, $resourceUri, $query, $version ) {
            $restRequesturi = if ( $restRequest ) { $restRequest.Uri }
            $restRequestMethod = if ( $restRequest ) { $restRequest.Method }
            $restRequestHeaders = if ( $restRequest ) { $restRequest.headers } else { @{} }
            $restRequestBody = if ( $restRequest ) { $restRequest.body }

            $restRequestBodySize = if ( $restRequestBody -ne $null ) {
                $restRequestBody.length
            } else {
                0
            }

            [ordered] @{
                RequestTimestamp = $null
                Uri = $restRequestUri
                Method = $restRequestMethod
                ClientRequestId = $restRequestHeaders['client-request-id']
                RequestHeaders = $scrubbedRequestHeaders
                RequestBody = $requestBody
                RequestBodySize = $restRequestBodySize
                AppId = $appId
                AuthType = $authType
                UserObjectId = $userObjectId
                UserUpn = $userUpn
                TenantId = $tenantId
                Permissions = $scopes
                ResourceUri = $resourceUri
                Query = $query
                Version = $version
                Status = 0
                ResponseTimestamp = $null
                $ERROR_RESPONSE_FIELD = $null
                ResponseClientRequestId = $null
                ResponseHeaders = $null
                ResponseContent = $null
                ResponseContentSize = $null
                ResponseRawContent = $null
                ResponseRawContentSize = $null
                ClientElapsedTime = $null
                LogLevel = $logLevel
            }
        }

        function __AddMembersToOutputType {
            $displayProperties = (__NewDisplayProperties).keys
            $propertyMembers = $displayProperties | foreach {
                $typeArgs = @{
                    TypeName = $LOG_ENTRY_DISPLAY_TYPE
                    MemberType = 'NoteProperty'
                    MemberName = $_
                    Value = $null
                }

                Update-typedata @typeArgs -force
            }
            $displayProperties
        }

        $ExtendedPropertySet = @( $EXTENDED_PROPERTIES )
        $ExtendedPropertySet += __AddMembersToOutputType
    }

    function __initialize($connection, $restRequest, $logLevel) {
        $this.logLevel = $logLevel

        $userInfo = if ( $connection ) { $connection.identity.GetUserInformation() }
        $scrubbedRequestHeaders = __GetScrubbedHeaders $restRequest.headers

        $requestBody = if ( __ShouldLogFullRequest ) { $restRequest.body }
        $appId = if ( $connection ) { $connection.identity.app.appid }
        $authType = if ( $connection ) { $connection.identity.app.authtype }
        $userObjectId = if ( $userInfo ) { $userInfo.userObjectId }
        $userUpn = if ( $userInfo ) { $userInfo.userId }
        $tenantId = if ( $connection ) { $connection.identity.tenantdisplayid }
        $scopes = if ( $connection -and
                       $connection.identity -and
                       ( $connection.identity.token | gm scopes -erroraction ignore ) ) {
                           $connection.identity.token.scopes
                       }
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

        $this.displayProperties = if ( $logLevel -ne 'None' ) {
            $this |::> __NewDisplayProperties $restRequest $logLevel $scrubbedRequestHeaders $requestBody $appId $authType $userObjectId $userUpn $tenantId $scopes $resourceUri $query $version
        }
    }

    function LogRequestStart {
        $this.displayProperties.RequestTimestamp = [DateTimeOffset]::now
    }

    function LogSuccess([PSTypeName('RESTResponse')] $response) {
        try {
            $responseTimestamp = [DateTimeOffset]::now
            $scrubbedHeaders = __GetScrubbedHeaders $response.headers

            if ( $this.logLevel -ne 'None' ) {
                $this.displayProperties.Status = $response.statuscode
                $this.displayProperties.ResponseTimestamp = [DateTimeOffset]::now
                $this.displayProperties.ResponseTimestamp = $responseTimestamp
                $this.displayProperties.ClientRequestId = $scrubbedHeaders['client-request-id']
                $this.displayProperties.ResponseHeaders = $scrubbedHeaders
                $this.displayProperties.ClientElapsedTime = $responseTimestamp - $this.displayProperties.RequestTimestamp

                $this.displayProperties.ResponseContentSize = $response.RawContentLength
                $this.displayProperties.ResponseRawContentSize = $response.RawContent.Length

                if ( __ShouldLogFullResponse ) {
                    $this.displayProperties.ResponseContent = $response.content
                    $this.displayProperties.ResponseRawContent = $response.rawContent
                }
            }
        } catch {
            $_ | write-debug
        }
    }

    function LogError($response, $responseMessage ) {
        $this.isError = $true

        $headers = $null

        # Interesting -- assigning $response.headers this as the output of the if
        # converts the type -- quite unexpected and not a good behavior. We'll
        # just assign it explicitly to work around it
        if ( $response | gm headers -erroraction ignore) {
            $headers = $response.headers
        }

        $statusCode = if ( $response | gm statuscode -erroraction ignore ){
            [int] $response.statusCode
        }

        try {
            $responseTimestamp = [DateTimeOffset]::now
            $responseHeaders = $::.HttpUtilities |=> NormalizeHeaders $headers
            $this.displayProperties.Status = $statuscode
            $this.displayProperties.ResponseClientRequestId = if ( $responseHeaders ) { $responseHeaders['client-request-id'] }
            $this.displayProperties.ResponseHeaders = $responseHeaders
            $this.displayProperties.ResponseTimestamp = $responseTimestamp
            $this.displayProperties[$this.scriptclass.ERROR_RESPONSE_FIELD] = $responseMessage
            $this.displayProperties.ClientElapsedTime = $responseTimestamp - $this.displayProperties.RequestTimestamp

            $this.displayProperties.ResponseContentSize = if ( $response | gm RawContentLength -erroraction ignore ) { $response.RawContentLength }
            $this.displayProperties.ResponseRawContentSize = if ( $response | gm RawContent -erroraction ignore ) { $response.RawContent.Length }

            if ( __ShouldLogFullResponse ) {
                $this.displayProperties.ResponseContent = if ( $response | gm Content -erroraction ignore ) { $response.content }
                $this.displayProperties.ResponseRawContent = if ( $response | gm RawContent -erroraction ignore ) { $response.rawContent }
            }
        } catch {
            $_ | write-debug
        }
    }

    function ToDisplayableObject {
        if ( $this.displayProperties ) {
            try {
                $result = [PSCustomObject] $this.displayProperties
                $result.psobject.typenames.add($this.scriptclass.LOG_ENTRY_DISPLAY_TYPE)
                $result
            } catch {
                $_ | write-debug
            }
        }
    }

    function __GetScrubbedHeaders([HashTable] $headers) {
        $scrubbedHeaders = $::.HttpUtilities |=> NormalizeHeaders ( $headers.clone() )
        'Authorization', 'Workload-Authorization' | foreach {
            if ( $headers.ContainsKey($_) ) {
                $scrubbedHeaders[$_] = '<redacted>'
            }
        }
        $scrubbedHeaders
    }

    function __ShouldLogFullRequest {
        'FullRequest', 'Full' -contains $this.logLevel
    }

    function __ShouldLogFullResponse {
        'FullResponse', 'Full' -contains $this.logLevel
    }
}
