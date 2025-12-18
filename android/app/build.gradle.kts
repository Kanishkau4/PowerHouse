plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.powerhouse"
    // 👇 1. මෙතන 35 කරන්න (36 ඉල්ලුවට 35 බොහෝ විට හරියනවා)
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Updated to VERSION_17
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Updated JVM target to 17
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.powerhouse"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}