#pragma once

#include <glm/glm.hpp>

#include "game/Level.h"

namespace LasVegas {

struct Enemy {
  glm::vec3 position = glm::vec3(0.0f, 1.0f, 0.0f);
  glm::vec3 velocity = glm::vec3(0.0f);

  // Prototype tuning (used later by AI milestone).
  float moveSpeed = 1.6f;
  float attackRange = 1.0f;
  float detectRange = 8.0f;

  // Simple AABB proxy.
  float radius = 0.35f;
  float eyeHeight = 1.0f;
  float bodyHeight = 1.6f;

  enum class State { Patrol, Chase, Attack };
  State state = State::Patrol;

  bool playerInAttackRange = false;

  // Must be set by the game when the enemy is spawned.
  glm::vec3 spawnPosition = glm::vec3(0.0f);
  float patrolPhase = 0.0f;

  void UpdateAI(const glm::vec3& playerPos, const Level& level, float dt);
};

} // namespace LasVegas

