import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firebase config is added per environment and is not in VCS yet. Without
// it the build still works and the app runs without push notifications.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.warn("w: android/app/google-services.json is missing; push notifications are disabled in this build.")
}

// Secrets live in the git-ignored android/local.properties, never in VCS.
val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

// Upload-key credentials live in the git-ignored android/key.properties
// (template: key.properties.example), never in VCS.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "com.ssm.merchant"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
    }


    defaultConfig {
        // Permanent once published on Google Play.
        applicationId = "com.ssm.merchant"
        // versionCode/versionName come from `version:` in pubspec.yaml.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        val mapsApiKey = localProperties.getProperty("MAPS_API_KEY").orEmpty()
        if (mapsApiKey.isBlank()) {
            // Without a key Google Maps renders an empty grey map.
            logger.warn("w: MAPS_API_KEY is missing from android/local.properties; the store location map will be blank.")
        }
        manifestPlaceholders["mapsApiKey"] = mapsApiKey
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                // Keeps `flutter run --release` working on machines without
                // the upload key. Google Play rejects debug-signed bundles.
                logger.warn("w: android/key.properties is missing; the release build is signed with the DEBUG key and cannot be uploaded to Google Play.")
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
