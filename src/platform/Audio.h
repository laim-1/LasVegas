#pragma once

#include <atomic>
#include <cstdint>

#include <SDL.h>

namespace LasVegas {

class AudioSystem {
public:
  AudioSystem() = default;
  ~AudioSystem();

  bool Init();
  void SetProximity(float proximity01);
  void Shutdown();

private:
  static void SDLAudioCallback(void* userdata, Uint8* stream, int lenBytes);

private:
  std::atomic<float> m_proximity01{0.0f};
  SDL_AudioDeviceID m_device = 0;

  // Callback-thread state.
  int m_sampleRate = 44100;
  int m_channels = 2;
  double m_timeSec = 0.0;
  uint32_t m_rngState = 0x12345678u;
  float m_ambientLP = 0.0f;
};

} // namespace LasVegas

