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

ScriptClass ParameterCompleter {
    static {
        const ParameterCompletionMethod CompleteCommandParameter
        const ParameterCompletionScriptFormat @"
            param(`$commandName, `$parameterName, `$wordToComplete, `$commandAst, `$fakeBoundParameter)
            `$::.ParameterCompleter.__CompleteCommandParameter(
                '{0}',
                `$commandName,
                `$parameterName,
                `$wordToComplete,
                `$commandAst,
                `$fakeBoundParameter)
"@

        $completersByParameter = @{}

        function RegisterParameterCompleter([string] $command, [string[]] $parameterNames, $completerObject) {
            $parameterNames | foreach {
                $completerBlock = __RegisterCompleter $command $_ $completerObject
                Register-ArgumentCompleter -commandname $command -ParameterName $_ -ScriptBlock $completerBlock
            }
        }

        function FindMatchesStartingWith($target, $sortedItems) {
            $targetNormal = $target.tolower()
            $sortedItemsCollection = try {
                if ( $sortedItems.Count -eq 0 ) {
                    return $null
                }
                $sortedItems
            } catch [System.Management.Automation.PropertyNotFoundException] {
                # Don't assign an array / collection of size 1 here as PowerShell
                # converts this to a non-array / collection! Do it outside the catch
            }

            # This happens if $sortedItems is not an array, i.e. it is
            # just one string.
            if ( ! $sortedItemsCollection ) {
                $sortedItemsCollection = @($sortedItems)
            }

            $matchingItems = @()
            $lastMatch = $null

            $first = 0
            $last = $sortedItemsCollection.Count - 1

            $current = 0
            $previous = -1

            if ( $target.length -ne 0 ) {
                while ($current -ne $previous) {
                    $previous = $current
                    $current = $first + [int] ($last - $first) / 2

                    $item = $sortedItemsCollection[$current]
                    $itemNormal = $item.tolower()

                    $comparison = $targetNormal.CompareTo($itemNormal)

                    if ( $comparison -gt 0 ) {
                        $first = $current
                    } else {
                        if ( $itemNormal.StartsWith($targetNormal) ) {
                            $lastMatch = $current
                        }
                        $last = $current
                    }
                }
            } else {
                $lastMatch = 0
            }

            if ( $lastMatch -ne $null ) {
                for ( $startsWithCandidate = $lastMatch; $startsWithCandidate -lt $sortedItemsCollection.Count; $startsWithCandidate++ ) {
                    $candidate = $sortedItemsCollection[$startsWithCandidate]
                    if ( ! $candidate.tolower().StartsWith($targetNormal) ) {
                        break
                    }

                    $matchingItems += $candidate
                }
            }

            $matchingItems
        }

        function __CompleteCommandParameter {
            param($parameterId, $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            $this.completersByParameter[$parameterId].CompleterObject.$($this.ParameterCompletionMethod)(
                $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameter)
        }

        function __GetCompleterHash($commandName, $parameterName) {
            "{0}/{1}" -f $commandName, $parameterName
        }

        function __FindCompleter($commandName, $parameterName) {
            $hash = __GetCompleterHash $commandName $parameterName
            $this.completersByParameter[$hash]
        }

        function __NewCompleter($commandName, $parameterName, $completerObject) {
            $hash = __GetCompleterHash $commandName $parameterName
            $completerScriptBlock = __NewCompleterScriptBlock $hash $completerObject
            @{
                Id = $hash
                CompleterObject = $completerObject
                ParameterName = $parameterName
                CommandName = $commandName
                ScriptBlock = $completerScriptBlock
            }
        }

        function __NewCompleterScriptBlock($hash, $completerObject) {
            [ScriptBlock]::Create($this.ParameterCompletionScriptFormat -f $hash)
        }

        function __UpdateCompleter($completer, $completerObject) {
            $existingObject = $this.completersByParameter[$completer.CompleterObject.GetHashCode()]
            $newObjectId = $completerObject.GetHashCode()

            if ( ! $existingObject -or ($existingObject.Id -ne $newObjectId) ) {
                $completer.CompleterObject = $completerObject
            }
        }

        function __RegisterCompleter($commandName, $parameterName, $completerObject) {
            $existingCompleter = __FindCompleter $commandName $parameterName

            $completer = if ( $existingCompleter ) {
                __UpdateCompleter $existingCompleter $completerObject
                $existingCompleter
            } else {
                $newCompleter = __NewCompleter $commandName $parameterName $completerObject
                __AddCompleter $newCompleter
                $newCompleter
            }

            $completer.ScriptBlock
        }

        function __AddCompleter($completer) {
            $this.completersByParameter.Add($completer.Id, $completer)
        }

        function __GetCompleterScriptBlock($completerObject) {
            $completerBlock = $completerObject |=> GetCommandCompletionScriptBlock

            if ( ! $completerBlock ) {
                throw "No command completion block returned by completer object"
            }

            $completerBlock
        }
    }
}
