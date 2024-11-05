# Copyright 2023, Adam Edwards
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

. (import-script ../common/GraphUtilities)
. (import-script ../common/GraphAccessDeniedException)
. (import-script common/QueryHelper)
. (import-script common/ItemResultHelper)
. (import-script ../REST/GraphRequest)
. (import-script ../REST/RequestLog)
. (import-script common/GraphOutputFile)
. (import-script common/PermissionParameterCompleter)

<#
.SYNOPSIS
Issues a REST HTTP request for a URI on a Graph endpoint

.DESCRIPTION
The Invoke-GraphApiRequest command issues a request to the Graph in the context of a given graph resource URI and Graph API version. To learn about the capabilities of the Graph API and the URIs that can be supplied to this command to access resources such as users, devices, documents, and relationships, see the Graph API documentation: https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0.

Invoke-GraphApiRequest obtains information from or alters objects in the Graph by making requests to a Graph endpoint such as https://graph.microsoft.com. To make the request, the command obtains a token for a Graph endpoint, issues the specified REST HTTP method request to the endpoint and returns the resulting response. The graph resource URI, HTTP method, HTTP Headers, and other Microsoft Graph-specific parameters of the request may all be specified by this command. Invoke-GraphApiRequest allows the issuing of any valid request to Microsoft Graph. As such, it can be used not just to read data from the Graph, but also to create new objects, invoke function and actions, update objects, and delete them.

The output of the command is typically the Content field of the response as deserialized objects returned by the API call; the format may be altered through command parameters such as RawContent to provide output in other formats such as the exact stream returned by Graph. If the HTTP status code of the response does not indicate success (i.e. it is not 2XX), an exception will be thrown.

Executing Invoke-GraphApiRequest will result in a sign-in UX if the Connection object of the current Graph or one explicitly supplied to the command through the Connection parameter does not already have a token associated with it. Once the token is acquired for the Connection object, it is used to issue the request to Graph. Subsequent invocations of this or any other commands in the module that use the same connection will silently use the previously acquired token without a UX, so there will be no additional sign-in UX.

The command also supports paging, since the Graph endpoint can return large result sets in the thousands of objects over HTTP protocol. By default this command returns only a limited number of results in the request depending on the particular request. The PowerShell standard paging parameters First and Skip can be used to control the number and overall subset of the results to return in a single invocation of Invoke-GraphApiRequest.

This command, like all commands in this module, uses the Connection object of the current graph by default to determine the Graph endpoint and credentials / permissions of an access token used to communicate to Graph. The current Graph's connection can be changed to use different credentials, permissions, or Graph endpoing by using the Connect-GraphApi command.

.PARAMETER Uri
This parameter is required -- it is the URI relative to the current Graph of the Graph resource on which to invoke the REST method. For example, if the goal was to invoke a method on the resource URI https://graph.microsoft.com/v1.0/users/user1@mydomain.org, assuming that the current Graph endpoint was http://graph.microsoft.com and the API version was 'v1.0', this parameter would be specified as 'users/user1@mydomain.org'. If the AbsoluteUri parameter is specified, the Uri parameter must be an absolute Uri (see the AbsoluteUri documentation below).

.PARAMETER Method
Specifies the method used for this request. If this parameter is not specified, the default value of 'GET' is used. Other acceptable values are
    - Delete
    - Get
    - Head
    - Merge
    - Options
    - Patch
    - Post
    - Put

.PARAMETER Body
The HTTP body of the request. The body typically specifies parameters for resource methods and actions, or parameters / specification of all or part of a resource to create or update. Many POST requests for example will require a Body as they often result in the creation of a new resource.

The body may be specified in one of two forms:

    - As PowerShell objects: since Graph documentation defines requests and responses including the body in JSON format, a PowerShell object may be specified here which are converted to JSON before sending the request to Graph. To see more about how to structure PowerShell objects to create the desired JSON, see PowerShell's ConvertTo-Json and ConvertFrom-Json commands. Providing input this way can be convenient if you're comfortable translating JSON to PowerShell or if you're building your Graph requests programatically since you can avoid the need to perform correct JSON formatting and escaping, and you can take advantage of type systems and other features of the language to improve correctness.

    - As a JSON string: A JSON string may be directly supplied here instead of PowerShell objects. This enables a one-to-one translation of the JSON-based documentation without the need to transfrom your understanding of the documentation into PowerShell representation and syntax. In general it enables direct re-use of samples from documentation or reproduction of Graph requests from other codebases and languages.

