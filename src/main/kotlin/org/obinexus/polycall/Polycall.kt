/*
 * kotlin-polycall - Kotlin reference adapter for libpolycall.
 *
 * Uses the JDK 21 Foreign Function & Memory API (Project Panama) to bind the
 * flat FFI boundary (include/polycall/polycall_ffi.h). No JNI, no native shim,
 * and no config/runtime logic: every function forwards to the shared C core.
 * Mirrors java-polycall - the JVM template.
 *
 * Compile (JDK 21 + Kotlin):
 *   kotlinc src/main/kotlin/org/obinexus/polycall/Polycall.kt -include-runtime -d polycall.jar
 * Run:
 *   java --enable-preview --enable-native-access=ALL-UNNAMED \
 *     -Djava.library.path=../../build -jar polycall.jar ../kotlin-polycallrc
 */
package org.obinexus.polycall

import java.lang.foreign.Arena
import java.lang.foreign.FunctionDescriptor
import java.lang.foreign.Linker
import java.lang.foreign.MemorySegment
import java.lang.foreign.SymbolLookup
import java.lang.foreign.ValueLayout
import java.lang.invoke.MethodHandle

class PolycallException(message: String, val code: Int) :
    RuntimeException("$message (status=$code)")

class Polycall : AutoCloseable {
    private val arena = Arena.ofConfined()
    private val hVersion: MethodHandle
    private val hRunConfig: MethodHandle
    private val hDescribe: MethodHandle

    init {
        val linker = Linker.nativeLinker()
        val lib = loadCore(arena)
        hVersion = linker.downcallHandle(
            lib.find("polycall_ffi_version").orElseThrow(),
            FunctionDescriptor.of(ValueLayout.JAVA_INT, ValueLayout.ADDRESS, ValueLayout.JAVA_INT))
        hRunConfig = linker.downcallHandle(
            lib.find("polycall_ffi_run_config").orElseThrow(),
            FunctionDescriptor.of(ValueLayout.JAVA_INT, ValueLayout.ADDRESS, ValueLayout.JAVA_INT))
        hDescribe = linker.downcallHandle(
            lib.find("polycall_ffi_describe").orElseThrow(),
            FunctionDescriptor.of(ValueLayout.JAVA_INT, ValueLayout.ADDRESS, ValueLayout.ADDRESS, ValueLayout.JAVA_INT))
    }

    private fun loadCore(arena: Arena): SymbolLookup {
        var last: RuntimeException? = null
        for (n in listOf("polycall", "libpolycall")) {
            try {
                return SymbolLookup.libraryLookup(System.mapLibraryName(n), arena)
            } catch (e: RuntimeException) {
                last = e
            }
        }
        throw IllegalStateException(
            "could not load shared libpolycall; build the core first (./setup.sh) " +
                "and set -Djava.library.path to build/", last)
    }

    fun version(): String =
        Arena.ofConfined().use { a ->
            val buf = a.allocate(64)
            hVersion.invoke(buf, 64)
            buf.getUtf8String(0)
        }

    fun runConfig(path: String?, run: Boolean) {
        Arena.ofConfined().use { a ->
            val p = if (path == null) MemorySegment.NULL else a.allocateUtf8String(path)
            val rc = hRunConfig.invoke(p, if (run) 1 else 0) as Int
            if (rc != 0) throw PolycallException("run_config($path)", rc)
        }
    }

    fun describe(path: String?): String =
        Arena.ofConfined().use { a ->
            val buf = a.allocate(256)
            val p = if (path == null) MemorySegment.NULL else a.allocateUtf8String(path)
            val rc = hDescribe.invoke(p, buf, 256) as Int
            val text = buf.getUtf8String(0)
            if (rc != 0) throw PolycallException("describe: $text", rc)
            text
        }

    override fun close() = arena.close()
}

fun main(args: Array<String>) {
    val cfg = args.getOrNull(0)
    Polycall().use { pc ->
        try {
            println("kotlin-polycall using libpolycall ${pc.version()}")
            println(pc.describe(cfg))
            pc.runConfig(cfg, true)
        } catch (e: PolycallException) {
            System.err.println("kotlin-polycall error: ${e.message}")
            kotlin.system.exitProcess(e.code)
        }
    }
}
