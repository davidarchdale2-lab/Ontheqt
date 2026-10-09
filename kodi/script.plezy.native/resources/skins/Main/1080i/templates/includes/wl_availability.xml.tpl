{% if plezy %}{# Plezy detail: the availability note in the action row's track-status slot (right-aligned, read-only).
   params: x (default 600), y (default 590), width (default 1260), height (default 56); right-aligned, so the note
   ends at x + width (1860) and only grows left as far as its text needs; bottom-weighted like the track status #}
    {% with ax = x|default(600) & ay = y|default(590) & aw = width|default(1260) & ah = height|default(56) %}
    <control type="grouplist">
        <visible>!String.IsEmpty(Window.Property(wl_server_availability_verbose))</visible>
        <posx>{{ ax }}</posx>
        <posy>{{ ay|vscale }}</posy>
        <width>{{ aw }}</width>
        <height>{{ ah|vscale }}</height>
        <align>right</align>
        <itemgap>0</itemgap>
        <orientation>horizontal</orientation>
        <usecontrolcoords>true</usecontrolcoords>
        <control type="label">
            <posy>{{ vscale(12) }}</posy>
            <width max="{{ aw }}">auto</width>
            <height>{{ (ah - 12)|vscale }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>[B]$ADDON[script.plezy.native 34005][/B]</label>
        </control>
        <control type="image">
            <posx>14</posx>
            <posy>{{ ((ah - 24) / 2 + 6)|vscale }}</posy>
            <width>24</width>
            <height>{{ vscale(24) }}</height>
            <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/dns.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="label">
            <posx>8</posx>
            <posy>{{ vscale(12) }}</posy>
            <width max="{{ aw - 300 }}">auto</width>
            <height>{{ (ah - 12)|vscale }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>true</scroll>
            <scrollspeed>10</scrollspeed>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>[B]$INFO[Window.Property(wl_server_availability_verbose)][/B]</label>
        </control>
    </control>
    {% endwith %}
{% else %}
    <control type="grouplist">
        <visible>!String.IsEmpty(Window.Property(wl_server_availability_verbose))</visible>
        <posx>466</posx>
        <posy>{{ vscale(223) }}</posy>
        <width>1360</width>
        <height>{{ vscale(34) }}</height>
        <align>left</align>
        <itemgap>15</itemgap>
        <orientation>horizontal</orientation>
        <usecontrolcoords>true</usecontrolcoords>
        <control type="button">
            <width>auto</width>
            <height>{{ vscale(34) }}</height>
            <font>font12</font>
            <align>center</align>
            <aligny>center</aligny>
            <focusedcolor>FFFFFFFF</focusedcolor>
            <textcolor>FFFFFFFF</textcolor>
            <textoffsetx>15</textoffsetx>
            <texturefocus colordiffuse="40000000" border="8">script.plex/white-square-rounded-top-padded.png</texturefocus>
            <texturenofocus colordiffuse="40000000" border="8">script.plex/white-square-rounded-top-padded.png</texturenofocus>
            <label>[UPPERCASE]$ADDON[script.plezy.native 34005][/UPPERCASE]</label>
        </control>
        <control type="label">
            <width>1160</width>
            <height>{{ vscale(34) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <textcolor>FFFFFFFF</textcolor>
            <scroll>true</scroll>
            <scrollspeed>10</scrollspeed>
            <label>$INFO[Window.Property(wl_server_availability_verbose)]</label>
        </control>
    </control>
{% endif %}