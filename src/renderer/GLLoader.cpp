#include "renderer/GLLoader.h"

#include <cassert>

namespace gl {

// Helper for loading OpenGL entry points.
template <typename T>
static T LoadFunc(const char* name) {
  // SDL_GL_GetProcAddress returns void*; casting to function pointer is standard for this pattern.
  void* p = reinterpret_cast<void*>(SDL_GL_GetProcAddress(name));
  return reinterpret_cast<T>(p);
}

// Function pointer slots.
static PFNGLCREATESHADERPROC pCreateShader = nullptr;
static PFNGLSHADERSOURCEPROC pShaderSource = nullptr;
static PFNGLCOMPILESHADERPROC pCompileShader = nullptr;
static PFNGLGETSHADERIVPROC pGetShaderiv = nullptr;
static PFNGLGETSHADERINFOLOGPROC pGetShaderInfoLog = nullptr;
static PFNGLDELETESHADERPROC pDeleteShader = nullptr;

static PFNGLCREATEPROGRAMPROC pCreateProgram = nullptr;
static PFNGLATTACHSHADERPROC pAttachShader = nullptr;
static PFNGLLINKPROGRAMPROC pLinkProgram = nullptr;
static PFNGLGETPROGRAMIVPROC pGetProgramiv = nullptr;
static PFNGLGETPROGRAMINFOLOGPROC pGetProgramInfoLog = nullptr;
static PFNGLDELETEPROGRAMPROC pDeleteProgram = nullptr;
static PFNGLUSEPROGRAMPROC pUseProgram = nullptr;

static PFNGLGETUNIFORMLOCATIONPROC pGetUniformLocation = nullptr;
static PFNGLUNIFORMMATRIX4FVPROC pUniformMatrix4fv = nullptr;
static PFNGLUNIFORM3FVPROC pUniform3fv = nullptr;
static PFNGLUNIFORM1FPROC pUniform1f = nullptr;
static PFNGLUNIFORM1IPROC pUniform1i = nullptr;

static PFNGLGENVERTEXARRAYSPROC pGenVertexArrays = nullptr;
static PFNGLBINDVERTEXARRAYPROC pBindVertexArray = nullptr;
static PFNGLGENBUFFERSPROC pGenBuffers = nullptr;
static PFNGLBINDBUFFERPROC pBindBuffer = nullptr;
static PFNGLBUFFERDATAPROC pBufferData = nullptr;
static PFNGLENABLEVERTEXATTRIBARRAYPROC pEnableVertexAttribArray = nullptr;
static PFNGLVERTEXATTRIBPOINTERPROC pVertexAttribPointer = nullptr;
static PFNGLDRAWARRAYSPROC pDrawArrays = nullptr;

static PFNGLVIEWPORTPROC pViewport = nullptr;
static PFNGLCLEARCOLORPROC pClearColor = nullptr;
static PFNGLCLEARPROC pClear = nullptr;
static PFNGLENABLEPROC pEnable = nullptr;
static PFNGLDEPTHFUNCPROC pDepthFunc = nullptr;

bool Load() {
  pCreateShader = LoadFunc<PFNGLCREATESHADERPROC>("glCreateShader");
  pShaderSource = LoadFunc<PFNGLSHADERSOURCEPROC>("glShaderSource");
  pCompileShader = LoadFunc<PFNGLCOMPILESHADERPROC>("glCompileShader");
  pGetShaderiv = LoadFunc<PFNGLGETSHADERIVPROC>("glGetShaderiv");
  pGetShaderInfoLog = LoadFunc<PFNGLGETSHADERINFOLOGPROC>("glGetShaderInfoLog");
  pDeleteShader = LoadFunc<PFNGLDELETESHADERPROC>("glDeleteShader");

  pCreateProgram = LoadFunc<PFNGLCREATEPROGRAMPROC>("glCreateProgram");
  pAttachShader = LoadFunc<PFNGLATTACHSHADERPROC>("glAttachShader");
  pLinkProgram = LoadFunc<PFNGLLINKPROGRAMPROC>("glLinkProgram");
  pGetProgramiv = LoadFunc<PFNGLGETPROGRAMIVPROC>("glGetProgramiv");
  pGetProgramInfoLog = LoadFunc<PFNGLGETPROGRAMINFOLOGPROC>("glGetProgramInfoLog");
  pDeleteProgram = LoadFunc<PFNGLDELETEPROGRAMPROC>("glDeleteProgram");
  pUseProgram = LoadFunc<PFNGLUSEPROGRAMPROC>("glUseProgram");

  pGetUniformLocation = LoadFunc<PFNGLGETUNIFORMLOCATIONPROC>("glGetUniformLocation");
  pUniformMatrix4fv = LoadFunc<PFNGLUNIFORMMATRIX4FVPROC>("glUniformMatrix4fv");
  pUniform3fv = LoadFunc<PFNGLUNIFORM3FVPROC>("glUniform3fv");
  pUniform1f = LoadFunc<PFNGLUNIFORM1FPROC>("glUniform1f");
  pUniform1i = LoadFunc<PFNGLUNIFORM1IPROC>("glUniform1i");

  pGenVertexArrays = LoadFunc<PFNGLGENVERTEXARRAYSPROC>("glGenVertexArrays");
  pBindVertexArray = LoadFunc<PFNGLBINDVERTEXARRAYPROC>("glBindVertexArray");
  pGenBuffers = LoadFunc<PFNGLGENBUFFERSPROC>("glGenBuffers");
  pBindBuffer = LoadFunc<PFNGLBINDBUFFERPROC>("glBindBuffer");
  pBufferData = LoadFunc<PFNGLBUFFERDATAPROC>("glBufferData");
  pEnableVertexAttribArray = LoadFunc<PFNGLENABLEVERTEXATTRIBARRAYPROC>("glEnableVertexAttribArray");
  pVertexAttribPointer = LoadFunc<PFNGLVERTEXATTRIBPOINTERPROC>("glVertexAttribPointer");
  pDrawArrays = LoadFunc<PFNGLDRAWARRAYSPROC>("glDrawArrays");

  pViewport = LoadFunc<PFNGLVIEWPORTPROC>("glViewport");
  pClearColor = LoadFunc<PFNGLCLEARCOLORPROC>("glClearColor");
  pClear = LoadFunc<PFNGLCLEARPROC>("glClear");
  pEnable = LoadFunc<PFNGLENABLEPROC>("glEnable");
  pDepthFunc = LoadFunc<PFNGLDEPTHFUNCPROC>("glDepthFunc");

  // Minimal sanity: shader + buffer API.
  return pCreateShader && pCreateProgram && pGenVertexArrays && pBindVertexArray && pDrawArrays &&
         pUniformMatrix4fv && pViewport && pClear && pEnable && pDepthFunc;
}

// Wrapper functions.
GLuint CreateShader(GLenum type) { assert(pCreateShader); return pCreateShader(type); }
void ShaderSource(GLuint shader, GLsizei count, const GLchar* const* string,
                   const GLint* length) {
  assert(pShaderSource);
  pShaderSource(shader, count, string, length);
}
void CompileShader(GLuint shader) {
  assert(pCompileShader);
  pCompileShader(shader);
}
void GetShaderiv(GLuint shader, GLenum pname, GLint* params) {
  assert(pGetShaderiv);
  pGetShaderiv(shader, pname, params);
}
void GetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei* length, GLchar* infoLog) {
  assert(pGetShaderInfoLog);
  pGetShaderInfoLog(shader, maxLength, length, infoLog);
}
void DeleteShader(GLuint shader) {
  assert(pDeleteShader);
  pDeleteShader(shader);
}

