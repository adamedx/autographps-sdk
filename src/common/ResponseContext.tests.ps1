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

. $psscriptroot/ResponseContext.ps1

Describe 'ResponseContext class' {
    Context "When parsing a response context URL" {
        It 'Should throw if the ResponseContext instance is initialized with both requestUrl and contextUrl set to $null' {
            { $responseContext = new-so ResponseContext $null $null } | Should Throw 'must not be $null'
        }

        It 'Should be able to parse a users entity set graph URI of the form "https://graph.microsoft.com/v1.0/$metadata#users/$entity" and request url is null' {
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users/$entity'

            $responseContext = new-so ResponseContext $null $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $null
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $true
            $responseContext.Root | Should Be 'users'
        }

        It "Should be able to parse a users entity set graph URI when only the request url is supplied" {
            $requestUri = 'https://graph.microsoft.com/v1.0/users'

            $responseContext = new-so ResponseContext $requestUri $null |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $null
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be 'users'
        }

        It 'Should be able to parse a users entity set graph URI of the form "https://graph.microsoft.com/v1.0/$metadata#users/$entity" and request url is "https://graph.microsoft.com/v1.0/users/userid"' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users/$entity'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $true
            $responseContext.Root | Should Be 'users'
        }
    }

    Context 'When ResponseContext processes the URLs from the OData 4.01 specification examples for Context URL at https://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html#sec_ContextURL' {

        It 'Should correctly parse example 10.1 Service Document - {context-url} - with $metadata segment' {
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata'

            $responseContext = new-so ResponseContext $null $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be $null
            $responseContext.TypelessGraphUri | Should Be $null
            $responseContext.AbsoluteGraphUri | Should Be $null
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $null
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be $null
        }

        It 'Should correctly parse example 10.1 Service Document - {context-url} - without $metadata segment' {
            $contextUri = 'https://graph.microsoft.com/v1.0'

            $responseContext = new-so ResponseContext $null $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be $null
            $responseContext.TypelessGraphUri | Should Be $null
            $responseContext.AbsoluteGraphUri | Should Be $null
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $null
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be $null
        }

        It "Should correctly parse example 10.2 Collection of Entities - {context-url}#{entity=set}" {
            $requestUri = 'https://graph.microsoft.com/v1.0/users'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be 'users'
        }

        It "Should correctly parse example 10.2 Collection of Entities - {context-url}#Collection({type-name})" {
            $requestUri = 'https://graph.microsoft.com/v1.0/users'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(microsoft.graph.user)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'microsoft.graph.user'
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be 'users'
        }

        It 'Should correctly parse 10.3 Entity - {context-url}#{entity-set}/$entity' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users/$entity'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $true
            $responseContext.Root | Should Be 'users'
        }

        It "Should correctly parse 10.3 Entity - {context-url}#{type-name} -- can be used in cases when entity is returned from an action or function" {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/someaction'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#graph.user'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be $null
            $responseContext.TypelessGraphUri | Should Be $null
            $responseContext.AbsoluteGraphUri | Should Be $null
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'graph.user'
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be $null
        }

        It "Should correctly parse 10.4 Singleton - {context-url}#{singleton}" {
            $requestUri = 'https://graph.microsoft.com/v1.0/me'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#me'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/me'
            $responseContext.TypelessGraphUri | Should Be '/me'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/me'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be 'me'
        }

        It 'Should correctly parse 10.6 Derived Entity - {context-url}#{entity-set}{/type-name}/$entity' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid/Mail.User'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users/Mail.User/$entity'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext
            $responseContext.GraphUri | Should Be '/users/Mail.User'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users/Mail.user'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'Mail.User'
            $responseContext.IsEntity | Should Be $true
            $responseContext.Root | Should Be 'users'
        }

        It 'Should correctly parse 10.7 Collection of Projected Entities - {context-url}#{entity-set}{/type-name}{select-list}' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users?$select=displayName,mail'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(displayName,mail)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext
            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be ('displayName', 'mail' | sort)
            $responseContext.Root | Should Be 'users'
        }

        It 'Should correctly parse 10.7 Collection of Projected Entities - {context-url}#Collection({type-name}){select-list}' {
            $requestUri = 'https://graph.microsoft.com/v1.0/me/memberOf/microsoft.graph.group?$select=displayName,id'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#groups(microsoft.graph.group)(displayName,id)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext
            $responseContext.GraphUri | Should Be '/groups'
            $responseContext.TypelessGraphUri | Should Be '/groups'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/groups'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'microsoft.graph.group'
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be ('displayName', 'id' | sort)
            $responseContext.Root | Should Be 'groups'
        }

        It 'Should correctly parse 10.8 Projected Entity - {context-url}#{entity-set}{select-list}/$entity' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid/?$select=displayName,mail'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users(displayName,mail)/$entity'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext
            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $true
            $responseContext.SelectedProperties | sort | Should Be ('displayName', 'mail' | sort)
            $responseContext.Root | Should Be 'users'
        }

        It 'Should correctly parse 10.8 Projected Entity - {context-url}#{entity-set}{/type-name}{select-list}/$entity' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/userid/microsoft.graph.user?$select=displayName,mail'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users/microsoft.graph.user(displayName,mail)/$entity'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/users/microsoft.graph.user'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users/microsoft.graph.user'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'microsoft.graph.user'
            $responseContext.IsEntity | Should Be $true
            $responseContext.SelectedProperties | sort | Should Be ('displayName', 'mail' | sort)
            $responseContext.Root | Should Be 'users'
        }

        It 'Should correctly parse 10.8 Projected Entity - {context-url}#{singleton}{select-list}' {
            $requestUri = 'https://graph.microsoft.com/v1.0/me?$select=displayName,mail'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#me(displayName,mail)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/me'
            $responseContext.TypelessGraphUri | Should Be '/me'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/me'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be ('displayName', 'mail' | sort)
            $responseContext.Root | Should Be 'me'
        }

        It 'Should correctly parse 10.8 Projected Entity - {context-url}#{type-name}{select-list}' {
            $requestUri = 'https://graph.microsoft.com/v1.0/groups/groupid/members?$select=displayName,mail'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#microsoft.graph.directoryObject(displayName,mail)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be $null
            $responseContext.TypelessGraphUri | Should Be $null
            $responseContext.AbsoluteGraphUri | Should Be $null
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'microsoft.graph.directoryObject'
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be ('displayName', 'mail' | sort)
            $responseContext.Root | Should Be $null
        }

        It "Should correctly parse 10.9 Projected Entity - {context-url}#{entity-set}{select-list} when a property is expanded" {
            $requestUri = 'https://host/service/Customers?$select=Name,Company&$expand=Address,Office'
            $contextUri = 'https://host/service/$metadata#Customers(Name,Address(),Office(),Company)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/Customers'
            $responseContext.TypelessGraphUri | Should Be '/Customers'
            $responseContext.AbsoluteGraphUri | Should Be 'https://host/service/Customers'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be ('Name', 'Company' | sort)
            $responseContext.ExpandedProperties | sort | Should Be ('Address', 'Office' | sort)
            $responseContext.Root | Should Be 'Customers'
        }

        It "Should correctly parse 10.9 Projected Entity - {context-url}#{entity-set}{/type-name}{select-list} when a property is expanded" {
            $requestUri = 'https://host/service/Customers/Customer.Wholesale?$select=Name,Company&$expand=Address,Office'
            $contextUri = 'https://host/service/$metadata#Customers/Customer.Wholesale(Name,Address(),Office(),Company)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/Customers/Customer.Wholesale'
            $responseContext.TypelessGraphUri | Should Be '/Customers'
            $responseContext.AbsoluteGraphUri | Should Be 'https://host/service/Customers/Customer.Wholesale'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'Customer.Wholesale'
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be ('Name', 'Company' | sort)
            $responseContext.ExpandedProperties | sort | Should Be ('Address', 'Office' | sort)
            $responseContext.Root | Should Be 'Customers'
        }

        It "Should correctly parse 10.9 Projected Entity - {context-url}#{entity-set}{select-list} when a navigation property's property is expanded" {
            $requestUri = 'https://host/service/Customers?$select=Name&$expand=Address/Country'
            $contextUri = 'https://host/service/$metadata#Customers(Name,Address/Country())'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/Customers'
            $responseContext.TypelessGraphUri | Should Be '/Customers'
            $responseContext.AbsoluteGraphUri | Should Be 'https://host/service/Customers'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | Should Be @('Name')
            $responseContext.ExpandedProperties | Should Be @('Address')
            $responseContext.Root | Should Be 'Customers'
        }

        It "Should correctly parse 10.9 Projected Entity - {context-url}#{entity-set}{select-list} should throw when a segment does not contain equal number of open and closed parens" {
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address/Country(())' |=> ToPublicContext | out-null } | Should Throw "is missing one or more closing"
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address/Country()))' |=> ToPublicContext | out-null } | Should Throw "contained too many closing"
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address/Country))' |=> ToPublicContext | out-null } | Should Throw "contained too many closing"
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address/Country()' |=> ToPublicContext | out-null } | Should Throw "is missing one or more closing"
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address(())' |=> ToPublicContext | out-null } | Should Throw "is missing one or more closing"
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address()))' |=> ToPublicContext | out-null } | Should Throw "contained too many closing"
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address))' |=> ToPublicContext | out-null } | Should Throw "contained too many closing"
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address()' |=> ToPublicContext | out-null } | Should Throw "is missing one or more closing"
        }

        It "Should correctly parse 10.9 Projected Entity - {context-url}#{entity-set}{select-list} should throw when a segment contains equal number of open and closed parens but they are not balanced" {
            { new-so ResponseContext $null 'https://host/service/$metadata#Customers(Name,Address/Country))(()' |=> ToPublicContext | out-null } | Should Throw "contained too many closing"
        }

        It 'Should correctly parse 10.10 Expanded Entity - {context-url}#{entity-set}{/type-name}{select-list}/$entity and {/type-name} segment is not specified' {
            $requestUri = 'https://host/service/Employees(1)?$expand=DirectReports($select=FirstName,LastName)'
            $contextUri = 'https://host/service/$metadata#Employees(DirectReports+(FirstName,LastName))/$entity'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/Employees'
            $responseContext.TypelessGraphUri | Should Be '/Employees'
            $responseContext.AbsoluteGraphUri | Should Be 'https://host/service/Employees'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $true
            $responseContext.SelectedProperties | sort | Should Be $null
            $responseContext.ExpandedProperties | sort | Should Be ('DirectReports' | sort)
            $responseContext.Root | Should Be 'Employees'
        }

        It 'Should correctly parse 10.10 Expanded Entity - {context-url}#{entity-set}{/type-name}{select-list}/$entity and the type-name is specified' {
            $requestUri = 'https://host/service/Employees(1)/Sales.Manager?$expand=DirectReports($select=FirstName,LastName)'
            $contextUri = 'https://host/service/$metadata#Employees/Sales.Manager(DirectReports+(FirstName,LastName))/$entity'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/Employees/Sales.Manager'
            $responseContext.TypelessGraphUri | Should Be '/Employees'
            $responseContext.AbsoluteGraphUri | Should Be 'https://host/service/Employees/Sales.Manager'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'Sales.Manager'
            $responseContext.IsEntity | Should Be $true
            $responseContext.SelectedProperties | sort | Should Be $null
            $responseContext.ExpandedProperties | sort | Should Be ('DirectReports' | sort)
            $responseContext.Root | Should Be 'Employees'
        }

        It 'Should correctly parse 10.10 Expanded Entity - {context-url}#{singleton}{select-list}' {
            $requestUri = 'https://host/service/me$expand=DirectReports($select=FirstName,LastName)'
            $contextUri = 'https://host/service/$metadata#me(DirectReports+(FirstName,LastName))'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/me'
            $responseContext.TypelessGraphUri | Should Be '/me'
            $responseContext.AbsoluteGraphUri | Should Be 'https://host/service/me'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be $null
            $responseContext.ExpandedProperties | sort | Should Be ('DirectReports' | sort)
            $responseContext.Root | Should Be 'me'
        }

        It 'Should correctly parse 10.10 Expanded Entity - {context-url}#{type-name}{select-list}' {
            $requestUri = 'https://host/service/Employees/Managers?$expand=DirectReports($select=FirstName,LastName)'
            $contextUri = 'https://host/service/$metadata#Sales.Manager(DirectReports+(FirstName,LastName))'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be $null
            $responseContext.TypelessGraphUri | Should Be $null
            $responseContext.AbsoluteGraphUri | Should Be $null
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'Sales.Manager'
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be $null
            $responseContext.ExpandedProperties | sort | Should Be ('DirectReports' | sort)
            $responseContext.Root | Should Be $null
        }

        It 'Should correctly parse a context URI for 10.11 collection of entity references of the form {context-url}#Collection($ref) -- this means the context URL does not contain the type of the referenced entities' {
            $requestUri = 'https://host/service/Employees(1)/Orders/$ref'
            $contextUri = 'https://host/service/$metadata#Collection($ref)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be $null
            $responseContext.TypelessGraphUri | Should Be $null
            $responseContext.AbsoluteGraphUri | Should Be $null
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | Should Be $null
            $responseContext.ExpandedProperties | Should Be $null
            $responseContext.Root | Should Be $null
            $responseContext.IsReference | Should Be $true
        }

        It 'Should correctly parse a context URI for 10.12 a single entity reference of the form {context-url}#$ref -- this means the context URL does not contain the type of the referenced entitiy' {
            $requestUri = 'https://host/service/Orders(10643)/Customer/$ref'
            $contextUri = 'https://host/service/$metadata#$ref'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be $null
            $responseContext.TypelessGraphUri | Should Be $null
            $responseContext.AbsoluteGraphUri | Should Be $null
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $true
            $responseContext.SelectedProperties | Should Be $null
            $responseContext.ExpandedProperties | Should Be $null
            $responseContext.Root | Should Be $null
            $responseContext.IsReference | Should Be $true
        }

        It 'Should correctly parse 10.13 Property Value: {context-url}#{entity}/{property-path}{select-list}' {
            $requestUri = 'https://host/service/Employees(1)/Address?$select=City,State'
            $contextUri = 'https://host/service/$metadata#Employees/Address(City,State)'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/Employees/Address'
            $responseContext.TypelessGraphUri | Should Be '/Employees/Address'
            $responseContext.AbsoluteGraphUri | Should Be 'https://host/service/Employees/Address'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be ('City', 'State' | sort)
            $responseContext.ExpandedProperties | sort | Should Be $null
            $responseContext.Root | Should Be 'Employees'
        }

        It -Skip 'Should correctly parse 10.14 Collection of Complex or Primitive Types: {context-url}#Collection({type-name}){select-list} -- should be covered by other cases so not explicitly tested' {
        }

        It -Skip 'Should correctly parse 10.16 Operation Result: {context-url}#{entity-set}{/type-name}{select-list} {context-url}#{entity-set}{/type-name}{select-list}/$entity {context-url}#{entity}/{property-path}{select-list} {context-url}#Collection({type-name}){select-list} {context-url}#{type-name}{select-list} -- should be covered by other cases so not explicitly tested' {
        }

        It 'Should correctly parse 10.17 Delta Payload Response: {context-url}#{entity-set}{/type-name}{select-list}/$delta' {
            $requestUri = 'https://host/service/Employees(1)/Sales.Manager?$select=FirstName,LastName/$delta'
            $contextUri = 'https://host/service/$metadata#Employees/Sales.Manager(FirstName,LastName)/$delta'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/Employees/Sales.Manager'
            $responseContext.TypelessGraphUri | Should Be '/Employees'
            $responseContext.AbsoluteGraphUri | Should Be 'https://host/service/Employees/Sales.Manager'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be 'Sales.Manager'
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | sort | Should Be ( 'FirstName', 'LastName' | sort )
            $responseContext.ExpandedProperties | Should Be $null
            $responseContext.Root | Should Be 'Employees'
            $responseContext.IsDelta | Should Be $true
        }

        It 'Should correctly parse 10.17 Delta Payload Response: The context URL of an update request body for a collection of entities is simply the fragment #$delta' {
            $requestUri = 'https://graph.microsoft.com/v1.0/groups/mygroup/members'
            $contextUri = 'https://host/service/$metadata#$delta'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be $null
            $responseContext.TypelessGraphUri | Should Be $null
            $responseContext.AbsoluteGraphUri | Should Be $null
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsEntity | Should Be $false
            $responseContext.SelectedProperties | Should Be $null
            $responseContext.ExpandedProperties | Should Be $null
            $responseContext.Root | Should Be $null
            $responseContext.IsReference | Should Be $false
            $responseContext.IsDelta | Should Be $true
        }

        It 'Should correctly parse 10.18 Item in a Delta Payload Response: {context-url}#{entity-set}/$deletedEntity' {
            $requestUri = 'https://graph.microsoft.com/v1.0/users/?$deltaToken=xxxxx'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#users/$deletedEntity'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/users'
            $responseContext.TypelessGraphUri | Should Be '/users'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/users'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsDeletedEntity | Should Be $true
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be 'users'
        }

        It 'Should correctly parse 10.18 Item in a Delta Payload Response: {context-url}#{entity-set}/$deletedLink' {
            $requestUri = 'https://graph.microsoft.com/v1.0/groups/?$deltaToken=xxxxx'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#groups/$deletedLink'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/groups'
            $responseContext.TypelessGraphUri | Should Be '/groups'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/groups'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsDeletedLink | Should Be $true
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be 'groups'
        }

        It 'Should correctly parse 10.18 Item in a Delta Payload Response: {context-url}#{entity-set}/$link' {
            $requestUri = 'https://graph.microsoft.com/v1.0/groups/?$deltaToken=xxxxx'
            $contextUri = 'https://graph.microsoft.com/v1.0/$metadata#groups/$link'

            $responseContext = new-so ResponseContext $requestUri $contextUri |=> ToPublicContext

            $responseContext.GraphUri | Should Be '/groups'
            $responseContext.TypelessGraphUri | Should Be '/groups'
            $responseContext.AbsoluteGraphUri | Should Be 'https://graph.microsoft.com/v1.0/groups'
            $responseContext.ContextUrl | Should Be $contextUri
            $responseContext.RequestUrl | Should Be $requestUri
            $responseContext.TypeCast | Should Be $null
            $responseContext.IsNewLink | Should Be $true
            $responseContext.IsEntity | Should Be $false
            $responseContext.Root | Should Be 'groups'
        }
    }
}

