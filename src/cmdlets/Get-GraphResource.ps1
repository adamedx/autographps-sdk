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

. (import-script Invoke-GraphApiRequest)
. (import-script common/ItemResultHelper)
. (import-script common/PermissionParameterCompleter)

<#
.SYNOPSIS
Issues a REST HTTP request with the GET method for a URI on a Graph endpoint

.DESCRIPTION
The Get-GraphResource command issues a GET method request to the Graph in the context of a given graph resource URI and Graph API version. To learn about the capabilities of the Graph API and the URIs that can be supplied to this command to access resources such as users, devices, documents, and relationships, see the Graph API documentation: https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0.

Get-GraphResource obtains information from the Graph by making GET HTTP requests to a Graph endpoint such as https://graph.microsoft.com. To make the request, the command obtains a token for a Graph endpoint and then issues the GET request against a URI based on the endpoint and returns the resulting response. The graph resource URI, HTTP Headers, and other Microsoft Graph-specific parameters of the request may all be specified by this command. Get-GraphResource allows the issuing of any valid GET request to Microsoft Graph. Because the command is limited to GET requests, it can only be used to read data from the Graph. To perform write operations, see the Invoke-GraphApiRequest command which takes a set of parameters similar to Get-GraphResource but also allows the HTTP method to be specified; it defaults to the GET method as in the Get-GraphResource command, but other methods may be specified in order to accomplish write operations.

The output of the command is typically the Content field of the response as deserialized objects returned by the API call; the format may be altered through command parameters such as RawContent to provide output in other formats such as the exact stream returned by Graph. If the HTTP status code of the response does not indicate success (i.e. it is not 2XX), an exception will be thrown.

Executing Get-GraphResource will result in a sign-in UX if the Connection object of the current Graph or one explicitly supplied to the command through the Connection parameter does not already have a token associated with it. Once the token is acquired for the Connection object, it is used to issue the request to Graph. Subsequent invocations of this or any other commands in the module that use the same connection will silently use the previously acquired token without a UX, so there will be no additional sign-in UX.

The command also supports paging, since the Graph endpoint can return large result sets in the thousands of objects over HTTP protocol. By default this command returns only the first 10 results in a request. The PowerShell standard paging parameters First and Skip can be used to control which subset of the results to return in a single invocation of Get-GraphResource.

This command, like all commands in this module, uses the Connection object of the current graph by default to determine the Graph endpoint and credentials / permissions of an access token used to communicate to Graph. The current Graph's connection can be changed to use different credentials, permissions, or Graph endpoing by using the Connect-GraphApi command.

.PARAMETER Uri
This parameter is required -- it is the URI relative to the current Graph of the graph resource on which to invoke the GET method. For example, if the goal was to issue a GET on the resource URI https://graph.microsoft.com/v1.0/users/user1@mydomain.org, assuming that the current Graph endpoint was http://graph.microsoft.com and the API version was 'v1.0', this parameter would be specified as 'users/user1@mydomain.org'. If the AbsoluteUri parameter is specified, the Uri parameter must be an absolute Uri (see the AbsoluteUri documentation below).

.PARAMETER Filter
Specifies an optional OData query filter to reduce the number of results returned to those satisfying the query's criteria. Visit https://www.odata.org/ for details on the OData query syntax.

.PARAMETER Select
Specifies as an array the set of properties of the resource objects that the response to the request contain -- this is exactly the set of properties that will be returned as output of the command for each resource. When this parameter is not specified (default), the set of properties to return is determined by Graph. To ensure that a specific property is always returned, specify it (along with other desired properties) through the Select parameter. To select all properties, including those that are not returned by default, use the value '*'. Another use of Select is to limit the amount of data returned by the Graph to reduce network traffic; a request that by default returns 15 properties for each object in in a response when only two of those properties are needed could be specified with just those two properties. The resulting response would be far smaller, a savings particularly important if large result sets are returned.

