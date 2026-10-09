{% extends "base.xml.tpl" %}
{% block headers %}
    <defaultcontrol>800</defaultcontrol>
    <zorder>100</zorder>
{% endblock %}
{% block backgroundcolor %}{% endblock %}

{% block controls %}
{#
  Plezy player chrome (edde746/plezy lib/widgets/video_controls/desktop_video_controls.dart, used on TV too), drawn
  at x1.5 of Plezy's unscaled logical px (PLEZY_DESIGN.md). Geometry shared with lib/windows/seekdialog.py lives in
  lib/plezy_player_osd.py (tests/test_player_osd.py keeps the two in sync). Everything below the header is anchored
  to the bottom edge ("vscale(1080 - y)r"), so non-16:9 displays keep the chrome at the bottom; 1080p tops:
    scrims       black .70 -> 0 over the top and bottom 20% (video_controls.dart gradient stops 0/.2/.8/1)
    header       0..84: decorative back arrow, series/movie title + "S1 · E2 · Title · 45m", clock (white70)
    timeline     track 1572x12 at x 174, centre y 962 (BAR_X/BAR_W/TRACK_Y); timestamps at x 36 and ending 1884
    scrub        time pill 112x40 (group 202, top 898) + 28px knob on the track; preview 240x135 (group 300, top 809)
    buttons      row 972..1068 (centre 1020): transport cluster from x 36, track/settings cluster ending at 1884
    big seek     12 dots on the track, or the chapter strip (318 pitch, 296x167 thumbs) above the timeline
    skip marker  white pill right 36, bottom 36 (chrome hidden) / 172 (chrome shown)
#}
<control type="group" id="804">
    <visible>!String.IsEmpty(Window.Property(show.blackout))</visible>
    <animation effect="fade" time="200" delay="200" end="0">Hidden</animation>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>1080</height>
        <texture>script.plex/white-square.png</texture>
        <colordiffuse>FF000000</colordiffuse>
    </control>
</control>

<control type="group" id="802">
    <!-- This is the buttonless OSD: scrims, header and timeline (also shown while seeking without the OSD) -->
    <visible>[!String.IsEmpty(Window.Property(show.OSD)) | [String.IsEmpty(Window.Property(is_plextuary)) + Window.IsVisible(seekbar)] | !String.IsEmpty(Window.Property(button.seek))] + !Window.IsVisible(osdvideosettings) + !Window.IsVisible(osdaudiosettings) + !Window.IsVisible(osdsubtitlesettings) + !Window.IsVisible(subtitlesearch) + !Window.IsActive(playerprocessinfo) + !Window.IsActive(selectdialog) + !Window.IsVisible(osdcmssettings)</visible>
    <animation effect="fade" start="0" end="100" time="200">Visible</animation>
    <animation effect="fade" time="200" delay="200" end="0">Hidden</animation>

    <!-- controls gradient: black .7 -> 0 over the top 20%, 0 -> .7 over the bottom 20% -->
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>1920</width>
        <height>{{ vscale(216) }}</height>
        <texture>script.plex/plezy/scrim-top.png</texture>
    </control>
    <control type="image">
        <visible>String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))</visible>
        <posx>0</posx>
        <posy>{{ vscale(216) }}r</posy>
        <width>1920</width>
        <height>{{ vscale(216) }}</height>
        <texture flipy="true">script.plex/plezy/scrim-top.png</texture>
    </control>

    <!-- header (VideoControlsHeader, multi-line): back arrow, title column, clock -->
    <control type="group">
        <posx>0</posx>
        <posy>0</posy>
        <control type="image">
            <posx>27</posx>
            <posy>{{ vscale(27) }}</posy>
            <width>30</width>
            <height>{{ vscale(30) }}</height>
            <texture colordiffuse="{{ core.plezy.player_fg }}">script.plex/plezy/icons/arrow_back.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="label">
            <visible>!String.IsEmpty(Window.Property(is.show))</visible>
            <posx>108</posx>
            <posy>{{ vscale(8) }}</posy>
            <width>1440</width>
            <height>{{ vscale(40) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <scroll>false</scroll>
            <label>[B]$INFO[VideoPlayer.TVShowTitle][/B]</label>
        </control>
        <control type="label">
            <visible>String.IsEmpty(Window.Property(is.show))</visible>
            <posx>108</posx>
            <posy>{{ vscale(8) }}</posy>
            <width>1440</width>
            <height>{{ vscale(40) }}</height>
            <font>font13</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <scroll>false</scroll>
            <label>[B]$INFO[VideoPlayer.Title][/B]</label>
        </control>
        <control type="label">
            <posx>108</posx>
            <posy>{{ vscale(46) }}</posy>
            <width>1440</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg_muted }}</textcolor>
            <scroll>false</scroll>
            <label>$INFO[Window.Property(video.line2)]</label>
        </control>
        <control type="label">
            <posx>1584</posx>
            <posy>{{ vscale(22) }}</posy>
            <width>300</width>
            <height>{{ vscale(40) }}</height>
            <font>font12</font>
            <align>right</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg_muted }}</textcolor>
            <label>$INFO[System.Time]</label>
        </control>
    </control>

    <!-- timeline row (VideoTimelineBar): position | slider | remaining; top 944, anchored to the bottom edge -->
    <control type="group">
        <animation effect="fade" start="100" end="0" time="150" condition="!String.IsEmpty(Window.Property(playlist.visible))">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(136) }}r</posy>
        <width>1920</width>
        <height>{{ vscale(36) }}</height>
        <control type="label">
            <visible>!String.IsEmpty(Window.Property(direct.play)) + [String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))]</visible>
            <posx>36</posx>
            <posy>0</posy>
            <width>120</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <label>$INFO[Player.Time($INFO[Window.Property(time.fmt)])]</label>
        </control>
        <control type="label">
            <visible>String.IsEmpty(Window.Property(direct.play)) + [String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))]</visible>
            <posx>36</posx>
            <posy>0</posy>
            <width>120</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <label>$INFO[Window.Property(time.current)]</label>
        </control>
        <control type="label">
            <visible>!String.IsEmpty(Window.Property(direct.play)) + [String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))]</visible>
            <posx>1764</posx>
            <posy>0</posy>
            <width>120</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>right</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <label>$INFO[Player.TimeRemaining($INFO[Window.Property(time.fmt)])]$INFO[Window.Property(time.add)]</label>
        </control>
        <control type="label">
            <visible>String.IsEmpty(Window.Property(direct.play)) + [String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))]</visible>
            <posx>1764</posx>
            <posy>0</posy>
            <width>120</width>
            <height>{{ vscale(36) }}</height>
            <font>font12</font>
            <align>right</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <label>$INFO[Window.Property(time.left)]</label>
        </control>

        <!-- slider: 12px pill track; Python sizes 206 (buffer), 201 (played) and 200 (seek span) -->
        <control type="group">
            <posx>174</posx>
            <posy>{{ vscale(12) }}</posy>
            <control type="image">
                <visible>String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))</visible>
                <posx>0</posx>
                <posy>0</posy>
                <width>1572</width>
                <height>{{ vscale(12) }}</height>
                <texture border="6" colordiffuse="{{ core.plezy.player_track }}">script.plex/plezy/r6.png</texture>
            </control>
            <control type="image" id="206">
                <visible>!String.IsEmpty(Window.Property(show.buffer)) + [String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))]</visible>
                <posx>0</posx>
                <posy>0</posy>
                <width>1</width>
                <height>{{ vscale(12) }}</height>
                <texture border="6" colordiffuse="{{ core.plezy.player_buffer }}">script.plex/plezy/r6.png</texture>
            </control>
            <control type="image" id="201">
                <visible>String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))</visible>
                <posx>0</posx>
                <posy>0</posy>
                <width>1</width>
                <height>{{ vscale(12) }}</height>
                <texture border="6" colordiffuse="{{ core.plezy.player_fg }}">script.plex/plezy/r6.png</texture>
            </control>
            <control type="image" id="200">
                <visible>[Control.HasFocus(100) | !String.IsEmpty(Window.Property(button.seek))] + [String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))]</visible>
                <posx>0</posx>
                <posy>0</posy>
                <width>1</width>
                <height>{{ vscale(12) }}</height>
                <texture border="6" colordiffuse="{{ core.plezy.player_fg_subtle }}">script.plex/plezy/r6.png</texture>
            </control>
        </control>
    </control>
