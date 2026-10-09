{% extends "default.xml.tpl" %}
{% block content %}
<control type="group" id="50">
    <defaultcontrol>101</defaultcontrol><posx>0</posx><posy>0</posy>
    <width>1920</width><height>{{ vscale(1080) }}</height>
<control type="image">
    
    <posx>0</posx><posy>{{ vscale(0) }}</posy>
    <width>352</width><height>{{ vscale(1080) }}</height>
    <texture border="10">script.plex/white-square.png</texture><colordiffuse>F212151C</colordiffuse>
</control>
<control type="group" id="100">
    <posx>24</posx><posy>{{ vscale(154) }}</posy>
    <width>310</width><height>{{ vscale(880) }}</height>
    <control type="list" id="101">
        <posx>0</posx><posy>0</posy><width>310</width><height>{{ vscale(842) }}</height>
        <onup>203</onup><ondown>101</ondown><onleft>101</onleft>
        {% for i in range(core.hub_count) %}
        <onright condition="Control.IsVisible({{ i + 400 }})">{{ i + 400 }}</onright>
        {% endfor %}
        <scrolltime>100</scrolltime><orientation>vertical</orientation>
        <preloaditems>2</preloaditems>
<itemlayout width="310" height="{{ vscale(76) }}">
    <control type="group">
        <visible>!String.IsEmpty(ListItem.Property(item))</visible>
        <control type="image">
    
    <posx>0</posx><posy>{{ vscale(4) }}</posy>
    <width>306</width><height>{{ vscale(66) }}</height>
    <texture border="10">script.plex/white-square-rounded.png</texture><colordiffuse>FF171B24</colordiffuse>
</control>
        <control type="image">
            <posx>20</posx><posy>{{ vscale(20) }}</posy>
            <width>34</width><height>{{ vscale(34) }}</height>
            <texture>$INFO[ListItem.Thumb]</texture><aspectratio>keep</aspectratio>
            <colordiffuse>FFE3E7EF</colordiffuse>
        </control>
        <control type="label">
            <posx>70</posx><posy>{{ vscale(8) }}</posy>
            <width>211</width><height>{{ vscale(58) }}</height>
            <font>font14</font><aligny>center</aligny><textcolor>FFE3E7EF</textcolor>
            <scroll>false</scroll>
            <label>$INFO[ListItem.Label]</label>
        </control>
        <control type="image">
    <visible>!String.IsEmpty(ListItem.Property(is.mapped)) + String.IsEmpty(ListItem.Property(is.mapped.broken))</visible>
    <posx>296</posx><posy>{{ vscale(4) }}</posy>
    <width>10</width><height>{{ vscale(10) }}</height>
    <texture border="10">script.plex/white-square-rounded-4r.png</texture><colordiffuse>FFB7C1D6</colordiffuse>
</control>
        <control type="image">
    <visible>!String.IsEmpty(ListItem.Property(is.mapped.broken))</visible>
    <posx>296</posx><posy>{{ vscale(4) }}</posy>
    <width>10</width><height>{{ vscale(10) }}</height>
    <texture border="10">script.plex/white-square-rounded-4r.png</texture><colordiffuse>FFFF6666</colordiffuse>
</control>
        <control type="image">
    <visible>!String.IsEmpty(ListItem.Property(moving))</visible>
    <posx>0</posx><posy>{{ vscale(4) }}</posy>
    <width>306</width><height>{{ vscale(66) }}</height>
    <texture border="10">script.plex/white-outline-rounded.png</texture><colordiffuse>FFB7C1D6</colordiffuse>
</control>
    </control>
</itemlayout><focusedlayout width="310" height="{{ vscale(76) }}">
    <control type="group">
        <visible>!String.IsEmpty(ListItem.Property(item))</visible>
        <control type="image">
    
    <posx>0</posx><posy>{{ vscale(4) }}</posy>
    <width>306</width><height>{{ vscale(66) }}</height>
    <texture border="10">script.plex/white-square-rounded.png</texture><colordiffuse>FFFFFFFF</colordiffuse>
</control>
        <control type="image">
            <posx>20</posx><posy>{{ vscale(20) }}</posy>
            <width>34</width><height>{{ vscale(34) }}</height>
            <texture>$INFO[ListItem.Thumb]</texture><aspectratio>keep</aspectratio>
            <colordiffuse>FF11141A</colordiffuse>
        </control>
        <control type="label">
            <posx>70</posx><posy>{{ vscale(8) }}</posy>
            <width>211</width><height>{{ vscale(58) }}</height>
            <font>font14</font><aligny>center</aligny><textcolor>FF11141A</textcolor>
            <scroll>Control.HasFocus(101)</scroll>
            <label>$INFO[ListItem.Label]</label>
        </control>
        <control type="image">
    <visible>!String.IsEmpty(ListItem.Property(is.mapped)) + String.IsEmpty(ListItem.Property(is.mapped.broken))</visible>
    <posx>296</posx><posy>{{ vscale(4) }}</posy>
    <width>10</width><height>{{ vscale(10) }}</height>
    <texture border="10">script.plex/white-square-rounded-4r.png</texture><colordiffuse>FFB7C1D6</colordiffuse>
