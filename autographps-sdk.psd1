#
# Module manifest for module 'AutoGraphPS-SDK'
#
# Generated by: adamedx
#
# Generated on: 9/24/2017
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'autographps-sdk.psm1'

# Version number of this module.
ModuleVersion = '0.22.0'

# Supported PSEditions
CompatiblePSEditions = @('Desktop', 'Core')

# ID used to uniquely identify this module
GUID = '4d32f054-da30-4af7-b2cc-af53fb6cb1b6'

# Author of this module
Author = 'Adam Edwards'

# Company or vendor of this module
CompanyName = 'Modulus Group'

# Copyright statement for this module
Copyright = '(c) 2020 Adam Edwards.'

# Description of the functionality provided by this module
Description = 'PowerShell SDK for automating the Microsoft Graph'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(@{ModuleName='scriptclass';ModuleVersion='0.20.2';Guid='9b0f5599-0498-459c-9a47-125787b1af19'})

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Clear-GraphLog'
    'Connect-Graph'
    'Disconnect-Graph'
    'Find-GraphLocalCertificate'
    'Format-GraphLog'
    'Get-GraphApplication'
    'Get-GraphApplicationCertificate'
    'Get-GraphApplicationConsent'
    'Get-GraphApplicationServicePrincipal'
    'Get-GraphConnectionInfo'
    'Get-GraphError'
    'Get-GraphResource'
    'Get-GraphLog'
    'Get-GraphLogOption'
    'Get-GraphToken'
    'Invoke-GraphRequest'
    'New-GraphApplication'
    'New-GraphApplicationCertificate'
    'New-GraphConnection'
    'New-GraphLocalCertificate'
    'Register-GraphApplication'
    'Remove-GraphApplication'
    'Remove-GraphApplicationCertificate'
    'Remove-GraphApplicationConsent'
    'Remove-GraphItem'
    'Set-GraphApplicationConsent'
    'Set-GraphConnectionStatus'
    'Set-GraphLogOption'
    'Test-Graph'
    'Unregister-GraphApplication'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @(
    'GraphVerboseOutputPreference'
    'LastGraphItems'
)

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @('gge', 'ggr', 'gcat', 'Get-GraphContent', 'ggl', 'fgl')

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @('')