<#
https://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html#sec_ContextURL



10.1 Service Document
{context-url}

https://host/service/
https://host/service/$metadata

10.2 Collection of Entities
{context-url}#{entity-set}
{context-url}#Collection({type-name})

https://host/service/Customers
https://host/service/$metadata#Customers

https://host/service/Orders(4711)/Items
https://host/service/$metadata#Orders(4711)/Items

10.3 Entity
{context-url}#{entity-set}/$entity
{context-url}#{type-name}

https://host/service/Customers(1)
https://host/service/$metadata#Customers/$entity

Example 14: resource URL and corresponding context URL for contained entity
https://host/service/Orders(4711)/Items(1)
https://host/service/$metadata#Orders(4711)/Items/$entity

10.4 Singleton
Context URL template:

{context-url}#{singleton}

# If a response or response part is a singleton, its name is the context URL fragment.

Example 15: resource URL and corresponding context URL

https://host/service/MainSupplier
https://host/service/$metadata#MainSupplier

10.5 Collection of Derived Entities
{context-url}#{entity-set}{/type-name}

If an entity set consists exclusively of derived entities, a type-cast segment is added to the context URL.

Example 16: resource URL and corresponding context URL

https://host/service/Customers/Model.VipCustomer

https://host/service/$metadata#Customers/Model.VipCustomer

