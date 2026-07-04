# TODO — kotlin-polycall

Status: implemented thin Kotlin/JNI adapter for libpolycall 1.5.

- [x] Publishable `@obinexusltd/kotlin-polycall` npm source package
- [x] Stable Kotlin/JVM API without preview JDK dependencies
- [x] JNI string marshalling and explicit native-library loading
- [x] Exact `polycall_ffi_run_config(config_path, 1)` forwarding
- [x] Runnable example under `examples/`
- [x] Native forwarding test and Kotlin/JNI smoke test
- [x] Thin-adapter source audit for Windows and POSIX shells
- [ ] Exercise the Kotlin smoke test in release CI across supported platforms
- [ ] Publish signed platform-native artifacts alongside the source package

Do not add configuration parsing or runtime policy here; adapt the core only.
