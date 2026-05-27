#pragma once

#include <glm/glm.hpp>

#include "platform/Window.h"

#include "game/Enemy.h"
#include "game/Level.h"
#include "game/Player.h"
#include "renderer/Camera.h"
#include "renderer/Mesh.h"
#include "renderer/Shader.h"

namespace LasVegas {

class Renderer {
public:
  bool Init();

  void BeginFrame(const Window::Size& framebufferSize);
  void BeginFrame(int w, int h);

  void RenderScene(const Level& level, const Camera& camera, const Player& player,
                    const Enemy& enemy, float timeSeconds);

private:
  void RenderBox(const glm::vec3& min, const glm::vec3& max, const glm::vec3& color,
                  const glm::mat4& view, const glm::mat4& proj);

private:
  bool m_initialized = false;
  Shader m_shader;
  Mesh m_cube;

  int m_fbW = 0;
  int m_fbH = 0;
};

} // namespace LasVegas

