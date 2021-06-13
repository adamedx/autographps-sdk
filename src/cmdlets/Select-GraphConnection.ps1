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

. (import-script ../client/GraphConnection)
. (import-script ../client/GraphContext)
. (import-script ../client/LogicalGraphManager)


<#
.SYNOPSIS
Makes the specified connection the active connection for the current context.

.DESCRIPTION
Commands such as `New-GraphConnection` may be used to create connections to the Grapi API; such connections may also be defined through profile settings. By invoking Select-GraphConnection, any subsequent commands that access the Graph will use the connection specified to Select-GraphConnection.

Note that unlike Connect-GraphApi, when a connection is specified to Select-GraphConnection, no sign-in occurs to establish the connection. Sign-in will only occur from a subsequent Connect-GraphApi invocation or by invoking any command that attempts to access the Graph when auto-connect is enabled (the default behavior).

This command also differs from Connect-GraphApi in that it does not emit output.

For more information on how connections may be specified using profiles, see the documentation at https://github.com/adamedx/autographps-sdk/tree/main/docs/settings.

.PARAMETER ConnectionName
The name of a named connection to set as the current connection

.PARAMETER Connection
An existing connection object returned by Connect-GraphApi, New-GraphConnection, or Get-GraphConnection. The connection may be named or unnamed.

.OUTPUTS
None.

.EXAMPLE
Select-GraphConnection TempElevatedAccessConnection

In this example, a named connection TempEelvatedAccessConnection is set as the current connection.

.EXAMPLE

$testEnvironmentConnection = New-GraphConnection -AppId $testTenantAppId
Select-GraphConnection -Connection $testEnvironmentConnection
# ... Execute commands to run a test scenario such as an application that creates certain users ...
$userResultsToValidate = Get-GraphResource /users # Sign-in will occur now using the new connection

.LINK
Connect-GraphApi
New-GraphConnection
Get-GraphConnection
Get-GraphCurrentConnection
Remove-GraphConnection
Get-GraphProfile
#>
function Select-GraphConnection {
    [cmdletbinding(positionalbinding=$false)]
    [OutputType('GraphConnection')]
    param(
        [parameter(parametersetname='connectionname', position=0, mandatory=$true)]
        [ArgumentCompleter({
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
                               $::.GraphConnection |=> GetNamedConnection | where Name -like "$($wordToComplete)*" | select-object -expandproperty Name
                           })]
        [Alias('Name')]
        [string] $ConnectionName,

        [parameter(parametersetname='connection', valuefrompipeline=$true, mandatory=$true)]
        [PSTypeName('GraphConnection')]
        $Connection
    )

    $targetConnection = if ( $Connection ) {
        $Connection
    } else {
        $::.GraphConnection |=> GetNamedConnection $ConnectionName $true
    }

    $currentContext = $::.GraphContext |=> GetCurrent

    $newContext = $::.LogicalGraphManager |=> Get |=> NewContext $currentContext $targetConnection

    $::.GraphContext |=> SetCurrentByName $newContext.name

    $targetConnection
}
