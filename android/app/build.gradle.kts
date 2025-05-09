plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hanahala3"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.hanahala3"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = "1.8"
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

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // ✅ required for notifications
}
