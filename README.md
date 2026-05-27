# LasVegas Horror

A small **3D first-person horror** vertical slice: explore a dark room with a flashlight while something hunts you. **Survive 30 seconds** to win.

Two implementations live in this repo:

| Folder | Stack | Run where |
|--------|--------|-----------|
| [`godot/`](godot/) | **Godot 4.6.3** (recommended) | Desktop + **browser (GitHub Pages)** |
| `src/` + `CMakeLists.txt` | C++ / SDL2 / OpenGL | Windows desktop only |

---

## Quick start (Godot — play in browser on GitHub Pages)

1. Install [Godot 4.6.3](https://godotengine.org/download).
2. Open [`godot/project.godot`](godot/project.godot) in the editor → **F5**.
3. To publish on GitHub Pages, follow **[godot/README.md](godot/README.md)** (export Web → `docs/` → enable Pages).

---

## Quick start (C++ desktop)

See the original build steps below (vcpkg + CMake). The C++ version does **not** run in a browser.

### Dependencies (Windows)

```powershell
.\vcpkg.exe install sdl2:x64-windows glm:x64-windows
```

### Build

```powershell
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE="C:\path\to\vcpkg\scripts\buildsystems\vcpkg.cmake"
cmake --build build --config Release
```

Run `build/bin/Release/LasVegasHorror.exe` from the repo root so `assets/shaders/` resolves.

---

## Gameplay

- **Mouse** — look  
- **WASD** — move  
- **R** — restart  
- **Goal** — stay alive for **30 seconds**; the enemy chases when it sees you  

Features: flashlight spotlight, fog, proximity flicker/shake, heartbeat audio, simple patrol/chase/attack AI.