.PARAMETER Search
The Search parameter allows specification of a content search string, i.e. a string to search a collection of written human language artifacts such as e-mail messages, documents, presentations, etc. By specifying the Search parameter, a request to the approprpiate could be issued to retrieve just documents or e-mail messages that contain a certain word or set of words for instance. Not all Graph URIs will support this parameter, and a particular resource may used a fix sort order and in general limit query-related parameters of the request when Search is used. See the documentation for the particular Graph resource to understand the behavior for queries with Search.

.PARAMETER Expand
The Expand parameter transforms results in a response from identifiers to the full content of the identified objects. If the goal is to retrieve the full content of the objects, the Expand parameter in this case reduces the number of rount trip calls to the Graph API -- all the objects are returned in a single call, rather than at least two calls, the first of which retrieves the identifiers, and the second of which queries for the content of the objects with those identifiers.

.PARAMETER OrderBy
The OrderBy parameter, which is also aliased as 'Sort', indicates that the results returned by the Graph API should be sorted using the key specified as the parameter value. If the Descending parameter is not specified when OrderBy is specified, the values should be sorted in ascending order.

.PARAMETER First
The First parameter specifies that Graph should only return a specific number of results in the HTTP response. If a request would normally result in 500 items, only the number specified by this parameter would be returned, i.e. the first N results according to the sort order that Graph defaults to or that is specified by this command through the OrderBy parameter. This parameter can be used in conjunction with the Skip parameter to page through results -- First is essentially the page size. By default, Get-GraphResource returns only the first 10 results.

.PARAMETER Skip
Skip specifies that Graph should not return the first N results in the HTTP response, i.e. that it should "discard" them. Graph determines the results to throw away after sorting them according to the order Graph defaults to or is specified by this command through the OrderBy parameter. This parameter can be used in conjunction with this First parameter to page through results -- if 20 results were already returned by one or more previous invocations of this command, then by specifying 20 for Skip in the next invocation, Graph will skip past the previously returned results and return the next "page" of results with a page size specified by First.

.PARAMETER Value
The Value parameter may be used when the result is itself metadata describing some data, such as an image. To obtain the actual data, rather than the metadata, specify Value. This is particularly useful for obtaining pictures for instance, e.g. me/photo.

.PARAMETER OutputFilePrefix
The OutputFilePrefix parameter specifies that rather than emitting the results to the PowerShell pipeline, each result should be written to a file name prefixed with the value of the OutputFilePrefix. The parameter value may be a path to a directory, or simply a name with no path separator. If there is more than one item in the result, the base file name for that result will end with a unique integer identifier within the result set. The file extension will be 'json' unless the result is of another content type, in which case the command will attempt to determine the extension from the content type returned in the HTTP response. If the content type cannot be determined, then the file extension will be '.dat'.

.PARAMETER Query
The Query parameter specifies the URI query parameter of the REST request made by the command to Graph. Because the URI's query parameter is affected by the Select, Filter, OrderBy, Search, and Expand options, the command's Query parameter may not be specified of any those parameters are specified. This parameter is most useful for advanced scenarios where the other command parameters are unable to express valid Graph protocol use of the URI query parameter.

.PARAMETER Count
The Count parameter specifies that the count of objects that would be returned by the given request URI should be returned as the output of the command rather than the objects themselves. Note that this will only be successful if the functionality to return a count is supported by the given given URI.

.PARAMETER Headers
Specifies optional HTTP headers to include in the request to Graph, which some parts of the Graph API may support. The headers must be specified as a HashTable, where each key in the hash table is the name of the header, and the value for that key is the value of the header.

.PARAMETER Version
Specifies the Graph API version that this command should target when making Graph requests. When not specified, the API version of the current Graph is used, which is v1.0 for the default Graph.