</control>
<control type="button" id="800">
    <visible allowhiddenfocus="true">String.IsEmpty(Window.Property(show.OSD))</visible>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texturefocus>-</texturefocus>
    <texturenofocus>-</texturenofocus>
    <label> </label>
    <onclick condition="String.IsEmpty(Window.Property(button.seek)) + String.IsEmpty(Window.Property(marker.countdown)) + !String.IsEmpty(Window.Property(mouse.mode))">SetProperty(show.OSD,1)</onclick>
</control>

<!-- PPI: Plezy's performance overlay card (black 80%, radius 8 -> 12), top-left under the header -->
<control type="group" id="803">
    <visible>!String.IsEmpty(Window.Property(show.PPI)) + String.IsEmpty(Window.Property(settings.visible)) + String.IsEmpty(Window.Property(playlist.visible))</visible>
    <animation effect="fade" start="0" end="100" time="300">Visible</animation>
    <animation effect="fade" start="100" end="0" time="200">Hidden</animation>
    <posx>24</posx>
    <posy>{{ vscale(96) }}</posy>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>1872</width>
        <height>{{ vscale(404) }}</height>
        <texture border="12" colordiffuse="{{ core.plezy.player_card }}">script.plex/plezy/r12.png</texture>
    </control>
    <control type="grouplist">
        <posx>24</posx>
        <posy>{{ vscale(18) }}</posy>
        <width>1824</width>
        <height>{{ vscale(328) }}</height>
        <orientation>horizontal</orientation>
        <itemgap>36</itemgap>
        <control type="grouplist">
            <width>800</width>
            <height>{{ vscale(328) }}</height>
            <itemgap>0</itemgap>
            <control type="label">
                <width>800</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>$INFO[Player.Process(videodecoder),[COLOR {{ core.plezy.player_fg_subtle }}]$LOCALIZE[31139]:[/COLOR] ]$VAR[VideoHWDecoder, (,)]</label>
                <visible>Player.HasVideo</visible>
            </control>
            <control type="label">
                <width>800</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>$INFO[Player.Process(pixformat),[COLOR {{ core.plezy.player_fg_subtle }}]$LOCALIZE[31140]:[/COLOR] ]</label>
                <visible>Player.HasVideo</visible>
            </control>
            <control type="label">
                <width>800</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>$INFO[Player.Process(deintmethod),[COLOR {{ core.plezy.player_fg_subtle }}]$LOCALIZE[16038]:[/COLOR] ]</label>
                <visible>Player.HasVideo</visible>
            </control>
            <control type="label">
                <width>800</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>$INFO[Player.Process(videowidth),[COLOR {{ core.plezy.player_fg_subtle }}]$LOCALIZE[38031]:[/COLOR] ,x]$INFO[Player.Process(videoheight),, px]$INFO[Player.Process(videodar),$COMMA , AR]$INFO[Player.Process(videofps),$COMMA , FPS]</label>
                <visible>Player.HasVideo</visible>
            </control>
            <control type="textbox">
                <width>800</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <autoscroll delay="1000" time="1000" repeat="2000"></autoscroll>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>[COLOR {{ core.plezy.player_fg_subtle }}]$LOCALIZE[460]:[/COLOR] $INFO[Player.Process(audiochannels),,$COMMA ]$INFO[Player.Process(audiodecoder)]$INFO[Player.Process(audiobitspersample),$COMMA , bits]$INFO[Player.Process(audiosamplerate),$COMMA , Hz]</label>
            </control>
            <control type="label">
                <width>800</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>$INFO[System.Memory(used.percent),[COLOR {{ core.plezy.player_fg_subtle }}]$LOCALIZE[31030]:[/COLOR] ,]</label>
            </control>
        </control>
        <control type="grouplist">
            <width>988</width>
            <height>{{ vscale(328) }}</height>
            <itemgap>0</itemgap>
            <control type="label">
                <width>988</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>$INFO[Window.Property(ppi.Status)]</label>
                <visible>Player.HasVideo + !String.IsEmpty(Window.Property(ppi.Status))</visible>
            </control>
            <control type="label">
                <width>988</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>[COLOR {{ core.plezy.player_fg_subtle }}]Mode:[/COLOR] $INFO[Window.Property(ppi.Mode)]</label>
                <visible>Player.HasVideo + !String.IsEmpty(Window.Property(ppi.Mode))</visible>
            </control>
            <control type="label">
                <width>988</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>[COLOR {{ core.plezy.player_fg_subtle }}]Container:[/COLOR] $INFO[Window.Property(ppi.Container)]</label>
                <visible>Player.HasVideo + !String.IsEmpty(Window.Property(ppi.Container))</visible>
            </control>
            <control type="textbox">
                <width>988</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <autoscroll delay="1000" time="1000" repeat="2000"></autoscroll>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>[COLOR {{ core.plezy.player_fg_subtle }}]Video:[/COLOR] $INFO[Window.Property(ppi.Video)]</label>
                <visible>Player.HasVideo + !String.IsEmpty(Window.Property(ppi.Video))</visible>
            </control>
            <control type="textbox">
                <width>988</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <autoscroll delay="1000" time="1000" repeat="2000"></autoscroll>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>$INFO[Window.Property(ppi.Audio),[COLOR {{ core.plezy.player_fg_subtle }}]Audio:[/COLOR] ]$INFO[Window.Property(ppi.Subtitles),   [COLOR {{ core.plezy.player_fg_subtle }}]Subtitle:[/COLOR] ]</label>
                <visible>Player.HasVideo + [!String.IsEmpty(Window.Property(ppi.Audio)) | !String.IsEmpty(Window.Property(ppi.Subtitles))]</visible>
            </control>
            <control type="textbox">
                <width>988</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <autoscroll delay="1000" time="1000" repeat="2000"></autoscroll>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>[COLOR {{ core.plezy.player_fg_subtle }}]Server:[/COLOR] $INFO[Window.Property(ppi.User)]</label>
                <visible>Player.HasVideo + !String.IsEmpty(Window.Property(ppi.User))</visible>
            </control>
            <control type="label">
                <width>988</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>[COLOR {{ core.plezy.player_fg_subtle }}]Buffer:[/COLOR] $INFO[Player.CacheLevel]%$INFO[Window.Property(ppi.BufferMB), (of ~, MB]$INFO[Window.Property(ppi.ReadFactor),$COMMA Readfactor: ,x)]$INFO[Window.Property(ppi.AReadFactor),$COMMA Readfactor: ,)]</label>
                <visible>Player.HasVideo + String.IsEmpty(Window.Property(ppi.Buffered))</visible>
            </control>
            <control type="label">
                <width>988</width>
                <height>{{ vscale(40) }}</height>
                <aligny>center</aligny>
                <font>font10</font>
                <textcolor>{{ core.plezy.player_fg }}</textcolor>
                <label>[COLOR {{ core.plezy.player_fg_subtle }}]Buffer:[/COLOR] $INFO[Window.Property(ppi.Buffered)]% (% of Video cached)$INFO[Window.Property(ppi.BufferMB), (of ~, MB]$INFO[Window.Property(ppi.ReadFactor),$COMMA Readfactor:,x)]$INFO[Window.Property(ppi.AReadFactor),$COMMA Readfactor: ,)]</label>
                <visible>Player.HasVideo + !String.IsEmpty(Window.Property(ppi.Buffered))</visible>
            </control>
        </control>
    </control>
    <control type="label">
        <posx>24</posx>
        <posy>{{ vscale(346) }}</posy>
        <width>1824</width>
        <height>{{ vscale(40) }}</height>
        <aligny>center</aligny>
        <font>font10</font>
        <textcolor>{{ core.plezy.player_fg }}</textcolor>
        <label>$INFO[System.CpuUsage,[COLOR {{ core.plezy.player_fg_subtle }}]$LOCALIZE[13271][/COLOR] ]</label>
    </control>
