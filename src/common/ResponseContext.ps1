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

# This implementation parses the OData context response from the Graph service.
# It is based on the specification for OData context URL:
#
#    http://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html#sec_ContextURL
#
# Note that it doesn't handle all of the cases covered there, just those necessary to
# reliably implement capabilities required by this module, most notably:
#
#   * Determining whether a response corresponds to an entity or collection of entities
#   * For an entity or collection of entities, is there a canonical URI?
#   * If the entity or collection being cast to a specific type, and what is that type?
#   * What properties were projected for the response?
#
# One assumption that consumers should make of this data is that it is not 100% reliable --
# services have been known to not always populate the context, or to render it incorrectly.
# As a a result, consumers should consider a reasonable fallback behavior if the data are not
# present when expected, and should also cross-check it against more reliable sources such as
# service API metadata if it is available and again adopt a fallback posture. It is advisable
# to restrict use of this information to scenarios where it is absolutely essential to
# implement a feature, and to have reasonable behaviors and documented expectations for
# cases when it is inaccurate.
#
# For example, features that need to know the derived type
# in a response can only get this information from odata context in some cases. A fallback
# could be to assume the base type described in metadata and to use that base type information
# to inform functionality. This may result in limited functionality for users compared to
# if the derived type were known, but mitigations could include
#
#   * If it's possible to know that derived types exist by analyzing metadata, a warning
#     could be given to users to notify that some functionality may be missing
#   * Users could have the option of specifying an explicit type based on their scenario
#     knowledge to force tooling to adopt the right behavior.
#
# Ideally the context URL would become as reliable a part of a Graph service as the aspects
# that return actual data and operational behavior. A more explicit behavior rather than
# document-based context URL could simplify this greatly and would avoid the need to adhere
# to the contract built up over time around the current context URL specification.

