{# Plezy media card for the music / list screens (a copy of plezy_hub_card.xml.tpl with the subtitle taken from any
   infolabel, because the artist screen's album items carry their year in Property(year) rather than Label2 and
   lib/windows/subitems.py (ArtistWindow) is not ours to change; fold this back into plezy_hub_card with a `sub` param
   when that file is next touched).
   params: kind, focused (bool), cw/ch (artwork size), mask (rounded diffuse mask), fid (control id whose focus drives glow/ring/scroll),
     line2 (infolabel of the muted line under the title, e.g. "ListItem.Property(year)"; none = no second line),
     item_h (layout height, for panels), placeholder_icon (icon on the surface placeholder)
   Paginator boundary items (is.boundary, left./right.boundary, is.updating) draw as a chevron tile like the hub card. #}
{% with item_w = cw + 24 %}
<{% if focused %}focusedlayout{% else %}itemlayout{% endif %} width="{{ item_w }}"{% if item_h %} height="{{ item_h|vscale }}"{% endif %}>
    <control type="group">
        <posx>16</posx>
        <posy>{{ vscale(14) }}</posy>
        <control type="group">
            {% if focused %}
            <animation effect="zoom" start="100" end="103" time="120" tween="cubic" easing="out" center="{{ cw / 2 }},{{ (ch / 2)|vscale }}" reversible="false">Focus</animation>
            <animation effect="zoom" start="103" end="100" time="120" tween="cubic" easing="out" center="{{ cw / 2 }},{{ (ch / 2)|vscale }}" reversible="false">UnFocus</animation>
            <control type="image">
                <visible>Control.HasFocus({{ fid }})</visible>
                <posx>-40</posx>
                <posy>{{ vscale(-40) }}</posy>
                <width>{{ cw + 80 }}</width>
                <height>{{ (ch + 80)|vscale }}</height>
                <texture border="48">script.plex/plezy/glow.png</texture>
            </control>
            {% endif %}
            <!-- placeholder surface while artwork loads -->
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>{{ cw }}</width>
                <height>{{ ch|vscale }}</height>
                <texture border="8" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r8.png</texture>
            </control>
            {% if placeholder_icon %}
            <control type="image">
                <posx>{{ cw / 2 - 32 }}</posx>
                <posy>{{ (ch / 2 - 32)|vscale }}</posy>
                <width>64</width>
                <height>{{ vscale(64) }}</height>
                <texture colordiffuse="{{ core.plezy.faint }}">{{ placeholder_icon }}</texture>
                <aspectratio>keep</aspectratio>
            </control>
            {% endif %}
            <control type="group">
                <visible>!String.IsEmpty(ListItem.Property(is.end)) | !String.IsEmpty(ListItem.Property(is.boundary))</visible>
                <control type="image">
                    <visible>String.IsEmpty(ListItem.Property(is.updating)) + String.IsEmpty(ListItem.Property(left.boundary))</visible>
                    <posx>{{ cw / 2 - 28 }}</posx>
                    <posy>{{ (ch / 2 - 28)|vscale }}</posy>
                    <width>56</width>
                    <height>{{ vscale(56) }}</height>
                    <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/chevron_right.png</texture>
                </control>
                <control type="image">
                    <visible>String.IsEmpty(ListItem.Property(is.updating)) + !String.IsEmpty(ListItem.Property(left.boundary))</visible>
                    <posx>{{ cw / 2 - 28 }}</posx>
                    <posy>{{ (ch / 2 - 28)|vscale }}</posy>
                    <width>56</width>
                    <height>{{ vscale(56) }}</height>
                    <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/chevron_left.png</texture>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(ListItem.Property(is.updating))</visible>
                    <posx>{{ cw / 2 - 48 }}</posx>
                    <posy>{{ (ch / 2 - 48)|vscale }}</posy>
                    <width>96</width>
                    <height>{{ vscale(96) }}</height>
                    <texture>script.plex/home/busy.gif</texture>
                </control>
            </control>
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>{{ cw }}</width>
                <height>{{ ch|vscale }}</height>
                <texture diffuse="{{ mask }}">$INFO[ListItem.Property(thumb.fallback)]</texture>
                <aspectratio>scale</aspectratio>
            </control>
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>{{ cw }}</width>
                <height>{{ ch|vscale }}</height>
                <texture background="true" diffuse="{{ mask }}">$INFO[ListItem.Thumb]</texture>
                <aspectratio>scale</aspectratio>
            </control>
            <!-- MediaProgressBar: primary on a translucent track, inset at the artwork's foot -->
            <control type="group">
                <visible>!String.IsEmpty(ListItem.Property(progress))</visible>
                <posx>10</posx>
                <posy>{{ (ch - 14)|vscale }}</posy>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>{{ cw - 20 }}</width>
                    <height>{{ vscale(5) }}</height>
                    <texture colordiffuse="99000000">script.plex/white-square.png</texture>
                </control>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>{{ cw - 20 }}</width>
                    <height>{{ vscale(5) }}</height>
                    <texture colordiffuse="{{ core.plezy.text }}">$INFO[ListItem.Property(progress)]</texture>
                </control>
            </control>
            {% include "includes/watched_indicator.xml.tpl" with xoff=cw & uw_size=40 & with_count=True & scale="medium" %}
            {% if focused %}
            <control type="image">
                <visible>Control.HasFocus({{ fid }})</visible>
                <posx>-3</posx>
                <posy>{{ vscale(-3) }}</posy>
                <width>{{ cw + 6 }}</width>
                <height>{{ (ch + 6)|vscale }}</height>
                <texture border="11" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-8.png</texture>
            </control>
            {% if selected_ring %}
            <control type="image">
                <visible>!Control.HasFocus({{ fid }})</visible>
                <posx>-3</posx>
                <posy>{{ vscale(-3) }}</posy>
                <width>{{ cw + 6 }}</width>
                <height>{{ (ch + 6)|vscale }}</height>
                <texture border="11" colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/ring-8.png</texture>
            </control>
            {% endif %}
            {% endif %}
        </control>
        <control type="label">
            <scroll>{% if focused %}Control.HasFocus({{ fid }}){% else %}false{% endif %}</scroll>
            <posx>2</posx>
            <posy>{{ (ch + 12)|vscale }}</posy>
            <width>{{ cw - 4 }}</width>
            <height>{{ vscale(34) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[ListItem.Label][/B]</label>
        </control>
        {% if line2 %}
        <control type="label">
            <scroll>{% if focused %}Control.HasFocus({{ fid }}){% else %}false{% endif %}</scroll>
            
            <posx>2</posx>
            <posy>{{ (ch + 44)|vscale }}</posy>
            <width>{{ cw - 4 }}</width>
            <height>{{ vscale(30) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[{{ line2 }}]</label>
        </control>
        {% endif %}
    </control>
</{% if focused %}focusedlayout{% else %}itemlayout{% endif %}>
{% endwith %}
