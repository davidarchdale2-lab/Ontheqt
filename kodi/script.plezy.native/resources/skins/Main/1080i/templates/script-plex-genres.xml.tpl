{% extends "library.xml.tpl" %}
{# Plezy has no genre browser; the genre tiles use Plezy's wide media card (16:9 artwork, semi-bold title under it,
   ring + glow + 1.03 scale on focus, a surface placeholder with the genre icon until artwork loads) in a grid.
   The library header's sort / filter row does not apply here, so it is dropped.
   Python (lib/windows/genres.py) relies on: 101 (genre panel), 50 (content), 200-204 (header), screen.title / items.count. #}
{% block headers %}<defaultcontrol>50</defaultcontrol>{% endblock %}
{% block header_bg %}{% endblock %}
{% block header_animation %}{% endblock %}
{# the library header's sort / filter row has no handlers here: nothing is drawn. The ids stay as invisible stubs only so
   the layout keeps the control ids every library window shares (tools/check_layouts.py); genres.py never reads them #}
{% block filteropts_grouplist %}
<control type="grouplist" id="600">
    <visible>false</visible>
    <width>10</width>
    <height>10</height>
    {% for stub in (210, 211, 310, 311, 312) %}
    <control type="button" id="{{ stub }}">
        <enable>false</enable>
        <width>1</width>
        <height>1</height>
        <label> </label>
    </control>
    {% endfor %}
</control>
{% endblock %}

{% block content %}
<control type="group" id="50">
    <visible>!String.IsEmpty(Window.Property(initialized))</visible>
    <defaultcontrol>101</defaultcontrol>
    <posx>0</posx>
    <posy>{{ vscale(150) }}</posy>

    <control type="panel" id="101">
        <posx>44</posx>
        <posy>0</posy>
        <width>1832</width>
        <height>{{ vscale(930) }}</height>
        <onup>200</onup>
        <scrolltime tween="cubic" easing="out">200</scrolltime>
        <orientation>vertical</orientation>
        <preloaditems>2</preloaditems>
        {% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=False & cw=400 & ch=225 & mask="script.plex/plezy/mask-wide.png" & cond="none" & focus_id=101 & hub_id=101 & item_h=315 & placeholder_icon="script.plex/plezy/icons/hub_genre.png" %}
        {% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=True & cw=400 & ch=225 & mask="script.plex/plezy/mask-wide.png" & cond="none" & focus_id=101 & hub_id=101 & item_h=315 & placeholder_icon="script.plex/plezy/icons/hub_genre.png" %}
    </control>
</control>
{% endblock content %}
