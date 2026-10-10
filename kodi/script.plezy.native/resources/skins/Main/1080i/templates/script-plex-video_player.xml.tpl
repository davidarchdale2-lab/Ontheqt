{% extends "default.xml.tpl" %}
{% block header %}
<control type="group">
    <visible>!String.IsEmpty(Window.Property(post.play))</visible>
    {{ super() }}
</control>
{% endblock header %}

{% block content %}
{#
  Post-play. Plezy has no full-screen post-play page (its in-player PlayNext prompt is a small card), so this keeps
  Kodi's screen and draws it in the Plezy TV detail/home idiom at 1:1: backdrop under the spotlight scrims, muted
  kickers, Plezy media cards (radius 8 masks, ring + glow + 1.03 zoom on focus, bold title + muted subtitle under the
  artwork), a "15 >" Play next countdown pill (player_prompt_overlays.dart), and hub rows with an icon + bold header
  that dim while another part of the screen has focus.
  Group 50 slides and the row heights (360 / 520 / 410) are what VideoPlayerWindow.getRoleItemDDPosition expects.
#}
<control type="group">
    <visible>!String.IsEmpty(Window.Property(post.play))</visible>
    <control type="group">
        <control type="image">
            <posx>0</posx>
            <posy>0</posy>
            <width>1920</width>
            <height>1080</height>
            <texture background="true">$INFO[Window.Property(post.play.background)]</texture>
            {% include "includes/scale_background.xml.tpl" %}
        </control>
        {% include "includes/plezy_scrims.xml.tpl" with foot=True %}
    </control>

    <control type="group" id="50">
        <animation effect="slide" end="0,{{ vscale(-300) }}" time="200" tween="quadratic" easing="out" condition="!String.IsEmpty(Window.Property(on.extras))">Conditional</animation>

        <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),0) + Control.IsVisible(500)" reversible="true">
            <effect type="slide" end="0,{{ vscale(-500) }}" time="200" tween="quadratic" easing="out"/>
        </animation>

        <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),1) + Control.IsVisible(501)" reversible="true">
            <effect type="slide" end="0,{{ vscale(-500) }}" time="200" tween="quadratic" easing="out"/>
        </animation>

        <posx>0</posx>
        <posy>{{ vscale(135) }}</posy>
        <defaultcontrol>102</defaultcontrol>

        <control type="label">
            <scroll>false</scroll>
            <posx>60</posx>
            <posy>{{ vscale(40) }}</posy>
            <width>400</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$ADDON[script.plezy.native 32438]</label>
        </control>

        <control type="group" id="100">
            <defaultcontrol>102</defaultcontrol>

            <!-- previous item: 400x225 card with a replay badge -->
            <control type="group">
                <posx>60</posx>
                <posy>{{ vscale(88) }}</posy>
                <control type="group">
                    <animation effect="zoom" start="100" end="103" time="120" tween="cubic" easing="out" center="200,{{ vscale(112.5) }}" reversible="true" condition="Control.HasFocus(101)">Conditional</animation>
                    <control type="image">
                        <visible>Control.HasFocus(101)</visible>
                        <posx>-40</posx>
                        <posy>{{ vscale(-40) }}</posy>
                        <width>480</width>
                        <height>{{ vscale(305) }}</height>
                        <texture border="48">script.plex/plezy/glow.png</texture>
                    </control>
                    <control type="image">
                        <posx>0</posx>
                        <posy>0</posy>
                        <width>400</width>
                        <height>{{ vscale(225) }}</height>
                        <texture border="8" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r8.png</texture>
                    </control>
                    <control type="image">
                        <posx>0</posx>
                        <posy>0</posy>
                        <width>400</width>
                        <height>{{ vscale(225) }}</height>
                        <texture diffuse="script.plex/plezy/mask-wide.png">$INFO[Window.Property(thumb.fallback)]</texture>
                        <aspectratio>scale</aspectratio>
                    </control>
                    <control type="image">
                        <posx>0</posx>
                        <posy>0</posy>
                        <width>400</width>
                        <height>{{ vscale(225) }}</height>
                        <texture background="true" diffuse="script.plex/plezy/mask-wide.png">$INFO[Window.Property(prev.thumb)]</texture>
                        <aspectratio>scale</aspectratio>
                    </control>
                    <control type="image">
                        <posx>164</posx>
                        <posy>{{ vscale(76.5) }}</posy>
                        <width>72</width>
                        <height>{{ vscale(72) }}</height>
                        <texture colordiffuse="{{ core.plezy.player_tooltip }}">script.plex/plezy/circle.png</texture>
                    </control>
                    <control type="image">
                        <posx>180</posx>
                        <posy>{{ vscale(92.5) }}</posy>
                        <width>40</width>
                        <height>{{ vscale(40) }}</height>
                        <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/replay.png</texture>
                        <aspectratio>keep</aspectratio>
                    </control>
                    <control type="image">
                        <visible>Control.HasFocus(101)</visible>
                        <posx>-3</posx>
                        <posy>{{ vscale(-3) }}</posy>
                        <width>406</width>
                        <height>{{ vscale(231) }}</height>
                        <texture border="11" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-8.png</texture>
                    </control>
                </control>
                <control type="label">
                    <scroll>Control.HasFocus(101)</scroll>
                    <posx>2</posx>
                    <posy>{{ vscale(237) }}</posy>
                    <width>396</width>
                    <height>{{ vscale(34) }}</height>
                    <font>font12</font>
                    <align>left</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <label>[B]$INFO[Window.Property(prev.title)][/B]</label>
                </control>
                <control type="label">
                    <scroll>false</scroll>
                    <posx>2</posx>
                    <posy>{{ vscale(271) }}</posy>
                    <width>396</width>
                    <height>{{ vscale(30) }}</height>
                    <font>font10</font>
                    <align>left</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.muted }}</textcolor>
                    <label>$INFO[Window.Property(prev.subtitle)]</label>
                </control>
                <control type="button" id="101">
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>400</width>
                    <height>{{ vscale(225) }}</height>
                    <onup>200</onup>
                    <ondown>400</ondown>
                    <onright>102</onright>
                    <texturefocus>-</texturefocus>
                    <texturenofocus>-</texturenofocus>
                </control>
            </control>

            <!-- up next: 532x299 card with the Play next countdown pill -->
            <control type="group">
                <visible>!String.IsEmpty(Window.Property(has.next))</visible>
                <control type="label">
                    <scroll>false</scroll>
                    <posx>520</posx>
                    <posy>{{ vscale(40) }}</posy>
                    <width>532</width>
                    <height>{{ vscale(36) }}</height>
                    <font>font12</font>
                    <align>left</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.muted }}</textcolor>
                    <label>$ADDON[script.plezy.native 35161]</label>
                </control>
                <control type="group">
                    <posx>520</posx>
                    <posy>{{ vscale(88) }}</posy>
                    <control type="group">
                        <animation effect="zoom" start="100" end="103" time="120" tween="cubic" easing="out" center="266,{{ vscale(149.5) }}" reversible="true" condition="Control.HasFocus(102)">Conditional</animation>
                        <control type="image">
                            <visible>Control.HasFocus(102)</visible>
                            <posx>-40</posx>
                            <posy>{{ vscale(-40) }}</posy>
                            <width>612</width>
                            <height>{{ vscale(379) }}</height>
                            <texture border="48">script.plex/plezy/glow.png</texture>
                        </control>
                        <control type="image">
                            <posx>0</posx>
                            <posy>0</posy>
                            <width>532</width>
                            <height>{{ vscale(299) }}</height>
                            <texture border="8" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r8.png</texture>
                        </control>
                        <control type="image">
                            <posx>0</posx>
                            <posy>0</posy>
                            <width>532</width>
                            <height>{{ vscale(299) }}</height>
                            <texture diffuse="script.plex/plezy/mask-grid-wide.png">$INFO[Window.Property(thumb.fallback)]</texture>
                            <aspectratio>scale</aspectratio>
                        </control>
                        <control type="image">
                            <posx>0</posx>
                            <posy>0</posy>
                            <width>532</width>
                            <height>{{ vscale(299) }}</height>
                            <texture background="true" diffuse="script.plex/plezy/mask-grid-wide.png">$INFO[Window.Property(next.thumb)]</texture>
                            <aspectratio>scale</aspectratio>
                        </control>
                        <!-- Play next countdown: white pill, "15" + play_arrow in the on-primary colour -->
                        <control type="group">
                            <visible>!String.IsEmpty(Window.Property(countdown.seconds))</visible>
                            <posx>16</posx>
                            <posy>{{ vscale(227) }}</posy>
                            <control type="image">
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>108</width>
                                <height>{{ vscale(56) }}</height>
                                <texture border="28" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/pill-56.png</texture>
                            </control>
                            <control type="label">
                                <posx>14</posx>
                                <posy>0</posy>
                                <width>46</width>
                                <height>{{ vscale(56) }}</height>
                                <font>font12</font>
                                <align>right</align>
                                <aligny>center</aligny>
                                <textcolor>{{ core.plezy.on_primary }}</textcolor>
                                <label>[B]$INFO[Window.Property(countdown.seconds)][/B]</label>
                            </control>
                            <control type="image">
                                <posx>64</posx>
                                <posy>{{ vscale(12) }}</posy>
                                <width>32</width>
                                <height>{{ vscale(32) }}</height>
                                <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/play_arrow.png</texture>
                                <aspectratio>keep</aspectratio>
                            </control>
                        </control>
                        <control type="image">
                            <visible>Control.HasFocus(102)</visible>
                            <posx>-3</posx>
                            <posy>{{ vscale(-3) }}</posy>
                            <width>538</width>
                            <height>{{ vscale(305) }}</height>
                            <texture border="11" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-8.png</texture>
                        </control>
                    </control>
                    <control type="label">
                        <scroll>Control.HasFocus(102)</scroll>
                        <posx>2</posx>
                        <posy>{{ vscale(311) }}</posy>
                        <width>528</width>
                        <height>{{ vscale(34) }}</height>
                        <font>font12</font>
                        <align>left</align>
                        <aligny>center</aligny>
                        <textcolor>{{ core.plezy.text }}</textcolor>
                        <label>[B]$INFO[Window.Property(next.title)][/B]</label>
                    </control>
                    <control type="label">
                        <scroll>false</scroll>
                        <posx>2</posx>
                        <posy>{{ vscale(345) }}</posy>
                        <width>528</width>
                        <height>{{ vscale(30) }}</height>
                        <font>font10</font>
                        <align>left</align>
                        <aligny>center</aligny>
                        <textcolor>{{ core.plezy.muted }}</textcolor>
                        <label>$INFO[Window.Property(next.subtitle)]</label>
                    </control>
                    <control type="button" id="102">
                        <posx>0</posx>
                        <posy>0</posy>
                        <width>532</width>
                        <height>{{ vscale(299) }}</height>
                        <onup>200</onup>
                        <ondown>400</ondown>
                        <onleft>101</onleft>
                        <texturefocus>-</texturefocus>
                        <texturenofocus>-</texturenofocus>
                    </control>
                </control>
            </control>

            <!-- info: the next item, or the finished one when nothing follows -->
            <control type="group">
                <visible>!String.IsEmpty(Window.Property(has.next))</visible>
                <posx>1112</posx>
                <posy>{{ vscale(88) }}</posy>
                <control type="label">
                    <scroll>true</scroll>
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>748</width>
                    <height>{{ vscale(48) }}</height>
                    <font>font14</font>
                    <align>left</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <label>[B]$INFO[Window.Property(info.title)][/B]</label>
                </control>
                <control type="label">
                    <scroll>false</scroll>
                    <posx>0</posx>
                    <posy>{{ vscale(52) }}</posy>
                    <width>748</width>
                    <height>{{ vscale(36) }}</height>
                    <font>font12</font>
                    <align>left</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.muted }}</textcolor>
                    <label>$INFO[Window.Property(info.date)]$INFO[Window.Property(info.duration), &#183; ]</label>
                </control>
                <control type="textbox">
                    <autoscroll delay="2000" time="2000" repeat="10000"></autoscroll>
                    <posx>0</posx>
                    <posy>{{ vscale(104) }}</posy>
                    <width>748</width>
                    <height>{{ vscale(195) }}</height>
                    <font>font12</font>
                    <align>left</align>
                    <textcolor>{{ core.plezy.summary }}</textcolor>
                    <label>$INFO[Window.Property(info.summary)]</label>
                </control>
            </control>

            <control type="group">
                <visible>String.IsEmpty(Window.Property(has.next))</visible>
                <posx>520</posx>
                <posy>{{ vscale(88) }}</posy>
                <control type="label">
                    <scroll>true</scroll>
                    <posx>0</posx>
                    <posy>0</posy>
                    <width>1340</width>
                    <height>{{ vscale(48) }}</height>
                    <font>font14</font>
                    <align>left</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.text }}</textcolor>
                    <label>[B]$INFO[Window.Property(prev.info.title)][/B]</label>
                </control>
                <control type="label">
                    <scroll>false</scroll>
                    <posx>0</posx>
                    <posy>{{ vscale(52) }}</posy>
                    <width>1340</width>
                    <height>{{ vscale(36) }}</height>
                    <font>font12</font>
                    <align>left</align>
                    <aligny>center</aligny>
                    <textcolor>{{ core.plezy.muted }}</textcolor>
                    <label>$INFO[Window.Property(prev.info.date)]$INFO[Window.Property(prev.info.duration), &#183; ]</label>
                </control>
                <control type="textbox">
                    <autoscroll delay="2000" time="2000" repeat="10000"></autoscroll>
                    <posx>0</posx>
                    <posy>{{ vscale(104) }}</posy>
                    <width>1340</width>
                    <height>{{ vscale(160) }}</height>
                    <font>font12</font>
                    <align>left</align>
                    <textcolor>{{ core.plezy.summary }}</textcolor>
                    <label>$INFO[Window.Property(prev.info.summary)]</label>
                </control>
            </control>
        </control>

        <control type="grouplist" id="60">
            <posx>0</posx>
            <posy>{{ vscale(530) }}</posy>
            <width>1920</width>
            <height>{{ vscale(1610) }}</height>

            <onup>300</onup>
            <itemgap>0</itemgap>

            <control type="group" id="500">
                <visible>Integer.IsGreater(Container(400).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
                <animation effect="fade" start="100" end="55" time="200" condition="!Control.HasFocus(400)">Conditional</animation>
                <height>{{ vscale(360) }}</height>
                <width>1920</width>
                {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_continue.png" & title="$ADDON[script.plezy.native 35162]" & x=60 & y=0 %}
                <control type="list" id="400">
                    <posx>44</posx>
                    <posy>{{ vscale(36) }}</posy>
                    <width>1876</width>
                    <height>{{ vscale(324) }}</height>
                    <onup>100</onup>
                    <ondown>401</ondown>
                    <onleft>noop</onleft>
                    <onright>noop</onright>
                    <scrolltime tween="cubic" easing="out">200</scrolltime>
                    <orientation>horizontal</orientation>
                    <preloaditems>4</preloaditems>
                    {% with hub_id = 400 %}
                    {% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=False & cw=400 & ch=225 & mask="script.plex/plezy/mask-wide.png" & cond="none" & sub_always=True %}
                    {% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=True & cw=400 & ch=225 & mask="script.plex/plezy/mask-wide.png" & cond="none" & sub_always=True %}
                    {% endwith %}
                </control>
            </control>

            <control type="group" id="501">
                <visible>Integer.IsGreater(Container(401).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
                <animation effect="fade" start="100" end="55" time="200" condition="!Control.HasFocus(401)">Conditional</animation>
                <defaultcontrol>401</defaultcontrol>
                <width>1920</width>
                <height>{{ vscale(520) }}</height>
                {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_similar.png" & title="$INFO[Window.Property(related.header)]" & x=60 & y=0 %}
                <control type="list" id="401">
                    <posx>44</posx>
                    <posy>{{ vscale(36) }}</posy>
                    <width>1876</width>
                    <height>{{ vscale(420) }}</height>
                    <onup>400</onup>
                    <ondown>403</ondown>
                    <onleft>noop</onleft>
                    <onright>noop</onright>
                    <scrolltime tween="cubic" easing="out">200</scrolltime>
                    <orientation>horizontal</orientation>
                    <preloaditems>4</preloaditems>
                    {% with hub_id = 401 %}
                    {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=False & cw=200 & ch=300 & mask="script.plex/plezy/mask-poster.png" & cond="none" & sub_always=True %}
                    {% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=True & cw=200 & ch=300 & mask="script.plex/plezy/mask-poster.png" & cond="none" & sub_always=True %}
                    {% endwith %}
                </control>
            </control>

            <control type="group" id="503">
                <visible>Integer.IsGreater(Container(403).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
                <animation effect="fade" start="100" end="55" time="200" condition="!Control.HasFocus(403)">Conditional</animation>
                <defaultcontrol>403</defaultcontrol>
                <width>1920</width>
                <height>{{ vscale(410) }}</height>
                {% include "includes/plezy_row_header.xml.tpl" with icon="script.plex/plezy/icons/hub_cast.png" & title="$ADDON[script.plezy.native 32419]" & x=60 & y=0 %}
                <control type="list" id="403">
                    <posx>44</posx>
                    <posy>{{ vscale(36) }}</posy>
                    <width>1876</width>
                    <height>{{ vscale(330) }}</height>
                    <onup>401</onup>
                    <ondown>404</ondown>
                    <scrolltime tween="cubic" easing="out">200</scrolltime>
                    <orientation>horizontal</orientation>
                    <preloaditems>4</preloaditems>
                    {% with hub_id = 403 %}
                    {% include "includes/plezy_hub_card.xml.tpl" with kind="square" & focused=False & cw=200 & ch=200 & mask="script.plex/plezy/mask-square.png" & cond="none" & sub_always=True %}
                    {% include "includes/plezy_hub_card.xml.tpl" with kind="square" & focused=True & cw=200 & ch=200 & mask="script.plex/plezy/mask-square.png" & cond="none" & sub_always=True %}
                    {% endwith %}
                </control>
            </control>
        </control>
    </control>
</control>
{% endblock content %}
