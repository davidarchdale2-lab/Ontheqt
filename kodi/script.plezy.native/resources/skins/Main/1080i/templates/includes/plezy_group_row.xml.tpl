{# Plezy M3E grouped-list row card (edde746/plezy lib/widgets/settings_section.dart SettingsGroup): every row is its own
   surface card, large radii on the group's outer corners (first row top, last row bottom), small radii between rows.
   Focus is a 12% text fill clipped to the card: no ring, no scale (Plezy's ListTile focusColor).
   Draw it first inside a list item layout; the shape follows ListItem.Property(group.first) / (group.last), which the
   Python sets on the first and last visible row (lib/plezy_settings.group_flags). The item layout must be h + 3 tall
   (the 3px gap between cards).
   params: w (default 1728), h (default 84), focus_cond (Kodi condition under which the focus fill is drawn) #}
{% with gw = w|default(1728) & gh = h|default(84) %}
<control type="group">
    <visible>!String.IsEmpty(ListItem.Property(group.first)) + String.IsEmpty(ListItem.Property(group.last))</visible>
    <control type="image">
        <posx>0</posx><posy>0</posy><width>{{ gw }}</width><height>{{ gh|vscale }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/group-top.png</texture>
    </control>
    {% if focus_cond %}
    <control type="image">
        <visible>{{ focus_cond }}</visible>
        <posx>0</posx><posy>0</posy><width>{{ gw }}</width><height>{{ gh|vscale }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/group-top.png</texture>
    </control>
    {% endif %}
</control>
<control type="group">
    <visible>String.IsEmpty(ListItem.Property(group.first)) + String.IsEmpty(ListItem.Property(group.last))</visible>
    <control type="image">
        <posx>0</posx><posy>0</posy><width>{{ gw }}</width><height>{{ gh|vscale }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/group-mid.png</texture>
    </control>
    {% if focus_cond %}
    <control type="image">
        <visible>{{ focus_cond }}</visible>
        <posx>0</posx><posy>0</posy><width>{{ gw }}</width><height>{{ gh|vscale }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/group-mid.png</texture>
    </control>
    {% endif %}
</control>
<control type="group">
    <visible>String.IsEmpty(ListItem.Property(group.first)) + !String.IsEmpty(ListItem.Property(group.last))</visible>
    <control type="image">
        <posx>0</posx><posy>0</posy><width>{{ gw }}</width><height>{{ gh|vscale }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/group-bottom.png</texture>
    </control>
    {% if focus_cond %}
    <control type="image">
        <visible>{{ focus_cond }}</visible>
        <posx>0</posx><posy>0</posy><width>{{ gw }}</width><height>{{ gh|vscale }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/group-bottom.png</texture>
    </control>
    {% endif %}
</control>
<control type="group">
    <visible>!String.IsEmpty(ListItem.Property(group.first)) + !String.IsEmpty(ListItem.Property(group.last))</visible>
    <control type="image">
        <posx>0</posx><posy>0</posy><width>{{ gw }}</width><height>{{ gh|vscale }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/group-single.png</texture>
    </control>
    {% if focus_cond %}
    <control type="image">
        <visible>{{ focus_cond }}</visible>
        <posx>0</posx><posy>0</posy><width>{{ gw }}</width><height>{{ gh|vscale }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/group-single.png</texture>
    </control>
    {% endif %}
</control>
{% endwith %}