.PARAMETER Filter
Specifies an optional OData query filter to reduce the number of results returned to those satisfying the query's criteria -- this is used primarily for GET requests. Visit https://www.odata.org/ for details on the OData query syntax.

.PARAMETER Select
Specifies as an array the set of properties of the resource objects that the response to the request contain -- this is exactly the set of properties that will be returned as output of the command for each resource. When this parameter is not specified (default), the set of properties to return is determined by Graph. To ensure that a specific property is always returned, specify it (along with other desired properties) through the Select parameter. To select all properties, including those that are not returned by default, use the value '*'. Another use of Select is to limit the amount of data returned by the Graph to reduce network traffic; a request that by default returns 15 properties for each object in in a response when only two of those properties are needed could be specified with just those two properties. The resulting response would be far smaller, a savings particularly important if large result sets are returned.

.PARAMETER Search
The Search parameter allows specification of a content search string, i.e. a string to search a collection of written human language artifacts such as e-mail messages, documents, presentations, etc. By specifying the Search parameter, a request to the approprpiate could be issued to retrieve just documents or e-mail messages that contain a certain word or set of words for instance. Not all Graph URIs will support this parameter, and a particular resource may used a fix sort order and in general limit query-related parameters of the request when Search is used. See the documentation for the particular Graph resource to understand the behavior for queries with Search.

.PARAMETER Expand
The Expand parameter transforms results in a response from identifiers to the full content of the identified objects. If the goal is to retrieve the full content of the objects, the Expand parameter in this case reduces the number of rount trip calls to the Graph API -- all the objects are returned in a single call, rather than at least two calls, the first of which retrieves the identifiers, and the second of which queries for the content of the objects with those identifiers.

.PARAMETER OrderBy
The OrderBy parameter, which is also aliased as 'Sort', indicates that the results returned by the Graph API should be sorted using the key specified as the parameter value. If the Descending parameter is not specified when OrderBy is specified, the values should be sorted in ascending order.

.PARAMETER First
The First parameter specifies that Graph should only return a specific number of results in the HTTP response. If a request would normally result in 500 items, only the number specified by this parameter would be returned, i.e. the first N results according to the sort order that Graph defaults to or that is specified by this command through the OrderBy parameter.

.PARAMETER Skip
Skip specifies that Graph should not return the first N results in the HTTP response, i.e. that it should "discard" them. Graph determines the results to throw away after sorting them according to the order Graph defaults to or is specified by this command through the OrderBy parameter. This parameter can be used in conjunction with this First parameter to page through results -- if 20 results were already returned by one or more previous invocations of this command, then by specifying 20 for Skip in the next invocation, Graph will skip past the previously returned results and return the next "page" of results with a page size specified by First.

.PARAMETER Value
The Value parameter may be used when the result is itself metadata describing some data, such as an image. To obtain the actual data, rather than the metadata, specify Value. This is particularly useful for obtaining pictures for instance, e.g. me/photo.

.PARAMETER Delta
The Delta parameter specifies that this command should issue a request to get incremental changes for the specified URI. For example, if the caller needs information about new security groups as they are created, they could use this command to periodically issue a query with the URI /groups which would return all currently existing groups, and compare this list to the result from a previous response to the same query. Such an approach is expensive, particularly for tenants with a large number of security groups. To avoid this, use the Delta parameter in the first command invocation. The response will conform to that used when the AsResponseDetail parameter is specified, and will include not just the results in the Content field, but also the fields DeltaToken and DeltaUri. The DeltaUri field can be used any subsequent request to Invoke-GraphApiRequest -- the response to such a request will include only the data that have changed between the time all data was retrieved from the initial request with Delta specified and now. Because these responses include only the changes, this approach to obtaining the changes to security groups is dramatically more efficient.

.PARAMETER DeltaToken
This parameter provides a way to request only the incremental changes that would be returned compared to a previous request issued by this command using the Delta parameter. Its value can be obtained from the result of that initial request in the DeltaToken field of its response. When DeltaToken is specified, the URI parameter should simply be the same URI specified in the initial request that used the Delta parameter. Alternatively, the DeltaUri field can be specified as the URI for subsequent requests and the DeltaToken field should not be specified in that case.