.PARAMETER ClientRequestId
Specifies the client request in the form of a GUID id that should be passed in the 'client-request-id' request header to the Graph API. This can be used to correlate verbose output regarding the request made by this command with request logs accessible to the operator of the Graph API service. Such correlation speeds up diagnosis of errors in service support scenarios. By default, this command automatically generates a request id and sends it in the header and also logs it in the command's verbose output, so this parameter does not need to be specified unless there is a particular reason to customize the id, such as using an id generated from another tool or API as a prerequisite for issuing this command that makes it easy to correlate the request from this command with that tool output for troubleshooting and log analysis. It is possible to prevent the generation of a client request id altogether by specifying the NoClientRequestId parameter.

.PARAMETER Connection
Specifies a Connection object returned by the New-GraphConnection command whose Graph endpoint will be accessed when making Graph requests with this command.

.PARAMETER Cloud
Specifies that for this command invocation, an access token with delegated permissions for the specified cloud must be acquired and then used to make the call. This will result in a sign-in UX.

.PARAMETER Permissions
Specifies that for this command invocation, an access token with the specified delegated permissions must be acquired and then used to make the call. This will result in a sign-in UX. This is useful when the permissions for the current Graph's Connection are not sufficient for the command to succeed. For more information on permissions, see documentation at https://developer.microsoft.com/en-us/graph/docs/concepts/permissions_reference. When this permission is not specified (default), the current Graph's existing access token is used for requests, and if no such token exists, the Graph's existng Connection object is used to acquire one.

.PARAMETER AbsoluteUri
By default the URIs specified by the Uri parameter are relative to the current Graph endpoint and API version (or the version specified by the Version parameter). If the AbsoluteUri parameter is specified, such URIs must be given as absolute URIs starting with the schema, e.g. instead of a URI such as 'me/messages', the Uri or TargetItem parameters must be https://graph.microsoft.com/v1.0/me/messages when the current Graph endpoint is graph.microsoft.com and the version is v1.0.

.PARAMETER RawContent
This parameter specifies that the command should return results exactly in the format of the HTTP response from the Graph endpoint, rather than the default behavior where the objects are deserialized into PowerShell objects. Graph returns objects as JSON except in cases where content types such as media are being requested, so use of this parameter will generally cause the command to return JSON output.

.PARAMETER ConsistencyLevel
This parameter specifies that Graph should process the request using a specific consistency level of 'Default', 'Session' or 'Eventual'. Requests processed with 'Session" consistency, originally the only supported consistency level for Graph API requests, these requests will make a best effort to ensure that the response reflects any changes made by previous Graph API requests made by the current caller. This allows applications to perform Graph API change operations such as creating a new resource such as a user or group followed by a request to retrieve information about that group or other information (e.g. the count of all users or groups) that would be influenced by the success of the earlier change. All operations are therefore consistent within the boundary of the "session." The disadvantage of session semantics is that the cost of supporting advanced queries such as counts or searches is very costly for the Graph API services that process the request, and so many advanced queries are not supported with session semantics. For this reason, a subset of services including those providing Azure Active Directory objects like user and group subsequently added the eventual consistency level. With eventual semantics, the API services that support this consistency level may temporarily violate session consistency with the benefit that advanced queries too costly to process with session semantics are now available. The results of those queries may not be fully up to date with the latest changes, but after some (typically short, a few minutes or less than an hour) time period a given set of changes will be reflected in the results for the same query repeated at a later time. The results of the API are not immediately consistent with changes in the session, but will be "eventually." For a given use case, a particular consistency level that prioritizes short-term accuracy higher or lower than complex query capability may be more appropriate; this parameter allows the caller of this command to make that choice. Specifying 'Default' for this parameter means the consistency level is determined by the API itself and API documentation should be consulted to determine if the API even supports a particular consistency level and therefore whether it is necessary to use this parameter. Note that if this parameter is not specified, the behavior is determined by the configuration of the Graph connection used for this request.

.PARAMETER AADGraph
This parameter specifies that instead of accessing Microsoft Graph, the command should make requests against Azure Active Directory Graph (AAD Graph). Note that most functionality of this command and other commands in the module is not compatible with AAD Graph; this parameter may be deprecated in the future.