</control>
        <control type="image">
    <visible>!String.IsEmpty(ListItem.Property(is.mapped.broken))</visible>
    <posx>296</posx><posy>{{ vscale(4) }}</posy>
    <width>10</width><height>{{ vscale(10) }}</height>
    <texture border="10">script.plex/white-square-rounded-4r.png</texture><colordiffuse>FFFF6666</colordiffuse>
</control>
        <control type="image">
    <visible>!String.IsEmpty(ListItem.Property(moving))</visible>
    <posx>0</posx><posy>{{ vscale(4) }}</posy>
    <width>306</width><height>{{ vscale(66) }}</height>
    <texture border="10">script.plex/white-outline-rounded.png</texture><colordiffuse>FFB7C1D6</colordiffuse>
</control>
    </control>
</focusedlayout>
    </control>
</control>

    <control type="group">
        <visible>!String.IsEmpty(Container(400).ListItem.Label) + String.IsEmpty(Window.Property(no.content))</visible>
        <posx>414</posx><posy>{{ vscale(172) }}</posy><width>1300</width><height>{{ vscale(196) }}</height>
        {% for i in range(core.hub_count) %}
        <control type="group">
            <visible>{% if loop.is_first %}String.IsEmpty(Window.Property(hub.focus)) | String.IsEqual(Window.Property(hub.focus),0){% else %}String.IsEqual(Window.Property(hub.focus),{{ i }}){% endif %}</visible>
            <control type="label">
                <posx>0</posx><posy>0</posy><width>1300</width><height>{{ vscale(78) }}</height>
                <font>font60</font><textcolor>FFFFFFFF</textcolor><scroll>false</scroll>
                <label>$INFO[Container({{ i + 400 }}).ListItem.Label]</label>
            </control>
            <control type="label">
                <posx>2</posx><posy>{{ vscale(88) }}</posy><width>1200</width><height>{{ vscale(44) }}</height>
                <font>font14</font><textcolor>FFBAC3D3</textcolor><scroll>false</scroll>
                <label>$INFO[Container({{ i + 400 }}).ListItem.Label2]</label>
            </control>
        </control>
        {% endfor %}
    </control>
    <control type="grouplist" id="51">
        <defaultcontrol>400</defaultcontrol><posx>352</posx><posy>{{ vscale(390) }}</posy>
        {% with n = core.hub_count %}{% with grouplist_height = n * 555 + 100 %}
        <width>1568</width><height>{{ vscale(grouplist_height) }}</height>
        {% endwith %}{% endwith %}
        <itemgap>20</itemgap><orientation>vertical</orientation><usecontrolcoords>true</usecontrolcoords>
        <scrolltime tween="quadratic" easing="out">100</scrolltime>
        {% for i in range(1, core.hub_count) %}
        <animation type="Conditional" condition="Integer.IsGreater(Window.Property(hub.focus),{{ i - 1 }}) + Control.IsVisible({{ i + 499 }})" reversible="true">
            <effect type="slide" end="0,{{ vscale(-555) }}" time="120" tween="quadratic" easing="out" />
        </animation>
        {% endfor %}
    <!-- DYNAMIC HUB ROWS - Generated from hub_count setting -->
    {% for i in range(core.hub_count) %}
    {% with group_id = i + 500 & hub_id = i + 400 %}
    <control type="group" id="{{ group_id }}">
        <visible>Integer.IsGreater(Container({{ hub_id }}).NumItems,0) + String.IsEmpty(Window.Property(drawing))</visible>
        <defaultcontrol>{{ hub_id }}</defaultcontrol>
        <width>1580</width>
        <height>{{ vscale(535) }}</height>
        <control type="image">
            <visible>!String.IsEmpty(Window.Property(bifurcation_lines))</visible>
            <posx>60</posx>
            <posy>{{ vscale(12) }}</posy>
            <width>1800</width>
            <height>{{ vscale(2) }}</height>
            <texture>script.plex/white-square.png</texture>
            <colordiffuse>A0000000</colordiffuse>
        </control>
        <control type="label">
            <posx>60</posx>
            <posy>0</posy>
            <width>1000</width>
            <height>{{ vscale(87) }}</height>
            <font>font14</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>FFFFFFFF</textcolor>
            <label>$INFO[Window.Property(hub.{{ hub_id }})]</label>
        </control>
        <control type="list" id="{{ hub_id }}">
            <posx>0</posx>
            <posy>{{ vscale(29) }}</posy>
            <width>1580</width>
            <height>{{ vscale(515) }}</height>
            <onup>{% if loop.is_first %}203{% else %}{{ hub_id - 1 }}{% endif %}</onup>
            <ondown>{% if loop.is_last %}{{ hub_id }}{% else %}{{ hub_id + 1 }}{% endif %}</ondown>
            <onright>noop</onright>
            <onleft>101</onleft>
            <scrolltime>100</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>

            <!-- Conditional item layouts - Kodi selects layout based on condition attribute -->
            {% include "includes/hub_itemlayout_poster.xml.tpl" %}
            {% include "includes/hub_itemlayout_square.xml.tpl" %}
            {% include "includes/hub_itemlayout_ar16x9.xml.tpl" %}
            <!-- Conditional focused layouts - Kodi selects layout based on condition attribute -->
            {% include "includes/hub_focusedlayout_poster.xml.tpl" %}
            {% include "includes/hub_focusedlayout_square.xml.tpl" %}
            {% include "includes/hub_focusedlayout_ar16x9.xml.tpl" %}
        </control>
    </control>
    {% endwith %}
    {% endfor %}

    <control type="label">
        <!-- DUMMY -->
        <width>1580</width>
        <height>{{ vscale(100) }}</height>
        <font>font14</font>
        <align>left</align>
        <aligny>center</aligny>
        <textcolor>00FFFFFF</textcolor>
        <label> </label>
    </control>

    </control>
