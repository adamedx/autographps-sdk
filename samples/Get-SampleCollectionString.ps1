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
param([string] $CollectionTitle, [String] $CollectionDescription, [String[]] $SampleCaseStrings, [string[]] $SampleTitles, [string[]] $SampleDescriptions)

Set-StrictMode -Version 2

$sampleIndex = 0
$sampleCaseDocStrings = foreach ( $sampleCaseCode in $SampleCaseStrings ) {
    $sampleTitle = $SampleTitles[$sampleIndex]
    $sampleDescription = $SampleDescriptions[$sampleIndex]
    $sampleIndex++
    & "$psscriptroot/Get-SampleCaseDocString.ps1" $sampleTitle $sampleDescription $sampleCaseCode
}

$sampleContent = $sampleCaseDocStrings -join "`n"

@"
# $CollectionTitle

$CollectionDescription

## Samples

$sampleContent
"@
