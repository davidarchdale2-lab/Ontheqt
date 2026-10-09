{# Plezy CircularProgressIndicator stand-in: a 270-degree arc spinning once a second.
   params: x, y (top-left), size (default 60), visible (condition), color (default core.plezy.text) #}
<control type="image">
    {% if visible %}<visible>{{ visible }}</visible>{% endif %}
    <animation effect="rotate" start="0" end="-360" center="auto" time="1000" loop="true" reversible="false" condition="true">Conditional</animation>
    <posx>{{ x }}</posx>
    <posy>{{ y|vscale }}</posy>
    <width>{{ size|default(60) }}</width>
    <height>{{ size|default(60)|vscale }}</height>
    <texture colordiffuse="{{ color|default(core.plezy.text) }}">script.plex/plezy/spinner.png</texture>
    <aspectratio>keep</aspectratio>
</control>
