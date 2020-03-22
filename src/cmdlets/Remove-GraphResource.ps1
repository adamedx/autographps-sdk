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

. (import-script Invoke-GraphRequest)
. (import-script common/PermissionParameterCompleter)


<#
.SYNOPSIS
Deletes resources such as users, groups, drive items, or any other resource from the Graph.

.DESCRIPTION
The Remove-GraphItem command issues a DELETE request against the URI for one or more Graph objects; if successful, any such objects will be deleted from the Graph according to Graph REST API semantics.

.PARAMETER Uri
If this parameter is specified and the TargetItem parameter is not specified, this Uri specifies a URI relative to the current Graph's API version. For example, if the current Graph endpoint is https://graph.microsoft.com and the API version is v1.0, a Uri parameter of 'users/user1@domain.org' specifies that this command must delete the object at https://graph.microsoft.com/v1.0/users/user1@domain.org. Note that the version may be overridden by the Version parameter (see the documentation for Version below). If the AbsoluteUri parameter is specified, the Uri parameter must be an absolute Uri (see the AbsoluteUri documentation below). If TargetItem is specified, the Uri parameter is interpreted as the "parent" of the objects to delete -- see the documentation for the TargetItem parameter.

.PARAMETER TargetItem
TargetItem may be any object returned by Get-GraphResource or Invoke-GraphRequest. Remove-GraphItem will attempt to delete that object from the Graph. If both Uri and TargetItem are specified, the Uri and TargetItem parameters are intepreted together as the path of the item to delete, i.e. for each specified TargetItem, a relative URI consisting of the Uri parameter succeeded with a segment named with the TargetItem object's id property. The TargetItem parameter accepts one or more objects from the pipeline as objects to delete.

.PARAMETER ODataFilter
Specifies a filter using the OData specification to filter the items to be deleted from the Uri or TargetItem that is specified. This parameter may not be supported by all Graph Uris.

.PARAMETER Version
Specifies the Graph API version that this command should target when making Graph requests. When not specified, the API version of the current Graph is used, which is v1.0 for the default Graph.

.PARAMETER AbsoluteUri
By default the URIs specified by the Uri or TargetItem parameters are relative to the current Graph endpoint and API version (or the version specified by the Version parameter). If the AbsoluteUri parameter is specified, such URIs must be given as absolute URIs starting with the schema, e.g. instead of a URI such as 'me/messages', the Uri or TargetItem parameters must be https://graph.microsoft.com/v1.0/me/messages when the current Graph endpoint is graph.microsoft.com and the version is v1.0.

.PARAMETER Headers
Specifies optional HTTP headers to include in the request to Graph, which some parts of the Graph API may support. The headers must be specified as a HashTable, where each key in the hash table is the name of the header, and the value for that key is the value of the header.

.PARAMETER Connection
Specifies a Connection object returned by the New-GraphConnection command whose Graph endpoint will be accessed when making Graph requests with this command.

.PARAMETER Permissions
Specifies that for this command invocation, an access token with the specified delegated permissions must be acquired and then used to make the call. This will result in a sign-in UX. This is useful when the permissions for the current Graph's Connection are not sufficient for the command to succeed. For more information on permissions, see documentation at https://developer.microsoft.com/en-us/graph/docs/concepts/permissions_reference. When this permission is not specified (default), the current Graph's existing access token is used for requests, and if no such token exists, the Graph's existng Connection object is used to acquire one.

.PARAMETER Cloud
Specifies that for this command invocation, an access token with delegated permissions for the specified cloud must be acquired and then used to make the call. This will result in a sign-in UX.

.OUTPUTS
None.

.EXAMPLE
Remove-GraphItem groups/19f1afdc-376c-48b7-9125-54ac8e73e3a3

Confirm
Are you sure you want to perform this action?
Performing the operation "DELETE" on target "groups/19f1afdc-376c-48b7-9125-54ac8e73e3a3".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):Y

This example removes the group object with ID 19f1afdc-376c-48b7-9125-54ac8e73e3a3; it ultimately makes a DELETE request against the URI https://graph.microsoft.com/v1.0/groups/19f1afdc-376c-48b7-9125-54ac8e73e3a3. By default, the command asks for confirmation, so a prompt was displayed that requires the user to enter "A" or "Y" to proceed.

