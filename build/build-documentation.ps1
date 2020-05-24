# Copyright 2020, Adam Edwards
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

[cmdletbinding()]
param($DocumentationPath = $null)

. "$psscriptroot/common-build-functions.ps1"

$docPath = if ( $DocumentationPath ) {
    $DocumentationPath
} else {
    Get-DefaultDocsDirectory
}

if ( ! ( test-path $docPath ) ) {
    new-directory $docPath | out-null
}

New-LogsDirectory | out-null

$docsLogPath = Get-DocsLogPath

if ( test-path $docsLogPath ) {
    remove-item $docsLogPath
}

$docToolModulePath = Get-DocModulePath
$moduleName = Get-ModuleName
$moduleManifestPath = Get-ModuleManifestPath

# TODO: Rewrite! This mechanism of launching another process is extremely cumbersome.
# The requirement is to prevent pollution of the current environment by the modifications
# such as environment variables and module paths required to load modules for testing
# in an isolated fashion. Use of jobs through start-job and other mechanisms better
# integrated into the PowerShell model should be used to do this cleanly. Returning
# the results through a (sometimes JSON) log file is particuarly... terrible.

# Use FromSource here so that this can be generated without building the module.
# The module just needs to be loadable via its manifest to generate help.
$docCommand = "
    try {
        # Note: Do *NOT* try to log errors as json to the log file -- convertto-json cannot
        # serialize certain types that are part of som exceptions. :( Also, do *NOT* try
        # to serialize log results too deeply -- even a depth of 5 results in hangs and recursion,
        # so limit it to 2 for now.
        `$erroractionpreference = 'stop'
        `$succeeded = `$false
        import-module -force '$($docToolModulePath.fullname)'

        # This is required to get New-MarkdownHelp to see the module by its name -- seems this
        # does not work when the module is imported by manifest path as it is for 'fromsource'
        get-module $moduleName | out-null

        `$helpFiles = New-MarkdownHelp -Module '$moduleName' -OutputFolder '$docPath' -Force -NoMetadata

        if ( `$helpFiles ) {
            `$helpFiles | convertto-json -depth 2 | out-file '$docsLogPath' -encoding utf8 -append
            `$succeeded = `$true
            exit 0
        } else {
            `$_ | out-file '$docsLogPath' -encoding utf8 -append
            exit 1
        }
    } catch {
        `$_ | out-file '$docsLogPath' -encoding utf8 -append
        exit 2
    } finally {
        if ( `$succeeded ) {
            exit 0
        }

        exit 4
    }

    exit 3
"

$processExitCode = & $psscriptroot/import-devmodule.ps1 -reuseconsole -wait -returnexitcode -fromsource -initialcommand $docCommand

$logData = if ( test-path $docsLogPath ) {
    get-content -raw $docsLogPath -erroraction ignore
}

if ( $processExitCode -eq 0 ) {
    $logResults = if ( $logData ) {
        get-content -raw $docsLogPath | convertfrom-json
    } else {
        write-error "Documentation tool process exited successfully, but no log results were returned. Check '$docslogPath' for diagnostics."
        return
    }

    $logResults | select mode, lastwritetimeutc, length, name | write-verbose
    write-host -fore green "Successfully generated help files to '$docPath'"
} else {
    $logData | write-error -erroraction continue
    write-error "Failed to generate help files, status '$processExitCode'. Ensure that the module was built and published to the dev module location and retry. Check '$docsLogPath' for diagnostics."
}
