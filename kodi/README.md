# Plezy Native for Kodi

`script.plezy.native` is a Kodi add-on derived from PM4K (pannal/plex-for-kodi) with an interface modelled on the
official Plezy app (edde746/plezy). Kodi still does all video and audio playback. See
`script.plezy.native/LOCAL-CHANGES.md` for what changed per revision and `INSTALL-NATIVE.txt` for installing.

## Layout

- `script.plezy.native/` – the add-on source (what goes in the ZIP)
- `tools/make_plezy_textures.py` – regenerates the Plezy textures (pills, masks, rings, scrims, button theme) and,
  given the Material Symbols Rounded font + codepoints, the icons
- `tools/render_templates.py`, `tools/check_layouts.py` – render every template outside Kodi and compare a render
  against a baseline (XML validity, control IDs the Python uses, fonts, textures)
- `tools/preview_layout.py` + `tools/preview/*.json` – approximate PNG previews of a rendered window with mock data
- `tools/build_zip.py` – builds the installable ZIP
- `tests/` – unit tests for `lib/plezy_ui.py`

## Common tasks

```sh
# unit tests
python3 -m pytest kodi/tests

# render all layouts and check them against a baseline render of the previous release
python3 -I kodi/tools/render_templates.py kodi/script.plezy.native /tmp/render_new
python3 -I kodi/tools/check_layouts.py kodi/script.plezy.native /tmp/render_base /tmp/render_new

# preview the home screen
python3 -I kodi/tools/preview_layout.py kodi/script.plezy.native \
    /tmp/render_new/plezy/modern_2024/script-plex-home.xml kodi/tools/preview/home.json /tmp/home.png

# build the ZIP
python3 kodi/tools/build_zip.py kodi/script.plezy.native kodi/dist/Plezy-Native-preview-r2.zip
```

Design tokens live in `script.plezy.native/lib/templating/context.py` (`core.plezy`); a `context_overrides.json`
in the add-on's profile folder can override them on a device. Bump `THEME_VERSION` in `lib/util.py` whenever
templates change so installed copies re-render.
