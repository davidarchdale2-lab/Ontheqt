{% extends "base.xml.tpl" %}
{# Plezy's cold-start SetupScreen (edde746/plezy lib/main.dart): the bg colour, the app mark in the middle (172px) and a 20lp spinner
   (30px) below it, with an optional status line between them. The splash (startup), the busy state (loading after sign-in / user
   switch) and the shutdown state are separate global properties set from lib/windows/background.py; busy looks exactly like the splash
   so loading is one continuous screen. Shutdown is the bare spinner Plezy shows for a loading dialog.
   The busy dialog (script-plex-busy.xml, a bare 60px spinner centred on the screen) takes over from the mark and the small spinner
   while it is open, so two spinners never stack. The mark is the stand-in from includes/plezy_auth_brand.xml.tpl (Plezy's logo is
   not used). #}
{% block headers %}{% endblock %}
{% block backgroundcolor %}<backgroundcolor>0x{{ core.plezy.bg }}</backgroundcolor>{% endblock %}

{% block controls %}
{% with brand = core.plezy.brand|default(core.plezy.active) & accent = core.plezy.accent|default(core.plezy.active) %}
<control type="image">
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.bg }}">script.plex/white-square.png</texture>
</control>

{# splash and busy: the mark, an optional status line and the small amber spinner #}
<control type="group">
    <visible>[!String.IsEmpty(Window(10000).Property(script.plezy.native.background.splash)) | !String.IsEmpty(Window(10000).Property(script.plezy.native.background.busy))] + !Window.IsVisible(script-plex-busy.xml)</visible>
    <control type="image">
        <posx>874</posx>
        <posy>{{ vperc(vscale(172)) }}</posy>
        <width>172</width>
        <height>{{ vscale(172) }}</height>
        <texture border="32" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r32.png</texture>
    </control>
    <control type="image">
        <posx>906</posx>
        <posy>{{ vperc(vscale(108)) }}</posy>
        <width>108</width>
        <height>{{ vscale(108) }}</height>
        <texture colordiffuse="{{ brand }}">script.plex/plezy/icons/play_arrow.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <visible>!String.IsEmpty(Window(10000).Property(script.plezy.native.background.message))</visible>
        <posx>0</posx>
        <posy>{{ vperc(0) + vscale(215) }}</posy>
        <width>1920</width>
        <height>{{ vscale(40) }}</height>
        <font>font12</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$INFO[Window(10000).Property(script.plezy.native.background.message)]</label>
    </control>
    <control type="group">
        <posx>0</posx>
        <posy>{{ vperc(0) }}</posy>
        {% include "includes/plezy_spinner.xml.tpl" with x = 945 & y = 270 & size = 30 & color = accent %}
    </control>
</control>

{# shutdown: a bare spinner, like Plezy's loading dialog #}
<control type="group">
    <visible>!String.IsEmpty(Window(10000).Property(script.plezy.native.background.shutdown)) + !Window.IsVisible(script-plex-busy.xml)</visible>
    <posx>0</posx>
    <posy>{{ vperc(vscale(60)) }}</posy>
    {% include "includes/plezy_spinner.xml.tpl" with x = 930 & y = 0 & size = 60 & color = core.plezy.text %}
</control>
{% endwith %}
{% endblock controls %}
