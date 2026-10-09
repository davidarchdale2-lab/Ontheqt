{% extends "base.xml.tpl" %}
{# Photo viewer. Plezy has no counterpart, so it follows its player idiom (see PLEZY_DESIGN.md): the photo full-bleed on the
   dark background, a bottom scrim with the title and date and the themed transport row while the OSD shows, the queue
   strip sliding up from the bottom edge and an info panel as a floating surface at the right.
   Python (lib/windows/photos.py) relies on: 600 (the photo: top-level 1920x1080 at 0,0, rotated and resized by Python),
   250 (overlay button), 200 (OSD group; slides up with the queue strip), 400 (transport: 401 repeat, 402 shuffle, 403 rotate,
   404 previous, 406 play/pause, 407 stop, 409 next, 412 queue strip, 413 info), 500 / 501 (queue strip list / overlay
   button), 650 / 659 (title / date rows of the info panel). #}
{% block headers %}
    <defaultcontrol>250</defaultcontrol>
    <zorder>100</zorder>
{% endblock %}

{% block controls %}
<control type="group">
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture colordiffuse="{{ core.plezy.bg }}">script.plex/white-square.png</texture>
    </control>
    <control type="image" id="600">
        <!-- Doesn't work for all aspects -->
        <!-- <animation effect="zoom" start="56" end="100" time="200" center="960,540" reversible="false" condition="String.IsEqual(Window.Property(rotate),90) | String.IsEqual(Window.Property(rotate),270)">Conditional</animation>
        <animation effect="zoom" start="178" end="100" time="200" center="960,540" reversible="false" condition="String.IsEqual(Window.Property(rotate),0) | String.IsEqual(Window.Property(rotate),180)">Conditional</animation> -->
        <animation effect="rotate" time="200" start="0" end="90" center="960,540" reversible="false" condition="Integer.IsGreater(Window.Property(rotate),89)">Conditional</animation>
        <animation effect="rotate" time="200" start="0" end="90" center="960,540" reversible="false" condition="Integer.IsGreater(Window.Property(rotate),179)">Conditional</animation>
        <animation effect="rotate" time="200" start="0" end="90" center="960,540" reversible="false" condition="Integer.IsGreater(Window.Property(rotate),269)">Conditional</animation>
        <animation effect="rotate" time="200" start="270" end="360" center="960,540" reversible="false" condition="!Integer.IsGreater(Window.Property(rotate),89)">Conditional</animation>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <fadetime>1000</fadetime>
        <texture background="true">$INFO[Window.Property(photo)]</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <!-- loading: a spinner on a surface pill (Plezy's CircularProgressIndicator) -->
    <control type="group">
        <visible>!String.IsEmpty(Window.Property(is.updating))</visible>
        <animation effect="fade" time="500" delay="500">VisibleChange</animation>
        <control type="image">
            <posx>840</posx>
            <posy>{{ vscale(465) }}</posy>
            <width>240</width>
            <height>{{ vscale(150) }}</height>
            <texture border="20" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r20.png</texture>
        </control>
        {% include "includes/plezy_spinner.xml.tpl" with x=930 & y=510 & size=60 %}
    </control>
</control>
<control type="togglebutton" id="250">
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texturefocus>-</texturefocus>
    <texturenofocus>-</texturenofocus>
    <usealttexture>!String.IsEmpty(Window.Property(OSD))</usealttexture>
    <alttexturefocus>-</alttexturefocus>
    <alttexturenofocus>-</alttexturenofocus>
    <label> </label>
    <onclick>SetProperty(OSD,1)</onclick>
    <onclick>SetFocus(406)</onclick>
    <altclick>SetProperty(OSD,)</altclick>
    <ondown>SetProperty(OSD,1)</ondown>
    <ondown>SetFocus(400)</ondown>
    <ondown>SetFocus(406)</ondown>
    <onfocus condition="!String.IsEmpty(Window.Property(show.pqueue))">SetFocus(501)</onfocus>
    <onfocus condition="!String.IsEmpty(Window.Property(OSD))">SetFocus(400)</onfocus>
</control>
<control type="group" id="200">
    <animation effect="slide" start="0,0" end="0,{{ vscale(-135) }}" time="100" condition="!String.IsEmpty(Window.Property(show.pqueue))">Conditional</animation>
    <posx>0</posx>
    <posy>0</posy>
    <control type="group">
        <visible allowhiddenfocus="true">!String.IsEmpty(Window.Property(OSD))</visible>
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
        <!-- bottom scrim, title and date -->
        <control type="image">
            <posx>0</posx>
            <posy>{{ vscale(720) }}</posy>
            <width>1920</width>
            <height>{{ vscale(360) }}</height>
            <texture>script.plex/plezy/scrim-bottom.png</texture>
        </control>
        <control type="label">
            <posx>96</posx>
            <posy>{{ vscale(852) }}</posy>
            <width>1200</width>
            <height>{{ vscale(40) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
            <label>[B]$INFO[Window.Property(photo.title)][/B]</label>
        </control>
        <control type="label">
            <posx>96</posx>
            <posy>{{ vscale(894) }}</posy>
            <width>1200</width>
            <height>{{ vscale(32) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
            <label>$INFO[Window.Property(photo.date)]</label>
        </control>
        <control type="grouplist" id="400">
            <defaultcontrol>406</defaultcontrol>
            <posx>360</posx>
            <posy>{{ vscale(930) }}</posy>
            <width>1200</width>
            <height>{{ vscale(145) }}</height>
            <align>center</align>
            <onup>250</onup>
            <onup>SetProperty(OSD,)</onup>
            <ondown>250</ondown>
            <itemgap>0</itemgap>
            <orientation>horizontal</orientation>
            <scrolltime tween="quadratic" easing="out">200</scrolltime>
            <usecontrolcoords>true</usecontrolcoords>

            {% include "includes/music_button.xml.tpl" with bid=401 & asset="repeat" & toggle="!String.IsEmpty(Window.Property(pq.repeat))" & vis="String.IsEmpty(Window.Property(no.playlist))" %}
            {% include "includes/music_button.xml.tpl" with bid=421 & asset="repeat" & disabled=True & vis="!String.IsEmpty(Window.Property(no.playlist))" %}
            {% include "includes/music_button.xml.tpl" with bid=402 & asset="shuffle" & toggle="!String.IsEmpty(Window.Property(pq.shuffled))" & vis="String.IsEmpty(Window.Property(no.playlist))" %}
            {% include "includes/music_button.xml.tpl" with bid=422 & asset="shuffle" & disabled=True & vis="!String.IsEmpty(Window.Property(no.playlist))" %}
            {% include "includes/music_button.xml.tpl" with bid=403 & asset="rotate" %}
            {% include "includes/music_button.xml.tpl" with bid=404 & asset="next" & flip=True & vis="String.IsEmpty(Window.Property(hide.prev))" %}
            {% include "includes/music_button.xml.tpl" with bid=424 & asset="next" & flip=True & disabled=True & vis="!String.IsEmpty(Window.Property(hide.prev))" %}
            {% include "includes/music_button.xml.tpl" with bid=406 & asset="play" & alt_asset="pause" & toggle="!String.IsEmpty(Window.Property(playing))" & neutral=True %}
            {% include "includes/music_button.xml.tpl" with bid=407 & asset="stop" %}
            {% include "includes/music_button.xml.tpl" with bid=409 & asset="next" & vis="String.IsEmpty(Window.Property(hide.next))" %}
            {% include "includes/music_button.xml.tpl" with bid=419 & asset="next" & disabled=True & vis="!String.IsEmpty(Window.Property(hide.next))" %}
            {% include "includes/music_button.xml.tpl" with bid=412 & asset="square2x2" & toggle="!String.IsEmpty(Window.Property(show.pqueue))" & onclick="SetProperty(show.pqueue,1)" & altclick="SetProperty(show.pqueue,)" %}
            {% include "includes/music_button.xml.tpl" with bid=413 & asset="info" & toggle="!String.IsEmpty(Window.Property(show.info))" & onclick="SetProperty(show.info,1)" & altclick="SetProperty(show.info,)" %}
            {% include "includes/music_button.xml.tpl" with bid=414 & asset="tags" & vis="false" %}
            {% include "includes/music_button.xml.tpl" with bid=411 & asset="more" & vis="false" %}
        </control>
    </control>

    <!-- queue strip: on the background colour under the screen's bottom edge, brought in by group 200's slide -->
    <control type="button" id="501">
        <posx>0</posx>
        <posy>1080</posy>
        <width>1920</width>
        <height>{{ vscale(135) }}</height>
        <onup>SetProperty(OSD,1)</onup>
        <onup>400</onup>
        <font>font12</font>
        <texturefocus>-</texturefocus>
        <texturenofocus>-</texturenofocus>
        <label> </label>
        <onclick>SetProperty(OSD,1)</onclick>
        <onclick>SetFocus(400)</onclick>
    </control>
    <control type="image">
        <posx>0</posx>
        <posy>1080</posy>
        <width>1920</width>
        <height>135</height>
        <texture colordiffuse="{{ core.plezy.bg }}">script.plex/white-square.png</texture>
    </control>
    <control type="fixedlist" id="500">
        <posx>0</posx>
        <posy>1080</posy>
        <width>1920</width>
        <height>{{ vscale(135) }}</height>
        <scrolltime>0</scrolltime>
        <orientation>horizontal</orientation>
        <preloaditems>4</preloaditems>
        <focusposition>7</focusposition>
        <itemlayout width="128">
            <control type="group">
                <posx>6</posx>
                <posy>{{ vscale(10) }}</posy>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>116</width>
                    <height>{{ vscale(116) }}</height>
                    <texture border="12" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r12.png</texture>
                </control>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>116</width>
                    <height>{{ vscale(116) }}</height>
                    <texture fallback="script.plex/thumb_fallbacks/broken-photo-thumb.png" background="true" diffuse="script.plex/plezy/mask-grid-square.png">$INFO[ListItem.Thumb]</texture>
                    <aspectratio>scale</aspectratio>
                </control>
            </control>
        </itemlayout>
        <focusedlayout width="128">
            <control type="group">
                <posx>6</posx>
                <posy>{{ vscale(10) }}</posy>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>116</width>
                    <height>{{ vscale(116) }}</height>
                    <texture border="12" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r12.png</texture>
                </control>
                <control type="image">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>116</width>
                    <height>{{ vscale(116) }}</height>
                    <texture fallback="script.plex/thumb_fallbacks/broken-photo-thumb.png" background="true" diffuse="script.plex/plezy/mask-grid-square.png">$INFO[ListItem.Thumb]</texture>
                    <aspectratio>scale</aspectratio>
                </control>
            </control>
        </focusedlayout>
    </control>
    <!-- static ring on the centre slot (the list always selects it) -->
    <control type="image">
        <posx>899</posx>
        <posy>{{ vscale(1087) }}</posy>
        <width>122</width>
        <height>{{ vscale(122) }}</height>
        <texture border="11" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-8.png</texture>
    </control>
</control>

<!-- info panel: a floating surface at the right -->
<control type="group">
    <visible>!String.IsEmpty(Window.Property(show.info))</visible>
    <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
    <posx>1404</posx>
    <posy>{{ vscale(48) }}</posy>
    <width>468</width>
    <height>{{ vscale(984) }}</height>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>468</width>
        <height>{{ vscale(984) }}</height>
        <texture border="30" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r30.png</texture>
    </control>
    <control type="grouplist">
        <posx>24</posx>
        <posy>{{ vscale(24) }}</posy>
        <width>420</width>
        <height>{{ vscale(936) }}</height>
        <itemgap>10</itemgap>
        <orientation>vertical</orientation>
        <usecontrolcoords>true</usecontrolcoords>

        <control type="button" id="650">
            <enable>false</enable>
            <width>420</width>
            <height>{{ vscale(48) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <textoffsetx>0</textoffsetx>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <disabledcolor>{{ core.plezy.text }}</disabledcolor>
            <texturefocus>-</texturefocus>
            <texturenofocus>-</texturenofocus>
            <label>[B]$INFO[Window.Property(photo.title)][/B]</label>
        </control>
        <control type="button" id="659">
            <enable>false</enable>
            <width>420</width>
            <height>{{ vscale(36) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <textoffsetx>0</textoffsetx>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <disabledcolor>{{ core.plezy.muted }}</disabledcolor>
            <texturefocus>-</texturefocus>
            <texturenofocus>-</texturenofocus>
            <label>$INFO[Window.Property(photo.date)]</label>
        </control>
        <control type="image">
            <posy>{{ vscale(6) }}</posy>
            <width>420</width>
            <height>{{ vscale(2) }}</height>
            <texture colordiffuse="{{ core.plezy.outline }}">script.plex/white-square.png</texture>
        </control>
        <control type="group">
            <visible>!String.IsEmpty(Window.Property(camera.model))</visible>
            <posy>{{ vscale(6) }}</posy>
            <width>420</width>
            <height>{{ vscale(44) }}</height>
            <control type="label">
                <posx>0</posx>
                <posy>0</posy>
                <width>370</width>
                <height>{{ vscale(44) }}</height>
                <font>font12</font>
                <align>left</align>
                <aligny>center</aligny>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <label>$INFO[Window.Property(camera.model)]</label>
            </control>
            <control type="image">
                <posx>384</posx>
                <posy>{{ vscale(8) }}</posy>
                <width>30</width>
                <height>{{ vscale(28) }}</height>
                <texture colordiffuse="{{ core.plezy.muted }}">script.plex/indicators/camera.png</texture>
                <aspectratio>keep</aspectratio>
            </control>
        </control>
        <control type="label">
            <visible>!String.IsEmpty(Window.Property(camera.lens))</visible>
            <width>420</width>
            <height>{{ vscale(40) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[Window.Property(camera.lens)]</label>
        </control>
        <control type="group">
            <visible>!String.IsEmpty(Window.Property(photo.container))</visible>
            <width>420</width>
            <height>{{ vscale(48) }}</height>
            <control type="label">
                <posx>0</posx>
                <posy>0</posy>
                <width>300</width>
                <height>{{ vscale(48) }}</height>
                <font>font12</font>
                <align>left</align>
                <aligny>center</aligny>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <label>$INFO[Window.Property(photo.dims)]</label>
            </control>
            <control type="grouplist">
                <posx>300</posx>
                <posy>{{ vscale(6) }}</posy>
                <width>120</width>
                <height>{{ vscale(36) }}</height>
                <itemgap>0</itemgap>
                <orientation>horizontal</orientation>
                <align>right</align>
                <control type="button">
                    <enable>false</enable>
                    <width>auto</width>
                    <height>{{ vscale(36) }}</height>
                    <font>font10</font>
                    <align>center</align>
                    <aligny>center</aligny>
                    <textoffsetx>16</textoffsetx>
                    <textcolor>{{ core.plezy.on_primary }}</textcolor>
                    <disabledcolor>{{ core.plezy.on_primary }}</disabledcolor>
                    <texturefocus border="20" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-40.png</texturefocus>
                    <texturenofocus border="20" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-40.png</texturenofocus>
                    <label>[B][UPPERCASE]$INFO[Window.Property(photo.container)][/UPPERCASE][/B]</label>
                </control>
            </control>
        </control>
        <control type="label">
            <visible>!String.IsEmpty(Window.Property(camera.settings))</visible>
            <width>420</width>
            <height>{{ vscale(40) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$INFO[Window.Property(camera.settings)]</label>
        </control>
        <control type="group">
            <visible>!String.IsEmpty(Window.Property(photo.summary))</visible>
            <width>420</width>
            <height>{{ vscale(240) }}</height>
            <control type="image">
                <posx>0</posx>
                <posy>{{ vscale(8) }}</posy>
                <width>420</width>
                <height>{{ vscale(2) }}</height>
                <texture colordiffuse="{{ core.plezy.outline }}">script.plex/white-square.png</texture>
            </control>
            <control type="textbox">
                <posx>0</posx>
                <posy>{{ vscale(24) }}</posy>
                <width>420</width>
                <height>{{ vscale(210) }}</height>
                <font>font12</font>
                <align>left</align>
                <textcolor>{{ core.plezy.summary }}</textcolor>
                <label>$INFO[Window.Property(photo.summary)]</label>
            </control>
        </control>
    </control>
</control>
{% endblock controls %}
