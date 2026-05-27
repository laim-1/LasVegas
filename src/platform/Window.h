#pragma once

#include <string>

#include "platform/Input.h"

struct SDL_Window;

namespace LasVegas {

class Window {
public:
  Window();
  ~Window();

  bool Init(const char* title, int width, int height);
  bool Poll(Input& outInput);

  bool IsOpen() const { return m_open; }
  void SwapBuffers();

  void ShowCursor(bool show);
  void SetRelativeMouseMode(bool enabled);
  void SetTitle(const std::string& title);

  // Current framebuffer size (pixels).
  void FramebufferSize(int& outW, int& outH) const;
  struct Size {
    int w = 0;
    int h = 0;
  };
  Size FramebufferSize() const;

private:
  void Shutdown();

private:
  bool m_open = false;
  int m_width = 0;
  int m_height = 0;

  SDL_Window* m_window = nullptr;

  // Persistent key state so gameplay can read "is down" each frame.
  bool m_wDown = false;
  bool m_aDown = false;
  bool m_sDown = false;
  bool m_dDown = false;
};

} // namespace LasVegas

