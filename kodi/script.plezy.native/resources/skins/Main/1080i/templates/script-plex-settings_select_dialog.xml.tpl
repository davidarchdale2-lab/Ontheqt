{% extends "base.xml.tpl" %}
{# Plezy selection sheet (track / quality / subtitle pickers in the player, edde746/plezy track_selection_helper.dart +
   overlay_sheet.dart): a bottom sheet over a 50% scrim, a bold title, 84px rows with a title, an optional muted subtitle
   and a trailing check on the current choice. Focus is a 12% fill. List 100 as before; the sheet grows with the row count. #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block backgroundcolor %}{% endblock %}
{% block controls %}
{% include "includes/plezy_sheet.xml.tpl" with lid = 100 & rows = 8 & rh = 84 & hdr = "[B]$INFO[Window.Property(heading)][/B]" %}
<control type="group">
    <animation effect="slide" start="0,{{ vscale(300) }}" end="0,0" time="250" tween="cubic" easing="out" condition="Integer.IsGreater(Container(100).NumItems,0)">Conditional</animation>
    <animation effect="fade" start="0" end="100" time="200" tween="cubic" easing="out" condition="Integer.IsGreater(Container(100).NumItems,0)">Conditional</animation>
    <animation effect="slide" start="0,0" end="0,{{ vscale(300) }}" time="200" tween="cubic" easing="in">WindowClose</animation>
    {% with lpy = 36 + 84 * 8 & lph = 84 * 8 %}
    <control type="list" id="100">
        <posx>435</posx>
        <posy>{{ lpy|vscale }}r</posy>
        <width>1050</width>
        <height>{{ lph|vscale }}</height>
        <onup>noop</onup>
        <ondown>noop</ondown>
        <scrolltime tween="cubic" easing="out">160</scrolltime>
        <orientation>vertical</orientation>
        {% for r in range(1, 8) %}
        {% with sl = (8 - r) * 84 %}
        <animation effect="slide" end="0,{{ sl|vscale }}" time="0" condition="Integer.IsEqual(Container(100).NumItems,{{ r }})">Conditional</animation>
        {% endwith %}
        {% endfor %}
        <!-- ITEM LAYOUT ########################################## -->
        <itemlayout height="{{ vscale(84) }}">
            {% include "includes/plezy_select_row.xml.tpl" %}
        </itemlayout>
        <focusedlayout height="{{ vscale(84) }}">
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>1050</width>
                <height>{{ vscale(84) }}</height>
                <texture colordiffuse="{{ core.plezy.focus_fill }}">script.plex/white-square.png</texture>
            </control>
            {% include "includes/plezy_select_row.xml.tpl" with focused = True %}
        </focusedlayout>
    </control>
    {% endwith %}
</control>
{% endblock controls %}
