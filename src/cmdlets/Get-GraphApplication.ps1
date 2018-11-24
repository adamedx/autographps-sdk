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

function Get-GraphApplication {
    [cmdletbinding(defaultparametersetname='appid', positionalbinding=$false)]
    param (
        [parameter(parametersetname='appid', position=0)]
        $AppId,

        [parameter(parametersetname='objectid', mandatory=$true)]
        $ObjectId,

        [parameter(parametersetname='odatafilter', mandatory=$true)]
        $ODataFilter,

        [parameter(parametersetname='name', mandatory=$true)]
        $Name,

        [switch] $RawContent,

        [String] $Version = $null,

        [parameter(parametersetname='NewConnection')]
        [parameter(parametersetname='NewConnectionAppId')]
        [parameter(parametersetname='NewConnectionObjectId')]
        [parameter(parametersetname='NewConnectionODataFilter')]
        [parameter(parametersetname='NewConnectionName')]
        [String[]] $Scopes = $null,

        [parameter(parametersetname='NewConnection')]
        [parameter(parametersetname='NewConnectionAppId')]
        [parameter(parametersetname='NewConnectionObjectId')]
        [parameter(parametersetname='NewConnectionODataFilter')]
        [parameter(parametersetname='NewConnectionName')]
        [GraphCloud] $Cloud = [GraphCloud]::Public,

        [parameter(parametersetname='ExistingConnection')]
        [parameter(parametersetname='ExistingConnectionAppId')]
        [parameter(parametersetname='ExistingConnectionODataFilter')]
        [parameter(parametersetname='ExistingConnectionObjectId')]
        [parameter(parametersetname='ExistingConnectionName')]
        [PSCustomObject] $Connection = $null
    )

    $DefaultApplicationApiVersion = 'beta'

    $apiVersion = if ( $Version ) {
        $Version
    } else {
        $DefaultApplicationApiVersion
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
        RawContent = $RawContent
        ODataFilter = $filter
        Scopes = $Scopes
    }

    if ( $Connection ) {
        $commonRequestArguments['Connection'] = $Connection
    }

    $result = Invoke-GraphRequest -Method GET $uri @requestArguments -version $apiVersion

    if ( $result -and ( $RawContent.IsPresent -or ( $result | gm id ) ) ) {
        $result
    }
}
