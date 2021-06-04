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

. (import-script Get-GraphLog)

<#
.SYNOPSIS
Retrieves the error response from Graph for the last failed REST call invoked by one of this module's commands.

.DESCRIPTION
When a command such as Get-GraphResource or Invoke-GraphApiRequest fails due to an error response from Graph, i.e. a status code other than 2xx is returned, this command outputs the full response stream from the failed call to assist in troubleshooting the failure. This output may include details such as error messages on the specifics of an incorrectly specified parameter or unsupported scenario.

.OUTPUTS
If the last Graph request from this module was successful, this command returns no output. If there was a failure, the result of this command is an object that contains a System.Net.HttpWebResponse object, and also important fields obtained from that object such as the response headers, the time at which the error occurred, and the deserialized response.

.EXAMPLE
Get-GraphError

RequestTimestamp        : 6/1/2021 09:21:15 PM -07:00
Status                  : 400
ErrorResponse           : {"error":{"code":"Request_BadRequest","message":"A value is required for property
                          'securityEnabled' of resource 'Group'.","innerError":{"date":"2021-06-04T12:39:23","request-i
                          ":"b9a624e0-8b97-4888-81f7-23976c0488d0","client-request-id":"a17ecfec-99c9-4578-a1db-a194a6
                          b6abbf"}}}
Method                  : POST
Uri                     : https://graph.microsoft.com/v1.0/groups
RequestBodySize         : 0
ClientElapsedTime       : 00:00:00.1098080
RequestHeaders          : {Authorization, Content-Type, client-request-id, ConsistencyLevel}
ClientRequestId         : b01e4465-3543-4eda-abd8-b26d1ffb9a82
AppId                   : 6afd9af6-a06a-4522-b06b-59142f41306d
TenantId                : a764b39d-c66a-4166-b1ef-5cdfb5259d3e
serUpn                  : cleo@hotline.org
UserObjectId            : 95230052-9ee3-3ee3-0001-fa3829ec1399
AuthType                : Delegated
ResourceUri             : groups
Query                   :
ResponseTimestamp       : 6/1/2021 09:21:17 PM -07:00
ResponseClientRequestId : b01e4465-3543-4eda-abd8-b26d1ffb9a82
ResponseHeaders         : {x-ms-ags-diagnostic, Transfer-Encoding, request-id, Content-Type...}

The Get-GraphError command was invoked after the following Graph command failed:

    Invoke-GraphApiRequest -Method POST groups -Body @{mailNickName='datasec';displayName='Data Security Team';mailEnabled=$false}

Invoke-GraphApiRequest was invoked to POST to the 'groups' relative URI of https://graph.microsoft.com/v1.0 with a Body parameter that specifies the mailNickName, displayName, and boolean securityEnabled properties of an Azure Active Directory group. According to intent, the command should create a new group resource, but received a 'BadRequest' status code of 400 from Graph and returned an error instead.

By executing the Get-GraphError command after the failed command, the operator is able to see additional information beyond the status code and the line number on which the error occurred. The ErrorResponse property often has detailed information about the error, and in this case it contains an error message "A value is required for property 'securityEnabled' of resource 'Group'". This guides the operator to retry the command by specifying that 'securityEnabled' property after consulting with the documentation for the group resource which confirms that this property must be specified when creating a group.

The subsequent retry with the corrected command issued below succeeds and a group is successfully created:

    Invoke-GraphApiRequest -Method POST groups -Body @{mailNickName='datasec';displayName='Data Security Team';mailEnabled=$false;securityEnabled=$true}

.LINK
Get-GraphResource
Invoke-GraphApiRequest
Remove-GraphResource
#>
function Get-GraphError {
    [cmdletbinding(positionalbinding=$false)]
    param(
        [parameter(position=0, parametersetname='bycount')]
        $First = 1,

        [parameter(parametersetname='bycount')]
        [switch] $Oldest,

        [parameter(parametersetname='all', mandatory=$true)]
        [switch] $All
    )

    begin {
        Enable-ScriptClassVerbosePreference
    }

    process {
        $parameters = if ( $All.IsPresent ) {
            @{All = $All}
        } elseif ( $Oldest.IsPresent ) {
            @{Oldest = $First}
        } else {
            @{Newest = $First}
        }

        Get-GraphLog @parameters -StatusFilter Error | foreach {
            $_.pstypenames.insert(0, 'GraphErrorDetail')
            $_
        }
    }

    end {
    }
}

