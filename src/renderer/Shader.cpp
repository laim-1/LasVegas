#include "renderer/Shader.h"

#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>

namespace LasVegas {

static std::string ReadTextFromDisk(const std::string& path) {
  std::ifstream f(path, std::ios::in | std::ios::binary);
  if (!f) return {};
  std::ostringstream ss;
  ss << f.rdbuf();
  return ss.str();
}

std::string Shader::ReadTextFile(const std::string& path) { return ReadTextFromDisk(path); }

bool Shader::LoadFromFiles(const std::string& vertexPath, const std::string& fragmentPath) {
  if (m_program != 0) {
    gl::DeleteProgram(m_program);
    m_program = 0;
  }

  // Try "as-is" first, then fall back to CWD/exec-dir-relative.
  const std::string vertexSrc = ReadTextFromDisk(vertexPath);
  const std::string fragmentSrc = ReadTextFromDisk(fragmentPath);
  if (vertexSrc.empty() || fragmentSrc.empty()) {
    // Best-effort fallback relative to current working directory.
    const auto cwd = std::filesystem::current_path();
    const std::string vertex2 = ReadTextFromDisk((cwd / vertexPath).string());
    const std::string fragment2 = ReadTextFromDisk((cwd / fragmentPath).string());
    if (vertex2.empty() || fragment2.empty()) {
      std::cerr << "Shader load failed. Missing: " << vertexPath << " or " << fragmentPath << "\n";
      return false;
    }
  }

  const std::string vSrc = vertexSrc.empty() ? ReadTextFromDisk((std::filesystem::current_path() / vertexPath).string()) : vertexSrc;
  const std::string fSrc = fragmentSrc.empty() ? ReadTextFromDisk((std::filesystem::current_path() / fragmentPath).string()) : fragmentSrc;

  // Compile vertex shader.
  GLuint vs = gl::CreateShader(GL_VERTEX_SHADER);
  const char* vPtr = vSrc.c_str();
  gl::ShaderSource(vs, 1, &vPtr, nullptr);
  gl::CompileShader(vs);

  GLint ok = 0;
  gl::GetShaderiv(vs, GL_COMPILE_STATUS, &ok);
  if (!ok) {
    std::string log(1024, '\0');
    gl::GetShaderInfoLog(vs, static_cast<GLsizei>(log.size()), nullptr, log.data());
    std::cerr << "Vertex shader compile error:\n" << log << "\n";
    gl::DeleteShader(vs);
    return false;
  }

  // Compile fragment shader.
  GLuint fs = gl::CreateShader(GL_FRAGMENT_SHADER);
  const char* fPtr = fSrc.c_str();
  gl::ShaderSource(fs, 1, &fPtr, nullptr);
  gl::CompileShader(fs);
  gl::GetShaderiv(fs, GL_COMPILE_STATUS, &ok);
  if (!ok) {
    std::string log(1024, '\0');
    gl::GetShaderInfoLog(fs, static_cast<GLsizei>(log.size()), nullptr, log.data());
    std::cerr << "Fragment shader compile error:\n" << log << "\n";
    gl::DeleteShader(vs);
    gl::DeleteShader(fs);
    return false;
  }

  // Link program.
  GLuint prog = gl::CreateProgram();
  gl::AttachShader(prog, vs);
  gl::AttachShader(prog, fs);
  gl::LinkProgram(prog);

  gl::GetProgramiv(prog, GL_LINK_STATUS, &ok);
  if (!ok) {
    std::string log(2048, '\0');
    gl::GetProgramInfoLog(prog, static_cast<GLsizei>(log.size()), nullptr, log.data());
    std::cerr << "Shader program link error:\n" << log << "\n";
    gl::DeleteProgram(prog);
    gl::DeleteShader(vs);
    gl::DeleteShader(fs);
    return false;
  }

  gl::DeleteShader(vs);
  gl::DeleteShader(fs);
  m_program = prog;
  return true;
}

void Shader::Use() const { gl::UseProgram(m_program); }

void Shader::SetMat4(const char* name, const glm::mat4& m) const {
  const GLint loc = gl::GetUniformLocation(m_program, name);
  if (loc < 0) return;
  gl::UniformMatrix4fv(loc, 1, GL_FALSE, &m[0][0]);
}

void Shader::SetVec3(const char* name, const glm::vec3& v) const {
  const GLint loc = gl::GetUniformLocation(m_program, name);
  if (loc < 0) return;
  gl::Uniform3fv(loc, 1, &v[0]);
}

void Shader::SetFloat(const char* name, float v) const {
  const GLint loc = gl::GetUniformLocation(m_program, name);
  if (loc < 0) return;
  gl::Uniform1f(loc, v);
}

void Shader::SetInt(const char* name, int v) const {
  const GLint loc = gl::GetUniformLocation(m_program, name);
  if (loc < 0) return;
  gl::Uniform1i(loc, v);
}

} // namespace LasVegas