10.6 Derived Entity
Context URL template:

{context-url}#{entity-set}{/type-name}/$entity

If a response or response part is a single entity of a type derived from the declared type of an entity set, a type-cast segment is appended to the entity set name.

Example 17: resource URL and corresponding context URL

https://host/service/Customers(2)/Model.VipCustomer

https://host/service/$metadata#Customers/Model.VipCustomer/$entity

10.7 Collection of Projected Entities
Context URL templates:

{context-url}#{entity-set}{/type-name}{select-list}

{context-url}#Collection({type-name}){select-list}

If a result contains only a subset of properties, the parenthesized comma-separated list of the selected defined or dynamic properties, instance annotations, navigation properties, functions, and actions is appended to the context URL representing the collection of entities.

Regardless of how contained structural properties are represented in the request URL (as paths or as select options) they are represented in the context URL using path syntax, as defined in OData 4.0.

The shortcut * represents the list of all structural properties. Properties defined on types derived from the declared type of the entity set (or type specified in the type-cast segment if specified) are prefixed with the qualified name of the derived type as defined in [OData-ABNF].

The list also contains explicitly selected or expanded instance annotations. It is possible to select or expand only instance annotations, in which case only those selected or expanded annotations appear in the result. Note that annotations specified only in the include-annotations preference do not appear in the context URL and do not affect the selected/expanded properties.

