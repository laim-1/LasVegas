#include "platform/Window.h"

#include <SDL.h>

namespace LasVegas {

Window::Window() = default;

Window::~Window() { Shutdown(); }

void Window::Shutdown() {
  if (m_window) {
    SDL_DestroyWindow(m_window);
    m_window = nullptr;
  }
  SDL_Quit();
  m_open = false;
}

bool Window::Init(const char* title, int width, int height) {
  m_width = width;
  m_height = height;

  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_EVENTS) != 0) {
    return false;
  }

  // Request a modern OpenGL context.
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

  const Uint32 flags = SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE;
  m_window = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width,
                               height, flags);
  if (!m_window) {
    return false;
  }

  SDL_GL_SetSwapInterval(1);

  m_open = true;
  return true;
}

bool Window::Poll(Input& outInput) {
  outInput.quitRequested = false;
  outInput.restartRequested = false;
  outInput.mouseDeltaX = 0.0f;
  outInput.mouseDeltaY = 0.0f;

  outInput.wDown = m_wDown;
  outInput.aDown = m_aDown;
  outInput.sDown = m_sDown;
  outInput.dDown = m_dDown;

  SDL_Event e;
  while (SDL_PollEvent(&e)) {
    switch (e.type) {
      case SDL_QUIT: {
        outInput.quitRequested = true;
        m_open = false;
        break;
      }
      case SDL_KEYDOWN: {
        if (e.key.repeat) break;
        switch (e.key.keysym.scancode) {
          case SDL_SCANCODE_W:
            m_wDown = true;
            break;
          case SDL_SCANCODE_A:
            m_aDown = true;
            break;
          case SDL_SCANCODE_S:
            m_sDown = true;
            break;
          case SDL_SCANCODE_D:
            m_dDown = true;
            break;
          case SDL_SCANCODE_ESCAPE:
            outInput.quitRequested = true;
            m_open = false;
            break;
          case SDL_SCANCODE_R:
            outInput.restartRequested = true;
            break;
          default:
            break;
        }
        break;
      }
      case SDL_KEYUP: {
        if (e.key.repeat) break;
        switch (e.key.keysym.scancode) {
          case SDL_SCANCODE_W:
            m_wDown = false;
            break;
          case SDL_SCANCODE_A:
            m_aDown = false;
            break;
          case SDL_SCANCODE_S:
            m_sDown = false;
            break;
          case SDL_SCANCODE_D:
            m_dDown = false;
            break;
          default:
            break;
        }
        break;
      }
      case SDL_MOUSEMOTION: {
        // Relative movement events come from mouse mode or pointer lock.
        outInput.mouseDeltaX += static_cast<float>(e.motion.xrel);
        outInput.mouseDeltaY += static_cast<float>(e.motion.yrel);
        break;
      }
      default:
        break;
    }
  }

  // Close if ESC/quit requested.
  return m_open && !outInput.quitRequested;
}

void Window::SwapBuffers() { SDL_GL_SwapWindow(m_window); }

void Window::ShowCursor(bool show) {
  SDL_ShowCursor(show ? SDL_ENABLE : SDL_DISABLE);
}

void Window::SetRelativeMouseMode(bool enabled) { SDL_SetRelativeMouseMode(enabled ? SDL_TRUE : SDL_FALSE); }

void Window::SetTitle(const std::string& title) {
  if (!m_window) return;
  SDL_SetWindowTitle(m_window, title.c_str());
}

Window::Size Window::FramebufferSize() const {
  int w = 0;
  int h = 0;
  SDL_GL_GetDrawableSize(m_window, &w, &h);
  return Size{w, h};
}

void Window::FramebufferSize(int& outW, int& outH) const {
  const auto s = FramebufferSize();
  outW = s.w;
  outH = s.h;
}

} // namespace LasVegas

