#include "app/Game.h"

#include <chrono>
#include <cmath>
#include <algorithm>
#include <sstream>

namespace LasVegas {

static float SecondsSince(const std::chrono::steady_clock::time_point& start,
                           const std::chrono::steady_clock::time_point& now) {
  return std::chrono::duration_cast<std::chrono::duration<float>>(now - start).count();
}

Game::Game() = default;

void Game::ResetLevel() {
  m_level = Level::CreatePrototypeRoom();

  m_player.position = m_level.playerStart;
  m_enemy.position = m_level.enemySpawn;
  m_enemy.spawnPosition = m_enemy.position;
  m_enemy.state = Enemy::State::Patrol;
  m_enemy.playerInAttackRange = false;
  m_enemy.patrolPhase = 0.0f;

  m_camera.position = m_player.position;
  m_camera.yawRadians = 0.0f;
  m_camera.pitchRadians = 0.0f;

  m_elapsedSeconds = 0.0f;
}

int Game::Run() {
  // Window + OpenGL context
  if (!m_window.Init("LasVegasHorror", 1280, 720)) {
    return 1;
  }
  if (!m_renderer.Init()) {
    return 2;
  }
  m_audio.Init(); // best-effort: audio can be disabled if device init fails

  m_mode = Mode::Playing;
  ResetLevel();

  m_window.ShowCursor(false);
  m_window.SetRelativeMouseMode(true);

  const auto start = std::chrono::steady_clock::now();
  auto last = start;

  while (m_window.IsOpen()) {
    Input input;
    if (!m_window.Poll(input)) {
      break;
    }

    const auto now = std::chrono::steady_clock::now();
    const float dt = SecondsSince(last, now);
    last = now;

    const float t = SecondsSince(start, now);
    Update(dt, input);
    Render(t);
  }

  return 0;
}

void Game::Update(float dt, const Input& input) {
  if (input.quitRequested) {
    // Window will close on next Poll; kept here so we can expand logic later.
    return;
  }

  if (input.restartRequested) {
    m_mode = Mode::Playing;
    ResetLevel();
  }

  const bool canControlPlayer = (m_mode == Mode::Playing);

  if (canControlPlayer) {
    // FPS controls:
    // - mouse look updates yaw/pitch
    // - WASD moves along the horizontal plane with AABB collision resolution
    constexpr float sensitivity = 0.0022f;
    constexpr float maxPitch = 1.5f; // ~86 degrees
    m_camera.yawRadians += input.mouseDeltaX * sensitivity;
    m_camera.pitchRadians += input.mouseDeltaY * sensitivity;
    if (m_camera.pitchRadians > maxPitch) m_camera.pitchRadians = maxPitch;
    if (m_camera.pitchRadians < -maxPitch) m_camera.pitchRadians = -maxPitch;

    constexpr float moveSpeed = 3.0f;
    const glm::vec3 forward =
        glm::normalize(glm::vec3(m_camera.Forward().x, 0.0f, m_camera.Forward().z));
    const glm::vec3 right = glm::normalize(glm::cross(forward, glm::vec3(0.0f, 1.0f, 0.0f)));

    glm::vec3 inputDir(0.0f);
    if (input.wDown) inputDir += forward;
    if (input.sDown) inputDir -= forward;
    if (input.dDown) inputDir += right;
    if (input.aDown) inputDir -= right;

    if (glm::length(inputDir) > 0.0001f) {
      inputDir = glm::normalize(inputDir);
      const glm::vec3 desired = inputDir * moveSpeed * dt;

      auto BodyMinMax = [&](const glm::vec3& eyePos, glm::vec3& outMin, glm::vec3& outMax) {
        const float bottomY = eyePos.y - m_player.eyeHeight;
        const float topY = bottomY + 1.7f; // body height (scaffold)
        outMin = glm::vec3(eyePos.x - m_player.radius, bottomY, eyePos.z - m_player.radius);
        outMax = glm::vec3(eyePos.x + m_player.radius, topY, eyePos.z + m_player.radius);
      };

      auto Intersects = [&](const glm::vec3& aMin, const glm::vec3& aMax, const glm::vec3& bMin,
                             const glm::vec3& bMax) -> bool {
        // Strict overlap: touching faces is not considered a collision.
        const bool x = aMin.x < bMax.x && aMax.x > bMin.x;
        const bool y = aMin.y < bMax.y && aMax.y > bMin.y;
        const bool z = aMin.z < bMax.z && aMax.z > bMin.z;
        return x && y && z;
      };

      glm::vec3 pos = m_player.position;

      // X axis resolve.
      if (std::abs(desired.x) > 0.000001f) {
        pos.x += desired.x;
        glm::vec3 pMin, pMax;
        BodyMinMax(pos, pMin, pMax);

        for (const auto& b : m_level.boxes) {
          if (!Intersects(pMin, pMax, b.min, b.max)) continue;
          if (desired.x > 0.0f) {
            pos.x = b.min.x - m_player.radius;
          } else {
            pos.x = b.max.x + m_player.radius;
          }
          BodyMinMax(pos, pMin, pMax);
        }
      }

      // Z axis resolve.
      if (std::abs(desired.z) > 0.000001f) {
        pos.z += desired.z;
        glm::vec3 pMin, pMax;
        BodyMinMax(pos, pMin, pMax);

        for (const auto& b : m_level.boxes) {
          if (!Intersects(pMin, pMax, b.min, b.max)) continue;
          if (desired.z > 0.0f) {
            // In our coordinate system, positive Z is "forward".
            pos.z = b.min.z - m_player.radius;
          } else {
            pos.z = b.max.z + m_player.radius;
          }
          BodyMinMax(pos, pMin, pMax);
        }
      }

      m_player.position = pos;
    }
  }

  m_enemy.UpdateAI(m_player.position, m_level, dt);
  m_camera.position = m_player.position;

  // Objective + win/lose state.
  if (m_mode == Mode::Playing) {
    m_elapsedSeconds += dt;
    if (m_enemy.playerInAttackRange) {
      m_mode = Mode::Dead;
    } else if (m_elapsedSeconds >= m_surviveSeconds) {
      m_mode = Mode::Won;
    }
  }

  // Atmosphere audio intensity ramps up near the enemy (and at full intensity on "attack" range).
  glm::vec3 d = m_enemy.position - m_player.position;
  d.y = 0.0f;
  const float dist = glm::length(d);
  const float prox = 1.0f - (dist / 12.0f);
  float proximity01 = std::clamp(prox, 0.0f, 1.0f);
  if (m_enemy.playerInAttackRange) proximity01 = 1.0f;
  if (m_mode != Mode::Playing) {
    proximity01 *= 0.2f; // calm down audio when you're dead or you've won
  }
  m_audio.SetProximity(proximity01);

  // UI via window title.
  {
    std::ostringstream title;
    title << "LasVegasHorror - ";
    if (m_mode == Mode::Playing) {
      const float remaining = std::max(0.0f, m_surviveSeconds - m_elapsedSeconds);
      title << "Survive: " << remaining << "s";
    } else if (m_mode == Mode::Dead) {
      title << "You were caught. Press R to restart.";
    } else {
      title << "You survived. Press R to restart.";
    }
    m_window.SetTitle(title.str());
  }
}

void Game::Render(float timeSeconds) {
  m_renderer.BeginFrame(m_window.FramebufferSize());
  m_renderer.RenderScene(m_level, m_camera, m_player, m_enemy, timeSeconds);
  m_window.SwapBuffers();
}

} // namespace LasVegas

