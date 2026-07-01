# kotlin-polycall

**Kotlin** binding for [libpolycall](https://github.com/obinexus/libpolycall) — an
implemented reference adapter.

A thin adapter over the flat FFI boundary (`polycall_ffi.h`). It contains no
config or runtime logic; every call forwards to the shared C core. See
[../../docs/adapter-pattern.md](../../docs/adapter-pattern.md).

## Build & run

```bash
cd ../.. && ./setup.sh          # build the shared core (build/libpolycall.*)
cd bindings/kotlin-polycall
kotlinc src/main/kotlin/org/obinexus/polycall/Polycall.kt -include-runtime -d polycall.jar
java --enable-preview --enable-native-access=ALL-UNNAMED \
  -Djava.library.path=../../build -jar polycall.jar kotlin-polycallrc
```

Uses the JDK 21 Foreign Function & Memory API (Project Panama), like java-polycall.

## Config

Read-only config: [`kotlin-polycallrc`](kotlin-polycallrc) — the standard `*polycallrc` convention on
the single shared schema. No per-language parser exists.

## Manifest

See [`polycall-binding.json`](polycall-binding.json).
