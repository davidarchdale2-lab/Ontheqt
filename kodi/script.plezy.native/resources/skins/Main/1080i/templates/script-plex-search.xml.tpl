{% extends "base.xml.tpl" %}
{# Plezy TV search (edde746/plezy lib/screens/search_screen.dart, search_input_field.dart, tv_virtual_keyboard.dart).
   A full screen on the Plezy background, 1080p coordinates:
     - the keyboard panel (x 96-664): a stadium input (650 edit, 651 query + caret, 999 clear), the 6x6 alphabetical
       keyboard (1001-1036) and the icon keys delete / space / clear / search (951-954, group 950). Plezy's own keyboard is
       a QWERTY modal; this one keeps the add-on's persistent grid. With the Kodi keyboard setting (hide.kbd) the panel
       shrinks to the input.
     - the results column (x 688-1920): filter chips (grouplist 900: 901-906) over TV shelves (grouplist 3000: row groups
       2000-2011 holding the hub lists 2100-2111), or the recent searches (list 2050), or a state message.
   Plezy shows one ranked list; the Plex server answers with one hub per kind, so each hub is a Plezy HubSection shelf.
   Window properties set by lib/windows/search.py: hide.kbd, search.section (all|movie|show|artist|photo|people),
   search.has.query, search.chips, search.kind.*, show.history, searching, no.results, search.error, hub.<id>, hub.icon.<id>,
   hub.display.<id>, hub.text2lines.<id>, hub.focus.
   Rows are 456 apart (44 header + 402 cards + 10 gap), the active one slides to the top; the row groups above it fade out. #}
{% block headers %}<onload>SetProperty(dropdown,1)</onload>{% endblock %}
{% block backgroundcolor %}{% endblock %}
{% block controls %}
<!-- BACKGROUND: an opaque Plezy screen; the calling window's own search scrim and fanart end up hidden underneath.
     Full height even on 4:3, where vscale shortens the layout -->
<control type="image">
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.bg }}">script.plex/white-square.png</texture>
</control>
<control type="label">
    <posx>120</posx>
    <posy>{{ vscale(40) }}</posy>
    <width>520</width>
    <height>{{ vscale(48) }}</height>
    <font>font13</font>
    <align>left</align>
    <aligny>center</aligny>
    <scroll>false</scroll>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <label>[B]$ADDON[script.plezy.native 32431][/B]</label>
</control>

