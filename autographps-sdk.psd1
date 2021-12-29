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
ModuleVersion = '0.29.0'

# Supported PSEditions
CompatiblePSEditions = @('Desktop', 'Core')

# ID used to uniquely identify this module
GUID = '4d32f054-da30-4af7-b2cc-af53fb6cb1b6'

# Author of this module
Author = 'Adam Edwards'

# Company or vendor of this module
CompanyName = 'Modulus Group'

# Copyright statement for this module
Copyright = '(c) 2021 Adam Edwards.'

# Description of the functionality provided by this module
Description = 'PowerShell SDK for Microsoft Graph automation'

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
FormatsToProcess = @('./src/cmdlets/common/Formats.ps1xml')

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(@{ModuleName='scriptclass';ModuleVersion='0.20.2';Guid='9b0f5599-0498-459c-9a47-125787b1af19'})

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Clear-GraphLog'
    'Connect-GraphApi'
    'Disconnect-GraphApi'
    'Find-GraphLocalCertificate'
    'Format-GraphLog'
    'Get-GraphApplication'
    'Get-GraphApplicationCertificate'
    'Get-GraphApplicationConsent'
    'Get-GraphApplicationServicePrincipal'
    'Get-GraphConnection'
    'Get-GraphCurrentConnection'
    'Get-GraphError'
    'Get-GraphResource'
    'Get-GraphLog'
    'Get-GraphLogOption'
    'Get-GraphProfile'
    'Get-GraphAccessToken'
    'Invoke-GraphApiRequest'
    'New-GraphApplication'
    'New-GraphApplicationCertificate'
    'New-GraphConnection'
    'New-GraphLocalCertificate'
    'Register-GraphApplication'
    'Remove-GraphApplication'
    'Remove-GraphApplicationCertificate'
    'Remove-GraphApplicationConsent'
    'Remove-GraphConnection'
    'Remove-GraphResource'
    'Select-GraphConnection'
    'Select-GraphProfile'
    'Set-GraphApplicationCertificate'
    'Set-GraphApplicationConsent'
    'Set-GraphConnectionStatus'
    'Set-GraphLogOption'
    'Test-Graph'
    'Test-GraphSettings'
    'Unregister-GraphApplication'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
 VariablesToExport = @(
    'AutoGraphColorModePreference'
    'GraphVerboseOutputPreference'
    'LastGraphItems'
)

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @('conga', 'fgl', 'gge', 'ggr', 'gcat', 'gcon', 'gcur', 'Get-GraphContent', 'ggl', 'scon')

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
        '.\src\formats.ps1'
        '.\src\graph-sdk.ps1'
        '.\src\auth\AuthProvider.ps1'
        '.\src\auth\CompiledDeviceCodeAuthenticator.ps1'
        '.\src\auth\DeviceCodeAuthenticator.ps1'
        '.\src\auth\V2AuthProvider.ps1'
        '.\src\client\Application.ps1'
        '.\src\client\GraphApplication.ps1'
        '.\src\client\GraphConnection.ps1'
        '.\src\client\GraphContext.ps1'
        '.\src\client\GraphIdentity.ps1'
        '.\src\client\LocalConnectionProfile.ps1'
        '.\src\client\LocalProfile.ps1'
        '.\src\client\LocalProfileSpec.ps1'
        '.\src\client\LocalSettings.ps1'
        '.\src\client\LogicalGraphManager.ps1'
        '.\src\cmdlets\Clear-GraphLog.ps1'
        '.\src\cmdlets\Connect-GraphApi.ps1'
        '.\src\cmdlets\Disconnect-GraphApi.ps1'
        '.\src\cmdlets\Find-GraphLocalCertificate.ps1'
        '.\src\cmdlets\Format-GraphLog.ps1'
        '.\src\cmdlets\Get-GraphApplication.ps1'
        '.\src\cmdlets\Get-GraphApplicationCertificate.ps1'
        '.\src\cmdlets\Get-GraphApplicationConsent.ps1'
        '.\src\cmdlets\Get-GraphApplicationServicePrincipal.ps1'
        '.\src\cmdlets\Get-GraphConnection.ps1'
        '.\src\cmdlets\Get-GraphCurrentConnection.ps1'
        '.\src\cmdlets\Get-GraphError.ps1'
        '.\src\cmdlets\Get-GraphResource.ps1'
        '.\src\cmdlets\Get-GraphLog.ps1'
        '.\src\cmdlets\Get-GraphLogOption.ps1'
        '.\src\cmdlets\Get-GraphProfile.ps1'
        '.\src\cmdlets\Get-GraphAccessToken.ps1'
        '.\src\cmdlets\Invoke-GraphApiRequest.ps1'
        '.\src\cmdlets\New-GraphApplication.ps1'
        '.\src\cmdlets\New-GraphApplicationCertificate.ps1'
        '.\src\cmdlets\New-GraphConnection.ps1'
        '.\src\cmdlets\New-GraphLocalCertificate.ps1'
        '.\src\cmdlets\Register-GraphApplication.ps1'
        '.\src\cmdlets\Remove-GraphApplication.ps1'
        '.\src\cmdlets\Remove-GraphApplicationCertificate.ps1'
        '.\src\cmdlets\Remove-GraphApplicationConsent.ps1'
        '.\src\cmdlets\Remove-GraphConnection.ps1'
        '.\src\cmdlets\Remove-GraphResource.ps1'
        '.\src\cmdlets\Select-GraphConnection.ps1'
        '.\src\cmdlets\Select-GraphProfile.ps1'
        '.\src\cmdlets\Set-GraphApplicationCertificate.ps1'
        '.\src\cmdlets\Set-GraphApplicationConsent.ps1'
        '.\src\cmdlets\Set-GraphConnectionStatus.ps1'
        '.\src\cmdlets\Set-GraphLogOption.ps1'
        '.\src\cmdlets\Test-Graph.ps1'
        '.\src\cmdlets\Test-GraphSettings.ps1'
        '.\src\cmdlets\Unregister-GraphApplication.ps1'
        '.\src\cmdlets\common\CertificateHelper.ps1'
        '.\src\cmdlets\common\ApplicationHelper.ps1'
        '.\src\cmdlets\common\CommandContext.ps1'
        '.\src\cmdlets\common\ConsentHelper.ps1'
        '.\src\cmdlets\common\DisplayTypeFormatter.ps1'
        '.\src\cmdlets\common\DynamicParamHelper.ps1'
        '.\src\cmdlets\common\Formats.ps1xml'
        '.\src\cmdlets\common\GraphOutputFile.ps1'
        '.\src\cmdlets\common\ItemResultHelper.ps1'
        '.\src\cmdlets\common\ParameterCompleter.ps1'
        '.\src\cmdlets\common\PermissionParameterCompleter.ps1'
        '.\src\cmdlets\common\QueryHelper.ps1'
        '.\src\common\LocalCertificate.ps1'
        '.\src\common\ColorString.ps1'
        '.\src\common\ColorScheme.ps1'
        '.\src\common\DefaultScopeData.ps1'
        '.\src\common\GraphAccessDeniedException.ps1'
        '.\src\common\GraphApplicationCertificate.ps1'
        '.\src\common\GraphFormatter.ps1'
        '.\src\common\GraphUtilities.ps1'
        '.\src\common\PreferenceHelper.ps1'
        '.\src\common\ProgressWriter.ps1'
        '.\src\common\ResponseContext.ps1'
        '.\src\common\ScopeHelper.ps1'
        '.\src\common\Secret.ps1'
        '.\src\graphservice\ApplicationAPI.ps1'
        '.\src\graphservice\ApplicationObject.ps1'
        '.\src\graphservice\GraphEndpoint.ps1'
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
## AutoGraphPS-SDK 0.29.0 Release Notes

