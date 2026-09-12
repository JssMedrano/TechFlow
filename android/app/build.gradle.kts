plugins {
    id("com.android.application")
    // O plugin Gradle do Flutter deve ser aplicado depois dos plugins Android e Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.manutencao.manutencao_os"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Defina seu próprio Application ID único (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.manutencao.manutencao_os"
        // Você pode atualizar os valores abaixo conforme as necessidades do aplicativo.
        // Mais informações: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Usa o version code do pubspec.yaml. Ao usar APKs divididos, 1000 * ABI_VERSION
        // é adicionado automaticamente pelo Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // Você pode forçar o uso do valor de versionCode especificando `-P force-version-code-ignoring-abi=true`
        // na compilação.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Adicione sua própria configuração de assinatura para o build de release.
            // Por enquanto assina com as chaves de debug, para que `flutter run --release` funcione.
            signingConfig = signingConfigs.getByName("debug")
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
