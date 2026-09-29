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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// ---------------------------------------------------------------------------
// Force compileSdk=36 on ALL Android sub-projects (Flutter plugins).
// gradle.afterProject fires AFTER each project finishes its own evaluation,
// so our value wins over the plugin's own hardcoded compileSdkVersion(33).
// This is the Gradle 9-compatible replacement for afterEvaluate.
// ---------------------------------------------------------------------------
gradle.afterProject {
    extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
        compileSdkVersion(36)
        ndkVersion = "28.2.13676358"
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
