plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}

// Kotlin version for plugins that use rootProject.ext.kotlin_version (Groovy compat)
extra["kotlin_version"] = "1.9.23"

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