</control>

<!-- scrub preview (TimelineSlider tooltip): 240x135 still above the knob; Python sets x (clamped) and y -->
<control type="group" id="300">
    <visible>!String.IsEmpty(Window.Property(has.bif)) + !String.IsEmpty(Window.Property(bif.image)) + String.IsEmpty(Window.Property(show.chapters)) + [Control.HasFocus(100) | Control.HasFocus(501) | !String.IsEmpty(Window.Property(button.seek))] + [String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))] </visible>
    <animation effect="fade" time="100" delay="100" end="100">Visible</animation>
    <posx>174</posx>
    <posy>{{ vscale(271) }}r</posy>
    <control type="image">
        <posx>-40</posx>
        <posy>{{ vscale(-36) }}</posy>
        <width>320</width>
        <height>{{ vscale(215) }}</height>
        <texture border="48" colordiffuse="{{ core.plezy.shadow }}">script.plex/plezy/glow.png</texture>
    </control>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>240</width>
        <height>{{ vscale(135) }}</height>
        <texture border="8" colordiffuse="{{ core.plezy.player_card }}">script.plex/plezy/r8.png</texture>
    </control>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>240</width>
        <height>{{ vscale(135) }}</height>
        <fadetime>10</fadetime>
        <texture diffuse="script.plex/plezy/mask-strip.png">$INFO[Window.Property(bif.image)]</texture>
        <aspectratio>scale</aspectratio>
    </control>
