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

. (join-path $psscriptroot src/graph-sdk.ps1)

$cmdlets = @(
    'Connect-Graph'
    'Disconnect-Graph'
    'Find-GraphLocalCertificate'
    'Get-GraphApplication'
    'Get-GraphApplicationCertificate'
    'Get-GraphApplicationConsent'
    'Get-GraphApplicationServicePrincipal'
    'Get-GraphConnectionInfo'
    'Get-GraphError'
    'Get-GraphItem'
    'Get-GraphSchema'
    'Get-GraphToken'
    'Get-GraphVersion'
    'Invoke-GraphRequest'
    'New-GraphApplication'
    'New-GraphApplicationCertificate'
    'New-GraphConnection'
    'New-GraphLocalCertificate'
    'Register-GraphApplication'
    'Remove-GraphApplication'
    'Remove-GraphApplicationCertificate'
    'Remove-GraphApplicationConsent'
    'Remove-GraphItem'
    'Set-GraphApplicationConsent'
    'Set-GraphConnectionStatus'
    'Test-Graph'
    'Unregister-GraphApplication'
)

$aliases = @('gge', 'ggi')

$variables = @('GraphVerboseOutputPreference', 'LastGraphItems')

export-modulemember -function $cmdlets -alias $aliases -variable $variables
