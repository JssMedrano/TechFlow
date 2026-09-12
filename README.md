# TechFlow

Aplicativo Flutter para gestão de ordens de serviço e manutenção técnica.

**Marca:** TechFlow  
**Plataformas:** Web, Windows, Android, macOS e Linux.

## Objetivo

Centralizar clientes, técnicos, equipamentos e ordens de serviço, substituindo planilhas e controles dispersos, com acompanhamento do atendimento da abertura à conclusão.

## Tecnologias

- Flutter 3 / Dart 3
- SQLite (`sqflite` + `sqflite_common_ffi` + `sqflite_common_ffi_web` + `sqlite3_flutter_libs`)
- Provider (estado)
- image_picker / SharedPreferences (evidências)
- google_fonts (UI TechFlow)

## Estrutura

```
lib/
  core/           # constantes, tema, validações, transições de status
  models/         # entidades OOP
  repositories/   # persistência (padrão Repository)
  services/       # banco, seed, imagens
  providers/      # gerenciamento de estado
  screens/        # telas
  widgets/        # componentes reutilizáveis
```

## Pré-requisitos

- Flutter SDK (`flutter doctor`)
- Windows: Visual Studio com workload Desktop C++
- macOS: Xcode (aplicativos macOS)
- Linux: `clang`, `cmake`, `ninja-build`, `pkg-config` e `libgtk-3-dev`
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

## Funcionalidades

- Login local com perfis
- CRUD de clientes, técnicos e equipamentos
- Abertura/edição de OS com prioridade, prazo, status, diagnóstico e solução
- Fluxo de status com transições validadas
- Peças/materiais + mão de obra com total automático
- Destaque de OS urgentes e atrasadas
- Anexos de imagem (galeria/câmera)
- Busca e filtros
- Painel com indicadores operacionais
- Histórico de alterações
- Persistência local SQLite
- Interface TechFlow (tema escuro) responsiva

## Documentação

- `docs/DOCUMENTACAO.md` — descrição completa
- `docs/RELATORIO_FINAL.md` — análise crítica
- `docs/WIREFRAMES.md` — protótipo das telas
- `docs/EVIDENCIAS.md` — roteiro de demonstração
