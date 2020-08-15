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

Describe 'GraphUtilities methods' {
    Context 'When Parsing the relative Uri with the ParseGraphRelativeUri static method' {
        $relativeUri = 'teams/74268ac2-b550-4d36-99a9-34988bab4cf5/channels/43:32872541-732c-4a76-81ea-d1881cc9e290@thread.skype'
        $graphName = 'v2.0'

        $context1 = @{Name='v1.0';Version='v1.0';location=$null}
        $context2 = @{Name='v2.0';Version='v2.0';location=$null}
        $contextTable = @{'v1.0'=@{Context=$context1};'v2.0'=@{Context=$context2}}

        $mockGraphManager = New-ScriptObjectMock LogicalGraphManager -propertyvalues @{contexts = $contextTable}
        Mock-ScriptClassMethod -static LogicalGraphManager Get { $MockContext } -MockContext $mockGraphManager

        It 'Should return the default context as the context, and exactly the uri as the relativeUri preceded by "/" if the path does not start with "/"' {
            $testUri = $relativeUri
            $result = $::.GraphUtilities |=> ParseGraphRelativeLocation $testUri

            $result.Context.Version | Should Be 'v1.0'
            $result.GraphRelativeUri | Should Be "/$testUri"
        }

        It "Should still return the default context and exactly the uri as the relative uri preceded by '/' if the path does not start with '/' even if it ends with a ':'" {
            $testUri = ($graphName + ":"), $relativeUri -join '/'
            $result = $::.GraphUtilities |=> ParseGraphRelativeLocation $testUri

            $result.Context.Version | Should Be 'v1.0'
            $result.GraphRelativeUri | Should Be "/$testUri"

        }

        It "Should return the default context if the uri starts with '/' but its first segment does not end in ':'" {
            $testUri = '/', $relativeUri -join '/'
            $result = $::.GraphUtilities |=> ParseGraphRelativeLocation $testUri

            $result.Context.Version | Should Be 'v1.0'
            $result.GraphRelativeUri | Should Be $testUri
        }

        It "Should return the default context if the uri starts with '/' but its first segment does not end in ':' even if it contains a ':' elsewhere" {
            $testUri = 'bad:name', $relativeUri -join '/'
            $result = $::.GraphUtilities |=> ParseGraphRelativeLocation $testUri

            $result.Context.Version | Should Be 'v1.0'
            $result.GraphRelativeUri | Should Be "/$testUri"
        }

        It "Should return the specified context if the uri starts with '/' and  its first segment ends in ':'" {
            $testUri = ('/' + $graphName + ':'), $relativeUri -join '/'
            $result = $::.GraphUtilities |=> ParseGraphRelativeLocation $testUri

            $result.Context.Version | Should Be $graphName
            $result.GraphRelativeUri | Should Be "/$relativeUri"
        }

        It "Should throw an exception if the first segment starts with '/', ends in ':', and contains another ':'" {
            $testUri = "v2:01:", $relativeUri -join '/'
            { $result = $::.GraphUtilities |=> ParseGraphRelativeLocation "/$testUri" } | Should Throw
        }

        It 'Should return the context and the root path "/" as the relative uri if given a path starting with "/" followed by a context name and ":" and nothing else' {
            $testUri = ('/' + $graphName + ':')
            $result = $::.GraphUtilities |=> ParseGraphRelativeLocation $testUri

            $result.Context.Version | Should Be $graphName
            $result.GraphRelativeUri | Should Be '/'
        }

        It 'Should return the context and the root path "/" as the relative uri if given a path starting with "/" followed by a context name and ":" followed by "/"' {
            $testUri = ('/' + $graphName + ':/')
            $result = $::.GraphUtilities |=> ParseGraphRelativeLocation $testUri

            $result.Context.Version | Should Be $graphName
            $result.GraphRelativeUri | Should Be '/'
        }

        It 'Should return the default context and a path containing a ":" if the path is simply a graph name followed by ":" and no "/" characters' {
            $testUri = $graphName
            $result = $::.GraphUtilities |=> ParseGraphRelativeLocation $testUri

            $result.Context.Version | Should Be 'v1.0'
            $result.GraphRelativeUri | Should Be "/$graphName"
        }
    }

    Context "When retrieving information about the request context from a response item returned by the Graph service through GetAbstractUriFromItem" {
        function NewTestItemWithContext($requestUri, $contextUri, $id) {
            # The id is used to populate the id field of the object,
            # which must be present unless it is not selected or the object
            # being returned is not an entity type (e.g. a complex type)
            $itemContext = $::.ItemResultHelper |=> GetItemContext $requestUri $contextUri

            $objectTable = @{}

            if ( $id ) {
                $objectTable.Add('id', $id)
            }

            $object = [PSCUstomObject] $objectTable

            $::.ItemResultHelper |=> SetItemContext @($object) $itemContext

            $object
        }

        It 'Should return a URI similar to the request URI when the request URI specified an id from an entity set' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users/$entity'

            $item = (NewTestItemWithContext $requestUri $contextUri userid)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be $requestUri
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $true

            $::.GraphUtilities |=> GetAbstractUriFromItem $item | Should Be '/users/userid'
        }

        It 'Should return null when the request URI specified an id from an entity set and the assumeEntity option is true' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users/$entity'

            $item = (NewTestItemWithContext $requestUri $contextUri userid)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be $requestUri
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $true

            $::.GraphUtilities |=> GetAbstractUriFromItem $item $true | Should Be '/users/userid'
        }

        It 'Should return a URI similar to the request URI with an additional id segment when the request URI specified an entity set and assumeEntity is true' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users'

            $item = (NewTestItemWithContext $requestUri $contextUri userid)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be $requestUri
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $false

            $::.GraphUtilities |=> GetAbstractUriFromItem $item $true | Should Be '/users/userid'
        }

        It 'Should return a URI similar to the request URI with an additional id segment when the request URI specified an entity set and assumeEntity is true and a default id is specified and the response object does not have an id' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users?$select=displayName'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(displayName)'

            # No id since select did not include it
            $item = (NewTestItemWithContext $requestUri $contextUri)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be ( $requestUri -split '\?' )[0]
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $false

            $::.GraphUtilities |=> GetAbstractUriFromItem $item $true myoverrideid | Should Be '/users/myoverrideid'
        }

        It 'Should return null when the request URI specified an entity set and assumeEntity is false but a default id is specified because the response object does not have an id' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users?$select=displayName'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(displayName)'

            # No id since select did not include it
            $item = (NewTestItemWithContext $requestUri $contextUri)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be ( $requestUri -split '\?' )[0]
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $false

            $::.GraphUtilities |=> GetAbstractUriFromItem $item $false myoverrideid | Should Be $null
        }

        It 'Should return null when the request URI specified an entity and assumeEntity is true but a default id is not specified and the response object does not have an id' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid?$select=displayName'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(displayName)/$entity'

            # no id since select did not include it
            $item = (NewTestItemWithContext $requestUri $contextUri)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be ( $requestUri -split '\?' )[0]
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $true

            $::.GraphUtilities |=> GetAbstractUriFromItem $item $true | Should Be $null
        }

        It 'Should return Should return a URI similar to the request URI when the request URI specified an id for an entity when and assumeEntity is $false and a default id is specified and the response object does not have an id and an explicit override id is supplied (this is used to complete the uri)' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid?$select=displayName'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(displayName)/$entity'

            # no id since select did not include it
            $item = (NewTestItemWithContext $requestUri $contextUri)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be ( $requestUri -split '\?' )[0]
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $true

            $::.GraphUtilities |=> GetAbstractUriFromItem $item $false userid | Should Be '/users/userid'
        }

        It 'Should return Should return a URI similar to the request URI when the request URI specified an id for an entity when and assumeEntity is $true and a default id is specified and the response object does not have an id and an explicit override id is supplied (this is used to complete the uri)' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid?$select=displayName'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(displayName)/$entity'

            # no id since select did not include it
            $item = (NewTestItemWithContext $requestUri $contextUri)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be ( $requestUri -split '\?' )[0]
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $true

            $::.GraphUtilities |=> GetAbstractUriFromItem $item $true userid | Should Be '/users/userid'
        }

        It 'Should return $null when the request URI specified an entity set and assumeEntity is set to false and no id override is specified' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users'

            $item = (NewTestItemWithContext $requestUri $contextUri userid)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be $requestUri
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $false

            $::.GraphUtilities |=> GetAbstractUriFromItem $item $false | Should Be $null
        }

        It 'Should return the entity set when the request URI specified an entity set and assumeEntity is true and the response object does not have an id and no override is specified' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users?$select=displayName'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(displayName)'

            # no id since select did not include it
            $item = (NewTestItemWithContext $requestUri $contextUri)
            $itemWithContext = $item.__ItemContext()

            $itemWithContext.GraphUri | Should Be '/users'
            $itemWithContext.TypelessGraphUri | Should Be '/users'
            $itemWithContext.ContextUri | Should Be $contextUri
            $itemWithContext.RequestUri | Should Be ( $requestUri -split '\?' )[0]
            $itemWithContext.TypeCast | Should Be $null
            $itemWithContext.IsEntity | Should Be $false

            $::.GraphUtilities |=> GetAbstractUriFromItem $item | Should Be $null
        }

    }
}