.PARAMETER AsResponseDetail
By default, unless the NoPaging, Delta, or DeltaToken parameters are specified, the ouptut of this command is simply the collection of objects returned from the Graph. Such default output is missing some additional information returned by Graph including the OData context or the next URI to use for incomplete results. The additional output which may include additional type information about the content can be useful for custom processing of incremental delta requests, customized result paging and indication of partial results, and interpretation of the content. The fields of this output are as follows:
  * Content: contains the equivalent of the output emitted when the AsResponseDetail format is not used.
  * ContextUri (optional): contains the OData context URI
  * DeltaUri (optional): a URI that can be used with this command to get only incremental changes from this response. Only returned once all data are processed for a request issued with the Delta parameter
  * AbsoluteDeltaUri (optional): Same as DeltaUri, but uses an absolute URI format that can only be used as the Invoke-GraphApiRequest Uri parameter when the AbsoluteUri parameter is specified
  * DeltaToken (optional): a state token that can be used with this command to get only incremental changes from this response, and returned only when DeltaUri would be returned
  * NextUri (optional): a URI used to retrieve the next page of results, empty if there are no next results. This can be used to do custom paging, or to indicate that there are more results left to retrieve.
  * AbsoluteNextUri (optional): Same as NextUri, but uses an absolute URI format that can only be as the Invoke-GraphApiRequest Uri parameter when the AbsoluteUri parameter is specified
  * Responses: This contains the actual HTTP protocol responses from Graph along with additional details about each response. There will always be at least one response if the command is successful, and more than one of Invoke-GraphApiRequest makes additional requests as part of paging through partial responses returned by Graph

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
Specifies that the request should target a specific cloud -- this means the command will use the Graph API endpoint associated with that cloud as well as that cloud's sign-in endpoint. If this parameter is not specified, the Azure Public cloud endpoints are used. Other supported clouds include the Azure China cloud and Azure Germany clouds.

.PARAMETER Permissions
Specifies that for this command invocation, an access token with the specified delegated permissions must be acquired and then used to make the call. This will result in a sign-in UX. This is useful when the permissions for the current Graph's Connection are not sufficient for the command to succeed. For more information on permissions, see documentation at https://developer.microsoft.com/en-us/graph/docs/concepts/permissions_reference. When this permission is not specified (default), the current Graph's existing access token is used for requests, and if no such token exists, the Graph's existng Connection object is used to acquire one.

.PARAMETER AbsoluteUri
By default the URIs specified by the Uri parameter are relative to the current Graph endpoint and API version (or the version specified by the Version parameter). If the AbsoluteUri parameter is specified, such URIs must be given as absolute URIs starting with the schema, e.g. instead of a URI such as 'me/messages', the Uri or TargetItem parameters must be https://graph.microsoft.com/v1.0/me/messages when the current Graph endpoint is graph.microsoft.com and the version is v1.0.

.PARAMETER RawContent
This parameter specifies that the command should return results exactly in the format of the HTTP response from the Graph endpoint, rather than the default behavior where the objects are deserialized into PowerShell objects. Graph returns objects as JSON except in cases where content types such as media are being requested, so use of this parameter will generally cause the command to return JSON output.

.PARAMETER ConsistencyLevel
This parameter specifies that Graph should process the request using a specific consistency level of 'Auto', 'Default', 'Session' or 'Eventual'. Requests processed with 'Session" consistency, originally the only supported consistency level for Graph API requests, these requests will make a best effort to ensure that the response reflects any changes made by previous Graph API requests made by the current caller. This allows applications to perform Graph API change operations such as creating a new resource such as a user or group followed by a request to retrieve information about that group or other information (e.g. the count of all users or groups) that would be influenced by the success of the earlier change. All operations are therefore consistent within the boundary of the "session." The disadvantage of session semantics is that the cost of supporting advanced queries such as counts or searches is very costly for the Graph API services that process the request, and so many advanced queries are not supported with session semantics. For this reason, a subset of services including those providing Entra ID objects like user and group subsequently added the eventual consistency level. With eventual semantics, the API services that support this consistency level may temporarily violate session consistency with the benefit that advanced queries too costly to process with session semantics are now available. The results of those queries may not be fully up to date with the latest changes, but after some (typically short, a few minutes or less than an hour) time period a given set of changes will be reflected in the results for the same query repeated at a later time. The results of the API are not immediately consistent with changes in the session, but will be "eventually." For a given use case, a particular consistency level that prioritizes short-term accuracy higher or lower than complex query capability may be more appropriate; this parameter allows the caller of this command to make that choice. Specifying 'Default' for this parameter means the consistency level is determined by the API itself and API documentation should be consulted to determine if the API even supports a particular consistency level and therefore whether it is necessary to use this parameter. Note that if this parameter has the default value of 'Auto', the behavior is determined by the configuration of the Graph connection used for this request.

