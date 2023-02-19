# Copyright 2022, Adam Edwards
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
param([string] $ScriptRoot, $TestTargetPath, $DocTargetPath, [switch] $NoSave)

Set-StrictMode -Version 2

. "$psscriptroot/../build/common-build-functions.ps1"

$sourceRoot = if ( $ScriptRoot ) {
    $ScriptRoot
} else {
    ( get-item ( join-path $psscriptroot scripts ) ).FullName
}

$targetRoot = if ( $TestTargetPath ) {
    $TestTargetPath
} else {
    Clean-TestDirectories
    $generatedTestsDirectory = Get-GeneratedTestsDirectory

    if ( ! ( test-path $generatedTestsDirectory ) ) {
        New-Directory $generatedTestsDirectory | out-null
    }

    $generatedTestsDirectory
}

$docsRoot = if ( $DocTargetPath ) {
    $DocTargetPath
} else {
    Clean-DocDirectories
    $generatedDocsDirectory = Get-GeneratedDocsDirectory
    if ( ! ( test-path $generatedDocsDirectory ) ) {
        New-Directory $generatedDocsDirectory | out-null
    }

    $generatedDocsDirectory
}

# The Filter parameter of Get-ChildItem includes things that do not end in '*.ps1`' for instance -- why????
# We perform a client-side filter to remove them. :(
$testScripts = Get-ChildItem $sourceRoot -Filter '*.ps1' | where Name -like '*.ps1' | where Name -notlike '*#*'

foreach ( $script in $testScripts ) {
    $test = & $psscriptroot/Get-SampleScriptTest.ps1 $script.FullName
    $documentationContent = & $psscriptroot/Get-SampleCollectionString.ps1 -CollectionTitle $test.CollectionTitle -CollectionDescription $test.CollectionDescription $test.SampleCodeCases $test.SampleTitles $test.SampleDescriptions
    if ( ! $NoSave.IsPresent ) {
        & $psscriptroot/Save-SampleTestsFromScriptFile.ps1 $targetRoot $test.TestTitle $test.TestContent
        & $psscriptroot/Save-SampleDocsFromScriptFile.ps1 $docsRoot $test.CollectionTitle $documentationContent
    }
}