This release removes the ADAL library dependency and removes support for the AAD Graph service endpoint. Includes an extensive documentation update so that all commands are now documented.

### New dependencies

None.

### Breaking changes

* Support for the AAD Graph service endpoint (https://graph.windows.net) has been removed; the `AADGraph` parameter has been removed from all commands that supported it such as `Connect-GraphApi`, `Get-GraphResource`, and `Invoke-GraphApiRequest`. The module now only supports endpoints that support the Graph API protocol implemented by https://graph.microsoft.com and documented at https://docs.microsoft.com/en-us/graph.
* The `AuthProtocol` parameter of `Connect-GraphApi` and `New-GraphConnection` has been removed
* If you relied on the module loading ADAL in some circumstances, this no longer occurs as this release removes the ADAL code altogether.
* The `Get-GraphToken` command was renamed to `Get-GraphAccessToken`
* `Set-GraphApplicationConsent` and some other commands no longer support a version parameter.

### New features

* `Index` parameter added to `Get-GraphLog` to get the log entry at a specific index
* `Get-GraphLog` now supports the parameter aliases `First` for `Newest` and `Last` for `Oldest`.
* `Register-GraphApplication` now returns formatted output

### Fixed defects

* Fixed `./build/import-devmodule.ps1` command so that if it launches a shell it does not load the PowerShell profile by default to ensure that components like posh-git, oh-my-posh, or anything else loaded in the profile does not interfere with unit tests. Added `PSProfile` option to the command to allow the profile to be loaded.
* `Skip` parameter of `Get-GraphLog` had no effect, this has been fixed
* `Set-GraphApplicationConsent` now handles errors correctly when processing objects in the pipeline.

'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