.PARAMETER PageSizePreference
This parameter directs the command to issue requests that instruct the Graph API to return a specific maximum number of items in each page of results. This parameter will only take effect if Graph honors it for the particular request.

.PARAMETER NoPaging
The NoPaging pararameter that the command must make only one request to the Graph API -- it should not make additional requests to "page" through the results even if additional results are indicated by the response.

.PARAMETER NoClientRequestId
This parameter suppresses the automatic generation and submission of the 'client-request-id' header in the request used for troubleshooting with service-side request logs. This parameter is included only to enable complete control over the protocol as there would be very few use cases for not sending the request id.

.PARAMETER NoRequest
When NoRequest is specified, instead of the command issuing a request to the Graph and returning the response content as command output, no request is issued and the request URI including query parameters rather than the content is emitted as output. This parameter is a useful way to understnd the request URI that would be generated for a given set of parameter options including search filters, and could be used to supply a URI to other Graph clients that could issue the actual request.

.PARAMETER NoSizeWarning
Specify NoSizeWarning to suppress the warning emitted by the command if 1000 or more items are retrieved by the command and no paging parameters, i.e. First or Skip parameters, were specified. The warning is intended to communicate that returning such a large result set may not have been intended. Use this parameter to ensure that automated scripts do not output the warning when intentionally used on large result sets to return all results.

.PARAMETER All
Specify the All parameter to retrieve all results. By default, requests to the Graph will return a limited number of results; this number varies by API. This parameter makes it easy to override that behavior and retrieve all possible results in a set with a single command as opposed to querying for the result size and then paging through results (and implementing error handling logic). The downside is that in the case of a large result set the command could be unresponsive for several minutes or even longer.

.OUTPUTS
TThe command returns the content of the HTTP response from the Graph endpoint. The result will depend on the documented response for the specified HTTP method parameter for the Graph URI. The results are formatted as either deserialized PowerShell objects, or, if the RawContent parameter is also specified, the literal content of the HTTP response. Because Graph responds to requests with JSON except in cases where content types such as images or other media are requested, use of the RawContent parameter will usually result in JSON output.

.EXAMPLE
Invoke-GraphApiRequest me

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
Invoke-GraphApiRequest users -Filter "startsWith(displayName, 'Alan')" -Select userPrincipalName, displayName

    userPrincipalName         displayName
    -----------------         -----------
    alan1@tron.org            Alan Okoye
    ralan@tron.org            Alan Rich
    alanajackson@tron.org     Alana Jackson

This command issues a GET request to retrieve all users in the tenant whose displayName properties start with 'Alan' by specifying an OData query filter with the Filter parameter. The output of the command consists of just those users, and only includes the userPrinicpal and displayName properties in the output because those properties were specified with the Select parameter.

.EXAMPLE
Invoke-GraphApiRequest me/messages -Search 'Michigan conference' -First 3 -Descending | Select-Object receivedDateTime, subject

receivedDateTime     subject
----------------     -------
2019-01-06T19:39:21Z Industry update - Jan 06, 2019
2019-01-04T18:29:58Z RE: Design+ Convention - Detroit, Michigan
2019-01-04T18:04:16Z Design+ Convention - Detroit, Michigan

This example issues a GET request to search the me/messages resource -- this resource represents a user's mailbox, i.e. all the user's mailbox. By specifying the Search parameter with the value 'Michigan', the command will make a request to Graph to search the user's mailbox for mail containing the search term 'Michigan conference' and return the results. The results are PowerShell objects with the fields specified in the documentation for the message resource, and so those fields may be addressed by PowerShell commands such as Select-Object and Where-Object for additional processing. Here the Select-Object command is used to filter the output fields to just 'receivedDateTime' and 'subject'.

Note that the behavior of search is resource-specific -- it happens to return the results in reverse chronological order of the 'receivedDateTime' property, and currently this cannot be overridden in the request to Graph. Behaviors peculiar to a given resource may only be understood by consulting that specific resource's documentation as found in the Graph API documentation: https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0.

.EXAMPLE
$credential = (Get-Credential -Message 'New user password' -Username 'katjo').getnetworkcredential()
PS C:\> Invoke-GraphApiRequest users POST @{displayName='Katherine Johnson';passwordProfile=@{password=$credential.password};mailNickName=$credential.username;accountEnabled=$true;userPrincipalName="$($credential.username)@nasa.org";jobTitle='Rocket Scientist'}

