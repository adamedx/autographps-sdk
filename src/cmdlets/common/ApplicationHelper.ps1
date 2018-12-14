# Copyright 2018, Adam Edwards
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

. (import-script DisplayTypeFormatter)
. (import-script ../Invoke-GraphRequest)

ScriptClass ApplicationHelper {
    static {
        $appFormatter = $null
        $keyFormatter = $null

        function __initialize {
            $this.appFormatter = new-so DisplayTypeFormatter GraphApplicationDisplayType 'AppId', 'DisplayName', 'CreatedDateTime', 'Id'
            $this.keyFormatter = new-so DisplayTypeFormatter GraphAppCertDisplayType 'Thumbprint', 'NotAfter', 'KeyId', 'AppId'
        }

        function ToDisplayableObject($object) {
            $this.appFormatter |=> DeserializedGraphObjectToDisplayableObject $object
        }

        function KeyCredentialToDisplayableObject($object, $appId) {
            $remappedObject = try {
                $notAfter = try { [DateTime]::Parse($object.endDateTime) } catch { $object.endDateTime }
                $notBefore = try { [DateTime]::Parse($object.startDateTime) } catch { $object.startDateTime }
                [PSCustomObject] @{
                    AppId = $appId
                    KeyId = $object.KeyId
                    Thumbprint = $object.customKeyIdentifier
                    NotAfter = $notAfter
                    NotBefore = $notBefore
                    FriendlyName = $object.displayName
                    Content = $object
                }
            } catch {
                [PSCustomObject] @{Content=$object}
            }

            $this.keyFormatter |=> DeserializedGraphObjectToDisplayableObject $remappedObject
        }

        function QueryApplications($appId, $objectId, $odataFilter, $name, [object] $rawContent, $version, $permissions, $cloud, $connection, $select = '*', $queryMethod = 'GET') {
            $apiVersion = if ( $Version ) {
                $Version
            } else {
                $::.ApplicationAPI.DefaultApplicationApiVersion
            }

            $uri = '/Applications'

            $filter = if ( $ODataFilter ) {
                $ODataFilter
            } elseif ( $AppId ) {
                "appId eq '$AppId'"
            } elseif ( $Name ) {
                "displayName eq '$Name'"
            } elseif ( $ObjectId ) {
                $uri += "/$ObjectId"
            }

            $requestArguments = @{
                RawContent = $rawContent
                ODataFilter = $filter
                Permissions = $permissions
                Select = $select
            }

            if ( $connection ) {
                $requestArguments['Connection'] = $connection
            }

            write-verbose "Querying for applications at version $apiVersion' with uri '$uri, filter '$filter', select '$select'"
            Invoke-GraphRequest -Method $queryMethod -RelativeUri $uri @requestArguments -version $apiVersion
        }
    }
}

$::.ApplicationHelper |=> __initialize
