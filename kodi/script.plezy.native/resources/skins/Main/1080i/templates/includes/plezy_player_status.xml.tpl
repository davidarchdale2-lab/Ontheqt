{# "Now playing" chip of the add-on's header (control 204: opens the audio player), restyled for the Plezy pages:
   a thumbnail, artist and title, a hairline progress bar, and a 12% fill on focus instead of PM4K's white inversion.
   Hidden unless music plays. Pages without the default header (settings, info) place it at the top right.
   params: x (left edge of the chip), onleft, onright, onup, ondown (navigation targets of button 204) #}
<control type="group">
    <visible>Player.HasAudio + String.IsEmpty(Window(10000).Property(script.plezy.native.theme_playing))</visible>
    <posx>{{ x }}</posx>
    <posy>0</posy>
    <control type="button" id="204">
        <visible>Player.HasAudio + String.IsEmpty(Window(10000).Property(script.plezy.native.theme_playing))</visible>
        <posx>-10</posx>
        <posy>{{ vscale(9) }}</posy>
        <width>260</width>
        <height>{{ vscale(66) }}</height>
        {% if onleft %}<onleft>{{ onleft }}</onleft>{% endif %}
        {% if onright %}<onright>{{ onright }}</onright>{% endif %}
        {% if onup %}<onup>{{ onup }}</onup>{% endif %}
        {% if ondown %}<ondown>{{ ondown }}</ondown>{% endif %}
        <font>font10</font>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <focusedcolor>{{ core.plezy.text }}</focusedcolor>
        <texturefocus border="12" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/r12.png</texturefocus>
        <texturenofocus>-</texturenofocus>
        <label> </label>
    </control>
    <control type="image">
        <posx>0</posx>
        <posy>{{ vscale(21) }}</posy>
        <width>42</width>
        <height>{{ vscale(42) }}</height>
        <texture>$INFO[Player.Art(thumb)]</texture>
    </control>
    <control type="label">
        <posx>53</posx>
        <posy>{{ vscale(21) }}</posy>
        <width>187</width>
        <height>{{ vscale(22) }}</height>
        <font>font10</font>
        <align>left</align>
        <aligny>center</aligny>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <info>MusicPlayer.Artist</info>
    </control>
    <control type="label">
        <posx>53</posx>
        <posy>{{ vscale(45) }}</posy>
        <width>187</width>
        <height>{{ vscale(22) }}</height>
        <font>font10</font>
        <align>left</align>
        <aligny>center</aligny>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <info>MusicPlayer.Title</info>
    </control>
    <control type="progress">
        <description>Progressbar</description>
        <posx>0</posx>
        <posy>{{ vscale(72) }}</posy>
        <width>240</width>
        <height>{{ vscale(2) }}</height>
        <texturebg colordiffuse="{{ core.plezy.track }}">script.plex/white-square-1px.png</texturebg>
        <lefttexture>-</lefttexture>
        <midtexture colordiffuse="{{ core.plezy.text }}">script.plex/white-square-1px.png</midtexture>
        <righttexture>-</righttexture>
        <overlaytexture>-</overlaytexture>
        <info>Player.Progress</info>
    </control>
</control>
