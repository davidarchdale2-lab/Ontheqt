{% extends "base.xml.tpl" %}
{# Plezy's profile switcher (edde746/plezy lib/screens/profile/profile_switch_screen.dart + pin_entry_dialog.dart) at x1.5 chrome:
   a pinned app bar (power menu button, title, clock), then one M3E connected group of full-width profile tiles (list 101, rows from
   includes/profile_tile.xml.tpl) ending in an outlined "Refresh users" stadium. Focus is a white @20% fill, never a ring. A PIN
   protected profile opens Plezy's PIN dialog (group 400, includes/pin_dialog.xml.tpl) over a scrim. Picking a profile shows
   ProfileSwitchingOverlay. The theme-music mini player (buttons 404 406 409 407, grouplist 600) is kept at the bottom.
   Control ids the Python uses: 101 the profiles, 400 the PIN pad (200-211 its keys; 212 close is skin-only), 500 the power menu.
   Window properties: busy, initialized, dropdown, switching, pin.error. Item properties: see includes/profile_tile.xml.tpl. #}
{% block headers %}<defaultcontrol>100</defaultcontrol>
<animation effect="fade" start="0" end="100" time="200" tween="cubic" easing="out">WindowOpen</animation>{% endblock %}
{% block backgroundcolor %}<backgroundcolor>$INFO[Window.Property(background_colour_opaque)]</backgroundcolor>{% endblock %}
{% block controls %}
<control type="image">
    <visible>String.IsEmpty(Window.Property(use_solid_background))</visible>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.bg }}">script.plex/white-square.png</texture>
</control>