</control>
{% endblock content %}

{% block header %}
<control type="label">
    <posx>414</posx><posy>{{ vscale(40) }}</posy><width>500</width><height>{{ vscale(72) }}</height>
    <font>font45</font><textcolor>FFFFFFFF</textcolor><label>Plezy</label>
</control>
<control type="group" id="200">
    <defaultcontrol always="true">201</defaultcontrol>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>{{ vscale(135) }}</height>
    <control type="image">
        <animation effect="fade" start="0" end="100" time="200" tween="quadratic" easing="out" reversible="true">VisibleChange</animation>
        <visible>ControlGroup(200).HasFocus(0) + !String.IsEmpty(Window(10000).Property(script.plezy.native.off.sections))</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>{{ vscale(135) }}</height>
        <texture>script.plex/white-square.png</texture>
        <colordiffuse>C0000000</colordiffuse>
    </control>
    <control type="group">
        <visible>String.IsEmpty(Window.Property(search.dialog))</visible>
        <control type="button" id="203">
            <animation effect="zoom" start="100" end="144" time="100" center="80,{{ vscale(67.5) }}" reversible="false">Focus</animation>
            <animation effect="zoom" start="144" end="100" time="100" center="80,{{ vscale(67.5) }}" reversible="false">UnFocus</animation>
            <posx>60</posx>
            <posy>{{ vscale(47.5) }}</posy>
            <width>40</width>
            <height>{{ vscale(40) }}</height>
            <ondown>50</ondown>
            <font>font12</font>
            <focusedcolor>FF000000</focusedcolor>
            <texturefocus colordiffuse="FFFFFFFF">script.plex/buttons/search-focus.png</texturefocus>
            <texturenofocus colordiffuse="99FFFFFF">script.plex/buttons/search.png</texturenofocus>
            <label> </label>
        </control>
        <control type="label">
            <posx>160</posx>
            <posy>{{ vscale(35) }}</posy>
            <width>500</width>
            <height>{{ vscale(65) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>FFFFFFFF</textcolor>
            <label>[UPPERCASE]$ADDON[script.plezy.native 32430][/UPPERCASE]</label>
        </control>
    </control>
    <control type="group">
        <visible>Player.HasAudio + String.IsEmpty(Window(10000).Property(script.plezy.native.theme_playing))</visible>
        <posx>438</posx>
        <posy>0</posy>
        <control type="button" id="204">
            <visible>Player.HasAudio + String.IsEmpty(Window(10000).Property(script.plezy.native.theme_playing))</visible>
            <posx>-10</posx>
            <posy>{{ vscale(38) }}</posy>
            <width>260</width>
            <height>{{ vscale(75) }}</height>
            <onleft>203</onleft>
            <ondown>50</ondown>
            <font>font12</font>
            <textcolor>FFFFFFFF</textcolor>
            <focusedcolor>FF000000</focusedcolor>
            <align>right</align>
            <aligny>center</aligny>
            <texturefocus colordiffuse="FFFFFFFF" border="10">script.plex/white-square-rounded.png</texturefocus>
            <texturenofocus>-</texturenofocus>
            <textoffsetx>100</textoffsetx>
            <textoffsety>0</textoffsety>
            <label> </label>
        </control>
        <control type="image">
            <posx>0</posx>
            <posy>{{ vscale(48) }}</posy>
            <width>42</width>
            <height>{{ vscale(42) }}</height>
            <texture>$INFO[Player.Art(thumb)]</texture>
        </control>

        <control type="group">
            <visible>!Control.HasFocus(204)</visible>
            <control type="label">
                <posx>53</posx>
                <posy>{{ vscale(48) }}</posy>
                <width>187</width>
                <height>{{ vscale(20) }}</height>
                <font>font10</font>
                <align>left</align>
                <aligny>center</aligny>
                <textcolor>FFFFFFFF</textcolor>
                <info>MusicPlayer.Artist</info>
            </control>
            <control type="label">
                <posx>53</posx>
                <posy>{{ vscale(72) }}</posy>
                <width>187</width>
                <height>{{ vscale(20) }}</height>
                <font>font10</font>
                <align>left</align>
                <aligny>center</aligny>
                <textcolor>FFFFFFFF</textcolor>
                <info>MusicPlayer.Title</info>
            </control>
        </control>
        <control type="group">
            <visible>Control.HasFocus(204)</visible>
            <control type="label">
                <posx>53</posx>
                <posy>{{ vscale(48) }}</posy>
                <width>187</width>
                <height>{{ vscale(20) }}</height>
                <font>font10</font>
                <align>left</align>
                <aligny>center</aligny>
                <textcolor>FF000000</textcolor>
                <info>MusicPlayer.Artist</info>
            </control>
            <control type="label">
                <posx>53</posx>
                <posy>{{ vscale(72) }}</posy>
                <width>187</width>
                <height>{{ vscale(20) }}</height>
                <font>font10</font>
                <align>left</align>
                <aligny>center</aligny>
                <textcolor>FF000000</textcolor>
                <info>MusicPlayer.Title</info>
            </control>
        </control>

        <control type="progress">
            <description>Progressbar</description>
            <posx>0</posx>
            <posy>{{ vscale(102) }}</posy>
            <width>240</width>
            <height>{{ vscale(1) }}</height>
            <texturebg colordiffuse="9AFFFFFF">script.plex/white-square-1px.png</texturebg>
            <lefttexture>-</lefttexture>
            <midtexture colordiffuse="FFB7C1D6">script.plex/white-square-1px.png</midtexture>
            <righttexture>-</righttexture>
            <overlaytexture>-</overlaytexture>
            <info>Player.Progress</info>
        </control>
    </control>
    <control type="label">
        <right>213</right>
        <posy>{{ vscale(35) }}</posy>
        <width>200</width>
        <height>{{ vscale(65) }}</height>
        <font>font12</font>
        <align>right</align>
        <aligny>center</aligny>
        <textcolor>FFFFFFFF</textcolor>
        <label>$INFO[System.Time]</label>
    </control>
    <control type="image">
        <posx>153r</posx>
        <posy>{{ vscale(47.5) }}</posy>
        <width>93</width>
        <height>{{ vscale(43) }}</height>
        <texture>script.plex/home/plex.png</texture>
    </control>
    <control type="group">
        <posx>576</posx>
        <posy>{{ vscale(34) }}</posy>
        <width>1000</width>
        <height>{{ vscale(1046) }}</height>
        <control type="grouplist">
            <posx>0</posx>
            <posy>0</posy>
            <width>1000</width>
            <height>{{ vscale(1046) }}</height>
            <ondown>50</ondown>
            <onleft>204</onleft>
            <align>right</align>
            <itemgap>0</itemgap>
            <orientation>horizontal</orientation>
            <scrolltime tween="quadratic" easing="out">200</scrolltime>
            <usecontrolcoords>true</usecontrolcoords>
            <control type="button" id="201">
                <width max="500">auto</width>
                <height>{{ vscale(66) }}</height>
                <font>font12</font>
                <textcolor>FFFFFFFF</textcolor>
                <focusedcolor>FF000000</focusedcolor>
                <disabledcolor>FFFFFFFF</disabledcolor>
                <align>right</align>
                <aligny>center</aligny>
                <texturefocus colordiffuse="FFFFFFFF" border="10">script.plex/white-square-rounded.png</texturefocus>
                <texturenofocus>-</texturenofocus>
                <textoffsetx>100</textoffsetx>
                <textoffsety>0</textoffsety>
                <label>$INFO[Window.Property(server.name)]</label>
                <onunfocus condition="!String.IsEmpty(Window.Property(show.servers))">SetFocus(260)</onunfocus>
            </control>
            <!-- server control -->
            <control type="group">
                <posx>-93</posx>
                <width>93</width>
                <height>{{ vscale(66) }}</height>
                <control type="image">
                    <posx>6</posx>
                    <posy>{{ vscale(14) }}</posy>
                    <width>40</width>
                    <height>{{ vscale(39) }}</height>
                    <texture>$INFO[Window.Property(server.icon)]</texture>
                </control>
                <control type="image">
                    <posx>0</posx>
                    <posy>{{ vscale(38) }}</posy>
                    <width>16</width>
                    <height>{{ vscale(15) }}</height>
                    <texture>$INFO[Window.Property(server.iconmod)]</texture>
                </control>
                <!-- secure + local -->
                <control type="image">
                    <visible>!String.IsEmpty(Window.Property(server.iconmod))</visible>
                    <posx>0</posx>
                    <posy>{{ vscale(20) }}</posy>
                    <width>16</width>
                    <height>{{ vscale(14) }}</height>
                    <texture>$INFO[Window.Property(server.iconmod2)]</texture>
                    <colordiffuse>FFEEEEEE</colordiffuse>
                </control>
                <!-- local -->
                <control type="image">
                    <visible>String.IsEmpty(Window.Property(server.iconmod))</visible>
                    <posx>0</posx>
                    <posy>{{ vscale(38) }}</posy>
                    <width>16</width>
                    <height>{{ vscale(14) }}</height>
                    <texture>$INFO[Window.Property(server.iconmod2)]</texture>
                    <colordiffuse>FFEEEEEE</colordiffuse>
                </control>
                <control type="image">
                    <visible>!Control.HasFocus(201)</visible>
                    <posx>59</posx>
                    <posy>{{ vscale(27) }}</posy>
                    <width>15</width>
                    <height>{{ vscale(13) }}</height>
                    <texture>script.plex/indicators/dropdown-triangle.png</texture>
                    <colordiffuse>99FFFFFF</colordiffuse>
                </control>
                <control type="image">
                    <visible>Control.HasFocus(201)</visible>
                    <posx>59</posx>
                    <posy>{{ vscale(27) }}</posy>
                    <width>15</width>
                    <height>{{ vscale(13) }}</height>
                    <texture>script.plex/indicators/dropdown-triangle.png</texture>
                    <colordiffuse>FF222222</colordiffuse>
                </control>
                <control type="group">
                    <visible>Control.HasFocus(260) | !String.IsEmpty(Window.Property(show.servers))</visible>
                    <posx>-250</posx>
                    <posy>{{ vscale(70) }}</posy>
                    <control type="image" id="800">
                        <posx>-40</posx>
                        <posy>{{ vscale(-40) }}</posy>
                        <width>580</width>
                        <height>{{ vscale(146) }}</height>
                        <texture border="42">script.plex/drop-shadow.png</texture>
                    </control>
                    <control type="image">
                        <posx>269</posx>
                        <posy>{{ vscale(-13) }}</posy>
                        <width>15</width>
                        <height>{{ vscale(13) }}</height>
                        <texture flipy="true">script.plex/indicators/dropdown-triangle.png</texture>
                        <colordiffuse>FF1F1F1F</colordiffuse>
                    </control>
                    <control type="list" id="260">
                        <hitrect x="0" y="-10" w="500" h="910" />
                        <posx>0</posx>
                        <posy>0</posy>
                        <width>500</width>
                        <height>{{ vscale(900) }}</height>
                        <onleft>203</onleft>
                        <onright>202</onright>
                        <onunfocus>SetProperty(show.servers,)</onunfocus>
                        <scrolltime>200</scrolltime>
                        <orientation>vertical</orientation>
                        <pagecontrol>261</pagecontrol>
                        <!-- ITEM LAYOUT ########################################## -->
                        <itemlayout height="{{ vscale(100) }}">
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(first))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>500</width>
                                <height>{{ vscale(100) }}</height>
                                <texture colordiffuse="FF1F1F1F" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="image">
                                <visible>String.IsEmpty(ListItem.Property(first)) + String.IsEmpty(ListItem.Property(last)) + String.IsEmpty(ListItem.Property(only))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>500</width>
                                <height>{{ vscale(100) }}</height>
                                <texture colordiffuse="FF1F1F1F">script.plex/white-square.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(last))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>500</width>
                                <height>{{ vscale(100) }}</height>
                                <texture flipy="true" colordiffuse="FF1F1F1F" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(only))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>500</width>
                                <height>{{ vscale(100) }}</height>
                                <texture colordiffuse="FF1F1F1F" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="group">
                                <visible>!String.IsEmpty(ListItem.Label2)</visible>
                                <control type="label">
                                    <posx>20</posx>
                                    <posy>{{ vscale(20) }}</posy>
                                    <width>400</width>
                                    <height>{{ vscale(35) }}</height>
                                    <font>font12</font>
                                    <align>left</align>
                                    <aligny>center</aligny>
                                    <textcolor>FFFFFFFF</textcolor>
                                    <label>$INFO[ListItem.Label]</label>
                                </control>
                                <control type="label">
                                    <posx>20</posx>
                                    <posy>{{ vscale(50) }}</posy>
                                    <width>400</width>
                                    <height>{{ vscale(35) }}</height>
                                    <font>font12</font>
                                    <align>left</align>
                                    <aligny>center</aligny>
                                    <textcolor>FFA0A0A0</textcolor>
                                    <label>$INFO[ListItem.Label2]</label>
                                </control>
                            </control>
                            <control type="label">
                                <visible>String.IsEmpty(ListItem.Label2)</visible>
                                <posx>20</posx>
                                <posy>0</posy>
                                <width>400</width>
                                <height>{{ vscale(100) }}</height>
                                <font>font12</font>
                                <align>left</align>
                                <aligny>center</aligny>
                                <textcolor>FFFFFFFF</textcolor>
                                <label>$INFO[ListItem.Label]</label>
                            </control>

                            <!-- not status + not current + local -->
                            <control type="image">
                                <visible>String.IsEmpty(ListItem.Property(status)) + String.IsEmpty(ListItem.Property(current)) + !String.IsEmpty(ListItem.Property(local)) </visible>
                                <posx>456</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(21) }}</height>
                                <texture>script.plex/home/device/home.png</texture>
                            </control>
                            <!-- not status + current + local -->
                            <control type="image">
                                <visible>String.IsEmpty(ListItem.Property(status)) + !String.IsEmpty(ListItem.Property(current)) + !String.IsEmpty(ListItem.Property(local)) </visible>
                                <posx>415</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(21) }}</height>
                                <texture>script.plex/home/device/home.png</texture>
                            </control>
                            <!-- status + not current + local -->
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(status)) + String.IsEmpty(ListItem.Property(current)) + !String.IsEmpty(ListItem.Property(local)) </visible>
                                <posx>415</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(21) }}</height>
                                <texture>script.plex/home/device/home.png</texture>
                            </control>
                            <!-- status + current + local -->
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(status)) + !String.IsEmpty(ListItem.Property(current)) + !String.IsEmpty(ListItem.Property(local)) </visible>
                                <posx>374</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(21) }}</height>
                                <texture>script.plex/home/device/home.png</texture>
                            </control>
                            <!-- status + not current -->
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(status)) + String.IsEmpty(ListItem.Property(current))</visible>
                                <posx>456</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(24) }}</height>
                                <texture>script.plex/home/device/$INFO[ListItem.Property(status)]</texture>
                            </control>
                            <!-- status + current -->
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(status)) + !String.IsEmpty(ListItem.Property(current))</visible>
                                <posx>415</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(24) }}</height>
                                <texture>script.plex/home/device/$INFO[ListItem.Property(status)]</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(current))</visible>
                                <posx>449</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>31</width>
                                <height>{{ vscale(24) }}</height>
                                <texture colordiffuse="FFFFFFFF">script.plex/home/device/check.png</texture>
                            </control>

                        </itemlayout>
                        <focusedlayout height="{{ vscale(100) }}">
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(first))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>500</width>
                                <height>{{ vscale(100) }}</height>
                                <texture colordiffuse="FFFFFFFF" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="image">
                                <visible>String.IsEmpty(ListItem.Property(first)) + String.IsEmpty(ListItem.Property(last)) + String.IsEmpty(ListItem.Property(only))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>500</width>
                                <height>{{ vscale(100) }}</height>
                                <texture colordiffuse="FFFFFFFF">script.plex/white-square.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(last))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>500</width>
                                <height>{{ vscale(100) }}</height>
                                <texture flipy="true" colordiffuse="FFFFFFFF" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(only))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>500</width>
                                <height>{{ vscale(100) }}</height>
                                <texture colordiffuse="FFFFFFFF" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="group">
                                <visible>!String.IsEmpty(ListItem.Label2)</visible>
                                <control type="label">
                                    <posx>20</posx>
                                    <posy>{{ vscale(20) }}</posy>
                                    <width>400</width>
                                    <height>{{ vscale(35) }}</height>
                                    <font>font12</font>
                                    <align>left</align>
                                    <aligny>center</aligny>
                                    <textcolor>FF000000</textcolor>
                                    <label>$INFO[ListItem.Label]</label>
                                </control>
                                <control type="label">
                                    <posx>20</posx>
                                    <posy>{{ vscale(50) }}</posy>
                                    <width>400</width>
                                    <height>{{ vscale(35) }}</height>
                                    <font>font12</font>
                                    <align>left</align>
                                    <aligny>center</aligny>
                                    <textcolor>FFFFFFFF</textcolor>
                                    <label>$INFO[ListItem.Label2]</label>
                                </control>
                            </control>
                            <control type="label">
                                <visible>String.IsEmpty(ListItem.Label2)</visible>
                                <posx>20</posx>
                                <posy>0</posy>
                                <width>400</width>
                                <height>{{ vscale(100) }}</height>
                                <font>font12</font>
                                <align>left</align>
                                <aligny>center</aligny>
                                <textcolor>FF000000</textcolor>
                                <label>$INFO[ListItem.Label]</label>
                            </control>

                            <!-- not status + not current + local -->
                            <control type="image">
                                <visible>String.IsEmpty(ListItem.Property(status)) + String.IsEmpty(ListItem.Property(current)) + !String.IsEmpty(ListItem.Property(local)) </visible>
                                <posx>456</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(21) }}</height>
                                <texture>script.plex/home/device/home.png</texture>
                            </control>
                            <!-- not status + current + local -->
                            <control type="image">
                                <visible>String.IsEmpty(ListItem.Property(status)) + !String.IsEmpty(ListItem.Property(current)) + !String.IsEmpty(ListItem.Property(local)) </visible>
                                <posx>415</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(21) }}</height>
                                <texture>script.plex/home/device/home.png</texture>
                            </control>
                            <!-- status + not current + local -->
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(status)) + String.IsEmpty(ListItem.Property(current)) + !String.IsEmpty(ListItem.Property(local)) </visible>
                                <posx>415</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(21) }}</height>
                                <texture>script.plex/home/device/home.png</texture>
                            </control>
                            <!-- status + current + local -->
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(status)) + !String.IsEmpty(ListItem.Property(current)) + !String.IsEmpty(ListItem.Property(local)) </visible>
                                <posx>374</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(21) }}</height>
                                <texture>script.plex/home/device/home.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(status)) + String.IsEmpty(ListItem.Property(current))</visible>
                                <posx>456</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(24) }}</height>
                                <texture>script.plex/home/device/focus-$INFO[ListItem.Property(status)]</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(status)) + !String.IsEmpty(ListItem.Property(current))</visible>
                                <posx>415</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>24</width>
                                <height>{{ vscale(24) }}</height>
                                <texture>script.plex/home/device/focus-$INFO[ListItem.Property(status)]</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(current))</visible>
                                <posx>449</posx>
                                <posy>{{ vscale(38) }}</posy>
                                <width>31</width>
                                <height>{{ vscale(24) }}</height>
                                <texture colordiffuse="FF000000">script.plex/home/device/check.png</texture>
                            </control>

                        </focusedlayout>
                    </control>

                    <control type="scrollbar" id="261">
                        <posx>492</posx>
                        <posy>{{ vscale(20) }}</posy>
                        <width>8</width>
                        <height>{{ vscale(860) }}</height>
                        <texturesliderbackground>-</texturesliderbackground>
                        <texturesliderbar colordiffuse="20FFFFFF" border="4">script.plex/white-square.png</texturesliderbar>
                        <texturesliderbarfocus colordiffuse="20E5A00D" border="4">script.plex/white-square.png</texturesliderbarfocus>
                        <textureslidernib>-</textureslidernib>
                        <textureslidernibfocus>-</textureslidernibfocus>
                        <pulseonselect>false</pulseonselect>
                        <orientation>vertical</orientation>
                        <showonepage>false</showonepage>
                        <onleft>250</onleft>
                    </control>

                </control>
            </control>
            <control type="button" id="202">
                <width max="500">auto</width>
                <height>{{ vscale(66) }}</height>
                <font>font12</font>
                <textcolor>FFFFFFFF</textcolor>
                <focusedcolor>FF000000</focusedcolor>
                <align>right</align>
                <aligny>center</aligny>
                <texturefocus colordiffuse="FFFFFFFF" border="10">script.plex/white-square-rounded.png</texturefocus>
                <texturenofocus>-</texturenofocus>
                <textoffsetx>100</textoffsetx>
                <textoffsety>0</textoffsety>
                <label>$INFO[Window.Property(user.name)]</label>
                <onunfocus condition="!String.IsEmpty(Window.Property(show.options))">SetFocus(250)</onunfocus>
            </control>
            <control type="group">
                <posx>-87</posx>
                <width>87</width>
                <height>{{ vscale(66) }}</height>
                <control type="image">
                    <posx>0</posx>
                    <posy>{{ vscale(14) }}</posy>
                    <width>40</width>
                    <height>{{ vscale(39) }}</height>
                    <texture diffuse="script.plex/home/avatar-diffuse.png" fallback="script.plex/gray-square.png">$INFO[Window.Property(user.avatar)]</texture>
                </control>
                <control type="label">
                    <visible>String.IsEmpty(Window.Property(user.avatar))</visible>
                    <posx>0</posx>
                    <posy>{{ vscale(14) }}</posy>
                    <width>40</width>
                    <height>{{ vscale(39) }}</height>
                    <font>font10</font>
                    <align>center</align>
                    <aligny>center</aligny>
                    <textcolor>FFFFFFFF</textcolor>
                    <label>[B]$INFO[Window.Property(user.avatar.letter)][/B]</label>
                </control>
                <control type="image">
                    <visible>!String.IsEmpty(Window(10000).Property(script.plezy.native.update_available))</visible>
                    <posx>-8</posx>
                    <posy>{{ vscale(38) }}</posy>
                    <width>16</width>
                    <height>{{ vscale(14) }}</height>
                    <texture>script.plex/home/device/update_small.png</texture>
                    <colordiffuse>FF00CC00</colordiffuse>
                </control>
                <control type="image">
                    <visible>!Control.HasFocus(202)</visible>
                    <posx>53</posx>
                    <posy>{{ vscale(27) }}</posy>
                    <width>15</width>
                    <height>{{ vscale(13) }}</height>
                    <texture>script.plex/indicators/dropdown-triangle.png</texture>
                    <colordiffuse>99FFFFFF</colordiffuse>
                </control>
                <control type="image">
                    <visible>Control.HasFocus(202)</visible>
                    <posx>53</posx>
                    <posy>{{ vscale(27) }}</posy>
                    <width>15</width>
                    <height>{{ vscale(13) }}</height>
                    <texture>script.plex/indicators/dropdown-triangle.png</texture>
                    <colordiffuse>FF222222</colordiffuse>
                </control>
                <control type="group" id="901">
                    <visible>Control.HasFocus(250) | !String.IsEmpty(Window.Property(show.options))</visible>
                    <posx>-213</posx>
                    <posy>{{ vscale(70) }}</posy>
                    <control type="image" id="801">
                        <posx>-40</posx>
                        <posy>{{ vscale(-40) }}</posy>
                        <width>380</width>
                        <height>{{ vscale(146) }}</height>
                        <texture border="42">script.plex/drop-shadow.png</texture>
                    </control>
                    <control type="image">
                        <posx>226</posx>
                        <posy>{{ vscale(-13) }}</posy>
                        <width>15</width>
                        <height>{{ vscale(13) }}</height>
                        <texture flipy="true">script.plex/indicators/dropdown-triangle.png</texture>
                        <colordiffuse>FF1F1F1F</colordiffuse>
                    </control>
                    <control type="list" id="250">
                        <hitrect x="0" y="-10" w="300" h="422" />
                        <posx>0</posx>
                        <posy>0</posy>
                        <width>300</width>
                        <height>{{ vscale(422) }}</height>
                        <onleft>201</onleft>
                        <onunfocus>SetProperty(show.options,)</onunfocus>
                        <scrolltime>200</scrolltime>
                        <orientation>vertical</orientation>
                        <!-- ITEM LAYOUT ########################################## -->
                        <itemlayout height="{{ vscale(66) }}">
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(first))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <texture colordiffuse="FF1F1F1F" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="image">
                                <visible>String.IsEmpty(ListItem.Property(first)) + String.IsEmpty(ListItem.Property(last)) + String.IsEmpty(ListItem.Property(only))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <texture colordiffuse="FF1F1F1F">script.plex/white-square.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(last))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <texture flipy="true" colordiffuse="FF1F1F1F" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(only))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <texture colordiffuse="FF1F1F1F" border="10">script.plex/white-square-rounded.png</texture>
                            </control>
                            <control type="label">
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <font>font12</font>
                                <align>center</align>
                                <aligny>center</aligny>
                                <textcolor>FFFFFFFF</textcolor>
                                <label>$INFO[ListItem.Label]</label>
                            </control>
                        </itemlayout>
                        <focusedlayout height="{{ vscale(66) }}">
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(first))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <texture colordiffuse="FFFFFFFF" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="image">
                                <visible>String.IsEmpty(ListItem.Property(first)) + String.IsEmpty(ListItem.Property(last)) + String.IsEmpty(ListItem.Property(only))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <texture colordiffuse="FFFFFFFF">script.plex/white-square.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(last))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <texture flipy="true" colordiffuse="FFFFFFFF" border="10">script.plex/white-square-top-rounded.png</texture>
                            </control>
                            <control type="image">
                                <visible>!String.IsEmpty(ListItem.Property(only))</visible>
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <texture colordiffuse="FFFFFFFF" border="10">script.plex/white-square-rounded.png</texture>
                            </control>
                            <control type="label">
                                <posx>0</posx>
                                <posy>0</posy>
                                <width>300</width>
                                <height>{{ vscale(66) }}</height>
                                <font>font12</font>
                                <align>center</align>
                                <aligny>center</aligny>
                                <textcolor>FF000000</textcolor>
                                <label>$INFO[ListItem.Label]</label>
                            </control>
                        </focusedlayout>
                    </control>
                </control>
            </control>
            <control type="image">
                <!-- dummy image to allow shadow -->
                <width>40</width>
                <height>{{ vscale(10) }}</height>
                <texture>-</texture>
            </control>
        </control>
    </control>