id                : 16ab7cf8-e7ef-4dde-a282-adcbf183a12a
@odata.context    : https://graph.microsoft.com/v1.0/$metadata#users/
jobTitle          : Rocket Scientist
userPrincipalName : katjo@nasa.org
displayName       : Katherine Johnson

This example uses Graph to create a user. First it uses the PowerShell command Get-Credential to obtain a password for the user and store it in the variable $credential. Next, the Invoke-GraphApiRequest command is specified with the resource 'users' and a method POST -- this means that a POST request will be issued ot the resource. For this resource, Graph interprets a POST as a request to create the user specified by the body, which is the last parameter of the command.

The body is given a PowerShell object that conforms to the documented structure given in the documentation for the users resource. Because Graph requires the body to be specified as JSON, the PowerShell object is serialized into JSON before sending it to Graph. To understand how PowerShell objects are serialized and deserialized to and from JSON, see the standard ConvertTo-Json and ConvertFrom-Json commands.

.EXAMPLE
Invoke-GraphApiRequest groups POST @{mailNickName='AccessGroup6';displayName='Group 6 Access';mailEnabled=$false;securityEnabled=$true}

id                           : d90733b4-8aba-40e0-86ac-8eb0ede2b799
displayName                  : Group 6 Access
createdDateTime              : 2019-02-03T05:02:26Z
securityEnabled              : True
@odata.context               : https://graph.microsoft.com/v1.0/$metadata#groups/$entity
renewedDateTime              : 2019-02-03T05:02:26Z
visibility                   :
mailEnabled                  : False
mailNickname                 : AccessGroup6


This example creates a group via POST, and passes the body as a PowerShell hashtable which will be converted to JSON when communicating with Graph.

.EXAMPLE
Invoke-GraphApiRequest groups POST '
{
     "mailNickName":    "AccessGroup7",
     "displayName":     "Group 7 Access",
     "mailEnabled":     false,
     "securityEnabled": true,
     "visibility":      "Private"
}'

id                           : c4cc09b2-fc4a-42ec-81f5-1d4894a702bc
displayName                  : Group 7 Access
createdDateTime              : 2019-02-03T05:02:26Z
securityEnabled              : True
@odata.context               : https://graph.microsoft.com/v1.0/$metadata#groups/$entity
renewedDateTime              : 2019-02-03T05:02:26Z
visibility                   : Private
mailEnabled                  : False
mailNickname                 : AccessGroup7

In this example a group is created and the body that defines the group is specified directly in JSON rather than PowerShell objects.

