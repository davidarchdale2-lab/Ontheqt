{% extends "default.xml.tpl" %}
{# Plezy playlists (edde746/plezy lib/screens/libraries/tabs/library_playlists_tab.dart + widgets/media_card.dart, playlist
   cards: square for music, 16:9 for video, "N items • duration" caption). Plezy shows one card grid; Kodi keeps its two
   TV rails styled like Plezy's rails: audio playlists as square cards, video playlists as wide cards, the one without focus
   dimmed. Python (lib/windows/playlists.py) relies on: 101 (audio list), 301 (video list), 100 / 300 (row groups), 200-204. #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block header_bgfade %}{% endblock %}
{% block topleft_add %}
<control type="label">
    <width max="500">auto</width>
    <height>{{ vscale(56) }}</height>
    <font>font14</font>
    <align>left</align>
    <aligny>center</aligny>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>[B]$ADDON[script.plezy.native 32333][/B]</label>
</control>
{% endblock %}
{% block content %}
<control type="group" id="50">
    <defaultcontrol always="true">101</defaultcontrol>
    <posx>0</posx>
    <posy>0</posy>

    <!-- AUDIO: square cards -->
    <control type="group" id="100">
        <visible>Integer.IsGreater(Container(101).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>101</defaultcontrol>
        <animation effect="fade" start="100" end="45" time="160" condition="Control.HasFocus(301)">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(150) }}</posy>
        <width>1920</width>
        <height>{{ vscale(372) }}</height>
        {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_playlist.png" & title="$ADDON[script.plezy.native 32048]" & x=60 & y=0 %}
        <control type="list" id="101">
            <posx>44</posx>
            <posy>{{ vscale(44) }}</posy>
            <width>1876</width>
            <height>{{ vscale(328) }}</height>
            <onup>200</onup>
            <ondown>301</ondown>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            {% include "includes/plezy_hub_card.xml.tpl" with kind="square" & focused=False & cw=240 & ch=240 & mask="script.plex/plezy/mask-grid-square.png" & cond="none" & focus_id=101 & hub_id=101 & sub_always=True %}
            {% include "includes/plezy_hub_card.xml.tpl" with kind="square" & focused=True & cw=240 & ch=240 & mask="script.plex/plezy/mask-grid-square.png" & cond="none" & focus_id=101 & hub_id=101 & sub_always=True %}
        </control>
    </control>

    <!-- VIDEO: wide cards; slides up into the audio row's place when there are no audio playlists -->
    <control type="group" id="300">
        <visible>Integer.IsGreater(Container(301).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>301</defaultcontrol>
        <animation effect="slide" end="0,{{ vscale(-420) }}" time="200" tween="quadratic" easing="out" condition="!Control.IsVisible(100)">Conditional</animation>
        <animation effect="fade" start="100" end="45" time="160" condition="Control.HasFocus(101)">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(570) }}</posy>
        <width>1920</width>
        <height>{{ vscale(341) }}</height>
        {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_playlist.png" & title="$ADDON[script.plezy.native 32053]" & x=60 & y=0 %}
        <control type="list" id="301">
            <posx>44</posx>
            <posy>{{ vscale(44) }}</posy>
            <width>1876</width>
            <height>{{ vscale(313) }}</height>
            <onup condition="Control.IsVisible(100)">101</onup>
            <onup>200</onup>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            {% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=False & cw=400 & ch=225 & mask="script.plex/plezy/mask-wide.png" & cond="none" & focus_id=301 & hub_id=301 & sub_always=True %}
            {% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=True & cw=400 & ch=225 & mask="script.plex/plezy/mask-wide.png" & cond="none" & focus_id=301 & hub_id=301 & sub_always=True %}
        </control>
    </control>
</control>
{% endblock content %}
