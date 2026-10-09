{% extends "base.xml.tpl" %}
{# Plezy settings (edde746/plezy lib/screens/settings/settings_screen.dart, widgets/settings_section.dart, setting_tile.dart,
   screens/settings/settings_utils.dart showSelectionDialog) on the TV layout at x1.5.
   One page at a time, like Plezy's pushed pages: the ROOT page is list 75 (one M3E grouped list of the settings sections:
   icon, title, a subtitle naming what is inside, chevron); a SUBPAGE is list 100 (the section's settings: title, value or
   description as the subtitle, a switch for on/off settings, a chevron where a dialog opens); choosing a value from a list
   opens list 125 as a modal selection dialog (radio rows, or checkbox rows for multi-select settings). The app bar shows
   "Settings" on the root page and a back arrow with the section name on a subpage. The collapsed 72px rail on the left only
   offers Home (button 201); the settings icon under it marks the current destination.
   Python: lib/windows/settings.py (list ids 75 / 100 / 125, buttons 201 / 204; scrollbars 101 / 126 are kept hidden). #}
{% block headers %}<defaultcontrol>75</defaultcontrol>{% endblock %}
{% block controls %}
<control type="image">
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture>script.plex/white-square.png</texture>
    <colordiffuse>{{ core.plezy.bg }}</colordiffuse>
</control>

