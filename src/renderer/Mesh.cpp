#include "renderer/Mesh.h"

#include <SDL_opengl.h>

#include <glm/glm.hpp>
#include <vector>

#include "renderer/GLLoader.h"

namespace LasVegas {

Mesh::~Mesh() {
  // For this scaffold, we skip glDelete* calls. (Would require extra loader functions.)
}

bool Mesh::InitCube() {
  // 36 vertices for a cube (positions + normals per face).
  // Attribute layout:
  //  - location 0: vec3 aPos
  //  - location 1: vec3 aNormal
  const float vertices[] = {
      // +X face
      1, -1, -1, 1, 0, 0, 1, 1, -1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, -1, -1, 1, 0, 0,
      1, 1, 1, 1, 0, 0, 1, -1, 1, 1, 0, 0,

      // -X face
      -1, -1, 1, -1, 0, 0, -1, 1, 1, -1, 0, 0, -1, 1, -1, -1, 0, 0, -1, -1, 1, -1,
      0, 0, -1, 1, -1, -1, 0, 0, -1, -1, -1, -1, 0, 0,

      // +Y face
      -1, 1, -1, 0, 1, 0, -1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, -1, 1, -1, 0,
      1, 0, 1, 1, 1, 0, 1, 0, 1, 1, -1, 0, 1, 0,

      // -Y face
      -1, -1, 1, 0, -1, 0, -1, -1, -1, 0, -1, 0, 1, -1, -1, 0, -1, 0, -1, -1, 1,
      0, -1, 0, 1, -1, -1, 0, -1, 0, 1, -1, 1, 0, -1, 0,

      // +Z face
      1, -1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, -1, 1, 1, 0, 0, 1, 1, -1, 1, 0, 0,
      1, -1, 1, 1, 0, 0, 1, -1, -1, 1, 0, 0, 1,

      // -Z face
      -1, -1, -1, 0, 0, -1, -1, 1, -1, 0, 0, -1, 1, 1, -1, 0, 0, -1, -1, -1, -1,
      0, 0, -1, 1, 1, -1, 0, 0, -1, 1, -1, -1, 0, 0, -1,
  };

  m_vertexCount = 36;

  gl::GenVertexArrays(1, reinterpret_cast<GLuint*>(&m_vao));
  gl::BindVertexArray(m_vao);

  gl::GenBuffers(1, reinterpret_cast<GLuint*>(&m_vbo));
  gl::BindBuffer(GL_ARRAY_BUFFER, m_vbo);
  gl::BufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

  const GLsizei stride = 6 * sizeof(float);

  gl::EnableVertexAttribArray(0);
  gl::VertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, reinterpret_cast<void*>(0));

  gl::EnableVertexAttribArray(1);
  gl::VertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, stride,
                           reinterpret_cast<void*>(3 * sizeof(float)));

  gl::BindVertexArray(0);
  return true;
}

void Mesh::Draw() const {
  gl::BindVertexArray(m_vao);
  gl::DrawArrays(GL_TRIANGLES, 0, static_cast<GLsizei>(m_vertexCount));
  gl::BindVertexArray(0);
}

} // namespace LasVegas