.PARAMETER NoClientRequestId
This parameter suppresses the automatic generation and submission of the 'client-request-id' header in the request used for troubleshooting with service-side request logs. This parameter is included only to enable complete control over the protocol as there would be very few use cases for not sending the request id.

.PARAMETER NoRequest
When NoRequest is specified, instead of the command issuing a request to the Graph and returning the response content as command output, no request is issued and the request URI including query parameters rather than the content is emitted as output. This parameter is a useful way to understnd the request URI that would be generated for a given set of parameter options including search filters, and could be used to supply a URI to other Graph clients that could issue the actual request.

.PARAMETER NoSizeWarning
Specify NoSizeWarning to suppress the warning emitted by the command if 1000 or more items are retrieved by the command and no paging parameters, i.e. First or Skip parameters, were specified. The warning is intended to communicate that returning such a large result set may not have been intended. Use this parameter to ensure that automated scripts do not output the warning when intentionally used on large result sets to return all results.

.PARAMETER All
Specify the All parameter to retrieve all results. By default, requests to the Graph will return a limited number of results; this number varies by API. This parameter makes it easy to override that behavior and retrieve all possible results in a set with a single command as opposed to querying for the result size and then paging through results (and implementing error handling logic). The downside is that in the case of a large result set the command could be unresponsive for several minutes or even longer.

.OUTPUTS
The command returns the content of the HTTP response from the Graph endpoint. The result will depend on the documented response of GET requests for the Graph URI. The results are formatted as either deserialized PowerShell objects, or, if the RawContent parameter is also sp ecified, the literal content of the HTTP response. Because Graph responds to requests with JSON except in cases where content types such as images or other media are requested, use of the RawContent parameter will usually result in JSON output.

.EXAMPLE
Get-GraphResource me

    id                : 82f53da9-b996-4227-b268-c20564ceedf7
    officeLocation    : 7/3191
    @odata.context    : https://graph.microsoft.com/v1.0/$metadata#users/$entity
    surname           : Okorafor
    mail              : starchild@mothership.io
    jobTitle          : Professor
    givenName         : Starchild
    userPrincipalName : starchild@mothership.io
    businessPhones    : +1 (313) 360 3141
    displayName       : Starchild Okorafor

In this example a request is made to retrieve 'me', which stands for the user resource of the signed in user. The command is executed with only one parameter, the positional parameter Uri specified as 'me.' In addition to the output, a sign-in UX that may execute outside of the PowerShell session might be triggered if the user had not previously signed in.

The specification of the single parameter value 'me' in this case results in a request based on the current graph, which in this example was the endpoint https://graph.microsoft.com with API version 1.0. The request then is made against the URI https://graph.microsoft.com/v1.0/me.

.EXAMPLE
Get-GraphResource users -Filter "startsWith(displayName, 'Alan')" -Select userPrincipalName, displayName

    userPrincipalName         displayName
    -----------------         -----------
    alan1@tron.org            Alan Okoye
    ralan@tron.org            Alan Rich
    alanajackson@tron.org     Alana Jackson

This command issues a GET request to retrieve all users in the tenant whose displayName properties start with 'Alan' by specifying an OData query filter with the Filter parameter. The output of the command consists of just those users, and only includes the userPrinicpal and displayName properties in the output because those properties were specified with the Select parameter.

.EXAMPLE
Get-GraphResource me/messages -Search 'Michigan conference' -First 3 -Descending | Select-Object receivedDateTime, subject

receivedDateTime     subject
----------------     -------
2019-01-06T19:39:21Z Industry update - Jan 06, 2019
2019-01-04T18:29:58Z RE: Design+ Convention - Detroit, Michigan
2019-01-04T18:04:16Z Design+ Convention - Detroit, Michigan

This example issues a GET request to search the me/messages resource -- this resource represents a user's mailbox, i.e. all the user's mailbox. By specifying the Search parameter with the value 'Michigan', the command will make a request to Graph to search the user's mailbox for mail containing the search term 'Michigan conference' and return the results. The results are PowerShell objects with the fields specified in the documentation for the message resource, and so those fields may be addressed by PowerShell commands such as Select-Object and Where-Object for additional processing. Here the Select-Object command is used to filter the output fields to just 'receivedDateTime' and 'subject'.