Operations in the context URL are represented using the namespace- or alias-qualified name. Function names suffixed with parentheses represent a specific overload, while function names without parentheses represent all overloads of the function.

OData 4.01 responses MAY use the shortcut pattern {namespace}.* to represent the list of all bound actions or functions available for entities in the collection, see system query option $select.

Example 18: resource URL and corresponding context URL

https://host/service/Customers?$select=Address,Orders

https://host/service/$metadata#Customers(Address,Orders)

10.8 Projected Entity
Context URL templates:

{context-url}#{entity-set}{/type-name}{select-list}/$entity

{context-url}#{singleton}{select-list}

{context-url}#{type-name}{select-list}

If a single entity contains a subset of properties, the parenthesized comma-separated list of the selected defined or dynamic properties, instance annotations, navigation properties, functions, and actions is appended to the {entity-set} after an optional type-cast segment and prior to appending /$entity. If the response is not a subset of a single entity set, the {select-list} is instead appended to the {type-name} of the returned entity.

Regardless of how contained structural properties are represented in the request URL (as paths or as select options) they are represented in the context URL using path syntax, as defined in OData 4.0.

The shortcut * represents the list of all structural properties. Properties defined on types derived from the type of the entity set (or type specified in the type-cast segment if specified) are prefixed with the qualified name of the derived type as defined in [OData-ABNF]. Note that expanded properties are automatically included in the response.

