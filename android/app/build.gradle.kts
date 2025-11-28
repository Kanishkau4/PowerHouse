plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.powerhouse"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Kotlin වලදී මෙතනට = ලකුණ ඕන
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        
        // Kotlin වලදී නම වෙනස්: isCoreLibraryDesugaringEnabled
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Desugaring එක්ක යද්දි මේකත් 1.8 කරන එක හොඳයි
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.powerhouse"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // සමහර විට ඕන වෙන්න පුළුවන් (Error එකක් ආවොත් විතරක් මේක uncomment කරන්න)
        // multiDexEnabled = true
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
    // Kotlin වලදී වරහන් () සහ ඩබල් කෝට්ස් "" ඕන
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}