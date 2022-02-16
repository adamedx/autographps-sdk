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
param([string] $ScriptPath)

Set-StrictMode -Version 2

$testParameterToCodeString = {
    param($parameterValue)
    if ( $parameterValue -eq $null ) {
    } elseif ( $parameterValue -is [ScriptBlock] ) {
        "( . { $parameterValue } )"
    } elseif ( $parameterValue -is [string] ) {
        "'$parameterValue'"
    } elseif ( $parameterValue -is [int] -or
               $parameterValue -is [double] )  {
            "( $parameterValue )"
        } else {
            throw "Parameter must be null or of type string, scriptblock, int or double -- type $($parameterValue.GetType()) is not valid."
        }

}

$testScriptBlock = {
    param(
        [string] $testTitle,
        [string[]] $testCases,
        [HashTable] $testSetupParams,
        [string] $beforeAll,
        [string] $afterall,
        [string] $beforeEach,
        [string] $afterEach)
    $concatenatedCases = $testCases -join "`n        "
    $setupParams = foreach ( $setupParam in $testSetupParams.Keys ) {
        "'$setupParam' = $($testSetupParams[$setupParam])"
    } -join "`n"
@"
Describe 'The samples for ''$testTitle''' -Tag SampleIntegration {
    Context 'When executing the samples' {
        BeforeAll {
            `$__setupState = @{}

            `$__setupParams = @{
                $setupParams
            }

            `$__TestContext = @{}

            . { $beforeAll } `$__setupParams `$__setupState `$__testContext
        }

        AfterAll {
            . { $afterAll } `$__setupState
        }

        BeforeEach {
            . { $beforeEach } `$__setupParams `$__setupState `$__testContext
        }

        AfterEach {
            . { $afterEach } `$__setupState
        }

        $concatenatedCases
    }
}
"@
}

$testCaseScriptBlock = {
    param( [string] $testDescription, [string] $testCode )
@"
It '$testDescription' {
    $testCode
        }
"@
}

$scriptTitle = [System.IO.Path]::GetFileNameWithoutExtension((split-path -leaf $ScriptPath))
$sampleCollection = & "$psscriptroot/Get-SamplesFromScriptFile.ps1" $ScriptPath
$collectionTitle = $sampleCollection.Title
$collectionDescription = $sampleCollection.Description

$testSetupParameterTable = @{}

foreach ( $testSetupParameterName in $sampleCollection.TestSetupParams.Keys ) {
    $testSetupParameterValue = . $testParameterToCodeString $sampleCollection.TestSetupParams[$testSetupParameterName]
    $testSetupParameterTable.Add($testSetupParameterName, $testSetupParameterValue)
}

$sampleCodeCases = @()
$sampleDescriptions = @()
$sampleTitles = @()

$testCaseStrings = for ( $testIndex = 0; $testIndex -lt $sampleCollection.Samples.length; $testIndex++ ) {
    $sample = $sampleCollection.Samples[$testIndex]
    $sampleTitles += $sample.Name
    $sampleDescriptions += $sample.Description
    $generatorScript = $sample.SampleGenerator
    $generatorParameters = $generatorScript.ast.paramblock.parameters
    $generatorParameterCount = ($generatorParameters | measure-object).count
    $testParameters = $sample.TestParameters
    $docParameterTable = @{}
    $exceptionSubstring = $sample['ExpectedExceptionSubstring']
    $testBlock = $sample['Test']

    if ( $generatorParameterCount -ne $testParameters.Length ) {
        throw "Sample test '$($sample.Name) in file '$scriptFileName' at index $testIndex takes $generatorParmaeterCount parameters but only $($sample.TestParameters.Length) parameters were specifid"
    }

    $testBlockCode = if ( $testBlock ) {
        $testBlock.ToString()
    }

    $testParameterTable = @{}

    $parameterIndex = 0

    foreach ( $parameter in $generatorParameters ) {
        $parameterName = $parameter.Name.VariablePath
        $defaultParameterValue = $parameter.Defaultvalue
        $testParameter = $testParameters[$parameterIndex++]

        if ( $defaultParameterValue -eq $null ) {
            throw "A non-null default value for parameter '$parameterName' for test case '$testCaseName' was not specified"
        }

        $docParameterValue = if ( $defaultParameterValue.value -is [ScriptBlock] ) {
            . $defaultParameterValue.value
        } else {
            $defaultParameterValue.value
        }

        $testParameterValue = . $testParameterToCodeString $testParameter

        $testParameterTable.Add($parameterName, $testParameterValue)
        $docParameterTable.Add($parameterName, $docParameterValue)
    }


    $testParameterAssignments = foreach ( $testParameterName in $testParameterTable.Keys ) {
        "`$$testParameterName = $($testParameterTable[$testParameterName])"
    }

    $testParameterCodeString = ( $testParameterAssignments -join "`n" )

    $generatedTestCode = ( . $sample.samplegenerator ) -join "`n"

    $wrappedTestCode = if ( $exceptionSubstring ) {
        "{ $generatedTestCode } | Should Throw '$exceptionSubstring'"
    } else {
        " `$testResult = ( $generatedTestCode )"
    }

    $testCodeString = @"
    $testParameterAssignments
    $wrappedTestCode
    $testBlockCode
"@
    $sampleCodeCases += . $sample.sampleGenerator @docParameterTable

    . $testCaseScriptBlock $sample.Description $testCodeString
}

$testContent = . $testScriptBlock $scriptTitle $testCaseStrings $testSetupParameterTable $sampleCollection['BeforeAll'] $sampleCollection['Afterall'] $sampleCollection['BeforeEach'] $sampleCollection['AfterEach']


[PSCustomObject] @{
    CollectionTitle = $collectionTitle
    CollectionDescription = $collectionDescription
    TestTitle = $scriptTitle
    TestContent = $testContent
    SampleCodeCases = $sampleCodeCases
    SampleDescriptions = $sampleDescriptions
    SampleTitles = $sampleTitles
}

