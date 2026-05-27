#pragma once

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

namespace LasVegas {

struct Camera {
  glm::vec3 position = glm::vec3(0.0f, 1.6f, 0.0f);

  // Rotation (radians).
  float yawRadians = 0.0f;
  float pitchRadians = 0.0f;

  glm::vec3 Forward() const {
    const float cp = cosf(pitchRadians);
    const float sp = sinf(pitchRadians);
    const float sy = sinf(yawRadians);
    const float cy = cosf(yawRadians);
    // yaw=0 => looking down -Z.
    return glm::normalize(glm::vec3(cp * sy, sp, -cp * cy));
  }

  glm::mat4 ViewMatrix() const {
    return glm::lookAt(position, position + Forward(), glm::vec3(0.0f, 1.0f, 0.0f));
  }
};

} // namespace LasVegas

