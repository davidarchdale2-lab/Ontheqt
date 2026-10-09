{# Body of includes/seek_osd_button.xml.tpl (which picks sc = art scale, pitch = slot width, disc = focus disc size
   for the theme's button art). The 180x145 art canvas is centred in a pitch x 96 slot; the hitrect (parent
   coordinates, like posx) covers just the disc so neighbouring canvases don't steal the mouse.
   abase overrides theme.assets.buttons.base and nosfx drops the focus suffix, for art a theme doesn't ship (vs10). #}
{% with cw = 180 * sc & ch = 145 * sc & rowh = 96 & base = abase|default(theme.assets.buttons.base) & sfx = theme.assets.buttons.focusSuffix %}
{% with bx = (pitch - cw) / 2 & by = (rowh - ch) / 2 & hx = (pitch - disc) / 2 & hy = (rowh - disc) / 2 %}
<control type="group"{% if gid %} id="{{ gid }}"{% endif %}>
    {% if vis %}<visible>{{ vis }}</visible>{% endif %}
    <animation effect="zoom" start="100" end="112" time="150" tween="cubic" easing="out" center="{{ pitch / 2 }},{{ (rowh / 2)|vscale }}" reversible="true" condition="Control.HasFocus({{ bid }})">Conditional</animation>
    <width>{{ pitch }}</width>
    <height>{{ rowh|vscale }}</height>
    <control type="{% if alt_asset %}togglebutton{% else %}button{% endif %}" id="{{ bid }}">
        <hitrect x="{{ hx }}" y="{{ hy|vscale }}" w="{{ disc }}" h="{{ disc|vscale }}" />
        <posx>{{ bx }}</posx>
        <posy>{{ by|vscale }}</posy>
        <width>{{ cw }}</width>
        <height>{{ ch|vscale }}</height>
        {% if disabled %}<enable>false</enable>{% endif %}
        {% if onleft %}<onleft>{{ onleft }}</onleft>{% endif %}
        {% if onright %}<onright>{{ onright }}</onright>{% endif %}
        <onup>100</onup>
        <ondown>501</ondown>
        {% if onclick %}<onclick>{{ onclick }}</onclick>{% endif %}
        <font>font12</font>
        {% if states %}
        <texturefocus>-</texturefocus>
        <texturenofocus>-</texturenofocus>
        {% elif disabled %}
        <texturefocus{% if flip %} flipx="true"{% endif %} colordiffuse="{{ core.plezy.player_track }}">{{ base }}{{ asset }}.png</texturefocus>
        <texturenofocus{% if flip %} flipx="true"{% endif %} colordiffuse="{{ core.plezy.player_track }}">{{ base }}{{ asset }}.png</texturenofocus>
        {% else %}
        <texturefocus{% if flip %} flipx="true"{% endif %}{% if theme.buttons.useFocusColor %} colordiffuse="{{ core.plezy.player_fg }}"{% endif %}>{{ base }}{{ asset }}{% if not nosfx %}{{ sfx }}{% endif %}.png</texturefocus>
        <texturenofocus{% if flip %} flipx="true"{% endif %}{% if theme.buttons.useNoFocusColor %} colordiffuse="{{ theme.buttons.noFocusColor|default(core.plezy.player_fg_subtle) }}"{% endif %}>{{ base }}{{ asset }}.png</texturenofocus>
        {% endif %}
        {% if alt_asset %}
        {% if alt_active %}
        <alttexturefocus{% if flip %} flipx="true"{% endif %} colordiffuse="{{ core.plezy.active }}">{{ base }}{{ alt_asset }}{% if not nosfx %}{{ sfx }}{% endif %}.png</alttexturefocus>
        <alttexturenofocus{% if flip %} flipx="true"{% endif %} colordiffuse="{{ core.plezy.active }}">{{ base }}{{ alt_asset }}.png</alttexturenofocus>
        {% else %}
        <alttexturefocus{% if flip %} flipx="true"{% endif %}{% if theme.buttons.useFocusColor %} colordiffuse="{{ core.plezy.player_fg }}"{% endif %}>{{ base }}{{ alt_asset }}{% if not nosfx %}{{ sfx }}{% endif %}.png</alttexturefocus>
        <alttexturenofocus{% if flip %} flipx="true"{% endif %}{% if theme.buttons.useNoFocusColor %} colordiffuse="{{ theme.buttons.noFocusColor|default(core.plezy.player_fg_subtle) }}"{% endif %}>{{ base }}{{ alt_asset }}.png</alttexturenofocus>
        {% endif %}
        <usealttexture>{{ alt_cond }}</usealttexture>
        {% endif %}
        <label> </label>
    </control>
    {% if states %}{# multi-state control (repeat off / all / one): the art is drawn by images, one pair per state #}
    {% for scond, sasset, sactive in states %}
    <control type="image">
        <visible>[{{ scond }}] + !Control.HasFocus({{ bid }})</visible>
        <posx>{{ bx }}</posx>
        <posy>{{ by|vscale }}</posy>
        <width>{{ cw }}</width>
        <height>{{ ch|vscale }}</height>
        {% if sactive %}<texture colordiffuse="{{ core.plezy.active }}">{{ base }}{{ sasset }}.png</texture>
        {% else %}<texture{% if theme.buttons.useNoFocusColor %} colordiffuse="{{ theme.buttons.noFocusColor|default(core.plezy.player_fg_subtle) }}"{% endif %}>{{ base }}{{ sasset }}.png</texture>{% endif %}
    </control>
    <control type="image">
        <visible>[{{ scond }}] + Control.HasFocus({{ bid }})</visible>
        <posx>{{ bx }}</posx>
        <posy>{{ by|vscale }}</posy>
        <width>{{ cw }}</width>
        <height>{{ ch|vscale }}</height>
        {% if sactive %}<texture colordiffuse="{{ core.plezy.active }}">{{ base }}{{ sasset }}{% if not nosfx %}{{ sfx }}{% endif %}.png</texture>
        {% else %}<texture{% if theme.buttons.useFocusColor %} colordiffuse="{{ core.plezy.player_fg }}"{% endif %}>{{ base }}{{ sasset }}{% if not nosfx %}{{ sfx }}{% endif %}.png</texture>{% endif %}
    </control>
    {% endfor %}
    {% endif %}
</control>
{% endwith %}
{% endwith %}
