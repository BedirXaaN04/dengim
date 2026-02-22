plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}

// Kotlin version for plugins that use rootProject.ext.kotlin_version (Groovy compat)
extra.set("kotlin_version", "1.9.24")
extra.set("compileSdkVersion", 35)
extra.set("minSdkVersion", 23)
extra.set("targetSdkVersion", 35)

allprojects {
    extra.set("kotlin_version", "1.9.24")
    
    repositories {
        google()
        mavenCentral()
    }
}

// Force specific Kotlin version for ALL dependencies to avoid mismatches
subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion("1.9.24")
            }
        }
    }
}

// Redirect build output to ASCII-only path if project path contains non-ASCII chars (e.g. Turkish 'ü')
val projectPath = rootProject.projectDir.absolutePath
val hasNonAscii = projectPath.any { it.code > 127 }

val newBuildDir: Directory = if (hasNonAscii) {
    // Local Windows: use ASCII-safe temp path
    rootProject.layout.projectDirectory.dir("C:/tmp/dengim-build")
} else {
    // CI (Linux): use relative path
    rootProject.layout.buildDirectory.dir("../../build").get()
}
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
