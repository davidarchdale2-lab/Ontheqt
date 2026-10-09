{% extends "base.xml.tpl" %}
{# Plezy player settings sheet (edde746/plezy lib/widgets/video_controls/sheets/video_settings_sheet.dart): a bottom sheet
   over a 50% barrier with the "tune" glyph and a bold title, then one row per setting: icon, title, current value, chevron
   (72px rows, 12% focus fill). Shown over the video from the OSD (via.OSD) and over the detail screens (non_playback). The
   sheet hides while one of Kodi's own settings dialogs is open on top of it. List 100 and scrollbar 101 as before; Plezy has
   no scrollbars on TV, so 101 draws nothing. Python: lib/windows/playersettings.py. #}
{% block backgroundcolor %}{% endblock %}
{% block controls %}
{% with kvis = "!Window.IsVisible(sliderdialog) + !Window.IsVisible(osdvideosettings) + !Window.IsVisible(osdaudiosettings) + !Window.IsVisible(osdsubtitlesettings) + !Window.IsVisible(subtitlesearch) + !Window.IsActive(selectdialog) + !Window.IsVisible(osdcmssettings)" & svis = "String.IsEmpty(Window.Property(is_plextuary)) + !Window.IsVisible(sliderdialog) + !Window.IsVisible(osdvideosettings) + !Window.IsVisible(osdaudiosettings) + !Window.IsVisible(osdsubtitlesettings) + !Window.IsVisible(subtitlesearch) + !Window.IsActive(selectdialog) + !Window.IsVisible(osdcmssettings)" %}
{% include "includes/plezy_sheet.xml.tpl" with lid = 100 & rows = 9 & rh = 72 & hdr = "[B]$INFO[Window.Property(heading)][/B]" & hdr_icon = "script.plex/plezy/icons/tune.png" & vis = kvis & scrim_vis = svis %}
<control type="group">
    <visible>{{ kvis }}</visible>
    <animation effect="slide" start="0,{{ vscale(300) }}" end="0,0" time="250" tween="cubic" easing="out" condition="Integer.IsGreater(Container(100).NumItems,0)">Conditional</animation>
    <animation effect="fade" start="0" end="100" time="200" tween="cubic" easing="out" condition="Integer.IsGreater(Container(100).NumItems,0)">Conditional</animation>
    <animation effect="slide" start="0,0" end="0,{{ vscale(300) }}" time="200" tween="cubic" easing="in">WindowClose</animation>
    {% with lpy = 36 + 72 * 9 & lph = 72 * 9 %}
    <control type="list" id="100">
        <posx>435</posx>
        <posy>{{ lpy|vscale }}r</posy>
        <width>1050</width>
        <height>{{ lph|vscale }}</height>
        <onup>noop</onup>
        <ondown>noop</ondown>
        <onright>noop</onright>
        <scrolltime tween="cubic" easing="out">160</scrolltime>
        <orientation>vertical</orientation>
        <pagecontrol>101</pagecontrol>
        {% for r in range(1, 9) %}
        {% with sl = (9 - r) * 72 %}
        <animation effect="slide" end="0,{{ sl|vscale }}" time="0" condition="Integer.IsEqual(Container(100).NumItems,{{ r }})">Conditional</animation>
        {% endwith %}
        {% endfor %}
        <!-- ITEM LAYOUT ########################################## -->
        <itemlayout height="{{ vscale(72) }}">
            {% include "includes/plezy_player_setting_row.xml.tpl" %}
        </itemlayout>
        <focusedlayout height="{{ vscale(72) }}">
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>1050</width>
                <height>{{ vscale(72) }}</height>
                <texture colordiffuse="{{ core.plezy.focus_fill }}">script.plex/white-square.png</texture>
            </control>
            {% include "includes/plezy_player_setting_row.xml.tpl" with focused = True %}
        </focusedlayout>
    </control>
    {% endwith %}
</control>
<control type="scrollbar" id="101">
    <left>1490</left>
    <top>300</top>
    <width>6</width>
    <height>{{ vscale(648) }}</height>
    <onleft>100</onleft>
    <visible>true</visible>
    <texturesliderbackground>-</texturesliderbackground>
    <texturesliderbar>-</texturesliderbar>
    <texturesliderbarfocus>-</texturesliderbarfocus>
    <textureslidernib>-</textureslidernib>
    <textureslidernibfocus>-</textureslidernibfocus>
    <pulseonselect>false</pulseonselect>
    <orientation>vertical</orientation>
    <showonepage>false</showonepage>
</control>
{% endwith %}
{% endblock controls %}
