{# Plezy person card (cast_member_strip.dart / person_search_row.dart): a 200px circular avatar over a surface disc,
   with a person glyph when there is no photo (drawn only then: a faded row would show it through the photo), the name
   in semi-bold and the credit under it, both centred.
   Focus is the card language of plezy_hub_card: a 3px outside ring in the text colour (ring-circle), a soft glow
   under the art (glow-circle) and a 1.03 scale; the name scrolls while it has focus.
   params: focused (bool). Uses hub_id from the caller; the layout applies while hub.display.<hub_id> is "circle".
   ListItem: Label (name), Label2 (credit), Thumb (photo), Property(glyph) (placeholder, default person.png). #}
{% with fid = hub_id %}
<{% if focused %}focusedlayout{% else %}itemlayout{% endif %} width="224" condition="String.IsEqual(Window.Property(hub.display.{{ hub_id }}),circle)">
    <control type="group">
        <posx>16</posx>
        <posy>{{ vscale(14) }}</posy>
        <control type="group">
            {% if focused %}
            <animation effect="zoom" start="100" end="103" time="120" tween="cubic" easing="out" center="100,{{ vscale(100) }}" reversible="false">Focus</animation>
            <animation effect="zoom" start="103" end="100" time="120" tween="cubic" easing="out" center="100,{{ vscale(100) }}" reversible="false">UnFocus</animation>
            <control type="image">
                <visible>Control.HasFocus({{ fid }})</visible>
                <posx>-40</posx>
                <posy>{{ vscale(-40) }}</posy>
                <width>280</width>
                <height>{{ vscale(280) }}</height>
                <texture>script.plex/plezy/glow-circle.png</texture>
            </control>
            {% endif %}
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>200</width>
                <height>{{ vscale(200) }}</height>
                <texture colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/mask-circle.png</texture>
            </control>
            <control type="image">
                <visible>String.IsEmpty(ListItem.Thumb)</visible>
                <posx>52</posx>
                <posy>{{ vscale(52) }}</posy>
                <width>96</width>
                <height>{{ vscale(96) }}</height>
                <texture colordiffuse="{{ core.plezy.muted }}" fallback="script.plex/plezy/icons/person.png">$INFO[ListItem.Property(glyph)]</texture>
                <aspectratio>keep</aspectratio>
            </control>
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>200</width>
                <height>{{ vscale(200) }}</height>
                <texture background="true" diffuse="script.plex/plezy/mask-circle.png">$INFO[ListItem.Thumb]</texture>
                <aspectratio scalediffuse="false" aligny="top">scale</aspectratio>
            </control>
            {% if focused %}
            <control type="image">
                <visible>Control.HasFocus({{ fid }})</visible>
                <posx>-4</posx>
                <posy>{{ vscale(-4) }}</posy>
                <width>208</width>
                <height>{{ vscale(208) }}</height>
                <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-circle.png</texture>
            </control>
            {% endif %}
        </control>
        <control type="label">
            <scroll>{% if focused %}Control.HasFocus({{ fid }}){% else %}false{% endif %}</scroll>
            <posx>2</posx>
            <posy>{{ vscale(212) }}</posy>
            <width>196</width>
            <height>{{ vscale(34) }}</height>
            <font>font12</font>
            <align>center</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[ListItem.Label][/B]</label>
        </control>
        <control type="label">
            <scroll>false</scroll>
            <posx>2</posx>
            <posy>{{ vscale(244) }}</posy>
            <width>196</width>
            <height>{{ vscale(30) }}</height>
            <font>font10</font>
            <align>center</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Label2]</label>
        </control>
    </control>
</{% if focused %}focusedlayout{% else %}itemlayout{% endif %}>
{% endwith %}
