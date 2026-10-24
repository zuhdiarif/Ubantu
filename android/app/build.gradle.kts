import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.raion.ubantu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "id.raion.ubantu"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAliasVal = keystoreProperties.getProperty("keyAlias")
            val keyPasswordVal = keystoreProperties.getProperty("keyPassword")
            val storeFileVal = keystoreProperties.getProperty("storeFile")
            val storePasswordVal = keystoreProperties.getProperty("storePassword")

            val resolvedFile = if (storeFileVal != null) {
                rootProject.file(storeFileVal).takeIf { it.exists() }
                    ?: file(storeFileVal).takeIf { it.exists() }
            } else {
                file("upload-keystore.jks").takeIf { it.exists() }
            }

            if (resolvedFile != null && resolvedFile.exists()) {
                keyAlias = keyAliasVal
                keyPassword = keyPasswordVal
                storeFile = resolvedFile
                storePassword = storePasswordVal
            }
        }
    }

    buildTypes {
        release {
            val isReleaseKeystoreConfigured = keystorePropertiesFile.exists() &&
                !keystoreProperties.getProperty("keyAlias").isNullOrBlank() &&
                signingConfigs.getByName("release").storeFile?.exists() == true

            signingConfig = if (isReleaseKeystoreConfigured) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