The list also contains explicitly selected or expanded instance annotations. It is possible to select or expand only instance annotations, in which case only those selected or expanded annotations appear in the result. Note that annotations specified only in the include-annotations preference do not appear in the context URL and do not affect the selected/expanded properties.

Operations in the context URL are represented using the namespace- or alias-qualified name. Function names suffixed with parentheses represent a specific overload, while function names without parentheses represent all overloads of the function.

OData 4.01 responses MAY use the shortcut pattern {namespace}.* to represent the list of all bound actions or functions available for the returned entity, see system query option $select.

Example 19: resource URL and corresponding context URL

https://host/service/Customers(1)?$select=Name,Rating

https://host/service/$metadata#Customers(Name,Rating)/$entity

10.9 Collection of Expanded Entities
Context URL template:

{context-url}#{entity-set}{/type-name}{select-list}

{context-url}#Collection({type-name}){select-list}

For a 4.01 response, if a navigation property is explicitly expanded, then in addition to any non-suffixed names of any selected properties, navigation properties, functions or actions, the comma-separated list of properties MUST include the name of the expanded property, suffixed with the parenthesized comma-separated list of any properties of the expanded navigation property that are selected or expanded. If the expanded navigation property does not contain a nested $select or $expand, then the expanded property is suffixed with empty parentheses. If the expansion is recursive for nested children, a plus sign (+) is infixed between the navigation property name and the opening parenthesis.

