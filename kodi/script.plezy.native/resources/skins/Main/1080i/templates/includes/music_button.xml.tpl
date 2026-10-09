{# Now-playing round control (Plezy now_playing_screen.dart transport / utility buttons), drawn at x1.5 with the
   theme's button art (theme.assets.buttons: the "plezy" theme bakes the white disc + dark glyph into the -focus
   textures). The 180x145 art canvas sits centred in a fixed-pitch wrapper so the grouplists use itemgap 0: the
   plezy / modern themes' ~73px discs end up 12px apart (pitch 85); classic's 100px boxes get pitch 105.
   Toggles (shuffle, repeat) are muted while off and text-coloured while on. Focus scales the wrapper 1.12.
   See includes/music_button_body.xml.tpl for the params. #}
{% if theme.assets.buttons.base == "script.plex/buttons/" %}
    {% include "includes/music_button_body.xml.tpl" with pitch=105 & disc=100 %}
{% else %}
    {% include "includes/music_button_body.xml.tpl" with pitch=85 & disc=73 %}
{% endif %}
