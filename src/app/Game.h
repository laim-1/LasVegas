#pragma once

#include <cstdint>

#include "game/Enemy.h"
#include "game/Level.h"
#include "game/Player.h"
#include "platform/Input.h"
#include "platform/Window.h"
#include "platform/Audio.h"
#include "renderer/Camera.h"
#include "renderer/Renderer.h"

namespace LasVegas {

class Game {
public:
  Game();
  int Run();

private:
  void Update(float dt, const Input& input);
  void Render(float timeSeconds);
  void ResetLevel();

private:
  Window m_window;
  Renderer m_renderer;
  AudioSystem m_audio;

  Level m_level;
  Player m_player;
  Enemy m_enemy;

  Camera m_camera;

  enum class Mode { Playing, Dead, Won };
  Mode m_mode = Mode::Playing;

  float m_surviveSeconds = 30.0f;
  float m_elapsedSeconds = 0.0f;
};

} // namespace LasVegas

