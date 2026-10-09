{# Plezy sign-in brand panel (edde746/plezy lib/screens/auth_screen.dart, TV layout: a centred 800 container, a brand column
   on the left and the auth body on the right). Solid Plezy bg, then a stand-in mark and the add-on's own title in the left
   column x 396..924. Plezy's logo artwork is NOT used (GPL-3 asset): the mark is a Material "play_arrow" in a rounded tile.
   Every sign-in window draws this (they are full windows, so the background window is not drawn beneath them).
   The content box is the 1920 x vscale(1080) design area, centred on the screen: pass nothing, the right column of each
   window uses the same `vperc(vscale(1080))` offset (0 on 16:9). #}
{% with brand = core.plezy.brand|default(core.plezy.active) %}
<control type="image">
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.bg }}">script.plex/white-square.png</texture>
</control>
<control type="group">
    <posx>0</posx>
    <posy>{{ vperc(vscale(1080)) }}</posy>
    <control type="image">
        <posx>570</posx>
        <posy>{{ vscale(402) }}</posy>
        <width>180</width>
        <height>{{ vscale(180) }}</height>
        <texture border="32" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r32.png</texture>
    </control>
    <control type="image">
        <posx>604</posx>
        <posy>{{ vscale(436) }}</posy>
        <width>112</width>
        <height>{{ vscale(112) }}</height>
        <texture colordiffuse="{{ brand }}">script.plex/plezy/icons/play_arrow.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <posx>396</posx>
        <posy>{{ vscale(618) }}</posy>
        <width>528</width>
        <height>{{ vscale(60) }}</height>
        <font>font45</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>[B]$ADDON[script.plezy.native 35050][/B]</label>
    </control>
</control>
{% endwith %}
