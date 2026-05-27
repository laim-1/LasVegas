#include "game/Enemy.h"

#include <algorithm>
#include <cmath>

namespace LasVegas {

static bool AABBIntersectsStrict(const glm::vec3& aMin, const glm::vec3& aMax,
                                  const glm::vec3& bMin, const glm::vec3& bMax) {
  const bool x = aMin.x < bMax.x && aMax.x > bMin.x;
  const bool y = aMin.y < bMax.y && aMax.y > bMin.y;
  const bool z = aMin.z < bMax.z && aMax.z > bMin.z;
  return x && y && z;
}

static bool SegmentIntersectsAABB(const glm::vec3& segA, const glm::vec3& segB,
                                   const glm::vec3& bMin, const glm::vec3& bMax) {
  // Slab method for segment vs AABB.
  const glm::vec3 d = segB - segA;
  const float len = glm::length(d);
  if (len < 1e-6f) return false;

  const glm::vec3 dir = d / len;
  float t0 = 0.0f;
  float t1 = len;

  for (int axis = 0; axis < 3; ++axis) {
    const float origin = segA[axis];
    const float direction = dir[axis];
    const float minVal = bMin[axis];
    const float maxVal = bMax[axis];

    if (std::abs(direction) < 1e-7f) {
      // Parallel to slabs: if outside, no intersection.
      if (origin < minVal || origin > maxVal) return false;
    } else {
      const float inv = 1.0f / direction;
      float tmin = (minVal - origin) * inv;
      float tmax = (maxVal - origin) * inv;
      if (tmin > tmax) std::swap(tmin, tmax);
      t0 = std::max(t0, tmin);
      t1 = std::min(t1, tmax);
      if (t0 > t1) return false;
    }
  }

  // Intersection exists on the segment.
  return t1 >= 0.0f && t0 <= len;
}

static bool HasLineOfSight(const glm::vec3& from, const glm::vec3& to, const Level& level) {
  // Skip extremely thin boxes (like the floor), so the ray doesn't get blocked by ground planes.
  for (const auto& b : level.boxes) {
    if ((b.max.y - b.min.y) < 0.15f) continue;
    if (SegmentIntersectsAABB(from, to, b.min, b.max)) {
      return false;
    }
  }
  return true;
}

static void MoveWithAABBCollision(glm::vec3& pos, const glm::vec3& desiredDelta, const Level& level,
                                   float radius, float eyeHeight, float bodyHeight) {
  auto BodyMinMax = [&](const glm::vec3& eyePos, glm::vec3& outMin, glm::vec3& outMax) {
    const float bottomY = eyePos.y - eyeHeight;
    const float topY = bottomY + bodyHeight;
    outMin = glm::vec3(eyePos.x - radius, bottomY, eyePos.z - radius);
    outMax = glm::vec3(eyePos.x + radius, topY, eyePos.z + radius);
  };

  auto intersects = [&](const glm::vec3& aMin, const glm::vec3& aMax, const glm::vec3& bMin,
                        const glm::vec3& bMax) {
    return AABBIntersectsStrict(aMin, aMax, bMin, bMax);
  };

  glm::vec3 p = pos;

  // Resolve X.
  if (std::abs(desiredDelta.x) > 1e-7f) {
    p.x += desiredDelta.x;

    glm::vec3 pMin, pMax;
    BodyMinMax(p, pMin, pMax);

    for (const auto& b : level.boxes) {
      if (!intersects(pMin, pMax, b.min, b.max)) continue;
      p.x = (desiredDelta.x > 0.0f) ? (b.min.x - radius) : (b.max.x + radius);
      BodyMinMax(p, pMin, pMax);
    }
  }

  // Resolve Z.
  if (std::abs(desiredDelta.z) > 1e-7f) {
    p.z += desiredDelta.z;

    glm::vec3 pMin, pMax;
    BodyMinMax(p, pMin, pMax);

    for (const auto& b : level.boxes) {
      if (!intersects(pMin, pMax, b.min, b.max)) continue;
      p.z = (desiredDelta.z > 0.0f) ? (b.min.z - radius) : (b.max.z + radius);
      BodyMinMax(p, pMin, pMax);
    }
  }

  pos = p;
}

void Enemy::UpdateAI(const glm::vec3& playerPos, const Level& level, float dt) {
  playerInAttackRange = false;

  const glm::vec3 toPlayer = playerPos - position;
  const float dist = glm::length(toPlayer);

  const glm::vec3 enemyEye = position;
  const glm::vec3 playerEye = glm::vec3(playerPos.x, playerPos.y, playerPos.z);

  bool inRange = dist <= detectRange;
  bool los = false;
  if (inRange) {
    los = HasLineOfSight(enemyEye, playerEye, level);
  }

  if (los && dist <= attackRange) {
    state = State::Attack;
    playerInAttackRange = true;
    return; // stop moving while attacking
  }

  if (los) {
    state = State::Chase;
  } else {
    state = State::Patrol;
  }

  // Target selection.
  glm::vec3 target = position;
  switch (state) {
    case State::Patrol: {
      patrolPhase += dt;
      // Simple deterministic patrol around spawn.
      const float r = 1.7f;
      target = spawnPosition + glm::vec3(std::sinf(patrolPhase) * r, 0.0f,
                                          std::cosf(patrolPhase) * r);
      break;
    }
    case State::Chase:
      target = glm::vec3(playerPos.x, position.y, playerPos.z);
      break;
    case State::Attack:
      return;
  }

  // Horizontal move toward target.
  const glm::vec3 toTarget = target - position;
  const glm::vec3 toTargetXZ(toTarget.x, 0.0f, toTarget.z);
  const float len = glm::length(toTargetXZ);
  if (len > 0.001f) {
    const glm::vec3 dir = toTargetXZ / len;
    const glm::vec3 desiredDelta = dir * (moveSpeed * dt);
    MoveWithAABBCollision(position, desiredDelta, level, radius, eyeHeight, bodyHeight);
  }
}

} // namespace LasVegas

