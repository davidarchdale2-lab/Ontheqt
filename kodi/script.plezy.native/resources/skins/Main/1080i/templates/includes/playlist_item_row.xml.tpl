{# Plezy PlaylistItemCard (edde746/plezy lib/screens/playlist/playlist_item_card.dart) as a list layout, x1.5: a 120px
   surface card with the item's thumbnail at its left (96px square for music, 171x96 wide for video, with the progress
   bar inset at its foot and the watched mark), the title, a muted second line, the duration at the right and the
   equalizer glyph before the playing track's title. Focus is a ring around the card, no zoom (Plezy: 2.5px primary
   border, radius 12). 132px pitch (card + 12px gap).
   params: focused (bool), w (row width), fid (list control id) #}
{% with dur_x = w - 216 %}
<{% if focused %}focusedlayout{% else %}itemlayout{% endif %} height="{{ vscale(132) }}">
    <control type="group">
        <posx>0</posx>
        <posy>{{ vscale(3) }}</posy>
        <control type="image">
            <posx>0</posx>
            <posy>0</posy>
            <width>{{ w }}</width>
            <height>{{ vscale(120) }}</height>
            <texture border="12" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r12.png</texture>
        </control>
        {% for is_video in range(2) %}
        {% with tx = 126 + is_video * 75 %}
        <control type="group">
            <visible>{% if is_video %}!{% endif %}String.IsEmpty(ListItem.Property(video)) + !String.IsEmpty(ListItem.Label)</visible>
            <!-- thumbnail -->
            <control type="image">
                <posx>12</posx>
                <posy>{{ vscale(12) }}</posy>
                <width>{% if is_video %}171{% else %}96{% endif %}</width>
                <height>{{ vscale(96) }}</height>
                <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/mask-row-{% if is_video %}wide{% else %}square{% endif %}.png</texture>
            </control>
            <control type="image">
                <posx>12</posx>
                <posy>{{ vscale(12) }}</posy>
                <width>{% if is_video %}171{% else %}96{% endif %}</width>
                <height>{{ vscale(96) }}</height>
                <texture background="true" diffuse="script.plex/plezy/mask-row-{% if is_video %}wide{% else %}square{% endif %}.png">$INFO[ListItem.Thumb]</texture>
                <aspectratio>scale</aspectratio>
            </control>
            {% if is_video %}
            <control type="group">
                <visible>!String.IsEmpty(ListItem.Property(progress))</visible>
                <posx>22</posx>
                <posy>{{ vscale(97) }}</posy>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>151</width>
                    <height>{{ vscale(5) }}</height>
                    <texture colordiffuse="99000000">script.plex/white-square.png</texture>
                </control>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>151</width>
                    <height>{{ vscale(5) }}</height>
                    <texture colordiffuse="{{ core.plezy.text }}">$INFO[ListItem.Property(progress)]</texture>
                </control>
            </control>
            {% include "includes/watched_indicator.xml.tpl" with xoff=183 & yoff=12 & uw_size=32 & with_count=False & scale="small" %}
            {% endif %}
            <!-- playing track: equalizer glyph, then the title shifts right -->
            <control type="image">
                <visible>!String.IsEmpty(ListItem.Property(track.ID)) + String.IsEqual(ListItem.Property(track.ID),Window(10000).Property(script.plezy.native.track.ID))</visible>
                <animation effect="fade" start="100" end="35" time="700" tween="sine" easing="inout" pulse="true" condition="Player.Playing">Conditional</animation>
                <posx>{{ tx }}</posx>
                <posy>{{ vscale(24) }}</posy>
                <width>30</width>
                <height>{{ vscale(30) }}</height>
                <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/equalizer.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
            {% for is_cur in range(2) %}
            <control type="label">
                <visible>{% if is_cur %}!String.IsEmpty(ListItem.Property(track.ID)) + String.IsEqual{% else %}String.IsEmpty(ListItem.Property(track.ID)) | !String.IsEqual{% endif %}(ListItem.Property(track.ID),Window(10000).Property(script.plezy.native.track.ID))</visible>
                <posx>{% if is_cur %}{{ tx + 40 }}{% else %}{{ tx }}{% endif %}</posx>
                <posy>{{ vscale(18) }}</posy>
                <width>{% if is_cur %}{{ dur_x - tx - 52 }}{% else %}{{ dur_x - tx - 12 }}{% endif %}</width>
                <height>{{ vscale(40) }}</height>
                <font>font13</font>
                <align>left</align>
                <aligny>center</aligny>
                <scroll>{% if focused %}Control.HasFocus({{ fid }}){% else %}false{% endif %}</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <label>{% if is_cur %}[B]$INFO[ListItem.Label][/B]{% else %}$INFO[ListItem.Label]{% endif %}</label>
            </control>
            {% endfor %}
            <control type="label">
                <posx>{{ tx }}</posx>
                <posy>{{ vscale(62) }}</posy>
                <width>{{ dur_x - tx - 12 }}</width>
                <height>{{ vscale(34) }}</height>
                <font>font10</font>
                <align>left</align>
                <aligny>center</aligny>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <label>$INFO[ListItem.Label2]</label>
            </control>
        </control>
        {% endwith %}
        {% endfor %}
        <control type="label">
            <posx>{{ dur_x }}</posx>
            <posy>0</posy>
            <width>120</width>
            <height>{{ vscale(120) }}</height>
            <font>font10</font>
            <align>right</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Property(track.duration)]</label>
        </control>
        {% if focused %}
        <control type="image">
            <visible>Control.HasFocus({{ fid }})</visible>
            <posx>-3</posx>
            <posy>{{ vscale(-3) }}</posy>
            <width>{{ w + 6 }}</width>
            <height>{{ vscale(126) }}</height>
            <texture border="15" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-12.png</texture>
        </control>
        {% endif %}
    </control>
</{% if focused %}focusedlayout{% else %}itemlayout{% endif %}>
{% endwith %}
