{# Plezy dialog action (edde746/plezy lib/widgets/dialog_action_button.dart, FocusableButton) at x1.5: a 64px stadium.
   Idle: label at 60% (muted), no fill. Focused: white (text) stadium with an on_primary label. No scale, no zoom.
   Auto width (min 120) with 30px side padding; place it in a right-aligned horizontal grouplist (itemgap 12).
   params: id, prop (window property holding the label, e.g. button.0), visible (Kodi condition),
           allowhiddenfocus (keep focusable while its visible condition is still false), enable (Kodi condition) #}
<control type="button" id="{{ id }}">
    <visible{% if allowhiddenfocus %} allowhiddenfocus="true"{% endif %}>{{ visible }}</visible>
    {% if enable %}<enable>{{ enable }}</enable>{% endif %}
    <posx>0</posx>
    <posy>0</posy>
    <width min="120">auto</width>
    <height>{{ vscale(64) }}</height>
    <font>font12</font>
    <align>center</align>
    <aligny>center</aligny>
    <textoffsetx>30</textoffsetx>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <focusedcolor>{{ core.plezy.on_primary }}</focusedcolor>
    <disabledcolor>{{ core.plezy.disabled }}</disabledcolor>
    <texturefocus border="32" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-64.png</texturefocus>
    <texturenofocus>-</texturenofocus>
    <label>[B]$INFO[Window.Property({{ prop }})][/B]</label>
</control>