</control>

<control type="group">
    <visible>!String.IsEmpty(Window.Property(search.dialog))</visible>
    <control type="group" >
        <visible>!String.IsEmpty(Window.Property(search.dialog.hasresults))</visible>
        <control type="image">
            <posx>0</posx>
            <posy>0</posy>
            <width>1920</width>
            <height>1080</height>
            <texture>script.plex/home/background-fallback.png</texture>
            {% include "includes/scale_background.xml.tpl" %}
        </control>
        <control type="image">
            <posx>0</posx>
            <posy>0</posy>
            <width>1920</width>
            <height>1080</height>
            <texture background="true">$INFO[Window.Property(background)]</texture>
            {% include "includes/scale_background.xml.tpl" %}
        </control>
    </control>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture colordiffuse="99606060">script.plex/white-square.png</texture>
        {% include "includes/scale_background.xml.tpl" %}
    </control>
</control>

<control type="group">
    <visible>String.IsEmpty(Window.Property(busy)) + !String.IsEmpty(Window.Property(no.content))</visible>
    <posx>0</posx>
    <posy>{{ vscale(465) }}</posy>
    <control type="label">
        <scroll>false</scroll>
        <posx>60</posx>
        <posy>0</posy>
        <width>1800</width>
        <height>{{ vscale(35) }}</height>
        <font>font13</font>
        <align>center</align>
        <textcolor>FFFFFFFF</textcolor>
        <label>[B]$ADDON[script.plezy.native 32452][/B]</label>
    </control>
    <control type="label">
        <scroll>false</scroll>
        <posx>60</posx>
        <posy>{{ vscale(60) }}</posy>
        <width>1800</width>
        <height>{{ vscale(35) }}</height>
        <font>font13</font>
        <align>center</align>
        <textcolor>FFCCCCCC</textcolor>
        <label>$ADDON[script.plezy.native 32453]</label>
    </control>
