# Local preview changes

## Revision 3 - 10 October 2026

Ports every remaining screen to the Plezy TV design and runs three adversarial review passes over them. Playback,
the stream-decision engine, codec and audio settings are still Kodi's and are unchanged.

- Detail screens (pre-play, show, season, episodes): full-bleed backdrop with scrims, bottom-aligned hero column,
  `includes/plezy_action_button.xml.tpl` action row, card rails. New helpers in `lib/plezy_*.py`.
- Player, seek bar and playlist: Plezy control bar (x1.5 geometry), "plezy" button art, amber active toggles.
- Search, settings and dialogs, user select and sign-in, music, photos and list views: Plezy surfaces, rows and pills.
- Shared: `plezy_scrims` foot fill and `default_background` use the full 1080 height at 4:3; card artwork uses
  `scalediffuse="false"`; new error icon; strings 35120-35261 added in the Plezy block.
- Home: spotlight type label and "S2 E4" episode label as in Plezy; rail hitrect; vscaled row gap. Library filter
  bars in sentence case with Plezy pills.
- Classic theme: `buttongroup_1300.posy` is a number (fixed a 4:3 render failure).
- THEME_VERSION is 101, so installed templates re-render on first start.
- Verified by rendering 940 layouts at 1920x1080 and 1440x1080 and 167 unit tests. Physical Kodi installation,
  interface speed and playback remain untested.

## Revision 2 — 9 October 2026

Moves the interface closer to the official Plezy app (edde746/plezy, TV layout). Playback, the stream-decision
engine, codec and audio settings are still Kodi's and are unchanged.

- Home (`script-plex-home.xml.tpl`): Plezy's TV structure. A 72px icon rail (Search, Home, libraries) that opens
  into a floating 300px panel with labels while it has focus; a spotlight for the focused item (clear logo or
  title, metadata line, summary) over the backdrop; hub rows anchored to the bottom with the active row leading,
  rows that scrolled past fading out and the others dimmed. Server/user buttons are Plezy primary pills. Control
  IDs and navigation targets the Python relies on are unchanged; Up from the first row now goes to the toolbar.
- Home Python (`lib/windows/home.py`, new `lib/plezy_ui.py`): spotlight text built from the hub listing (no extra
  requests; honours the spoiler settings), Plezy's row icons, and a `hub.focus.id` property that keeps the row
  fade in step with the slide. Spotlight metadata drops ratings, then content rating, then runtime when long,
  like Plezy's FittedMetadataLine.
- Cards (home rows, library grids, extras): rounded 8px artwork, 2.5px-style primary ring and glow on focus,
  left-aligned semi-bold titles with muted subtitles, inset progress bars.
- Palette: Plezy's dark tokens (`core.plezy` in `lib/templating/context.py`) replace r1's blue-grey accent and
  the dialog greys across all templates; the Plex wordmark is gone from headers.
- Theme: new default "Plezy" button theme (muted glyphs, white disc on focus); Modern/Classic remain selectable.
- Background art opacity defaults to 100% (was 20%). Home draws Plezy's gradient scrims instead of a flat dim;
  other screens keep their dim so text stays readable.
- Icons: Material Symbols Rounded (Google, Apache-2.0), the set Plezy uses, rendered to PNG.
- THEME_VERSION is bumped (see lib/util.py), so installed templates re-render on first start.

Credits: layout values, colours, the hub-icon keyword table and the metadata ordering follow edde746/plezy
(GPL-3.0); they were re-implemented here rather than copied. Detail screens keep PM4K's layout with the Plezy
palette and buttons.

Physical Kodi installation, interface speed and playback remain untested.

## Revision 1 — 8 October 2026

Derived from pannal/plex-for-kodi at commit
2707bbe72a7ea829b69bdd7ebb753c700552b4d0. Original copyright notices and the
complete upstream licence aggregate are retained.

- Native left sidebar, larger title and captions, neutral dark palette and
  white focus outlines. Original Kodi controller IDs and remote actions stay
  connected to their existing Plex functions.
- Library reordering uses Up/Down to match the vertical sidebar; dummy
  horizontal padding items are removed.
- Subtitle picker explicitly says Off and selects it when no stream is set.
- Separate add-on ID, global-property namespace and singleton lock.
- Local self-updater disabled and its unsupported controls hidden.
- Native playback/stream-decision engines, codec and audio settings unchanged.
