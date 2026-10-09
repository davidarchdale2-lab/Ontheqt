{# Plezy M3 Switch (mono scheme) for list item layouts, drawn at x1.5: 78x48 stadium track, 36px / 24px thumb.
   ON  (ListItem.Property(checkbox.checked) set): track in text, thumb in on_primary at the right.
   OFF: no fill, a 3px outline just outside the track (Plezy draws a 2px outline in 12% white, which is nearly
        invisible on a TV, so the outline uses the track token) and a muted thumb at the left.
   params: x, y (track top-left; y unscaled, vscale is applied here) #}
<control type="group">
    <visible>!String.IsEmpty(ListItem.Property(checkbox.checked))</visible>
    <control type="image">
        <posx>{{ x }}</posx><posy>{{ y|vscale }}</posy><width>78</width><height>{{ vscale(48) }}</height>
        <texture border="24" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-48.png</texture>
    </control>
    <control type="image">
        <posx>{{ x + 36 }}</posx><posy>{{ (y + 6)|vscale }}</posy><width>36</width><height>{{ vscale(36) }}</height>
        <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/circle.png</texture>
    </control>
</control>
<control type="group">
    <visible>String.IsEmpty(ListItem.Property(checkbox.checked))</visible>
    <control type="image">
        <posx>{{ x - 3 }}</posx><posy>{{ (y - 3)|vscale }}</posy><width>84</width><height>{{ vscale(54) }}</height>
        <texture border="27" colordiffuse="{{ core.plezy.track }}">script.plex/plezy/ring-pill-48.png</texture>
    </control>
    <control type="image">
        <posx>{{ x + 12 }}</posx><posy>{{ (y + 12)|vscale }}</posy><width>24</width><height>{{ vscale(24) }}</height>
        <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/circle.png</texture>
    </control>
</control>
