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

[cmdletbinding()]
param([switch] $clean)

. "$psscriptroot/common-build-functions.ps1"

function InstallDependencies($clean) {
    validate-nugetpresent

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

    $configFilePath = join-path $appRoot 'NuGet.Config'
    $nugetConfigFileArgument = if ( Test-Path $configFilePath ) {
        $configFileFullPath = (gi (join-path $appRoot 'NuGet.Config')).fullname
        Write-Warning "Using test NuGet config file '$configFileFullPath'..."
        "-configfile '$configFileFullPath'"
    } else {
        ''
    }
    $packagesConfigFile = join-path -path (join-path $psscriptroot ..) -child packages.config

    if ( ! ( test-path $packagesConfigFile ) ) {
        return
    }

    $restoreCommand = if ( $PSVersionTable.PSEdition -eq 'Desktop' ) {
        # Add the explicit fallback source to nuget.org because we've hit issues in the past where the required packages
        # weren't in the local source that the CI pipeline uses, even though these are very popular packages!
        "& nuget restore '$packagesConfigFile' $nugetConfigFileArgument -FallbackSource  https://api.nuget.org/v3/index.json -packagesDirectory '$packagesDestination' -packagesavemode nuspec"
    } else {
        $psCorePackagesCSProj = New-DotNetCoreProjFromPackagesConfig $packagesConfigFile $packagesDestination
        "dotnet restore '$psCorePackagesCSProj' --packages '$packagesDestination' /verbosity:normal --no-cache"
    }
    write-host "Executing command: $restoreCommand"
    iex $restoreCommand | out-host

    $nuspecFile = get-childitem -path $approot -filter '*.nuspec' | select -expandproperty fullname

    if ( $nuspecFile -is [object[]] ) {
        throw "More than one nuspec file found in directory '$appRoot'"
    }

    Normalize-LibraryDirectory $packagesConfigFile $packagesDestination

    $librarySourcePathDirectories = get-allowedlibrarydirectoriesfromnuspec $nuspecFile src

    # Find the library files (.dlls) in the nuspec and normalize the names
    # to address case-sensitivity behaviors on non-Windows platforms
    $normalizedLibrarySourceDirectoryPaths = $librarySourcePathDirectories | foreach {
        # For linux for example, the path case may not match the case of the directory which comes
        # from metadata -- seems that nuget converts to lower case on linux, so we try
        # normal case and lower case get the actual file name from the file system via get-item
        $directoryPathMixedCase = join-path . $_
        $directoryPath = if ( test-path $directoryPathMixedCase ) {
            $directoryPathMixedCase
        } else {
            $directoryPathMixedCase.tolower()
        }

        get-childitem -path $directoryPath -filter *.dll
    }

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
    #        <platformspec2>
    #                        library1.dll
    #                        library2.dll
    #                        library3.dll

    $platforms = @{}
    $targetFiles = @{}

    foreach ( $sourceLibraryDirectory in $normalizedLibrarySourceDirectoryPaths ) {
        # Extract the platform specification -- this assumes the path looks like
        # <somedir>/<somedir>/.../<somedir>/lib/<platformspec>/<libraryname>.dll
        $platform = split-path -leaf ( split-path -parent $sourceLibraryDirectory.FullName )

        $platformDirectory = join-path $packagesDestination $platform
        if ( $platforms[$platform] -ne $platformDirectory ) {
            if ( ! ( test-path $platformDirectory ) ) {
                new-directory $platformDirectory -force | out-null
            }
            $platforms[$platform] = $platformDirectory
        }

        $platformTargetFile = join-path $platformDirectory $sourceLibraryDirectory.Name

        if ( ! $targetFiles[$platformTargetFile] ) {
            if ( ! ( test-path $platformTargetFile ) ) {
                foreach ( $sourceLibraryPath in ( get-childitem $sourceLibraryDirectory.FullName *.dll) ) {
                    move-item $sourceLibraryPath $platformTargetFile
                }
            }
            $targetFiles[$platformTargetFile] = $true
        } else {
            throw "The target library file '$platformTargetFile' from source directory '$($sourceLibraryDirectory.FullName)' was previously specified by another source location for the given platform spec '$platform' -- the nuspec files element may be misconfigured or the expanded nuget archive contents may be incorrect. Retrying the operation after deleting all build artifacts may resolve this failure."
        }
    }

    get-childitem $packagesDestination |
      where name -notin $platforms.keys |
      remove-item -r -force
}

InstallDependencies $clean
