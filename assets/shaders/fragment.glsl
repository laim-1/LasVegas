#version 330 core

in vec3 vNormal;
in vec3 vWorldPos;

out vec4 FragColor;

uniform vec3 uColor;
uniform vec3 uLightDir;
uniform vec3 uCameraPos;
uniform vec3 uCameraForward;
uniform float uFlashlightRange;
uniform float uFlashlightCutoffCos;
uniform float uFlashlightIntensity;
uniform float uFogDensity;
uniform float uTime;

void main() {
  vec3 N = normalize(vNormal);
  // Directional "ambient" light (tiny amount).
  vec3 Ld = normalize(-uLightDir);
  float diffDir = max(dot(N, Ld), 0.0);

  // Flashlight spotlight centered on the camera forward direction.
  vec3 toFrag = vWorldPos - uCameraPos; // camera -> fragment
  float dist = length(toFrag);
  vec3 dir = (dist > 0.0001) ? (toFrag / dist) : vec3(0.0);

  // Spot mask based on angle between camera forward and fragment direction.
  float spot = max(dot(normalize(uCameraForward), dir), 0.0);
  float spotMask = smoothstep(uFlashlightCutoffCos, uFlashlightCutoffCos + 0.08, spot);

  // Diffuse from flashlight light position (camera as a point light).
  vec3 Lf = normalize(uCameraPos - vWorldPos); // fragment -> camera
  float diffFlash = max(dot(N, Lf), 0.0);

  // Range attenuation: smooth falloff to zero at uFlashlightRange.
  float rangeAtten = clamp(1.0 - (dist / uFlashlightRange), 0.0, 1.0);

  // Combine spotlight and falloff.
  float flashlight = diffFlash * uFlashlightIntensity * spotMask * rangeAtten / max(dist * dist, 0.25);

  // Simple ambient + directional + flashlight.
  vec3 base = uColor * (0.05 + 0.25 * diffDir) + uColor * flashlight;

  // Depth-based fog (reuse the camera<->fragment distance).
  float fogFactor = exp(-uFogDensity * dist);
  vec3 fogColor = vec3(0.02, 0.02, 0.03);

  vec3 col = mix(fogColor, base, fogFactor);
  FragColor = vec4(col, 1.0);
}

