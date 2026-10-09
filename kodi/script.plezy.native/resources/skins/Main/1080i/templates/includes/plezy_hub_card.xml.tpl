{# Plezy media card for the home hub rows (edde746/plezy lib/widgets/media_card.dart + tv_browse_rail.dart).
   params: kind (poster|square|ar16x9), focused (bool), cw/ch (artwork size), mask (rounded diffuse mask). Uses hub_id from the caller.
   Artwork is clipped to radiusSm (8px) with a diffuse mask; focus is the 2.5px primary-colour outside
   stroke plus a soft glow and a 1.03 scale (FocusTheme.fullCardFocusScale), titles sit left-aligned under
   the artwork in semi-bold text with a muted subtitle. #}
{% with item_w = cw + 24 %}
<{% if focused %}focusedlayout{% else %}itemlayout{% endif %} width="{{ item_w }}" condition="String.IsEqual(Window.Property(hub.display.{{ hub_id }}),{{ kind }})">
    <control type="group">
        <posx>16</posx>
        <posy>{{ vscale(14) }}</posy>
        <control type="group">
            {% if focused %}
            <animation effect="zoom" start="100" end="103" time="120" tween="cubic" easing="out" center="{{ cw / 2 }},{{ (ch / 2)|vscale }}" reversible="false">Focus</animation>
            <animation effect="zoom" start="103" end="100" time="120" tween="cubic" easing="out" center="{{ cw / 2 }},{{ (ch / 2)|vscale }}" reversible="false">UnFocus</animation>
            <control type="image">
                <visible>Control.HasFocus({{ hub_id }})</visible>
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
            <control type="group">
                <visible>!String.IsEmpty(ListItem.Property(is.end))</visible>
                <control type="image">
                    <visible>String.IsEmpty(ListItem.Property(is.updating))</visible>
                    <posx>{{ cw / 2 - 28 }}</posx>
                    <posy>{{ (ch / 2 - 28)|vscale }}</posy>
                    <width>56</width>
                    <height>{{ vscale(56) }}</height>
                    <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/chevron_right.png</texture>
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
                <visible>Control.HasFocus({{ hub_id }})</visible>
                <posx>-3</posx>
                <posy>{{ vscale(-3) }}</posy>
                <width>{{ cw + 6 }}</width>
                <height>{{ (ch + 6)|vscale }}</height>
                <texture border="11" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-8.png</texture>
            </control>
            {% endif %}
        </control>
        <control type="label">
            <scroll>{% if focused %}Control.HasFocus({{ hub_id }}){% else %}false{% endif %}</scroll>
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
        <control type="label">
            <scroll>{% if focused %}Control.HasFocus({{ hub_id }}){% else %}false{% endif %}</scroll>
            <visible>!String.IsEmpty(Window.Property(hub.text2lines.{{ hub_id }}))</visible>
            <posx>2</posx>
            <posy>{{ (ch + 44)|vscale }}</posy>
            <width>{{ cw - 4 }}</width>
            <height>{{ vscale(30) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Label2]</label>
        </control>
    </control>
</{% if focused %}focusedlayout{% else %}itemlayout{% endif %}>
{% endwith %}
