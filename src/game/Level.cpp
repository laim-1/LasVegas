#include "game/Level.h"

namespace LasVegas {

static AABBBox MakeBox(const glm::vec3& mn, const glm::vec3& mx, const glm::vec3& color) {
  AABBBox b;
  b.min = mn;
  b.max = mx;
  b.color = color;
  return b;
}

Level Level::CreatePrototypeRoom() {
  Level level;

  // Room bounds: roughly x,z in [-5,5], height 3.
  const float minX = -5.0f;
  const float maxX = 5.0f;
  const float minZ = -5.0f;
  const float maxZ = 5.0f;
  const float floorY0 = -0.1f;
  const float floorY1 = 0.0f;
  const float wallY0 = 0.0f;
  const float wallY1 = 3.0f;
  const float t = 0.2f; // wall thickness

  // Floor
  level.boxes.push_back(MakeBox(glm::vec3(minX, floorY0, minZ), glm::vec3(maxX, floorY1, maxZ),
                                 glm::vec3(0.5f, 0.5f, 0.55f)));

  // Outer walls
  level.boxes.push_back(MakeBox(glm::vec3(minX, wallY0, minZ - t), glm::vec3(maxX, wallY1, minZ),
                                 glm::vec3(0.2f, 0.2f, 0.25f))); // north (back)
  level.boxes.push_back(MakeBox(glm::vec3(minX, wallY0, maxZ), glm::vec3(maxX, wallY1, maxZ + t),
                                 glm::vec3(0.2f, 0.2f, 0.25f))); // south (front)
  level.boxes.push_back(MakeBox(glm::vec3(minX - t, wallY0, minZ), glm::vec3(minX, wallY1, maxZ),
                                 glm::vec3(0.2f, 0.2f, 0.25f))); // west
  level.boxes.push_back(MakeBox(glm::vec3(maxX, wallY0, minZ), glm::vec3(maxX + t, wallY1, maxZ),
                                 glm::vec3(0.2f, 0.2f, 0.25f))); // east

  // A couple interior blocks to make navigation non-trivial.
  level.boxes.push_back(MakeBox(glm::vec3(-1.6f, wallY0, -2.0f), glm::vec3(1.6f, wallY1, -1.4f),
                                 glm::vec3(0.18f, 0.18f, 0.22f)));
  level.boxes.push_back(MakeBox(glm::vec3(-3.5f, wallY0, 1.4f), glm::vec3(-2.9f, wallY1, 3.5f),
                                 glm::vec3(0.18f, 0.18f, 0.22f)));

  level.playerStart = glm::vec3(0.0f, 1.6f, 0.0f);
  level.enemySpawn = glm::vec3(0.0f, 1.0f, -3.2f);
  return level;
}

} // namespace LasVegas

