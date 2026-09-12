#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>
#include <vector>

// Cria um console para o processo e redireciona stdout e stderr
// para ele, tanto no runner quanto na biblioteca Flutter.
void CreateAndAttachConsole();

// Recebe um wchar_t* nulo-terminado em UTF-16 e retorna um std::string
// em UTF-8. Retorna um std::string vazio em caso de falha.
std::string Utf8FromUtf16(const wchar_t* utf16_string);

// Obtém os argumentos da linha de comando como std::vector<std::string>,
// codificados em UTF-8. Retorna um vetor vazio em caso de falha.
std::vector<std::string> GetCommandLineArguments();

#endif  // RUNNER_UTILS_H_
