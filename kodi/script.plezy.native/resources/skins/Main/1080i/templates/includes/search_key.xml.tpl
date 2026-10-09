{# One icon-only Plezy action key of the search keyboard (the TvVirtualKeyboard's delete / space / clear / search keys):
   a 124x64 button with a white r14 tile on focus and a centred icon (text colour idle, on_primary when focused).
   Goes inside the group at 120,744 of script-plex-search.xml.tpl.
   params: id, x (in the group), icon (texture), isize (icon size, default 40), onleft, onright, onup, results_right
   (True: onright is the results / history pair instead of a single id) #}
{% with s = isize|default(40) %}
<control type="button" id="{{ id }}">
    <posx>{{ x }}</posx>
    <posy>0</posy>
    <width>124</width>
    <height>{{ vscale(64) }}</height>
    <onleft>{{ onleft }}</onleft>
    {% if results_right %}
    <onright condition="!String.IsEmpty(Window.Property(show.history))">2050</onright>
    <onright condition="String.IsEmpty(Window.Property(show.history))">3000</onright>
    {% else %}
    <onright>{{ onright }}</onright>
    {% endif %}
    <onup>{{ onup }}</onup>
    <font>font14</font>
    <texturefocus border="14" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/r14.png</texturefocus>
    <texturenofocus>-</texturenofocus>
    <label> </label>
</control>
<control type="image">
    <visible>!Control.HasFocus({{ id }})</visible>
    <posx>{{ x + (124 - s) / 2 }}</posx>
    <posy>{{ ((64 - s) / 2)|vscale }}</posy>
    <width>{{ s }}</width>
    <height>{{ s|vscale }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">{{ icon }}</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>Control.HasFocus({{ id }})</visible>
    <posx>{{ x + (124 - s) / 2 }}</posx>
    <posy>{{ ((64 - s) / 2)|vscale }}</posy>
    <width>{{ s }}</width>
    <height>{{ s|vscale }}</height>
    <texture colordiffuse="{{ core.plezy.on_primary }}">{{ icon }}</texture>
    <aspectratio>keep</aspectratio>
</control>
{% endwith %}
