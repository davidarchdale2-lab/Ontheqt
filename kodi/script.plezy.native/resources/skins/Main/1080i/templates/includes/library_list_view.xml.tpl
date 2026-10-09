{# Plezy library list view (edde746/plezy lib/widgets/media_card.dart _MediaCardList + media_card_list_layout.dart), x1.5:
   full-width rows of [artwork | title, metadata, summary] with a ring around the focused row (CardFocusBorder, inside
   stroke), a slim scrollbar and the alphabet jump bar at the right. Shared by script-plex-listview-16x9.xml.tpl (poster
   rows: 128x192 artwork, 216px pitch, summary) and script-plex-listview-square.xml.tpl (music and photos: 128px square
   artwork, 152px pitch). Python (lib/windows/library.py LibraryWindow) relies on: 101 (items), 151 (alphabet list),
   152 (scrollbar), 300 (play 301 / shuffle 302 / more 303 / view type 304), 100 / 150 (groups), 50, plus the header and
   filter ids the parent library layouts carry. Item properties: Label, Label2 (duration, date), Thumb, year, meta,
   summary, progress, watched / unwatched / unwatched.count, thumb.fallback, is.folder.
   params: square (bool) #}
<control type="group" id="50">
    <posx>0</posx>
    <posy>{{ vscale(135) }}</posy>
    <defaultcontrol>101</defaultcontrol>

    <control type="grouplist" id="300">
        <animation effect="fade" start="0" end="100" time="200" reversible="true">VisibleChange</animation>
        <defaultcontrol>301</defaultcontrol>
        <posx>30</posx>
        <posy>{{ vscale(-25) }}</posy>
        <width>1000</width>
        <height>{{ vscale(145) }}</height>
        <visible>!String.IsEmpty(Window.Property(initialized))</visible>
        <onup>200</onup>
        <ondown>101</ondown>
        <onleft>210</onleft>
        <onright>600</onright>
        <itemgap>-20</itemgap>
        <orientation>horizontal</orientation>
        <scrolltime tween="quadratic" easing="out">200</scrolltime>
        <usecontrolcoords>true</usecontrolcoords>

        {% with attr = {"width": 126, "height": 100} & template = "includes/themed_button.xml.tpl" & hitrect = {"x": 20, "y": 20, "w": 86, "h": 60} %}
            {% include template with name="play" & id=301 & visible="String.IsEmpty(Window.Property(disable_playback)) + [!String.IsEqual(Window(10000).Property(script.plezy.native.item.type),collection) | String.IsEqual(Window.Property(media),collection)]" %}
            {% include template with name="shuffle" & id=302 & visible="String.IsEmpty(Window.Property(disable_playback)) + [!String.IsEqual(Window(10000).Property(script.plezy.native.item.type),collection) | String.IsEqual(Window.Property(media),collection)]" %}
            {% include template with name="more" & id=303 & visible="String.IsEmpty(Window.Property(disable_playback)) + [String.IsEmpty(Window.Property(no.options)) | Player.HasAudio]" %}
            {% include template with name="chapters" & id=304 %}
        {% endwith %}
    </control>

    <control type="group" id="100">
        <visible>Integer.IsGreater(Container(101).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>101</defaultcontrol>
        <posx>0</posx>
        <posy>{{ vscale(80) }}</posy>
        <width>1920</width>
        <height>{{ vscale(865) }}</height>
        <control type="list" id="101">
            <hitrect x="60" y="0" w="1710" h="{{ vscale(865) }}" />
            <posx>60</posx>
            <posy>0</posy>
            <width>1710</width>
            <height>{{ vscale(865) }}</height>
            <onup>600</onup>
            <onright>151</onright>
            <onleft>304</onleft>
            <scrolltime tween="cubic" easing="out">200</scrolltime>
            <orientation>vertical</orientation>
            <preloaditems>4</preloaditems>
            <pagecontrol>152</pagecontrol>
            {% include "includes/library_list_row.xml.tpl" with focused=False & square=square %}
            {% include "includes/library_list_row.xml.tpl" with focused=True & square=square %}
        </control>
    </control>
    <control type="scrollbar" id="152">
        <hitrect x="1770" y="0" w="60" h="{{ vscale(865) }}" />
        <left>1784</left>
        <top>{{ vscale(80) }}</top>
        <width>6</width>
        <height>{{ vscale(865) }}</height>
        <visible>Integer.IsGreater(Container(101).NumItems,0)</visible>
        <onleft>151</onleft>
        <texturesliderbackground colordiffuse="{{ core.plezy.track }}" border="3">script.plex/plezy/r3.png</texturesliderbackground>
        <texturesliderbar colordiffuse="{{ core.plezy.faint }}" border="3">script.plex/plezy/r3.png</texturesliderbar>
        <texturesliderbarfocus colordiffuse="{{ core.plezy.text }}" border="3">script.plex/plezy/r3.png</texturesliderbarfocus>
        <textureslidernib>-</textureslidernib>
        <textureslidernibfocus>-</textureslidernibfocus>
        <pulseonselect>false</pulseonselect>
        <orientation>vertical</orientation>
        <showonepage>false</showonepage>
    </control>
</control>

<!-- alphabet jump bar (title sort): letters in 32px slots; the current letter sits on a soft disc, the focused one on a text disc -->
<control type="group" id="150">
    <visible>String.IsEqual(Window(10000).Property(script.plezy.native.sort),titleSort) + Integer.IsGreater(Container(101).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
    <defaultcontrol>151</defaultcontrol>
    <posx>1836</posx>
    <posy>{{ vscale(215) }}</posy>
    <width>36</width>
    <height>{{ vscale(865) }}</height>
    <control type="list" id="151">
        <posx>0</posx>
        <posy>0</posy>
        <width>36</width>
        <height>{{ vscale(865) }}</height>
        <onleft condition="Integer.IsGreater(Container(101).ListItem.Property(index),5) | !Integer.IsEqual(Container(151).ListItem.Property(index),0)">100</onleft>
        <onleft>600</onleft>
        <onright>152</onright>
        <scrolltime>200</scrolltime>
        <orientation>vertical</orientation>
        {% for focused in range(2) %}
        {% with cur = "String.IsEqual(Window(10000).Property(script.plezy.native.key),ListItem.Property(key))" %}
        <{% if focused %}focusedlayout{% else %}itemlayout{% endif %} width="36" height="{{ vscale(32) }}">
            <control type="group">
                <control type="image">
                    <visible>{{ cur }}{% if focused %} + !Control.HasFocus(151){% endif %}</visible>
                    <posx>2</posx>
                    <posy>0</posy>
                    <width>32</width>
                    <height>{{ vscale(32) }}</height>
                    <texture colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/circle.png</texture>
                </control>
                {% if focused %}
                <control type="image">
                    <visible>Control.HasFocus(151)</visible>
                    <posx>2</posx>
                    <posy>0</posy>
                    <width>32</width>
                    <height>{{ vscale(32) }}</height>
                    <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/circle.png</texture>
                </control>
                {% endif %}
                <control type="label">
                    <visible>!{{ cur }}{% if focused %} + !Control.HasFocus(151){% endif %}</visible>
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>36</width>
                    <height>{{ vscale(32) }}</height>
                    <font>font10</font>
                    <align>center</align>
                    <aligny>center</aligny>
                    <scroll>false</scroll>
                    <textcolor>{{ core.plezy.muted }}</textcolor>
                    <label>$INFO[ListItem.Label]</label>
                </control>
                <control type="label">
                    <visible>{{ cur }}{% if focused %} + !Control.HasFocus(151){% endif %}</visible>
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>36</width>
                    <height>{{ vscale(32) }}</height>
                    <font>font10</font>
                    <align>center</align>
                    <aligny>center</aligny>
                    <scroll>false</scroll>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <label>[B]$INFO[ListItem.Label][/B]</label>
                </control>
                {% if focused %}
                <control type="label">
                    <visible>Control.HasFocus(151)</visible>
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>36</width>
                    <height>{{ vscale(32) }}</height>
                    <font>font10</font>
                    <align>center</align>
                    <aligny>center</aligny>
                    <scroll>false</scroll>
                    <textcolor>{{ core.plezy.on_primary }}</textcolor>
                    <label>[B]$INFO[ListItem.Label][/B]</label>
                </control>
                {% endif %}
            </control>
        </{% if focused %}focusedlayout{% else %}itemlayout{% endif %}>
        {% endwith %}
        {% endfor %}
    </control>
</control>
