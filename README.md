# TechFlow

Aplicativo Flutter para gestão de ordens de serviço e manutenção técnica.

**Plataformas:** Web, Windows, Android, macOS e Linux.

## Tecnologias

- Flutter 3 / Dart 3
- SQLite (`sqflite` + `sqflite_common_ffi` + `sqflite_common_ffi_web` + `sqlite3_flutter_libs`)
- Provider (gerenciamento de estado)
- image_picker / SharedPreferences (evidências)
- google_fonts (interface TechFlow)

## Pré-requisitos

- Flutter SDK (`flutter doctor`)
- Windows: Visual Studio com workload Desktop C++
- macOS: Xcode
- Linux: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev` e `libstdc++-dev`
- Android: Android Studio / SDK
- Web: Chrome ou Edge

## Execução

```bash
flutter pub get
```

### Web

```bash
dart run sqflite_common_ffi_web:setup
flutter run -d chrome
```

### Windows

```bash
flutter run -d windows
```

### macOS

```bash
flutter run -d macos
```

### Linux

```bash
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-dev
flutter run -d linux
```

### Android

```bash
flutter run -d android
```

## Login de demonstração

| Usuário    | Senha     | Perfil         |
|------------|-----------|----------------|
| admin      | admin123  | Administrador  |
| atendente  | atend123  | Atendente      |
| tecnico    | tec123    | Técnico        |

Na primeira execução o app popula automaticamente clientes, técnicos, equipamentos e **12 ordens de serviço** de exemplo.

## Documentação

O projeto tem um único documento de entrega:

`entrega/TRABALHO_ACADEMICO_TechFlow.docx`

Ele reúne descrição, objetivos, tecnologias, arquitetura, regras, wireframes, roteiro de evidências e análise crítica. Preencha o nome e o RU e cole as capturas nos espaços marcados.

## Testes

```bash
flutter test
```
