{# Plezy filter chip (focusable_tab_chip.dart, TV colours): a 48px stadium toggle button. Idle = tonal fill with a
   regular label; focused = white fill with an on_primary label; selected = white fill with a bold on_primary label;
   selected and focused = the two blended (chip_selected_focus). Selection is the usealttexture condition, so the click
   handler only has to change the property it reads. Chips belong in a horizontal grouplist, which skips hidden ones.
   params: id, label (text or $ADDON[...]), width (Kodi's buttons are not content sized: pick one that fits the
   longest translation), selected (condition), visible (optional condition), height (optional, default 48) #}
<control type="togglebutton" id="{{ id }}">
    {% if visible %}<visible>{{ visible }}</visible>{% endif %}
    <width>{{ width }}</width>
    <height>{{ height|default(48)|vscale }}</height>
    <font>font12</font>
    <align>center</align>
    <aligny>center</aligny>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <focusedcolor>{{ core.plezy.on_primary }}</focusedcolor>
    <texturenofocus border="24" colordiffuse="{{ core.plezy.tonal }}">script.plex/plezy/pill-48.png</texturenofocus>
    <texturefocus border="24" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-48.png</texturefocus>
    <alttexturenofocus border="24" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-48.png</alttexturenofocus>
    <alttexturefocus border="24" colordiffuse="{{ core.plezy.chip_selected_focus }}">script.plex/plezy/pill-48.png</alttexturefocus>
    <usealttexture>{{ selected }}</usealttexture>
    <label>{{ label }}</label>
    <altlabel>[COLOR {{ core.plezy.on_primary }}][B]{{ label }}[/B][/COLOR]</altlabel>
</control>
