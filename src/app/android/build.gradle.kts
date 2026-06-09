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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// isar_flutter_libs 3.x ships with compileSdkVersion 30, which lacks android:attr/lStar (API 31+).
// gradle.afterProject fires right after each project's build script finishes, still in configuration phase.
gradle.afterProject {
    if (name == "isar_flutter_libs") {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.let { android ->
            if (android.namespace == null) android.namespace = group.toString()
            if ((android.compileSdk ?: 0) < 31) android.compileSdk = 31
        }
    }
}