# List of all files packaged with this module
    FileList = @(
        '.\autographps-sdk.psd1'
        '.\autographps-sdk.psm1'
        '.\src\aliases.ps1'
        '.\src\cmdlets.ps1'
        '.\src\graph-sdk.ps1'
        '.\src\auth\AuthProvider.ps1'
        '.\src\auth\CompiledDeviceCodeAuthenticator.ps1'
        '.\src\auth\DeviceCodeAuthenticator.ps1'
        '.\src\auth\V1AuthProvider.ps1'
        '.\src\auth\V2AuthProvider.ps1'
        '.\src\client\Application.ps1'
        '.\src\client\GraphApplication.ps1'
        '.\src\client\GraphConnection.ps1'
        '.\src\client\GraphContext.ps1'
        '.\src\client\GraphIdentity.ps1'
        '.\src\client\LogicalGraphManager.ps1'
        '.\src\cmdlets\Clear-GraphLog.ps1'
        '.\src\cmdlets\Connect-Graph.ps1'
        '.\src\cmdlets\Disconnect-Graph.ps1'
        '.\src\cmdlets\Find-GraphLocalCertificate.ps1'
        '.\src\cmdlets\Format-GraphLog.ps1'
        '.\src\cmdlets\Get-GraphApplication.ps1'
        '.\src\cmdlets\Get-GraphApplicationCertificate.ps1'
        '.\src\cmdlets\Get-GraphApplicationConsent.ps1'
        '.\src\cmdlets\Get-GraphApplicationServicePrincipal.ps1'
        '.\src\cmdlets\Get-GraphConnectionInfo.ps1'
        '.\src\cmdlets\Get-GraphError.ps1'
        '.\src\cmdlets\Get-GraphResource.ps1'
        '.\src\cmdlets\Get-GraphLog.ps1'
        '.\src\cmdlets\Get-GraphLogOption.ps1'
        '.\src\cmdlets\Get-GraphToken.ps1'
        '.\src\cmdlets\Invoke-GraphRequest.ps1'
        '.\src\cmdlets\New-GraphApplication.ps1'
        '.\src\cmdlets\New-GraphApplicationCertificate.ps1'
        '.\src\cmdlets\New-GraphConnection.ps1'
        '.\src\cmdlets\New-GraphLocalCertificate.ps1'
        '.\src\cmdlets\Register-GraphApplication.ps1'
        '.\src\cmdlets\Remove-GraphApplication.ps1'
        '.\src\cmdlets\Remove-GraphApplicationCertificate.ps1'
        '.\src\cmdlets\Remove-GraphApplicationConsent.ps1'
        '.\src\cmdlets\Remove-GraphResource.ps1'
        '.\src\cmdlets\Set-GraphApplicationConsent.ps1'
        '.\src\cmdlets\Set-GraphConnectionStatus.ps1'
        '.\src\cmdlets\Set-GraphLogOption.ps1'
        '.\src\cmdlets\Test-Graph.ps1'
        '.\src\cmdlets\Unregister-GraphApplication.ps1'
        '.\src\cmdlets\common\ApplicationHelper.ps1'
        '.\src\cmdlets\common\CommandContext.ps1'
        '.\src\cmdlets\common\ConsentHelper.ps1'
        '.\src\cmdlets\common\DisplayTypeFormatter.ps1'
        '.\src\cmdlets\common\DynamicParamHelper.ps1'
        '.\src\cmdlets\common\GraphOutputFile.ps1'
        '.\src\cmdlets\common\ItemResultHelper.ps1'
        '.\src\cmdlets\common\ParameterCompleter.ps1'
        '.\src\cmdlets\common\PermissionParameterCompleter.ps1'
        '.\src\cmdlets\common\QueryHelper.ps1'
        '.\src\common\DefaultScopeData.ps1'
        '.\src\common\GraphAccessDeniedException.ps1'
        '.\src\common\GraphApplicationCertificate.ps1'
        '.\src\common\GraphUtilities.ps1'
        '.\src\common\PreferenceHelper.ps1'
        '.\src\common\ProgressWriter.ps1'
        '.\src\common\ResponseContext.ps1'
        '.\src\common\ScopeHelper.ps1'
        '.\src\common\Secret.ps1'
        '.\src\graphservice\ApplicationAPI.ps1'
        '.\src\graphservice\ApplicationObject.ps1'
        '.\src\graphservice\GraphEndpoint.ps1'
        '.\src\REST\GraphErrorRecorder.ps1'
        '.\src\REST\GraphRequest.ps1'
        '.\src\REST\GraphResponse.ps1'
        '.\src\REST\HttpUtilities.ps1'
        '.\src\REST\RequestLog.ps1'
        '.\src\REST\RequestLogEntry.ps1'
        '.\src\REST\RESTRequest.ps1'
        '.\src\REST\RESTResponse.ps1'
    )

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('MSGraph', 'Graph', 'AADGraph', 'Azure', 'MicrosoftGraph', 'Microsoft-Graph', 'MS-Graph', 'AAD-Graph', 'REST', 'CRUD', 'GraphAPI', 'poshgraph', 'poshgraph-sdk', 'autograph', 'PSEdition_Core', 'PSEdition_Desktop', 'Windows', 'Linux', 'MacOS')

        # A URL to the license for this module.
        LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/adamedx/autographps-sdk'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/adamedx/poshgraph-sdk/main/assets/PoshGraphIcon.png'

        # Adds pre-release to the patch version according to the conventions of https://semver.org/spec/v1.0.0.html
        # Requires PowerShellGet 1.6.0 or greater
        # Prerelease = '-preview'

        # ReleaseNotes of this module
        ReleaseNotes = @'
