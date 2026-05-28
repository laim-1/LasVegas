#!/usr/bin/env python3
"""Patch Godot Web export for cache busting + on-page reload (GitHub Pages)."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def patch(html_path: Path, version: str) -> None:
    version = version.strip()[:40]
    if not version:
        version = "dev"

    html = html_path.read_text(encoding="utf-8")

    if "lv-reload-btn" in html:
        # Update version in place for re-runs.
        html = re.sub(
            r'<meta name="build-version" content="[^"]*">',
            f'<meta name="build-version" content="{version}">',
            html,
            count=1,
        )
        html = re.sub(
            r'window\.LV_BUILD = "[^"]*";',
            f'window.LV_BUILD = "{version}";',
            html,
            count=1,
        )
        html_path.write_text(html, encoding="utf-8")
        return

    inject_head = f"""
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta name="build-version" content="{version}">
<style>
#lv-reload-btn {{
  position: fixed;
  top: 12px;
  right: 12px;
  z-index: 100000;
  padding: 14px 20px;
  font-size: 17px;
  font-weight: 600;
  cursor: pointer;
  background: #1e4a7a;
  color: #fff;
  border: 2px solid #8ab4f8;
  border-radius: 8px;
  font-family: system-ui, sans-serif;
  pointer-events: auto;
  box-shadow: 0 2px 8px rgba(0,0,0,0.35);
}}
#lv-reload-btn:hover {{ background: #2563a8; }}
#lv-reload-hint {{
  position: fixed;
  bottom: 12px;
  left: 12px;
  z-index: 100000;
  padding: 8px 12px;
  font-size: 13px;
  color: #ddd;
  background: rgba(0,0,0,0.55);
  border-radius: 6px;
  font-family: system-ui, sans-serif;
  pointer-events: none;
}}
</style>
<script>
window.LV_BUILD = "{version}";
window.reloadLasVegasGame = function() {{
  try {{
    sessionStorage.setItem("lv_force_reload", "1");
  }} catch (e) {{}}
  var url = location.pathname;
  if (!url.endsWith("/")) {{
    var slash = url.lastIndexOf("/");
    url = slash >= 0 ? url.slice(0, slash + 1) : "/";
  }}
  location.replace(url + "index.html?v=" + window.LV_BUILD + "&t=" + Date.now());
}};
(function() {{
  var build = window.LV_BUILD;
  try {{
    var prev = sessionStorage.getItem("lv_build");
    if (prev && prev !== build && !sessionStorage.getItem("lv_force_reload")) {{
      sessionStorage.setItem("lv_build", build);
      window.reloadLasVegasGame();
      return;
    }}
    sessionStorage.setItem("lv_build", build);
    sessionStorage.removeItem("lv_force_reload");
  }} catch (e) {{}}

  var _fetch = window.fetch;
  window.fetch = function(url, opts) {{
    if (typeof url === "string" && /\\.(pck|wasm|js)(\\?|$)/.test(url)) {{
      url += (url.indexOf("?") >= 0 ? "&" : "?") + "v=" + build;
    }}
    return _fetch(url, opts);
  }};
}})();
</script>
"""

    html = html.replace("<head>", "<head>" + inject_head, 1)
    html = re.sub(r'src="index\.js"', f'src="index.js?v={version}"', html, count=1)

    if '"mainPack"' not in html:
        html = html.replace(
            '"focusCanvas":true',
            f'"mainPack":"index.pck?v={version}","focusCanvas":true',
            1,
        )

    btn = (
        '<button type="button" id="lv-reload-btn" '
        'onclick="window.reloadLasVegasGame()">Reload game</button>\n'
        '<div id="lv-reload-hint">Tip: U key or in-game Reload button (Chromebook: no F5)</div>\n'
    )
    html = html.replace("<body>", "<body>\n" + btn, 1)

    html_path.write_text(html, encoding="utf-8")


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: patch_web_export.py <path/to/index.html> <build-version>")
        return 1
    patch(Path(sys.argv[1]), sys.argv[2])
    print(f"Patched {sys.argv[1]} (version={sys.argv[2][:12]}...)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
