{% extends "default.xml.tpl" %}
{# Plezy TV season detail (edde746/plezy lib/screens/media_detail_screen.dart _buildTvDetailScreen for a season).
   No poster and no big episode still: the season's backdrop full-bleed under the spotlight scrims, a bottom-aligned
   hero column (the show's clear logo or title, the selected episode's title, its metadata line and summary) whose
   text block is one focus target opening the episode's info window, the Plezy action row (Play stadium or the
   version split, shuffle, watched toggle, playback settings, more), the read-only track status at the row's right
   end, and the rail of hubs anchored to the bottom: the season's episodes, the other seasons, cast, trailers & extras
   and related shows, the active hub on top of the band, the next one peeking, the band dimmed while focus is above.
   While a row other than the episodes has focus the hero describes the season (Plezy clears the focused episode);
   otherwise it follows the selected episode, which Play, the watched toggle, settings, info and more act on.
   1080p, TV-scaled values 1:1 (PLEZY_DESIGN.md): hero x 60, column 1092; action row y 590, 56 tall; rail y 652.
   Python (lib/windows/episodes.py EpisodesWindow) relies on: 50 (content), 60 (rail), 200-204 (header), 250 (progress
   image, hidden), 300 / 1300 (action groups, single / multi-version, with their info blocks 304 / 1304), 301 / 1301
   (play), 306 / 1306 (play while the selected episode loads), 302 / 1302 (shuffle), 303 / 1303 (more), 305 / 1305
   (audio / subtitle settings), 308 / 1308 (watched), 1307 (version), 400-404 (rows), 500-504 (row groups). #}
{% block background %}
    {% include "includes/default_background.xml.tpl" with spotlight=True %}
    {% include "includes/plezy_scrims.xml.tpl" %}
{% endblock %}
{# Plezy's back button never leaves: the header stays put instead of sliding away over the rail #}
{% block header_anim %}{% endblock %}
{% block header_bgfade %}{% endblock %}
{% block content %}
{% with ep = "[String.IsEmpty(Window.Property(on.extras)) | String.IsEqual(Window.Property(hub.focus),0)]" & sm = "!String.IsEmpty(Window.Property(on.extras)) + !String.IsEqual(Window.Property(hub.focus),0)" & loaded = "!String.IsEmpty(Window.Property(current_item.loaded))" & resume = "!String.IsEmpty(Container(400).ListItem.Property(progress))" %}
<control type="group" id="50">
    <defaultcontrol>300</defaultcontrol>
    <ondown condition="!String.IsEmpty(Window.Property(disable_playback))">400</ondown>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>{{ vscale(1080) }}</height>

    <!-- RAIL (TvBrowseRail): drawn first so the hero and the action row stay on top while rows slide away. The active
         hub slides to the top of the band while the rail has focus (each slide equals that row's height: 44 header +
         card band), rows above it leave, the rest dim, and the whole band sits at 60% while focus is above it -->
    <control type="group">
        <animation effect="fade" start="100" end="60" time="160" condition="!ControlGroup(60).HasFocus(0)">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(652) }}</posy>
        <width>1920</width>
        <height>{{ vscale(428) }}</height>
        <control type="grouplist" id="60">
            <visible>!String.IsEmpty(Window.Property(initialized))</visible>
            <posx>0</posx>
            <posy>0</posy>
            <width>1920</width>
            <height>{{ vscale(2900) }}</height>
            <onup condition="Control.IsVisible(300)">300</onup>
            <onup condition="Control.IsVisible(1300)">1300</onup>
            <onup condition="!Control.IsVisible(1300) + !Control.IsVisible(300)">200</onup>
            <itemgap>0</itemgap>
            <orientation>vertical</orientation>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),0) + Control.IsVisible(500) + !String.IsEmpty(Window.Property(on.extras))" reversible="true">
                <effect type="slide" end="0,{{ vscale(-303) }}" time="160" tween="cubic" easing="out" />
            </animation>
            <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),1) + Control.IsVisible(501) + !String.IsEmpty(Window.Property(on.extras))" reversible="true">
                <effect type="slide" end="0,{{ vscale(-397) }}" time="160" tween="cubic" easing="out" />
            </animation>
            <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),2) + Control.IsVisible(502) + !String.IsEmpty(Window.Property(on.extras))" reversible="true">
                <effect type="slide" end="0,{{ vscale(-310) }}" time="160" tween="cubic" easing="out" />
            </animation>
            <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),3) + Control.IsVisible(503) + !String.IsEmpty(Window.Property(on.extras))" reversible="true">
                <effect type="slide" end="0,{{ vscale(-303) }}" time="160" tween="cubic" easing="out" />
            </animation>

            <!-- EPISODES: the season's hub (Plezy: tv icon, 16:9 thumbnails at .72, 'S1E3 · 45m'); EpisodesPaginator
                 boundary tiles page in place, so left/right stay inside the list -->
            {% include "includes/episodes_rail_row.xml.tpl" with n=0 & title="$INFO[Window.Property(episodes.header)]" & icon="script.plex/plezy/icons/tv.png" & kind="ar16x9" & cw=296 & ch=167 & mask="script.plex/plezy/mask-rail-wide.png" & boundary=True %}

            <!-- OTHER SEASONS: posters, Select opens that season -->
            {% include "includes/episodes_rail_row.xml.tpl" with n=1 & title="$INFO[Window.Property(seasons.header)]" & icon="script.plex/plezy/icons/hub_seasons.png" & kind="poster" & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" %}

            <!-- CAST (of the selected episode): person cards, name + role -->
            {% include "includes/episodes_rail_row.xml.tpl" with n=2 & title="$ADDON[script.plezy.native 32419]" & icon="script.plex/plezy/icons/hub_cast.png" & kind="square" & cw=174 & ch=174 & mask="script.plex/plezy/mask-rail-square.png" %}

            <!-- TRAILERS & EXTRAS: wide cards, title + extra type -->
            {% include "includes/episodes_rail_row.xml.tpl" with n=3 & title="$INFO[Window.Property(extras.header)]" & icon="script.plex/plezy/icons/hub_extras.png" & kind="ar16x9" & cw=296 & ch=167 & mask="script.plex/plezy/mask-rail-wide.png" %}

            <!-- RELATED SHOWS: posters, RelatedPaginator boundary tiles -->
            {% include "includes/episodes_rail_row.xml.tpl" with n=4 & title="$INFO[Window.Property(related.header)]" & icon="script.plex/plezy/icons/hub_related.png" & kind="poster" & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & boundary=True %}
        </control>
    </control>

    <!-- HERO: _buildTvDetailForeground, bottom-aligned 16px above the action row (a vertical grouplist's "bottom"
         alignment), so a missing logo, title line or summary lets the rest sit down -->
    <control type="group">
        <visible>!String.IsEmpty(Window.Property(initialized))</visible>
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>

        <!-- info block focus (FocusTheme.focusBackgroundDecoration: white @ 20%, radius 8) behind the episode title,
             metadata and summary. A twin of the column below with the same item heights: the fill hangs from the
             block's first row and the grouplist clips it at the column's foot, where a fixed cap rounds it off -->
        <control type="group">
            <visible>Control.HasFocus(304) | Control.HasFocus(1304)</visible>
            <control type="grouplist">
                <posx>48</posx>
                <posy>{{ vscale(100) }}</posy>
                <width>1116</width>
                <height>{{ vscale(474) }}</height>
                <orientation>vertical</orientation>
                <align>bottom</align>
                <itemgap>0</itemgap>
                <usecontrolcoords>true</usecontrolcoords>
                <control type="group">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(title))</visible>
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
                        <visible>String.IsEmpty(Container(400).ListItem.Property(title))</visible>
                        <posx>0</posx>
                        <posy>{{ vscale(-10) }}</posy>
                        <width>1116</width>
                        <height>{{ vscale(600) }}</height>
                        <texture border="8" colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/r8.png</texture>
                    </control>
                </control>
                <control type="textbox">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(summary))</visible>
                    <posx>12</posx>
                    <posy>{{ vscale(10) }}</posy>
                    <width>1092</width>
                    <height max="{{ vscale(112) }}">auto</height>
                    <font>font12</font>
                    <textcolor>00000000</textcolor>
                    <label>$INFO[Container(400).ListItem.Property(summary)]</label>
                </control>
                <control type="textbox">
                    <visible>String.IsEmpty(Container(400).ListItem.Property(summary)) + !String.IsEmpty(Window.Property(season.summary))</visible>
                    <posx>12</posx>
                    <posy>{{ vscale(10) }}</posy>
                    <width>1092</width>
                    <height max="{{ vscale(112) }}">auto</height>
                    <font>font12</font>
                    <textcolor>00000000</textcolor>
                    <label>$INFO[Window.Property(season.summary)]</label>
                </control>
            </control>
            <control type="grouplist">
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
        </control>

        <control type="grouplist">
            <posx>60</posx>
            <posy>{{ vscale(100) }}</posy>
            <width>1092</width>
            <height>{{ vscale(474) }}</height>
            <orientation>vertical</orientation>
            <align>bottom</align>
            <itemgap>0</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <!-- logo slot: the show's ClearLogoImage contained in 790x220, hugging the lines below it -->
            <control type="image">
                <visible>!String.IsEmpty(Window.Property(clear.logo))</visible>
                <width>790</width>
                <height>{{ vscale(220) }}</height>
                <texture background="true">$INFO[Window.Property(clear.logo)]</texture>
                <aspectratio align="left" aligny="bottom">keep</aspectratio>
            </control>
            <!-- title fallback (FittingTitleText 56px w800): the show's name, up to two lines, sized to its text -->
            <control type="textbox">
                <visible>String.IsEmpty(Window.Property(clear.logo))</visible>
                <width>1092</width>
                <height max="{{ vscale(128) }}">auto</height>
                <font>font45</font>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                <label>[B]$INFO[Window.Property(show.title)][/B]</label>
            </control>
            <control type="group">
                <width>1092</width>
                <height>{{ vscale(14) }}</height>
            </control>

            <!-- the selected episode's own title (+ the time left on a started one) -->
            <control type="group">
                <visible>{{ ep }} + !String.IsEmpty(Container(400).ListItem.Property(title))</visible>
                <width>1092</width>
                <height>{{ vscale(44) }}</height>
                <control type="grouplist">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>1092</width>
                    <height>{{ vscale(40) }}</height>
                    <orientation>horizontal</orientation>
                    <itemgap>16</itemgap>
                    <usecontrolcoords>true</usecontrolcoords>
                    <control type="label">
                        <width max="860">auto</width>
                        <height>{{ vscale(40) }}</height>
                        <font>font14</font>
                        <aligny>center</aligny>
                        <scroll>false</scroll>
                        <textcolor>{{ core.plezy.text }}</textcolor>
                        <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                        <label>[B]$INFO[Container(400).ListItem.Property(title)][/B]</label>
                    </control>
                    <control type="label">
                        <visible>!String.IsEmpty(Container(400).ListItem.Property(remainingTime))</visible>
                        <width max="216">auto</width>
                        <height>{{ vscale(40) }}</height>
                        <font>font12</font>
                        <aligny>center</aligny>
                        <scroll>false</scroll>
                        <textcolor>{{ core.plezy.muted }}</textcolor>
                        <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                        <label>$INFO[Container(400).ListItem.Property(remainingTime)]</label>
                    </control>
                </control>
            </control>
            <!-- season mode: the season's title in the same slot -->
            <control type="group">
                <visible>{{ sm }} + !String.IsEmpty(Window.Property(season.title))</visible>
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
                    <label>[B]$INFO[Window.Property(season.title)][/B]</label>
                </control>
            </control>

            <!-- metadata line: S1 E3 • air date • content rating • runtime, then the score badges when they fit, the
                 user's stars and, for an episode without accessible media, why Play won't work -->
            <control type="grouplist">
                <visible>{{ ep }}</visible>
                <width>1092</width>
                <height>{{ vscale(40) }}</height>
                <orientation>horizontal</orientation>
                <itemgap>0</itemgap>
                <usecontrolcoords>true</usecontrolcoords>
                <control type="label">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(meta.line))</visible>
                    <width max="1092">auto</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font13</font>
                    <aligny>center</aligny>
                    <scroll>false</scroll>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]$INFO[Container(400).ListItem.Property(meta.line)][/B]</label>
                </control>
                <control type="label">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(meta.line)) + !String.IsEmpty(Container(400).ListItem.Property(meta.ratings)) + [!String.IsEmpty(Container(400).ListItem.Property(rating)) | !String.IsEmpty(Container(400).ListItem.Property(rating2))]</visible>
                    <width>32</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font13</font>
                    <align>center</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]&#8226;[/B]</label>
                </control>
                {% for prop in ["rating", "rating2"] %}
                <control type="image">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(meta.ratings)) + !String.IsEmpty(Container(400).ListItem.Property({{ prop }})) + String.Contains(Container(400).ListItem.Property({{ prop }}.image),imdb)</visible>
                    <posx>{% if prop == "rating2" %}16{% else %}0{% endif %}</posx>
                    <posy>{{ vscale(7) }}</posy>
                    <width>55</width>
                    <height>{{ vscale(26) }}</height>
                    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Container(400).ListItem.Property({{ prop }}.image)]</texture>
                    <aspectratio align="left">keep</aspectratio>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(meta.ratings)) + !String.IsEmpty(Container(400).ListItem.Property({{ prop }})) + !String.Contains(Container(400).ListItem.Property({{ prop }}.image),imdb)</visible>
                    <posx>{% if prop == "rating2" %}16{% else %}0{% endif %}</posx>
                    <posy>{{ vscale(7) }}</posy>
                    <width>30</width>
                    <height>{{ vscale(26) }}</height>
                    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Container(400).ListItem.Property({{ prop }}.image)]</texture>
                    <aspectratio align="left">keep</aspectratio>
                </control>
                <control type="label">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(meta.ratings)) + !String.IsEmpty(Container(400).ListItem.Property({{ prop }}))</visible>
                    <posx>6</posx>
                    <width max="200">auto</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font13</font>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]$INFO[Container(400).ListItem.Property({{ prop }})][/B]</label>
                </control>
                {% endfor %}
                <control type="image">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(rating.stars))</visible>
                    <posx>16</posx>
                    <posy>{{ vscale(9) }}</posy>
                    <width>134</width>
                    <height>{{ vscale(22) }}</height>
                    <texture>script.plex/stars/$INFO[Container(400).ListItem.Property(rating.stars)].png</texture>
                </control>
                <control type="button">
                    <visible>!String.IsEmpty(Container(400).ListItem.Property(unavailable))</visible>
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
            <!-- season mode: year • episode count -->
            <control type="group">
                <visible>{{ sm }} + !String.IsEmpty(Window.Property(season.meta))</visible>
                <width>1092</width>
                <height>{{ vscale(40) }}</height>
                <control type="label">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>1092</width>
                    <height>{{ vscale(40) }}</height>
                    <font>font13</font>
                    <aligny>center</aligny>
                    <scroll>false</scroll>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]$INFO[Window.Property(season.meta)][/B]</label>
                </control>
            </control>

            <!-- summary: 3 lines at most in the summary ink (text @ 78%); an episode without one borrows the season's
                 (Plezy _tvDetailDescription), spoiler-hidden ones keep the add-on's placeholder -->
            <control type="textbox">
                <visible>{{ ep }} + !String.IsEmpty(Container(400).ListItem.Property(summary))</visible>
                <posy>{{ vscale(10) }}</posy>
                <width>1092</width>
                <height max="{{ vscale(112) }}">auto</height>
                <font>font12</font>
                <textcolor>{{ core.plezy.summary }}</textcolor>
                <label>$INFO[Container(400).ListItem.Property(summary)]</label>
            </control>
            <control type="textbox">
                <visible>[{{ sm }} | String.IsEmpty(Container(400).ListItem.Property(summary))] + !String.IsEmpty(Window.Property(season.summary))</visible>
                <posy>{{ vscale(10) }}</posy>
                <width>1092</width>
                <height max="{{ vscale(112) }}">auto</height>
                <font>font12</font>
                <textcolor>{{ core.plezy.summary }}</textcolor>
                <label>$INFO[Window.Property(season.summary)]</label>
            </control>
        </control>

        <!-- Plezy shows resume progress through the Play glyph and the card's bar; the add-on still sizes this one -->
        <control type="image" id="250">
            <visible>false</visible>
            <posx>-1</posx>
            <posy>{{ vscale(646) }}</posy>
            <width>1</width>
            <height>{{ vscale(4) }}</height>
            <texture colordiffuse="{{ core.plezy.text }}">script.plex/white-square.png</texture>
        </control>
    </control>

    <!-- ACTION ROW (FocusableActionBar): 300 (one version) / 1300 (several) hold the row and the info block above it,
         so Back closes and the watched / page keys work anywhere in them. Up from the rail lands on Play; up from the
         row on the info block, up from there on the header -->
    {% for multi in range(2) %}
    {% with base = multi * 1000 %}
    <control type="group" id="{{ base + 300 }}">
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
        {% if multi %}
        <visible>!String.IsEmpty(Container(400).ListItem.Property(media.multiple)) + !String.IsEmpty(Window.Property(initialized)) + String.IsEmpty(Window.Property(disable_playback))</visible>
        {% else %}
        <visible allowhiddenfocus="!String.IsEmpty(Container(400).ListItem.Property(media.multiple))">String.IsEmpty(Container(400).ListItem.Property(media.multiple)) + !String.IsEmpty(Window.Property(initialized)) + String.IsEmpty(Window.Property(disable_playback))</visible>
        {% endif %}
        <defaultcontrol always="true">{{ base + 301 }}</defaultcontrol>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>{{ vscale(1080) }}</height>

        <control type="grouplist" id="{{ base + 310 }}">
            <posx>60</posx>
            <posy>{{ vscale(590) }}</posy>
            <width>1092</width>
            <height>{{ vscale(56) }}</height>
            <orientation>horizontal</orientation>
            <align>left</align>
            <itemgap>10</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <onup>{{ base + 304 }}</onup>
            <ondown>400</ondown>
            {% with nav_up = base + 304 & nav_down = 400 %}
            {# Play: icon-only stadium (the split's left segment with versions), play or resume glyph; its twin holds
               focus while the selected episode loads #}
            {% if multi %}
            {% include "includes/plezy_action_button.xml.tpl" with id=1301 & shape="split" & icon="play_arrow" & alt_icon="resume" & alt_cond=resume & visible=loaded & allowhiddenfocus=True & enable=loaded & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=1306 & shape="split" & icon="play_arrow" & alt_icon="resume" & alt_cond=resume & visible="String.IsEmpty(Window.Property(current_item.loaded))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=1307 & shape="version" & icon="keyboard_arrow_down" & posx=-8 & onup=nav_up & ondown=nav_down %}
            {% else %}
            {% include "includes/plezy_action_button.xml.tpl" with id=301 & shape="pill" & icon="play_arrow" & alt_icon="resume" & alt_cond=resume & visible=loaded & allowhiddenfocus=True & enable=loaded & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=306 & shape="pill" & icon="play_arrow" & alt_icon="resume" & alt_cond=resume & visible="String.IsEmpty(Window.Property(current_item.loaded))" & onup=nav_up & ondown=nav_down %}
            {% endif %}
            {% include "includes/plezy_action_button.xml.tpl" with id=base + 302 & icon="shuffle" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=base + 308 & icon="check" & alt_icon="remove_done" & alt_cond="!String.IsEmpty(Container(400).ListItem.Property(watched))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=base + 305 & icon="tune" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=base + 303 & icon="more_vert" & onup=nav_up & ondown=nav_down %}
            {% endwith %}
        </control>

        <!-- INFO BLOCK: the selected episode's title, metadata and summary are one focus target (Plezy's details sheet;
             here the info window). Its fill is drawn under the hero text above; this is only the hit area -->
        <control type="button" id="{{ base + 304 }}">
            <posx>48</posx>
            <posy>{{ vscale(330) }}</posy>
            <width>1116</width>
            <height>{{ vscale(254) }}</height>
            <onup>200</onup>
            <ondown>{{ base + 300 }}</ondown>
            <onleft>noop</onleft>
            <onright>noop</onright>
            <font>font12</font>
            <texturefocus>-</texturefocus>
            <texturenofocus>-</texturenofocus>
            <label> </label>
        </control>
    </control>
    {% endwith %}
    {% endfor %}

    <!-- TRACK STATUS (playback_tracks_status.dart): a read-only footnote at the row's right end for what Play would
         play, bottom-weighted like Plezy's bottomRight alignment. Plezy's slot is the right 40% (x 1176-1860) and
         sheds parts to fit; Kodi can't measure text and its fonts run larger, so the right-aligned line may grow left
         over the empty end of the action row (which never passes x 440) and each part truncates within its own
         share: the subtitle part always stays -->
    <control type="group">
        <visible>!String.IsEmpty(Window.Property(initialized)) + {{ loaded }} + String.IsEmpty(Window.Property(disable_playback))</visible>
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
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
                <visible>!String.IsEmpty(Container(400).ListItem.Property(tracks.video))</visible>
                <posy>{{ vscale(12) }}</posy>
                <width max="300">auto</width>
                <height>{{ vscale(44) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                <label>[B]$INFO[Container(400).ListItem.Property(tracks.video)][/B]</label>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Container(400).ListItem.Property(tracks.video)) + !String.IsEmpty(Container(400).ListItem.Property(tracks.audio))</visible>
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
                <visible>!String.IsEmpty(Container(400).ListItem.Property(tracks.audio))</visible>
                <posy>{{ vscale(22) }}</posy>
                <width>24</width>
                <height>{{ vscale(24) }}</height>
                <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/volume_up.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Container(400).ListItem.Property(tracks.audio))</visible>
                <posx>6</posx>
                <posy>{{ vscale(12) }}</posy>
                <width max="400">auto</width>
                <height>{{ vscale(44) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                <label>[B]$INFO[Container(400).ListItem.Property(tracks.audio)][/B]</label>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Container(400).ListItem.Property(tracks.subtitles)) + [!String.IsEmpty(Container(400).ListItem.Property(tracks.video)) | !String.IsEmpty(Container(400).ListItem.Property(tracks.audio))]</visible>
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
                <visible>!String.IsEmpty(Container(400).ListItem.Property(tracks.subtitles))</visible>
                <posy>{{ vscale(22) }}</posy>
                <width>24</width>
                <height>{{ vscale(24) }}</height>
                <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/subtitles.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Container(400).ListItem.Property(tracks.subtitles))</visible>
                <posx>6</posx>
                <posy>{{ vscale(12) }}</posy>
                <width max="300">auto</width>
                <height>{{ vscale(44) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                <label>[B]$INFO[Container(400).ListItem.Property(tracks.subtitles)][/B]</label>
            </control>
        </control>
    </control>
</control>
{% endwith %}
{% endblock content %}
