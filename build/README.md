Build README
============

This document describes how to build AutoGraphPS-SDK and provides additional information on build customizations and advanced development scenarios.

## Prerequisites

**AutoGraphPS-SDK** development requires the following:

* A **Windows 10** operating system or later
* [PowerShellGet](https://www.powershellgallery.com/packages/PowerShellGet) PowerShell module version 1.0.0.1 (default in Windows 10 versions) or [version 1.6.0](https://www.powershellgallery.com/packages/PowerShellGet/1.6.0).
* [Git command-line tools](https://git-for-windows.github.io/) to clone this repository locally:

```powershell
git clone https://github.com/adamedx/autographps-sdk
cd autographps-sdk
```

**Note:** PowerShellGet version 1.6.6 is incompatible with AutoGraphPS-SDK due to a code defect. Versions other than 1.0.0.1 and 1.6.0 have not been tested; use 1.0.0.1 (default) or [install 1.6.0](https://www.powershellgallery.com/packages/PowerShellGet/1.6.0) in order to build this module.

### Simple building and debugging
The most common case is to build the module and then execute it in a new shell.

### Build a new module
To create a new version of the module in the `pkg` output directory, run this command:

```powershell
.\build\configure-tools.ps1 # only needed before your first build or when tools are updated
.\build\build-package.ps1 -downloaddependencies
```

The `-downloaddependencies` option is only required the first time you perform a build, or if you've run a "clean build" command or realize you need to update the project's non-[PowerShell Gallery](https://powershellgallery.com) dependencies (dependent modules are sources from PowerShell Gallery and are managed through subsequent build operations described below). Note that you do not need to do this every time you make a code change -- it is only strictly necessary when you want to test module installation or generate an installable / publishable module package, or if you simply want to verify that you haven't broken the build. Alternatively, you can update these dependencies using the [install.ps1](install.ps1) script before executing `build-package` without the `downloaddependencies` parameter.

### Test your code changes
It is best to test your code changes in a shell session in which all dependent modules are loaded. The commands below will create such a shell. Note that you do not need to run these commands to test every code change. For ad-hoc testing, it is generally sufficient to launch the shell, and then enable your code changes by simply dot-sourcing the file(s) in which you've made changes. To run automated tests or to perform extended interactive scenario testing, it is actually best to run these commands to create the new shell:

```powershell
.\build\publish-moduletodev.ps1
```

This creates a local PowerShell Gallery-compatible repository under the directory `.psrepo` that contains the PowerShell module and dependencies copied down any PowerShell modules from which it depends from PowerShell Gallery. This then allows commands like `install-module` to install the module to your test system in the subdirectory `.devmodule` of the repository for real-world testing.

It also allows you to simply start a shell in which the module is loaded with your code changes for ad-hoc testing without module installation or making any configuration / applications changes to your system with the following command:

```powershell
.\build\import-devmodule.ps1
```

The resulting shell can be used as if you had installed your module, and you can also run tests from it.

### Test / debug iteration

You'll likely need to repeat the cycle of making a change, running some sort of test (ad-hoc, unit, etc.), and if it fails, debugging. The steps mentioned above, i.e. building, publishing (aka deploying), and running a test will need to be repeated with something like the following commands:

```powershell
# Assumes you've already run the previously mentioned configure and -downloaddependencies steps

# After you've changed your code, run the following commands:
.\build\build-package.ps1
.\build\publish-moduletodev.ps1 # Hmm, this takes a while!
.\build\import-devmodule.ps1

```

You can again run whatever tests in the launched shell. However, the `publish-moduletodev` steps is particularly slow, so while this approach gives a reliably stable and unpolluted test environment, the tradeoff is efficiency. Fortunately, there is a way to speeed things up....

#### Testing -- the fast method
The `publish-moduletodev` step is slow because it is creating a somewhat isolated environment that includes the other module dependencies and also validates the module manifest by publishing it as well AND even installing it. The publish step includes gathering files together and compressing them, then installing them into the module directory.

Getting past this is a good sign that the module is still installable, but what if you haven't changed anything about the module manifest or added new files or dependencies to the module? In this case, assuming you successfully executed `publish-moduletodev` in a previous iteration, you can use the following technique to quickly test a change:

```
.\build\import-devmodule.ps1 -FromSource
```

That command alone will launch a shell that loads the module from the source directory, i.e. *with the files in source control that you've edited*, rather than requiring you to use `publish-moduletodev` to labriously publish and then install the module's files to the `.devmodule` directory and run the module from there.

This should be the most common way you actually test new code. It has the limitations mentioned earlier when dependencies change; if anything about the module manifest must be changed, validation of the change would be skipped by using this method. In those cases, simply revert to the build / publish / test approach -- you'll pay the performance penalty but can successfully validate the change. You can then return to using the faster `-FromSource` approach since running the `publish-moduletodev` step will have updated the dependencies.

#### Automated tests
AutoGraphPS-SDK's automated tests can be executed by starting a shell via the previously described `import-devmodule` script and executing the following command from within the shell:

```powershell
invoke-pester
```

## Publish the module to a PowerShell repository
Use the command below to publish the package generated by the `build-package` command to a PowerShell Gallery compatible module repository:

```powershell
.\build\publish-modulepackage.ps1 [your-module-repo] [-repositoryKeyFile your-access-key-if-needed]
```

After you've published the module to a repository, you can use commands such as `install-module` targeted at that repository to install a AutoGraphPS-SDK module with your code changes from that repository.

## Clean build
To remove all artifacts generated by the build process such as files under `pkg`, downloaded dependencies, etc., run the following command

```powershell
.\build\clean-build.ps1
```

It is advisable to run this command prior to publishing the module or performing acceptance tests -- this ensures that you're testing your latest changes and that possibly hidden or removed dependencies are identified prior to module being published to a repository.

## Installing from source
If you'd like to install the module from source, either to test installation itself or to make use of changes (your own or other forks / branches of the project) on your own system, you can simply run the following command

```powershell
.\build\install-fromsource.ps1
```

Note that this script simply automates the sequence of a clean build, build, publish to a local developer repository, followed by installation from that repository. A faster way to achieve this result follows if you've already had at least one successful `build-package` execution:

```powershell
.\build\build-package.ps1 # skip if you haven't changed code since last build-package
.\build\publish-moduletodev.ps1
.\build\install-devmodule.ps1
```

## Advanced scenarios
The `publish-moduletodev`, `import-devmodule`, and `install-devmodule` scripts support parameters that allow you to obtain dependencies from a repository other than PowerShell Gallery. This may be required because your changes to AutoGraphPS-SDK are dependent on changes that you're making to a dependency (e.g. [`ScriptClass`](https://github.com/adamedx/scriptclass) that have not yet been accepted to that dependency and uploaded to PowerShell Gallery.

In this use case, you can clone the dependency, build it, and publish it to your own repository, whether a local file-system based repository or a hosted (NuGet) module repository at some remote URI. The repository must be registered via the `Register-PSRepository` cmdlet, and then the name under which it is registered supplied to `publish-moduletodev`, `import-devmodule`, or `install-devmodule`.

Without this type of feature, developers would need to manually provision dependencies for use in testing `AutoGraphPS-SDK`, or implement their own automation to compensate for the omission.

## Build script inventory

All of the build scripts used in this project are given below with their uses -- for mroe information, see the actual build scripts in this [directory](.) and review their supported options.

|   | Script                         | Purpose                                                                                           |
|---|--------------------------------|---------------------------------------------------------------------------------------------------|
| 1 | [configure-tools.ps1](configure-tools.ps1)  | Installs tools required by all other scripts such as the dotnet tool and PowerShell Pester module    |
| 2 | [install.ps1](install.ps1)         | Installs any prerequesite library dependnecies from a package repository that must be bundled with the PowerShell module    |
| 3 | [build-package.ps1](build-package.ps1)         | Builds the Powershell module package for AutoGraphPS-SDK that can be published to a repository      |
| 4 | [publish-moduletodev.ps1](publish-moduletodev.ps1)   | Copies a built module to a local repository along with its module dependencies                    |
| 5 | [import-devmodule.ps1](import-devmodule.ps1)      | Creates a new shell with your module imported -- does not require a recent build as long as the required module dependencies are avaialble from a previous execution of `publish-moduletodev.ps1`                                           |
| 6 | [publish-modulepackage.ps1](publish-modulepackage.ps1) | Publishes the module to a PowerShell package repository        |
| 7 | [install-devmodule.ps1](install-devmodule.ps1)     | Installs the module published via `publish-moduletodev.ps1` to the system                    |
| 8 | [clean-build.ps1](clean-build.ps1)           | Deletes all artifacts generated by any of the build scripts                                       |
| 9 | [install-fromsource.ps1](install-fromsource.ps1)    | Installs the module by automating 6, 1, 2, and 5.                                                 |
| 10 | [quickstart.ps1](quickstart.ps1)            | Starts a shell with AutoGraphPS-SDK imported with hints / and tips without installing to the system |

