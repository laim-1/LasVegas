cmake_minimum_required(VERSION 3.20)
project(LasVegasHorror LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Put binaries under build/bin/<config> for predictable "assets/" lookup.
foreach(cfg IN ITEMS Debug Release RelWithDebInfo MinSizeRel)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${cfg} "${CMAKE_BINARY_DIR}/bin/${cfg}")
endforeach()

add_executable(LasVegasHorror
  src/main.cpp

  src/app/Game.cpp
  src/app/Game.h

  src/platform/Window.cpp
  src/platform/Window.h
  src/platform/Input.cpp
  src/platform/Input.h

  src/renderer/GLLoader.cpp
  src/renderer/GLLoader.h
  src/renderer/Renderer.cpp
  src/renderer/Renderer.h
  src/renderer/Shader.cpp
  src/renderer/Shader.h
  src/renderer/Mesh.cpp
  src/renderer/Mesh.h
  src/renderer/Camera.cpp
  src/renderer/Camera.h

  src/game/Level.cpp
  src/game/Level.h
  src/game/Player.cpp
  src/game/Player.h
  src/game/Enemy.cpp
  src/game/Enemy.h
)

# SDL2 (vcpkg typically provides SDL2::SDL2)
find_package(SDL2 CONFIG REQUIRED)

# glm (header-only; with vcpkg it usually provides a target)
find_package(glm CONFIG QUIET)

target_include_directories(LasVegasHorror PRIVATE src)

target_link_libraries(LasVegasHorror PRIVATE opengl32)

if(TARGET SDL2::SDL2)
  target_link_libraries(LasVegasHorror PRIVATE SDL2::SDL2)
else()
  # Fallback for non-config installs: adjust these paths in CMakeLists if needed.
  message(FATAL_ERROR "SDL2 target SDL2::SDL2 was not found. Install SDL2 via vcpkg or update CMakeLists.")
endif()

if(TARGET glm::glm)
  target_link_libraries(LasVegasHorror PRIVATE glm::glm)
elseif(TARGET glm::glm-header-only)
  target_link_libraries(LasVegasHorror PRIVATE glm::glm-header-only)
else()
  # If glm config isn't available, at least try to locate headers.
  find_path(GLM_INCLUDE_DIR glm/glm.hpp)
  if(NOT GLM_INCLUDE_DIR)
    message(FATAL_ERROR "glm was not found. Install via vcpkg (glm:x64-windows) or provide GLM_INCLUDE_DIR.")
  endif()
  target_include_directories(LasVegasHorror PRIVATE "${GLM_INCLUDE_DIR}")
endif()

