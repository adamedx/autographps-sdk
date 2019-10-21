
[cmdletbinding(defaultparametersetname='bymodulename')]
param(
    [parameter(mandatory=$true)]
    $Path,

    [parameter(parametersetname='bymodulename')]
    $ModuleName,

    [parameter(parametersetname='byclassname', mandatory=$true)]
    [switch] $Class,

    [parameter(parametersetname='byclassname')]
    $ClassName
)
set-strictmode -version 2

if ( ! ( test-path $Path ) ) {
    throw "Path '$Path' does not exist"
}

$fileInfo = get-item $Path

$module = if ( $Class.IsPresent ) {
    $targetClassName = if   ( $ClassName ) {
        $className
    } else {
        $fileInfo.basename
    }

    $classInfo = try {
        get-scriptclass $targetClassName
    } catch {
        throw
    }

    $classInfo.module
} else {
    $targetModuleName = if ( $ModuleName ) {
        $ModuleName
    } else {
        ( get-item (split-path -parent $psscriptroot) ).name
    }

    write-host 'mod', $targetModuleName
    get-module $targetModuleName
}

. $module.NewBoundScriptBlock(
    {
        param($sourcePath)
        [ScriptBlock]::Create(". '$sourcePath'")
    }
) $fileInfo.fullname
