{% extends "base.xml.tpl" %}
{# Plezy AuthScreen, TV (edde746/plezy lib/screens/auth_screen.dart): the brand column on the left and, on the right, an
   autofocused primary "Sign in with Plex" stadium, an "or" divider and an outlined stadium ("Use a local server" stands in for
   "Use browser", which Kodi has no use for). The Jellyfin / Emby buttons do not apply. Controls the Python uses: 100 signs in,
   101 goes local. #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block backgroundcolor %}<backgroundcolor>0x{{ core.plezy.bg }}</backgroundcolor>{% endblock %}
{% block controls %}
{% include "includes/plezy_auth_brand.xml.tpl" %}

<control type="group">
    <posx>0</posx>
    <posy>{{ vperc(vscale(1080)) }}</posy>
    {% include "includes/plezy_signin_button.xml.tpl" with bid = 100 & x = 996 & y = 434 & w = 528 & variant = "primary" & down = 101 & label = "$ADDON[script.plezy.native 35220]" %}

    {# divider row: outlineVariant hairlines (2px at x1.5) around a muted "or" #}
    <control type="image">
        <posx>996</posx>
        <posy>{{ vscale(548) }}</posy>
        <width>204</width>
        <height>2</height>
        <texture colordiffuse="{{ core.plezy.outline }}">script.plex/white-square.png</texture>
    </control>
    <control type="label">
        <posx>1212</posx>
        <posy>{{ vscale(534) }}</posy>
        <width>96</width>
        <height>{{ vscale(30) }}</height>
        <font>font10</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$ADDON[script.plezy.native 35221]</label>
    </control>
    <control type="image">
        <posx>1320</posx>
        <posy>{{ vscale(548) }}</posy>
        <width>204</width>
        <height>2</height>
        <texture colordiffuse="{{ core.plezy.outline }}">script.plex/white-square.png</texture>
    </control>

    {% include "includes/plezy_signin_button.xml.tpl" with bid = 101 & x = 996 & y = 582 & w = 528 & variant = "outlined" & up = 100 & blank = True %}
    {# OutlinedButton.icon: the icon and the label are centred together, so they are drawn over the (blank) button #}
    {% for focus in [0, 1] %}
    <control type="grouplist">
        <visible>{% if focus %}Control.HasFocus(101){% else %}!Control.HasFocus(101){% endif %}</visible>
        <posx>996</posx>
        <posy>{{ vscale(582) }}</posy>
        <width>528</width>
        <height>{{ vscale(64) }}</height>
        <orientation>horizontal</orientation>
        <align>center</align>
        <itemgap>12</itemgap>
        <usecontrolcoords>true</usecontrolcoords>
        <control type="image">
            <posx>0</posx>
            <posy>{{ vscale(17) }}</posy>
            <width>30</width>
            <height>{{ vscale(30) }}</height>
            <texture colordiffuse="{% if focus %}{{ core.plezy.text }}{% else %}{{ core.plezy.muted }}{% endif %}">script.plex/plezy/icons/dns.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="label">
            <posx>0</posx>
            <posy>0</posy>
            <width max="440">auto</width>
            <height>{{ vscale(64) }}</height>
            <font>font12</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{% if focus %}{{ core.plezy.text }}{% else %}{{ core.plezy.muted }}{% endif %}</textcolor>
            <label>[B]$ADDON[script.plezy.native 35022][/B]</label>
        </control>
    </control>
    {% endfor %}
</control>
{% endblock controls %}