<control type="group" id="50">
    <animation effect="fade" start="0" end="100" time="200" tween="cubic" easing="out">WindowOpen</animation>
    <defaultcontrol always="true">75</defaultcontrol>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>

    <!-- ROOT PAGE: the settings sections ########################################## -->
    <control type="list" id="75">
        <visible allowhiddenfocus="true">!Control.HasFocus(100) + !Control.HasFocus(125)</visible>
        <animation effect="fade" start="0" end="100" time="200" tween="cubic" easing="out">Visible</animation>
        <animation effect="slide" start="-48,0" end="0,0" time="200" tween="cubic" easing="out">Visible</animation>
        <animation effect="fade" start="100" end="0" time="150" tween="cubic" easing="in">Hidden</animation>
        <posx>96</posx>
        <posy>{{ vscale(96) }}</posy>
        <width>1728</width>
        <height>{{ vscale(957) }}</height>
        <onleft>201</onleft>
        <onright>noop</onright>
        <onup>204</onup>
        <scrolltime tween="cubic" easing="out">200</scrolltime>
        <orientation>vertical</orientation>
        <!-- ITEM LAYOUT ########################################## -->
        <itemlayout height="{{ vscale(87) }}">
            {% include "includes/plezy_group_row.xml.tpl" %}
            {% include "includes/plezy_settings_section_row.xml.tpl" %}
        </itemlayout>
        <focusedlayout height="{{ vscale(87) }}">
            {% include "includes/plezy_group_row.xml.tpl" with focus_cond = "Control.HasFocus(75)" %}
            {% include "includes/plezy_settings_section_row.xml.tpl" with focused = True %}
        </focusedlayout>
    </control>

    <!-- SUBPAGE: the settings of one section ########################################## -->
    <control type="list" id="100">
        <visible allowhiddenfocus="true">Control.HasFocus(100) | Control.HasFocus(125)</visible>
        <animation effect="fade" start="0" end="100" time="200" tween="cubic" easing="out">Visible</animation>
        <animation effect="slide" start="48,0" end="0,0" time="200" tween="cubic" easing="out">Visible</animation>
        <animation effect="fade" start="100" end="0" time="150" tween="cubic" easing="in">Hidden</animation>
        <posx>96</posx>
        <posy>{{ vscale(96) }}</posy>
        <width>1728</width>
        <height>{{ vscale(957) }}</height>
        <onleft>75</onleft>
        <onright>noop</onright>
        <scrolltime tween="cubic" easing="out">200</scrolltime>
        <orientation>vertical</orientation>
        <pagecontrol>101</pagecontrol>
        <!-- ITEM LAYOUT ########################################## -->
        <itemlayout height="{{ vscale(87) }}">
            {% include "includes/plezy_group_row.xml.tpl" %}
            {% include "includes/plezy_settings_row.xml.tpl" %}
        </itemlayout>
        <focusedlayout height="{{ vscale(87) }}">
            {% include "includes/plezy_group_row.xml.tpl" with focus_cond = "Control.HasFocus(100) | Control.HasFocus(125)" %}
            {% include "includes/plezy_settings_row.xml.tpl" with focused = True %}
        </focusedlayout>
    </control>

    <!-- Plezy shows no scrollbars on TV: the ids stay (pagecontrol links, layout checks) but draw nothing -->
    <control type="scrollbar" id="101">
        <left>1830</left>
        <top>{{ vscale(96) }}</top>
        <width>6</width>
        <height>{{ vscale(957) }}</height>
        <visible>true</visible>
        <texturesliderbackground>-</texturesliderbackground>
        <texturesliderbar>-</texturesliderbar>
        <texturesliderbarfocus>-</texturesliderbarfocus>
        <textureslidernib>-</textureslidernib>
        <textureslidernibfocus>-</textureslidernibfocus>
        <pulseonselect>false</pulseonselect>
        <orientation>vertical</orientation>
        <showonepage>false</showonepage>
        <onleft>100</onleft>
    </control>

    <!-- SELECTION DIALOG (list 125): Plezy's showSelectionDialog / showChecklistDialog, an AlertDialog over a black54
         barrier. The card is content sized: one card per row count (1-10), picked by the number of items, with the list
         slid to match. -->
    <control type="image">
        <visible>Control.HasFocus(125)</visible>
        <animation effect="fade" start="0" end="100" time="150" tween="cubic" easing="out">Visible</animation>
        <animation effect="fade" start="100" end="0" time="120" tween="cubic" easing="in">Hidden</animation>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture>script.plex/white-square.png</texture>
        <colordiffuse>{{ core.plezy.dialog_scrim }}</colordiffuse>
    </control>
    {% for r in range(1, 11) %}
    {% with ch = 138 + 60 * r %}
    <control type="group">
        <visible>Control.HasFocus(125) + {% if r == 10 %}Integer.IsGreater(Container(125).NumItems,9){% else %}Integer.IsEqual(Container(125).NumItems,{{ r }}){% endif %}</visible>
        <animation effect="fade" start="0" end="100" time="150" tween="cubic" easing="out">Visible</animation>
        <animation effect="zoom" start="96" end="100" time="150" tween="cubic" easing="out" center="auto">Visible</animation>
        <animation effect="fade" start="100" end="0" time="120" tween="cubic" easing="in">Hidden</animation>
        <posx>540</posx>
        <posy>{{ vperc(vscale(ch)) }}</posy>
        <width>840</width>
        <height>{{ ch|vscale }}</height>
        <control type="image">
            <posx>0</posx>
            <posy>0</posy>
            <width>840</width>
            <height>{{ ch|vscale }}</height>
            <texture border="28" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r28.png</texture>
        </control>
        <control type="label">
            <posx>36</posx>
            <posy>{{ vscale(36) }}</posy>
            <width>768</width>
            <height>{{ vscale(48) }}</height>
            <font>font20_title</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>$INFO[Container(100).ListItem.Label]</label>
        </control>
    </control>
    {% endwith %}
    {% endfor %}
    <control type="list" id="125">
        <visible allowhiddenfocus="true">Control.HasFocus(125) + Integer.IsGreater(Container(100).NumItems,0)</visible>
        <enable>Integer.IsGreater(Container(100).NumItems,0)</enable>
        <animation effect="fade" start="0" end="100" time="150" tween="cubic" easing="out">Visible</animation>
        <animation effect="zoom" start="96" end="100" time="150" tween="cubic" easing="out" center="960,540">Visible</animation>
        <animation effect="fade" start="100" end="0" time="120" tween="cubic" easing="in">Hidden</animation>
        {% for r in range(1, 10) %}
        {% with sl = (10 - r) * 30 %}
        <animation effect="slide" end="0,{{ sl|vscale }}" time="0" condition="Integer.IsEqual(Container(125).NumItems,{{ r }})">Conditional</animation>
        {% endwith %}
        {% endfor %}
        <posx>540</posx>
        <posy>{{ vperc(vscale(738)) + vscale(102) }}</posy>
        <width>840</width>
        <height>{{ vscale(600) }}</height>
        <onleft>noop</onleft>
        <onright>noop</onright>
        <scrolltime tween="cubic" easing="out">160</scrolltime>
        <orientation>vertical</orientation>
        <pagecontrol>126</pagecontrol>
        <!-- ITEM LAYOUT ########################################## -->
        <itemlayout height="{{ vscale(60) }}">
            {% include "includes/plezy_settings_option_row.xml.tpl" %}
        </itemlayout>
        <focusedlayout height="{{ vscale(60) }}">
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>840</width>
                <height>{{ vscale(60) }}</height>
                <texture colordiffuse="{{ core.plezy.focus_fill }}">script.plex/white-square.png</texture>
            </control>
            {% include "includes/plezy_settings_option_row.xml.tpl" with focused = True %}
        </focusedlayout>
    </control>
    <control type="scrollbar" id="126">
        <left>1386</left>
        <top>{{ vperc(vscale(738)) + vscale(102) }}</top>
        <width>6</width>
        <height>{{ vscale(600) }}</height>
        <visible>true</visible>
        <texturesliderbackground>-</texturesliderbackground>
        <texturesliderbar>-</texturesliderbar>
        <texturesliderbarfocus>-</texturesliderbarfocus>
        <textureslidernib>-</textureslidernib>
        <textureslidernibfocus>-</textureslidernibfocus>
        <pulseonselect>false</pulseonselect>
        <orientation>vertical</orientation>
        <showonepage>false</showonepage>
        <onleft>125</onleft>
    </control>
