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

. (import-script ParameterCompleter)
. (import-script ../../common/ScopeHelper)

enum PermissionCompletionType {
    AnyPermission
    DelegatedPermission
    AppOnlyPermission
}

ScriptClass PermissionParameterCompleter {
    $authType = $null

    function __initialize([PermissionCompletionType] $completionType) {
        $this.authType = if ( $completionType -ne ([PermissionCompletionType]::AnyPermission) ) {
            if ( $completionType -eq ([PermissionCompletionType]::AppOnlyPermission) ) {
                ([GraphAppAuthType]::AppOnly)
            } else {
                ([GraphAppAuthType]::Delegated)
            }
        }
    }

    function CompleteCommandParameter {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $allPossiblePermissions = $::.ScopeHelper |=> GetKnownPermissionsSorted $null $this.authType

        if ( $allPossiblePermissions ) {
            $::.ParameterCompleter |=> FindMatchesStartingWith $wordToComplete $allPossiblePermissions
        }
    }
}

