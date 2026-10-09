{# Plezy player content strip item (lib/widgets/video_controls/widgets/content_strip.dart _buildStripItem +
   media_selector_thumbnail.dart; tablet metrics on a 1080p TV, x1.5): 318 wide, a 296x167 thumb (radius 6 -> 9) on
   a surface placeholder, the current entry outlined in white, a title (bold when current) and a muted subtitle
   (Label2). Focus: FocusableWrapper's white 20% background plate behind the whole item and a 1.02 scale.
   Used by the chapter strip (seek dialog list 501) and the queue strip (playlist dialog list 101).
   params: focused (bool), list_id, current (ListItem property marking the current entry, default is.current) #}
{% with cur = current|default("is.current") %}
<control type="group">
    {% if focused %}
    <animation effect="zoom" start="100" end="102" time="150" tween="cubic" easing="out" center="159,{{ vscale(121) }}" reversible="false">Focus</animation>
    <animation effect="zoom" start="102" end="100" time="150" tween="cubic" easing="out" center="159,{{ vscale(121) }}" reversible="false">UnFocus</animation>
    <control type="image">
        <visible>Control.HasFocus({{ list_id }})</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>318</width>
        <height>{{ vscale(243) }}</height>
        <texture border="8" colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/r8.png</texture>
    </control>
    {% endif %}
    <control type="group">
        <posx>11</posx>
        <posy>{{ vscale(6) }}</posy>
        <control type="image">
            <posx>0</posx>
            <posy>0</posy>
            <width>296</width>
            <height>{{ vscale(167) }}</height>
            <texture border="8" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r8.png</texture>
        </control>
        <control type="image">
            <visible>String.IsEmpty(ListItem.Thumb)</visible>
            <posx>127</posx>
            <posy>{{ vscale(62) }}</posy>
            <width>42</width>
            <height>{{ vscale(42) }}</height>
            <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/icons/movie.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="image">
            <posx>0</posx>
            <posy>0</posy>
            <width>296</width>
            <height>{{ vscale(167) }}</height>
            <texture background="true" diffuse="script.plex/plezy/mask-rail-wide.png">$INFO[ListItem.Thumb]</texture>
            <aspectratio>scale</aspectratio>
        </control>
        <control type="group">
            <visible>!String.IsEmpty(ListItem.Property(progress))</visible>
            <posx>10</posx>
            <posy>{{ vscale(153) }}</posy>
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>276</width>
                <height>{{ vscale(5) }}</height>
                <texture colordiffuse="{{ core.plezy.player_tooltip }}">script.plex/white-square.png</texture>
            </control>
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>276</width>
                <height>{{ vscale(5) }}</height>
                <texture colordiffuse="{{ core.plezy.player_fg }}">$INFO[ListItem.Property(progress)]</texture>
            </control>
        </control>
        <control type="image">
            <visible>!String.IsEmpty(ListItem.Property({{ cur }}))</visible>
            <posx>-3</posx>
            <posy>{{ vscale(-3) }}</posy>
            <width>302</width>
            <height>{{ vscale(173) }}</height>
            <texture border="11" colordiffuse="{{ core.plezy.player_fg }}">script.plex/plezy/ring-8.png</texture>
        </control>
        <control type="label">
            <visible>String.IsEmpty(ListItem.Property({{ cur }}))</visible>
            <scroll>{% if focused %}Control.HasFocus({{ list_id }}){% else %}false{% endif %}</scroll>
            <posx>0</posx>
            <posy>{{ vscale(173) }}</posy>
            <width>296</width>
            <height>{{ vscale(32) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <label>$INFO[ListItem.Label]</label>
        </control>
        <control type="label">
            <visible>!String.IsEmpty(ListItem.Property({{ cur }}))</visible>
            <scroll>{% if focused %}Control.HasFocus({{ list_id }}){% else %}false{% endif %}</scroll>
            <posx>0</posx>
            <posy>{{ vscale(173) }}</posy>
            <width>296</width>
            <height>{{ vscale(32) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <label>[B]$INFO[ListItem.Label][/B]</label>
        </control>
        <control type="label">
            <scroll>{% if focused %}Control.HasFocus({{ list_id }}){% else %}false{% endif %}</scroll>
            <posx>0</posx>
            <posy>{{ vscale(204) }}</posy>
            <width>296</width>
            <height>{{ vscale(30) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg_subtle }}</textcolor>
            <label>$INFO[ListItem.Label2]</label>
            <visible>String.IsEmpty(ListItem.Property({{ cur }}))</visible>
        </control>
        <control type="label">
            <scroll>{% if focused %}Control.HasFocus({{ list_id }}){% else %}false{% endif %}</scroll>
            <posx>0</posx>
            <posy>{{ vscale(204) }}</posy>
            <width>296</width>
            <height>{{ vscale(30) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg_muted }}</textcolor>
            <label>$INFO[ListItem.Label2]</label>
            <visible>!String.IsEmpty(ListItem.Property({{ cur }}))</visible>
        </control>
    </control>
</control>
{% endwith %}
