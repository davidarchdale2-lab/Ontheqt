{% extends "default.xml.tpl" %}
{# Plezy artist detail (edde746/plezy lib/screens/music/artist_detail_screen.dart + widgets/music/music_detail_header.dart),
   x1.5 of Plezy's unscaled geometry: a round portrait with the name, genres, a three-line bio and the action row, then
   the albums and similar artists as rails of square cards. While a rail has focus the header scrolls away (the albums row
   leaves, the similar-artists row takes its place), as in Plezy.
   Python (lib/windows/subitems.py ArtistWindow, which inherits ShowWindow) relies on: 50 (content), 200-204 (header),
   300 (actions: 301 info, 302 play, 303 shuffle, 304 more), 400 (albums), 401 (similar artists, paginated: boundary
   tiles), 100 / 500 (row groups), hub.focus / on.extras (set on focus). Properties: summary, thumb, related.header,
   artist.title, artist.genre; album items carry Property(year). #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{# the back / search buttons stay over the artwork at all times, as in Plezy #}
{% block header_anim %}{% endblock %}
{% block header_bgfade %}{% endblock %}
{% block content %}
<control type="group" id="50">
    <defaultcontrol>400</defaultcontrol>
    <animation effect="slide" end="0,{{ vscale(-432) }}" time="200" tween="quadratic" easing="out" condition="Integer.IsGreater(Window.Property(hub.focus),0) + Control.IsVisible(500)">Conditional</animation>
    <posx>0</posx>
    <posy>0</posy>

    <!-- HEADER: portrait, name, genres, bio, actions -->
    <control type="group">
        <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),0)">Conditional</animation>
        <posx>0</posx>
        <posy>0</posy>
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(176) }}</posy>
            <width>270</width>
            <height>{{ vscale(270) }}</height>
            <texture colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/circle.png</texture>
        </control>
        <control type="image">
            <posx>147</posx>
            <posy>{{ vscale(263) }}</posy>
            <width>96</width>
            <height>{{ vscale(96) }}</height>
            <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/icons/artist.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(176) }}</posy>
            <width>270</width>
            <height>{{ vscale(270) }}</height>
            <texture background="true" diffuse="script.plex/masks/role.png">$INFO[Window.Property(thumb)]</texture>
            <aspectratio>scale</aspectratio>
        </control>
        <control type="label">
            <posx>366</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>1434</width>
            <height>{{ vscale(52) }}</height>
            <font>font32_title</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>$INFO[Window.Property(artist.title)]</label>
        </control>
        <control type="label">
            <posx>366</posx>
            <posy>{{ vscale(208) }}</posy>
            <width>1434</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[Window.Property(artist.genre)]</label>
        </control>
        <control type="textbox">
            <posx>366</posx>
            <posy>{{ vscale(256) }}</posy>
            <width>1080</width>
            <height>{{ vscale(114) }}</height>
            <font>font12</font>
            <align>left</align>
            <textcolor>{{ core.plezy.summary }}</textcolor>
            <autoscroll>false</autoscroll>
            <label>$INFO[Window.Property(summary)]</label>
        </control>
        <control type="grouplist" id="300">
            <defaultcontrol>302</defaultcontrol>
            <posx>366</posx>
            <posy>{{ vscale(388) }}</posy>
            <width>900</width>
            <height>{{ vscale(56) }}</height>
            <orientation>horizontal</orientation>
            <itemgap>10</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <onup>200</onup>
            <ondown>400</ondown>
            <onleft>noop</onleft>
            {% include "includes/plezy_action_button.xml.tpl" with id=302 & shape="label" & icon="play_arrow" & label="$LOCALIZE[208]" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=303 & icon="shuffle" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=301 & icon="info" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=304 & icon="more_vert" %}
        </control>
    </control>

    <!-- ALBUMS (newest first when Python sorts that way) -->
    <control type="group" id="100">
        <visible>Integer.IsGreater(Container(400).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>400</defaultcontrol>
        <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),0)">Conditional</animation>
        <animation effect="fade" start="100" end="70" time="160" condition="!Control.HasFocus(400) + !Integer.IsGreater(Window.Property(hub.focus),0)">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(505) }}</posy>
        <width>1920</width>
        <height>{{ vscale(372) }}</height>
        {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/album.png" & title="$ADDON[script.plezy.native 32461]" & x=60 & y=0 %}
        <control type="list" id="400">
            <posx>44</posx>
            <posy>{{ vscale(44) }}</posy>
            <width>1876</width>
            <height>{{ vscale(328) }}</height>
            <onup>300</onup>
            <ondown>401</ondown>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            {% include "includes/music_card.xml.tpl" with kind="square" & focused=False & cw=240 & ch=240 & mask="script.plex/plezy/mask-grid-square.png" & fid=400 & line2="ListItem.Property(year)" %}
            {% include "includes/music_card.xml.tpl" with kind="square" & focused=True & cw=240 & ch=240 & mask="script.plex/plezy/mask-grid-square.png" & fid=400 & line2="ListItem.Property(year)" %}
        </control>
    </control>

    <!-- SIMILAR ARTISTS (paginated by the add-on: boundary tiles carry the next page) -->
    <control type="group" id="500">
        <visible>Integer.IsGreater(Container(401).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>401</defaultcontrol>
        <animation effect="fade" start="100" end="45" time="160" condition="!Control.HasFocus(401)">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(937) }}</posy>
        <width>1920</width>
        <height>{{ vscale(372) }}</height>
        {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/artist.png" & title="$INFO[Window.Property(related.header)]" & x=60 & y=0 %}
        <control type="list" id="401">
            <posx>44</posx>
            <posy>{{ vscale(44) }}</posy>
            <width>1876</width>
            <height>{{ vscale(328) }}</height>
            <onup>400</onup>
            <ondown>noop</ondown>
            <onleft>noop</onleft>
            <onright>noop</onright>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            {% include "includes/music_card.xml.tpl" with kind="square" & focused=False & cw=240 & ch=240 & mask="script.plex/plezy/mask-grid-square.png" & fid=401 %}
            {% include "includes/music_card.xml.tpl" with kind="square" & focused=True & cw=240 & ch=240 & mask="script.plex/plezy/mask-grid-square.png" & fid=401 %}
        </control>
    </control>
</control>
{% endblock content %}