Note that the behavior of search is resource-specific -- it happens to return the results in reverse chronological order of the 'receivedDateTime' property, and currently this cannot be overridden in the request to Graph. Behaviors peculiar to a given resource may only be understood by consulting that specific resource's documentation as found in the Graph API documentation: https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0.

.LINK
Invoke-GraphApiRequest
Connect-GraphApi
New-GraphConnection
ConvertTo-JSON
ConvertFrom-JSON
#>
function Get-GraphResource {
    [cmdletbinding(positionalbinding=$false, supportspaging=$true, supportsshouldprocess=$true, defaultparametersetname='MSGraphDefaultConnection')]
    param(
        [parameter(position=0, valuefrompipeline=$true, mandatory=$true)]
        [Uri] $Uri,

        [String] $Filter = $null,

        [parameter(position=1)]
        [Alias('Property')]
        [String[]] $Select = $null,

        [String] $Search = $null,

        [String[]] $Expand = $null,

        [Alias('Sort')]
        $OrderBy = $null,

        [Switch] $Descending,

        [Switch] $Value,

        $OutputFilePrefix,

        [String] $Query = $null,

        [switch] $Count,

        [HashTable] $Headers = $null,

        [String] $Version = $null,

        [Guid] $ClientRequestId,

        [parameter(parametersetname='ExistingConnection', mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [parameter(parametersetname='MSGraphNewConnection')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud,

        [parameter(parametersetname='MSGraphNewConnection')]
        [String[]] $Permissions = $null,

        [switch] $AbsoluteUri,

        [switch] $RawContent,

        [ValidateSet('Auto', 'Default', 'Session', 'Eventual')]
        [string] $ConsistencyLevel = 'Auto',

        [parameter(parametersetname='AADGraphNewConnection', mandatory=$true)]
        [switch] $AADGraph,

        [switch] $NoClientRequestId,

        [switch] $NoRequest,

        [switch] $NoSizeWarning,

        [switch] $All,

        [string] $ResultVariable = $null
    )

    begin {
        Enable-ScriptClassVerbosePreference
        $uris = @()

        $requestArguments = @{
            Query = $Query
            Filter = $Filter
            Search = $Search
            Select = $Select
            Expand = $Expand
            OrderBy = $OrderBy
            Descending = $Descending
            OutputFilePrefix = $OutputFilePrefix
            Value = $Value
            Count = $Count
            Version=$Version
            RawContent=$RawContent
            AbsoluteUri=$AbsoluteUri
            Headers=$Headers
            ConsistencyLevel=$ConsistencyLevel
            NoClientRequestId=$NoClientRequestId
            NoRequest=$NoRequest
            NoSizeWarning=$NoSizeWarning
            All=$All
            First=$pscmdlet.pagingparameters.first
            Skip=$pscmdlet.pagingparameters.skip
            IncludeTotalCount=$pscmdlet.pagingparameters.includetotalcount
        }

        if ( $Cloud ) {
            $requestArguments['Cloud'] = $Cloud
        }

        if ( $ClientRequestId ) {
            $requestArguments['ClientRequestId'] = $ClientRequestId
        }

        if ( $AADGraph.ispresent ) {
            $requestArguments['AADGraph'] = $AADGraph
        } elseif ($Permissions -ne $null) {
            $requestArguments['Permissions'] = $Permissions
        }

        if ( $Connection -ne $null ) {
            $requestArguments['Connection'] = $Connection
        }
    }

    process {
        $uris += $Uri
    }

    end {
        $localResult = $null

        $targetResultVariable = $::.ItemResultHelper |=> GetResultVariable $ResultVariable

        $uris | Invoke-GraphApiRequest @requestArguments | tee-object -variable localResult

        $targetResultVariable.value = $localResult
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Get-GraphResource Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))


