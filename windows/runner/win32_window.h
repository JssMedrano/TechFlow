#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// Abstração de classe para uma janela Win32 com suporte a DPI alto. Pensada
// para ser herdada por classes que queiram especializar renderização
// e tratamento de entrada personalizados.
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  // Cria uma janela win32 com |title|, posicionada e dimensionada com
  // |origin| e |size|. Novas janelas são criadas no monitor padrão. Os
  // tamanhos são informados ao SO em pixels físicos; por isso, para manter
  // um tamanho consistente, esta função escala a largura e a altura de
  // entrada conforme o monitor padrão. A janela fica invisível até
  // |Show| ser chamado. Retorna true se a janela foi criada com sucesso.
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  // Exibe a janela atual. Retorna true se a janela foi exibida com sucesso.
  bool Show();

  // Libera os recursos do SO associados à janela.
  void Destroy();

  // Insere |content| na árvore de janelas.
  void SetChildContent(HWND content);

  // Retorna o handle da Janela para permitir definir ícone e outras
  // propriedades. Retorna nullptr se a janela foi destruída.
  HWND GetHandle();

  // Se true, fechar esta janela encerra o aplicativo.
  void SetQuitOnClose(bool quit_on_close);

  // Retorna um RECT com os limites da área cliente atual.
  RECT GetClientArea();

 protected:
  // Processa e encaminha mensagens relevantes de mouse, mudança de
  // tamanho e DPI. Delega o tratamento a sobrecargas de membros que
  // classes herdeiras podem implementar.
  virtual LRESULT MessageHandler(HWND window,
                                 UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  // Chamado quando CreateAndShow é executado, permitindo configuração
  // relacionada à janela na subclasse. Subclasses devem retornar false se falhar.
  virtual bool OnCreate();

  // Chamado quando Destroy é executado.
  virtual void OnDestroy();

 private:
  friend class WindowClassRegistrar;

  // Callback do SO chamado pela bomba de mensagens. Trata WM_NCCREATE, que
  // é enviado quando a área não cliente está sendo criada, e habilita o
  // dimensionamento automático de DPI da área não cliente para que ela
  // responda automaticamente a mudanças de DPI. As demais mensagens
  // são tratadas por MessageHandler.
  static LRESULT CALLBACK WndProc(HWND const window,
                                  UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  // Obtém o ponteiro da instância da classe para |window|
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  // Atualiza o tema do frame da janela para combinar com o tema do sistema.
  static void UpdateTheme(HWND const window);

  bool quit_on_close_ = false;

  // Handle da janela de nível superior.
  HWND window_handle_ = nullptr;

  // Handle do conteúdo hospedado.
  HWND child_content_ = nullptr;
};

#endif  // RUNNER_WIN32_WINDOW_H_
