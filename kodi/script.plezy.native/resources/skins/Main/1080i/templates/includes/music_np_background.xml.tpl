{# Now-playing / queue backdrop (now_playing_screen.dart: the blurred cover at 22% under the dark background):
   Python sets np.background to a Plex-transcoded blurred cover (lib/windows/currentplaylist.py setNowPlayingBackground);
   until then, or on servers that can't blur, the plain cover at 22% stands in. #}
<control type="image">
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.bg }}">script.plex/white-square.png</texture>
</control>
<control type="image">
    <visible>!String.IsEmpty(Window.Property(np.background))</visible>
    <animation effect="fade" start="0" end="100" time="400">Visible</animation>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <fadetime>400</fadetime>
    <texture background="true">$INFO[Window.Property(np.background)]</texture>
    <aspectratio>scale</aspectratio>
</control>
<control type="image">
    <visible>String.IsEmpty(Window.Property(np.background))</visible>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture background="true" colordiffuse="38FFFFFF">$INFO[Player.Art(thumb)]</texture>
    <aspectratio>scale</aspectratio>
</control>
