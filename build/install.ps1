# Copyright 2023, Adam Edwards
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
param([switch] $clean)

. "$psscriptroot/common-build-functions.ps1"

function InstallDependencies($clean) {
    $appRoot = join-path $psscriptroot '..'
    $packagesDestination = join-path $appRoot lib

    if ( $clean -and (test-path $packagesDestination) ) {
        write-host -foregroundcolor cyan "Clean install specified -- deleting '$packagesDestination'"
        remove-item -r -force $packagesDestination
    }

    write-host "Installing dependencies to '$appRoot'"

    if ( ! (test-path $packagesDestination) ) {
        psmkdir $packagesDestination | out-null
    }

    $projectFilePath = Get-ProjectFilePath

    if ( ! ( test-path $projectFilePath ) ) {
        return
    }

    $projectContent = [xml] ( get-content $projectFilePath | out-string )
    $targetPlatforms = $projectContent.Project.PropertyGroup.TargetFrameworks -split ';'

    if ( ! $targetPlatforms ) {
        throw "No platforms found for the TargetFrameWorks element of '$projectfilePath'; at least one platform must be specified"
    }

    $restoreCommand = "dotnet restore '$projectFilePath' --packages '$packagesDestination' /verbosity:normal --no-cache"

    write-host "Executing command: $restoreCommand"

    # This will download and install libraries and transitive dependencies under packages destination
    Invoke-Expression $restoreCommand | out-host

    # Group the libraries by platform and place all libraries for the same platform
    # into the same platform-specific directory. Example layout is below -- note that
    # this does not allow for the same library to have different versions in the same
    # platform (which is a good thing to avoid conflicting or non-deterministic
    # versionining issues):
    #
    #     lib/
    #        <platformspec1>/
    #                        library1.dll
    #                        library2.dll
    #                        library3.dll
    #        <platformspec2>/
    #                        library1.dll
    #                        library2.dll
    #                        library3.dll

    foreach ( $platform in $targetPlatforms ) {
        $platformSourceLibraries = Get-ChildItem -r $packagesDestination |
          where name -like *.dll |
          where { $_.Directory.Name -eq $platform }

        if ( $platformSourceLibraries ) {
            $platformDirectory = join-path $packagesDestination $platform

            if ( ! ( test-path $platformDirectory ) ) {
                new-directory $platformDirectory -force | out-null
            }

            foreach ( $sourceLibrary in $platformSourceLibraries ) {
                move-item $sourceLibrary.FullName $platformDirectory
            }
        }
    }

    # Remove all of the other files under the packages destination -- these
    # other files are either non-library artifacts# or libraries from
    # unneeded platforms
    get-childitem $packagesDestination |
      where name -notin $targetPlatforms |
      remove-item -r -force
}

InstallDependencies $clean
