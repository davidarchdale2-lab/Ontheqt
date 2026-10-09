{# Plezy AppMenuItemTile (edde746/plezy lib/widgets/app_menu.dart) for the dropdown lists (id 250), 66px rows at x1.5.
   An inset radius-8 highlight sits in the row: focused = focus_fill, selected = selected_fill, both = selected_focus_fill,
   a row being moved gets selected_focus_fill plus a 3px ring (kept inside the row: lists clip to their bounds). Selected rows also draw their label bold. Labels are
   left-aligned (ListItem.Property(align) is ignored, as Plezy menus are). The trailing slots (27px, from the right)
   hold the submenu chevron (far right) and the PM4K indicator image mapped to a Plezy icon.
   Properties (set by lib/windows/dropdown.py): first / last / only, selected, slots (trailing icons: 0, 1 or 2),
   with.indicator, has.submenu, separator, moving; ListItem.Thumb carries the indicator image.
   params: w (row width), item_bg (draw the menu surface behind the row: the popup; the sheet draws it itself),
           focused (this is the focused layout), lid (list id, default 250) #}
{% with mw = w|default(300) & hid = lid|default(250) %}
{% if item_bg %}
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(first))</visible>
    <posx>0</posx><posy>0</posy><width>{{ mw }}</width><height>{{ vscale(66) }}</height>
    <texture border="12" colordiffuse="{{ core.plezy.menu_surface }}">script.plex/plezy/r12-top.png</texture>
</control>
<control type="image">
    <visible>String.IsEmpty(ListItem.Property(first)) + String.IsEmpty(ListItem.Property(last)) + String.IsEmpty(ListItem.Property(only))</visible>
    <posx>0</posx><posy>0</posy><width>{{ mw }}</width><height>{{ vscale(66) }}</height>
    <texture colordiffuse="{{ core.plezy.menu_surface }}">script.plex/white-square.png</texture>
</control>
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(last))</visible>
    <posx>0</posx><posy>0</posy><width>{{ mw }}</width><height>{{ vscale(66) }}</height>
    <texture border="12" colordiffuse="{{ core.plezy.menu_surface }}">script.plex/plezy/r12-bottom.png</texture>
</control>
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(only))</visible>
    <posx>0</posx><posy>0</posy><width>{{ mw }}</width><height>{{ vscale(66) }}</height>
    <texture border="12" colordiffuse="{{ core.plezy.menu_surface }}">script.plex/plezy/r12.png</texture>
</control>
{% endif %}
{# highlight: selected (10%), focused (12%), focused + selected (15%); never two fills stacked #}
{% if focused %}
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(selected)) + !Control.HasFocus({{ hid }})</visible>
    <posx>9</posx><posy>{{ vscale(2) }}</posy><width>{{ mw - 18 }}</width><height>{{ vscale(62) }}</height>
    <texture border="8" colordiffuse="{{ core.plezy.selected_fill }}">script.plex/plezy/r8.png</texture>
</control>
<control type="image">
    <visible>String.IsEmpty(ListItem.Property(selected)) + String.IsEmpty(ListItem.Property(moving)) + Control.HasFocus({{ hid }})</visible>
    <posx>9</posx><posy>{{ vscale(2) }}</posy><width>{{ mw - 18 }}</width><height>{{ vscale(62) }}</height>
    <texture border="8" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/r8.png</texture>
</control>
<control type="image">
    <visible>[!String.IsEmpty(ListItem.Property(selected)) + Control.HasFocus({{ hid }})] | !String.IsEmpty(ListItem.Property(moving))</visible>
    <posx>9</posx><posy>{{ vscale(2) }}</posy><width>{{ mw - 18 }}</width><height>{{ vscale(62) }}</height>
    <texture border="8" colordiffuse="{{ core.plezy.selected_focus_fill }}">script.plex/plezy/r8.png</texture>
</control>
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(moving))</visible>
    <posx>6</posx><posy>0</posy><width>{{ mw - 12 }}</width><height>{{ vscale(66) }}</height>
    <texture border="11" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-8.png</texture>
</control>
{% else %}
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(selected))</visible>
    <posx>9</posx><posy>{{ vscale(2) }}</posy><width>{{ mw - 18 }}</width><height>{{ vscale(62) }}</height>
    <texture border="8" colordiffuse="{{ core.plezy.selected_fill }}">script.plex/plezy/r8.png</texture>
</control>
{% endif %}
{# labels: three widths (0, 1 or 2 trailing slots) x regular / bold #}
{% for n in range(3) %}
<control type="label">
    <visible>{% if n == 0 %}!String.IsEqual(ListItem.Property(slots),1) + !String.IsEqual(ListItem.Property(slots),2){% else %}String.IsEqual(ListItem.Property(slots),{{ n }}){% endif %} + String.IsEmpty(ListItem.Property(selected))</visible>
    <posx>21</posx><posy>0</posy><width>{{ mw - 42 - 39 * n }}</width><height>{{ vscale(66) }}</height>
    <font>font12</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>$INFO[ListItem.Label]</label>
</control>
<control type="label">
    <visible>{% if n == 0 %}!String.IsEqual(ListItem.Property(slots),1) + !String.IsEqual(ListItem.Property(slots),2){% else %}String.IsEqual(ListItem.Property(slots),{{ n }}){% endif %} + !String.IsEmpty(ListItem.Property(selected))</visible>
    <posx>21</posx><posy>0</posy><width>{{ mw - 42 - 39 * n }}</width><height>{{ vscale(66) }}</height>
    <font>font12</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
    <scrollspeed>40</scrollspeed>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>[B]$INFO[ListItem.Label][/B]</label>
</control>
{% endfor %}
{# trailing slots: submenu chevron at the far right, the indicator right of it when both are present #}
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(has.submenu))</visible>
    <posx>{{ mw - 48 }}</posx><posy>{{ vscale(19) }}</posy><width>27</width><height>{{ vscale(27) }}</height>
    <texture colordiffuse="{% if focused %}{{ core.plezy.text }}{% else %}{{ core.plezy.muted }}{% endif %}">script.plex/plezy/icons/chevron_right.png</texture>
    <aspectratio>keep</aspectratio>
</control>
{% include "includes/plezy_menu_indicator.xml.tpl" with ix = mw - 48 & col = core.plezy.text & slot = "!String.IsEmpty(ListItem.Property(with.indicator)) + String.IsEmpty(ListItem.Property(has.submenu))" %}
{% include "includes/plezy_menu_indicator.xml.tpl" with ix = mw - 87 & col = core.plezy.text & slot = "!String.IsEmpty(ListItem.Property(with.indicator)) + !String.IsEmpty(ListItem.Property(has.submenu))" %}
<control type="image">
    <visible>!String.IsEmpty(ListItem.Property(separator))</visible>
    <posx>0</posx><posy>{{ vscale(64) }}</posy><width>{{ mw }}</width><height>{{ vscale(2) }}</height>
    <texture colordiffuse="{{ core.plezy.outline }}">script.plex/white-square.png</texture>
</control>
{% endwith %}
