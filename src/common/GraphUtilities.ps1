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

ScriptClass GraphUtilities {
    static {

        function ToGraphRelativeUriPathUnqualified( $relativeUri, $context = $null ) {
            $this.__ToGraphRelativeUriPath($relativeUri, $context)
        }

        function __NormalizeBacktrack( $uriAbsoluteString ) {
            if ( $uriAbsoluteString[0] -ne '/' ) {
                throw "'$uriAbsoluteString' is not an absolute path"
            }

            $segments = $uriAbsoluteString -split '/'

            $newSegments = new-object System.Collections.Generic.List[string]

            $segments | foreach {
                if ( $_ -eq '..' ) {
                    if ( $newSegments.count -gt 0 ) {
                        $newSegments.RemoveAt($newSegments.count - 1)
                     }
                } else {
                    $newSegments.Add($_)
                }
            }

            $result = $newSegments -join '/'

            if ( $result[0] -ne '/' ) {
                $result = '/' + $result
            }
            write-verbose "Backtrack '$uriAbsoluteString' converted to '$result'"
            $result
        }

        function ToGraphRelativeUri( $relativeUri, $context = $null ) {
             __ToGraphRelativeUriPath $relativeUri $context
        }

        function __ToGraphRelativeUriPath( $relativeUri, $context = $null ) {
            $normalizedUri = ($relativeUri -split '/' | where { $_ -ne '.' }) -join '/'
            $result = if ( $relativeUri.tostring()[0] -eq '/' ) {
                [Uri] ($this.__NormalizeBacktrack($normalizedUri))
            } else {
                $graphContext = if ( $context ) {
                    $context
                } else {
                    'GraphContext' |::> GetCurrent
                }

                $locationUri = if ( $graphContext.location ) {
                    $graphContext.location |=> ToGraphUri
                } else {
                    # By default, locations are not defined, so if there isn't one,
                    # assume the root
                    '/'
                }

                $graphUri = $this.JoinGraphUri($locationUri, $normalizedUri)
                $canonicalGraphUri = __NormalizeBacktrack $graphUri.tostring()
                $canonicalGraphUri
            }

            $result
        }

        function ToLocationUriPath( $context, $relativeUri ) {
            $graphRelativeUri = $this.ToGraphRelativeUriPathUnqualified($relativeUri, $context)
            "/{0}:{1}" -f $context.name, $graphRelativeUri
        }

        function JoinAbsoluteUri([Uri] $absoluteUri, [string] $relativeUri) {
            if ( ! $absoluteUri.IsAbsoluteUri ) {
                throw "Absolute uri argument '$($absoluteUri.tostring())' is not an absolute uri"
            }

            $::.GraphUtilities.JoinFragmentUri($absoluteUri, $relativeUri)
        }

        function JoinRelativeUri([string] $relativeUri1, [string] $relativeUri2) {
            if ( $relativeUri1[0] -eq '/' ) {
                throw "'$relativeUri1' is an absolute path"
            }

            $this.JoinFragmentUri($relativeUri1, $relativeUri2)
        }

        function JoinFragmentUri([string] $fragmentUri1, [string] $fragmentUri2) {
            ($fragmentUri1.trimend('/'), $fragmentUri2.trim('/') -join '/')
        }

        function JoinGraphUri([Uri] $graphUri, [string] $relativeUri) {
            if ( $graphUri.tostring()[0] -ne '/' ) {
                throw "Graph uri parameter '$graphUri' is not an absolute graph path"
            }

            $uriString = $this.JoinFragmentUri($graphUri, $relativeUri)
            [Uri] $uriString
        }

        function ParseLocationUriPath($UriPath) {
            $context = $null
            $isAbsolute = $false
            $graphRelativeUri = $null
            if ( $UriPath ) {
                $UriString = $UriPath.tostring()
                $contextEnd = $UriString.IndexOf(':')
                $isAbsolute = $UriString[0] -eq '/'
                $graphRelativeUri = if ( $contextEnd -eq -1 ) {
                    $isAbsolute = $UriString[0] -eq '/'
                    $UriString
                } else {
                    if ( $isAbsolute ) {
                        $contextComponents = $UriString.substring(0, $contextEnd) -split '/'
                        if ( $contextComponents.length -eq 2 ) {
                            $context = $contextComponents[1]
                            $UriString.substring($contextEnd + 1, $UriString.length - $contextEnd - 1)
                        } else {
                            $UriString
                        }
                    } else {
                        $UriString
                    }
                }
            }

            [PSCustomObject]@{
                ContextName=$context
                RelativeUri=$graphRelativeUri
                IsAbsoluteUri=$isAbsolute
            }
        }

        function ParseGraphUri([Uri] $uri, $context) {
            $endpoint = $null
            $version = $null
            $sameEndpoint = $true
            $sameVersion = $true
            $isAbsolute = $uri.IsAbsoluteUri
            $matchedContext = $null

            $relativeUri = if ( $isAbsolute ) {
                $endpoint = [Uri] ('https://{0}' -f $uri.host)
                $graphRelativeUri = ''
                $version = if ( $uri.segments.length -gt 0 ) {
                    for ( $uriIndex = 2; $uriIndex -lt $uri.segments.length; $uriIndex++ ) {
                        $graphRelativeUri += $uri.segments[$uriIndex]
                    }
                    $uri.segments[1].trim('/')
                } else {
                    throw [ArgumentException]::new("Invalid uri '$($uri.tostring())'")
                }

                if ( $context ) {
                    $sameEndpoint = if ( $context.connection -and $context.connection.GraphEndpoint ) {
                        $userAbsoluteUri = $uri.absoluteuri
                        $userEndpoint = $userAbsoluteUri.substring(0, $userAbsoluteUri.length - $uri.PathAndQuery.length).trimend('/')
                        write-verbose ("Comparing endpoints: user: '{0}' vs. context '{1}'" -f $userEndpoint, $context.connection.GraphEndpoint.Graph)
                        $userEndpoint -eq ($context.connection.GraphEndpoint.Graph).tostring().trimend('/')
                    } else {
                        $false
                    }
                    $sameVersion = $version -eq $context.version
                }

                $graphRelativeUri
            } else {
                $uri
            }

            if ( $relativeUri -eq $null ) {
                throw "Invalid graph uri '$uri'"
            }

            $normalized = JoinGraphUri / $relativeUri

            $matchedContext = if ( $isAbsolute )  {
                if ( $context -and ($sameEndpoint -and $sameVersion) ) {
                    $context
                } else {
                    $::.GraphContext |=> FindContext $endpoint $version | select -first 1
                }
            } else {
                $::.GraphContext.GetCurrent()
            }

            [PSCustomObject]@{
                GraphRelativeUri = $normalized
                GraphVersion = $version
                EndpointMatchesContext = $sameEndpoint
                VersionMatchesContext = $sameVersion
                IsContextCompatible = $sameEndpoint -and ($isAbsolute -or $sameVersion)
                MatchedContext = $matchedContext
                IsAbsolute = $isAbsolute
            }
        }

        function ParseGraphRelativeLocation([string] $locationUri) {
            $graphName = if ( $locationUri.startswith('/') ) {
                $segments = $locationUri.tostring() -split '/'
                if ( $segments[1].endswith(':') ) {
                    ($locationUri -split ':')[0].trimstart('/')
                }
            }

            # Handle absolute web uri's, e.g. https://mygraph.microsoft.com/v1.0/singleton/etc
            $locationUriAsWebUri = [Uri] $locationUri

            if ( $locationUriAsWebUri.IsAbsoluteUri -and ( !( !$locationUriAsWebUri.host) ) -eq $true ) {
                # This is an absolute web uri
                $parsedUri = ParseGraphUri $locationUriAsWebUri
                @{
                    Context = $parsedUri.MatchedContext
                    GraphRelativeUri = $parsedUri.GraphRelativeUri
                }
            } else {
                $relativeUri = $locationUri
                $context = if ( ! $graphName ) {
                    $::.GraphContext |=> GetCurrent
                } else {
                    # Start 2 after graphname due to the required '/' and ':' in '/graphname:', and account for that in length as well
                    $relativeUri = $locationUri.substring($graphName.length + 2, $locationUri.length - $graphName.length - 2)
                    $::.logicalgraphmanager.Get().contexts[$graphName].Context
                }

                @{
                    Context = $context
                    GraphRelativeUri = $::.GraphUtilities |=> ToGraphRelativeUri $relativeUri $context
                }
            }
        }

        function IsDeltaUri([Uri] $uri) {
            $uriString = GetUriNoQuery $uri

            $lastSegment = ($uriString -split '/' | select -last 1).trimend('/')
            $lastSegment -eq 'delta' -or $lastSegment -eq 'microsoft.graph.delta'
        }

        function ParseAbsoluteUri([Uri] $uri) {
            $uriString = GetUriNoQuery $uri

            $query = ( $uri.query -split '\?' )[1]
            $parameters = $query -split '='

            $deltaToken = for ( $parameterIndex = 0; $parameterIndex -lt $parameters.length; $parameterIndex++ ) {
                if ( $parameters[$parameterIndex] -eq '$deltatoken' ) {
                    if ( ( $parameterIndex + 1 ) -lt $parameters.length ) {
                        $parameters[$parameterIndex + 1]
                        break
                    }
                }
            }

            $graphUri = ($::.GraphUtilities |=> ParseGraphUri $uriString).GraphRelativeUri

            [PSCustomObject] @{
                AbsoluteUriString = $uriString
                GraphUri = $graphUri
                GraphUriAndQuery = $graphUri.tostring() + $uri.query
                DeltaToken = $deltatoken
            }
        }

        function GetUriNoQuery([Uri] $uri) {
            $pathAndQuery = $uri.tostring() -split '\?'
            if ( ! $pathAndQuery -or ( $pathAndQuery.length -lt 1 ) -or ( $pathAndQuery.length -gt 2 ) ) {
                throw [ArgumentException]::new("The URI '$uri' is not a valid URI")
            }

            $uriQueryLength = if ( $pathAndQuery.length -gt 1 ) { $pathAndQuery[1].length + 1 } else { 0 }
            $uri.OriginalString.substring(0, $uri.OriginalString.length - $uriQueryLength)
        }

        function GetOptionalTypeFromResponseObject($object) {
            if ( $object | gm '@odata.type' -erroraction ignore ) {
                $object.'@odata.type'.trimstart('#')
            }
        }

        function GetAbstractUriFromResponseObject($object, $assumeEntity, $explicitId) {
            $objectContext = GetResponseObjectContext $object

            if ( $objectContext ) {
                $id = if ( $object | gm id -erroraction ignore ) {
                    $object.id
                }

                $isEntity = $objectContext.IsEntity -or $objectContext.IsDelta
                $idNotNeededOrInItem = $assumeEntity -or ! $isEntity

                $targetId = if ( $id ) {
                    $id
                } else {
                    $explicitId
                }

                $typelessUri = $objectContext.TypelessGraphUri

                # If we have an id, we'll return something if it's known to be entity,
                # if we were told to assume that its an entity
                if ( $targetId ) {
                    $result = $typelessUri
                    if ( $result  ) {
                        $normalizedUri = $result.trimend('/')
                        if ( $normalizedUri.tolower().endswith($targetId.tolower()) ) {
                            $result
                        } elseif ( $assumeEntity -or $isEntity ) {
                            $result.trimend('/'), $targetId -join '/'
                        }
                    }
                    # If there is no typeless URI, we will return nothing
                } elseif ( ! $idNotNeededOrInItem ) {
                    $typelessUri
                }

                # If we return $null, it is because there was no typeless uri OR
                # we needed an id and couldn't get one. The latter case happens
                # because (1) we were instructed to assume this was an entity
                # regardless even if the context does not mark it as such explicitly,
                # or (2) we know for sure that the item is an entity
            }
        }

        function GetResponseObjectContext($object) {
            if ( $object | gm -membertype scriptmethod __ItemContext -erroraction ignore ) {
                $object.__ItemContext()
            }
        }
    }
}
