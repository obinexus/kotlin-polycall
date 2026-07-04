# @obinexusltd/kotlin-polycall

Kotlin/JVM JNI binding for
[libpolycall](https://github.com/obinexus/libpolycall) 1.5. The adapter maps
Kotlin calls to the single core entry point:

```c
polycall_ffi_run_config(config_path, 1)
```

Configuration parsing, validation, networking, and runtime policy remain in
libpolycall. This package only marshals the configuration path across JNI and
returns the core status unchanged.

## Install the source package

```shell
npm install @obinexusltd/kotlin-polycall
```

The npm package publishes the complete Kotlin, JNI, and C source tree. It is a
native source distribution rather than a JavaScript implementation. Calling
`require('@obinexusltd/kotlin-polycall')` returns absolute paths to the packaged
sources, headers, configuration, manifest, and build files.

## Requirements

- libpolycall 1.5 development library and headers
- JDK 17 or newer
- Kotlin 2.4 or a compatible Gradle installation
- a C11 compiler and GNU Make

## Build

Build the standalone adapter archive without linking libpolycall:

```shell
make
```

Build the Kotlin classes with Gradle or the command-line compiler:

```shell
gradle build
# or
npm run build:kotlin
```

Build the JNI shared library by supplying the JDK location and libpolycall
linker flags:

```shell
export JAVA_HOME=/path/to/jdk
export POLYCALL_LDFLAGS='-L/path/to/lib -lpolycall'
make jni
```

PowerShell uses the same variables:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-21'
$env:POLYCALL_LDFLAGS = '-LC:\path\to\lib -lpolycall'
make jni
```

Place the JNI library on `java.library.path`, or pass its absolute path with
`-Dkotlin.polycall.library=/absolute/path/to/the/library`.

## API

```kotlin
import org.obinexus.polycall.Polycall

val status = Polycall.runConfig("kotlin-polycallrc")
Polycall.runConfigOrThrow("kotlin-polycallrc")
```

- `runConfig` returns the exact libpolycall status.
- `runConfigOrThrow` raises `PolycallException` for a non-zero status.
- Omitting the path uses `kotlin-polycallrc`.
- `kotlin.polycall.library` selects an explicit JNI library file.

See [`examples/Main.kt`](examples/Main.kt) for a runnable example.

## Verification

The default suite needs only a C compiler, Make, Node.js, and PowerShell on
Windows:

```shell
npm test
```

It verifies exact path forwarding, the required validation flag, status
propagation, thin-adapter constraints, and npm package completeness.

With Kotlin and a JDK matching the native compiler architecture installed, run
the end-to-end JNI smoke test:

```shell
npm run test:kotlin
```

## Package layout

- `src/main/kotlin/` — public Kotlin API
- `c_src/` — C adapter and JNI bridge
- `include/` — adapter C header
- `generated/polycall/` — minimal generated core FFI declaration
- `examples/` — Kotlin example and sample configuration
- `tests/` — native mock, Kotlin smoke test, and npm package test

## Author and license

Copyright © 2026 Nnamdi Michael Okpala
<okpalan@protonmail.com>.

Released under the [MIT License](LICENSE).
