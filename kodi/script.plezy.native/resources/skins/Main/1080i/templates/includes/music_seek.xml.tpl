{# Plezy now-playing seek bar (now_playing_screen.dart _buildSeekBar): a 6px track under a 78px pill that fills with
   focus_fill while the bar is focused. Drawn at x1.5. Shared by the now-playing and queue windows, whose Python
   (lib/windows/currentplaylist.py) positions the selection image and the time bubble from the same numbers:
   SEEK_IMAGE_WIDTH = w, BAR_X = x, BAR_RIGHT = x + w, BAR_Y = y, BAR_BOTTOM = y + 78, SELECTION_INDICATOR_Y = y - 32.
   params: x (track left), w (track width), y (pill top), img (id of the selection image: 200 now playing, 510 queue),
     onup, ondown (neighbours); 500 is the seek button, 202 / 203 the time bubble group + box.
   The selection image and the bubble sit in a group at x so Python's setPosition(x relative) lands on the track. #}
<control type="button" id="500">
    <enable>Player.HasAudio</enable>
    <posx>{{ x - 18 }}</posx>
    <posy>{{ y|vscale }}</posy>
    <width>{{ w + 36 }}</width>
    <height>{{ vscale(78) }}</height>
    <onup>{{ onup }}</onup>
    <ondown>{{ ondown }}</ondown>
    <onleft>noop</onleft>
    <onright>noop</onright>
    <font>font12</font>
    <texturefocus border="30" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/r30.png</texturefocus>
    <texturenofocus>-</texturenofocus>
    <label> </label>
</control>
<!-- track -->
<control type="image">
    <posx>{{ x }}</posx>
    <posy>{{ (y + 15)|vscale }}</posy>
    <width>{{ w }}</width>
    <height>{{ vscale(6) }}</height>
    <texture border="3" colordiffuse="{{ core.plezy.track }}">script.plex/plezy/r3.png</texture>
</control>
<control type="progress">
    <description>Progressbar</description>
    <posx>{{ x }}</posx>
    <posy>{{ (y + 15)|vscale }}</posy>
    <width>{{ w }}</width>
    <height>{{ vscale(6) }}</height>
    <texturebg>-</texturebg>
    <lefttexture>-</lefttexture>
    <midtexture border="3" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/r3.png</midtexture>
    <righttexture>-</righttexture>
    <overlaytexture>-</overlaytexture>
    <info>Player.Progress</info>
</control>
<!-- times under the track, inside the pill's padding -->
<control type="label">
    <posx>{{ x + 18 }}</posx>
    <posy>{{ (y + 27)|vscale }}</posy>
    <width>300</width>
    <height>{{ vscale(36) }}</height>
    <font>font10</font>
    <align>left</align>
    <aligny>center</aligny>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <label>$INFO[Player.Time]</label>
</control>
<control type="label">
    <posx>{{ x + w - 318 }}</posx>
    <posy>{{ (y + 27)|vscale }}</posy>
    <width>300</width>
    <height>{{ vscale(36) }}</height>
    <font>font10</font>
    <align>right</align>
    <aligny>center</aligny>
    <textcolor>{{ core.plezy.muted }}</textcolor>
    <label>$INFO[MusicPlayer.Duration]</label>
</control>
<!-- the position being sought: selection fill (Python sets its width) and the time bubble above it -->
<control type="group">
    <posx>{{ x }}</posx>
    <posy>0</posy>
    <control type="image" id="{{ img }}">
        <visible>Control.HasFocus(500)</visible>
        <animation effect="fade" time="100" delay="100" end="100">Visible</animation>
        <posx>0</posx>
        <posy>{{ (y + 15)|vscale }}</posy>
        <width>1</width>
        <height>{{ vscale(6) }}</height>
        <texture border="3" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/r3.png</texture>
    </control>
    <control type="group" id="202">
        <visible>Control.HasFocus(500) + !String.IsEmpty(Window.Property(time.selection))</visible>
        <posx>0</posx>
        <posy>{{ (y - 32)|vscale }}</posy>
        <control type="group" id="203">
            <posx>-50</posx>
            <posy>0</posy>
            <control type="image">
                <animation effect="fade" time="100" delay="100" end="100">Visible</animation>
                <posx>0</posx>
                <posy>0</posy>
                <width>101</width>
                <height>{{ vscale(39) }}</height>
                <texture border="12" colordiffuse="{{ core.plezy.menu_surface }}">script.plex/plezy/r12.png</texture>
            </control>
            <control type="label">
                <posx>0</posx>
                <posy>0</posy>
                <width>101</width>
                <height>{{ vscale(39) }}</height>
                <font>font10</font>
                <align>center</align>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <label>$INFO[Window.Property(time.selection)]</label>
            </control>
        </control>
        <control type="image">
            <animation effect="fade" time="100" delay="100" end="100">Visible</animation>
            <posx>-7</posx>
            <posy>{{ vscale(39) }}</posy>
            <width>15</width>
            <height>{{ vscale(7) }}</height>
            <texture colordiffuse="{{ core.plezy.menu_surface }}">script.plex/indicators/player-selection-time_arrow.png</texture>
        </control>
    </control>
</control>
