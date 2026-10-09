# Local preview changes — 8 October 2026

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

Physical Kodi installation, interface speed and playback remain untested.
