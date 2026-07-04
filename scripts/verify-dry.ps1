$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$nativeSources = @(
    (Join-Path $root 'c_src/kotlin_polycall.c'),
    (Join-Path $root 'c_src/kotlin_polycall_jni.c')
)
$kotlinSource = Join-Path $root 'src/main/kotlin/org/obinexus/polycall/Polycall.kt'
$forbidden = 'fopen|open\(|CreateFile|sscanf|strtok|socket\(|connect\('
$matches = Select-String -Path ($nativeSources + $kotlinSource) -Pattern $forbidden

if ($matches) {
    $matches | ForEach-Object { Write-Error $_.Line }
    throw 'kotlin-polycall must not parse configuration or implement runtime logic'
}

$adapter = Get-Content -Raw $nativeSources[0]
$jni = Get-Content -Raw $nativeSources[1]
$kotlin = Get-Content -Raw $kotlinSource
if (-not $adapter.Contains('polycall_ffi_run_config(config_path, 1)')) {
    throw 'kotlin-polycall does not forward through polycall_ffi_run_config'
}
if (-not $jni.Contains('GetStringUTFChars') -or
    -not $jni.Contains('ReleaseStringUTFChars')) {
    throw 'kotlin-polycall does not safely marshal its JNI string'
}
if (-not $kotlin.Contains('external fun nativeRunConfig')) {
    throw 'kotlin-polycall does not declare its JNI entry point'
}

Write-Output 'kotlin-polycall thin-adapter check: PASS'
