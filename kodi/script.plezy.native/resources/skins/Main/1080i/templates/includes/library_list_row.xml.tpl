{# One row of the Plezy library list view (see includes/library_list_view.xml.tpl): artwork at the left, then the title,
   a muted metadata line and, for poster rows, up to three lines of summary. The focus ring is Plezy's CardFocusBorder
   (inside stroke, radius 8) around the whole row, no fill, no zoom. Lists clip their rows, so the ring sits on the row's
   own edge and the content is inset by 12px.
   params: focused (bool), square (bool: music / photo rows with 128px square artwork, else 128x192 poster rows) #}
{% with row_w = 1710 %}
<{% if focused %}focusedlayout{% else %}itemlayout{% endif %} width="{{ row_w }}" height="{% if square %}{{ vscale(152) }}{% else %}{{ vscale(216) }}{% endif %}">
    <control type="group">
        <!-- artwork: surface placeholder, fallback art, the thumb, inset progress and the watched mark -->
        <control type="group">
            <posx>12</posx>
            <posy>{{ vscale(12) }}</posy>
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>128</width>
                <height>{% if square %}{{ vscale(128) }}{% else %}{{ vscale(192) }}{% endif %}</height>
                <texture border="12" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r12.png</texture>
            </control>
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>128</width>
                <height>{% if square %}{{ vscale(128) }}{% else %}{{ vscale(192) }}{% endif %}</height>
                <texture diffuse="script.plex/plezy/mask-list-{% if square %}square{% else %}poster{% endif %}.png">$INFO[ListItem.Property(thumb.fallback)]</texture>
                <aspectratio>scale</aspectratio>
            </control>
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>128</width>
                <height>{% if square %}{{ vscale(128) }}{% else %}{{ vscale(192) }}{% endif %}</height>
                <texture background="true" diffuse="script.plex/plezy/mask-list-{% if square %}square{% else %}poster{% endif %}.png">$INFO[ListItem.Thumb]</texture>
                <aspectratio>scale</aspectratio>
            </control>
            <control type="group">
                <visible>!String.IsEmpty(ListItem.Property(progress))</visible>
                <posx>10</posx>
                <posy>{% if square %}{{ vscale(114) }}{% else %}{{ vscale(178) }}{% endif %}</posy>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>108</width>
                    <height>{{ vscale(5) }}</height>
                    <texture colordiffuse="99000000">script.plex/white-square.png</texture>
                </control>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>108</width>
                    <height>{{ vscale(5) }}</height>
                    <texture colordiffuse="{{ core.plezy.text }}">$INFO[ListItem.Property(progress)]</texture>
                </control>
            </control>
            {% include "includes/watched_indicator.xml.tpl" with xoff=128 & uw_size=32 & with_count=True & scale="small" %}
        </control>
        {% if square %}
        <!-- two-line 'Artist / Album' titles (albums) or a centred single line + metadata -->
        <control type="textbox">
            <visible>String.IsEqual(Window.Property(media.itemType),album)</visible>
            <posx>158</posx>
            <posy>{{ vscale(16) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(76) }}</height>
            <font>font13</font>
            <align>left</align>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[ListItem.Label][/B]</label>
        </control>
        <control type="label">
            <visible>!String.IsEqual(Window.Property(media.itemType),album) + String.IsEmpty(ListItem.Property(is.folder))</visible>
            <posx>158</posx>
            <posy>{{ vscale(30) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(40) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>{% if focused %}Control.HasFocus(101){% else %}false{% endif %}</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[ListItem.Label][/B]</label>
        </control>
        <control type="label">
            <visible>!String.IsEqual(Window.Property(media.itemType),album) + !String.IsEmpty(ListItem.Property(is.folder))</visible>
            <posx>158</posx>
            <posy>{{ vscale(30) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(40) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[ListItem.Label]/[/B]</label>
        </control>
        <control type="label">
            <visible>String.IsEqual(Window.Property(media.itemType),album)</visible>
            <posx>158</posx>
            <posy>{{ vscale(100) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(32) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Property(meta)]</label>
        </control>
        <control type="label">
            <visible>!String.IsEqual(Window.Property(media.itemType),album) + !String.IsEmpty(ListItem.Property(meta))</visible>
            <posx>158</posx>
            <posy>{{ vscale(72) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(32) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Property(meta)]</label>
        </control>
        <control type="label">
            <visible>!String.IsEqual(Window.Property(media.itemType),album) + String.IsEmpty(ListItem.Property(meta))</visible>
            <posx>158</posx>
            <posy>{{ vscale(72) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(32) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Label2]</label>
        </control>
        {% else %}
        <control type="label">
            <posx>158</posx>
            <posy>{{ vscale(14) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(40) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>{% if focused %}Control.HasFocus(101){% else %}false{% endif %}</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[ListItem.Label][/B]</label>
        </control>
        <control type="label">
            <visible>!String.IsEmpty(ListItem.Property(meta))</visible>
            <posx>158</posx>
            <posy>{{ vscale(58) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(32) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Property(meta)]</label>
        </control>
        <control type="label">
            <visible>String.IsEmpty(ListItem.Property(meta))</visible>
            <posx>158</posx>
            <posy>{{ vscale(58) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(32) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[ListItem.Label2]</label>
        </control>
        <control type="textbox">
            <posx>158</posx>
            <posy>{{ vscale(98) }}</posy>
            <width>{{ row_w - 190 }}</width>
            <height>{{ vscale(96) }}</height>
            <font>font10</font>
            <align>left</align>
            <textcolor>{{ core.plezy.subtle }}</textcolor>
            <label>$INFO[ListItem.Property(summary)]</label>
        </control>
        {% endif %}
        {% if focused %}
        <control type="image">
            <visible>Control.HasFocus(101)</visible>
            <posx>0</posx>
            <posy>0</posy>
            <width>{{ row_w }}</width>
            <height>{% if square %}{{ vscale(150) }}{% else %}{{ vscale(214) }}{% endif %}</height>
            <texture border="11" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-8.png</texture>
        </control>
        {% endif %}
    </control>
</{% if focused %}focusedlayout{% else %}itemlayout{% endif %}>
{% endwith %}
