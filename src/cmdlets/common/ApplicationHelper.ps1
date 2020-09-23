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

. (import-script DisplayTypeFormatter)
. (import-script ../Invoke-GraphApiRequest)

ScriptClass ApplicationHelper {
    static {
        $appFormatter = $null
        $keyFormatter = $null

        function __initialize {
            $this.appFormatter = new-so DisplayTypeFormatter GraphApplicationDisplayType 'AppId', 'DisplayName', 'CreatedDateTime', 'Id'
            $this.keyFormatter = new-so DisplayTypeFormatter GraphAppCertDisplayType 'Thumbprint', 'NotAfter', 'KeyId', 'AppId'
        }

        function ToDisplayableObject($object) {
            $object.createdDateTime = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $object.createdDateTime $true
            $this.appFormatter |=> DeserializedGraphObjectToDisplayableObject $object
        }

        function KeyCredentialToDisplayableObject($object, $appId) {
            $notAfter = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $object.endDateTime $true
            $notBefore = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $object.startDateTime $true

            $remappedObject = [PSCustomObject] @{
                AppId = $appId
                KeyId = $object.KeyId
                Thumbprint = $object.customKeyIdentifier
                NotAfter = $notAfter
                NotBefore = $notBefore
                FriendlyName = $object.displayName
                Content = [PSCustomObject] $object
            }

            $this.keyFormatter |=> DeserializedGraphObjectToDisplayableObject $remappedObject
        }

        function QueryApplications($appId, $objectId, $odataFilter, $name, [object] $rawContent, $version, $permissions, $cloud, $connection, $select, $queryMethod, [int32] $maxResultCount) {
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

            $targetSelect = if ( $select ) {
                $select
            } else {
                '*'
            }

            $requestArguments = @{
                RawContent = $rawContent
                Filter = $filter
                Permissions = $permissions
                Select = $targetSelect
            }

            if ( $connection ) {
                $requestArguments['Connection'] = $connection
            }

            if ( $maxResultCount ) {
                $requestArguments['First'] = $maxResultCount
            }

            $method = if ( $queryMethod ) {
                $queryMethod
            } else {
                'GET'
            }

            write-verbose "Querying for applications at version $apiVersion' with uri '$uri, filter '$filter', select '$select'"
            Invoke-GraphApiRequest -Method $method -Uri $uri @requestArguments -version $apiVersion
        }
    }
}

$::.ApplicationHelper |=> __initialize

