{% extends "base.xml.tpl" %}
{# Plezy anchored menu popup (edde746/plezy lib/widgets/app_menu.dart showAppMenu / AppMenuList): a menu_surface card with
   radius-12 corners, no shadow and no scrim, 66px rows (x1.5) with an inset radius-8 highlight; selected rows are bold with
   a trailing check. Rows come from includes/plezy_menu_row.xml.tpl. The Python (lib/windows/dropdown.py) positions group
   100 and sizes list 250, scrollbar 1152 and image 110 (kept as an invisible placeholder: Plezy menus have no shadow). #}
{% block backgroundcolor %}{% endblock %}
{% block headers %}
<onload>SetProperty(dropdown,1)</onload>
<defaultcontrol>100</defaultcontrol>
<zorder>100</zorder>
{% endblock %}
{% block controls %}
<control type="button" id="700">
    <!-- dummy for clicks off list -->
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texturefocus>-</texturefocus>
    <texturenofocus>-</texturenofocus>
</control>
<control type="group" id="100">
    <defaultcontrol>250</defaultcontrol>
    <visible>!String.IsEmpty(Window.Property(show))</visible>
    <animation effect="fade" start="0" end="100" time="120" tween="cubic" easing="out">Visible</animation>
    <animation effect="fade" start="100" end="0" time="100" tween="cubic" easing="in">WindowClose</animation>
    <posx>0</posx>
    <posy>0</posy>
    <control type="image" id="110">
        <posx>0</posx>
        <posy>0</posy>
        <width>360</width>
        <height>{{ vscale(146) }}</height>
        <texture>-</texture>
    </control>
    <control type="list" id="250">
        <posx>0</posx>
        <posy>0</posy>
        <width>360</width>
        <height>{{ vscale(924) }}</height>
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
            {% include "includes/plezy_menu_row.xml.tpl" with w = 360 & item_bg = True %}
        </itemlayout>
        <focusedlayout height="{{ vscale(66) }}">
            {% include "includes/plezy_menu_row.xml.tpl" with w = 360 & item_bg = True & focused = True %}
        </focusedlayout>
    </control>
    <control type="scrollbar" id="1152">
        <visible>!String.IsEmpty(Window.Property(scroll))</visible>
        <left>366</left>
        <top>0</top>
        <width>6</width>
        <height>{{ vscale(924) }}</height>
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