</control>

<control type="group" id="801">
    <!-- This is the OSD with buttons -->
    <visible>!String.IsEmpty(Window.Property(show.OSD)) + !Window.IsVisible(osdvideosettings) + !Window.IsVisible(osdaudiosettings) + !Window.IsVisible(osdsubtitlesettings) + !Window.IsVisible(subtitlesearch) + !Window.IsActive(playerprocessinfo) + !Window.IsActive(selectdialog) + !Window.IsVisible(osdcmssettings)</visible>
    <animation effect="fade" time="200" delay="200" end="0">Hidden</animation>

    <!-- button row: transport controls on the left, track/settings controls on the right (Plezy's Row with the
         finish time in the Expanded middle). Faded, not hidden, while the queue strip is open so focus is never
         left on a hidden control. -->
    <control type="group" id="400">
        <defaultcontrol>406</defaultcontrol>
        <animation effect="fade" start="100" end="0" time="150" condition="!String.IsEmpty(Window.Property(playlist.visible))">Conditional</animation>
        <posx>0</posx>
        <posy>{{ vscale(108) }}r</posy>
        <width>1920</width>
        <height>{{ vscale(96) }}</height>

        <control type="grouplist" id="440">
            <defaultcontrol>406</defaultcontrol>
            <posx>30</posx>
            <posy>0</posy>
            <width>1100</width>
            <height>{{ vscale(96) }}</height>
            <orientation>horizontal</orientation>
            <align>left</align>
            <itemgap>0</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <onup>100</onup>
            <ondown>501</ondown>
            <onright>441</onright>
            <control type="image">{# keeps the first control's 1.12 zoom inside the grouplist's clip #}
                <width>6</width>
                <height>1</height>
                <texture>-</texture>
            </control>
            {% include "includes/seek_osd_button.xml.tpl" with gid=4404 & bid=404 & asset="next" & flip=True & vis="!String.IsEmpty(Window.Property(pq.hasprev)) + !String.IsEmpty(Window.Property(nav.prevnext))" & onright=4424 %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4424 & bid=424 & asset="next" & flip=True & disabled=True & vis="String.IsEmpty(Window.Property(pq.hasprev)) + !String.IsEmpty(Window.Property(nav.prevnext))" %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4405 & bid=405 & asset="skip-forward" & flip=True & size="small" & vis="!String.IsEmpty(Window.Property(nav.ffwdrwd))" & onleft=4424 & onright=426 %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=426 & bid=406 & asset="pause" & alt_asset="play" & alt_cond="Player.Paused | Player.Forwarding | Player.Rewinding" & size="play" & onleft=4405 & onright=4408 & onclick="PlayerControl(Play)" %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4408 & bid=408 & asset="skip-forward" & size="small" & vis="!String.IsEmpty(Window.Property(nav.ffwdrwd))" & onleft=426 & onright=4409 %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4409 & bid=409 & asset="next" & vis="!String.IsEmpty(Window.Property(pq.hasnext)) + !String.IsEmpty(Window.Property(nav.prevnext))" & onleft=4408 & onright=441 %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4419 & bid=419 & asset="next" & disabled=True & vis="String.IsEmpty(Window.Property(pq.hasnext)) + !String.IsEmpty(Window.Property(nav.prevnext))" %}
            <!-- "Ends at 9:45 PM" (FinishTimeBuilder): white70, 8 -> 12px after the last control -->
            <control type="label">
                <visible>!String.IsEmpty(Window.Property(media.show_ends)) + !String.IsEmpty(Window.Property(direct.play))</visible>
                <posx>12</posx>
                <posy>0</posy>
                <width max="460">auto</width>
                <height>{{ vscale(96) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.player_fg_muted }}</textcolor>
                <label>$INFO[Window.Property(time.ends_label)] $INFO[Player.FinishTime($INFO[Window.Property(time.fmt.ends)])]</label>
            </control>
            <control type="label">
                <visible>!String.IsEmpty(Window.Property(media.show_ends)) + String.IsEmpty(Window.Property(direct.play))</visible>
                <posx>12</posx>
                <posy>0</posy>
                <width max="460">auto</width>
                <height>{{ vscale(96) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.player_fg_muted }}</textcolor>
                <label>$INFO[Window.Property(time.ends_label)] $INFO[Window.Property(time.end)]</label>
            </control>
            <control type="label">
                <visible>Player.IsTempo</visible>
                <posx>16</posx>
                <posy>0</posy>
                <width max="120">auto</width>
                <height>{{ vscale(96) }}</height>
                <font>font10</font>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.player_fg_muted }}</textcolor>
                <label>$INFO[Player.PlaySpeed]x</label>
            </control>
        </control>

        <control type="grouplist" id="441">
            <defaultcontrol always="true">403</defaultcontrol>
            <posx>1290</posx>
            <posy>0</posy>
            <width>600</width>
            <height>{{ vscale(96) }}</height>
            <orientation>horizontal</orientation>
            <align>right</align>
            <itemgap>0</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            <onup>100</onup>
            <ondown>501</ondown>
            <onleft>440</onleft>
            {% include "includes/seek_osd_button.xml.tpl" with gid=4403 & bid=403 & asset="settings" & onleft=440 & onright=4412 %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4412 & bid=412 & asset="subtitle" & vis="!String.IsEmpty(Window.Property(nav.quick_subtitles))" & onleft=4403 & onright=4410 %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4410 & bid=410 & asset="pqueue" & vis="[!String.IsEmpty(Window.Property(pq.hasnext)) | !String.IsEmpty(Window.Property(pq.hasprev))] + !String.IsEmpty(Window.Property(nav.playlist))" & onleft=4412 & onright=4430 %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4430 & bid=430 & asset="pqueue" & disabled=True & vis="String.IsEmpty(Window.Property(pq.hasnext)) + String.IsEmpty(Window.Property(pq.hasprev)) + !String.IsEmpty(Window.Property(nav.playlist))" %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=421 & bid=401 & asset="repeat" & vis="!String.IsEmpty(Window.Property(nav.repeat))" & onleft=4430 & onright=4402 & states=[("!Playlist.IsRepeatOne + !Playlist.IsRepeat + String.IsEmpty(Window.Property(pq.repeat)) + String.IsEmpty(Window.Property(pq.repeat.one))", "repeat", False), ("[Playlist.IsRepeat | !String.IsEmpty(Window.Property(pq.repeat))] + !Playlist.IsRepeatOne + String.IsEmpty(Window.Property(pq.repeat.one))", "repeat", True), ("Playlist.IsRepeatOne | !String.IsEmpty(Window.Property(pq.repeat.one))", "repeat-one", True)] %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4402 & bid=402 & asset="shuffle" & alt_asset="shuffle" & alt_active=True & alt_cond="!String.IsEmpty(Window.Property(pq.shuffled))" & vis="!String.IsEmpty(Window.Property(has.playlist)) + !String.IsEmpty(Window.Property(nav.shuffle))" & onleft=421 & onright=4422 %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4422 & bid=422 & asset="shuffle" & disabled=True & vis="String.IsEmpty(Window.Property(has.playlist)) + !String.IsEmpty(Window.Property(nav.shuffle))" %}
            <!-- VS10 mode switcher - CoreELEC/Amlogic only. Visibility controlled via nav.vs10 window property
                 set in seekdialog.py. To restrict to CoreELEC hardware once tested, change the Python side:
                 self.setBoolProperty('nav.vs10', xbmc.getCondVisibility('System.AddonIsEnabled(service.coreelec.settings)')) -->
            {% if theme.assets.buttons.base == "script.plex/buttons/player/plezy/" %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4413 & bid=413 & asset="vs10" & size="small" & vis="!String.IsEmpty(Window.Property(nav.vs10))" & onleft=4422 & onright=4407 %}
            {% else %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4413 & bid=413 & asset="vs10" & size="small" & abase="script.plex/buttons/player/modern/" & nosfx=True & vis="!String.IsEmpty(Window.Property(nav.vs10))" & onleft=4422 & onright=4407 %}
            {% endif %}
            {% include "includes/seek_osd_button.xml.tpl" with gid=4407 & bid=407 & asset="stop" & onleft=4413 %}
            <control type="image">{# keeps the last control's 1.12 zoom inside the grouplist's clip #}
                <width>6</width>
                <height>1</height>
                <texture>-</texture>
            </control>
        </control>
    </control>

    <!-- timeline focus target (no ring, no scale: the knob shows instead); also the mouse seek area -->
    <control type="button" id="100">
        <posx>174</posx>
        <posy>{{ vscale(142) }}r</posy>
        <width>1572</width>
        <height>{{ vscale(48) }}</height>
        <onup>501</onup>
        <ondown>400</ondown>
        <texturefocus>-</texturefocus>
        <texturenofocus>-</texturenofocus>
    </control>

    <!-- big seek: 12 dots on the track (Python moves the group), or the chapter strip (ContentStrip) -->
    <control type="group" id="500">
        <visible>String.IsEmpty(Window.Property(mouse.mode)) + String.IsEmpty(Window.Property(hide.bigseek)) + [Control.HasFocus(501) | Control.HasFocus(100)] + [!String.IsEmpty(Window.Property(show.chapters)) | String.IsEmpty(Window.Property(has.chapters))]</visible>
        <posx>0</posx>
        <posy>0</posy>
        <control type="group">
            <visible>!String.IsEmpty(Window.Property(has.chapters))</visible>
            <posx>0</posx>
            <posy>{{ vscale(560) }}r</posy>
            <width>1920</width>
            <height>{{ vscale(560) }}</height>
            <!-- ContentStripPanel: transparent -> black .65 at 42% -> .70 -->
            <control type="image">
                <posx>0</posx>
                <posy>0</posy>
                <width>1920</width>
                <height>{{ vscale(560) }}</height>
                <texture>script.plex/plezy/scrim-strip.png</texture>
            </control>
            <control type="label">
                <posx>0</posx>
                <posy>{{ vscale(62) }}</posy>
                <width>1920</width>
                <height>{{ vscale(36) }}</height>
                <font>font10</font>
                <align>center</align>
                <aligny>center</aligny>
                <textcolor>{{ core.plezy.player_fg_muted }}</textcolor>
                <label>$INFO[Window.Property(chapters.label)]</label>
            </control>
        </control>
        <control type="list" id="501">
            <hitrect x="-20" y="-20" w="10" h="10" />
            <posx>30</posx>
            <posy>{{ vscale(456) }}r</posy>
            <width>1860</width>
            <height>{{ vscale(250) }}</height>
            <ondown>100</ondown>
            <onfocus>SetProperty(hide.bigseek,)</onfocus>
            <scrolltime tween="cubic" easing="out">150</scrolltime>
            <orientation>horizontal</orientation>
            <preloaditems>4</preloaditems>
            <!-- 12 big seek steps: 8px dots on the track, the focused one becomes the 28px knob -->
            <itemlayout width="131" height="{{ vscale(32) }}" condition="String.IsEmpty(Window.Property(has.chapters))">
                <control type="image">
                    <posx>12</posx>
                    <posy>{{ vscale(12) }}</posy>
                    <width>8</width>
                    <height>{{ vscale(8) }}</height>
                    <texture colordiffuse="{{ core.plezy.player_tooltip }}">script.plex/plezy/circle.png</texture>
                </control>
            </itemlayout>
            <focusedlayout width="131" height="{{ vscale(32) }}" condition="String.IsEmpty(Window.Property(has.chapters))">
                <control type="image">
                    <visible>!Control.HasFocus(501)</visible>
                    <posx>12</posx>
                    <posy>{{ vscale(12) }}</posy>
                    <width>8</width>
                    <height>{{ vscale(8) }}</height>
                    <texture colordiffuse="{{ core.plezy.player_tooltip }}">script.plex/plezy/circle.png</texture>
                </control>
                <control type="group">
                    <visible>Control.HasFocus(501)</visible>
                    <control type="image">
                        <posx>0</posx>
                        <posy>{{ vscale(2) }}</posy>
                        <width>32</width>
                        <height>{{ vscale(30) }}</height>
                        <texture colordiffuse="{{ core.plezy.player_tooltip }}">script.plex/plezy/glow-circle.png</texture>
                    </control>
                    <control type="image">
                        <posx>2</posx>
                        <posy>{{ vscale(2) }}</posy>
                        <width>28</width>
                        <height>{{ vscale(28) }}</height>
                        <texture colordiffuse="{{ core.plezy.player_fg }}">script.plex/plezy/circle.png</texture>
                    </control>
                </control>
            </focusedlayout>

            <!-- chapter strip item (ContentStrip._buildStripItem, tablet metrics x1.5): 296x167 r9 thumb, white
                 border on the playing chapter, title + start time; focus = white 20% plate + 1.02 -->
            <itemlayout width="318" height="{{ vscale(250) }}" condition="!String.IsEmpty(Window.Property(has.chapters))">
                {% include "includes/seek_strip_item.xml.tpl" with focused=False & list_id=501 %}
            </itemlayout>
            <focusedlayout width="318" height="{{ vscale(250) }}" condition="!String.IsEmpty(Window.Property(has.chapters))">
                {% include "includes/seek_strip_item.xml.tpl" with focused=True & list_id=501 %}
            </focusedlayout>
        </control>
    </control>
</control>

<!-- scrub time pill + focus knob: Python places the group at (174 + w, 898) and the pill (203) inside it -->
<control type="group" id="202">
    <visible>[Control.HasFocus(100) | Control.HasFocus(501) | !String.IsEmpty(Window.Property(button.seek))] + [String.IsEmpty(Window.Property(no.osd.hide_info)) | !String.IsEmpty(Window.Property(show.OSD))]</visible>
    <posx>174</posx>
    <posy>{{ vscale(182) }}r</posy>
    <control type="group">
        <visible>Control.HasFocus(100) | !String.IsEmpty(Window.Property(button.seek))</visible>
        <control type="image">
            <posx>-20</posx>
            <posy>{{ vscale(47) }}</posy>
            <width>40</width>
            <height>{{ vscale(40) }}</height>
            <texture colordiffuse="{{ core.plezy.player_tooltip }}">script.plex/plezy/glow-circle.png</texture>
        </control>
        <control type="image">
            <posx>-14</posx>
            <posy>{{ vscale(50) }}</posy>
            <width>28</width>
            <height>{{ vscale(28) }}</height>
            <texture colordiffuse="{{ core.plezy.player_fg }}">script.plex/plezy/circle.png</texture>
        </control>
    </control>
    <control type="group" id="203">
        <posx>-56</posx>
        <posy>0</posy>
        <control type="image" id="204">
            <animation effect="fade" time="100" delay="100" end="100">Visible</animation>
            <posx>0</posx>
            <posy>0</posy>
            <width>112</width>
            <height>{{ vscale(40) }}</height>
            <texture border="6" colordiffuse="{{ core.plezy.player_tooltip }}">script.plex/plezy/r6.png</texture>
        </control>
        <control type="label" id="205">
            <posx>0</posx>
            <posy>0</posy>
            <width>112</width>
            <height>{{ vscale(40) }}</height>
            <font>font10</font>
            <align>center</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.player_fg }}</textcolor>
            <label>$INFO[Window.Property(time.selection)]</label>
        </control>
    </control>
