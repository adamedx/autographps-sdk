# AutoGraphPS-SDK - Copilot Instructions

AutoGraphPS-SDK is a PowerShell module that automates the Microsoft Graph API. It serves as the SDK foundation for [AutoGraphPS](https://github.com/adamedx/autographps), a Graph exploration UX. The module targets PowerShell 5.1+ (Windows) and PowerShell 7.0+ (Linux/macOS).

## Build and Test

First-time setup, or if dependencies change:

```powershell
./build/clean-build.ps1
./build/configure-tools.ps1
./build/install.ps1
./build/build-package.ps1
./build/publish-moduletodev.ps1
```

Subsequent builds (no dependency changes):

```powershell
./build/build-package.ps1
```

Launch a test shell with the module loaded:

```powershell
./build/import-devmodule.ps1 -FromSource   # fast: loads directly from source files
./build/import-devmodule.ps1               # full: loads from published dev module
```

Run all unit tests (from within the test shell):

```powershell
Invoke-Pester
```

Run a single test file:

```powershell
Invoke-Pester -Script ./src/cmdlets/Test-Graph.tests.ps1
```

Integration tests require a separate shell and pre-configured credentials in `.testconfig/TestConfig.json` (see `build/README.md`):

```powershell
./test/Initialize-IntegrationTestEnvironment.ps1
./test/CI/RunIntegrationTests.ps1
```

Clean all build artifacts:

```powershell
./build/clean-build.ps1
```

## Architecture

### Module Entry Points

- `autographps-sdk.psd1` — Module manifest declaring exported functions, aliases, variables, and the `ScriptClass` nested module dependency.
- `autographps-sdk.psm1` — Root module that dot-sources `src/graph-sdk.ps1`, defines the `GraphResponseObject` class, and calls `Export-ModuleMember`.
- `src/graph-sdk.ps1` — Bootstraps the module by importing `src/cmdlets.ps1`, `src/aliases.ps1`, and `src/formats.ps1`.

### Source Layout (`src/`)

| Directory | Purpose |
|-----------|---------|
| `cmdlets/` | One `.ps1` file per exported cmdlet (e.g., `Get-GraphResource.ps1`). Each file defines a single function. |
| `cmdlets/common/` | Shared helpers used by cmdlets: parameter completers, display formatting, query building, certificate handling. |
| `client/` | Core client objects — `GraphConnection`, `GraphContext`, `GraphIdentity`, `LocalSettings`, `LocalProfile`. |
| `auth/` | Authentication providers and device code flow (`V2AuthProvider`, `DeviceCodeAuthenticator`). |
| `REST/` | HTTP layer — `GraphRequest`, `GraphResponse`, `RESTRequest`, `RESTResponse`, `RequestLog`. |
| `graphservice/` | Graph service abstractions — `GraphEndpoint`, `ApplicationAPI`, `ApplicationObject`. |
| `common/` | Cross-cutting utilities — `GraphUtilities`, `ColorString`, `ScopeHelper`, `Secret`, `ProgressWriter`. |

### ScriptClass Framework

All internal components use the [ScriptClass](https://github.com/adamedx/scriptclass) module for object-oriented patterns. Instead of PowerShell native classes, types are declared with the `ScriptClass` keyword:

```powershell
ScriptClass GraphConnection {
    $Id = $null
    $Identity = $null
    # ...
    function __initialize(...) { ... }  # constructor
    static { ... }                      # static members
}
```

File imports use `import-script` (from ScriptClass) rather than dot-sourcing, analogous to `import`/`require` in other languages:

```powershell
. (import-script ../graphservice/GraphEndpoint)
. (import-script GraphIdentity)
```

### Dependencies

- **ScriptClass** (v0.20.3) — OOP framework, declared as a `NestedModule` in the manifest.
- **MSAL** (Microsoft.Identity.Client) — .NET assemblies under `lib/` for `net472` and `net6.0`, handling OAuth token acquisition.

## Conventions

### File Organization

- **One cmdlet per file** in `src/cmdlets/`, named exactly as the cmdlet (e.g., `Get-GraphResource.ps1`).
- **One ScriptClass per file** in other `src/` subdirectories.
- When adding a new cmdlet: create the file, add it to `src/cmdlets.ps1` (import list), `autographps-sdk.psm1` (export list), `autographps-sdk.psd1` (both `FunctionsToExport` and `FileList`), and `autographps-sdk.tests.ps1` (expected functions list).

### Test Files

- Unit tests live alongside source files with a `.tests.ps1` suffix (e.g., `Test-Graph.tests.ps1`).
- Integration tests use a `-integration.tests.ps1` suffix or reside under `test/integration/`.
- Tests use Pester v4.8.1 syntax (`Should Be`, `Should Not Throw` — not Pester v5 `Should -Be`).

### Code Style

- **OTBS** (One True Brace Style) for brace placement.
- `set-strictmode -version 5` is enabled in the module root.
- Cmdlets must include comment-based help (synopsis, description, parameters, examples) following the pattern in existing cmdlets like `Get-GraphResource.ps1`.

### Commit Requirements

DCO sign-off (`Signed-off-by: Name <email>` via `git commit -s`) is optional but appreciated.
