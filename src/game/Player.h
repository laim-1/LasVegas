#pragma once

#include <glm/glm.hpp>

namespace LasVegas {

struct Player {
  glm::vec3 position = glm::vec3(0.0f);
  glm::vec3 velocity = glm::vec3(0.0f);

  // Simple collision proxy.
  float radius = 0.3f;
  float eyeHeight = 1.6f;

  void Update(float /*dt*/, const void* /*input*/, const void* /*level*/) {
    // Placeholder: FPS controls + collision are implemented in later milestones.
  }
};

} // namespace LasVegas

