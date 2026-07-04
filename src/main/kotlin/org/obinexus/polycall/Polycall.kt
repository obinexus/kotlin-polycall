package org.obinexus.polycall

import java.io.File

/** Raised when libpolycall returns a non-zero status. */
class PolycallException(
    val status: Int,
    val configPath: String,
) : RuntimeException(
    "libpolycall failed with status $status for config '$configPath'",
)

/** Thin Kotlin/JNI adapter for libpolycall 1.5. */
object Polycall {
    const val DEFAULT_CONFIG: String = "kotlin-polycallrc"
    const val LIBRARY_PATH_PROPERTY: String = "kotlin.polycall.library"

    init {
        val explicitLibrary = System.getProperty(LIBRARY_PATH_PROPERTY)
        if (explicitLibrary != null && explicitLibrary.isNotBlank()) {
            System.load(File(explicitLibrary).absolutePath)
        } else {
            System.loadLibrary("kotlin_polycall")
        }
    }

    private external fun nativeRunConfig(configPath: String): Int

    /** Run a configuration and return the unchanged libpolycall status. */
    @JvmStatic
    fun runConfig(configPath: String = DEFAULT_CONFIG): Int =
        nativeRunConfig(configPath)

    /** Run a configuration and throw [PolycallException] on failure. */
    @JvmStatic
    fun runConfigOrThrow(configPath: String = DEFAULT_CONFIG) {
        val status = runConfig(configPath)
        if (status != 0) {
            throw PolycallException(status, configPath)
        }
    }
}
