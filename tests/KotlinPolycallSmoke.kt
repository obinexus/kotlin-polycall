package org.obinexus.polycall

fun main() {
    check(Polycall.runConfig("kotlin-polycallrc") == 0)
    check(Polycall.runConfig("__status_37__") == 37)

    val error = runCatching {
        Polycall.runConfigOrThrow("__status_37__")
    }.exceptionOrNull()

    check(error is PolycallException)
    check(error.status == 37)
    check(error.configPath == "__status_37__")

    println("kotlin-polycall Kotlin/JNI smoke test: PASS")
}
