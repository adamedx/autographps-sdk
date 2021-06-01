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

. (import-script ../../common/Secret)
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
            # Yes, this is changing an existing property and overwriting it with a new version of itself!
            # Terrible in some ways, but this makes up for the fact that the deserializer is unsophisticated --
            # it doesn't know the API schema so strings that represent time for instance simply remain strings
            # rather then being converted to the type described in the schema. This is a bespoke approach to
            # compensating for this in a specific case where we use knowledge of the schema to perform an explicit
            # conversion.
            $object.createdDateTime = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $object.createdDateTime $true

            $result = $this.appFormatter |=> DeserializedGraphObjectToDisplayableObject $object
            $result.pstypenames.insert(0, 'GraphApplication')
            $result
        }

        function KeyCredentialToDisplayableObject($object, $appId, $appObjectId) {
            if ( $object.Type -eq 'AsymmetricX509Cert' ) {
                $notAfter = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $object.endDateTime $true
                $notBefore = $::.DisplayTypeFormatter |=> UtcTimeStringToDateTimeOffset $object.startDateTime $true

                $::.CertificateHelper |=> CertificateInfoToDisplayableObject $object.displayName $object.displayName $object.KeyId $appId $appObjectId $notBefore $notAfter $object.customKeyIdentifier $null
            } else {
                $::.Secret |=> ToDisplayableSecretInfo Password $$object.displayName $null $object.keyId $appId $appObjectId $null $null $object.customKeyIdentifier $null
            }
        }

        function QueryApplications($appId, $objectId, $odataFilter, $name, [object] $rawContent, $version, $permissions, $cloud, $connection, $select, $queryMethod, $first, $skip, [bool] $all) {
            $apiVersion = if ( $Version ) {
                $Version
            } else {
                $::.ApplicationAPI.DefaultApplicationApiVersion
            }

            $uri = '/applications'

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

            $requestArguments = @{}

            'RawContent', 'Filter', 'Permissions', 'Select' | where { (get-variable $_ -value ) -ne $null } | foreach {
                $requestArguments.Add($_, (get-variable $_ -value))
            }

            if ( $connection ) {
                $requestArguments['Connection'] = $connection
            }

            if ( $first ) {
                $requestArguments['First'] = $first
            }

            if ( $skip ) {
                $requestArguments['Skip'] = $skip
            }

            $method = if ( $queryMethod ) {
                $queryMethod
            } else {
                'GET'
            }

            write-verbose "Querying for applications at version $apiVersion' with uri '$uri, filter '$filter', select '$select'"
            Invoke-GraphApiRequest -Method $method -Uri $uri @requestArguments -All:$all -version $apiVersion -ConsistencyLevel Session
        }
    }
}

$::.ApplicationHelper |=> __initialize
