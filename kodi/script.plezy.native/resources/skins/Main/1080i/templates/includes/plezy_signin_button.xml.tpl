{# Plezy sign-in button (FocusableButton around ElevatedButton / OutlinedButton / TextButton, all StadiumBorder) at x1.5: a
   64px stadium. FocusableButton draws every idle button at 60% opacity and the focused one at 100%; Kodi cannot fade a whole
   button, so the idle art and label are pre-tinted instead.
     primary:  white (text) stadium, on_primary label; idle = the same stadium at 60%
     outlined: 2px outline stadium, muted label; focus = 3px text ring (FocusTheme.focusDecoration) and a text label
     text:     no outline, muted label; focus = the same ring
   params: bid, x, y (unscaled; passed through vscale), w, label (a Kodi label or string), variant (primary | outlined | text,
           default primary), up / down / left / right (control ids, omit for none), blank (leave the label empty: the caller draws
           it), enable (Kodi condition) #}
{% with v = variant|default("primary") %}
<control type="button" id="{{ bid }}">
    <posx>{{ x }}</posx>
    <posy>{{ y|vscale }}</posy>
    <width>{{ w }}</width>
    <height>{{ vscale(64) }}</height>
    {% if up %}<onup>{{ up }}</onup>{% endif %}
    {% if down %}<ondown>{{ down }}</ondown>{% endif %}
    {% if left %}<onleft>{{ left }}</onleft>{% endif %}
    {% if right %}<onright>{{ right }}</onright>{% endif %}
    {% if enable %}<enable>{{ enable }}</enable>{% endif %}
    <font>font12</font>
    <align>center</align>
    <aligny>center</aligny>
    <textoffsetx>24</textoffsetx>
    <disabledcolor>{{ core.plezy.disabled }}</disabledcolor>
    {% if v == "primary" %}
    <textcolor>{{ core.plezy.on_primary }}</textcolor>
    <focusedcolor>{{ core.plezy.on_primary }}</focusedcolor>
    <texturenofocus border="32" colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/pill-64.png</texturenofocus>
    <texturefocus border="32" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-64.png</texturefocus>
    {% elif v == "outlined" %}
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <focusedcolor>{{ core.plezy.text }}</focusedcolor>
    <texturenofocus border="32" colordiffuse="{{ core.plezy.outline }}">script.plex/plezy/outline-pill-64.png</texturenofocus>
    <texturefocus border="32" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/focus-pill-64.png</texturefocus>
    {% else %}
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <focusedcolor>{{ core.plezy.text }}</focusedcolor>
    <texturenofocus>-</texturenofocus>
    <texturefocus border="32" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/focus-pill-64.png</texturefocus>
    {% endif %}
    <label>{% if blank %} {% else %}[B]{{ label }}[/B]{% endif %}</label>
</control>
{% endwith %}
