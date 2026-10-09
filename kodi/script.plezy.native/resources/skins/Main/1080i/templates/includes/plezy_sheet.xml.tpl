{# Plezy bottom sheet frame (edde746/plezy lib/widgets/overlay_sheet.dart + bottom_sheet_header.dart) at x1.5: a sheet_scrim
   over the whole screen, then a radius-16 surface sheet, 1050px wide and bottom-centred, with a bold title, whose height
   follows the number of rows in the list (Kodi cannot size to content, so one frame per row count is drawn and the one
   matching Container(lid).NumItems is shown). The sheet reaches 24px past the screen edge to hide its bottom corners.
   The caller draws the list itself, bottom-anchored, inside a group carrying the same slide-in as the one here:
     list: <posy>{{ vscale(36 + rh * rows) }}r</posy>, height vscale(rh * rows), x = 435 and width 1050
     (for r rows it slides down by vscale((rows - r) * rh): see the Conditional slides in the callers)
   Layout per r rows (rh = row height): top = 972 - rh*r (1080 space), 12 pad, 48 title, 12 gap, rows, 36 pad.
   params: lid (list id), rows (rows shown before the list scrolls), rh (row height),
           hdr (title label, e.g. [B]$INFO[Window.Property(heading)][/B]), hdr_icon (optional icon texture left of the title),
           vis (optional Kodi condition for the whole sheet), scrim_vis (condition for the scrim alone, default vis) #}
<control type="image">
    {% if scrim_vis %}<visible>{{ scrim_vis }}</visible>{% elif vis %}<visible>{{ vis }}</visible>{% endif %}
    <animation effect="fade" start="0" end="100" time="250" tween="cubic" easing="out">WindowOpen</animation>
    <animation effect="fade" start="100" end="0" time="200" tween="cubic" easing="in">WindowClose</animation>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.sheet_scrim }}">script.plex/white-square.png</texture>
</control>
<control type="group">
    {% if vis %}<visible>{{ vis }}</visible>{% endif %}
    <animation effect="slide" start="0,{{ vscale(300) }}" end="0,0" time="250" tween="cubic" easing="out" condition="Integer.IsGreater(Container({{ lid }}).NumItems,0)">Conditional</animation>
    <animation effect="fade" start="0" end="100" time="200" tween="cubic" easing="out" condition="Integer.IsGreater(Container({{ lid }}).NumItems,0)">Conditional</animation>
    <animation effect="slide" start="0,0" end="0,{{ vscale(300) }}" time="200" tween="cubic" easing="in">WindowClose</animation>
    {% with rmax = rows + 1 %}
    {% for r in range(1, rmax) %}
    {% with sy = 108 + rh * r & sh = 132 + rh * r & ty = 96 + rh * r & iy = 90 + rh * r %}
    <control type="group">
        <visible>{% if r == rows %}Integer.IsGreater(Container({{ lid }}).NumItems,{{ rows - 1 }}){% else %}Integer.IsEqual(Container({{ lid }}).NumItems,{{ r }}){% endif %}</visible>
        <control type="image">
            <posx>435</posx>
            <posy>{{ sy|vscale }}r</posy>
            <width>1050</width>
            <height>{{ sh|vscale }}</height>
            <texture border="16" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r16.png</texture>
        </control>
        {% if hdr_icon %}
        <control type="image">
            <posx>459</posx>
            <posy>{{ iy|vscale }}r</posy>
            <width>36</width>
            <height>{{ vscale(36) }}</height>
            <texture colordiffuse="{{ core.plezy.muted }}">{{ hdr_icon }}</texture>
            <aspectratio>keep</aspectratio>
        </control>
        {% endif %}
        <control type="label">
            <posx>{% if hdr_icon %}519{% else %}459{% endif %}</posx>
            <posy>{{ ty|vscale }}r</posy>
            <width>{% if hdr_icon %}942{% else %}1002{% endif %}</width>
            <height>{{ vscale(48) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>{{ hdr }}</label>
        </control>
    </control>
    {% endwith %}
    {% endfor %}
    {% endwith %}
</control>
