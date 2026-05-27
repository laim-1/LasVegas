#pragma once

#include <cstddef>

namespace LasVegas {

class Mesh {
public:
  Mesh() = default;
  ~Mesh();

  Mesh(const Mesh&) = delete;
  Mesh& operator=(const Mesh&) = delete;

  bool InitCube();
  void Draw() const;

private:
  unsigned int m_vao = 0;
  unsigned int m_vbo = 0;
  std::size_t m_vertexCount = 0;
};

} // namespace LasVegas