<!-- KEYBOARD PANEL (Plezy's keyboard card: surface, r28) -->
<control type="image">
    <visible>String.IsEmpty(Window.Property(hide.kbd))</visible>
    <posx>96</posx>
    <posy>{{ vscale(104) }}</posy>
    <width>568</width>
    <height>{{ vscale(728) }}</height>
    <texture border="28" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r28.png</texture>
</control>
<control type="image">
    <visible>!String.IsEmpty(Window.Property(hide.kbd))</visible>
    <posx>96</posx>
    <posy>{{ vscale(104) }}</posy>
    <width>568</width>
    <height>{{ vscale(112) }}</height>
    <texture border="28" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r28.png</texture>
</control>

<control type="group" id="899">
    <!-- ENTRY: SearchInputField, a stadium at 8% text that goes to 18% on focus (the fill is the only focus cue) -->
    <control type="edit" id="650">
        <posx>120</posx>
        <posy>{{ vscale(128) }}</posy>
        <width>520</width>
        <height>{{ vscale(64) }}</height>
        <align>left</align>
        <aligny>center</aligny>
        <ondown condition="String.IsEmpty(Window.Property(hide.kbd))">1001</ondown>
        <onright condition="!String.IsEmpty(Window.Property(search.has.query))">999</onright>
        <onright condition="String.IsEmpty(Window.Property(search.has.query)) + !String.IsEmpty(Window.Property(show.history))">2050</onright>
        <onright condition="String.IsEmpty(Window.Property(search.has.query)) + String.IsEmpty(Window.Property(show.history))">3000</onright>
        <textcolor>00000000</textcolor>
        <label> </label>
        <hinttext> </hinttext>
        <font>font13</font>
        <textoffsetx>68</textoffsetx>
        <texturefocus border="32" colordiffuse="{{ core.plezy.input_focus_fill }}">script.plex/plezy/pill-64.png</texturefocus>
        <texturenofocus border="32" colordiffuse="{{ core.plezy.input_fill }}">script.plex/plezy/pill-64.png</texturenofocus>
        <pulseonselect>no</pulseonselect>
    </control>
    <control type="image">
        <visible>!Control.HasFocus(650)</visible>
        <posx>140</posx>
        <posy>{{ vscale(144) }}</posy>
        <width>32</width>
        <height>{{ vscale(32) }}</height>
        <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/search.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="image">
        <visible>Control.HasFocus(650)</visible>
        <posx>140</posx>
        <posy>{{ vscale(144) }}</posy>
        <width>32</width>
        <height>{{ vscale(32) }}</height>
        <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/search.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <visible>String.IsEmpty(Window.Property(search.has.query))</visible>
        <posx>202</posx>
        <posy>{{ vscale(128) }}</posy>
        <width>430</width>
        <height>{{ vscale(64) }}</height>
        <font>font12</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$ADDON[script.plezy.native 35180]</label>
    </control>
    <control type="label" id="651">
        <scroll>false</scroll>
        <posx>188</posx>
        <posy>{{ vscale(128) }}</posy>
        <width>388</width>
        <height>{{ vscale(64) }}</height>
        <align>left</align>
        <aligny>center</aligny>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <font>font13</font>
        <label> </label>
    </control>
    <!-- the field's clear (x) button, only while there is text; RIGHT from the field lands on it -->
    <control type="button" id="999">
        <visible>!String.IsEmpty(Window.Property(search.has.query))</visible>
        <posx>576</posx>
        <posy>{{ vscale(132) }}</posy>
        <width>56</width>
        <height>{{ vscale(56) }}</height>
        <onleft>650</onleft>
        {% for sec in ["all", "movie", "show", "artist", "photo", "people"] %}{% with n = loop.index %}
        <onright condition="Control.IsVisible(900) + String.IsEqual(Window.Property(search.section),{{ sec }})">{{ n + 901 }}</onright>
        {% endwith %}{% endfor %}
        <onright condition="!Control.IsVisible(900) + !String.IsEmpty(Window.Property(show.history))">2050</onright>
        <onright condition="!Control.IsVisible(900) + String.IsEmpty(Window.Property(show.history))">3000</onright>
        <ondown condition="String.IsEmpty(Window.Property(hide.kbd))">1006</ondown>
        <font>font12</font>
        <texturefocus border="28" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-56.png</texturefocus>
        <texturenofocus>-</texturenofocus>
        <label> </label>
    </control>
    <control type="image">
        <visible>!String.IsEmpty(Window.Property(search.has.query)) + !Control.HasFocus(999)</visible>
        <posx>588</posx>
        <posy>{{ vscale(144) }}</posy>
        <width>32</width>
        <height>{{ vscale(32) }}</height>
        <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/close.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="image">
        <visible>!String.IsEmpty(Window.Property(search.has.query)) + Control.HasFocus(999)</visible>
        <posx>588</posx>
        <posy>{{ vscale(144) }}</posy>
        <width>32</width>
        <height>{{ vscale(32) }}</height>
        <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/close.png</texture>
        <aspectratio>keep</aspectratio>
    </control>

    <!-- KEYBOARD: 6x6, a-z then 0-9 (ids 1001-1036). Idle keys are bare glyphs (Plezy's idle key colour is the
         panel's), the focused key is a white r14 tile. Labels are lowercase like what they insert, and never bare
         digits (Kodi would read those as string ids) -->
    <control type="group">
        <visible>String.IsEmpty(Window.Property(hide.kbd))</visible>
        <posx>120</posx>
        <posy>{{ vscale(216) }}</posy>
        {% for row in ["abcdef", "ghijkl", "mnopqr", "stuvwx", "yz0123", "456789"] %}
        {% for ch in row %}
        {% with r = loop.parent.index & c = loop.index %}
        {% with kid = 1001 + r * 6 + c %}
        <control type="button" id="{{ kid }}">
            {% if kid == 1001 %}<visible allowhiddenfocus="true">true</visible>{% endif %}
            <posx>{{ 88 * c }}</posx>
            <posy>{{ (88 * r)|vscale }}</posy>
            <width>80</width>
            <height>{{ vscale(80) }}</height>
            <onleft>{% if c == 0 %}{{ kid + 5 }}{% else %}{{ kid - 1 }}{% endif %}</onleft>
            {% if c == 5 %}
            <onright condition="!String.IsEmpty(Window.Property(show.history))">2050</onright>
            <onright condition="String.IsEmpty(Window.Property(show.history))">3000</onright>
            {% else %}
            <onright>{{ kid + 1 }}</onright>
            {% endif %}
            {% if r == 0 %}
            {% if c == 5 %}
            <onup condition="!String.IsEmpty(Window.Property(search.has.query))">999</onup>
            <onup condition="String.IsEmpty(Window.Property(search.has.query))">650</onup>
            {% else %}
            <onup>650</onup>
            {% endif %}
            {% else %}
            <onup>{{ kid - 6 }}</onup>
            {% endif %}
            {% if r == 5 %}
            <ondown>{% if c < 2 %}951{% elif c == 2 %}952{% elif c < 5 %}953{% else %}954{% endif %}</ondown>
            {% else %}
            <ondown>{{ kid + 6 }}</ondown>
            {% endif %}
            <font>font14</font>
            <align>center</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <focusedcolor>{{ core.plezy.on_primary }}</focusedcolor>
            <texturefocus border="14" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/r14.png</texturefocus>
            <texturenofocus>-</texturenofocus>
            <label>[B]{{ ch }}[/B]</label>
        </control>
        {% endwith %}
        {% endwith %}
        {% endfor %}
        {% endfor %}
    </control>

    <!-- ACTION KEYS: delete, space, clear, search (Plezy's keyboard submit focuses the results; see search.py) -->
    <control type="group" id="950">
        <visible>String.IsEmpty(Window.Property(hide.kbd))</visible>
        <posx>120</posx>
        <posy>{{ vscale(744) }}</posy>
        <width>520</width>
        <height>{{ vscale(64) }}</height>
        {% include "includes/search_key.xml.tpl" with id=951 & x=0 & icon="script.plex/plezy/icons/backspace.png" & onleft=954 & onright=952 & onup=1031 %}
        {% include "includes/search_key.xml.tpl" with id=952 & x=132 & icon="script.plex/plezy/icons/space_bar.png" & isize=44 & onleft=951 & onright=953 & onup=1033 %}
        {% include "includes/search_key.xml.tpl" with id=953 & x=264 & icon="script.plex/plezy/icons/clear_all.png" & onleft=952 & onright=954 & onup=1034 %}
        {% include "includes/search_key.xml.tpl" with id=954 & x=396 & icon="script.plex/plezy/icons/search.png" & onleft=953 & results_right=True & onup=1036 %}
    </control>
</control>

<!-- FILTER CHIPS (FocusableTabChip): All plus the kinds the answer holds; the grouplist closes up around hidden chips -->
<control type="grouplist" id="900">
    <visible>!String.IsEmpty(Window.Property(search.has.query)) + !String.IsEmpty(Window.Property(search.chips))</visible>
    <defaultcontrol>901</defaultcontrol>
    <posx>704</posx>
    <posy>{{ vscale(136) }}</posy>
    <width>1200</width>
    <height>{{ vscale(48) }}</height>
    <itemgap>12</itemgap>
    <orientation>horizontal</orientation>
    <onleft>999</onleft>
    <onup>650</onup>
    <ondown>3000</ondown>
    {% include "includes/plezy_chip.xml.tpl" with id=901 & width=104 & label="$ADDON[script.plezy.native 32345]" & selected="String.IsEqual(Window.Property(search.section),all)" %}
    {% include "includes/plezy_chip.xml.tpl" with id=902 & width=148 & label="$ADDON[script.plezy.native 32348]" & selected="String.IsEqual(Window.Property(search.section),movie)" & visible="!String.IsEmpty(Window.Property(search.kind.movie))" %}
    {% include "includes/plezy_chip.xml.tpl" with id=903 & width=140 & label="$ADDON[script.plezy.native 32350]" & selected="String.IsEqual(Window.Property(search.section),show)" & visible="!String.IsEmpty(Window.Property(search.kind.show))" %}
    {% include "includes/plezy_chip.xml.tpl" with id=904 & width=132 & label="$ADDON[script.plezy.native 32394]" & selected="String.IsEqual(Window.Property(search.section),artist)" & visible="!String.IsEmpty(Window.Property(search.kind.artist))" %}
    {% include "includes/plezy_chip.xml.tpl" with id=905 & width=144 & label="[CAPITALIZE]$ADDON[script.plezy.native 32349][/CAPITALIZE]" & selected="String.IsEqual(Window.Property(search.section),photo)" & visible="!String.IsEmpty(Window.Property(search.kind.photo))" %}
    {% include "includes/plezy_chip.xml.tpl" with id=906 & width=144 & label="$ADDON[script.plezy.native 35185]" & selected="String.IsEqual(Window.Property(search.section),people)" & visible="!String.IsEmpty(Window.Property(search.kind.people))" %}
</control>

<!-- RESULTS: one TV shelf per hub. Dimmed (not hidden) while a search runs, so focus is never lost -->
<control type="grouplist" id="3000">
    <animation effect="fade" start="100" end="35" time="160" condition="!String.IsEmpty(Window.Property(searching))">Conditional</animation>
    {% for i in range(1, core.search_hub_count) %}
    <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),{{ i - 1 }}) + Control.IsVisible({{ i + 1999 }})" reversible="true">
        <effect type="slide" end="0,{{ vscale(-456) }}" time="160" tween="cubic" easing="out" />
    </animation>
    {% endfor %}
    <defaultcontrol always="true">2000</defaultcontrol>
    <posx>688</posx>
    <posy>{{ vscale(208) }}</posy>
    <width>1232</width>
    {% with n = core.search_hub_count %}{% with grouplist_height = n * 456 + 100 %}
    <height>{{ vscale(grouplist_height) }}</height>
    {% endwith %}{% endwith %}
    <itemgap>{{ vscale(10) }}</itemgap>{# rows are vscale(456) apart, which is what each row's slide animation moves by #}
    <orientation>vertical</orientation>
    <usecontrolcoords>true</usecontrolcoords>
    <scrolltime tween="cubic" easing="out">160</scrolltime>

{% for i in range(core.search_hub_count) %}
{% with hub_id = i + 2100 & group_id = i + 2000 %}
    <control type="group" id="{{ group_id }}">
        <visible>Integer.IsGreater(Container({{ hub_id }}).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>{{ hub_id }}</defaultcontrol>
        <width>1232</width>
        <height>{{ vscale(446) }}</height>
        <!-- rows that slid above the active one leave the stage; the others dim while a shelf has focus -->
        <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),{{ i }})">Conditional</animation>
        <animation effect="fade" start="100" end="55" time="160" condition="ControlGroup(3000).HasFocus(0) + !Control.HasFocus({{ hub_id }}) + !Integer.IsGreater(Window.Property(hub.focus),{{ i }})">Conditional</animation>
        <!-- plezy_row_header: the title and icon come from window properties the include cannot name -->
        <control type="image">
            <posx>16</posx>
            <posy>{{ vscale(8) }}</posy>
            <width>28</width>
            <height>{{ vscale(28) }}</height>
            <texture colordiffuse="{{ core.plezy.text }}" fallback="script.plex/plezy/icons/hub_default.png">$INFO[Window.Property(hub.icon.{{ hub_id }})]</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="label">
            <posx>56</posx>
            <posy>0</posy>
            <width>1100</width>
            <height>{{ vscale(44) }}</height>
            <font>font14</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[Window.Property(hub.{{ hub_id }})][/B]</label>
        </control>
        <control type="list" id="{{ hub_id }}">
            <posx>0</posx>
            <posy>{{ vscale(44) }}</posy>
            <width>1232</width>
            <height>{{ vscale(402) }}</height>
            <onleft>899</onleft>
            {% if loop.is_first %}
            {% for sec in ["all", "movie", "show", "artist", "photo", "people"] %}{% with n = loop.index %}
            <onup condition="Control.IsVisible(900) + String.IsEqual(Window.Property(search.section),{{ sec }})">{{ n + 901 }}</onup>
            {% endwith %}{% endfor %}
            <onup condition="!Control.IsVisible(900)">650</onup>
            {% else %}
            <onup>{{ hub_id - 1 }}</onup>
            {% endif %}
            <ondown>{% if loop.is_last %}{{ hub_id }}{% else %}{{ hub_id + 1 }}{% endif %}</ondown>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            {% include "includes/search_hub_poster.xml.tpl" %}
            {% include "includes/search_hub_square.xml.tpl" %}
            {% include "includes/search_hub_ar16x9.xml.tpl" %}
            {% include "includes/search_hub_circle.xml.tpl" %}
        </control>
    </control>
{% endwith %}
{% endfor %}

</control>

<!-- RECENT SEARCHES (a fork feature, Plezy has none): a hub-style header over list tiles with a fill-only focus -->
<control type="group">
    <visible>!String.IsEmpty(Window.Property(show.history))</visible>
    {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/history.png" & title="$ADDON[script.plezy.native 35004]" & x=704 & y=138 & width=900 %}
    <control type="list" id="2050">
        <posx>688</posx>
        <posy>{{ vscale(208) }}</posy>
        <width>672</width>
        <height>{{ vscale(832) }}</height>
        <orientation>vertical</orientation>
        <onleft>650</onleft>
        <scrolltime tween="cubic" easing="out">160</scrolltime>
        <itemlayout width="672" height="{{ vscale(64) }}">
            <control type="image">
                <posx>16</posx>
                <posy>{{ vscale(16) }}</posy>
                <width>32</width>
                <height>{{ vscale(32) }}</height>
                <texture colordiffuse="{{ core.plezy.muted }}">$INFO[ListItem.Property(icon)]</texture>
                <aspectratio>keep</aspectratio>
            </control>
            <control type="label">
                <posx>64</posx>
                <posy>0</posy>
                <width>592</width>
                <height>{{ vscale(64) }}</height>
                <font>font13</font>
                <align>left</align>
                <aligny>center</aligny>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <label>$INFO[ListItem.Label]</label>
            </control>
        </itemlayout>
        <focusedlayout width="672" height="{{ vscale(64) }}">
            <control type="image">
                <visible>Control.HasFocus(2050)</visible>
                <posx>0</posx>
                <posy>0</posy>
                <width>672</width>
                <height>{{ vscale(64) }}</height>
                <texture border="8" colordiffuse="{{ core.plezy.focus_fill }}">script.plex/plezy/r8.png</texture>
            </control>
            <control type="image">
                <posx>16</posx>
                <posy>{{ vscale(16) }}</posy>
                <width>32</width>
                <height>{{ vscale(32) }}</height>
                <texture colordiffuse="{{ core.plezy.text }}">$INFO[ListItem.Property(icon)]</texture>
                <aspectratio>keep</aspectratio>
            </control>
            <control type="label">
                <posx>64</posx>
                <posy>0</posy>
                <width>592</width>
                <height>{{ vscale(64) }}</height>
                <font>font13</font>
                <align>left</align>
                <aligny>center</aligny>
                <scroll>true</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <label>$INFO[ListItem.Label]</label>
            </control>
        </focusedlayout>
    </control>
</control>

<!-- STATES (StateMessageWidget), centred in the results column -->
{% include "includes/plezy_state_message.xml.tpl" with icon="script.plex/plezy/icons/search.png" & title="$ADDON[script.plezy.native 35181]" & subtitle="$ADDON[script.plezy.native 35182]" & x=704 & y=512 & w=1216 & visible="String.IsEmpty(Window.Property(search.has.query)) + String.IsEmpty(Window.Property(show.history))" %}
{% include "includes/plezy_state_message.xml.tpl" with icon="script.plex/plezy/icons/search_off.png" & title="$ADDON[script.plezy.native 35183]" & subtitle="$ADDON[script.plezy.native 35184]" & x=704 & y=512 & w=1216 & visible="!String.IsEmpty(Window.Property(no.results)) + String.IsEmpty(Window.Property(searching))" %}
{% include "includes/plezy_state_message.xml.tpl" with icon="script.plex/plezy/icons/search_off.png" & title="$ADDON[script.plezy.native 35186]" & x=704 & y=512 & w=1216 & visible="!String.IsEmpty(Window.Property(search.error)) + String.IsEmpty(Window.Property(searching))" %}
{% include "includes/plezy_spinner.xml.tpl" with x=1284 & y=616 & size=56 & visible="!String.IsEmpty(Window.Property(searching))" %}
{% endblock %}
