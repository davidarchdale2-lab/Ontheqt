{# One hub of the pre-play detail rail (Plezy TvBrowseRail at tallPosterScale .72): plezy_row_header over a
   plezy_hub_card row. Used by script-plex-pre_play.xml.tpl inside grouplist 60.
   params: n (row index 0-6: group 500+n, list 400+n), title, icon, kind, cw, ch, mask, boundary (paginated rows
   swallow left/right at the ends so the paginator can load the next page).
   Row height = 44 header + card band (ch + 88) + 4; the rail's slide for this row must use the same value. #}
{% with list_id = n + 400 & group_id = n + 500 & list_h = ch + 88 %}
<control type="group" id="{{ group_id }}">
    <visible>Integer.IsGreater(Container({{ list_id }}).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
    <defaultcontrol>{{ list_id }}</defaultcontrol>
    <width>1920</width>
    <height>{{ (ch + 136)|vscale }}</height>
    <!-- rows that slid above the active one leave the band; rows below it dim while the rail has focus -->
    <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),{{ n }}) + !String.IsEmpty(Window.Property(on.extras))">Conditional</animation>
    <animation effect="fade" start="100" end="70" time="160" condition="ControlGroup(60).HasFocus(0) + !Control.HasFocus({{ list_id }}) + !Integer.IsGreater(Window.Property(hub.focus),{{ n }})">Conditional</animation>
    {% include "includes/plezy_row_header.xml.tpl" with icon=icon & title=title & x=60 & y=0 %}
    <control type="list" id="{{ list_id }}">
        <posx>44</posx>
        <posy>{{ vscale(44) }}</posy>
        <width>1876</width>
        <height>{{ list_h|vscale }}</height>
        <onup>{% if n == 0 %}301{% else %}{{ list_id - 1 }}{% endif %}</onup>
        {% if n < 6 %}<ondown>{{ list_id + 1 }}</ondown>{% endif %}
        {% if boundary %}
        <onleft>noop</onleft>
        <onright>noop</onright>
        {% endif %}
        <scrolltime tween="cubic" easing="out">160</scrolltime>
        <orientation>horizontal</orientation>
        <preloaditems>4</preloaditems>
        {% include "includes/plezy_hub_card.xml.tpl" with kind=kind & focused=False & cw=cw & ch=ch & mask=mask & cond="none" & focus_id=list_id & hub_id=list_id & sub_always=True & placeholder_icon=placeholder_icon & selected_ring=selected_ring %}
        {% include "includes/plezy_hub_card.xml.tpl" with kind=kind & focused=True & cw=cw & ch=ch & mask=mask & cond="none" & focus_id=list_id & hub_id=list_id & sub_always=True & placeholder_icon=placeholder_icon & selected_ring=selected_ring %}
    </control>
</control>
{% endwith %}
