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

function __ShowPoshGraphDeprecation {
    $poshgraphLink = 'https://github.com/adamedx/autographps/blob/poshgraph/README.md#this-module-has-been-renamed'
    $poshgraphSDKLink = 'https://github.com/adamedx/autographps-sdk/blob/poshgraph-sdk/README.md#this-module-has-been-renamed'

    write-warning "***DEPRECATION!!!***"
    write-warning ''
    write-warning "PoshGraph and PoshGraph-SDK have been renamed to *AutoGraphPS* and *AutoGraphPS-SDK*."
    write-warning "The module packages for PoshGraph and PoshGraph-SDK will no longer be updated!"
    write-warning "Visit the links below for more details regarding the rename:"
    write-warning "`n`n         $poshGraphLink`n         $poshGraphSDKLink`n`n"
    write-warning "Please replace the respective modules with AutoGraphPS and / or AutoGraphPS-SDK to get"
    write-warning "the latest versions of all your favorite PoshGraph cmdlets:"
    write-warning "`n`n         Uninstall-Module poshgraph, poshgraph-sdk`n         Install-Module AutoGraphPS -Scope CurrentUser"
}

. (import-script cmdlets)
. (import-script aliases)

. (import-script common/ProgressWriter)

