{# Player OSD round control (seek dialog button row). Plezy: VideoControlButton + PlayerFocusDisc
   (lib/widgets/video_controls/video_control_button.dart, widgets/player_focus_disc.dart): a 40px control (48 for
   play/pause), white glyph when idle, a solid white disc with the glyph inverted when focused, amber when active,
   scaled 1.12 (FocusTheme.playerControlFocusScale). Drawn at x1.5 with the theme's button art
   (theme.assets.buttons: the "plezy" theme bakes the white disc + dark glyph into the -focus textures).

   Each control sits in a fixed-pitch wrapper group so the cluster grouplists use itemgap 0 and the art can be
   scaled per asset. Navigation: give the button's left/right neighbours as wrapper ids (Kodi follows the hidden or
   disabled wrappers' grouplist chain onwards); up goes to the timeline (100), down to the big seek list (501).

   params: gid (wrapper id), bid (button id), asset (theme asset name), size "std" (default) | "play" | "small"
     (assets whose disc is drawn larger, e.g. skip-forward, vs10), flip (mirror the glyph), vis (visible
     condition), disabled (bool), alt_asset + alt_cond (togglebutton: alt art while alt_cond holds) + alt_active
     (draw the alt art in core.plezy.active), onleft, onright, onclick #}
{% if theme.assets.buttons.base == "script.plex/buttons/" %}{# classic: 100x65 boxes, 160x125 focus plates #}
    {% if size == "play" %}{% include "includes/seek_osd_button_body.xml.tpl" with sc=0.72 & pitch=80 & disc=72 %}
    {% else %}{% include "includes/seek_osd_button_body.xml.tpl" with sc=0.6 & pitch=64 & disc=60 %}{% endif %}
{% else %}{# modern / plezy / dotted: ~36px glyphs, ~69px focus discs on a 180x145 canvas #}
    {% if size == "play" %}{% include "includes/seek_osd_button_body.xml.tpl" with sc=1.04 & pitch=80 & disc=72 %}
    {% elif size == "small" %}{% include "includes/seek_osd_button_body.xml.tpl" with sc=0.62 & pitch=64 & disc=62 %}
    {% else %}{% include "includes/seek_osd_button_body.xml.tpl" with sc=0.9 & pitch=64 & disc=62 %}{% endif %}
{% endif %}