ScriptClass ResponseContext {
    $RequestUrl = $null
    $ContextUrl = $null
    $Root = $null
    $GraphUri = $null
    $TypelessGraphuri = $null
    $AbsoluteGraphUri = $null
    $TypeCast = $null
    $ExpandedProperties = $null
    $SelectedProperties = $null
    $IsReference = $false
    $IsEntity = $false
    $IsDelta = $false
    $IsNewLink = $false
    $IsDeletedLink = $false
    $IsDeletedEntity = $false
    $isParsed = $false

    $publicMap = @{
        RequestUrl = $null
        ContextUrl = $null
        Root = $null
        GraphUri = $null
        TypelessGraphUri = $null
        AbsoluteGraphUri = $null
        TypeCast = $null
        SelectedProperties = $null
        ExpandedProperties = $null
        IsReference = $false
        IsEntity = $false
        IsDelta = $false
        IsNewLink = $false
        IsDeletedLink = $false
        IsDeletedEntity = $false
    }

    function __initialize([Uri] $requestUrl, [Uri] $contextUrl) {
        if ( ! $requestUrl -and ! $contextUrl ) {
            throw [ArgumentException]::new('One of requestUrl or contextUrl must not be $null')
        }

        $this.requestUrl = $requestUrl
        $this.contextUrl = $contextUrl
    }

    function GetMetadataUri {
        __Parse
        $this.GraphUri
    }

    function ToPublicContext {
        __Parse

        $result = @{}
        $this.publicMap.keys | foreach {
            $target = $this.publicMap[$_]

            if ( ! $target ) {
                $target = $_
            }
            $result.Add($target, $this.$target)
        }

        [PSCustomObject] $result
    }

    function __Parse {
        if ( ! $this.isParsed ) {
            $context = @{}

            if ( $this.contextUrl ) {
                $contextFragment = $this.contextUrl.Fragment.trimstart('#')
                __ParseContextFragment $contextFragment.trimend('/') $context

                if ( $context['GraphUri'] ) {
                    $version = if ( $this.contextUrl.segments.length -ge 2 ) {
                        $this.contextUrl.segments[1].trimend('/')
                    }

                    $absoluteUri = $this.contextUrl.Scheme + "://" + $this.contextUrl.Host
                    if ( $version ) {
                        $absoluteUri += '/' + $version + $context.GraphUri
                    }
                    $context.Add('AbsoluteGraphUri', $absoluteUri.trimend('/'))
                }
            } else {
                $segments = $this.requestUrl.Segments
                if ( $segments.length -gt 2 ) {
                    $context['GraphUri'] = $this.GraphUri + '/' + ( ( $segments[2..($segments.length - 1)] ).trimend('/') -join '/' )
                    $context['TypelessGraphUri'] = $context['GraphUri']
                    if ( $context['GraphUri'] ) {
                        $context['AbsoluteGraphUri'] = $this.requestUrl
                    }
                    $context['Root'] = $segments[2]
                } else {
                    throw [ArgumentExeption]::new("Request URL '$($this.RequestUrl)' is not a valid Graph URI'")
                }
            }

            $context.keys | foreach {
                $this.$_ = $context[$_]
            }

            $this.isParsed = $true
        }
    }

    function __ParseContextFragment($fragment, [HashTable] $context) {
        $rawFragmentSegments = , $fragment -split '/'

        $fragmentSegments = __NormalizeSegments $rawFragmentSegments

        $fragmentSegmentsIndex = 0

        $segments = @()

        $hasTypeCastOnlySegment = $false

        $context['GraphUri'] = $null
        $context['TypelessGraphUri'] = $null

        for ($fragmentSegmentIndex = 0; $fragmentSegmentIndex -lt $fragmentSegments.length; $fragmentSegmentIndex++ ) {
            $segment = $fragmentSegments[$fragmentSegmentIndex]

            if ( $segment -eq '$ref' ) {
                # Note that references are considered "unstable" -- we don't have type information
                # about the object being referenced, so callers should not interpret this as an object
                # that can be reliably addressed, i.e. it is not a physical location.
                # Traversing this would be like traversing a symbolic link, and would result in the use
                # of a non-canonical path. In summary, any parsed information cannot be used to
                # create a canonical path. In any event, the service is unlikely to return very much context
                # for such a request other than to say that it is a reference to an entity
                $context['IsReference'] = $true
                $context['IsEntity'] = $true
                break
            } elseif ($segment -eq '$entity' ) {
                $context['IsEntity'] = $true
                # anything after this is a property path
                continue
            } elseif ( $segment -eq '$delta' ) {
                # This is always the last element
                $context['IsDelta'] = $true
                break
            } elseif ( $segment -eq '$link' ) {
                $context['IsNewLink'] = $true
            } elseif ( $segment -eq '$deletedEntity' ) {
                $context['IsDeletedEntity'] = $true
            } elseif ( $segment -eq '$deletedLink' ) {
                $context['IsDeletedLink'] = $true
            } else {
                $isLastSegment = $fragmentSegmentIndex -eq ( $fragmentSegments.length - 1 )

                if ( ! $isLastSegment ) {
                    $isLastSegment = $fragmentSegments[$fragmentSegmentIndex + 1][0] -eq '$'
                }

                $parsedSegment = __ParseSegment $segment $isLastSegment

                if ( $parsedSegment ) {
                    if ( $parsedSegment.IsRefCollection ) {
                        $context['IsReference'] = $true
                    } elseif ( ! $context['IsEntity'] ) {
                        # Anything following entity is a property-path, type-name, or select-list
                        if ( $parsedSegment.name ) {
                            $segments += $parsedSegment.Name
                        }

                        if ( $parsedSegment.Id ) {
                            $segments += $parsedSegment.Id
                        }
                    } elseif ( ! $parsedSegment.TypeCast ) {
                        # If it's not a type name, it's either an explicit select-list or a property-path,
                        # which is the equivalent of a select-list
                        $context['SelectedProperties'] = $parsedSegment.Name
                    }

                    if ( $parsedSegment.TypeCast ) {
                        $context['TypeCast'] = $parsedSegment.TypeCast
                        if ( $parsedSegment.IsTypecastOnlySegment ) {
                            $hasTypecastOnlySegment = $true
                        }
                    }

                    if ( $parsedSegment.SelectedProperties ) {
                        $context['SelectedProperties'] = $parsedSegment.SelectedProperties
                    }

                    if ( $parsedSegment.ExpandedProperties ) {
                        $context['ExpandedProperties'] = $parsedSegment.ExpandedProperties
                    }
                }
            }
        }

        $graphUri = if ( $segments -and ( $segments[0] -ne 'Collection' ) ) {
            $context['Root'] = $segments[0]
            $segments -join '/'
        }

        if ( $graphUri ) {
            $context['TypelessGraphUri'] = "/$graphUri"
        }

        if ( $context['Root'] -and $context['Root'] -ne 'Collection' ) {
            $context['GraphUri'] = if ( $hasTypeCastOnlySegment ) {
                $context['TypelessGraphuri'], $context['TypeCast'] -join '/'
            } else {
                "/$graphUri"
            }
        }
    }

    function __ParseSegment($segment, $isLastNonSystemSegment) {
        $name = $null
        $id = $null
        $expandedProperties = $null
        $selectedProperties = $null
        $typeCast = $null
        $typeCastOnly = $false
        $isRefCollection = $false

        # Look for a parameterized segment
        $parsedParameters = if ( $segment -match '(?<name>[^\(\)]+)(?<parameters>\(.+\))' ) {
            __ParseParameters $matches.parameters
        }

        if ( $parsedParameters ) {
            $selectList = $parsedParameters.SelectList
            $parameterString = $parsedParameters.Parameters

            # This may be a type cast -- if so, it has a qualified name,
            # which always has a '.', so look for that to identify the cast
            if ( $matches.name.Contains('.') ) {
                $parsedSelect = __ParseSelectList $parameterString
                $selectedProperties = $parsedSelect.SelectedProperties
                $expandedProperties = $parsedSelect.ExpandedProperties
                $typeCastOnly = $true
                $typeCast = $matches.name
            } else {
                $name = $matches.name

                if ( $parameterString.Contains('.') ) {
                    $parsedSelect = __ParseSelectList $selectList
                    $selectedProperties = $parsedSelect.SelectedProperties
                    $expandedProperties = $parsedSelect.ExpandedProperties
                    $typeCast = $parameterString
                } else {
                    # If this is the last segment not supplied by the service (as opposed to the caller), it must be a select / expand
                    if ( $isLastNonSystemSegment ) {
                        $parsedSelect = __ParseSelectList $parameterString
                        if ( $parsedSelect ) {
                            $expandedProperties = $parsedSelect.ExpandedProperties

                            if ( $parsedSelect.SelectedProperties -contains '$ref' ) {
                                $selectedProperties = $parsedSelect.SelectedProperties | where { $_ -ne '$ref' }
                                $isRefCollection = $true
                            } else {
                                $selectedProperties = $parsedSelect.SelectedProperties
                            }
                        }
                    } else {
                        # It's not the last segment, so it must be an id
                        $id = $parameterString
                    }
                }
            }
        } else {
            # There are no parameters, the name is just the segment or a type cast
            if ( $segment.Contains('.') ) {
                $typeCast = $segment
                $typeCastOnly = $true
            } else {
                $name = $segment
            }
        }

        if ( $name -or $typeCastOnly ) {
            @{
                Name = $name
                Id = $id
                ExpandedProperties = $expandedProperties
                SelectedProperties = $selectedProperties
                TypeCast = $typeCast
                IsTypeCastOnlySegment = $typeCastOnly
                IsRefCollection = $isRefCollection
            }
        }
    }

    function __ParseParameters($parameterString) {
        $parameters = $null
        $selectList = $null

        $parameters = if ( $parameterString -match '\((?<parameters>.+)\)\((?<selectlist>.+)\)$' ) {
            $selectList = $matches.selectlist
            $matches.parameters
        } elseif ( $parameterString -match '\((?<parameters>.+)\)' ) {
            $matches.parameters
        }

        if ( $parameters ) {
            [PSCustomObject] @{
                Parameters = $parameters
                SelectList = $selectList
            }
        }
    }

    function __NormalizeSegments([string[]] $segments) {
        $incompleteSegment = ''
        $normalizedSegments = @()

        $segmentIndex = 0
        foreach ( $segment in $segments ) {
            $currentSegment = if ( $incompleteSegment ) {
                $incompleteSegment += "/$segment"
                $incompleteSegment
            } else {
                $segment
            }

            if ( $currentSegment.Contains('(') -or $currentSegment.Contains(')') ) {
                $left = 0
                $right = 0
                $currentIndex = 0
                $balance = 0

                $currentSegment.GetEnumerator() | foreach {
                    if ( $_ -eq '(' ) {
                        $left += 1
                        $balance += 1
                    } elseif ( $_ -eq ')' ) {
                        $right += 1
                        $balance -= 1
                    }

                    if ( $balance -lt 0 ) {
                        throw "A segment '$currentSegment' contained too many closing ')' characters"
                    }

                    $currentIndex++
                }

                if ( $balance -eq 0 ) {
                     $incompleteSegment = ''
                } else {
                    $incompleteSegment = $currentSegment
                }
            }

            if ( ! $incompleteSegment ) {
                $normalizedSegments += $currentSegment
            }
        }

        if ( $incompleteSegment ) {
            throw "The segment '$incompleteSegment' is missing one or more closing ')' characters"
        }

        , $normalizedSegments
    }

    function __ParseSelectList($selectString) {
        # Note that this only parses the first level -- nested elements are ignored,
        # so this is incomplete.
        # TODO: Add support for multiple nesting levels

        # The approach here is to replace parenthesized expressions, including the
        # ',' characters, with a '#' that should not otherwise be in the string.
        # After that's done, the idea is that the only ',' chars that will be
        # left are those on the first level, and we can then assume those are appended
        # to expanded fields.
        $replacedEmptyParens = $selectString -replace "(\(\))+", "#"
        $replacedParens = $replacedEmptyParens -replace "(\(.+,.+\))+", "#"

        $properties = $replacedParens -split ','

        $selectedProperties = @()
        $expandedProperties = @()

        foreach ( $property in $properties ) {
            if ( $property.Contains('#') ) {
                $normalizedProperty = $property -split '/' | select -first 1
                $expandedProperty = $normalizedProperty.TrimEnd('#').TrimEnd('+')
                $expandedProperties += $expandedProperty
            } else {
                $selectedProperties += $property
            }

            $normalizedProperty = $property -split '/' | select -first 1
        }

        [PSCustomObject] @{
            SelectedProperties = $selectedProperties
            ExpandedProperties = $expandedProperties
        }
    }

    function __NormalizePath($path) {
    }
}
