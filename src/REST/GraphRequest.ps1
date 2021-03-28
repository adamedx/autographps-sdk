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

. (import-script RESTRequest)
. (import-script GraphResponse)

ScriptClass GraphRequest {
    $Connection = $null
    $Uri = strict-val [Uri]
    $RelativeUri = strict-val [Uri]
    $Verb = strict-val [String]
    $Body = strict-val [String]
    $Query = $null
    $Headers = $null
    $ClientRequestId = $null
    $ReturnRequest = $false
    $DeltaQuery = $false
    $PageSizePreference = 0

    function __initialize([PSCustomObject] $GraphConnection, [Uri] $uri, $verb = 'GET', $headers = $null, $query = $null, $clientRequestId, [bool] $noRequestId, [bool] $returnRequest, [bool] $deltaQuery, $deltaToken, $pageSizePreference, [string] $consistencyLevel = 'Auto') {
        $targetConsistencyLevel = if ( $consistencyLevel -and $consistencyLevel -ne 'Auto' ) {
                $consistencyLevel
        } else {
            $graphConnection.consistencyLevel
        }

        if ( $targetConsistencyLevel -eq 'Auto' ) {
            $targetConsistencyLevel = $null
        }

        if ( $targetConsistencyLevel -and ( $targetConsistencyLevel -notin 'Default', 'Session', 'Eventual' ) ) {
            throw "The specified consistency level '$targetConsistencyLevel' is not valid -- it must be one of 'Auto', 'Default', 'Session', or 'Eventual'"
        }

        $uriString = if ( $uri.scheme -ne $null ) {
            $uri.AbsoluteUri
        } else {
            $graphConnection.GraphEndpoint.Graph.tostring() + $uri.originalstring
        }

        if ( ! $noRequestId ) {
            $this.ClientRequestId = if ( $clientRequestId ) {
                [guid] ($clientRequestId)
            } else {
                new-guid
            }
        }

        $uriQueryLength = if ( $uri.Query -ne $null ) { $uri.Query.length } else { 0 }
        $uriString = $uriString.substring(0, $uriString.length - $uriQueryLength)

        if ( $deltaQuery -or $deltaToken ) {
            if ( ! ( $::.GraphUtilities |=> IsDeltaUri $uri ) ) {
                $uriString = $uriString, 'microsoft.graph.delta' -join '/'
            }
        }

        $uriNoQuery = [Uri]::new($uriString)

        $this.PageSizePreference = $pageSizePreference
        $this.DeltaQuery = $deltaQuery
        $this.ReturnRequest = $returnRequest
        $this.Connection = $GraphConnection
        $this.RelativeUri = $uri
        $this.Uri = $uriNoQuery
        $this.Verb = $verb

        $queryParams = if ( ! $deltaToken ) {
            @($uri.query)
        } else {
            @("deltaToken=$deltaToken")
        }

        $queryParams += $query
        $this.Query = __AddQueryParameters $queryParams

        $this.Headers = if ( $headers -ne $null ) {
            $headers
        } else {
            @{'Content-Type'='application/json'}
        }

        if ($graphConnection.Identity) {
            $token = $graphConnection |=> GetToken
            $this.Headers['Authorization'] = $token.CreateAuthorizationHeader()
        }

        if ( $this.ClientRequestId ) {
            $this.Headers['client-request-id'] = $this.ClientRequestId.tostring()
        }

        if ( $this.PageSizePreference ) {
            $this.Headers['Prefer'] = "Prefer: odata.maxpagesize=$($this.PageSizePreference)"
        }

        if ( $targetConsistencyLevel -and $targetConsistencyLevel -ne 'Default' ) {
            $this.Headers['ConsistencyLevel'] = $targetConsistencyLevel
        }
    }

    function Invoke($pageStartIndex = $null, $maxResultCount = $null, $logger) {
        if ( $this.Connection.Status -eq ([GraphConnectionStatus]::Offline) ) {
            throw "Web request cannot proceed -- connection status is set to offline"
        }

        $queryParameters = $this.query
        if ( $this.Query -isnot [object[]] ) {
            $queryParameters = , $this.Query
        }

        if ($pageStartIndex -ne $null) {
            $queryParameters += (__NewODataParameter 'skip' $pageStartIndex)
        }

        if ( $maxResultCount ) {
            $queryParameters += (__NewODataParameter 'top' $maxResultCount)
        }

        $query = __AddQueryParameters $queryParameters

        if ( $this.ClientRequestId ) {
            write-verbose "Invoking Graph request with request id: '$($this.ClientRequestId)'"
        }

        $response = __InvokeRequest $this.verb $this.uri $query $logger
        new-so GraphResponse $response
    }

    function SetBody($body) {
        $this.body = if ($body -is [string] ) {
            $body
        } else {
            $body | convertto-json -depth 6
        }
    }

    function __InvokeRequest($verb, $uri, $query, $logger) {
        $uriPath = __UriWithQuery $uri $query
        $uri = new-object Uri $uriPath
        $restRequest = new-so RESTRequest $uri $verb $this.headers $this.body $this.Connection.UserAgent $this.returnRequest
        $logEntry = if ( $logger -and ! $this.returnRequest ) { $logger |=> NewLogEntry $this.Connection $restRequest }
        try {
            $restResponse = $restRequest |=> Invoke -logEntry $logEntry
        } finally {
            if ( $logEntry ) { $logger |=> CommitLogEntry $logEntry }
        }
        $restResponse
    }

    function __AddQueryParameters([string[]] $parameters) {
        $components = @()

        $parameters | foreach {
            if ( $_ -ne $null ) {

                $normalizedParameter = if ( $_.startswith('?') ) {
                    $_.substring(1, $_.length -1)
                } else {
                    $_
                }

                if ( $normalizedParameter -ne $null -and $normalizedParameter.length -gt 0 ) {
                    $components += $normalizedParameter
                }
            }
        }

        $components -join '&'
    }

    function __UriWithQuery($uri, $query) {
        if ( $query -ne $null -and $query.length -gt 0 ) {
            new-object Uri ($Uri.tostring() + '?' + $query)
        } else {
            new-object Uri $uri.tostring()
        }
    }

    function __NewODataParameter($parameterName, $value) {
        if ( $value -ne $null ) {
            '${0}={1}' -f $parameterName, $value
        } else {
            '${0}' -f $parameterName
        }
    }
}