For a 4.0 response, the expanded navigation property suffixed with parentheses is omitted from the select-list if it does not contain a nested $select or $expand, but MUST still be present, without a suffix, if it is explicitly selected.
0
If the context URL includes only expanded navigation properties (i.e., only navigation properties suffixed with parentheses), then all structural properties are implicitly selected (same as if there were no properties listed in the select-list).

Navigation properties with expanded references are not represented in the context URL.

Example 20: resource URL and corresponding context URL - select and expand

https://host/service/Customers?$select=Name&$expand=Address/Country

https://host/service/$metadata#Customers(Name,Address/Country())

Example 21: resource URL and corresponding context URL – expand $ref

https://host/service/Customers?$expand=Orders/$ref

https://host/service/$metadata#Customers

Example 22: resource URL and corresponding context URL – expand with $levels

https://host/service/Employees/Sales.Manager?$select=DirectReports
                &$expand=DirectReports($select=FirstName,LastName;$levels=4)

https://host/service/$metadata
                #Employees/Sales.Manager(DirectReports,
                                         DirectReports+(FirstName,LastName))

10.10 Expanded Entity
Context URL template:

{context-url}#{entity-set}{/type-name}{select-list}/$entity

{context-url}#{singleton}{select-list}

{context-url}#{type-name}{select-list}

