#pragma once

#include <string>

#include <glm/glm.hpp>

#include "renderer/GLLoader.h"

namespace LasVegas {

class Shader {
public:
  Shader() = default;

  bool LoadFromFiles(const std::string& vertexPath, const std::string& fragmentPath);
  void Use() const;

  void SetMat4(const char* name, const glm::mat4& m) const;
  void SetVec3(const char* name, const glm::vec3& v) const;
  void SetFloat(const char* name, float v) const;
  void SetInt(const char* name, int v) const;

  GLuint Program() const { return m_program; }

private:
  static std::string ReadTextFile(const std::string& path);

private:
  GLuint m_program = 0;
};

} // namespace LasVegas

