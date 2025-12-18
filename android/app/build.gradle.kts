plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bahasaku_v1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        
        // --- PERBAIKAN UTAMA DISINI ---
        // Menggunakan sintaks Kotlin DSL (pakai '=' dan 'is')
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.bahasaku_v1"
        // Min SDK 21 diperlukan untuk plugin kamera & desugaring
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Mengaktifkan multidex (opsional tapi disarankan)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// --- BLOK DEPENDENCIES ---
dependencies {
    // Library Desugaring (Wajib ada jika isCoreLibraryDesugaringEnabled = true)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
