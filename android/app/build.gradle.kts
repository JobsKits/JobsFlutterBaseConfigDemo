plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.jobs_flutter_base_config_demo"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // ✅ 开启 desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.jobs_flutter_base_config_demo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
            manifestPlaceholders.putAll(
                mapOf(
                    "ENGAGELAB_PRIVATES_CHANNEL" to "debug",
                    "ENGAGELAB_PRIVATES_PROCESS" to ":push",
                    "ENGAGELAB_PRIVATES_APPKEY" to "your_app_key",
                    "APP_TCP_SSL" to "true",
                    "APP_DEBUG" to "true",
                    "COUNTRY_CODE" to "CN",
                    "HONOR_APPID" to "xxx",
                    "XIAOMI_APPID" to "xxx",
                    "XIAOMI_APPKEY" to "xxx",
                    "MEIZU_APPID" to "xxx",
                    "MEIZU_APPKEY" to "xxx",
                    "OPPO_APPID" to "xxx",
                    "OPPO_APPKEY" to "xxx",
                    "OPPO_APPSECRET" to "xxx",
                    "VIVO_APPID" to "xxx",
                    "VIVO_APPKEY" to "xxx"
                )
            )
    }

    buildTypes {
        release {   
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ 添加 desugaring 支持库（必须写在外面）
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // 官方 Flutter 插件使用动态版本，在宿主固定最终 APK 的 SDK 版本。
    constraints {
        implementation("com.umeng.umsdk:common:9.9.9") {
            version { strictly("9.9.9") }
        }
        implementation("com.umeng.umsdk:asms:1.8.7.2") {
            version { strictly("1.8.7.2") }
        }
    }
}

flutter {
    source = "../.."
}

// android {
//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_17
//         targetCompatibility = JavaVersion.VERSION_17
//     }

//     kotlinOptions {
//         jvmTarget = "17"
//     }
// }
