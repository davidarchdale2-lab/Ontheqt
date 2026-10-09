{% extends "default.xml.tpl" %}
{# Plezy media details sheet (edde746/plezy lib/widgets/media_details_sheet.dart in an OverlaySheet) at x1.5: the item's
   backdrop under the detail-screen scrims and a 50% sheet barrier, with a radius-16 surface sheet, bottom-centred, 1050
   wide: the title, a muted close glyph (Back closes), the metadata line in bold and the summary (plus the media dump the
   Python appends) as one scrolling text body. The only focus stop is the scrollbar 152, which pages the text with Up and
   Down. Plezy's sheet has no artwork, so the poster is gone; the thumb properties are still set by lib/windows/info.py. #}
{% block headers %}<defaultcontrol>152</defaultcontrol>{% endblock %}

{% block content %}
<control type="group">
    <visible>String.IsEmpty(Window.Property(use_solid_background))</visible>
    <control type="image">
        <visible>String.IsEmpty(Window.Property(use_bg_fallback))</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture background="true">script.plex/home/background-fallback_black.png</texture>
    </control>
    <control type="image">
        <visible>!String.IsEmpty(Window.Property(use_bg_fallback))</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture background="true">script.plex/home/background-fallback.png</texture>
    </control>
    <control type="image">
        <visible>String.IsEmpty(Window.Property(use_bg_fallback))</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture background="true" fallback="script.plex/home/background-fallback_black.png">$INFO[Window.Property(background_static)]</texture>
    </control>
    <control type="image">
        <visible>String.IsEmpty(Window.Property(use_bg_fallback))</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <fadetime>1000</fadetime>
        <texture background="true">$INFO[Window.Property(background)]</texture>
    </control>
</control>
{% include "includes/plezy_scrims.xml.tpl" with foot = True %}

<!-- the sheet barrier -->
<control type="image">
    <animation effect="fade" start="0" end="100" time="250" tween="cubic" easing="out">WindowOpen</animation>
    <animation effect="fade" start="100" end="0" time="200" tween="cubic" easing="in">WindowClose</animation>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.sheet_scrim }}">script.plex/white-square.png</texture>
</control>

<!-- the sheet: bottom-anchored (270 from the top on 16:9), reaching 24px past the screen edge -->
<control type="group" id="50">
    <animation effect="slide" start="0,{{ vscale(810) }}" end="0,0" time="250" tween="cubic" easing="out">WindowOpen</animation>
    <animation effect="fade" start="0" end="100" time="250" tween="cubic" easing="out">WindowOpen</animation>
    <animation effect="slide" start="0,0" end="0,{{ vscale(810) }}" time="200" tween="cubic" easing="in">WindowClose</animation>
    <posx>435</posx>
    <posy>{{ vscale(810) }}r</posy>
    <width>1050</width>
    <height>{{ vscale(834) }}</height>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>1050</width>
        <height>{{ vscale(834) }}</height>
        <texture border="16" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r16.png</texture>
    </control>
    <control type="label">
        <posx>24</posx>
        <posy>{{ vscale(12) }}</posy>
        <width>930</width>
        <height>{{ vscale(72) }}</height>
        <font>font20_title</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$INFO[Window.Property(title.main)]</label>
    </control>
    <control type="image">
        <posx>990</posx>
        <posy>{{ vscale(30) }}</posy>
        <width>36</width>
        <height>{{ vscale(36) }}</height>
        <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/close.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <posx>24</posx>
        <posy>{{ vscale(96) }}</posy>
        <width>1002</width>
        <height>{{ vscale(42) }}</height>
        <font>font12</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>[B]$INFO[Window.Property(title.sub)][/B]</label>
    </control>
    <control type="textbox">
        <posx>24</posx>
        <posy>{{ vscale(150) }}</posy>
        <pagecontrol>152</pagecontrol>
        <width>978</width>
        <height>{{ vscale(624) }}</height>
        <font>font12</font>
        <align>left</align>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$INFO[Window.Property(info)]</label>
    </control>
    <control type="scrollbar" id="152">
        <hitrect x="954" y="{{ vscale(150) }}" w="96" h="{{ vscale(624) }}" />
        <left>1014</left>
        <top>{{ vscale(150) }}</top>
        <width>6</width>
        <height>{{ vscale(624) }}</height>
        <visible>true</visible>
        <texturesliderbackground colordiffuse="{{ core.plezy.track }}" border="4">script.plex/white-square-rounded-4r.png</texturesliderbackground>
        <texturesliderbar colordiffuse="{{ core.plezy.muted }}" border="4">script.plex/white-square-rounded-4r.png</texturesliderbar>
        <texturesliderbarfocus colordiffuse="{{ core.plezy.muted }}" border="4">script.plex/white-square-rounded-4r.png</texturesliderbarfocus>
        <textureslidernib>-</textureslidernib>
        <textureslidernibfocus>-</textureslidernibfocus>
        <pulseonselect>false</pulseonselect>
        <orientation>vertical</orientation>
        <showonepage>false</showonepage>
        <onleft>204</onleft>
        <onright>noop</onright>
    </control>
</control>
{% endblock content %}

{% block header %}
<control type="group" id="200">
    <!-- 201 / 202 (home, search) have no function on this sheet but stay as hidden stubs for the layout contract -->
    <control type="button" id="201">
        <visible>false</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1</width>
        <height>1</height>
        <texturefocus>-</texturefocus>
        <texturenofocus>-</texturenofocus>
        <label> </label>
    </control>
    <control type="button" id="202">
        <visible>false</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1</width>
        <height>1</height>
        <texturefocus>-</texturefocus>
        <texturenofocus>-</texturenofocus>
        <label> </label>
    </control>
    {% include "includes/plezy_player_status.xml.tpl" with x = 1376 & ondown = 152 %}
</control>
{% endblock header %}
