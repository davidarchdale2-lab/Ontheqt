{% extends "base.xml.tpl" %}
{% block headers %}
    <defaultcontrol>100</defaultcontrol>
    <zorder>101</zorder>{# above the seek dialog (zorder 100), whose bottom scrim would otherwise dim the strip #}
{% endblock %}
{% block controls %}
{#
  Plezy's TV queue strip (lib/widgets/video_controls/widgets/content_strip_panel.dart + content_strip.dart, queue
  tab), opened from the player's queue button over the seek dialog, whose timeline and buttons fade out meanwhile.
  x1.5 of Plezy's logical px: gradient panel (transparent -> black .65 at 42% -> .70), up chevron + "Queue" label,
  then a horizontal strip of 318-wide items with 296x167 thumbs; the playing item is outlined in white.
  LEFT/RIGHT move through the queue, UP closes it (PlaylistDialog.onAction).
#}
<control type="group">
    <control type="image">
        <posx>0</posx>
        <posy>{{ vscale(440) }}r</posy>
        <width>1920</width>
        <height>{{ vscale(440) }}</height>
        <texture>script.plex/plezy/scrim-strip.png</texture>
    </control>
    <control type="image">
        <posx>945</posx>
        <posy>{{ vscale(380) }}r</posy>
        <width>30</width>
        <height>{{ vscale(30) }}</height>
        <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/icons/keyboard_arrow_up.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <posx>0</posx>
        <posy>{{ vscale(344) }}r</posy>
        <width>1920</width>
        <height>{{ vscale(36) }}</height>
        <font>font10</font>
        <align>center</align>
        <aligny>center</aligny>
        <textcolor>{{ core.plezy.player_fg_muted }}</textcolor>
        <label>$ADDON[script.plezy.native 35160]</label>
    </control>

    <control type="group" id="100">
        <defaultcontrol>101</defaultcontrol>
        <posx>0</posx>
        <posy>{{ vscale(296) }}r</posy>
        <width>1920</width>
        <height>{{ vscale(250) }}</height>
        <control type="list" id="101">
            <posx>30</posx>
            <posy>0</posy>
            <width>1860</width>
            <height>{{ vscale(250) }}</height>
            <ondown>noop</ondown>
            <scrolltime tween="cubic" easing="out">150</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            <pagecontrol>152</pagecontrol>
            <itemlayout width="318" height="{{ vscale(250) }}">
                {% include "includes/seek_strip_item.xml.tpl" with focused=False & list_id=101 & current="playing" %}
            </itemlayout>
            <focusedlayout width="318" height="{{ vscale(250) }}">
                {% include "includes/seek_strip_item.xml.tpl" with focused=True & list_id=101 & current="playing" %}
            </focusedlayout>
        </control>

        <!-- kept for the list's pagecontrol and PlaylistDialog.onAction; the strip shows no scrollbar -->
        <control type="scrollbar" id="152">
            <visible>false</visible>
            <posx>30</posx>
            <posy>{{ vscale(246) }}</posy>
            <width>1860</width>
            <height>{{ vscale(4) }}</height>
            <texturesliderbackground colordiffuse="{{ core.plezy.player_track }}" border="2">script.plex/white-square-rounded.png</texturesliderbackground>
            <texturesliderbar colordiffuse="{{ core.plezy.player_fg_subtle }}" border="2">script.plex/white-square-rounded.png</texturesliderbar>
            <texturesliderbarfocus colordiffuse="{{ core.plezy.player_fg }}" border="2">script.plex/white-square-rounded.png</texturesliderbarfocus>
            <textureslidernib>-</textureslidernib>
            <textureslidernibfocus>-</textureslidernibfocus>
            <pulseonselect>false</pulseonselect>
            <orientation>horizontal</orientation>
            <showonepage>false</showonepage>
        </control>
    </control>
</control>
{% endblock controls %}
