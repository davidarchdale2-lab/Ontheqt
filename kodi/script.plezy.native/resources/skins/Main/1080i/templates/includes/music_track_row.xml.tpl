{# Plezy TrackRow as a Kodi list layout (edde746/plezy lib/widgets/music/track_row.dart), x1.5 of Plezy's 56dp row:
   an 84px grouped card (M3E: big outer corners on the first and last row of a group, small ones between; the
   shape comes from the item's group.pos = top|mid|bottom|single, mid when Python hasn't set it), a leading track
   number or the equalizer glyph of the playing track, a semi-bold title (bold while it plays, muted once played),
   an optional artist line, the duration and the more glyph. Focus is fill only (focus_fill in the card's shape).
   params: focused (bool), w (row width), fid (the list's control id), num (leading track-number slot),
     line2 (infolabel of the second line, e.g. "ListItem.Property(track.artist)"; none = title centred),
     played (mute rows the item's played property marks), more (draw the more column; the album list reaches it
     with RIGHT into hidden button 111, whose highlight is drawn here), hdr (disc header rows: label only)
   Rows are 87px apart (84 + Plezy's 3px group gap); the title column starts at x 78 with or without the number. #}
{% with tx = 78 & dur_x = w - 210 %}
<{% if focused %}focusedlayout{% else %}itemlayout{% endif %} height="{{ vscale(87) }}">
    <control type="group">
        <visible>String.IsEmpty(ListItem.Property(is.header))</visible>
        <!-- card -->
        <control type="image">
            <posx>0</posx>
            <posy>0</posy>
            <width>{{ w }}</width>
            <height>{{ vscale(84) }}</height>
            <texture border="20" colordiffuse="{{ core.plezy.surface }}" fallback="script.plex/plezy/group-mid.png">script.plex/plezy/group-$INFO[ListItem.Property(group.pos)].png</texture>
        </control>
        {% if focused %}
        <control type="image">
            <visible>Control.HasFocus({{ fid }})</visible>
            <posx>0</posx>
            <posy>0</posy>
            <width>{{ w }}</width>
            <height>{{ vscale(84) }}</height>
            <texture border="20" colordiffuse="{{ core.plezy.focus_fill }}" fallback="script.plex/plezy/group-mid.png">script.plex/plezy/group-$INFO[ListItem.Property(group.pos)].png</texture>
        </control>
        {% if more %}
        <control type="image">
            <visible>Control.HasFocus(111)</visible>
            <posx>0</posx>
            <posy>0</posy>
            <width>{{ w }}</width>
            <height>{{ vscale(84) }}</height>
            <texture border="20" colordiffuse="{{ core.plezy.selected_fill }}" fallback="script.plex/plezy/group-mid.png">script.plex/plezy/group-$INFO[ListItem.Property(group.pos)].png</texture>
        </control>
        {% endif %}
        {% endif %}
        {% if num %}
        <!-- leading slot: track number, or the playing track's equalizer (pulsing while Player.Playing) -->
        <control type="label">
            <visible>!String.IsEqual(ListItem.Property(track.ID),Window(10000).Property(script.plezy.native.track.ID))</visible>
            <posx>18</posx>
            <posy>0</posy>
            <width>48</width>
            <height>{{ vscale(84) }}</height>
            <font>font12</font>
            <align>center</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Property(track.number)]</label>
        </control>
        {% endif %}
        <control type="image">
            <visible>String.IsEqual(ListItem.Property(track.ID),Window(10000).Property(script.plezy.native.track.ID))</visible>
            <animation effect="fade" start="100" end="35" time="700" tween="sine" easing="inout" pulse="true" condition="Player.Playing">Conditional</animation>
            <posx>27</posx>
            <posy>{{ vscale(27) }}</posy>
            <width>30</width>
            <height>{{ vscale(30) }}</height>
            <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/equalizer.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <!-- title (+ second line) -->
        {% for is_cur in range(2) %}{% for is_played in range(2) %}
        {% if played or not is_played %}
        <control type="label">
            <visible>{% if is_cur %}String.IsEqual{% else %}!String.IsEqual{% endif %}(ListItem.Property(track.ID),Window(10000).Property(script.plezy.native.track.ID)){% if played %} + {% if is_played %}!{% endif %}String.IsEmpty(ListItem.Property(played)){% endif %}{% if line2 %} + String.IsEmpty({{ line2 }}){% endif %}</visible>
            <posx>{{ tx }}</posx>
            <posy>0</posy>
            <width>{{ dur_x - tx - 12 }}</width>
            <height>{{ vscale(84) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>{% if focused %}Control.HasFocus({{ fid }}){% else %}false{% endif %}</scroll>
            <textcolor>{% if played and is_played %}{{ core.plezy.muted }}{% else %}{{ core.plezy.text }}{% endif %}</textcolor>
            <label>{% if is_cur %}[B]$INFO[ListItem.Label][/B]{% else %}$INFO[ListItem.Label]{% endif %}</label>
        </control>
        {% if line2 %}
        <control type="label">
            <visible>{% if is_cur %}String.IsEqual{% else %}!String.IsEqual{% endif %}(ListItem.Property(track.ID),Window(10000).Property(script.plezy.native.track.ID)){% if played %} + {% if is_played %}!{% endif %}String.IsEmpty(ListItem.Property(played)){% endif %} + !String.IsEmpty({{ line2 }})</visible>
            <posx>{{ tx }}</posx>
            <posy>{{ vscale(10) }}</posy>
            <width>{{ dur_x - tx - 12 }}</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>{% if focused %}Control.HasFocus({{ fid }}){% else %}false{% endif %}</scroll>
            <textcolor>{% if played and is_played %}{{ core.plezy.muted }}{% else %}{{ core.plezy.text }}{% endif %}</textcolor>
            <label>{% if is_cur %}[B]$INFO[ListItem.Label][/B]{% else %}$INFO[ListItem.Label]{% endif %}</label>
        </control>
        {% endif %}
        {% endif %}
        {% endfor %}{% endfor %}
        {% if line2 %}
        <control type="label">
            <visible>!String.IsEmpty({{ line2 }})</visible>
            <posx>{{ tx }}</posx>
            <posy>{{ vscale(46) }}</posy>
            <width>{{ dur_x - tx - 12 }}</width>
            <height>{{ vscale(28) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[{{ line2 }}]</label>
        </control>
        {% endif %}
        <!-- duration, right-aligned before the more column -->
        <control type="label">
            <posx>{{ dur_x }}</posx>
            <posy>0</posy>
            <width>120</width>
            <height>{{ vscale(84) }}</height>
            <font>font10</font>
            <align>right</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Property(track.duration)]</label>
        </control>
        {% if more %}
        {% if focused %}
        <control type="image">
            <visible>Control.HasFocus(111)</visible>
            <posx>{{ w - 78 }}</posx>
            <posy>{{ vscale(6) }}</posy>
            <width>72</width>
            <height>{{ vscale(72) }}</height>
            <texture border="24" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/pill-48.png</texture>
        </control>
        {% endif %}
        <control type="image">
            <posx>{{ w - 57 }}</posx>
            <posy>{{ vscale(27) }}</posy>
            <width>30</width>
            <height>{{ vscale(30) }}</height>
            <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/more_vert.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        {% if focused %}
        <control type="image">
            <visible>Control.HasFocus(111)</visible>
            <posx>{{ w - 57 }}</posx>
            <posy>{{ vscale(27) }}</posy>
            <width>30</width>
            <height>{{ vscale(30) }}</height>
            <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/more_vert.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        {% endif %}
        {% endif %}
    </control>
    {% if hdr %}
    <!-- multi-disc header: no card, just 'Disc 2' sitting on the row pitch's lower half -->
    <control type="label">
        <visible>!String.IsEmpty(ListItem.Property(is.header))</visible>
        <posx>18</posx>
        <posy>{{ vscale(36) }}</posy>
        <width>600</width>
        <height>{{ vscale(48) }}</height>
        <font>font12</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>[B]$INFO[ListItem.Label][/B]</label>
    </control>
    {% endif %}
</{% if focused %}focusedlayout{% else %}itemlayout{% endif %}>
{% endwith %}
