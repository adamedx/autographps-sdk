AutoGraphPS-SDK Configuration
=============================

The AutoGraphPS-SDK module supports configuration in the form of settings that modify the user experiance and default behaviors of the module's commands.

## The settings file

The AutoGraphPS-SDK settings are read from a file by the module when it is first loaded, i.e. when it is explicitly imported using the `Import-Module` command or when the first AutoGraphPS-SDK command is invoked. By default the module reads the settings from the following location:

```
~/.autographps/settings.json
```

The file uses the `JSON` format and its schema is described using this [JSON schema file](settings.schema.json).

The settings file is completely optional, so AutoGraphPS-SDK commands will function without it using built-in defaults for those settings.

### Settings file management

AutoGraphPS-SDK behavior with respect to the settings file can be managed using environment variables. These may be configured in the PowerShell profile itself at PowerShell session start time for instance before the module is loaded. The following two environment variables are supported:

* `AUTOGRAPH_BYPASS_SETTINGS`: When this enviroment variable is configured to a non-empty value, the settings file will be completely ignored and no settings will be loaded.
* `AUTOGRAPH_SETTINGS_FILE`: Set this environment variable to a path to a settings file -- this is useful when testing out new settings since the default settings file can be left in place while new changes are specified in an alternate file which is then referenced by this variable.

By convention, settings file should end with the extension `.schema.json`.

## High-level organization

The settings file is arranged into four sections:

* **Root settings:** these are the key-value pairs at the root of the JSON hierarchy, with the exception of the `profiles`, `connections`, and `endpoints` keys which are themselves the root of the other three sections. Currently there is only one key-value pair defined at the Root Settings level, the property `defaultProfile`. Additional properties other than `defaultProfile` may be present without violating the file schema.

* **Profile settings:** A profile is a set of key-value pairs that affect the behavior of AutoGraphPS. In the file they are defined as child nodes of the root-level `profiles` property. These settings are essentially user preferences, and while users can define multiple profiles, only one may be active at a single time. At startup, the `defaultProfile` property from Root Settings determines which, if any, of the profiles defined under `profiles` is active. The `Select-ProfileSettings` command may be used to switch the active profile based on the profiles read by the module at startup. Like the keys of the Root Settings section, keys in a `profile` object that are not explicitly defined in the schema may still be present without a schema violation.

* **Connection definitions:** A *connection* defined in the `connections` section simply describes the same object created by the `New-GraphConnection` command which is used to define the target authentication / authorization and Graph API endpoints to use with commands. Unlike the `New-GraphConnection` command which allows connections to be created with an optionally specified `Name` property, the corresponding `name` property for that same connection when defined in the `connections` section *MUST* be specified; all connections specified in the file must be named connections. This allows connections defined in the settings file to be referenced by name to the `Connect-GraphApi` and `Get-GraphConnection` commands since the connections are created when the settings file is processed at module startup. The connections may also be referenced using their names from one of the profiles in the `profiles` sections since the `connection` property of a profile that defines the default connection to use when communicating with Graph may specify a connection via its `name` property.

* **Endpoint definitions:** An **endpoint* is a set of key-value pairs defined udnder the `endpoints` node of the file. The endpoint object provides a convenient way to name the authorization / authentication endpoint, Graph API endpoint, and the authorization resource URI of that Graph API endpoint. These endpoints, which may refer to proxy servers used for testing or may simply refer to new Graph API environments that are not yet direclty supported by the `Cloud` parameter of `New-GraphConnection`. These endpoints can be referenced by their names from connections defined in the `connections` section; this is the only use case for defining an endpoint at all.

### Settings reference

The [Settings Schema definition file](https://github.com/adamedx/autographps-sdk/blob/main/docs/settings/settings.schema.json) describes the semantics of all of the settings.

A [sample](sample-settings.json) settings file may also prove instructive.

### Extensibility

Some sections of the settings file allow for other applications to add custom keys and properties. This is useful for applications / modules that build on top of `AutoGraphPS-SDK` so that users can utilize the application without the need for more than one configuration file -- settings for all modules powered by AutoGraphPS-SDK can simply use the AutoGraphPS-SDK settings file.

The sections that support extensibilty are:

**Root Settings:** Any key value pairs may be added to the root level
**Profiles definitions:** Profiles can contain a setting for any behavior, including those defined outside of AutoGraphPS-SDK.

The `connections` and `endpoints` section do not allow for extensibility; if any property is added to a settings file that is not defined in the schema, the schema will be invalid. Those sections define objects that represent specific runtime object interface contracts defined by AutoGraphPS-SDK, whereas the properties in the profiles section define behaviors, but are not tied to an interface contract.