</control>

<!-- APP BAR (pinned, 84 tall): title on the root page; back arrow and section name on a subpage -->
<control type="group">
    <visible>!Control.HasFocus(100) + !Control.HasFocus(125)</visible>
    <animation effect="fade" start="0" end="100" time="150" tween="cubic" easing="out">Visible</animation>
    <animation effect="fade" start="100" end="0" time="150" tween="cubic" easing="in">Hidden</animation>
    <control type="label">
        <posx>96</posx>
        <posy>{{ vscale(9) }}</posy>
        <width>1200</width>
        <height>{{ vscale(66) }}</height>
        <font>font20_title</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$INFO[Window.Property(heading)]</label>
    </control>
</control>
<control type="group">
    <visible>Control.HasFocus(100) | Control.HasFocus(125)</visible>
    <animation effect="fade" start="0" end="100" time="150" tween="cubic" easing="out">Visible</animation>
    <animation effect="fade" start="100" end="0" time="150" tween="cubic" easing="in">Hidden</animation>
    <control type="image">
        <posx>96</posx>
        <posy>{{ vscale(24) }}</posy>
        <width>36</width>
        <height>{{ vscale(36) }}</height>
        <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/arrow_back.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <posx>156</posx>
        <posy>{{ vscale(9) }}</posy>
        <width>1140</width>
        <height>{{ vscale(66) }}</height>
        <font>font20_title</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$INFO[Window.Property(section.title)]</label>
    </control>
</control>

<!-- RAIL + HEADER (group 200 as before: home button 201, now-playing chip 204, clock) -->
<control type="group" id="200">
    <defaultcontrol always="true">201</defaultcontrol>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>{{ vscale(135) }}</height>
    <control type="button" id="201">
        <posx>8</posx>
        <posy>{{ vscale(136) }}</posy>
        <width>56</width>
        <height>{{ vscale(48) }}</height>
        <onright>75</onright>
        <onleft>noop</onleft>
        <onup>noop</onup>
        <ondown>noop</ondown>
        <font>font12</font>
        <texturefocus border="24" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/pill-48.png</texturefocus>
        <texturenofocus>-</texturenofocus>
        <label> </label>
    </control>
    <control type="image">
        <visible>!Control.HasFocus(201)</visible>
        <posx>20</posx>
        <posy>{{ vscale(144) }}</posy>
        <width>32</width>
        <height>{{ vscale(32) }}</height>
        <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/home.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="image">
        <visible>Control.HasFocus(201)</visible>
        <posx>20</posx>
        <posy>{{ vscale(144) }}</posy>
        <width>32</width>
        <height>{{ vscale(32) }}</height>
        <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/home.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="image">
        <posx>20</posx>
        <posy>{{ vscale(200) }}</posy>
        <width>32</width>
        <height>{{ vscale(32) }}</height>
        <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/settings.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    {% include "includes/plezy_player_status.xml.tpl" with x = 1376 & onleft = 201 & ondown = 75 %}
    <control type="label">
        <right>60</right>
        <posy>{{ vscale(9) }}</posy>
        <width>200</width>
        <height>{{ vscale(66) }}</height>
        <font>font12</font>
        <align>right</align>
        <aligny>center</aligny>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$INFO[System.Time]</label>
    </control>
</control>
{% endblock controls %}
