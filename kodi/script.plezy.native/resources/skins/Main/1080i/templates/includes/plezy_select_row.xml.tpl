{# Row of the Plezy selection sheet (settings_select_dialog): title, optional muted subtitle, trailing check.
   Reads ListItem.Label / Label2 and ListItem.Property(selected). params: focused (labels scroll) #}
<control type="label">
    <visible>String.IsEmpty(ListItem.Label2)</visible>
    <posx>24</posx>
    <posy>0</posy>
    <width>930</width>
    <height>{{ vscale(84) }}</height>
    <font>font12</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>$INFO[ListItem.Label]</label>
</control>
<control type="label">
    <visible>!String.IsEmpty(ListItem.Label2)</visible>
    <posx>24</posx>
    <posy>{{ vscale(10) }}</posy>
    <width>930</width>
    <height>{{ vscale(36) }}</height>
    <font>font12</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>$INFO[ListItem.Label]</label>
</control>
<control type="label">
    <visible>!String.IsEmpty(ListItem.Label2)</visible>
    <posx>24</posx>
    <posy>{{ vscale(46) }}</posy>
    <width>930</width>
    <height>{{ vscale(30) }}</height>
    <font>font10</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <label>$INFO[ListItem.Label2]</label>
</control>
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(selected))</visible>
    <posx>990</posx>
    <posy>{{ vscale(24) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/check.png</texture>
    <aspectratio>keep</aspectratio>
</control>
