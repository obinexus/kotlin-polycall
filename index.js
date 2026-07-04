'use strict';

const path = require('node:path');

const fromPackageRoot = (...parts) => path.join(__dirname, ...parts);

module.exports = Object.freeze({
  packageName: '@obinexusltd/kotlin-polycall',
  kotlinSource: fromPackageRoot('src', 'main', 'kotlin', 'org', 'obinexus', 'polycall', 'Polycall.kt'),
  nativeSource: fromPackageRoot('c_src', 'kotlin_polycall.c'),
  jniSource: fromPackageRoot('c_src', 'kotlin_polycall_jni.c'),
  nativeHeader: fromPackageRoot('include', 'kotlin_polycall.h'),
  ffiHeader: fromPackageRoot('generated', 'polycall', 'polycall_ffi.h'),
  config: fromPackageRoot('kotlin-polycallrc'),
  manifest: fromPackageRoot('polycall-binding.json'),
  makefile: fromPackageRoot('Makefile'),
  gradleBuild: fromPackageRoot('build.gradle.kts')
});
