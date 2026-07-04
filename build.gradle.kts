plugins {
    kotlin("jvm") version "2.4.0"
    `java-library`
}

group = "org.obinexus"
version = "1.0.0"

repositories {
    mavenCentral()
}

kotlin {
    jvmToolchain(17)
}

tasks.jar {
    manifest {
        attributes["Automatic-Module-Name"] = "org.obinexus.polycall.kotlin"
    }
}
