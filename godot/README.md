# LasVegas Horror (Godot 4.6.3)

3D first-person horror prototype — same design as the C++ version, rebuilt for **Godot 4.6.3** with **Web export** for GitHub Pages.

## Play in editor

1. Install [Godot 4.6.3](https://godotengine.org/download) (standard build; GDScript only — no .NET required).
2. Open Godot → **Import** → select this folder (`godot/project.godot`).
3. Press **F5** to run.

### Controls

| Input | Action |
|-------|--------|
| Mouse | Look |
| W / A / S / D | Move |
| R | Restart |
| Esc | Release mouse (desktop) |

**Web:** click the game canvas once to capture the mouse.

## Objective

Survive **30 seconds** without letting the enemy reach you (line-of-sight + attack range). Fog, flashlight flicker, camera shake, and heartbeat audio ramp up as it gets closer.

---

## Export for GitHub Pages

### One-time setup

1. In Godot: **Editor → Manage Export Templates** → download templates for **4.6.3** (must match your editor version).
2. **Project → Export** → add preset **Web** (already defined in `export_presets.cfg`).
3. Export path is set to `../docs/index.html` (repo `docs/` folder).

### Export

1. **Project → Export → Web → Export Project**
2. Choose output: `docs/index.html` (relative to repo root).
3. Godot writes `index.html`, `.wasm`, `.pck`, etc. into `docs/`.

### Enable GitHub Pages

1. Push the repo to GitHub.
2. **Settings → Pages → Build and deployment → Source**: **Deploy from a branch**
3. Branch: `main`, folder: **`/docs`**
4. Open `https://<username>.github.io/<repo>/` (may take a minute).

> If the game shows a black screen, open the browser devtools console. Web builds need to be served over HTTPS (GitHub Pages provides this).

### Optional: CI export

See `.github/workflows/godot-web-export.yml` — runs headless export on push (requires export templates in CI).

---

## Project layout

```
godot/
  project.godot
  scenes/main.tscn      # Main level + player + enemy + UI
  scripts/
    game_manager.gd     # Win/lose timer (autoload)
    player.gd           # FPS + flashlight flicker
    enemy.gd            # Patrol / chase / attack + LOS raycast
    level.gd            # Procedural room boxes
    heartbeat_audio.gd  # Procedural audio
    main.gd             # Spawns + HUD
  export_presets.cfg    # Web → ../docs/
```

The original C++ “no engine” build remains in the repo root (`src/`, `CMakeLists.txt`).