For a 4.01 response, if a navigation property is explicitly expanded, then in addition to the non-suffixed names of any selected properties, navigation properties, functions or actions, the comma-separated list of properties MUST include the name of the expanded property, suffixed with the parenthesized comma-separated list of any properties of the expanded navigation property that are selected or expanded. If the expanded navigation property does not contain a nested $select or $expand, then the expanded property is suffixed with empty parentheses. If the expansion is recursive for nested children, a plus sign (+) is infixed between the navigation property name and the opening parenthesis.

For a 4.0 response, the expanded navigation property suffixed with parentheses is omitted from the select-list if it does not contain a nested $select or $expand, but MUST still be present, without a suffix, if it is explicitly selected.

If the context URL includes only expanded navigation properties (i.e., only navigation properties suffixed with parentheses), then all structural properties are implicitly selected (same as if there were no properties listed in the select-list).

Navigation properties with expanded references are not represented in the context URL.

Example 23: resource URL and corresponding context URL

https://host/service/Employees(1)/Sales.Manager?
                   $expand=DirectReports($select=FirstName,LastName;$levels=4)

https://host/service/$metadata
       #Employees/Sales.Manager(DirectReports+(FirstName,LastName))/$entity

10.11 Collection of Entity References
Context URL template:

{context-url}#Collection($ref)

If a response is a collection of entity references, the context URL does not contain the type of the referenced entities.

Example 24: resource URL and corresponding context URL for a collection of entity references

https://host/service/Customers('ALFKI')/Orders/$ref

https://host/service/$metadata#Collection($ref)

10.12 Entity Reference
Context URL template:

{context-url}#$ref

If a response is a single entity reference, $ref is the context URL fragment.

Example 25: resource URL and corresponding context URL for a single entity reference

