#include "renderer/Renderer.h"

#include <algorithm>
#include <cmath>
#include <glm/gtc/matrix_transform.hpp>

#include "renderer/GLLoader.h"
#include "platform/Window.h"

namespace LasVegas {

bool Renderer::Init() {
  if (!gl::Load()) {
    return false;
  }

  if (!m_shader.LoadFromFiles("assets/shaders/vertex.glsl", "assets/shaders/fragment.glsl")) {
    return false;
  }

  if (!m_cube.InitCube()) {
    return false;
  }

  // Global GL state.
  gl::Enable(GL_DEPTH_TEST);
  gl::DepthFunc(GL_LESS);

  m_initialized = true;
  return true;
}

void Renderer::BeginFrame(const Window::Size& framebufferSize) { BeginFrame(framebufferSize.w, framebufferSize.h); }

void Renderer::BeginFrame(int w, int h) {
  if (!m_initialized) return;
  m_fbW = w;
  m_fbH = h;
  gl::Viewport(0, 0, w, h);
  gl::ClearColor(0.02f, 0.02f, 0.03f, 1.0f);
  gl::Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void Renderer::RenderBox(const glm::vec3& min, const glm::vec3& max, const glm::vec3& color,
                          const glm::mat4& view, const glm::mat4& proj) {
  glm::vec3 size = max - min;
  glm::vec3 center = (min + max) * 0.5f;

  glm::mat4 model = glm::mat4(1.0f);
  model = glm::translate(model, center);
  model = glm::scale(model, size);

  m_shader.Use();
  m_shader.SetMat4("uModel", model);
  m_shader.SetMat4("uView", view);
  m_shader.SetMat4("uProj", proj);
  m_shader.SetVec3("uColor", color);
}

void Renderer::RenderScene(const Level& level, const Camera& camera, const Player& /*player*/,
                            const Enemy& enemy, float timeSeconds) {
  if (!m_initialized) return;

  const float safeAspect = (m_fbH != 0) ? static_cast<float>(m_fbW) / static_cast<float>(m_fbH)
                                        : (16.0f / 9.0f);
  glm::mat4 proj = glm::perspective(glm::radians(70.0f), safeAspect, 0.01f, 100.0f);
  // Proximity-based atmosphere (flicker + subtle screen shake).
  glm::vec3 toEnemy = enemy.position - camera.position;
  toEnemy.y = 0.0f;
  const float dist = glm::length(toEnemy);
  const float proximity = std::clamp(1.0f - (dist / 10.0f), 0.0f, 1.0f);

  Camera shakenCam = camera;
  if (proximity > 0.0001f) {
    const float shakeStrength = 0.04f * proximity;
    shakenCam.position += glm::vec3(
        (std::sinf(timeSeconds * 60.0f) + std::sinf(timeSeconds * 35.0f)) * shakeStrength,
        std::sinf(timeSeconds * 50.0f) * (shakeStrength * 0.35f), 0.0f);
  }

  glm::mat4 view = shakenCam.ViewMatrix();

  m_shader.Use();
  m_shader.SetVec3("uCameraPos", shakenCam.position);
  m_shader.SetVec3("uCameraForward", glm::normalize(shakenCam.Forward()));
  m_shader.SetVec3("uLightDir", glm::normalize(glm::vec3(-0.25f, -1.0f, -0.2f)));
  // Flashlight tuning (prototype defaults).
  m_shader.SetFloat("uFlashlightRange", 12.0f);
  // cutoffCos = cos(spotAngleRadians). For ~25 degrees: cos(25deg) ~= 0.906.
  m_shader.SetFloat("uFlashlightCutoffCos", 0.906f);
  {
    // Flicker is stronger as the enemy gets closer.
    const float baseIntensity = 2.8f;
    const float flicker =
        1.0f + proximity * 0.25f * (std::sinf(timeSeconds * 38.0f) * 0.7f + std::sinf(timeSeconds * 9.0f) * 0.3f);
    m_shader.SetFloat("uFlashlightIntensity", baseIntensity * std::clamp(flicker, 0.5f, 1.4f));
  }
  m_shader.SetFloat("uFogDensity", 0.02f);
  m_shader.SetFloat("uTime", timeSeconds);

  for (const auto& b : level.boxes) {
    RenderBox(b.min, b.max, b.color, view, proj);
  }

  // Render enemy as a cube.
  {
    glm::vec3 half = glm::vec3(0.3f, 0.6f, 0.3f);
    glm::vec3 mn = enemy.position - half;
    glm::vec3 mx = enemy.position + half;

    glm::mat4 model = glm::mat4(1.0f);
    model = glm::translate(model, enemy.position);
    // Subtle bobbing so it's obvious something moves later.
    model = glm::rotate(model, 0.0f, glm::vec3(0, 1, 0));
    model = glm::scale(model, mx - mn);

    m_shader.Use();
    m_shader.SetMat4("uModel", model);
    m_shader.SetMat4("uView", view);
    m_shader.SetMat4("uProj", proj);
    m_shader.SetVec3("uColor", glm::vec3(0.8f, 0.2f, 0.2f));
  }
}

} // namespace LasVegas

