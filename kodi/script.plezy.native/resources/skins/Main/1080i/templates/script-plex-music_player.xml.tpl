{% extends "base.xml.tpl" %}
{# Plezy now playing (edde746/plezy lib/screens/music/now_playing_screen.dart _buildTvLayout), x1.5 of Plezy's unscaled
   geometry: the blurred cover over the dark background, the cover at the left (corners soften while paused) and the
   source line, title, artist, seek bar and transport in a column vertically centred next to it.
   Python (lib/windows/musicplayer.py + currentplaylist.py) relies on: 406 (play/pause, initial focus), 400 (transport
   grouplist: 401 repeat, 402 / 422 shuffle, 404 previous, 409 next), 407 (stop), 410 (queue, onclick Close), 411 (more),
   500 (seek button), 200 (seek selection image), 202 / 203 (time bubble). The seek numbers live in
   includes/music_seek.xml.tpl; musicplayer.py's SEEK_*/BAR_* constants mirror them. #}
{% block headers %}<defaultcontrol>406</defaultcontrol>{% endblock %}
{% block controls %}
{% include "includes/music_np_background.xml.tpl" %}

<!-- cover: 600px, radius 30 while playing / 42 while paused (cross-faded stand-in for Plezy's shape morph) -->
<control type="image">
    <visible>String.IsEmpty(Player.Art(thumb))</visible>
    <posx>157</posx>
    <posy>{{ vscale(240) }}</posy>
    <width>600</width>
    <height>{{ vscale(600) }}</height>
    <texture border="30" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r30.png</texture>
</control>
<control type="image">
    <visible>String.IsEmpty(Player.Art(thumb))</visible>
    <posx>397</posx>
    <posy>{{ vscale(480) }}</posy>
    <width>120</width>
    <height>{{ vscale(120) }}</height>
    <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/icons/music_note.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>!Player.Paused</visible>
    <animation effect="fade" time="350">VisibleChange</animation>
    <posx>157</posx>
    <posy>{{ vscale(240) }}</posy>
    <width>600</width>
    <height>{{ vscale(600) }}</height>
    <texture background="true" diffuse="script.plex/plezy/mask-np-600.png">$INFO[Player.Art(thumb)]</texture>
    <aspectratio>scale</aspectratio>
</control>
<control type="image">
    <visible>Player.Paused</visible>
    <animation effect="fade" time="350">VisibleChange</animation>
    <posx>157</posx>
    <posy>{{ vscale(240) }}</posy>
    <width>600</width>
    <height>{{ vscale(600) }}</height>
    <texture background="true" diffuse="script.plex/plezy/mask-np-600-paused.png">$INFO[Player.Art(thumb)]</texture>
    <aspectratio>scale</aspectratio>
</control>

<!-- info column -->
<control type="label">
    <posx>903</posx>
    <posy>{{ vscale(290) }}</posy>
    <width>800</width>
    <height>{{ vscale(72) }}</height>
    <font>font12</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>true</scroll>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <label>$INFO[MusicPlayer.Album]$INFO[MusicPlayer.Year, &#8226; ]</label>
</control>
<control type="group">
    <posx>1758</posx>
    <posy>{{ vscale(253) }}</posy>
    {% include "includes/music_button.xml.tpl" with bid=411 & asset="more" & onup="noop" & ondown="500" & onleft="noop" & onright="noop" %}
</control>
<control type="label">
    <posx>903</posx>
    <posy>{{ vscale(374) }}</posy>
    <width>933</width>
    <height>{{ vscale(64) }}</height>
    <font>font45</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>true</scroll>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>[B]$INFO[MusicPlayer.Title][/B]</label>
</control>
<control type="label">
    <posx>903</posx>
    <posy>{{ vscale(444) }}</posy>
    <width>933</width>
    <height>{{ vscale(44) }}</height>
    <font>font14</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>true</scroll>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <label>$INFO[MusicPlayer.Artist]</label>
</control>

{% include "includes/music_seek.xml.tpl" with x=903 & w=933 & y=518 & img=200 & onup=411 & ondown=400 %}

<!-- transport: shuffle, previous, play/pause, next, repeat -->
<control type="grouplist" id="400">
    <defaultcontrol>406</defaultcontrol>
    <posx>903</posx>
    <posy>{{ vscale(602) }}</posy>
    <width>933</width>
    <height>{{ vscale(145) }}</height>
    <align>center</align>
    <onup>500</onup>
    <ondown>450</ondown>
    <itemgap>0</itemgap>
    <orientation>horizontal</orientation>
    <scrolltime tween="quadratic" easing="out">200</scrolltime>
    <usecontrolcoords>true</usecontrolcoords>
    {% include "includes/music_player_buttons.xml.tpl" %}
</control>

<!-- queue and stop -->
<control type="grouplist" id="450">
    <posx>903</posx>
    <posy>{{ vscale(718) }}</posy>
    <width>933</width>
    <height>{{ vscale(145) }}</height>
    <align>center</align>
    <onup>400</onup>
    <itemgap>0</itemgap>
    <orientation>horizontal</orientation>
    <scrolltime tween="quadratic" easing="out">200</scrolltime>
    <usecontrolcoords>true</usecontrolcoords>
    {% include "includes/music_button.xml.tpl" with bid=410 & asset="pqueue" & onclick="Close" %}
    {% include "includes/music_button.xml.tpl" with bid=407 & asset="stop" & onclick="PlayerControl(Stop)" %}
</control>
{% endblock controls %}
