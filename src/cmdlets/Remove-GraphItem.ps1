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

. (import-script Invoke-GraphRequest)

function Remove-GraphItem {
    [cmdletbinding(supportsshouldprocess=$true, confirmimpact='High', positionalbinding=$false)]
    param(
        [parameter(position=0)]
        [Uri] $Uri = $null,

        [String] $ODataFilter = $null,

        [String] $Version = $null,

        [switch] $AbsoluteUri,

        [HashTable] $Headers = $null,

        [parameter(parametersetname='FromUri')]
        [parameter(parametersetname='FromObjects')]
        [String[]] $Permissions = $null,

        [parameter(parametersetname='FromUri')]
        [parameter(parametersetname='FromObjects')]
        [GraphCloud] $Cloud = [GraphCloud]::Public,

        [parameter(parametersetname='FromUriExistingConnection', mandatory=$true)]
        [parameter(parametersetname='FromObjectsExistingConnection', mandatory=$true)]
        [PSCustomObject] $Connection = $null,

        [switch] $Force,

        [parameter(parametersetname='FromObjects', valuefrompipeline=$true, mandatory=$true)]
        [parameter(parametersetname='FromObjectsExistingConnection', valuefrompipeline=$true, mandatory=$true)]
        $TargetItem
    )

    # Note that PowerShell requires us to sue the begin / process / end structure here
    # in order to process more than one element of the pipeline via $TargetItem

    begin {}

    process {
        $useFullyQualifiedUri = $AbsoluteUri.IsPresent

        $targetUri = if ( ! $targetItem ) {
            $Uri
        } else {
            $fullyQualifiedUri = $null
            $relativeId = $null

            # We check to see if this is an item that supports the __ItemContext interface -- we'll use that
            # if it's there to extract an absolute URI
            $content = $targetItem
            $itemContext = if ( $targetItem | gm __ItemContext -erroraction silentlycontinue ) {
                $targetItem.__ItemContext()
            } elseif ( ($targetItem | gm Content -erroraction silentlycontinue) -and ($targetItem.Content | gm __ItemContext -erroraction silentlycontinue) ) {
                $content = $targetItem.content
                $targetItem.Content.__ItemContext()
            }

            if ( $itemContext ) {
                $fullyQualifiedUri = $itemContext.RequestUri, $content.id -join '/'
                $useFullyQualifiedUri = $true
            } else {
                $relativeId = $targetItem.id
            }

            if ( $fullyQualifiedUri -and $Uri ) {
                throw [ArgumentException]::new("Uri option may not be specified with objects with known fully qualified paths")
            }

            if ( $fullyQualifiedUri ) {
                $fullyQualifiedUri
            } else {
                if ( $Uri ) {
                    $Uri.tostring().trimend('/'), $relativeId -join '/'
                } else {
                    $relativeId
                }
            }
        }

        $commonRequestArguments = @{
            ODataFilter = $ODataFilter
            Version = $Version
            Headers = $Headers
            Permissions = $Permissions
            Cloud = $Cloud
        }

        if ( $Connection ) {
            $commonRequestArguments['Connection'] = $Connection
        }

        write-verbose "DELETE requested for target URI '$targetUri'"
        if ( $Force.IsPresent -or $pscmdlet.shouldprocess($targetUri, 'DELETE') ) {
            if ( $Force.IsPresent ) {
                write-verbose "Force option was specified to override confirmation, object will be deleted"
            }
            Invoke-GraphRequest $targetUri -Method DELETE @commonRequestArguments -AbsoluteUri:$useFullyQualifiedUri | out-null
        }
    }

    end {}
}

