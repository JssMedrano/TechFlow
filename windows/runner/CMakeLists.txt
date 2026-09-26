cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define o alvo do aplicativo. Para alterar o nome, mude BINARY_NAME no
# CMakeLists.txt de nível superior, não o valor aqui, ou o `flutter run`
# deixará de funcionar.
#
# Quaisquer novos arquivos de código-fonte do aplicativo devem ser adicionados aqui.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Aplica o conjunto padrão de configurações de build. Pode ser removido em
# aplicativos que precisam de configurações diferentes.
apply_standard_settings(${BINARY_NAME})

# Adiciona definições de pré-processador para a versão do build.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Desativa macros do Windows que conflitam com funções da biblioteca padrão C++.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Adiciona bibliotecas de dependência e diretórios include. Inclua aqui
# quaisquer dependências específicas do aplicativo.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Executa as partes da ferramenta Flutter no build. Não deve ser removido.
add_dependencies(${BINARY_NAME} flutter_assemble)