## AutoGraphPS-SDK 0.22.0 Release Notes

This release adds helper libraries for interpreting OData protocol response metadata, simplifies result paging capabilities, adds a detailed Graph response output format for applications building complex scenarios that require protocol awareness, and adds preview support for delta query.

### New dependencies

None.

### Breaking changes

* The `IncludeFullResponse` parameter is no longer supported by the `Invoke-GraphRequest` command. It has been superseded by the `AsResponseDetail` parameter added in this release.
* Applications created by New-GraphApplication no longer include 'http://localhost' and 'urn:ietf:wg:oauth:2.0:oob' by default. The only default URI specified for these application is 'https://login.microsoftonline.com/common/oauth2/nativeclient'.

### New features

* `Invoke-GraphRequest` has several new parameters to support delta query and improved control over result pagin:
  * `AsResponseDetail`: when specified, the output of the command rather than directly returning the deserialized objects from the Graph response instead returns a structure that includes a `Content` field that contains those objects. The other fields of the structure include additional details about the response, including conditionally populated fields such as `DeltaUri` and `DeltaToken` returned from delta query responses. The `Responses` field contains all of the detailed protocol responses from the graph that were issued as the command paged through result sets that required multiple requests to process.
  * `Delta`: when this is specified, the command issues a delta query to Graph, i.e. a query that in addition to returning the results specified in the query also returns additional metadata in the form of a "delta URI" or "delta token" that can be used in subsequent requests to return only the information that has changed since the original query. When this parameter is specified, the results are returned in the format used when `AsResponseDetail` is specified.
  * `DeltaToken`: This parameter provides a way to request only the incremental changes that would be returned compared to a previous request issued by this command using the Delta parameter.
  * `NoPaging`: This disables the default behavior of the command that issues multiple requests to Graph until all results for the initial request have been retrieved. When this command is specified, the results are returned using the `AsResponseDetail` format so that the caller has the additional information beyond the request results necessary to retrieve the additional results if desired.
  * `PageSizePreference`: directs the command to issues requests that instruct the Graph API to return a specific maximum number of items in each page of results. This parameter will only take effect if Graph honors it for the particular request.
  * `ResponseContext` class: This class parses the `ODataContext` property, an [OData Context URL](http://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html#sec_ContextURL) to return information about the type of the response and the URI used to make the request.
  * New methods in `GraphUtilities`:
    * `GetAbstractUriFromResponseObject` returns a close approximation of a URI that can be used to make a request for that response.
    * `GetOptionalTypeFromResponseObject` returns the parsed type from `@odata.type` for a given object if it is present

### Fixed defects

* V2 public client authentication fails with mismatch reply URL when using a non-default app id unless localhost is configured as a reply url. The only workaround was to add localhost as a reply url to the app because no reply URL was specified by AutoGraphPS to the MSAL library when making the request. From an MSAL (and possibly from the protocol) standpoint, this is the equivalent of specifying no reply url. The fix is to specify whatever reply URL is configured in the local connection; by default, the app now uses 'https://login.microsoftonline.com/common/oauth2/nativeclient', which is now the default reply URL for applications created by New-GraphApplication.
* Get-GraphLog and related commands did not function correctly on PowerShell 7 -- error responses were logged with incomplete fields including an invalid http status code of 0. This was due to the underlying http client type being different on PowerShell 7 vs. PowerShell 5, and the methods and properties were different for this class, resulting in errors when trying to read data from the response. This seemed to only be an issue for error responses. The fix ensures that the type differences are accounted for on the different platforms and restores the error logging.
* Fixed an error where apps created by New-GraphApplication were registered such that device code authentication flow could not be used to sign-in with the apps. They were missing the fallbackPublicClient property for the app, which is apparently required for that flow to work. This is now fixed, and this restores device code flow login for these apps, which is critical for PowerShell 7 and later since they do not support the web browser controls used to sign in on PowerShell 5.

'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
