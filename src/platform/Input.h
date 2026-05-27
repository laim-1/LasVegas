#pragma once

#include <cstdint>

namespace LasVegas {

struct Input {
  bool quitRequested = false;
  bool restartRequested = false;

  bool wDown = false;
  bool aDown = false;
  bool sDown = false;
  bool dDown = false;

  // Relative mouse deltas for this frame.
  float mouseDeltaX = 0.0f;
  float mouseDeltaY = 0.0f;
};

} // namespace LasVegas

