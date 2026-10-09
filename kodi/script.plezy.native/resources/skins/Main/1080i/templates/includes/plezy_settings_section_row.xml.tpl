{# Row of the settings root page (list 75): leading section icon, title, subtitle naming what is inside, trailing chevron.
   Drawn over plezy_group_row (84px card, x1.5 of Plezy's dense two-line ListTile). Reads ListItem.Label and the properties
   icon / subtitle set by lib/windows/settings.py. params: focused (labels scroll) #}
<control type="image">
    <posx>24</posx>
    <posy>{{ vscale(24) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">$INFO[ListItem.Property(icon)]</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="label">
    <visible>!String.IsEmpty(ListItem.Property(subtitle))</visible>
    <posx>84</posx>
    <posy>{{ vscale(8) }}</posy>
    <width>1560</width>
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
    <visible>String.IsEmpty(ListItem.Property(subtitle))</visible>
    <posx>84</posx>
    <posy>0</posy>
    <width>1560</width>
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
    <posx>84</posx>
    <posy>{{ vscale(44) }}</posy>
    <width>1560</width>
    <height>{{ vscale(32) }}</height>
    <font>font10</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>$INFO[ListItem.Property(subtitle)]</label>
</control>
<control type="image">
    <posx>1668</posx>
    <posy>{{ vscale(24) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/chevron_right.png</texture>
    <aspectratio>keep</aspectratio>
</control>
