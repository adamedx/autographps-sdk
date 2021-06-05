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
