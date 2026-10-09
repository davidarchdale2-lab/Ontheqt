{# One key of includes/pin_dialog.xml.tpl (Plezy _buildKey: 60lp = 90px, radius 16 -> r20, titleLarge w800 digits / 30lp icons).
   Selected = white (text) with an on_primary glyph; idle = surface on the surface card. Expects kid, col, row, up, down, left, right,
   num (the digit; empty for the close / backspace keys) and icon (close | backspace, else empty). #}
{% with kx = 96 + col * 99 & ky = 186 + row * 99 %}
<control type="button" id="{{ kid }}">
    <posx>{{ kx }}</posx>
    <posy>{{ ky|vscale }}</posy>
    <width>90</width>
    <height>{{ vscale(90) }}</height>
    <onup>{{ up }}</onup>
    <ondown>{{ down }}</ondown>
    <onleft>{{ left }}</onleft>
    <onright>{{ right }}</onright>
    {% if icon == "close" %}<onclick>SetFocus(101)</onclick>{% endif %}
    <font>font14</font>
    <align>center</align>
    <aligny>center</aligny>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <focusedcolor>{{ core.plezy.on_primary }}</focusedcolor>
    <texturefocus border="20" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/r20.png</texturefocus>
    <texturenofocus border="20" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r20.png</texturenofocus>
    <label>{% if num %}[B]{{ num }}[/B]{% else %} {% endif %}</label>
</control>
{% if icon %}
<control type="image">
    <visible>!Control.HasFocus({{ kid }})</visible>
    <posx>{{ kx + 23 }}</posx>
    <posy>{{ (ky + 23)|vscale }}</posy>
    <width>44</width>
    <height>{{ vscale(44) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/{{ icon }}.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>Control.HasFocus({{ kid }})</visible>
    <posx>{{ kx + 23 }}</posx>
    <posy>{{ (ky + 23)|vscale }}</posy>
    <width>44</width>
    <height>{{ vscale(44) }}</height>
    <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/{{ icon }}.png</texture>
    <aspectratio>keep</aspectratio>
</control>
{% endif %}
{% endwith %}
