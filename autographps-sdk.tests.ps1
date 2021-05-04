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

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "Poshgraph application" {
    $manifestLocation = Join-Path $here 'autographps-sdk.psd1'

    function Get-ModuleMetadataFromManifest ( $moduleName, $manifestPath ) {
        # Load the module contents and deserialize it by evaluating
        # it (module files  are just hash tables expressed as PowerShell script)
        $moduleContentLines = get-content $manifestPath
        $moduleData = $moduleContentLines | out-string | iex
        $moduleData['Name'] = $moduleName
        $moduledata
    }

    $manifest = Get-ModuleMetadataFromManifest 'autographps-sdk' $manifestlocation

    Context "When loading the manifest" {
        It "should export the exact same set of functions as are in the set of expected functions" {
            $expectedFunctions = @(
                'Clear-GraphLog',
                'Connect-GraphApi',
                'Disconnect-GraphApi',
                'Find-GraphLocalCertificate',
                'Format-GraphLog',
                'Get-GraphApplication',
                'Get-GraphApplicationCertificate',
                'Get-GraphApplicationConsent',
                'Get-GraphApplicationServicePrincipal',
                'Get-GraphConnection',
                'Get-GraphConnectionInfo',
                'Get-GraphError',
                'Get-GraphResource',
                'Get-GraphLog',
                'Get-GraphLogOption',
                'Get-GraphProfileSettings',
                'Get-GraphToken',
                'Invoke-GraphApiRequest',
                'New-GraphApplication',
                'New-GraphApplicationCertificate',
                'New-GraphConnection',
                'New-GraphLocalCertificate',
                'Register-GraphApplication',
                'Remove-GraphApplication',
                'Remove-GraphApplicationCertificate',
                'Remove-GraphApplicationConsent',
                'Remove-GraphConnection',
                'Remove-GraphResource',
                'Select-GraphProfileSettings',
                'Set-GraphApplicationConsent',
                'Set-GraphConnectionStatus',
                'Set-GraphLogOption',
                'Test-Graph',
                'Unregister-GraphApplication')

            $verifiedExportsCount = 0

            $expectedFunctions | foreach {
                if ( $manifest.FunctionsToExport -contains $_ ) {
                    $verifiedExportsCount++
                }

                { get-command $_ | out-null } | Should Not Throw
            }

            $manifest.FunctionsToExport.count | Should BeExactly $expectedFunctions.length

            $verifiedExportsCount | Should BeExactly $expectedFunctions.length
        }

        It "should export the exact same set of aliases as are in the set of expected aliases" {
            $expectedAliases = @('conga', 'fgl', 'gge', 'ggr', 'gcat', 'gcon', 'Get-GraphContent', 'ggl')

            $manifest.AliasesToExport.count | Should BeExactly $expectedAliases.length

            $verifiedExportsCount = 0

            $expectedAliases | foreach {
                if ( $manifest.AliasesToExport -contains $_ ) {
                    $verifiedExportsCount++
                }
                $_ | get-alias | select -expandproperty resolvedcommandname | get-command | select -expandproperty module | select -expandproperty name | Should Be $manifest.Name
            }

            $verifiedExportsCount | Should BeExactly $expectedAliases.length
        }

        It "Should export the exact same set of variables that are in the set of expected variables" {
            $expectedVariables = @(
                'AutoGraphColorModePreference'
                'GraphVerboseOutputPreference'
                'LastGraphItems'
            )

            Compare-Object ($manifest.VariablesToExport | sort) ($expectedVariables | sort) | Should Be $null
        }
    }

    Context "When invoking the autographps-sdk application" {
        It "Should be able to create a connection object" {
            { $connection = New-GraphConnection } | Should Not Throw
        }
    }
}

