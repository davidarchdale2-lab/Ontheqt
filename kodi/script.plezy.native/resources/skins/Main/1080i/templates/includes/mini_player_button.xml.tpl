{# Round transport button of the mini player on script-plex-user_select.xml.tpl (a button of the "plezy" player art:
   a glyph that turns into a white disc with a dark glyph on focus, no zoom). The 180 x 145 art canvas is centred in an 80 x 64 slot of
   grouplist 600; the hit rect covers just the disc.
   params: bid (button id), asset (art name), flip (mirror the glyph), alt_asset + alt_cond (togglebutton: other art while alt_cond holds),
           enable (Kodi condition), onclick #}
{% with base = "script.plex/buttons/player/plezy/" & cw = 162 & ch = 130.5 %}
<control type="group">
    <width>80</width>
    <height>{{ vscale(64) }}</height>
    <control type="{% if alt_asset %}togglebutton{% else %}button{% endif %}" id="{{ bid }}">
        <hitrect x="9" y="{{ vscale(1) }}" w="62" h="{{ vscale(62) }}" />
        <posx>-41</posx>
        <posy>{{ vscale(-33.25) }}</posy>
        <width>{{ cw }}</width>
        <height>{{ vscale(130.5) }}</height>
        {% if enable %}<enable>{{ enable }}</enable>{% endif %}
        <font>font12</font>
        <texturefocus{% if flip %} flipx="true"{% endif %}>{{ base }}{{ asset }}-focus.png</texturefocus>
        <texturenofocus{% if flip %} flipx="true"{% endif %} colordiffuse="{{ core.plezy.player_fg_muted }}">{{ base }}{{ asset }}.png</texturenofocus>
        {% if alt_asset %}
        <usealttexture>{{ alt_cond }}</usealttexture>
        <alttexturefocus>{{ base }}{{ alt_asset }}-focus.png</alttexturefocus>
        <alttexturenofocus colordiffuse="{{ core.plezy.player_fg_muted }}">{{ base }}{{ alt_asset }}.png</alttexturenofocus>
        {% endif %}
        <onclick>{{ onclick }}</onclick>
        <label> </label>
    </control>
</control>
{% endwith %}
