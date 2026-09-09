import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->\n        keystoreProperties.load(stream)\n    }
}

fun requiredSigningProperty(name: String): String {
    val value = keystoreProperties.getProperty(name)?.trim()
    require(!value.isNullOrEmpty()) {
        "Missing '$name' in android/key.properties."
    }
    return value
}

android {
    namespace = "app.releaf.mobile"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "app.releaf.mobile"
        minSdk = flutter.minSdkVersion
        // Google Play requires new apps submitted after 31 Aug 2026 to
        // target Android 16 / API 36 or higher.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = requiredSigningProperty("keyAlias")
                keyPassword = requiredSigningProperty("keyPassword")
                storeFile = rootProject.file(requiredSigningProperty("storeFile"))
                storePassword = requiredSigningProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Never fall back to the debug key for a production artifact.
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

gradle.taskGraph.whenReady {
    val requestsReleaseArtifact = allTasks.any { task ->
        task.name.contains("Release", ignoreCase = true) &&
            (task.name.contains("bundle", ignoreCase = true) ||
                task.name.contains("assemble", ignoreCase = true) ||
                task.name.contains("package", ignoreCase = true))
    }

    if (requestsReleaseArtifact && !keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release signing is not configured. Copy android/key.properties.example " +
                "to android/key.properties and point it at the private upload keystore.",
        )
    }
}

flutter {
    source = "../.."
}
