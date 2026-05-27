#include "platform/Audio.h"

#include <cmath>
#include <algorithm>

namespace LasVegas {

static constexpr double PI = 3.14159265358979323846;

AudioSystem::~AudioSystem() { Shutdown(); }

bool AudioSystem::Init() {
  SDL_AudioSpec desired{};
  desired.freq = m_sampleRate;
  desired.format = AUDIO_F32SYS;
  desired.channels = static_cast<Uint8>(m_channels);
  desired.samples = 1024;
  desired.callback = &AudioSystem::SDLAudioCallback;
  desired.userdata = this;

  SDL_AudioSpec obtained{};
  m_device = SDL_OpenAudioDevice(nullptr, 0, &desired, &obtained, SDL_AUDIO_ALLOW_FORMAT_CHANGE);
  if (m_device == 0) {
    return false;
  }

  m_sampleRate = obtained.freq;
  m_channels = obtained.channels;

  SDL_PauseAudioDevice(m_device, 0);
  return true;
}

void AudioSystem::Shutdown() {
  if (m_device != 0) {
    SDL_PauseAudioDevice(m_device, 1);
    SDL_CloseAudioDevice(m_device);
    m_device = 0;
  }
}

void AudioSystem::SetProximity(float proximity01) {
  m_proximity01.store(std::clamp(proximity01, 0.0f, 1.0f), std::memory_order_relaxed);
}

void AudioSystem::SDLAudioCallback(void* userdata, Uint8* stream, int lenBytes) {
  auto* self = static_cast<AudioSystem*>(userdata);
  if (!self) return;

  const int floatsTotal = lenBytes / static_cast<int>(sizeof(float));
  if (floatsTotal <= 0) return;

  auto* out = reinterpret_cast<float*>(stream);
  const int frames = floatsTotal / std::max(1, self->m_channels);
  if (frames <= 0) return;

  const float proximity = self->m_proximity01.load(std::memory_order_relaxed);

  for (int i = 0; i < frames; ++i) {
    const double t = self->m_timeSec;

    // Ambient: low-volume noise with a cheap low-pass.
    self->m_rngState = self->m_rngState * 1664525u + 1013904223u;
    const float rnd = ((self->m_rngState >> 9) & 0x7FFFFFu) / 4194304.0f; // [0,1)
    const float noise = (rnd * 2.0f - 1.0f);
    const float ambTarget = 0.015f * (0.3f + proximity) * noise;
    self->m_ambientLP = self->m_ambientLP * 0.98f + ambTarget * 0.02f;

    // Heartbeat: faster when proximity increases.
    const double minInterval = 0.35; // seconds
    const double maxInterval = 1.2;  // seconds
    const double interval = maxInterval + (minInterval - maxInterval) * proximity;
    const double phase = std::fmod(t, interval);
    const double beatLen = interval * 0.18;
    const double env = (phase < beatLen) ? std::exp(-(phase / beatLen) * 10.0) : 0.0;

    const double bpmTone = 45.0 + 30.0 * proximity; // harmonic-ish frequency
    const float thump = static_cast<float>(std::sin(2.0 * PI * bpmTone * t) * env);
    const float heartbeat = thump * (0.25f + 0.85f * proximity);

    // Mix.
    float sampleL = self->m_ambientLP * 0.35f + heartbeat;
    float sampleR = self->m_ambientLP * 0.35f + heartbeat * 0.95f;

    // Clamp to avoid extreme distortion.
    sampleL = std::clamp(sampleL, -1.0f, 1.0f);
    sampleR = std::clamp(sampleR, -1.0f, 1.0f);

    // Write stereo (or duplicate if channels != 2).
    if (self->m_channels >= 2) {
      out[i * self->m_channels + 0] = sampleL;
      out[i * self->m_channels + 1] = sampleR;
    } else {
      out[i * self->m_channels + 0] = 0.5f * (sampleL + sampleR);
    }

    // Advance time.
    self->m_timeSec += 1.0 / static_cast<double>(self->m_sampleRate);
  }
}

} // namespace LasVegas

