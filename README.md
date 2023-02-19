# <img src="https://raw.githubusercontent.com/adamedx/autographps-sdk/main/assets/PoshGraphIcon.png" width="50"> AutoGraphPS-SDK

| [Documentation](https://github.com/adamedx/autographps/blob/main/docs/WALKTHROUGH.md) | [Installation](#Installation) | [Using AutoGraphPS-SDK](#Usage) | [Command inventory](#Reference) | [Contributing and development](#contributing-and-development) |
|-------------|-------------|-------------|-------------|-------------|

[![Build Status](https://adamedx.visualstudio.com/AutoGraphPS/_apis/build/status/AutoGraphPS-SDK-CI?branchName=main)](https://adamedx.visualstudio.com/AutoGraphPS/_build/latest?definitionId=4&branchName=main)

## Overview

**AutoGraphPS-SDK** automates the [Microsoft Graph API](https://graph.microsoft.io/) through PowerShell. AutoGraphPS-SDK enables the development of PowerShell-based applications and automation of the Microsoft Graph REST API gateway; the PowerShell Graph Exploration UX [AutoGraphPS](https://github.com/adamedx/autographps) is one such application based on the SDK. The Graph exposes a growing list of services such as

* Azure Active Directory (AAD)
* OneDrive
* Exchange / Outlook
* SharePoint
* Teams... and many more!

### System requirements

On the Windows operating system, PowerShell 5.1 and higher are supported. On Linux, PowerShell 7.0 and higher are supported. MacOS has not been tested, but should work with PowerShell 7.0 and higher.

## Installation
AutoGraphPS-SDK is available through the [PowerShell Gallery](https://www.powershellgallery.com/packages/autographps-sdk); run the following command to install the latest stable release of AutoGraphPSGraph-SDK into your user profile:

```powershell
Install-Module AutoGraphPS-SDK -scope currentuser
```

## Usage
Once you've installed, you can use an AutoGraphPS-SDK command like `Get-GraphResource` below to test out your installation. You'll need to authenticate using a [Microsoft Account](https://account.microsoft.com/account) or an [Azure Active Directory (AAD) account](https://docs.microsoft.com/en-us/azure/active-directory/active-directory-whatis):

```powershell
PS> Get-GraphResource me
```

After you've responded to the authentication prompt, you should see output that represents your user object similar to the following:

    id                : 82f53da9-b996-4227-b268-c20564ceedf7
    officeLocation    : 7/3191
    @odata.context    : https://graph.microsoft.com/v1.0/$metadata#users/$entity
    surname           : Okorafor
    mail              : starchild@mothership.io
    jobTitle          : Professor
    givenName         : Starchild
    userPrincipalName : starchild@mothership.io
    businessPhones    : +1 (313) 360 3141
    displayName       : Starchild Okorafor

Now you're ready to use any of AutoGraphPS-SDK's commands to access and explore Microsoft Graph! Visit the [WALKTHROUGH](https://github.com/adamedx/autographps/blob/main/docs/WALKTHROUGH.md) for detailed usage of the commands.

### Can you show some example graph commands?

If you're familiar with the Microsoft Graph REST API or you've used [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer), you know that Graph is accessed via [URI's that look like the following](https://developer.microsoft.com/en-us/graph/docs/concepts/overview#popular-requests):

```
https://graph.microsoft.com/v1.0/me/calendars
https://graph.microsoft.com/v1.0/me/people
https://graph.microsoft.com/v1.0/users
```

With the AutoGraphPS-SDK commands, you can invoke REST methods from PowerShell and omit the common `https://graph.microsoft.com/v1.0` of the URI as follows:

```powershell
Get-GraphResource me/calendars
Get-GraphResource me/people
Get-GraphResource users
```

These commands retrieve the same data as a `GET` for the full URIs given earlier. Of course, `Get-GraphResource` supports a `-AbsoluteUri` option to allow you to specify that full Uri if you so desire.

As with any PowerShell command, you can use AutoGraphPS-SDK commands interactively or from within simple or even highly complex PowerShell scripts and modules since the commands emit and operate upon PowerShell objects.

For more detailed information on how to use AutoGraphPS-SDK commands, see the [WALKTHROUGH](https://github.com/adamedx/autographps/blob/main/docs/WALKTHROUGH.md) for the separate AutoGraphPS module, which documents a superset of commands contained in this SDK in additions to those found in that module.

### How do AutoGraphPS-SDK use it in my PowerShell application?

If your application is packaged as a PowerShell module, simply include it in the `NestedModules` section of your module's [PowerShell module manifest](https://technet.microsoft.com/en-us/library/dd878337%28v=VS.85%29.aspx). This will allow you to publish your module to a repository like PSGallery and ensure that users who install your module from the gallery also get the installation of AutoGraphPS-SDK needed for your module to function. You should add the line `import-module autographps-sdk` to the beginning of the script you use to initialize your module.

If you're using a script module (`.psm1` file) or simply a plain PowerShell `ps1` script, you should ensure AutoGraphPS-SDK has been already been installed on the system using `Install-Module` or a similar deployment mechanism, then add a line `import-module autographps-sdk` to the beginning of your script or script module.

### Configuration and preferences

The module allows for customization through conventional PowerShell preference variables as a configuration file. In general, when a behavior may be specified by both a preference variable and a setting from the configuration file, the preference variable behavior takes precedence, making it easy to change a behavior at runtime without redefining profiles.

#### Preference variables

The following preference variable is defined by the module:

* `AutoGraphColorModePreference`: specify with the value `2bit` to override the default 16-color palette of command output to make it monochrome. Explicitly specifying `4bit` will ensure 16-color output.

#### Settings file

AutoGraphPS-SDK supports the use of a local settings configuration file at the location `~/.autographps/settings.json`. Configuration settings managed by this file include sign-in and credential customization, logging preferences, and API version override among other things. See the specific [settings file documentation](docs/settings/README.md) for more detail on the capabilities and format of the file.

## Reference

The full list of commands in this module is given below; note that `Invoke-GraphApiRequest` may be used not just for reading from the Graph, but also for write operations. Use `Connect-GraphApi` to request additional permissions as described in the [Graph permissions documentation](https://docs.microsoft.com/en-us/graph/permissions-reference).

| Command (alias)                       | Description                                                                                                                                             |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| Clear-GraphLog                       | Clear the log of REST requests to Graph made by the module's commands                                                                                   |
| Connect-GraphApi (conga)             | Establishes authentication and authorization context used across commands for the current graph                                                          |
| Disconnect-GraphApi                  | Clears authentication and authorization context used across commands for the current graph                                                               |
| Find-GraphLocalCertificate           | Gets a list of local certificates created by AutoGraphPS-SDK to for app-only or confidential delegated auth to Graph                                    |
| Format-GraphLog (fgl)                | Emits the Graph request log to the console in a manner optimized for understanding Graph and troubleshooting requests                                   |
| Get-GraphApplication                 | Gets a list of Azure AD applications in the tenant                                                                                                      |
| Get-GraphApplicationCertificate      | Gets the certificates with public keys configured on the application                                                                                    |
| Get-GraphApplicationConsent          | Gets the list of the tenant's consent grants (entries granting an app access to capabilities of users)                                                  |
| Get-GraphApplicationServicePrincipal | Gets the service principal for the application in the tenant                                                                                            |
| Get-GraphConnection (gcon)           | Gets information about all named connections and the current connection                                                                                 |
| Get-GraphCurrentConnection (gcur)    | Gets information about the current connection to a Graph endpoint, including identity and  `Online` or `Offline`                                        |
| Get-GraphError (gge)                 | Retrieves detailed errors returned from Graph in execution of the last command                                                                          |
| Get-GraphResource  (ggr, gcat, Get-GraphContent) | Given a relative (to the Graph or current location) Uri gets information about the entity                                                   |
| Get-GraphLog (ggl)                   | Gets the local log of all requests to Graph made by this module                                                                                         |
| Get-GraphLogOption                   | Gets the configuration options for logging of requests to Graph including options that control the detail level of the data logged                      |
| Get-GraphProfile                     | Gets the list of profiles defined in the [settings file](https://github.com/adamedx/autographps-sdk/blob/main/docs/settings/README.md) -- these profiles may be enabled by the `Select-GraphProfileSettings` command. |
| Get-GraphAccessToken                       | Gets an access token for the Graph -- helpful in using other tools such as [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer) |
| Invoke-GraphApiRequest               | Executes a REST method (e.g. `GET`, `PUT`, `POST`, `DELETE`, etc.) for a Graph Uri                                                                      |
| New-GraphApplication                 | Creates an Azure AD application configured to authenticate to Microsoft Graph                                                                           |
| New-GraphApplicationCertificate      | Creates a new certificate in the local certificate store and configures its public key on an application                                                |
| New-GraphConnection                  | Creates an authenticated connection using advanced identity customizations for accessing a Graph                                                        |
| New-GraphLocalCertificate            | Creates a certificate in the local certificate store for use in authenticating as an application                                                        |
| Register-GraphApplication            | Creates a registration in the tenant for an existing Azure AD application                                                                               |
| Remove-GraphApplication              | Deletes an Azure AD application                                                                                                                         |
| Remove-GraphApplicationCertificate   | Removes a public key from the application for a certificate allowed to authenticate as that application                                                 |
| Remove-GraphApplicationConsent       | Removes consent grants for an Azure AD application                                                                                                      |
| Remove-GraphConnection               | Removes a named graph connection                                                                                                                        |
| Remove-GraphResource                 | Makes generic ``DELETE`` requests to a specified Graph URI to delete resources                                                                          |
| Select-GraphConnection (scon)              | Sets the named connection used by default for commands in the current Graph                                                                       |
| Select-GraphProfile                  | Enables the behaviors mandated by the setting values of the specified profile. Profiles are defined by the user's [settings file](https://github.com/adamedx/autographps-sdk/blob/main/docs/settings/README.md). |
| Set-GraphApplicationCertificate      | Given the specified certificate or certificate path sets the application's certificates                                             |
| SetGraphApplicationConsent           | Sets a consent grant for an Azure AD application                                                                                                        |
| Set-GraphConnectionStatus            | Configures `Offline` mode for use with local-only commands or re-enables `Online`               mode for accessing the Graph service                    |
| Set-GraphLogOption                   | Sets the configuration options for logging of requests to Graph including options that control the detail level of the data logged                      |
| Test-Graph                           | Retrieves unauthenticated diagnostic information from instances of your Graph endpoint                                                                  |
| Test-GraphSettings                   | Validates whether AutoGraph settings specified as a file, JSON content, or in deserialized form are valid                                               |
| Unregister-GraphApplication          | Removes consent and service principal entries for the application from the tenant                                                                       |

### More about how it works

If you'd like a behind the scenes look at the implementation of AutoGraphPS-SDK, take a look at the following article:

* [Microsoft Graph via PowerShell](https://adamedx.github.io/softwarengineering/2018/08/09/Microsoft-Graph-via-PowerShell.html)

## Developer installation from source
For developers contributing to AutoGraphPS-SDK or those who wish to test out pre-release features that have not yet been published to PowerShell Gallery, run the following PowerShell commands to clone the repository and then build and install the module on your local system:

```powershell
git clone https://github.com/adamedx/autographps-sdk
cd autographps-sdk
.\build\install-fromsource.ps1
```

## Contributing and development

Read about our contribution process in [CONTRIBUTING.md](CONTRIBUTING.md).

See the [Build README](build/README.md) for instructions on building and testing changes to AutoGraphPS-SDK.

## Quickstart
The Quickstart is a way to try out AutoGraphPS-SDK without installing the AutoGraphPS-SDK module. In the future it will feature an interactive tutorial. Additionally, it is useful for developers to quickly test out changes without modifying the state of the operating system or user profile. Just follow these steps on your workstation to start **AutoGraphPS-SDK**:

* [Download](https://github.com/adamedx/autographps-sdkarchive/main.zip) and extract the zip file for this repository **OR** clone it with the following command:

  `git clone https://github.com/adamedx/autographps-sdk`

* Within a **PowerShell** terminal, `cd` to the extracted or cloned directory
* Execute the command for **QuickStart**:

  `.\build\quickstart.ps1`

This will download dependencies, build the AutoGraphPS-SDK module, and launch a new PowerShell console with the module imported. You can execute a AutoGraphPS-SDK command like the following in the console -- try it:

  `Test-Graph`

This should return something like the following:

    ADSiteName : wst
    Build      : 1.0.9736.8
    DataCenter : west us
    Host       : agsfe_in_29
    PingUri    : https://graph.microsoft.com/ping
    Ring       : 4
    ScaleUnit  : 000
    Slice      : slicea
    TimeLocal  : 2/6/2018 6:05:09 AM
    TimeUtc    : 2/6/2018 6:05:09 AM

If you need to launch another console with AutoGraphPS, you can run the faster command below which skips the build step since QuickStart already did that for you (though it's ok to run QuickStart again):

    .\build\import-devmodule.ps1

These commmands can also be used when testing modifications you make to AutoGraphPS-SDK, and also give you an isolated environment in which to test and develop applications and tools that depend on AutoGraphPS-SDK.

License and authors
-------------------
Copyright:: Copyright (c) 2023 Adam Edwards

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