.EXAMPLE
Get-GraphResource user/26a733c2-e87f-4030-a128-a8968c6ee204 | Remove-GraphItem -Confirm:$false

This example pipes the output of Get-GraphResource for a user object to Remove-GraphItem. This results in the deletion of that user object. Because the Confirm option was specified with the value '$false", no confirmation prompt was displayed and the command proceeded to delete the target without further user interaction.

Get-GraphResource
Invoke-GraphRequest
New-GraphConnection
Connect-Graph
#>
function Remove-GraphItem {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='High', positionalbinding=$false)]
    param(
        [parameter(position=0)]
        [Uri] $Uri = $null,

        [parameter(parametersetname='FromObjects', valuefrompipeline=$true, mandatory=$true)]
        [parameter(parametersetname='FromObjectsExistingConnection', valuefrompipeline=$true, mandatory=$true)]
        $TargetItem,

        [String] $ODataFilter = $null,

        [String] $Version = $null,

        [switch] $AbsoluteUri,

        [HashTable] $Headers = $null,

        [parameter(parametersetname='FromUri')]
        [parameter(parametersetname='FromObjects')]
        [String[]] $Permissions = $null,

        [parameter(parametersetname='FromUri')]
        [parameter(parametersetname='FromObjects')]
        [validateset("Public", "ChinaCloud", "GermanyCloud", "USGovernmentCloud")]
        [string] $Cloud,

        [parameter(parametersetname='FromUriExistingConnection', mandatory=$true)]
        [parameter(parametersetname='FromObjectsExistingConnection', mandatory=$true)]
        [PSCustomObject] $Connection = $null
    )

    # Note that PowerShell requires us to use the begin / process / end structure here
    # in order to process more than one element of the pipeline via $TargetItem

    begin {}

    process {
        Enable-ScriptClassVerbosePreference

        $useFullyQualifiedUri = $AbsoluteUri.IsPresent

        $targetUri = if ( ! $targetItem ) {
            $Uri
        } else {
            $fullyQualifiedUri = $null
            $relativeId = $null

            # We check to see if this is an item that supports the __ItemContext interface -- we'll use that
            # if it's there to extract an absolute URI
            $content = $targetItem
            $itemContext = if ( $targetItem | gm __ItemContext -erroraction ignore ) {
                $targetItem.__ItemContext()
            } elseif ( ($targetItem | gm Content -erroraction ignore) -and ($targetItem.Content | gm __ItemContext -erroraction ignore) ) {
                $content = $targetItem.content
                $targetItem.Content.__ItemContext()
            }

            if ( $itemContext ) {
                $fullyQualifiedUri = $itemContext.RequestUri, $content.id -join '/'
                $useFullyQualifiedUri = $true
            } else {
                $relativeId = $targetItem.id
            }

            if ( $fullyQualifiedUri -and $Uri ) {
                throw [ArgumentException]::new("Uri option may not be specified with objects with known fully qualified paths")
            }

            if ( $fullyQualifiedUri ) {
                $fullyQualifiedUri
            } else {
                if ( $Uri ) {
                    $Uri.tostring().trimend('/'), $relativeId -join '/'
                } else {
                    $relativeId
                }
            }
        }

        $commonRequestArguments = @{
            ODataFilter = $ODataFilter
            Version = $Version
            Headers = $Headers
            Permissions = $Permissions
        }

        if ( $Cloud ) {
            $commonRequestArguments['Cloud'] = $Cloud
        }

        if ( $Connection ) {
            $commonRequestArguments['Connection'] = $Connection
        }

        write-verbose "DELETE requested for target URI '$targetUri'"
        if ( $pscmdlet.shouldprocess($targetUri, 'DELETE') ) {
            Invoke-GraphRequest $targetUri -Method DELETE @commonRequestArguments -AbsoluteUri:$useFullyQualifiedUri | out-null
        }
    }

    end {}
}

$::.ParameterCompleter |=> RegisterParameterCompleter Remove-GraphItem Permissions (new-so PermissionParameterCompleter ([PermissionCompletionType]::AnyPermission))
