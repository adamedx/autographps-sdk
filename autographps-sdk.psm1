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

. (join-path $psscriptroot src/graph-sdk.ps1)

$cmdlets = @(
    'Clear-GraphLog'
    'Connect-GraphApi'
    'Disconnect-GraphApi'
    'Find-GraphLocalCertificate'
    'Format-GraphLog'
    'Get-GraphApplication'
    'Get-GraphApplicationCertificate'
    'Get-GraphApplicationConsent'
    'Get-GraphApplicationServicePrincipal'
    'Get-GraphConnection'
    'Get-GraphCurrentConnection'
    'Get-GraphError'
    'Get-GraphResource'
    'Get-GraphLog'
    'Get-GraphLogOption'
    'Get-GraphProfileSettings'
    'Get-GraphSchema'
    'Get-GraphToken'
    'Get-GraphVersion'
    'Invoke-GraphApiRequest'
    'New-GraphApplication'
    'New-GraphApplicationCertificate'
    'New-GraphConnection'
    'New-GraphLocalCertificate'
    'Register-GraphApplication'
    'Remove-GraphApplication'
    'Remove-GraphApplicationCertificate'
    'Remove-GraphApplicationConsent'
    'Remove-GraphConnection'
    'Remove-GraphResource'
    'Select-GraphConnection'
    'Select-GraphProfileSettings'
    'Set-GraphApplicationCertificate'
    'Set-GraphApplicationConsent'
    'Set-GraphConnectionStatus'
    'Set-GraphLogOption'
    'Test-Graph'
    'Unregister-GraphApplication'
)

$aliases = @('conga', 'fgl', 'gge', 'ggr', 'gcat', 'gcon', 'gcur', 'Get-GraphContent', 'ggl', 'scon')

$variables = @('AutoGraphColorModePreference', 'GraphVerboseOutputPreference', 'LastGraphItems')

export-modulemember -function $cmdlets -alias $aliases -variable $variables