{# theme-music mini player: a surface bar with the cover, title, artist / album, progress and four round transport buttons #}
<control type="group">
    <visible>Player.HasAudio + String.IsEmpty(Window(10000).Property(script.plezy.native.theme_playing))</visible>
    <posx>72</posx>
    <posy>{{ vscale(956) }}</posy>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>1776</width>
        <height>{{ vscale(96) }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r20.png</texture>
    </control>
    <control type="image">
        <posx>12</posx>
        <posy>{{ vscale(12) }}</posy>
        <width>72</width>
        <height>{{ vscale(72) }}</height>
        <texture diffuse="script.plex/plezy/mask-square.png">$INFO[Player.Art(thumb)]</texture>
        <aspectratio>scale</aspectratio>
    </control>
    <control type="label">
        <posx>100</posx>
        <posy>{{ vscale(8) }}</posy>
        <width>1100</width>
        <height>{{ vscale(36) }}</height>
        <font>font12</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>[B]$INFO[MusicPlayer.Title][/B]</label>
    </control>
    <control type="label">
        <posx>100</posx>
        <posy>{{ vscale(44) }}</posy>
        <width>1100</width>
        <height>{{ vscale(30) }}</height>
        <font>font10</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$INFO[MusicPlayer.Artist]$INFO[MusicPlayer.Album, &#8226; ]</label>
    </control>
    <control type="progress">
        <description>Progressbar</description>
        <posx>100</posx>
        <posy>{{ vscale(82) }}</posy>
        <width>1100</width>
        <height>{{ vscale(4) }}</height>
        <texturebg colordiffuse="{{ core.plezy.track }}">script.plex/white-square-1px.png</texturebg>
        <lefttexture>-</lefttexture>
        <midtexture colordiffuse="{{ core.plezy.text }}">script.plex/white-square-1px.png</midtexture>
        <righttexture>-</righttexture>
        <overlaytexture>-</overlaytexture>
        <info>Player.Progress</info>
    </control>
    <control type="grouplist" id="600">
        <defaultcontrol>406</defaultcontrol>
        <posx>1368</posx>
        <posy>{{ vscale(16) }}</posy>
        <width>396</width>
        <height>{{ vscale(64) }}</height>
        <align>right</align>
        <onup>101</onup>
        <itemgap>0</itemgap>
        <orientation>horizontal</orientation>
        <scrolltime tween="quadratic" easing="out">200</scrolltime>
        {% include "includes/mini_player_button.xml.tpl" with bid = 404 & asset = "next" & flip = True & enable = "MusicPlayer.HasPrevious" & r1 = 406 & onclick = "PlayerControl(Previous)" %}
        {% include "includes/mini_player_button.xml.tpl" with bid = 406 & asset = "pause" & alt_asset = "play" & alt_cond = "Player.Paused | Player.Forwarding | Player.Rewinding" & l1 = 404 & l1c = "MusicPlayer.HasPrevious" & r1 = 409 & r1c = "MusicPlayer.HasNext" & r2 = 407 & onclick = "PlayerControl(Play)" %}
        {% include "includes/mini_player_button.xml.tpl" with bid = 409 & asset = "next" & enable = "MusicPlayer.HasNext" & l1 = 406 & r1 = 407 & onclick = "PlayerControl(Next)" %}
        {% include "includes/mini_player_button.xml.tpl" with bid = 407 & asset = "stop" & l1 = 409 & l1c = "MusicPlayer.HasNext" & l2 = 406 & onclick = "PlayerControl(Stop)" %}
    </control>
</control>

{# app bar (FocusedScrollScaffold): the power menu as a 64px round icon button, the title, the clock #}
<control type="group">
    <posx>0</posx>
    <posy>0</posy>
    <control type="button" id="500">
        <posx>72</posx>
        <posy>{{ vscale(36) }}</posy>
        <width>64</width>
        <height>{{ vscale(64) }}</height>
        <ondown>101</ondown>
        <onright>101</onright>
        <font>font12</font>
        <texturefocus border="32" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-64.png</texturefocus>
        <texturenofocus>-</texturenofocus>
        <label> </label>
    </control>
    <control type="image">
        <visible>!String.IsEmpty(Window.Property(dropdown)) + !Control.HasFocus(500)</visible>
        <posx>72</posx>
        <posy>{{ vscale(36) }}</posy>
        <width>64</width>
        <height>{{ vscale(64) }}</height>
        <texture border="32" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-64.png</texture>
    </control>
    <control type="image">
        <visible>!Control.HasFocus(500) + String.IsEmpty(Window.Property(dropdown))</visible>
        <posx>86</posx>
        <posy>{{ vscale(50) }}</posy>
        <width>36</width>
        <height>{{ vscale(36) }}</height>
        <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/power_settings_new.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="image">
        <visible>Control.HasFocus(500) | !String.IsEmpty(Window.Property(dropdown))</visible>
        <posx>86</posx>
        <posy>{{ vscale(50) }}</posy>
        <width>36</width>
        <height>{{ vscale(36) }}</height>
        <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/power_settings_new.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <posx>156</posx>
        <posy>{{ vscale(36) }}</posy>
        <width>1200</width>
        <height>{{ vscale(64) }}</height>
        <font>font14</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>[B]$ADDON[script.plezy.native 32342][/B]</label>
    </control>
    <control type="label">
        <right>60</right>
        <posy>{{ vscale(35) }}</posy>
        <width>200</width>
        <height>{{ vscale(65) }}</height>
        <font>font12</font>
        <align>right</align>
        <aligny>center</aligny>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$INFO[System.Time]</label>
    </control>
</control>

<control type="group" id="100">
    <posx>0</posx>
    <posy>0</posy>
    <defaultcontrol always="true">101</defaultcontrol>

    {# the profiles: one tile per row (pitch 115 = 112 + the 3px group gap), then the refresh stadium #}
    <control type="list" id="101">
        <posx>72</posx>
        <posy>{{ vscale(144) }}</posy>
        <width>1776</width>
        <height>{{ vscale(800) }}</height>
        <orientation>vertical</orientation>
        <scrolltime tween="cubic" easing="out">160</scrolltime>
        <preloaditems>2</preloaditems>
        <onup>500</onup>
        <ondown condition="Player.HasAudio + String.IsEmpty(Window(10000).Property(script.plezy.native.theme_playing))">600</ondown>

        <itemlayout width="1776" height="{{ vscale(115) }}">
            {% include "includes/profile_tile.xml.tpl" %}
        </itemlayout>
        <focusedlayout width="1776" height="{{ vscale(115) }}">
            {% include "includes/profile_tile.xml.tpl" with focused = True %}
        </focusedlayout>
    </control>

    {# modal scrim behind the PIN dialog (Plezy's showDialog barrier, black54) #}
    <control type="image" id="110">
        <visible>ControlGroup(400).HasFocus(0) + String.IsEmpty(Window.Property(busy)) + String.IsEmpty(Window.Property(switching))</visible>
        <animation effect="fade" start="0" end="100" time="150" tween="cubic" easing="out">Visible</animation>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture colordiffuse="{{ core.plezy.dialog_scrim }}">script.plex/white-square.png</texture>
    </control>

    {% include "includes/pin_dialog.xml.tpl" %}
</control>

{# loading the profiles: Plezy's centred CircularProgressIndicator #}
<control type="group">
    <visible>!String.IsEmpty(Window.Property(busy)) + String.IsEmpty(Window.Property(switching))</visible>
    <posx>0</posx>
    <posy>{{ vperc(vscale(60)) }}</posy>
    {% include "includes/plezy_spinner.xml.tpl" with x = 930 & y = 0 & size = 60 & color = core.plezy.text %}
</control>

{# ProfileSwitchingOverlay: a barrier, a surface card (radius 14) with the spinner and "Switching profile...". The spinner is the busy
   dialog's: it sits at the same spot and hides while that dialog is open, so one spinner is ever shown #}
<control type="group">
    <visible>!String.IsEmpty(Window.Property(switching))</visible>
    <animation effect="fade" start="0" end="100" time="120" tween="cubic" easing="out">Visible</animation>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture colordiffuse="{{ core.plezy.dialog_scrim }}">script.plex/white-square.png</texture>
    </control>
    <control type="image">
        <posx>750</posx>
        <posy>{{ 540 - vscale(66) }}</posy>
        <width>420</width>
        <height>{{ vscale(196) }}</height>
        <texture border="14" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r14.png</texture>
    </control>
    <control type="group">
        <visible>!Window.IsVisible(script-plex-busy.xml)</visible>
        <posx>0</posx>
        <posy>{{ vperc(vscale(60)) }}</posy>
        {% include "includes/plezy_spinner.xml.tpl" with x = 930 & y = 0 & size = 60 & color = core.plezy.text %}
    </control>
    <control type="label">
        <posx>750</posx>
        <posy>{{ 540 + vscale(54) }}</posy>
        <width>420</width>
        <height>{{ vscale(40) }}</height>
        <font>font12</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$ADDON[script.plezy.native 35225]</label>
    </control>
</control>
{% endblock controls %}
