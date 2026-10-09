{% extends "default.xml.tpl" %}
{# Plezy actor / director screen (edde746/plezy lib/screens/actor_media_screen.dart): a round avatar with the name, the
   'Actor • 3 May 1970 (54) • Place' line and the bio, then the filmography (with a filter chip and the title count) and
   the "not in your library" discover rows as rails of poster cards. While a rail has focus the header scrolls away and the
   rows below move up one pitch (464px) per step, as in the home screen's rails.
   Python (lib/windows/person.py PersonWindow / ActorWindow / DirectorWindow) relies on: 400 (filmography), 401-406
   (discover rows in groups 501-506), 500 (filmography group), 300 (filter chip), 201/202/204 (header), hub.focus and
   on.extras (set on focus). Properties: loading, person.name, person.type_label, person.meta, person.thumb,
   person.summary, filmography.header, filmography.filter, filmography.total, discover.hub.N.label. #}
{% block headers %}<defaultcontrol>400</defaultcontrol>{% endblock %}
{# the back / search buttons stay over the artwork at all times, as in Plezy #}
{% block header_anim %}{% endblock %}
{% block header_bgfade %}{% endblock %}
{% block content %}
<control type="group" id="50">
    <defaultcontrol>400</defaultcontrol>
    {% for i in range(6) %}
    <animation effect="slide" end="0,{{ vscale(-464) }}" time="200" tween="quadratic" easing="out" condition="Integer.IsGreater(Window.Property(hub.focus),{{ i }}) + Control.IsVisible({{ i + 501 }})">Conditional</animation>
    {% endfor %}
    <posx>0</posx>
    <posy>0</posy>

    <!-- HEADER: avatar, name, meta line, bio -->
    <control type="group">
        <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),0)">Conditional</animation>
        <posx>0</posx>
        <posy>0</posy>
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>120</width>
            <height>{{ vscale(120) }}</height>
            <texture colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/circle.png</texture>
        </control>
        <control type="image">
            <posx>96</posx>
            <posy>{{ vscale(186) }}</posy>
            <width>48</width>
            <height>{{ vscale(48) }}</height>
            <texture colordiffuse="{{ core.plezy.faint }}">script.plex/plezy/icons/person.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>120</width>
            <height>{{ vscale(120) }}</height>
            <texture background="true" diffuse="script.plex/masks/role.png">$INFO[Window.Property(person.thumb)]</texture>
            <aspectratio scalediffuse="false" aligny="top">scale</aspectratio>
        </control>
        <control type="label">
            <posx>204</posx>
            <posy>{{ vscale(150) }}</posy>
            <width>1596</width>
            <height>{{ vscale(52) }}</height>
            <font>font32_title</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>$INFO[Window.Property(person.name)]</label>
        </control>
        <control type="label">
            <visible>!String.IsEmpty(Window.Property(person.meta))</visible>
            <posx>204</posx>
            <posy>{{ vscale(206) }}</posy>
            <width>1596</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[Window.Property(person.meta)]</label>
        </control>
        <control type="label">
            <visible>String.IsEmpty(Window.Property(person.meta))</visible>
            <posx>204</posx>
            <posy>{{ vscale(206) }}</posy>
            <width>1596</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[Window.Property(person.type_label)]</label>
        </control>
        <control type="textbox">
            <posx>204</posx>
            <posy>{{ vscale(250) }}</posy>
            <width>1080</width>
            <height>{{ vscale(114) }}</height>
            <font>font12</font>
            <align>left</align>
            <textcolor>{{ core.plezy.summary }}</textcolor>
            <autoscroll>false</autoscroll>
            <label>$INFO[Window.Property(person.summary)]</label>
        </control>
    </control>

    <!-- loading -->
    {% include "includes/plezy_spinner.xml.tpl" with x=930 & y=560 & size=60 & visible="!String.IsEmpty(Window.Property(loading))" %}

    <!-- FILMOGRAPHY: header with the title count and the filter chip, then the poster rail -->
    <control type="group" id="500">
        <visible>String.IsEmpty(Window.Property(loading))</visible>
        <defaultcontrol>400</defaultcontrol>
        <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),0)">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(392) }}</posy>
        <width>1920</width>
        <height>{{ vscale(488) }}</height>
        <control type="grouplist" id="350">
            <posx>60</posx>
            <posy>0</posy>
            <width>1800</width>
            <height>{{ vscale(48) }}</height>
            <orientation>horizontal</orientation>
            <align>left</align>
            <itemgap>0</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <control type="image">
                <posx>0</posx>
                <posy>{{ vscale(10) }}</posy>
                <width>28</width>
                <height>{{ vscale(28) }}</height>
                <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/hub_person.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
            <control type="label">
                <posx>12</posx>
                <posy>0</posy>
                <width>auto</width>
                <height>{{ vscale(48) }}</height>
                <font>font14</font>
                <aligny>center</aligny>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <label>[B]$INFO[Window.Property(filmography.header)][/B]</label>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Window.Property(filmography.total))</visible>
                <posx>16</posx>
                <posy>0</posy>
                <width>auto</width>
                <height>{{ vscale(48) }}</height>
                <font>font12</font>
                <aligny>center</aligny>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.muted }}</textcolor>
                <label>$INFO[Window.Property(filmography.total)]</label>
            </control>
            <!-- filter chip (Plezy FocusableFilterChip): tonal pill, text pill while focused -->
            <control type="button" id="300">
                <posx>28</posx>
                <posy>0</posy>
                <width max="420">auto</width>
                <height>{{ vscale(48) }}</height>
                <onup>201</onup>
                <ondown condition="Integer.IsGreater(Container(400).NumItems,0)">400</ondown>
                <ondown>401</ondown>
                <onleft>noop</onleft>
                <onright>noop</onright>
                <font>font12</font>
                <align>center</align>
                <aligny>center</aligny>
                <textoffsetx>24</textoffsetx>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <focusedcolor>{{ core.plezy.on_primary }}</focusedcolor>
                <texturenofocus border="24" colordiffuse="{{ core.plezy.tonal }}">script.plex/plezy/pill-48.png</texturenofocus>
                <texturefocus border="24" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-48.png</texturefocus>
                <label>$INFO[Window.Property(filmography.filter)]</label>
            </control>
        </control>
        <control type="list" id="400">
            <posx>44</posx>
            <posy>{{ vscale(48) }}</posy>
            <width>1876</width>
            <height>{{ vscale(420) }}</height>
            <onup>300</onup>
            <ondown>401</ondown>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=False & cw=200 & ch=300 & mask="script.plex/plezy/mask-poster.png" & cond="none" & focus_id=400 & hub_id=400 & sub_always=True %}
            {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=True & cw=200 & ch=300 & mask="script.plex/plezy/mask-poster.png" & cond="none" & focus_id=400 & hub_id=400 & sub_always=True %}
        </control>
    </control>

    <!-- empty filmography -->
    <control type="label">
        <visible>String.IsEmpty(Window.Property(loading)) + !Integer.IsGreater(Container(400).NumItems,0)</visible>
        <posx>0</posx>
        <posy>{{ vscale(560) }}</posy>
        <width>1920</width>
        <height>{{ vscale(60) }}</height>
        <font>font13</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$ADDON[script.plezy.native 32478]</label>
    </control>

    <!-- DISCOVER ROWS (not in the library): one pitch (464) apart, the first peeks under the filmography -->
    {% for i in range(6) %}
    {% with list_id = i + 401 & group_id = i + 501 & row_y = i * 464 + 880 %}
    <control type="group" id="{{ group_id }}">
        <visible>Integer.IsGreater(Container({{ list_id }}).NumItems,0)</visible>
        <defaultcontrol>{{ list_id }}</defaultcontrol>
        <animation effect="fade" start="100" end="0" time="160" condition="Integer.IsGreater(Window.Property(hub.focus),{{ i + 1 }})">Conditional</animation>
        <animation effect="fade" start="100" end="45" time="160" condition="!Control.HasFocus({{ list_id }})">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(row_y) }}</posy>
        <width>1920</width>
        <height>{{ vscale(464) }}</height>
        <!-- row header (plezy_row_header's look; the title property name carries the row number) -->
        <control type="image">
            <posx>60</posx>
            <posy>{{ vscale(8) }}</posy>
            <width>28</width>
            <height>{{ vscale(28) }}</height>
            <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/hub_person.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="label">
            <posx>100</posx>
            <posy>0</posy>
            <width>1500</width>
            <height>{{ vscale(44) }}</height>
            <font>font14</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]$INFO[Window.Property(discover.hub.{{ i }}.label)][/B]</label>
        </control>
        <control type="list" id="{{ list_id }}">
            <posx>44</posx>
            <posy>{{ vscale(44) }}</posy>
            <width>1876</width>
            <height>{{ vscale(420) }}</height>
            {% if loop.is_first %}<onup condition="Integer.IsGreater(Container(400).NumItems,0)">400</onup>
            <onup>300</onup>{% else %}<onup>{{ list_id - 1 }}</onup>{% endif %}
            <ondown>{% if loop.is_last %}{{ list_id }}{% else %}{{ list_id + 1 }}{% endif %}</ondown>
            <scrolltime tween="cubic" easing="out">160</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=False & cw=200 & ch=300 & mask="script.plex/plezy/mask-poster.png" & cond="none" & focus_id=list_id & hub_id=list_id & sub_always=True %}
            {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=True & cw=200 & ch=300 & mask="script.plex/plezy/mask-poster.png" & cond="none" & focus_id=list_id & hub_id=list_id & sub_always=True %}
        </control>
    </control>
    {% endwith %}
    {% endfor %}
</control>
{% endblock content %}
