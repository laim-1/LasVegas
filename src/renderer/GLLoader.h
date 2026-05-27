#pragma once

#include <SDL.h>
#include <SDL_opengl.h>
#include <SDL_opengl_glext.h>

namespace gl {

// Loads the subset of OpenGL entry points we use, via SDL's GetProcAddress.
bool Load();

// Shader API
GLuint CreateShader(GLenum type);
void ShaderSource(GLuint shader, GLsizei count, const GLchar* const* string,
                  const GLint* length);
void CompileShader(GLuint shader);
void GetShaderiv(GLuint shader, GLenum pname, GLint* params);
void GetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei* length, GLchar* infoLog);
void DeleteShader(GLuint shader);

// Program API
GLuint CreateProgram();
void AttachShader(GLuint program, GLuint shader);
void LinkProgram(GLuint program);
void GetProgramiv(GLuint program, GLenum pname, GLint* params);
void GetProgramInfoLog(GLuint program, GLsizei maxLength, GLsizei* length, GLchar* infoLog);
void DeleteProgram(GLuint program);
void UseProgram(GLuint program);

// Uniforms
GLint GetUniformLocation(GLuint program, const GLchar* name);
void UniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value);
void Uniform3fv(GLint location, GLsizei count, const GLfloat* value);
void Uniform1f(GLint location, GLfloat v0);
void Uniform1i(GLint location, GLint v0);

// Vertex buffers / drawing
void GenVertexArrays(GLsizei n, GLuint* arrays);
void BindVertexArray(GLuint array);
void GenBuffers(GLsizei n, GLuint* buffers);
void BindBuffer(GLenum target, GLuint buffer);
void BufferData(GLenum target, GLsizeiptr size, const void* data, GLenum usage);
void EnableVertexAttribArray(GLuint index);
void VertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized,
                          GLsizei stride, const void* pointer);
void DrawArrays(GLenum mode, GLint first, GLsizei count);

// Frame control
void Viewport(GLint x, GLint y, GLsizei width, GLsizei height);
void ClearColor(GLfloat r, GLfloat g, GLfloat b, GLfloat a);
void Clear(GLbitfield mask);
void Enable(GLenum cap);
void DepthFunc(GLenum func);

} // namespace gl

