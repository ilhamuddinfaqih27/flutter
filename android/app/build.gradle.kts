plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_iot"

    // Gunakan compileSdk bawaan Flutter
    compileSdk = flutter.compileSdkVersion

    // Gunakan versi NDK terbaru yang kamu punya
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID unik
        applicationId = "com.example.app_iot"

        // Firebase minimal butuh Android SDK 23
        minSdk = 23

        // Target SDK biar sesuai dengan versi Flutter saat ini
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Masih pakai debug key untuk sementara
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    // Path ke folder utama Flutter
    source = "../.."
}