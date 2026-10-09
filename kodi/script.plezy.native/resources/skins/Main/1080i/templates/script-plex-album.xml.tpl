{% extends "default.xml.tpl" %}
{# Plezy album detail (edde746/plezy lib/screens/music/album_detail_screen.dart + widgets/music/music_detail_header.dart,
   widgets/music/track_row.dart), x1.5 of Plezy's unscaled geometry: a bottom-aligned header (270px cover with the
   artist link, album title, meta line and the action row) over the grouped track cards. Once the list passes its
   fifth row the header scrolls away and the list takes the full height, as in Plezy.
   Python (lib/windows/tracks.py AlbumWindow) relies on: 101 (tracks), 111 (a track's more column; hidden button the
   list reaches with RIGHT, Python moves the selection on UP/DOWN there), 200-204 (header), 300 (actions: 301 play,
   302 shuffle, 303 more), 305 (artist link), 100 (list group), 152 (scrollbar). #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block content %}
{% with scrolled = "Integer.IsGreater(Container(101).ListItem.Property(index),4) + !ControlGroup(300).HasFocus(0) + !Control.HasFocus(305) + !ControlGroup(200).HasFocus(0)" %}
<control type="group" id="50">
    <defaultcontrol>101</defaultcontrol>
    <animation effect="slide" end="0,{{ vscale(-282) }}" time="200" tween="quadratic" easing="out" condition="{{ scrolled }}">Conditional</animation>
    <posx>0</posx>
    <posy>0</posy>

    <!-- HEADER: cover, artist link, title, meta, action row; fades out as the list scrolls past it -->
    <control type="group">
        <animation effect="fade" start="100" end="0" time="160" condition="{{ scrolled }}">Conditional</animation>
        <posx>0</posx>
        <posy>0</posy>
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>270</width>
            <height>{{ vscale(270) }}</height>
            <texture border="30" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r30.png</texture>
        </control>
        <control type="image">
            <posx>147</posx>
            <posy>{{ vscale(237) }}</posy>
            <width>96</width>
            <height>{{ vscale(96) }}</height>
            <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/icons/album.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>270</width>
            <height>{{ vscale(270) }}</height>
            <texture background="true" diffuse="script.plex/plezy/mask-cover-270.png">$INFO[Window.Property(album.thumb)]</texture>
            <aspectratio>scale</aspectratio>
        </control>
        <control type="label">
            <posx>366</posx>
            <posy>{{ vscale(222) }}</posy>
            <width>1434</width>
            <height>{{ vscale(52) }}</height>
            <font>font32_title</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>$INFO[Window.Property(album.title)]</label>
        </control>
        <control type="label">
            <posx>366</posx>
            <posy>{{ vscale(318) }}</posy>
            <width>1434</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[Window.Property(album.meta)]</label>
        </control>
        <!-- artist link (Plezy: tappable artist line); focus = text fill behind the name -->
        <control type="button" id="305">
            <visible>!String.IsEmpty(Window.Property(artist.title))</visible>
            <posx>357</posx>
            <posy>{{ vscale(276) }}</posy>
            <width max="1000">auto</width>
            <height>{{ vscale(40) }}</height>
            <onup>200</onup>
            <ondown>301</ondown>
            <onleft>noop</onleft>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <textoffsetx>9</textoffsetx>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <focusedcolor>{{ core.plezy.text }}</focusedcolor>
            <texturefocus border="8" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/r8.png</texturefocus>
            <texturenofocus>-</texturenofocus>
            <label>$INFO[Window.Property(artist.title)]</label>
        </control>
        <!-- action row: Play (labelled), shuffle, more; unfocused siblings stay at full strength (Plezy dims them
             to 60% only in the music header, which Kodi's grouplist can't do per sibling) -->
        <control type="grouplist" id="300">
            <defaultcontrol>301</defaultcontrol>
            <posx>366</posx>
            <posy>{{ vscale(364) }}</posy>
            <width>900</width>
            <height>{{ vscale(56) }}</height>
            <orientation>horizontal</orientation>
            <itemgap>10</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <onup condition="!String.IsEmpty(Window.Property(artist.title))">305</onup>
            <onup>200</onup>
            <ondown>101</ondown>
            <onleft>noop</onleft>
            {% include "includes/plezy_action_button.xml.tpl" with id=301 & shape="label" & icon="play_arrow" & label="$LOCALIZE[208]" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=302 & icon="shuffle" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=303 & icon="more_vert" %}
        </control>
    </control>

    <!-- TRACK LIST: grouped cards, 87px pitch -->
    <control type="group" id="100">
        <visible>Integer.IsGreater(Container(101).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>101</defaultcontrol>
        <posx>0</posx>
        <posy>{{ vscale(432) }}</posy>
        <width>1920</width>
        <height>{{ vscale(930) }}</height>
        <control type="list" id="101">
            <hitrect x="60" y="0" w="1800" h="{{ vscale(930) }}" />
            <posx>60</posx>
            <posy>0</posy>
            <width>1800</width>
            <height>{{ vscale(930) }}</height>
            <onup>300</onup>
            <onleft>noop</onleft>
            <onright>111</onright>
            <scrolltime tween="cubic" easing="out">200</scrolltime>
            <orientation>vertical</orientation>
            <preloaditems>4</preloaditems>
            <pagecontrol>152</pagecontrol>
            {% include "includes/music_track_row.xml.tpl" with focused=False & w=1800 & fid=101 & num=True & line2="ListItem.Property(track.artist)" & more=True & hdr=True %}
            {% include "includes/music_track_row.xml.tpl" with focused=True & w=1800 & fid=101 & num=True & line2="ListItem.Property(track.artist)" & more=True & hdr=True %}
        </control>
        <!-- the more column of the selected track: Python moves the selection on UP/DOWN and opens the menu on select -->
        <control type="button" id="111">
            <posx>1782</posx>
            <posy>0</posy>
            <width>72</width>
            <height>{{ vscale(84) }}</height>
            <onleft>101</onleft>
            <onright>noop</onright>
            <onup>noop</onup>
            <ondown>noop</ondown>
            <font>font12</font>
            <texturefocus>-</texturefocus>
            <texturenofocus>-</texturenofocus>
            <label> </label>
        </control>
    </control>
</control>

<control type="scrollbar" id="152">
    <visible>Integer.IsGreater(Container(101).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
    <animation effect="zoom" time="200" start="1872,{{ vscale(432) }},6,{{ vscale(648) }}" end="1872,{{ vscale(150) }},6,{{ vscale(930) }}" tween="quadratic" easing="out" condition="{{ scrolled }}">Conditional</animation>
    <left>1872</left>
    <top>{{ vscale(432) }}</top>
    <width>6</width>
    <height>{{ vscale(648) }}</height>
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
{% endwith %}
{% endblock content %}
