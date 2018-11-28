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

. (import-script ../cmdlets/Invoke-GraphRequest)
. (import-script ../graphservice/GraphApplicationRegistration)

function Set-GraphApplicationConsent {
    [cmdletbinding(defaultparametersetname='explicitscopes', positionalbinding = $false)]
    param(
        [parameter(position=0, mandatory=$true)]
        $AppId,

        [parameter(parametersetname='explicitscopes')]
        [string[]] $DelegatedPermissions,

        [parameter(parametersetname='explicitscopes')]
        [string[]] $AppOnlyPermissions,

        [parameter(parametersetname='allconfiguredpermissions', mandatory=$true)]
        [switch] $AllPermissions,

        [switch] $ConsentForTenant,

        $UserIdToConsent
    )

    $app = $::.GraphApplicationRegistration |=> GetApplicationByAppId $AppId

    $grant = $::.GraphApplicationRegistration |=> GetConsentGrantForApp $app $UserIdToConsent $DelegatedPermissions $AppOnlyPermissions $AllPermissions.IsPresent

    Invoke-GraphRequest /oauth2PermissionGrants -method POST -body $grant -version $::.GraphApplicationRegistration.DefaultApplicationApiVersion | out-null
}