.LINK
Get-GraphResource
Connect-GraphApi
New-GraphConnection
ConvertTo-JSON
ConvertFrom-JSON
#>
function Invoke-GraphApiRequest {
    [cmdletbinding(positionalbinding=$false, supportspaging=$true, supportsshouldprocess=$true, defaultparametersetname='MSGraphDefaultConnection')]
    param(
        [parameter(position=0, valuefrompipeline=$true, mandatory=$true)]
        [Uri] $Uri,

        [parameter(position=1)]
        [ValidateSet('DELETE', 'GET', 'HEAD', 'MERGE', 'OPTIONS', 'PATCH', 'POST', 'PUT', 'TRACE')]
        [String] $Method = 'GET',

        [parameter(position=2)]
        $Body = $null,

        [String] $Filter = $null,

        [Alias('Property')]
        [String[]] $Select = $null,

        [String] $Search = $null,

        [String[]] $Expand = $null,

        [Alias('Sort')]
        $OrderBy = $null,

        [Switch] $Descending,

        [Switch] $Value,

        [Switch] $Delta,

        [string] $DeltaToken,

        [Switch] $AsResponseDetail,

        [String] $OutputFilePrefix = $null,

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

        [int32] $PageSizePreference,

        [switch] $NoPaging,

        [switch] $NoClientRequestId,

        [switch] $NoRequest,

        [switch] $NoSizeWarning,

        [switch] $All
    )

    begin {
        Enable-ScriptClassVerbosePreference

        if ( $All.IsPresent -and $NoPaging.IsPresent ) {
            throw [ArgumentException]::new("The 'All' parameter may not be specified with the 'NoPaging' parameter is specified")
        }

        if ( $Count.IsPresent -and $Value.IsPresent ) {
            throw [ArgumentException]::new("The'Count' parameter may not be specified when the 'Value' parameter is specified")
        }

        if ( $OutputFilePrefix ) {
            $outputFileParent = split-path $OutputFilePrefix -parent
            if ( $outputFileParent ) {
                if ( ! (test-path $outputFileParent) ) {
                    throw "Specified OutputFilePrefix parameter value '$OutputFilePrefix' includes non-existent directories"
                }
            }
        }

        if ( $Value.IsPresent -and $Method -ne 'GET' ) {
            throw [ArgumentException]::new("The 'Value' parameter may not be specified when the 'Method' parameter has the value 'GET'")
        }

        $useRawContent = $RawContent.IsPresent -or $Value.IsPresent -or $Count.IsPresent

        if ( $Query ) {
            if ( $Search -or $Filter -or $Select -or $OrderBy ) {
                throw [ArgumentException]::new("'Filter', 'Search', 'OrderBy', and 'Select' parameters may not specified when the 'Query' parameter is specified")
            }
        }

        if ( $Descending.IsPresent -and ! $OrderBy ) {
            throw [ArgumentException]::new("'Descending' option was specified without 'OrderBy'")
        }

        if ( $Delta.IsPresent -and $DeltaToken ) {
            throw [ArgumentException]::new("Only one of the Delta and DeltaToken parameters may be specified")
        }

        $orderQuery = if ( $OrderBy ) {
            try {
                $::.QueryHelper |=> GetOrderQueryFromOrderByParameters $OrderBy $Descending.IsPresent
            } catch {
                throw
            }
        }

        $defaultVersion = $null

        $MSGraphScopes = if ( $Permissions -ne $null ) {
            if ( $Connection -ne $null ) {
                throw "Permissions may not be specified via -Permissions if an existing connection is supplied with -Connection"
            }
            $Permissions
        }

        $requestQuery = if ( $Query ) {
            @($Query)
        } else {
            $queryParameters = [string[]] @()

            if ( $Expand ) {
                $queryParameters += @('$expand={0}') -f ($Expand -join ',')
            }

            if ( $Select ) {
                $queryParameters += @('$select={0}') -f ($Select -join ',')
            }

            if ( $Search ) {
                $queryParameters += @('$search="{0}"' -f $Search)
            }

            if ( $Filter ) {
                $queryParameters += @('$filter={0}' -f $Filter)
            }

            if ( $orderQuery ) {
                $queryParameters += @('$orderBy={0}' -f $orderQuery)
            }

            if ( $queryParameters.length -gt 0 ) {
                $queryParameters
            }
        }

        if ( $pscmdlet.pagingparameters.includetotalcount.ispresent -eq $true ) {
            write-verbose 'Including the total count of results'
            $requestQuery += '$count'
        }

        $defaultVersion = 'GraphContext' |::> GetDefaultVersion

        $currentContext = $null

        $graphConnection = if ( $Connection -eq $null ) {
            'GraphContext' |::> GetConnection $null $null $cloud $Permissions
        } else {
            $Connection
        }

        $firstIndex = if ( $pscmdlet.pagingparameters.Skip -ne $null -and $pscmdlet.pagingparameters.skip -ne 0 ) {
            write-verbose "Skipping the first '$($pscmdlet.pagingparameters.skip)' parameters"
            $pscmdlet.pagingparameters.Skip
        }

        $maxReturnedResults = $null
        $maxResultCount = if ( ! $All.IsPresent ) { 100 }

        if ( ! $All.IsPresent -and ( $pscmdlet.pagingparameters.first -ne $null -and $pscmdlet.pagingparameters.first -lt [Uint64]::MaxValue ) ) {
            $maxResultCount = $pscmdlet.pagingparameters.first
            $maxReturnedResults = $pscmdlet.pagingparameters.first
        }

        $skipCount = $firstIndex
        $results = @()

        $deltaLink = $null
        $nextLink = $null
        $contextUri = $null

        $responses = @()
    }

    process {
        if ( ! $AbsoluteUri.IsPresent -and $Uri.IsAbsoluteUri -and ! (! $Uri.Host) ) {
            throw "An absolute URI was specified -- specify a URI relative to the graph host and version, or specify -AbsoluteUri"
        }

        $uriInfo = if ( $AbsoluteUri.ispresent ) {
            write-verbose "Caller specified AbsoluteUri -- interpreting uri as absolute"
            $specificContext = new-so GraphContext $graphConnection $version 'local'
            $info = $::.GraphUtilities |=> ParseGraphUri $Uri $specificContext
            write-verbose "Absolute uri parsed as relative '$($info.GraphRelativeUri)' and version $($info.GraphVersion)"
            if ( ! $info.IsAbsolute ) {
                throw "Absolute Uri was specified, but given Uri was not absolute: '$($Uri)'"
            }
            if ( ! $info.IsContextCompatible ) {
                throw "The version '$($info.Graphversion)' and connection endpoint '$($specificcontext.Connection.GraphEndpoint.Graph)' is not compatible with the uri '$Uri'"
            }
            $info
        } else {
            if ( ($::.GraphContext |=> GetCurrent).location ) {
                $info = $::.GraphUtilities |=> ParseGraphRelativeLocation $Uri
                @{
                    GraphRelativeUri = $info.GraphRelativeUri
                    GraphVersion = $info.Context.version
                }
            } else {
                @{
                    GraphRelativeUri = $Uri
                    GraphVersion = ($::.GraphContext |=> GetCurrent).version
                }
            }
        }

        $apiVersion = if ( $Version -ne $null -and $version.length -ne 0 ) {
            write-verbose "Using version specified by caller: '$Version'"
            $Version
        } elseif ( $uriInfo -and $uriInfo.GraphVersion -and $uriInfo ) {
            write-verbose "Using version from implied relative uri: '$($uriInfo.GraphVersion)'"
            $uriInfo.GraphVersion
        } else {
            if ( $currentContext ) {
                write-verbose "Using context Graph version '$($currentContext.Version)'"
                $currentContext.Version
            } else {
                write-verbose "Using default Graph version '$defaultVersion'"
                $defaultVersion
            }
        }

        $tenantQualifiedVersionSegment = $apiVersion

        $inputUriRelative = if ( ! $uriInfo ) {
            $Uri
        } else {
            $uriInfo.GraphRelativeUri
        }

        $contextUri = if ( ($::.GraphContext |=> GetCurrent).location ) {
            $::.GraphUtilities |=> ToGraphRelativeUri $inputUriRelative
        } else {
            $inputUriRelative
        }

        if ( $Value.IsPresent ) {
            $contextUri = $contextUri, '$value' -join '/'
        } elseif ( $Count.IsPresent ) {
            $contextUri = $contextUri, '$count' -join '/'
        }

        $graphRelativeUri = $::.GraphUtilities |=> JoinRelativeUri $tenantQualifiedVersionSegment $contextUri

        $countError = $false
        $optionalCountResult = $null
        $pageCount = 0
        $contentTypeData = $null

        $logger = $::.RequestLog |=> GetDefault

        $startDelta = $Delta.IsPresent
        $initialDeltaToken = $DeltaToken

        $isDeltaUri = ( $::.GraphUtilities |=> IsDeltaUri $Uri )

        $isDeltaRequest = $Delta.IsPresent -or $DeltaToken -or $isDeltaUri

        $skipSizeWarning = $Value.IsPresent -or $NoSizeWarning.IsPresent -or $pscmdlet.pagingparameters.Skip -or $NoPaging.IsPresent -or (
            ( $pscmdlet.pagingparameters.First -ne $null ) -and
            ( $pscmdlet.pagingparameters.First -gt 0 ) -and
            ( $pscmdlet.pagingparameters.First -lt [int32]::MaxValue )
        )

        while ( $graphRelativeUri -ne $null -and ($graphRelativeUri.tostring().length -gt 0) -and ($maxResultCount -eq $null -or $results.length -lt $maxResultCount) ) {
            $graphResponse = if ( $graphConnection.status -ne ([GraphConnectionStatus]::Offline) ) {
                $currentPageQuery = if ( $pageCount -eq 0 ) {
                    $requestQuery
                } else {
                    $null
                }

                $request = new-so GraphRequest $graphConnection $graphRelativeUri $Method $Headers $currentPageQuery $ClientRequestId $NoClientRequestId.IsPresent $NoRequest.IsPresent ( $startDelta -and ! $isDeltaUri ) $initialDeltaToken $PageSizePreference $ConsistencyLevel

                if ( ! $request ) {
                    throw "Unable to issue REST request"
                }

                $request |=> SetBody $Body
                try {
                    $request |=> Invoke $skipCount $PageSizePreference -logger $logger
                } catch [System.Net.WebException] {
                    $statusCode = if ( $_.exception.response | gm statuscode -erroraction ignore ) {
                        $_.exception.response.statuscode
                    }

                    if ( $statusCode -eq 'Unauthorized' -or $statusCode -eq 'Forbidden' ) {
                        throw [GraphAccessDeniedException]::new($_.exception)
                    }

                    # Note that there may be other errors, such as 'BadRequest' that deserve a warning rather than failure,
                    # so we should consider adding others if the cases can be narrowed sufficiently to avoid other
                    # undesirable side effects of continuing on an error. An even better workaround may be command-completion,
                    # which would (and should!) be scoped to purely local operations -- this would give visibility as to
                    # the next segments without a request to Graph that could fail.
                    throw
                }
            }

            $skipCount = $null

            $content = if ( $graphResponse -and $graphResponse.Entities -ne $null ) {
                if ( ! $contentTypeData ) {
                    $contentTypeData = $graphResponse.RestResponse.ContentTypeData
                }

                $nextLink = $graphResponse.NextLink
                $deltaLink = $graphResponse.DeltaLink
                if ( ! $contextUri ) {
                    $contextUri = $graphResponse.ODataContext
                }

                $graphRelativeUri = if ( ! $NoPaging.IsPresent ) {
                    $nextLink
                }

                $startDelta = $false
                $initialDeltaToken = $null

                if ( ! $useRawContent ) {
                    $entities = if ( $graphResponse.entities -is [Object[]] -and $graphResponse.entities.length -eq 1 ) {
                        @([PSCustomObject] $graphResponse.entities)
                    } elseif ($graphResponse.entities -is [HashTable]) {
                        if ( $graphResponse.HasNonEmptyValueData ) {
                            @([PSCustomObject] $graphResponse.Entities)
                        }
                    } else {
                        $graphResponse.Entities
                    }

                    if ( $pscmdlet.pagingparameters.includetotalcount.ispresent -eq $true -and $results.length -eq 0 ) {
                        try {
                            $optionalCountResult = $graphResponse.RestResponse.value.count
                        } catch {
                            $countError = $true
                        }
                    }
                    $entities
                } else {
                    $graphResponse |=> Content
                }
            } else {
                $graphRelativeUri = $null
                if ( $graphResponse ) {
                    $graphResponse |=> Content
                }
            }

            if ( $graphResponse -and ( ! $useRawContent ) ) {
                # Add __ItemContext to decorate the object with its source uri.
                # Do this as a script method to prevent deserialization

                $responseItemContext = $::.ItemResultHelper |=> GetItemContext $request.Uri $graphResponse.ODataContext

                $content | foreach {
                    $sourceContext = if ( $_ | gm '@odata.context' -erroraction ignore ) {
                        $::.ItemResultHelper |=> GetItemContext $request.Uri $_.'@odata.context'
                    } else {
                        $responseItemContext
                    }
                    $::.ItemResultHelper |=> SetItemContext $_ $sourceContext
                }

                $responses += $graphResponse
            }

            $results += $content

            $pageCount++

            if ( $results.length -gt 1000 -and ! $skipSizeWarning ) {
                write-warning "Graph is returning large result size of 1000 items or more; consider using filters or paging parameters to limit the amount of data returned."
                $skipSizeWarning = $true
            }
        }

        if ($pscmdlet.pagingparameters.includetotalcount.ispresent -eq $true) {
            $accuracy = [double] 1.0
            $count = if ( $optionalCountResult -eq $null ) {
                $accuracy = [double] .1
                $results.length
            } else {
                if ( $countError ) {
                    $accuracy = [double] .5
                }
                $optionalCountResult
            }

            $PSCmdlet.PagingParameters.NewTotalCount($count,  $accuracy)
        }
    }

    end {
        $filteredResults = $results

        $filteredResults = if ( $maxReturnedResults ) {
            $filteredResults | select -first $maxReturnedResults
        } else {
            $filteredResults
        }

        if ( ! $OutputFilePrefix ) {
            if ( ! $useRawContent -and ( $AsResponseDetail.IsPresent -or $isDeltaRequest -or $NoPaging.IsPresent ) ) {
                $::.ItemResultHelper |=> GetResponseDetail $filteredResults $contextUri $nextLink $deltaLink $responses
            } else {
                $filteredResults
            }
        } else {
            $enumerableResults = if ( ! $contentTypeData['charset'] ) {
                $byteResults = @($null, $null)
                $byteResults[0] = $filteredResults
                $byteResults
            } else {
                $filteredResults
            }

            $resultIndex = 0
            $enumerableResults | foreach {
                if ( $_ ) {
                    $baseName = $OutputFilePrefix
                    if ( $resultIndex -gt 0 ) {
                        $baseName += $resultIndex.tostring()
                    }
                    $resultIndex++
                    $outputFile = new-so GraphOutputFile $baseName $_ $contentTypeData
                    $outputFile |=> Save
                }
            }
        }
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Invoke-GraphApiRequest Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::DelegatedPermission))

