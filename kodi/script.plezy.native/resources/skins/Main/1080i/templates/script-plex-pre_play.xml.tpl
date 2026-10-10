{% extends "default.xml.tpl" %}
{# Plezy TV movie / episode detail (edde746/plezy lib/screens/media_detail_screen.dart _buildTvDetailScreen).
   No poster: the item's backdrop full-bleed under the spotlight scrims, a bottom-aligned hero column (clear logo or
   title, the episode's own title, the metadata line, a 3-line summary) whose text block is one focusable info
   block (304, opens the details window), the action row (Play stadium with the version split, trailer, watched,
   watchlist, playback settings, more), the read-only track status at the row's right end, and a rail of hubs
   (cast, reviews, extras, related, collections) anchored to the bottom: the active hub on top of the band, the
   next one peeking, the band dimmed while focus is above it.
   1080p, TV-scaled values 1:1 (PLEZY_DESIGN.md): hero x 60, column 1092; action row y 590, 56 tall; rail y 652. #}
{% block background %}
    {% include "includes/default_background.xml.tpl" with spotlight=True %}
    {% include "includes/plezy_scrims.xml.tpl" with foot=True %}
{% endblock %}
{# Plezy's back button never leaves: the header stays put instead of sliding away over the rail #}
{% block header_anim %}{% endblock %}
{% block header_bgfade %}{% endblock %}
{% block content %}
<control type="group" id="50">
    <!-- down from the header lands on the info block, as from Plezy's back button -->
    <defaultcontrol always="true">304</defaultcontrol>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>{{ vscale(1080) }}</height>

    {% block details %}
    <!-- HERO: _buildTvDetailForeground. Bottom-aligned column (a vertical grouplist's "right" alignment is its
         bottom) ending 16px above the action row, so a short summary or a missing logo lets the rest sit down -->
    <control type="group">
        <visible>!String.IsEmpty(Window.Property(initialized))</visible>
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>

        <!-- info block focus (FocusTheme.focusBackgroundDecoration: white @ 20%, radius 8). A twin of the column
             below whose items from the episode line down have the same heights; the fill hangs from the block's
             first row and the grouplist clips it at the column's foot, where a fixed cap rounds it off -->
        <control type="grouplist">
            <visible>Control.HasFocus(304)</visible>
            <posx>48</posx>
            <posy>{{ vscale(100) }}</posy>
            <width>1116</width>
            <height>{{ vscale(474) }}</height>
            <orientation>vertical</orientation>
            <align>right</align>
            <itemgap>0</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <control type="group">
                <visible>!String.IsEmpty(Window.Property(episode.title))</visible>
                <width>1116</width>
                <height>{{ vscale(44) }}</height>
                <control type="image">
                    <posx>0</posx>
                    <posy>{{ vscale(-10) }}</posy>
                    <width>1116</width>
                    <height>{{ vscale(600) }}</height>
                    <texture border="8" colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/r8.png</texture>
                </control>
            </control>
            <control type="group">
                <width>1116</width>
                <height>{{ vscale(40) }}</height>
                <control type="image">
                    <visible>String.IsEmpty(Window.Property(episode.title))</visible>
                    <posx>0</posx>
                    <posy>{{ vscale(-10) }}</posy>
                    <width>1116</width>
                    <height>{{ vscale(600) }}</height>
                    <texture border="8" colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/r8.png</texture>
                </control>
            </control>
            <control type="textbox">
                <visible>!String.IsEmpty(Window.Property(summary))</visible>
                <posx>12</posx>
                <posy>{{ vscale(10) }}</posy>
                <width>1092</width>
                <height max="{{ vscale(112) }}">auto</height>
                <font>font12</font>
                <textcolor>00000000</textcolor>
                <label>$INFO[Window.Property(summary)]</label>
            </control>
        </control>
        <control type="grouplist">
            <visible>Control.HasFocus(304)</visible>
            <posx>48</posx>
            <posy>{{ vscale(574) }}</posy>
            <width>1116</width>
            <height>{{ vscale(10) }}</height>
            <orientation>vertical</orientation>
            <usecontrolcoords>true</usecontrolcoords>
            <control type="image">
                <posx>0</posx>
                <posy>{{ vscale(-22) }}</posy>
                <width>1116</width>
                <height>{{ vscale(32) }}</height>
                <texture border="8" colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/r8.png</texture>
            </control>
        </control>

        <control type="grouplist">
            <posx>60</posx>
            <posy>{{ vscale(100) }}</posy>
            <width>1092</width>
            <height>{{ vscale(474) }}</height>
            <orientation>vertical</orientation>
            <align>right</align>
            <itemgap>0</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <!-- logo slot: ClearLogoImage contained in 790x220, hugging the metadata below it -->
            <control type="image">
                <visible>!String.IsEmpty(Window.Property(clear.logo))</visible>
                <width>790</width>
                <height>{{ vscale(220) }}</height>
                <texture background="true">$INFO[Window.Property(clear.logo)]</texture>
                <aspectratio align="left" aligny="bottom">keep</aspectratio>
            </control>
            <!-- title fallback (FittingTitleText 56px w800): up to two lines, sized to its text -->
            <control type="textbox">
                <visible>String.IsEmpty(Window.Property(clear.logo))</visible>
                <width>1092</width>
                <height max="{{ vscale(128) }}">auto</height>
                <font>font45</font>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                <label>[B]$INFO[Window.Property(hero.title)][/B]</label>
            </control>
            <control type="group">
                <width>1092</width>
                <height>{{ vscale(14) }}</height>
            </control>
            <!-- the episode's own title (the slot above keeps the show's name) -->
            <control type="group">
                <visible>!String.IsEmpty(Window.Property(episode.title))</visible>
                <width>1092</width>
                <height>{{ vscale(44) }}</height>
                <control type="label">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>1092</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font14</font>
                    <aligny>center</aligny>
                    <scroll>false</scroll>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]$INFO[Window.Property(episode.title)][/B]</label>
                </control>
            </control>
            <!-- metadata line: S1 E3 • date / year • content rating • runtime • score badges (when they fit) -->
            <control type="grouplist">
                <width>1092</width>
                <height>{{ vscale(40) }}</height>
                <orientation>horizontal</orientation>
                <itemgap>0</itemgap>
                <usecontrolcoords>true</usecontrolcoords>
                <control type="label">
                    <visible>!String.IsEmpty(Window.Property(meta))</visible>
                    <width max="1092">auto</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font13</font>
                    <aligny>center</aligny>
                    <scroll>false</scroll>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]$INFO[Window.Property(meta)][/B]</label>
                </control>
                <control type="label">
                    <visible>!String.IsEmpty(Window.Property(meta)) + !String.IsEmpty(Window.Property(meta.ratings)) + [!String.IsEmpty(Window.Property(rating)) | !String.IsEmpty(Window.Property(rating2))]</visible>
                    <width>32</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font13</font>
                    <align>center</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]&#8226;[/B]</label>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(meta.ratings)) + !String.IsEmpty(Window.Property(rating)) + String.Contains(Window.Property(rating.image),imdb)</visible>
                    <posy>{{ vscale(7) }}</posy>
                    <width>55</width>
                    <height>{{ vscale(26) }}</height>
                    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Window.Property(rating.image)]</texture>
                    <aspectratio align="left">keep</aspectratio>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(meta.ratings)) + !String.IsEmpty(Window.Property(rating)) + !String.Contains(Window.Property(rating.image),imdb)</visible>
                    <posy>{{ vscale(7) }}</posy>
                    <width>30</width>
                    <height>{{ vscale(26) }}</height>
                    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Window.Property(rating.image)]</texture>
                    <aspectratio align="left">keep</aspectratio>
                </control>
                <control type="label">
                    <visible>!String.IsEmpty(Window.Property(meta.ratings)) + !String.IsEmpty(Window.Property(rating))</visible>
                    <posx>6</posx>
                    <width max="200">auto</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font13</font>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]$INFO[Window.Property(rating)][/B]</label>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(meta.ratings)) + !String.IsEmpty(Window.Property(rating2)) + String.Contains(Window.Property(rating2.image),imdb)</visible>
                    <posx>16</posx>
                    <posy>{{ vscale(7) }}</posy>
                    <width>55</width>
                    <height>{{ vscale(26) }}</height>
                    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Window.Property(rating2.image)]</texture>
                    <aspectratio align="left">keep</aspectratio>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(meta.ratings)) + !String.IsEmpty(Window.Property(rating2)) + !String.Contains(Window.Property(rating2.image),imdb)</visible>
                    <posx>16</posx>
                    <posy>{{ vscale(7) }}</posy>
                    <width>30</width>
                    <height>{{ vscale(26) }}</height>
                    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Window.Property(rating2.image)]</texture>
                    <aspectratio align="left">keep</aspectratio>
                </control>
                <control type="label">
                    <visible>!String.IsEmpty(Window.Property(meta.ratings)) + !String.IsEmpty(Window.Property(rating2))</visible>
                    <posx>6</posx>
                    <width max="200">auto</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font13</font>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]$INFO[Window.Property(rating2)][/B]</label>
                </control>
                <!-- the user's own star rating -->
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(rating.stars))</visible>
                    <posx>16</posx>
                    <posy>{{ vscale(9) }}</posy>
                    <width>134</width>
                    <height>{{ vscale(22) }}</height>
                    <texture>script.plex/stars/$INFO[Window.Property(rating.stars)].png</texture>
                </control>
                <!-- no accessible media: Play is hidden, say why -->
                <control type="button">
                    <visible>!String.IsEmpty(Window.Property(unavailable))</visible>
                    <enable>false</enable>
                    <posx>16</posx>
                    <posy>{{ vscale(4) }}</posy>
                    <width>auto</width>
                    <height>{{ vscale(32) }}</height>
                    <font>font10</font>
                    <align>center</align>
                    <aligny>center</aligny>
                    <textoffsetx>14</textoffsetx>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <disabledcolor>{{ core.plezy.text }}</disabledcolor>
                    <texturefocus border="8" colordiffuse="{{ core.plezy.error }}">script.plex/plezy/r8.png</texturefocus>
                    <texturenofocus border="8" colordiffuse="{{ core.plezy.error }}">script.plex/plezy/r8.png</texturenofocus>
                    <label>[B]$ADDON[script.plezy.native 32312][/B]</label>
                </control>
            </control>
            {% block summary %}
            <!-- summary: 3 lines at most, in the summary ink (text @ 78%) -->
            <control type="textbox">
                <visible>!String.IsEmpty(Window.Property(summary))</visible>
                <posy>{{ vscale(10) }}</posy>
                <width>1092</width>
                <height max="{{ vscale(112) }}">auto</height>
                <font>font12</font>
                <textcolor>{{ core.plezy.summary }}</textcolor>
                <label>$INFO[Window.Property(summary)]</label>
            </control>
            {% endblock %}
        </control>

        <!-- Plezy shows resume progress only through the Play glyph; the add-on still sizes this bar -->
        <control type="image" id="250">
            <visible>false</visible>
            <posx>-1</posx>
            <posy>{{ vscale(646) }}</posy>
            <width>1</width>
            <height>{{ vscale(4) }}</height>
            <texture colordiffuse="{{ core.plezy.text }}">script.plex/white-square.png</texture>
        </control>
    </control>
    {% endblock %}

    {% block buttons %}
    <!-- ACTION ROW (FocusableActionBar): 300 holds the row (301, first so a fallback focus lands on an action) and
         the info block 304 above it -->
    <control type="group" id="300">
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
        <visible>!String.IsEmpty(Window.Property(initialized))</visible>
        <defaultcontrol always="true">301</defaultcontrol>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>{{ vscale(1080) }}</height>

        <control type="grouplist" id="301">
            <defaultcontrol>302</defaultcontrol>
            <posx>60</posx>
            <posy>{{ vscale(590) }}</posy>
            <width>1092</width>
            <height>{{ vscale(56) }}</height>
            <orientation>horizontal</orientation>
            <itemgap>10</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <onup>304</onup>
            <ondown>400</ondown>
            <!-- FocusableActionBar traps left/right at the ends; a grouplist without them wraps -->
            <onleft>noop</onleft>
            <onright>noop</onright>
            <!-- Play: icon-only stadium, drawn by the overlays below (pill or split shape, play or resume glyph) -->
            <control type="button" id="302">
                <visible>String.IsEmpty(Window.Property(unavailable)) + String.IsEmpty(Window.Property(disable_playback))</visible>
                <posx>0</posx>
                <posy>0</posy>
                <width>72</width>
                <height>{{ vscale(56) }}</height>
                <font>font12</font>
                <texturefocus>-</texturefocus>
                <texturenofocus>-</texturenofocus>
                <label> </label>
            </control>
            <!-- the split's version segment, 2px from Play -->
            {% include "includes/plezy_action_button.xml.tpl" with id=307 & shape="version" & icon="keyboard_arrow_down" & posx=-8 & visible="!String.IsEmpty(Window.Property(media.multiple)) + String.IsEmpty(Window.Property(unavailable)) + String.IsEmpty(Window.Property(disable_playback))" %}
            {% include "includes/wl_dynamic_buttons.xml.tpl" with plezy=True %}
            {% include "includes/plezy_action_button.xml.tpl" with id=303 & icon="theaters" & visible="!String.IsEmpty(Window.Property(trailer.button))" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=310 & icon="check" & alt_icon="remove_done" & alt_cond="!String.IsEmpty(Window.Property(watched))" & visible="String.IsEmpty(Window.Property(disable_playback))" %}
            {% include "includes/wl_add_remove_buttons.xml.tpl" with plezy=True %}
            {% include "includes/plezy_action_button.xml.tpl" with id=305 & icon="tune" & visible="String.IsEmpty(Window.Property(disable_playback))" %}
            {% include "includes/plezy_action_button.xml.tpl" with id=306 & icon="more_vert" & visible="String.IsEmpty(Window.Property(disable_playback))" %}
        </control>

        <!-- Play overlays at the row's first slot: stadium (or split left segment when versions follow), play or
             resume glyph, idle tonal / focused white -->
        <control type="group">
            <visible>Control.IsVisible(302)</visible>
            <posx>60</posx>
            <posy>{{ vscale(590) }}</posy>
            <control type="group">
                <visible>String.IsEmpty(Window.Property(media.multiple))</visible>
                <control type="image">
                    <visible>String.IsEmpty(Window.Property(play.resume)) + !Control.HasFocus(302)</visible>
                    <posx>0</posx><posy>0</posy><width>72</width><height>{{ vscale(56) }}</height>
                    <texture>script.plex/plezy/action/pill-play_arrow.png</texture>
                </control>
                <control type="image">
                    <visible>String.IsEmpty(Window.Property(play.resume)) + Control.HasFocus(302)</visible>
                    <posx>0</posx><posy>0</posy><width>72</width><height>{{ vscale(56) }}</height>
                    <texture>script.plex/plezy/action/pill-play_arrow-focus.png</texture>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(play.resume)) + !Control.HasFocus(302)</visible>
                    <posx>0</posx><posy>0</posy><width>72</width><height>{{ vscale(56) }}</height>
                    <texture>script.plex/plezy/action/pill-resume.png</texture>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(play.resume)) + Control.HasFocus(302)</visible>
                    <posx>0</posx><posy>0</posy><width>72</width><height>{{ vscale(56) }}</height>
                    <texture>script.plex/plezy/action/pill-resume-focus.png</texture>
                </control>
            </control>
            <control type="group">
                <visible>!String.IsEmpty(Window.Property(media.multiple))</visible>
                <control type="image">
                    <visible>String.IsEmpty(Window.Property(play.resume)) + !Control.HasFocus(302)</visible>
                    <posx>0</posx><posy>0</posy><width>72</width><height>{{ vscale(56) }}</height>
                    <texture>script.plex/plezy/action/split-play_arrow.png</texture>
                </control>
                <control type="image">
                    <visible>String.IsEmpty(Window.Property(play.resume)) + Control.HasFocus(302)</visible>
                    <posx>0</posx><posy>0</posy><width>72</width><height>{{ vscale(56) }}</height>
                    <texture>script.plex/plezy/action/split-play_arrow-focus.png</texture>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(play.resume)) + !Control.HasFocus(302)</visible>
                    <posx>0</posx><posy>0</posy><width>72</width><height>{{ vscale(56) }}</height>
                    <texture>script.plex/plezy/action/split-resume.png</texture>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(play.resume)) + Control.HasFocus(302)</visible>
                    <posx>0</posx><posy>0</posy><width>72</width><height>{{ vscale(56) }}</height>
                    <texture>script.plex/plezy/action/split-resume-focus.png</texture>
                </control>
            </control>
        </control>

        <!-- INFO BLOCK: episode title + metadata + summary are one focus target (Plezy's details sheet; here the
             info window). Its fill is drawn under the hero text above; this is only the hit area -->
        <control type="button" id="304">
            <posx>48</posx>
            <posy>{{ vscale(330) }}</posy>
            <width>1116</width>
            <height>{{ vscale(254) }}</height>
            <onup>200</onup>
            <ondown>301</ondown>
            <onleft>noop</onleft>
            <onright>noop</onright>
            <font>font12</font>
            <texturefocus>-</texturefocus>
            <texturenofocus>-</texturenofocus>
            <label> </label>
        </control>
    </control>
    {% endblock %}

    <!-- TRACK STATUS (playback_tracks_status.dart): a read-only footnote at the row's right end, bottom-weighted
         like Plezy's bottomRight alignment. Plezy's slot is the right 40% (x 1176-1860) and sheds parts to fit;
         Kodi can't measure text and its fonts run larger, so the right-aligned line may grow left over the empty
         end of the action row (which never passes x 600) and each part truncates within its own share
         (300 + 24 + 30 + 400 + 24 + 30 + 300 = 1108 of 1260): the subtitle part always stays -->
    <control type="group">
        <visible>!String.IsEmpty(Window.Property(initialized))</visible>
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
        {% block streams %}
        <control type="grouplist">
            <posx>600</posx>
            <posy>{{ vscale(590) }}</posy>
            <width>1260</width>
            <height>{{ vscale(56) }}</height>
            <align>right</align>
            <itemgap>0</itemgap>
            <orientation>horizontal</orientation>
            <usecontrolcoords>true</usecontrolcoords>
            <control type="label">
                <visible>!String.IsEmpty(Window.Property(tracks.video))</visible>
                <posy>{{ vscale(12) }}</posy>
                <width max="300">auto</width>
                <height>{{ vscale(44) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <label>[B]$INFO[Window.Property(tracks.video)][/B]</label>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Window.Property(tracks.video)) + !String.IsEmpty(Window.Property(tracks.audio))</visible>
                <posy>{{ vscale(12) }}</posy>
                <width>24</width>
                <height>{{ vscale(44) }}</height>
                <font>font10</font>
                <align>center</align>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <label>[B]&#8226;[/B]</label>
            </control>
            <control type="image">
                <visible>!String.IsEmpty(Window.Property(tracks.audio))</visible>
                <posy>{{ vscale(22) }}</posy>
                <width>24</width>
                <height>{{ vscale(24) }}</height>
                <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/volume_up.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Window.Property(tracks.audio))</visible>
                <posx>6</posx>
                <posy>{{ vscale(12) }}</posy>
                <width max="400">auto</width>
                <height>{{ vscale(44) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <label>[B]$INFO[Window.Property(tracks.audio)][/B]</label>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Window.Property(tracks.subtitles)) + [!String.IsEmpty(Window.Property(tracks.video)) | !String.IsEmpty(Window.Property(tracks.audio))]</visible>
                <posy>{{ vscale(12) }}</posy>
                <width>24</width>
                <height>{{ vscale(44) }}</height>
                <font>font10</font>
                <align>center</align>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <label>[B]&#8226;[/B]</label>
            </control>
            <control type="image">
                <visible>!String.IsEmpty(Window.Property(tracks.subtitles))</visible>
                <posy>{{ vscale(22) }}</posy>
                <width>24</width>
                <height>{{ vscale(24) }}</height>
                <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/subtitles.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Window.Property(tracks.subtitles))</visible>
                <posx>6</posx>
                <posy>{{ vscale(12) }}</posy>
                <width max="300">auto</width>
                <height>{{ vscale(44) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <label>[B]$INFO[Window.Property(tracks.subtitles)][/B]</label>
            </control>
        </control>
        {% endblock %}
    </control>

    <!-- RAIL (TvBrowseRail): hubs anchored to the bottom, the active one slides to the top of the band while the
         rail has focus, the band sits at 60% while focus is above it. Each slide equals that row's height -->
    <control type="group">
        <animation effect="fade" start="100" end="60" time="160" condition="!ControlGroup(60).HasFocus(0)">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(652) }}</posy>
        <width>1920</width>
        <height>{{ vscale(428) }}</height>
        <control type="grouplist" id="60">
            <posx>0</posx>
            <posy>0</posy>
            <width>1920</width>
            <height>{{ vscale(2900) }}</height>
            <onup>301</onup>
            <itemgap>0</itemgap>
            <orientation>vertical</orientation>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),0) + Control.IsVisible(500) + !String.IsEmpty(Window.Property(on.extras))" reversible="true">
                <effect type="slide" end="0,{{ vscale(-310) }}" time="160" tween="cubic" easing="out" />
            </animation>
            <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),1) + Control.IsVisible(501) + !String.IsEmpty(Window.Property(on.extras))" reversible="true">
                <effect type="slide" end="0,{{ vscale(-316) }}" time="160" tween="cubic" easing="out" />
            </animation>
            <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),2) + Control.IsVisible(502) + !String.IsEmpty(Window.Property(on.extras))" reversible="true">
                <effect type="slide" end="0,{{ vscale(-303) }}" time="160" tween="cubic" easing="out" />
            </animation>
            {% for i in range(3, 6) %}
            <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),{{ i }}) + Control.IsVisible({{ i + 500 }}) + !String.IsEmpty(Window.Property(on.extras))" reversible="true">
                <effect type="slide" end="0,{{ vscale(-397) }}" time="160" tween="cubic" easing="out" />
            </animation>
            {% endfor %}

            <!-- CAST: person cards, 174 rounded squares, name + role -->
            {% include "includes/pre_play_rail_row.xml.tpl" with n=0 & title="$ADDON[script.plezy.native 32419]" & icon="script.plex/plezy/icons/hub_cast.png" & kind="square" & cw=174 & ch=174 & mask="script.plex/plezy/mask-rail-square.png" & placeholder_icon="script.plex/plezy/icons/person.png" %}

            <!-- REVIEWS (add-on only): text cards -->
            <control type="group" id="501">
                <visible>Integer.IsGreater(Container(401).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
                <defaultcontrol>401</defaultcontrol>
                <width>1920</width>
                <height>{{ vscale(316) }}</height>
                <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),1) + !String.IsEmpty(Window.Property(on.extras))">Conditional</animation>
                <animation effect="fade" start="100" end="70" time="160" condition="ControlGroup(60).HasFocus(0) + !Control.HasFocus(401) + !Integer.IsGreater(Window.Property(hub.focus),1)">Conditional</animation>
                {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_reviews.png" & title="$ADDON[script.plezy.native 32953]" & x=60 & y=0 %}
                <control type="list" id="401">
                    <posx>44</posx>
                    <posy>{{ vscale(44) }}</posy>
                    <width>1876</width>
                    <height>{{ vscale(268) }}</height>
                    <onup>400</onup>
                    <ondown>402</ondown>
                    <scrolltime tween="cubic" easing="out">160</scrolltime>
                    <orientation>horizontal</orientation>
                    <preloaditems>4</preloaditems>
                    <itemlayout width="544">
                        <control type="group">
                            <posx>16</posx>
                            <posy>{{ vscale(14) }}</posy>
                            <control type="image">
                                <posx>0</posx><posy>0</posy><width>520</width><height>{{ vscale(240) }}</height>
                                <texture border="12" colordiffuse="{{ core.plezy.tile }}">script.plex/plezy/r12.png</texture>
                            </control>
                            <control type="image">
                                <posx>20</posx><posy>{{ vscale(20) }}</posy><width>40</width><height>{{ vscale(40) }}</height>
                                <texture>script.plex/reviews/$INFO[ListItem.Thumb].png</texture>
                                <aspectratio>keep</aspectratio>
                            </control>
                            <control type="label">
                                <posx>74</posx><posy>{{ vscale(14) }}</posy><width>426</width><height>{{ vscale(32) }}</height>
                                <font>font12</font><aligny>center</aligny><scroll>false</scroll>
                                <textcolor>{{ core.plezy.text }}</textcolor>
                                <label>[B]$INFO[ListItem.Label][/B]</label>
                            </control>
                            <control type="label">
                                <posx>74</posx><posy>{{ vscale(46) }}</posy><width>426</width><height>{{ vscale(26) }}</height>
                                <font>font10</font><aligny>center</aligny><scroll>false</scroll>
                                <textcolor>{{ core.plezy.muted }}</textcolor>
                                <label>$INFO[ListItem.Label2]</label>
                            </control>
                            <control type="textbox">
                                <posx>20</posx><posy>{{ vscale(84) }}</posy><width>480</width><height>{{ vscale(132) }}</height>
                                <font>font10</font>
                                <textcolor>{{ core.plezy.summary }}</textcolor>
                                <label>$INFO[ListItem.Property(text)]</label>
                            </control>
                        </control>
                    </itemlayout>
                    <focusedlayout width="544">
                        <control type="group">
                            <posx>16</posx>
                            <posy>{{ vscale(14) }}</posy>
                            <animation effect="zoom" start="100" end="103" time="120" tween="cubic" easing="out" center="260,{{ vscale(120) }}" reversible="false">Focus</animation>
                            <animation effect="zoom" start="103" end="100" time="120" tween="cubic" easing="out" center="260,{{ vscale(120) }}" reversible="false">UnFocus</animation>
                            <control type="image">
                                <visible>Control.HasFocus(401)</visible>
                                <posx>-40</posx><posy>{{ vscale(-40) }}</posy><width>600</width><height>{{ vscale(320) }}</height>
                                <texture border="48">script.plex/plezy/glow.png</texture>
                            </control>
                            <control type="image">
                                <posx>0</posx><posy>0</posy><width>520</width><height>{{ vscale(240) }}</height>
                                <texture border="12" colordiffuse="{{ core.plezy.tile }}">script.plex/plezy/r12.png</texture>
                            </control>
                            <control type="image">
                                <visible>Control.HasFocus(401)</visible>
                                <posx>0</posx><posy>0</posy><width>520</width><height>{{ vscale(240) }}</height>
                                <texture border="12" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/r12.png</texture>
                            </control>
                            <control type="image">
                                <posx>20</posx><posy>{{ vscale(20) }}</posy><width>40</width><height>{{ vscale(40) }}</height>
                                <texture>script.plex/reviews/$INFO[ListItem.Thumb].png</texture>
                                <aspectratio>keep</aspectratio>
                            </control>
                            <control type="label">
                                <posx>74</posx><posy>{{ vscale(14) }}</posy><width>426</width><height>{{ vscale(32) }}</height>
                                <font>font12</font><aligny>center</aligny><scroll>Control.HasFocus(401)</scroll>
                                <textcolor>{{ core.plezy.text }}</textcolor>
                                <label>[B]$INFO[ListItem.Label][/B]</label>
                            </control>
                            <control type="label">
                                <posx>74</posx><posy>{{ vscale(46) }}</posy><width>426</width><height>{{ vscale(26) }}</height>
                                <font>font10</font><aligny>center</aligny><scroll>Control.HasFocus(401)</scroll>
                                <textcolor>{{ core.plezy.muted }}</textcolor>
                                <label>$INFO[ListItem.Label2]</label>
                            </control>
                            <control type="textbox">
                                <posx>20</posx><posy>{{ vscale(84) }}</posy><width>480</width><height>{{ vscale(132) }}</height>
                                <font>font10</font>
                                <textcolor>{{ core.plezy.text }}</textcolor>
                                <autoscroll delay="6000" time="3000" repeat="12000">Control.HasFocus(401)</autoscroll>
                                <label>$INFO[ListItem.Property(text)]</label>
                            </control>
                            <control type="image">
                                <visible>Control.HasFocus(401)</visible>
                                <posx>-3</posx><posy>{{ vscale(-3) }}</posy><width>526</width><height>{{ vscale(246) }}</height>
                                <texture border="15" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-12.png</texture>
                            </control>
                        </control>
                    </focusedlayout>
                </control>
            </control>

            <!-- EXTRAS: wide cards, title + runtime -->
            {% include "includes/pre_play_rail_row.xml.tpl" with n=2 & title="$ADDON[script.plezy.native 32305]" & icon="script.plex/plezy/icons/hub_extras.png" & kind="ar16x9" & cw=296 & ch=167 & mask="script.plex/plezy/mask-rail-wide.png" %}

            <!-- RELATED: posters, title + year, paginated -->
            {% include "includes/pre_play_rail_row.xml.tpl" with n=3 & title="$INFO[Window.Property(related.header)]" & icon="script.plex/plezy/icons/hub_related.png" & kind="poster" & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & boundary=True %}

            <!-- COLLECTIONS: one row per collection the movie belongs to, paginated -->
            {% include "includes/pre_play_rail_row.xml.tpl" with n=4 & title="$INFO[Window.Property(collection.header.0)]" & icon="script.plex/plezy/icons/hub_collection.png" & kind="poster" & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & boundary=True %}
            {% include "includes/pre_play_rail_row.xml.tpl" with n=5 & title="$INFO[Window.Property(collection.header.1)]" & icon="script.plex/plezy/icons/hub_collection.png" & kind="poster" & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & boundary=True %}
            {% include "includes/pre_play_rail_row.xml.tpl" with n=6 & title="$INFO[Window.Property(collection.header.2)]" & icon="script.plex/plezy/icons/hub_collection.png" & kind="poster" & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & boundary=True %}
        </control>
    </control>
</control>
{% endblock content %}
