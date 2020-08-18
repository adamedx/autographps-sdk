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

. (import-script ../../common/ResponseContext)

$__DefaultResultVariableName = 'LastGraphItems'
$__DefaultResultVariable = new-variable $__DefaultResultVariableName -passthru -force

ScriptClass ItemResultHelper -ArgumentList $__DefaultResultVariable {
    param($defaultResultVariableParameter)

    static {
        $defaultResultVariable = $defaultResultVariableParameter

        function GetResultVariable( $customVariableName ) {
            if ( ! $customVariableName ) {
                $this.defaultResultVariable.value = $null
                $this.defaultResultVariable
            } else {
                $existingVariable = get-variable -scope 2 $customVariableName -erroraction ignore

                if ( $existingVariable ) {
                    $existingVariable
                } else {
                    new-variable -scope 2 $customVariableName -passthru
                }
            }
        }

        function  GetResponseDetail($content, $contextUri, $nextLink, $deltaLink, $protocolResponses) {
            $deltaInfo = if ( $deltaLink ) {
                $::.GraphUtilities |=> ParseAbsoluteUri $deltaLink
            }

            $absoluteDeltaUriString = if ( $deltaInfo ) { $deltaInfo.AbsoluteUriString }
            $deltaUri = if ( $deltaInfo ) { $deltaInfo.GraphUriAndQuery }
            $deltaToken = if ( $deltaInfo ) { $deltaInfo.DeltaToken }
            $nextUri = if ( $nextLink ) {
                $nextLinkInfo = $::.GraphUtilities |=> ParseAbsoluteUri $nextLink
                if ( $nextLinkInfo -and $nextLinkInfo.GraphUriAndQuery ) {
                    $nextLinkInfo.GraphUriAndQuery
                }
            }

            $normalizedContent = if ( $content -and $content.GetType().IsArray ) { $content } else { , $content }

            $responses = foreach ( $response in $protocolResponses ) {
                [PSCustomObject] @{
                    Content = $response.RestResponse.Content
                    RawContent = $response.RestResponse.RawContent
                    RawContentLength = $response.RestResponse.RawContentLength
                    Headers = $response.RestResponse.Headers
                    StatusCode = $response.RestResponse.StatusCode
                    StatusDescription = $response.RestResponse.StatusDescription
                }
            }

            [PSCustomObject] @{
                Content = $content
                ContextUri = $contextUri
                AbsoluteNextUri = $nextLink
                NextUri = $nextUri
                AbsoluteDeltaUri = $absoluteDeltaUriString
                DeltaUri = $deltaUri
                DeltaToken = $deltaToken
                Responses = $responses
            }
        }

        function GetItemContext([Uri] $requestUri, $contextUri) {
            $requestUriNoQuery = $requestUri.GetLeftPart([System.UriPartial]::Path).replace("'", "''")
            $responseContext = new-so ResponseContext $requestUriNoQuery $contextUri |=> ToPublicContext

            # Add __ItemContext to decorate the object with its source uri.
            # Do this as a script method to prevent deserialization
            $contextGraphUri = if ( $responseContext.GraphUri ) { $responseContext.GraphUri.replace("'", "''") }
            $contextTypelessGraphUri = if ( $responseContext.TypelessGraphUri ) { $responseContext.TypelessGraphUri.replace("'", "''") }
            $contextTypeCast = $responseContext.TypeCast
            $contextIsEntity = $responseContext.IsEntity
            $contextIsDeltaLink = $responseContext.IsNewLink -or $responseContext.IsDeletedLink
            $contextIsDelta = $responseContext.IsDelta -or $responseContext.IsDeletedEntity -or $contextIsDeltaLink
            $contextIsDeltaDeleted = $responseContext.IsDeletedLink -or $responseContext.IsDeletedEntity
            $contextcontextUri = $contextUri

            $contextGraphUriString = if ( $contextGraphUri ) { "'$contextGraphUri'" } else { '$null' }
            $contextTypelessGraphUriString = if ( $contextTypelessGraphUri ) { "'$contextTypelessGraphUri'" } else { '$null' }
            $contextTypeCastString = if ( $contextTypeCast ) { "'$contextTypeCast'" } else { '$null' }
            $contextIsEntityString = if ( $contextIsEntity ) { '$true' } else { '$false' }
            $contextIsDeltaLinkString = if ( $contextIsDeltaLink ) { '$true' } else { '$false' }
            $contextIsDeltaString = if ( $contextIsDelta ) { '$true' } else { '$false' }
            $contextIsDeltaDeletedString = if ( $contextIsDeltaDeleted ) { '$true' } else { '$false' }
            $contextContextUriString = if ( $contextContextUri ) { "'$contextContextUri'" } else { '$null' }

            $scriptText = @"
                [PSCustomObject] @{
                    RequestUri='$requestUriNoQuery'
                    GraphUri=$contextGraphUriString
                    ContextUri=$contextContextUriString
                    TypelessGraphuri=$contextTypelessGraphUriString
                    TypeCast=$contextTypeCastString
                    IsEntity=$contextIsEntityString
                    IsDelta=$contextIsDeltaString
                    IsDeltaLink=$contextIsDeltaLinkString
                    IsDeltaDeleted=$contextIsDeltaDeletedString
                }
"@
            [ScriptBlock]::Create($scriptText)
        }

        function SetItemContext([object[]] $items, [ScriptBlock] $contextScript) {
            $items | foreach {
                $_ | add-member -membertype scriptmethod -name __ItemContext -value $contextScript
            }
        }
    }
}
