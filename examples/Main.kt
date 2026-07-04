import org.obinexus.polycall.Polycall

fun main(args: Array<String>) {
    val configPath = args.firstOrNull() ?: Polycall.DEFAULT_CONFIG
    Polycall.runConfigOrThrow(configPath)
    println("libpolycall completed '$configPath' successfully")
}
