{% extends "base.xml.tpl" %}
{# Plezy menu sheet (edde746/plezy lib/widgets/app_menu.dart AppMenuSheet inside an OverlaySheet): a 50% sheet_scrim over
   the screen and a radius-16 surface sheet holding a bold title and the menu rows (66px, no per-row background). Used for
   every dropdown with a header (choose version, manage hubs, library actions, playback settings...). The Python
   (lib/windows/dropdown.py DropdownHeaderDialog) positions group 100, sizes list 250, scrollbar 1152 and the sheet 111. #}
{% block backgroundcolor %}{% endblock %}
{% block headers %}
<onload>SetProperty(dropdown,1)</onload>
<defaultcontrol>100</defaultcontrol>
{% endblock %}
{% block controls %}
<control type="button" id="700">
    <!-- dummy for clicks off list; its idle art is the sheet barrier -->
    <animation effect="fade" start="0" end="100" time="250" tween="cubic" easing="out">WindowOpen</animation>
    <animation effect="fade" start="100" end="0" time="200" tween="cubic" easing="in">WindowClose</animation>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texturefocus colordiffuse="{{ core.plezy.sheet_scrim }}">script.plex/white-square.png</texturefocus>
    <texturenofocus colordiffuse="{{ core.plezy.sheet_scrim }}">script.plex/white-square.png</texturenofocus>
</control>
<control type="group" id="100">
    <defaultcontrol>250</defaultcontrol>
    <visible>!String.IsEmpty(Window.Property(show))</visible>
    <animation effect="slide" start="0,{{ vscale(60) }}" end="0,0" time="250" tween="cubic" easing="out">Visible</animation>
    <animation effect="fade" start="0" end="100" time="200" tween="cubic" easing="out">Visible</animation>
    <animation effect="slide" start="0,0" end="0,{{ vscale(60) }}" time="200" tween="cubic" easing="in">WindowClose</animation>
    <animation effect="fade" start="100" end="0" time="200" tween="cubic" easing="in">WindowClose</animation>
    <posx>0</posx>
    <posy>0</posy>
    <control type="image" id="110">
        <posx>-60</posx>
        <posy>{{ vscale(-106) }}</posy>
        <width>720</width>
        <height>{{ vscale(146) }}</height>
        <texture>-</texture>
    </control>
    <control type="group">
        <visible>!String.IsEmpty(Window.Property(header))</visible>
        <posx>-20</posx>
        <posy>{{ vscale(-66) }}</posy>
        <control type="image" id="111">
            <posx>0</posx>
            <posy>0</posy>
            <width>640</width>
            <height>{{ vscale(132) }}</height>
            <texture border="16" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r16.png</texture>
        </control>
        <control type="label">
            <posx>41</posx>
            <posy>0</posy>
            <width>560</width>
            <height>{{ vscale(66) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>true</scroll>
            <scrollspeed>40</scrollspeed>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[Window.Property(header)][/B]</label>
        </control>
    </control>
    <control type="list" id="250">
        <posx>0</posx>
        <posy>0</posy>
        <width>600</width>
        <height>{{ vscale(528) }}</height>
        <onup condition="String.IsEqual(Window.Property(close.direction),top)">Close</onup>
        <onup condition="!String.IsEqual(Window.Property(close.direction),top)">noop</onup>
        <onleft condition="String.IsEqual(Window.Property(close.direction),left)">Close</onleft>
        <onright condition="!String.IsEmpty(Window.Property(scroll))">1152</onright>
        <onright condition="String.IsEqual(Window.Property(close.direction),right)">Close</onright>
        <ondown condition="String.IsEqual(Window.Property(close.direction),down)">Close</ondown>
        <ondown condition="!String.IsEqual(Window.Property(close.direction),down)">noop</ondown>
        <scrolltime>200</scrolltime>
        <orientation>vertical</orientation>
        <pagecontrol>1152</pagecontrol>
        <!-- ITEM LAYOUT ########################################## -->
        <itemlayout height="{{ vscale(66) }}">
            {% include "includes/plezy_menu_row.xml.tpl" with w = 600 %}
        </itemlayout>
        <focusedlayout height="{{ vscale(66) }}">
            {% include "includes/plezy_menu_row.xml.tpl" with w = 600 & focused = True %}
        </focusedlayout>
    </control>
    <control type="scrollbar" id="1152">
        <hitrect x="600" y="0" w="50" h="{{ vscale(528) }}" />
        <left>604</left>
        <top>0</top>
        <width>6</width>
        <height>{{ vscale(528) }}</height>
        <visible>true</visible>
        <texturesliderbackground colordiffuse="{{ core.plezy.track }}" border="4">script.plex/white-square-rounded-4r.png</texturesliderbackground>
        <texturesliderbar colordiffuse="{{ core.plezy.muted }}" border="4">script.plex/white-square-rounded-4r.png</texturesliderbar>
        <texturesliderbarfocus colordiffuse="{{ core.plezy.text }}" border="4">script.plex/white-square-rounded-4r.png</texturesliderbarfocus>
        <textureslidernib>-</textureslidernib>
        <textureslidernibfocus>-</textureslidernibfocus>
        <pulseonselect>false</pulseonselect>
        <orientation>vertical</orientation>
        <showonepage>false</showonepage>
        <onleft>250</onleft>
    </control>
</control>
{% endblock controls %}