https://host/service/Orders(10643)/Customer/$ref

https://host/service/$metadata#$ref

10.13 Property Value
Context URL templates:

{context-url}#{entity}/{property-path}{select-list}

{context-url}#{type-name}{select-list}

If a response represents an individual property of an entity with a canonical URL, the context URL specifies the canonical URL of the entity and the path to the structural property of that entity. The path MUST include cast segments for properties defined on types derived from the expected type of the previous segment.

If the property value does not contain explicitly or implicitly selected navigation properties or operations, OData 4.01 responses MAY use the less specific second template.

Example 26: resource URL and corresponding context URL

https://host/service/Customers(1)/Addresses

https://host/service/$metadata#Customers(1)/Addresses

10.14 Collection of Complex or Primitive Types
Context URL template:

{context-url}#Collection({type-name}){select-list}

If a response is a collection of complex types or primitive types that do not represent an individual property of an entity with a canonical URL, the context URL specifies the fully qualified type of the collection.

Example 27: resource URL and corresponding context URL

https://host/service/TopFiveHobbies()

https://host/service/$metadata#Collection(Edm.String)

10.15 Complex or Primitive Type
Context URL template:

{context-url}#{type-name}{select-list}

If a response is a complex type or primitive type that does not represent an individual property of an entity with a canonical URL, the context URL specifies the fully qualified type of the result.

Example 28: resource URL and corresponding context URL

https://host/service/MostPopularName()

https://host/service/$metadata#Edm.String

10.16 Operation Result
Context URL templates:

{context-url}#{entity-set}{/type-name}{select-list}

{context-url}#{entity-set}{/type-name}{select-list}/$entity

{context-url}#{entity}/{property-path}{select-list}

{context-url}#Collection({type-name}){select-list}

{context-url}#{type-name}{select-list}

If the response from an action or function is a collection of entities or a single entity that is a member of an entity set, the context URL identifies the entity set. If the response from an action or function is a property of a single entity, the context URL identifies the entity and property. Otherwise, the context URL identifies the type returned by the operation. The context URL will correspond to one of the former examples.

Example 29: resource URL and corresponding context URL

https://host/service/TopFiveCustomers()

https://host/service/$metadata#Customers

10.17 Delta Payload Response
Context URL template:

{context-url}#{entity-set}{/type-name}{select-list}/$delta

{context-url}#{entity}{select-list}/$delta

{context-url}#{entity}/{property-path}{select-list}/$delta

#$delta

The context URL of a delta response is the context URL of the response to the defining query, followed by /$delta. This includes singletons, single-valued navigation properties, and collection-valued navigation properties.

If the entities are contained, then {entity-set} is the top-level entity set followed by the path to the containment navigation property of the containing entity.

Example 30: resource URL and corresponding context URL

https://host/service/Customers?$deltatoken=1234

https://host/service/$metadata#Customers/$delta

The context URL of an update request body for a collection of entities is simply the fragment #$delta.

10.18 Item in a Delta Payload Response
Context URL templates:

{context-url}#{entity-set}/$deletedEntity

{context-url}#{entity-set}/$link

{context-url}#{entity-set}/$deletedLink

In addition to new or changed entities which have the canonical context URL for an entity, a delta response can contain deleted entities, new links, and deleted links. They are identified by the corresponding context URL fragment. {entity-set} corresponds to the set of the deleted entity, or source entity for an added or deleted link.

10.19 $all Response
Context URL template:

{context-url}#Collection(Edm.EntityType)

Responses to requests to the virtual collection $all (see [OData‑URL]) use the built-in abstract entity type. Each single entity in such a response has its individual context URL that identifies the entity set or singleton.

10.20 $crossjoin Response
Context URL template:

{context-url}#Collection(Edm.ComplexType)

Responses to requests to the virtual collections $crossjoin(...) (see [OData‑URL]) use the built-in abstract complex type. Single instances in these responses do not have a context URL.
#>
