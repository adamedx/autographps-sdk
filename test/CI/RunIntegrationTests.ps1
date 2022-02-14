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
param(
    [ValidateSet('All', 'SamplesOnly', 'NonSamplesOnly')]
    [string] $Filter = 'All',
    [switch] $NoClean,
    [switch] $CIPipeline
)

. "$psscriptroot/../../build/common-build-functions.ps1"

$tags = if ( $Filter -eq 'SamplesOnly' ) {
    'SampleIntegration'
} elseif ( $Filter -eq 'NonSamplesOnly' ) {
    'Integration'
} else {
    'Integration', 'SampleIntegration'
}

if ( ! $NoClean.IsPresent ) {
    Clean-TestDirectories
    & "$psscriptroot/../../samples/Generate-SampleTestScripts.ps1"
}

Invoke-Pester @args -Tag $tags