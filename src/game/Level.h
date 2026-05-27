#pragma once

#include <glm/glm.hpp>

#include <vector>

namespace LasVegas {

struct AABBBox {
  glm::vec3 min = glm::vec3(0.0f);
  glm::vec3 max = glm::vec3(0.0f);
  glm::vec3 color = glm::vec3(0.8f);
};

struct Level {
  std::vector<AABBBox> boxes;

  // For scaffold: these are already positioned for the camera (eye height included).
  glm::vec3 playerStart = glm::vec3(0.0f, 1.6f, 0.0f);
  glm::vec3 enemySpawn = glm::vec3(0.0f, 1.0f, 0.0f);

  static Level CreatePrototypeRoom();
};

} // namespace LasVegas

