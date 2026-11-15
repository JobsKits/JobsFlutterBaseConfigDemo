group = "com.jobs.platformlab"
version = "0.1.0"

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:9.3.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.4.20")
    }
}
apply(plugin = "com.android.library")
apply(plugin = "kotlin-android")

configure<com.android.build.api.dsl.LibraryExtension> {
    namespace = "com.jobs.platformlab"
    compileSdk = 36
    defaultConfig { minSdk = 24 }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://jitpack.io") }
}
dependencies {
    add("implementation", "com.github.pedroSG94.RootEncoder:library:2.8.1")
}
