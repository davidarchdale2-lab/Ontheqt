{# Body of includes/music_button.xml.tpl (which picks pitch = wrapper width and disc = hit width for the theme's art).
   params: bid (button id), gid (wrapper id), asset (theme art name: shuffle, next, repeat, stop, pqueue, more, ...),
     flip (mirror the glyph: previous), vis (visible condition), disabled (draw dimmed and unfocusable),
     toggle (condition under which the control is on: alt art in the text colour), alt_asset (the on-state art,
     default the same), neutral (a two-state control such as play / pause: both states keep the idle colour), onclick, altclick,
     onup, ondown, onleft, onright (standalone buttons; items of a grouplist leave them to the list),
     states (repeat: [(condition, asset, active), ...] drawn as images over a texture-less button) #}
{% with base = abase|default(theme.assets.buttons.base) & sfx = theme.assets.buttons.focusSuffix %}
{% with bx = (pitch - 180) / 2 %}
<control type="group"{% if gid %} id="{{ gid }}"{% endif %}>
    {% if vis %}<visible>{{ vis }}</visible>{% endif %}
    <animation effect="zoom" start="100" end="112" time="150" tween="cubic" easing="out" center="{{ pitch / 2 }},{{ vscale(72.5) }}" reversible="true" condition="Control.HasFocus({{ bid }})">Conditional</animation>
    <width>{{ pitch }}</width>
    <height>{{ vscale(145) }}</height>
    <control type="{% if toggle %}togglebutton{% else %}button{% endif %}" id="{{ bid }}">
        <hitrect x="{{ (pitch - disc) / 2 }}" y="{{ vscale(36) }}" w="{{ disc }}" h="{{ vscale(73) }}" />
        <posx>{{ bx }}</posx>
        <posy>0</posy>
        <width>180</width>
        <height>{{ vscale(145) }}</height>
        {% if disabled %}<enable>false</enable>{% endif %}
        {% if onup %}<onup>{{ onup }}</onup>{% endif %}
        {% if ondown %}<ondown>{{ ondown }}</ondown>{% endif %}
        {% if onleft %}<onleft>{{ onleft }}</onleft>{% endif %}
        {% if onright %}<onright>{{ onright }}</onright>{% endif %}
        {% if onclick %}<onclick>{{ onclick }}</onclick>{% endif %}
        {% if altclick %}<altclick>{{ altclick }}</altclick>{% endif %}
        <font>font12</font>
        {% if states %}
        <texturefocus>-</texturefocus>
        <texturenofocus>-</texturenofocus>
        {% elif disabled %}
        <texturefocus{% if flip %} flipx="true"{% endif %} colordiffuse="{{ core.plezy.player_track }}">{{ base }}{{ asset }}.png</texturefocus>
        <texturenofocus{% if flip %} flipx="true"{% endif %} colordiffuse="{{ core.plezy.player_track }}">{{ base }}{{ asset }}.png</texturenofocus>
        {% else %}
        <texturefocus{% if flip %} flipx="true"{% endif %}{% if theme.buttons.useFocusColor %} colordiffuse="{{ core.plezy.player_fg }}"{% endif %}>{{ base }}{{ asset }}{{ sfx }}.png</texturefocus>
        <texturenofocus{% if flip %} flipx="true"{% endif %}{% if toggle and not neutral %} colordiffuse="{{ core.plezy.muted }}"{% elif theme.buttons.useNoFocusColor %} colordiffuse="{{ theme.buttons.noFocusColor|default(core.plezy.player_fg_subtle) }}"{% endif %}>{{ base }}{{ asset }}.png</texturenofocus>
        {% endif %}
        {% if toggle %}
        <alttexturefocus{% if theme.buttons.useFocusColor %} colordiffuse="{{ core.plezy.player_fg }}"{% endif %}>{{ base }}{{ alt_asset|default(asset) }}{{ sfx }}.png</alttexturefocus>
        <alttexturenofocus{% if neutral %}{% if theme.buttons.useNoFocusColor %} colordiffuse="{{ theme.buttons.noFocusColor|default(core.plezy.player_fg_subtle) }}"{% endif %}{% else %} colordiffuse="{{ core.plezy.text }}"{% endif %}>{{ base }}{{ alt_asset|default(asset) }}.png</alttexturenofocus>
        <usealttexture>{{ toggle }}</usealttexture>
        {% endif %}
        <label> </label>
    </control>
    {% if states %}{# multi-state control (repeat off / all / one): one image pair per state #}
    {% for scond, sasset, sactive in states %}
    <control type="image">
        <visible>[{{ scond }}] + !Control.HasFocus({{ bid }})</visible>
        <posx>{{ bx }}</posx>
        <posy>0</posy>
        <width>180</width>
        <height>{{ vscale(145) }}</height>
        <texture colordiffuse="{% if sactive %}{{ core.plezy.text }}{% else %}{{ core.plezy.muted }}{% endif %}">{{ base }}{{ sasset }}.png</texture>
    </control>
    <control type="image">
        <visible>[{{ scond }}] + Control.HasFocus({{ bid }})</visible>
        <posx>{{ bx }}</posx>
        <posy>0</posy>
        <width>180</width>
        <height>{{ vscale(145) }}</height>
        <texture{% if theme.buttons.useFocusColor %} colordiffuse="{{ core.plezy.player_fg }}"{% endif %}>{{ base }}{{ sasset }}{{ sfx }}.png</texture>
    </control>
    {% endfor %}
    {% endif %}
</control>
{% endwith %}
{% endwith %}
