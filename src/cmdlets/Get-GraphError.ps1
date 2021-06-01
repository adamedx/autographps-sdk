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

AfterTimeLocal    : 1/25/2019 5:48:38 AM
AfterTimeUtc      : 1/25/2019 1:48:38 PM
PSErrorRecord     : The remote server returned an error: (400) Bad Request.
Response          : System.Net.HttpWebResponse
ResponseHeaders   : @{x-ms-ags-diagnostic=x-ms-ags-diagnostic;
                    Transfer-Encoding=Transfer-Encoding; request-id=request-id;
                    Content-Type=Content-Type; Cache-Control=Cache-Control;
                    Strict-Transport-Security=Strict-Transport-Security; Date=Date;
                    Duration=Duration; client-request-id=client-request-id}
ResponseStream    : {
                      "error": {
                        "code": "RequestBodyRead",
                        "message": "The property 'firstName' does not exist on type
                    'Microsoft.OutlookServices.Contact'. Make sure to only use property names
                    that are defined by the type or mark the type as open type.",
                        "innerError": {
                          "request-id": "b01e4465-3543-4eda-abd8-b26d1ffb9a82",
                          "date": "2019-01-25T13:48:39"
                        }
                      }
                    }
StatusCode        : BadRequest
StatusDescription : Bad Request

The Get-GraphError command was invoked after the following Graph command failed:

    Invoke-GraphApiRequest -Method POST me/contacts -Body @{firstName='Cleopatra';surname='Jones'}

Invoke-GraphApiRequest was invoked to POST to the 'me/contacts' relative URI of https://graph.microsoft.com/v1.0 with a Body parameter that specifies the first and last name of a personal contact. The command should create a new contact resource, but received a 'BadRequest' status code of 400 from Graph and threw and exception.

By executing the Get-GraphError command after the failed command, the operator is able to see additional information beyond the status code and the line number on which the error occurred. The ResponseStream property often has detailed information about the error, and in this case it contains an error message "The property 'firstName' does not exist on type 'Microsoft.OutlookServices.Contact'". This guides the operator to look more clsoely at the documentation for the contat resource, which instead of a 'firstName' property contains a 'givenName' property.

The operator can then correct the error in the original Invoke-GraphApiRequest command, replacing 'firstName' with 'givenName' in the Body parameter and the command will succeed.

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

        Get-GraphLog @parameters -StatusFilter Error
    }

    end {
    }
}

