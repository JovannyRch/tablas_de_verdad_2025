import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.tablas_de_verdad_2025"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    flavorDimensions += "version"

    productFlavors {
        create("es") {
            dimension = "version"
            applicationId = "com.jovannyrch.tablasdeverdad"
            manifestPlaceholders["app_name"] = "Tablas de Verdad"
            manifestPlaceholders["admob_app_id"] = "ca-app-pub-4665787383933447~4689744776"
        }
        create("en") {
            dimension = "version"
            applicationId = "com.jovannyrch.tablasdeverdad.en"
            manifestPlaceholders["app_name"] = "Truth Tables"
            manifestPlaceholders["admob_app_id"] = "ca-app-pub-4665787383933447~1652617896"
        }
    }

    defaultConfig {
        // applicationId is now set in productFlavors
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

     signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
