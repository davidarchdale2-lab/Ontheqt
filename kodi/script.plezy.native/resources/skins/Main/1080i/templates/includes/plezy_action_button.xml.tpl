{# Plezy detail action button (edde746/plezy lib/screens/media_detail/action_buttons.dart, TV).
   Idle: surface @38% with a text glyph; focused: text fill with a bg glyph; no scale, no ring. The colours are
   baked into script.plex/plezy/action/*.png (tools/make_plezy_textures.py ACTION_ICONS), so this stays a single
   Kodi control: grouplists, Python getControl/setFocusId and visibility behave like any button.
   params: id, icon (Material Symbols name with baked action textures)
     shape: "circle" (default, 56x56) | "pill" (icon-only 72x56, Play for movies/episodes)
            | "label" (glyph in the left cap + label, auto width; Play "S1 E3" for shows)
            | "split" (Play's left segment 72x56 when a version split follows) | "version" (the split's 42x56 chevron)
     label (shape "label"), alt_icon + alt_cond (togglebutton showing alt_icon while alt_cond holds),
     visible, allowhiddenfocus, enable, posx, posy, onleft/onright/onup/ondown, onclick, onfocus #}
{% with h = 56 %}
<control type="{% if alt_icon %}togglebutton{% else %}button{% endif %}" id="{{ id }}">
    {% if visible %}<visible{% if allowhiddenfocus %} allowhiddenfocus="true"{% endif %}>{{ visible }}</visible>{% endif %}
    {% if enable %}<enable>{{ enable }}</enable>{% endif %}
    {% if onleft %}<onleft>{{ onleft }}</onleft>{% endif %}
    {% if onright %}<onright>{{ onright }}</onright>{% endif %}
    {% if onup %}<onup>{{ onup }}</onup>{% endif %}
    {% if ondown %}<ondown>{{ ondown }}</ondown>{% endif %}
    {% if onclick %}<onclick>{{ onclick }}</onclick>{% endif %}
    {% if onfocus %}<onfocus>{{ onfocus }}</onfocus>{% endif %}
    <posx>{{ posx|default(0) }}</posx>
    <posy>{{ posy|default(0)|vscale }}</posy>
    {% if shape == "label" %}<width max="480">auto</width>{% elif shape == "pill" %}<width>72</width>{% elif shape == "split" %}<width>72</width>{% elif shape == "version" %}<width>42</width>{% else %}<width>{{ h }}</width>{% endif %}
    <height>{{ h|vscale }}</height>
    <font>font12</font>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <focusedcolor>{{ core.plezy.on_primary }}</focusedcolor>
    <disabledcolor>{{ core.plezy.disabled }}</disabledcolor>
    {% if shape == "label" %}
    <align>left</align>
    <aligny>center</aligny>
    <textoffsetx>62</textoffsetx>
    <texturefocus border="64,28,28,28">script.plex/plezy/action/label-{{ icon }}-focus.png</texturefocus>
    <texturenofocus border="64,28,28,28">script.plex/plezy/action/label-{{ icon }}.png</texturenofocus>
    {% if alt_icon %}
    <alttexturefocus border="64,28,28,28">script.plex/plezy/action/label-{{ alt_icon }}-focus.png</alttexturefocus>
    <alttexturenofocus border="64,28,28,28">script.plex/plezy/action/label-{{ alt_icon }}.png</alttexturenofocus>
    {% endif %}
    <label>[B]{{ label }}[/B]</label>
    {% else %}
    {% if shape == "pill" %}
    <texturefocus>script.plex/plezy/action/pill-{{ icon }}-focus.png</texturefocus>
    <texturenofocus>script.plex/plezy/action/pill-{{ icon }}.png</texturenofocus>
    {% if alt_icon %}
    <alttexturefocus>script.plex/plezy/action/pill-{{ alt_icon }}-focus.png</alttexturefocus>
    <alttexturenofocus>script.plex/plezy/action/pill-{{ alt_icon }}.png</alttexturenofocus>
    {% endif %}
    {% elif shape == "split" %}
    <texturefocus>script.plex/plezy/action/split-{{ icon }}-focus.png</texturefocus>
    <texturenofocus>script.plex/plezy/action/split-{{ icon }}.png</texturenofocus>
    {% if alt_icon %}
    <alttexturefocus>script.plex/plezy/action/split-{{ alt_icon }}-focus.png</alttexturefocus>
    <alttexturenofocus>script.plex/plezy/action/split-{{ alt_icon }}.png</alttexturenofocus>
    {% endif %}
    {% elif shape == "version" %}
    <texturefocus>script.plex/plezy/action/version-focus.png</texturefocus>
    <texturenofocus>script.plex/plezy/action/version.png</texturenofocus>
    {% else %}
    <texturefocus>script.plex/plezy/action/{{ icon }}-focus.png</texturefocus>
    <texturenofocus>script.plex/plezy/action/{{ icon }}.png</texturenofocus>
    {% if alt_icon %}
    <alttexturefocus>script.plex/plezy/action/{{ alt_icon }}-focus.png</alttexturefocus>
    <alttexturenofocus>script.plex/plezy/action/{{ alt_icon }}.png</alttexturenofocus>
    {% endif %}
    {% endif %}
    <label> </label>
    {% endif %}
    {% if alt_icon %}<usealttexture>{{ alt_cond }}</usealttexture>{% endif %}
</control>
{% endwith %}
