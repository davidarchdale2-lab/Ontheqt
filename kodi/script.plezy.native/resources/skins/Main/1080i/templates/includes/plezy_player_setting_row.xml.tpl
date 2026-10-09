{# Row of the player settings sheet (Plezy video_settings_sheet.dart _SettingsMenuItem, FocusableListTile) at x1.5, 72px:
   a muted leading icon, the title, the current value (muted, right aligned) and a muted chevron. Reads ListItem.Label,
   Label2 and Property(icon). params: focused (labels scroll) #}
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(icon))</visible>
    <posx>24</posx>
    <posy>{{ vscale(18) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.muted }}">$INFO[ListItem.Property(icon)]</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="label">
    <posx>84</posx>
    <posy>0</posy>
    <width>380</width>
    <height>{{ vscale(72) }}</height>
    <font>font12</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>$INFO[ListItem.Label]</label>
</control>
<control type="label">
    <posx>480</posx>
    <posy>0</posy>
    <width>480</width>
    <height>{{ vscale(72) }}</height>
    <font>font12</font>
    <align>right</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <label>$INFO[ListItem.Label2]</label>
</control>
<control type="image">
    <posx>990</posx>
    <posy>{{ vscale(18) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/chevron_right.png</texture>
    <aspectratio>keep</aspectratio>
</control>