GLuint CreateProgram() {
  assert(pCreateProgram);
  return pCreateProgram();
}
void AttachShader(GLuint program, GLuint shader) {
  assert(pAttachShader);
  pAttachShader(program, shader);
}
void LinkProgram(GLuint program) {
  assert(pLinkProgram);
  pLinkProgram(program);
}
void GetProgramiv(GLuint program, GLenum pname, GLint* params) {
  assert(pGetProgramiv);
  pGetProgramiv(program, pname, params);
}
void GetProgramInfoLog(GLuint program, GLsizei maxLength, GLsizei* length, GLchar* infoLog) {
  assert(pGetProgramInfoLog);
  pGetProgramInfoLog(program, maxLength, length, infoLog);
}
void DeleteProgram(GLuint program) {
  assert(pDeleteProgram);
  pDeleteProgram(program);
}
void UseProgram(GLuint program) {
  assert(pUseProgram);
  pUseProgram(program);
}

GLint GetUniformLocation(GLuint program, const GLchar* name) {
  assert(pGetUniformLocation);
  return pGetUniformLocation(program, name);
}
void UniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value) {
  assert(pUniformMatrix4fv);
  pUniformMatrix4fv(location, count, transpose, value);
}
void Uniform3fv(GLint location, GLsizei count, const GLfloat* value) {
  assert(pUniform3fv);
  pUniform3fv(location, count, value);
}
void Uniform1f(GLint location, GLfloat v0) {
  assert(pUniform1f);
  pUniform1f(location, v0);
}
void Uniform1i(GLint location, GLint v0) {
  assert(pUniform1i);
  pUniform1i(location, v0);
}

void GenVertexArrays(GLsizei n, GLuint* arrays) {
  assert(pGenVertexArrays);
  pGenVertexArrays(n, arrays);
}
void BindVertexArray(GLuint array) {
  assert(pBindVertexArray);
  pBindVertexArray(array);
}
void GenBuffers(GLsizei n, GLuint* buffers) {
  assert(pGenBuffers);
  pGenBuffers(n, buffers);
}
void BindBuffer(GLenum target, GLuint buffer) {
  assert(pBindBuffer);
  pBindBuffer(target, buffer);
}
void BufferData(GLenum target, GLsizeiptr size, const void* data, GLenum usage) {
  assert(pBufferData);
  pBufferData(target, size, data, usage);
}
void EnableVertexAttribArray(GLuint index) {
  assert(pEnableVertexAttribArray);
  pEnableVertexAttribArray(index);
}
void VertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride,
                          const void* pointer) {
  assert(pVertexAttribPointer);
  pVertexAttribPointer(index, size, type, normalized, stride, pointer);
}
void DrawArrays(GLenum mode, GLint first, GLsizei count) {
  assert(pDrawArrays);
  pDrawArrays(mode, first, count);
}

void Viewport(GLint x, GLint y, GLsizei width, GLsizei height) {
  assert(pViewport);
  pViewport(x, y, width, height);
}
void ClearColor(GLfloat r, GLfloat g, GLfloat b, GLfloat a) {
  assert(pClearColor);
  pClearColor(r, g, b, a);
}
void Clear(GLbitfield mask) {
  assert(pClear);
  pClear(mask);
}
void Enable(GLenum cap) {
  assert(pEnable);
  pEnable(cap);
}
void DepthFunc(GLenum func) {
  assert(pDepthFunc);
  pDepthFunc(func);
}

} // namespace gl

