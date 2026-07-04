#!/usr/bin/env sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if grep -E -n 'fopen|open\(|CreateFile|sscanf|strtok|socket\(|connect\(' \
    "$root/c_src/kotlin_polycall.c" \
    "$root/c_src/kotlin_polycall_jni.c" \
    "$root/src/main/kotlin/org/obinexus/polycall/Polycall.kt"; then
    echo "kotlin-polycall must not parse configuration or implement runtime logic" >&2
    exit 1
fi

grep -F -q 'polycall_ffi_run_config(config_path, 1)' \
    "$root/c_src/kotlin_polycall.c"
grep -F -q 'GetStringUTFChars' "$root/c_src/kotlin_polycall_jni.c"
grep -F -q 'ReleaseStringUTFChars' "$root/c_src/kotlin_polycall_jni.c"
grep -F -q 'external fun nativeRunConfig' \
    "$root/src/main/kotlin/org/obinexus/polycall/Polycall.kt"

echo "kotlin-polycall thin-adapter check: PASS"
