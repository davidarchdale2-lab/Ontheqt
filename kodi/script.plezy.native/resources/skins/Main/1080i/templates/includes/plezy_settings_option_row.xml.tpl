{# Row of the settings selection dialog (list 125): a radio button (single choice) or a checkbox (multi choice) and the
   option's label, 60px rows, full dialog width. Properties from lib/windows/settings.py fillList: selected (single choice
   in use), option.multi (checkbox rows), checkbox.checked (multi choice ticked). params: focused (label scrolls) #}
<control type="image">
    <visible>String.IsEmpty(ListItem.Property(option.multi)) + !String.IsEmpty(ListItem.Property(selected))</visible>
    <posx>24</posx>
    <posy>{{ vscale(12) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/radio_button_checked.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>String.IsEmpty(ListItem.Property(option.multi)) + String.IsEmpty(ListItem.Property(selected))</visible>
    <posx>24</posx>
    <posy>{{ vscale(12) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/radio_button_unchecked.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(option.multi)) + !String.IsEmpty(ListItem.Property(checkbox.checked))</visible>
    <posx>24</posx>
    <posy>{{ vscale(12) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/check_box.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(option.multi)) + String.IsEmpty(ListItem.Property(checkbox.checked))</visible>
    <posx>24</posx>
    <posy>{{ vscale(12) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/check_box_outline_blank.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="label">
    <posx>84</posx>
    <posy>0</posy>
    <width>732</width>
    <height>{{ vscale(60) }}</height>
    <font>font12</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>$INFO[ListItem.Label]</label>
</control>