</control>

<control type="group">
    <visible>String.IsEmpty(Window.Property(busy)) + !String.IsEmpty(Window.Property(loading.content))</visible>
    <posx>0</posx>
    <posy>{{ vscale(465) }}</posy>
    <control type="label">
        <scroll>false</scroll>
        <posx>60</posx>
        <posy>0</posy>
        <width>1800</width>
        <height>{{ vscale(35) }}</height>
        <font>font13</font>
        <align>center</align>
        <textcolor>FFFFFFFF</textcolor>
        <label>[B]$ADDON[script.plezy.native 34020][/B]</label>
    </control>
    <control type="label">
        <scroll>false</scroll>
        <posx>60</posx>
        <posy>{{ vscale(60) }}</posy>
        <width>1800</width>
        <height>{{ vscale(35) }}</height>
        <font>font13</font>
        <align>center</align>
        <textcolor>FFCCCCCC</textcolor>
        <label>[B]$ADDON[script.plezy.native 34021][/B]</label>
    </control>
</control>

<control type="group">
    <visible>!String.IsEmpty(Window.Property(busy))</visible>
    <animation effect="fade" start="0" end="100">Visible</animation>
    <posx>840</posx>
    <posy>{{ vscale(465) }}</posy>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>240</width>
        <height>{{ vscale(150) }}</height>
        <texture>script.plex/busy-back.png</texture>
        <colordiffuse>A0FFFFFF</colordiffuse>
    </control>
    <control type="image">
        <posx>75</posx>
        <posy>{{ vscale(56) }}</posy>
        <width>90</width>
        <height>{{ vscale(38) }}</height>
        <texture diffuse="script.plex/busy-diffuse.png">script.plex/busy.gif</texture>
    </control>
</control>
{% endblock header %}
