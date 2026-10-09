{% extends "default.xml.tpl" %}
{# Plezy playlist detail (edde746/plezy lib/screens/playlist/playlist_detail_screen.dart + playlist_item_card.dart), x1.5:
   the composite cover with the title, the item count / length line and the action row, over a column of item cards
   (a 96px square thumbnail for music, 171x96 for video). Once the list passes its fourth row the header scrolls away.
   Python (lib/windows/playlist.py PlaylistWindow) relies on: 101 (items), 300 (actions: 301 play, 302 shuffle,
   303 more), 100 (list group), 152 (scrollbar), 200-204 (header). Properties: playlist.thumb, playlist.title,
   playlist.meta; items: Label, Label2, Thumb, track.ID, track.number, track.duration, video, progress, watched,
   unwatched, index. #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block content %}
{% with scrolled = "Integer.IsGreater(Container(101).ListItem.Property(index),3) + !ControlGroup(300).HasFocus(0) + !ControlGroup(200).HasFocus(0)" %}
<control type="group" id="50">
    <defaultcontrol>101</defaultcontrol>
    <animation effect="slide" end="0,{{ vscale(-240) }}" time="200" tween="quadratic" easing="out" condition="{{ scrolled }}">Conditional</animation>
    <posx>0</posx>
    <posy>0</posy>

    <!-- HEADER -->
    <control type="group">
        <animation effect="fade" start="100" end="0" time="160" condition="{{ scrolled }}">Conditional</animation>
        <posx>0</posx>
        <posy>0</posy>
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>216</width>
            <height>{{ vscale(216) }}</height>
            <texture border="30" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r30.png</texture>
        </control>
        <control type="image">
            <posx>132</posx>
            <posy>{{ vscale(222) }}</posy>
            <width>72</width>
            <height>{{ vscale(72) }}</height>
            <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/icons/playlist_play.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>216</width>
            <height>{{ vscale(216) }}</height>
            <texture background="true" diffuse="script.plex/plezy/mask-cover-270.png">$INFO[Window.Property(playlist.thumb)]</texture>
            <aspectratio>scale</aspectratio>
        </control>
        <control type="label">
            <posx>312</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>1488</width>
            <height>{{ vscale(52) }}</height>
            <font>font32_title</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>$INFO[Window.Property(playlist.title)]</label>
        </control>
        <control type="label">
            <posx>312</posx>
            <posy>{{ vscale(206) }}</posy>
            <width>1488</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[Window.Property(playlist.meta)]</label>
        </control>
        {% block buttons %}
        <control type="grouplist" id="300">
            <defaultcontrol>301</defaultcontrol>
            <posx>312</posx>
            <posy>{{ vscale(310) }}</posy>
            <width>900</width>
            <height>{{ vscale(56) }}</height>
            <orientation>horizontal</orientation>
            <itemgap>10</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <onup>200</onup>
            <ondown>101</ondown>
            <onleft>noop</onleft>
            {% include "includes/plezy_action_button.xml.tpl" with id=301 & shape="label" & icon="play_arrow" & label="$LOCALIZE[208]" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=302 & icon="shuffle" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=303 & icon="more_vert" & visible="!String.IsEmpty(Window.Property(show.options)) | Player.HasAudio" %}
        </control>
        {% endblock %}
    </control>

    <!-- ITEMS -->
    <control type="group" id="100">
        <visible>Integer.IsGreater(Container(101).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>101</defaultcontrol>
        <posx>0</posx>
        <posy>{{ vscale(390) }}</posy>
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
            <onright>noop</onright>
            <scrolltime tween="cubic" easing="out">200</scrolltime>
            <orientation>vertical</orientation>
            <preloaditems>4</preloaditems>
            <pagecontrol>152</pagecontrol>
            {% include "includes/playlist_item_row.xml.tpl" with focused=False & w=1800 & fid=101 %}
            {% include "includes/playlist_item_row.xml.tpl" with focused=True & w=1800 & fid=101 %}
        </control>
    </control>
</control>

<control type="scrollbar" id="152">
    <visible>Integer.IsGreater(Container(101).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
    <animation effect="zoom" time="200" start="1872,{{ vscale(390) }},6,{{ vscale(690) }}" end="1872,{{ vscale(150) }},6,{{ vscale(930) }}" tween="quadratic" easing="out" condition="{{ scrolled }}">Conditional</animation>
    <left>1872</left>
    <top>{{ vscale(390) }}</top>
    <width>6</width>
    <height>{{ vscale(690) }}</height>
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
