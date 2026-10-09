{% extends "base.xml.tpl" %}
{# Plezy buffering indicator with a status line (edde746/plezy lib/screens/video_player/widgets/player_prompt_overlays.dart):
   a spinner on a black 50% disc over the video, and below it Plezy's status pill (black 54%, radius 20) holding the
   message ("Buffer: 35 %", "Buffering"). Window.Property(message) comes from BusyClosableMsgWindow.setMessage. #}
{% block backgroundcolor %}{% endblock %}
{% block controls %}
<control type="group">
    <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">WindowOpen</animation>
    <animation effect="fade" start="100" end="0" time="120" tween="cubic" easing="in">WindowClose</animation>
    <posx>0</posx>
    <posy>{{ vperc(vscale(180)) }}</posy>
    <control type="image">
        <posx>903</posx>
        <posy>0</posy>
        <width>114</width>
        <height>{{ vscale(114) }}</height>
        <texture colordiffuse="{{ core.plezy.sheet_scrim }}">script.plex/plezy/circle.png</texture>
    </control>
    {% include "includes/plezy_spinner.xml.tpl" with x = 933 & y = 30 & size = 54 %}
    <control type="image">
        <visible>!String.IsEmpty(Window.Property(message))</visible>
        <posx>780</posx>
        <posy>{{ vscale(132) }}</posy>
        <width>360</width>
        <height>{{ vscale(48) }}</height>
        <texture border="24" colordiffuse="{{ core.plezy.dialog_scrim }}">script.plex/plezy/pill-48.png</texture>
    </control>
    <control type="label">
        <visible>!String.IsEmpty(Window.Property(message))</visible>
        <posx>780</posx>
        <posy>{{ vscale(132) }}</posy>
        <width>360</width>
        <height>{{ vscale(48) }}</height>
        <font>font10</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$INFO[Window.Property(message)]</label>
    </control>
</control>
{% endblock controls %}