</control>

<!-- SKIP MARKER BUTTON (SkipMarkerButton): white 90% pill, radius 8 -> 12, label + trailing fast_forward glyph;
     right 36, bottom 36 with the chrome hidden, 172 with it shown, above the chapter strip while it is open -->
<control type="grouplist" id="790">
    <visible>!String.IsEmpty(Window.Property(initialized))</visible>
    <animation effect="fade" start="100" end="0" time="150" condition="!String.IsEmpty(Window.Property(playlist.visible))">Conditional</animation>
    <animation type="Conditional" condition="String.IsEmpty(Window.Property(show.OSD)) + !Window.IsVisible(seekbar)" reversible="true">
        <effect type="slide" end="0,{{ vscale(136) }}" time="200" tween="sine" easing="inout"></effect>
    </animation>
    <animation type="Conditional" condition="Control.HasFocus(501) + !String.IsEmpty(Window.Property(has.chapters))" reversible="true">
        <effect type="slide" end="0,{{ vscale(-334) }}" time="200" tween="sine" easing="inout"></effect>
    </animation>
    <posx>390</posx>
    <posy>{{ vscale(242) }}r</posy>
    <width>1500</width>
    <height>{{ vscale(74) }}</height>
    <align>right</align>
    <orientation>horizontal</orientation>
    <itemgap>0</itemgap>
    <usecontrolcoords>true</usecontrolcoords>
    <control type="button" id="791">
        <visible>[!String.IsEmpty(Window.Property(show.markerSkip)) + String.IsEmpty(Window.Property(show.markerSkip_OSDOnly))] | [!String.IsEmpty(Window.Property(show.markerSkip_OSDOnly)) + !String.IsEmpty(Window.Property(show.OSD))]</visible>
        <animation effect="zoom" start="100" end="102" time="150" tween="cubic" easing="out" center="auto">Focus</animation>
        <animation effect="zoom" start="102" end="100" time="150" tween="cubic" easing="out" center="auto">UnFocus</animation>
        <posx>0</posx>
        <posy>{{ vscale(4) }}</posy>
        <width min="200">auto</width>
        <height>{{ vscale(66) }}</height>
        <align>left</align>
        <aligny>center</aligny>
        <textoffsetx>24</textoffsetx>
        <font>font12</font>
        <texturefocus border="12" colordiffuse="{{ core.plezy.player_fg }}">script.plex/plezy/r12.png</texturefocus>
        <texturenofocus border="12" colordiffuse="{{ core.plezy.player_skip }}">script.plex/plezy/r12.png</texturenofocus>
        <textcolor>{{ core.plezy.on_primary }}</textcolor>
        <focusedcolor>{{ core.plezy.on_primary }}</focusedcolor>
        <label>[B]$INFO[Window.Property(skipMarkerName)][/B]&#160;&#160;&#160;&#160;&#160;&#160;</label>
    </control>
    <!-- trailing glyph drawn inside the pill's right padding (an auto-width button can't hold an image):
         fast_forward, or skip_next when the final credits lead into the next episode (marker.next) -->
    <control type="group">
        <visible>[!String.IsEmpty(Window.Property(show.markerSkip)) + String.IsEmpty(Window.Property(show.markerSkip_OSDOnly))] | [!String.IsEmpty(Window.Property(show.markerSkip_OSDOnly)) + !String.IsEmpty(Window.Property(show.OSD))]</visible>
        <posx>-54</posx>
        <posy>{{ vscale(22) }}</posy>
        <width>30</width>
        <height>{{ vscale(30) }}</height>
        <control type="image">
            <visible>String.IsEmpty(Window.Property(marker.next))</visible>
            <posx>0</posx>
            <posy>0</posy>
            <width>30</width>
            <height>{{ vscale(30) }}</height>
            <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/fast_forward.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="image">
            <visible>!String.IsEmpty(Window.Property(marker.next))</visible>
            <posx>0</posx>
            <posy>0</posy>
            <width>30</width>
            <height>{{ vscale(30) }}</height>
            <texture colordiffuse="{{ core.plezy.on_primary }}">script.plex/plezy/icons/skip_next.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
    </control>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>30</width>
        <height>1</height>
        <texture>-</texture>
    </control>
</control>
{% endblock controls %}
