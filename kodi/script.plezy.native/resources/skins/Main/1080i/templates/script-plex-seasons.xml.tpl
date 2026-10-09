{% extends "default.xml.tpl" %}
{# Plezy TV show detail (edde746/plezy lib/screens/media_detail_screen.dart _buildTvDetailScreen, TV layout).
   No poster: the show's backdrop full-bleed under the spotlight scrims, a bottom-aligned hero column (clear logo or
   title, the focused season's title, the metadata line, the summary) that is one focus target opening the info
   window, the Plezy action row, and the rail anchored to the bottom (seasons, cast, trailers & extras, more like
   this) with the active row on top, the next one peeking and every other row dimmed.
   Python (lib/windows/subitems.py ShowWindow) relies on: 50 (content), 200-204 (header), 250 (progress image),
   300 (hero + actions group), 301 (info), 302 (play), 303 (shuffle), 304 (more), 305 (watched), 306 (trailer),
   308/309 (watchlist), 2302-2305 (watchlist play states), 400-403 (rows), 500-503 (row groups), 60 (rail). #}
{% block background %}
    {% include "includes/default_background.xml.tpl" with spotlight=True %}
    {% include "includes/plezy_scrims.xml.tpl" %}
{% endblock %}
{# Plezy keeps its back button over the artwork at all times: no header slide or band when the rail has focus #}
{% block header_anim %}{% endblock %}
{% block header_bgfade %}{% endblock %}
{% block content %}
{% with hx = 60 & hw = 1092 & hero_bottom = 574 & action_y = 590 & rail_y = 652 %}
<control type="group" id="50">
    <defaultcontrol>300</defaultcontrol>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>{{ vscale(1080) }}</height>

    <!-- HERO FOCUS: FocusableWrapper useBackgroundFocus (white @20%, radius 8) behind the info block; Kodi can't size
         a control to its content, so one fill per combination of the optional lines (bottom fixed at the action row) -->
    {% for has_line in range(2) %}{% for has_av in range(2) %}{% for has_sum in range(2) %}
    {% with block_h = 36 + has_line * 38 + has_av * 36 + has_sum * 128 %}
    <control type="image">
        <visible>Control.HasFocus(301) + {% if has_line %}!{% endif %}String.IsEmpty(Window.Property(hero.line)) + {% if has_av %}!{% endif %}String.IsEmpty(Window.Property(wl_server_availability_verbose)) + {% if has_sum %}!{% endif %}String.IsEmpty(Window.Property(hero.summary))</visible>
        <posx>{{ hx - 14 }}</posx>
        <posy>{{ (hero_bottom - block_h - 8)|vscale }}</posy>
        <width>{{ hw + 28 }}</width>
        <height>{{ (block_h + 14)|vscale }}</height>
        <texture border="8" colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/r8.png</texture>
    </control>
    {% endwith %}
    {% endfor %}{% endfor %}{% endfor %}

    <!-- HERO: bottom-aligned column (Plezy _buildTvDetailForeground); a vertical grouplist aligned to the bottom
         collapses the optional lines and grows upwards like Plezy's Column in Align(bottomLeft) -->
    <control type="grouplist">
        <visible>!String.IsEmpty(Window.Property(title))</visible>
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
        <posx>{{ hx }}</posx>
        <posy>{{ vscale(96) }}</posy>
        <width>{{ hw }}</width>
        <height>{{ (hero_bottom - 96)|vscale }}</height>
        <orientation>vertical</orientation>
        <align>bottom</align>
        <itemgap>0</itemgap>
        <usecontrolcoords>true</usecontrolcoords>

        <!-- clear logo (contained in 790x220, left/bottom) or the title; 14px to the metadata -->
        <control type="group">
            <width>{{ hw }}</width>
            <height>{{ vscale(234) }}</height>
            <control type="image">
                <visible>!String.IsEmpty(Window.Property(clear.logo))</visible>
                <posx>0</posx>
                <posy>0</posy>
                <width>790</width>
                <height>{{ vscale(220) }}</height>
                <texture background="true">$INFO[Window.Property(clear.logo)]</texture>
                <aspectratio align="left" aligny="bottom">keep</aspectratio>
            </control>
            <control type="label">
                <visible>String.IsEmpty(Window.Property(clear.logo))</visible>
                <posx>0</posx>
                <posy>{{ vscale(64) }}</posy>
                <width>{{ hw }}</width>
                <height>{{ vscale(156) }}</height>
                <font>font45</font>
                <align>left</align>
                <aligny>center</aligny>
                <wrapmultiline>true</wrapmultiline>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                <label>[B]$INFO[Window.Property(title)][/B]</label>
            </control>
        </control>

        <!-- the focused season's title (Plezy: the focused episode's title, 24px w700) -->
        <control type="group">
            <visible>!String.IsEmpty(Window.Property(hero.line))</visible>
            <width>{{ hw }}</width>
            <height>{{ vscale(38) }}</height>
            <control type="label">
                <posx>0</posx>
                <posy>0</posy>
                <width>{{ hw }}</width>
                <height>{{ vscale(34) }}</height>
                <font>font14</font>
                <align>left</align>
                <aligny>center</aligny>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                <label>[B]$INFO[Window.Property(hero.line)][/B]</label>
            </control>
        </control>

        <!-- metadata line: year • content rating, then the rating badges (show only; plezy_ui.detail_meta) -->
        <control type="group">
            <width>{{ hw }}</width>
            <height>{{ vscale(36) }}</height>
            <control type="grouplist">
                <posx>0</posx>
                <posy>0</posy>
                <width>{{ hw }}</width>
                <height>{{ vscale(36) }}</height>
                <orientation>horizontal</orientation>
                <align>left</align>
                <itemgap>0</itemgap>
                <usecontrolcoords>true</usecontrolcoords>
                <control type="label">
                    <width>auto</width>
                    <height>{{ vscale(36) }}</height>
                    <font>font13</font>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
                    <label>[B]$INFO[Window.Property(hero.meta)][/B]</label>
                </control>
                <control type="label">
                    <visible>String.IsEmpty(Window.Property(hero.line)) + !String.IsEmpty(Window.Property(hero.meta)) + [!String.IsEmpty(Window.Property(rating)) | !String.IsEmpty(Window.Property(rating2))]</visible>
                    <width>auto</width>
                    <height>{{ vscale(36) }}</height>
                    <font>font13</font>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <label>[B] &#8226; [/B]</label>
                </control>
                {% include "includes/seasons_rating_badge.xml.tpl" with prop="rating" & image="rating.image" %}
                {% include "includes/seasons_rating_badge.xml.tpl" with prop="rating2" & image="rating2.image" %}
            </control>
        </control>

        <!-- watchlist availability (servers that have it) -->
        <control type="group">
            <visible>!String.IsEmpty(Window.Property(wl_server_availability_verbose))</visible>
            <width>{{ hw }}</width>
            <height>{{ vscale(36) }}</height>
            <control type="grouplist">
                <posx>0</posx>
                <posy>0</posy>
                <width>{{ hw }}</width>
                <height>{{ vscale(36) }}</height>
                <orientation>horizontal</orientation>
                <align>left</align>
                <itemgap>12</itemgap>
                <usecontrolcoords>true</usecontrolcoords>
                <control type="label">
                    <width>auto</width>
                    <height>{{ vscale(36) }}</height>
                    <font>font12</font>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.muted }}</textcolor>
                    <label>[B]$ADDON[script.plezy.native 34005][/B]</label>
                </control>
                <control type="label">
                    <width max="{{ hw - 200 }}">auto</width>
                    <height>{{ vscale(36) }}</height>
                    <font>font12</font>
                    <aligny>center</aligny>
                    <scroll>true</scroll>
                    <scrollspeed>10</scrollspeed>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <label>$INFO[Window.Property(wl_server_availability_verbose)]</label>
                </control>
            </control>
        </control>

        <!-- summary: 10px gap, up to three lines at 78% -->
        <control type="group">
            <visible>!String.IsEmpty(Window.Property(hero.summary))</visible>
            <width>{{ hw }}</width>
            <height>{{ vscale(128) }}</height>
            <control type="textbox">
                <posx>0</posx>
                <posy>{{ vscale(10) }}</posy>
                <width>{{ hw - 20 }}</width>
                <height>{{ vscale(118) }}</height>
                <font>font12</font>
                <align>left</align>
                <textcolor>{{ core.plezy.summary }}</textcolor>
                <autoscroll>false</autoscroll>
                <label>$INFO[Window.Property(hero.summary)]</label>
            </control>
        </control>
    </control>

    <!-- show progress (Python sizes it); Plezy's TV hero has no progress bar, the season cards carry it -->
    <control type="image" id="250">
        <visible>false</visible>
        <posx>0</posx>
        <posy>{{ vscale(1076) }}</posy>
        <width>1</width>
        <height>{{ vscale(4) }}</height>
        <texture colordiffuse="{{ core.plezy.text }}">script.plex/white-square.png</texture>
    </control>

    <!-- 300: the hero's focus targets (info block + action row), so on.extras stays off while they have focus -->
    <control type="group" id="300">
        <animation effect="fade" start="0" end="100" time="200" reversible="true">VisibleChange</animation>
        <visible>!String.IsEmpty(Window.Property(initialized))</visible>
        <defaultcontrol>310</defaultcontrol>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>{{ vscale(1080) }}</height>

        <!-- ACTION ROW (action_buttons.dart, TV): Play pill with the on-deck episode, then round tonal buttons in
             Plezy's order: trailer, shuffle, watched toggle, watchlist, more -->
        <control type="grouplist" id="310">
            <defaultcontrol>302</defaultcontrol>
            <posx>{{ hx }}</posx>
            <posy>{{ action_y|vscale }}</posy>
            <width>{{ hw + 200 }}</width>
            <height>{{ vscale(56) }}</height>
            <onup>301</onup>
            <ondown>60</ondown>
            <itemgap>10</itemgap>
            <orientation>horizontal</orientation>
            <align>left</align>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            {% with nav_up = 301 & nav_down = 60 %}
            {% include "includes/plezy_action_button.xml.tpl" with id=302 & shape="label" & icon="play_arrow" & alt_icon="resume" & alt_cond="!String.IsEmpty(Window.Property(play.resume))" & label="$INFO[Window.Property(play.label)]" & visible="String.IsEmpty(Window.Property(disable_playback))" & onup=nav_up & ondown=nav_down %}
            {# watchlist play states (includes/wl_dynamic_buttons.xml.tpl conditions): checking, several servers, one server, not available #}
            {% include "includes/plezy_action_button.xml.tpl" with id=2302 & icon="hourglass_empty" & visible="!String.IsEmpty(Window.Property(disable_playback)) + !String.IsEmpty(Window.Property(wl_availability_checking))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=2303 & shape="pill" & icon="play_circle" & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + !String.IsEmpty(Window.Property(wl_availability_multiple))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=2304 & shape="pill" & icon="play_arrow" & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + String.IsEmpty(Window.Property(wl_availability_multiple)) + !String.IsEmpty(Window.Property(wl_availability))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=2305 & icon="event_upcoming" & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + String.IsEmpty(Window.Property(wl_availability_multiple)) + String.IsEmpty(Window.Property(wl_availability))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=306 & icon="theaters" & visible="!String.IsEmpty(Window.Property(trailer.button)) + String.IsEmpty(Window.Property(disable_playback))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=303 & icon="shuffle" & visible="String.IsEmpty(Window.Property(disable_playback))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=305 & icon="check" & alt_icon="remove_done" & alt_cond="!String.IsEmpty(Window.Property(watched))" & visible="String.IsEmpty(Window.Property(disable_playback))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=308 & icon="bookmark_add" & visible="!String.IsEmpty(Window.Property(watchlist_enabled)) + String.IsEmpty(Window.Property(is_watchlisted))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=309 & icon="bookmark_added" & visible="!String.IsEmpty(Window.Property(watchlist_enabled)) + !String.IsEmpty(Window.Property(is_watchlisted))" & onup=nav_up & ondown=nav_down %}
            {% include "includes/plezy_action_button.xml.tpl" with id=304 & icon="more_vert" & visible="String.IsEmpty(Window.Property(disable_playback))" & onup=nav_up & ondown=nav_down %}
            {% endwith %}
        </control>

        <!-- the info block: metadata + summary as one target opening the full information (Plezy's details sheet);
             its fill is drawn above, sized to the visible lines -->
        <control type="button" id="301">
            <posx>{{ hx }}</posx>
            <posy>{{ vscale(400) }}</posy>
            <width>{{ hw }}</width>
            <height>{{ (hero_bottom - 400)|vscale }}</height>
            <onup>200</onup>
            <ondown>310</ondown>
            <onleft>noop</onleft>
            <onright>noop</onright>
            <font>font12</font>
            <texturefocus>-</texturefocus>
            <texturenofocus>-</texturenofocus>
            <label> </label>
        </control>
    </control>

    <!-- RAIL (tv_browse_rail.dart): rows of 0.72-scale cards; the active row slides to the top of the rail, rows
         above it leave, the next one peeks below and every row but the active one dims; the whole rail dims while
         the hero has focus (_unfocusedRailDimAlpha) -->
    {% with row_h0 = 396 & row_h1 = 310 & row_h2 = 303 & row_h3 = 396 %}
    <control type="grouplist" id="60">
        <posx>0</posx>
        <posy>{{ rail_y|vscale }}</posy>
        <width>1920</width>
        <height>{{ (row_h0 + row_h1 + row_h2 + row_h3 + 20)|vscale }}</height>
        <onup>310</onup>
        <itemgap>0</itemgap>
        <orientation>vertical</orientation>
        <usecontrolcoords>false</usecontrolcoords>
        <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),0) + Control.IsVisible(500)" reversible="true">
            <effect type="slide" end="0,{{ (0 - row_h0)|vscale }}" time="160" tween="cubic" easing="out"/>
        </animation>
        <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),1) + Control.IsVisible(501)" reversible="true">
            <effect type="slide" end="0,{{ (0 - row_h1)|vscale }}" time="160" tween="cubic" easing="out"/>
        </animation>
        <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),2) + Control.IsVisible(502)" reversible="true">
            <effect type="slide" end="0,{{ (0 - row_h2)|vscale }}" time="160" tween="cubic" easing="out"/>
        </animation>
        <animation effect="fade" start="100" end="60" time="150" condition="!ControlGroup(60).HasFocus(0)">Conditional</animation>

        <!-- SEASONS (Plezy: one hub per season with its episodes; here the season posters, Select opens the season) -->
        <control type="group" id="500">
            <visible>Integer.IsGreater(Container(400).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
            <defaultcontrol>400</defaultcontrol>
            <width>1920</width>
            <height>{{ row_h0|vscale }}</height>
            <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),0)">Conditional</animation>
            {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_seasons.png" & title="$INFO[Window.Property(seasons.header)]" & x=hx %}
            <control type="list" id="400">
                <posx>{{ hx - 16 }}</posx>
                <posy>{{ vscale(44) }}</posy>
                <width>{{ 1920 - hx + 16 }}</width>
                <height>{{ (row_h0 - 44)|vscale }}</height>
                <onup>310</onup>
                <ondown>401</ondown>
                <scrolltime tween="cubic" easing="out">160</scrolltime>
                <orientation>horizontal</orientation>
                <preloaditems>4</preloaditems>
                {% with hub_id = 400 %}
                {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=False & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & cond="none" & sub_always=True %}
                {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=True & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & cond="none" & sub_always=True %}
                {% endwith %}
            </control>
        </control>

        <!-- CAST (person cards: square 8px-rounded artwork, name and role) -->
        <control type="group" id="501">
            <visible>Integer.IsGreater(Container(401).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
            <defaultcontrol>401</defaultcontrol>
            <width>1920</width>
            <height>{{ row_h1|vscale }}</height>
            <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),1)">Conditional</animation>
            <animation effect="fade" start="100" end="45" time="160" condition="!Integer.IsGreater(Window.Property(hub.focus),0) + !ControlGroup(501).HasFocus(0)">Conditional</animation>
            {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_cast.png" & title="$ADDON[script.plezy.native 32419]" & x=hx %}
            <control type="list" id="401">
                <posx>{{ hx - 16 }}</posx>
                <posy>{{ vscale(44) }}</posy>
                <width>{{ 1920 - hx + 16 }}</width>
                <height>{{ (row_h1 - 44)|vscale }}</height>
                <onup>400</onup>
                <ondown>402</ondown>
                <scrolltime tween="cubic" easing="out">160</scrolltime>
                <orientation>horizontal</orientation>
                <preloaditems>4</preloaditems>
                {% with hub_id = 401 %}
                {% include "includes/plezy_hub_card.xml.tpl" with kind="square" & focused=False & cw=174 & ch=174 & mask="script.plex/plezy/mask-rail-square.png" & cond="none" & sub_always=True %}
                {% include "includes/plezy_hub_card.xml.tpl" with kind="square" & focused=True & cw=174 & ch=174 & mask="script.plex/plezy/mask-rail-square.png" & cond="none" & sub_always=True %}
                {% endwith %}
            </control>
        </control>

        <!-- TRAILERS & EXTRAS (16:9 at 0.72) -->
        <control type="group" id="502">
            <visible>Integer.IsGreater(Container(402).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
            <defaultcontrol>402</defaultcontrol>
            <width>1920</width>
            <height>{{ row_h2|vscale }}</height>
            <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),2)">Conditional</animation>
            <animation effect="fade" start="100" end="45" time="160" condition="!Integer.IsGreater(Window.Property(hub.focus),1) + !ControlGroup(502).HasFocus(0)">Conditional</animation>
            {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_extras.png" & title="$INFO[Window.Property(extras.header)]" & x=hx %}
            <control type="list" id="402">
                <posx>{{ hx - 16 }}</posx>
                <posy>{{ vscale(44) }}</posy>
                <width>{{ 1920 - hx + 16 }}</width>
                <height>{{ (row_h2 - 44)|vscale }}</height>
                <onup>401</onup>
                <ondown>403</ondown>
                <scrolltime tween="cubic" easing="out">160</scrolltime>
                <orientation>horizontal</orientation>
                <preloaditems>4</preloaditems>
                {% with hub_id = 402 %}
                {% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=False & cw=296 & ch=167 & mask="script.plex/plezy/mask-rail-wide.png" & cond="none" & sub_always=True %}
                {% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=True & cw=296 & ch=167 & mask="script.plex/plezy/mask-rail-wide.png" & cond="none" & sub_always=True %}
                {% endwith %}
            </control>
        </control>

        <!-- MORE LIKE THIS (RelatedPaginator: boundary tiles page in place) -->
        <control type="group" id="503">
            <visible>Integer.IsGreater(Container(403).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
            <defaultcontrol>403</defaultcontrol>
            <width>1920</width>
            <height>{{ row_h3|vscale }}</height>
            <animation effect="fade" start="100" end="45" time="160" condition="!Integer.IsGreater(Window.Property(hub.focus),2) + !ControlGroup(503).HasFocus(0)">Conditional</animation>
            {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_related.png" & title="$INFO[Window.Property(related.header)]" & x=hx %}
            <control type="list" id="403">
                <posx>{{ hx - 16 }}</posx>
                <posy>{{ vscale(44) }}</posy>
                <width>{{ 1920 - hx + 16 }}</width>
                <height>{{ (row_h3 - 44)|vscale }}</height>
                <onup>402</onup>
                <ondown>403</ondown>
                <onleft>noop</onleft>
                <onright>noop</onright>
                <scrolltime tween="cubic" easing="out">160</scrolltime>
                <orientation>horizontal</orientation>
                <preloaditems>4</preloaditems>
                {% with hub_id = 403 %}
                {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=False & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & cond="none" & sub_always=True %}
                {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=True & cw=174 & ch=261 & mask="script.plex/plezy/mask-rail-poster.png" & cond="none" & sub_always=True %}
                {% endwith %}
            </control>
        </control>
    </control>
    {% endwith %}
</control>
{% endwith %}
{% endblock content %}
