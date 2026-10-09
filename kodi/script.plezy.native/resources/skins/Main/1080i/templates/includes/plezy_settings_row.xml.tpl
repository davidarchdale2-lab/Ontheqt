{# Row of a settings subpage (list 100), no leading icon: title, optional subtitle (the current value and/or the setting's
   description, composed by lib/windows/settings.py in ListItem.Property(subtitle)), then a switch for on/off settings, a
   chevron where a dialog or input opens, nothing for read-only info rows. Drawn over plezy_group_row (84px card).
   Reads ListItem.Label, Property(subtitle) / (checkbox) / (checkbox.checked) / (type). params: focused (labels scroll) #}
<control type="label">
    <visible>!String.IsEmpty(ListItem.Property(subtitle))</visible>
    <posx>24</posx>
    <posy>{{ vscale(8) }}</posy>
    <width>1554</width>
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
    <posx>24</posx>
    <posy>0</posy>
    <width>1554</width>
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
    <posx>24</posx>
    <posy>{{ vscale(44) }}</posy>
    <width>1554</width>
    <height>{{ vscale(32) }}</height>
    <font>font10</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>$INFO[ListItem.Property(subtitle)]</label>
</control>
<control type="group">
    <visible>!String.IsEmpty(ListItem.Property(checkbox))</visible>
    {% include "includes/plezy_switch.xml.tpl" with x = 1626 & y = 18 %}
</control>
<control type="image">
    <visible>String.IsEmpty(ListItem.Property(checkbox)) + !String.IsEqual(ListItem.Property(type),info)</visible>
    <posx>1668</posx>
    <posy>{{ vscale(24) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/chevron_right.png</texture>
    <aspectratio>keep</aspectratio>
</control>
