{# Plezy now-playing transport (now_playing_screen.dart _buildTransport...), in Plezy's order: shuffle, previous, the big
   play/pause, next, repeat. Items of the caller's horizontal grouplist (id 400, align center, itemgap 0): every item is
   a fixed-pitch wrapper (see music_button.xml.tpl). Ids the Python relies on: 401 repeat, 402 shuffle (local playlists;
   422 inside wrapper 432 for remote play queues), 404 previous (424 = dimmed placeholder), 406 play/pause,
   409 next (419 = dimmed placeholder). 407 stop, 410 queue and 411 more are placed by the windows themselves. #}
{# shuffle: local playlists toggle Kodi's random mode, remote play queues ask the server (pq.shuffled) #}
{% include "includes/music_button.xml.tpl" with bid=402 & asset="shuffle" & vis="String.IsEmpty(Window.Property(pq.isremote))" & toggle="Playlist.IsRandom" & onclick="PlayerControl(RandomOn)" & altclick="PlayerControl(RandomOff)" %}
{% include "includes/music_button.xml.tpl" with gid=432 & bid=422 & asset="shuffle" & vis="!String.IsEmpty(Window.Property(pq.isremote))" & toggle="!String.IsEmpty(Window.Property(pq.shuffled))" %}
{# previous / next: the placeholders keep the row's spacing when there is no neighbour #}
{% include "includes/music_button.xml.tpl" with bid=404 & asset="next" & flip=True & vis="MusicPlayer.HasPrevious | !String.IsEmpty(Window.Property(pq.hasprev))" %}
{% include "includes/music_button.xml.tpl" with bid=424 & asset="next" & flip=True & disabled=True & vis="!MusicPlayer.HasPrevious + String.IsEmpty(Window.Property(pq.hasprev))" %}
{# play / pause: Plezy's filled button, a circle with the play glyph while paused and a rounded square with the
   pause glyph while playing (Kodi can't morph shapes: the two are cross-faded over 350ms); text fill, on_primary glyph #}
<control type="group">
    <width>{% if theme.assets.buttons.base == "script.plex/buttons/" %}140{% else %}120{% endif %}</width>
    <height>{{ vscale(145) }}</height>
    <control type="group">
        <animation effect="zoom" start="100" end="108" time="150" tween="cubic" easing="out" center="{% if theme.assets.buttons.base == "script.plex/buttons/" %}70{% else %}60{% endif %},{{ vscale(72.5) }}" reversible="true" condition="Control.HasFocus(406)">Conditional</animation>
        <posx>{% if theme.assets.buttons.base == "script.plex/buttons/" %}16{% else %}6{% endif %}</posx>
        <posy>0</posy>
        <width>108</width>
        <height>{{ vscale(145) }}</height>
        <control type="image">
            <visible>Control.HasFocus(406)</visible>
            <posx>-20</posx>
            <posy>{{ vscale(-2) }}</posy>
            <width>148</width>
            <height>{{ vscale(148) }}</height>
            <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/glow-circle.png</texture>
        </control>
        <control type="group">
            <visible>Player.Paused | Player.Forwarding | Player.Rewinding</visible>
            <animation effect="fade" time="350">VisibleChange</animation>
            <control type="image">
                <posx>0</posx>
                <posy>{{ vscale(18.5) }}</posy>
                <width>108</width>
                <height>{{ vscale(108) }}</height>
                <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/circle.png</texture>
            </control>
            <control type="image">
                <posx>27</posx>
                <posy>{{ vscale(45.5) }}</posy>
                <width>54</width>
                <height>{{ vscale(54) }}</height>
                <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/play_arrow.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
        </control>
        <control type="group">
            <visible>!Player.Paused + !Player.Forwarding + !Player.Rewinding</visible>
            <animation effect="fade" time="350">VisibleChange</animation>
            <control type="image">
                <posx>0</posx>
                <posy>{{ vscale(18.5) }}</posy>
                <width>108</width>
                <height>{{ vscale(108) }}</height>
                <texture border="30" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/r30.png</texture>
            </control>
            <control type="image">
                <posx>27</posx>
                <posy>{{ vscale(45.5) }}</posy>
                <width>54</width>
                <height>{{ vscale(54) }}</height>
                <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/pause.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
        </control>
    </control>
    <control type="button" id="406">
        <hitrect x="{% if theme.assets.buttons.base == "script.plex/buttons/" %}16{% else %}6{% endif %}" y="{{ vscale(18.5) }}" w="108" h="{{ vscale(108) }}" />
        <posx>0</posx>
        <posy>0</posy>
        <width>{% if theme.assets.buttons.base == "script.plex/buttons/" %}140{% else %}120{% endif %}</width>
        <height>{{ vscale(145) }}</height>
        <font>font12</font>
        <texturefocus>-</texturefocus>
        <texturenofocus>-</texturenofocus>
        <label> </label>
        <onclick>PlayerControl(Play)</onclick>
    </control>
</control>
{% include "includes/music_button.xml.tpl" with bid=409 & asset="next" & vis="MusicPlayer.HasNext | !String.IsEmpty(Window.Property(pq.hasnext))" %}
{% include "includes/music_button.xml.tpl" with bid=419 & asset="next" & disabled=True & vis="!MusicPlayer.HasNext + String.IsEmpty(Window.Property(pq.hasnext))" %}
{% include "includes/music_button.xml.tpl" with gid=421 & bid=401 & asset="repeat" & states=[("!Playlist.IsRepeatOne + !Playlist.IsRepeat + String.IsEmpty(Window.Property(pq.repeat))", "repeat", False), ("Playlist.IsRepeat | !String.IsEmpty(Window.Property(pq.repeat))", "repeat", True), ("Playlist.IsRepeatOne", "repeat-one", True)] %}
