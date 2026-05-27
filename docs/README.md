# GitHub Pages build output

This folder holds the **Godot Web export** for GitHub Pages.

## First time

1. Open the Godot project in [`../godot/`](../godot/).
2. Install export templates (Editor → Manage Export Templates).
3. **Project → Export → Web → Export Project** → save as `index.html` in **this folder**.

After export you should see files like:

- `index.html`
- `index.wasm` (or similar)
- `index.pck`
- supporting `.js` files

Commit and push, then enable **GitHub Pages** with source **`/docs`** on branch `main`.

See [../godot/README.md](../godot/README.md) for full steps.
