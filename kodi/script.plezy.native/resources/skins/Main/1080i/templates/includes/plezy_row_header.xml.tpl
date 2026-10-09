{# Plezy rail/hub row header (tv_browse_rail.dart _buildHubHeader): 28px icon, bold title, optional muted count.
   params: icon (texture or $INFO), title (label or $INFO), count (optional label), x (default 16), y (default 0),
   width (default 1500), fallback_icon (default hub_default). 44px tall. #}
{% with rx = x|default(16) & ry = y|default(0) %}
<control type="image">
    <posx>{{ rx }}</posx>
    <posy>{{ (ry + 8)|vscale }}</posy>
    <width>28</width>
    <height>{{ vscale(28) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}" fallback="{{ fallback_icon|default("script.plex/plezy/icons/hub_default.png") }}">{{ icon }}</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="label">
    <posx>{{ rx + 40 }}</posx>
    <posy>{{ ry|vscale }}</posy>
    <width>{{ width|default(1500) }}</width>
    <height>{{ vscale(44) }}</height>
    <font>font14</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>false</scroll>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>[B]{{ title }}[/B]{% if count %}[COLOR {{ core.plezy.muted }}]  {{ count }}[/COLOR]{% endif %}</label>
</control>
{% endwith %}
