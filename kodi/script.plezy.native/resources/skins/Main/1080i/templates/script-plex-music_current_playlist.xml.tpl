{% extends "base.xml.tpl" %}
{# Plezy queue (edde746/plezy lib/screens/music/now_playing_screen.dart _buildWideLayout + queue_sheet.dart), x1.5 of
   Plezy's unscaled geometry. Plezy's TV opens the queue as a sheet over now playing; this window carries its own
   transport and seek bar, so it uses the wide two-pane layout instead: the cover at the left, the title, artist, seek
   bar and transport at the top right, and the queue as grouped track cards in a panel below them.
   Python (lib/windows/currentplaylist.py) relies on: 101 (queue list), 152 (scrollbar), 400 (transport grouplist:
   401 repeat, 402 / 422 shuffle, 404 previous, 409 next, 406 play/pause), 407 (stop), 410 (close, handled in Python),
   411 (more), 500 (seek button), 510 (seek selection image), 202 / 203 (time bubble). The seek numbers live in
   includes/music_seek.xml.tpl; currentplaylist.py's SEEK_*/BAR_* constants mirror them. #}
{% block headers %}<defaultcontrol>101</defaultcontrol>{% endblock %}
{% block controls %}
{% include "includes/music_np_background.xml.tpl" %}

<control type="group" id="50">
<defaultcontrol>101</defaultcontrol>
<!-- top bar: close, album line, more -->
<control type="button" id="410">
    <posx>18</posx>
    <posy>{{ vscale(9) }}</posy>
    <width>72</width>
    <height>{{ vscale(72) }}</height>
    <onright>411</onright>
    <ondown>500</ondown>
    <onup>noop</onup>
    <onleft>noop</onleft>
    <font>font12</font>
    <texturefocus colordiffuse="{{ core.plezy.text }}">script.plex/plezy/circle.png</texturefocus>
    <texturenofocus>-</texturenofocus>
    <label> </label>
</control>
<control type="image">
    <visible>!Control.HasFocus(410)</visible>
    <posx>36</posx>
    <posy>{{ vscale(27) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/keyboard_arrow_down.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>Control.HasFocus(410)</visible>
    <posx>36</posx>
    <posy>{{ vscale(27) }}</posy>
    <width>36</width>
    <height>{{ vscale(36) }}</height>
    <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/keyboard_arrow_down.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="label">
    <posx>156</posx>
    <posy>{{ vscale(9) }}</posy>
    <width>1608</width>
    <height>{{ vscale(72) }}</height>
    <font>font10</font>
    <align>center</align>
    <aligny>center</aligny>
    <scroll>false</scroll>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <label>$INFO[Window.Property(np.from)]</label>
</control>
<control type="group">
    <posx>1758</posx>
    <posy>{{ vscale(-27) }}</posy>
    {% include "includes/music_button.xml.tpl" with bid=411 & asset="more" & onleft="410" & ondown="500" & onup="noop" & onright="noop" %}
</control>

<!-- cover: 688px, radius 30 while playing / 42 while paused -->
<control type="image">
    <visible>String.IsEmpty(Player.Art(thumb))</visible>
    <posx>97</posx>
    <posy>{{ vscale(226) }}</posy>
    <width>688</width>
    <height>{{ vscale(688) }}</height>
    <texture border="30" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r30.png</texture>
</control>
<control type="image">
    <visible>String.IsEmpty(Player.Art(thumb))</visible>
    <posx>381</posx>
    <posy>{{ vscale(510) }}</posy>
    <width>120</width>
    <height>{{ vscale(120) }}</height>
    <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/icons/music_note.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>!Player.Paused</visible>
    <animation effect="fade" time="350">VisibleChange</animation>
    <posx>97</posx>
    <posy>{{ vscale(226) }}</posy>
    <width>688</width>
    <height>{{ vscale(688) }}</height>
    <texture background="true" diffuse="script.plex/plezy/mask-np-688.png">$INFO[Player.Art(thumb)]</texture>
    <aspectratio>scale</aspectratio>
</control>
<control type="image">
    <visible>Player.Paused</visible>
    <animation effect="fade" time="350">VisibleChange</animation>
    <posx>97</posx>
    <posy>{{ vscale(226) }}</posy>
    <width>688</width>
    <height>{{ vscale(688) }}</height>
    <texture background="true" diffuse="script.plex/plezy/mask-np-688-paused.png">$INFO[Player.Art(thumb)]</texture>
    <aspectratio>scale</aspectratio>
</control>

<!-- title and artist -->
<control type="label">
    <posx>894</posx>
    <posy>{{ vscale(96) }}</posy>
    <width>990</width>
    <height>{{ vscale(56) }}</height>
    <font>font32_title</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>true</scroll>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>$INFO[MusicPlayer.Title]</label>
</control>
<control type="label">
    <posx>894</posx>
    <posy>{{ vscale(154) }}</posy>
    <width>990</width>
    <height>{{ vscale(40) }}</height>
    <font>font12</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>true</scroll>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <label>$INFO[MusicPlayer.Artist]</label>
</control>

{% include "includes/music_seek.xml.tpl" with x=894 & w=990 & y=200 & img=510 & onup=411 & ondown=400 %}

<!-- transport + stop (Plezy's right cluster) -->
<control type="grouplist" id="400">
    <defaultcontrol>406</defaultcontrol>
    <posx>894</posx>
    <posy>{{ vscale(288) }}</posy>
    <width>990</width>
    <height>{{ vscale(145) }}</height>
    <align>center</align>
    <onup>500</onup>
    <ondown>101</ondown>
    <onright>407</onright>
    <itemgap>0</itemgap>
    <orientation>horizontal</orientation>
    <scrolltime tween="quadratic" easing="out">200</scrolltime>
    <usecontrolcoords>true</usecontrolcoords>
    {% include "includes/music_player_buttons.xml.tpl" %}
</control>
<control type="group">
    <posx>1726</posx>
    <posy>{{ vscale(288) }}</posy>
    {% include "includes/music_button.xml.tpl" with bid=407 & asset="stop" & onclick="PlayerControl(Stop)" & onleft="400" & onup="500" & ondown="101" & onright="noop" %}
</control>

<!-- queue panel -->
<control type="group" id="100">
<defaultcontrol>101</defaultcontrol>
<control type="image">
    <posx>894</posx>
    <posy>{{ vscale(447) }}</posy>
    <width>990</width>
    <height>{{ vscale(603) }}</height>
    <texture border="30" colordiffuse="{{ core.plezy.tile }}">script.plex/plezy/r30.png</texture>
</control>
<control type="list" id="101">
    <posx>912</posx>
    <posy>{{ vscale(465) }}</posy>
    <width>954</width>
    <height>{{ vscale(567) }}</height>
    <onup>400</onup>
    <onleft>noop</onleft>
    <onright>noop</onright>
    <scrolltime tween="cubic" easing="out">200</scrolltime>
    <orientation>vertical</orientation>
    <preloaditems>4</preloaditems>
    <pagecontrol>152</pagecontrol>
    {% include "includes/music_track_row.xml.tpl" with focused=False & w=954 & fid=101 & line2="ListItem.Label2" & played=True %}
    {% include "includes/music_track_row.xml.tpl" with focused=True & w=954 & fid=101 & line2="ListItem.Label2" & played=True %}
</control>
<control type="scrollbar" id="152">
    <left>1872</left>
    <top>{{ vscale(465) }}</top>
    <width>6</width>
    <height>{{ vscale(567) }}</height>
    <onleft>101</onleft>
    <texturesliderbackground colordiffuse="{{ core.plezy.track }}" border="3">script.plex/plezy/r3.png</texturesliderbackground>
    <texturesliderbar colordiffuse="{{ core.plezy.faint }}" border="3">script.plex/plezy/r3.png</texturesliderbar>
    <texturesliderbarfocus colordiffuse="{{ core.plezy.text }}" border="3">script.plex/plezy/r3.png</texturesliderbarfocus>
    <textureslidernib>-</textureslidernib>
    <textureslidernibfocus>-</textureslidernibfocus>
    <pulseonselect>false</pulseonselect>
    <orientation>vertical</orientation>
    <showonepage>false</showonepage>
</control>
</control>
</control>
{% endblock controls %}
