{# Plezy AlertDialog (edde746/plezy lib/utils/dialogs.dart showConfirmDialog, DialogActionButton) at x1.5: a dialog_scrim
   over the whole screen, a 840px radius-28 surface card centred on screen with a bold title, the body text and
   right-aligned stadium actions. The Python (lib/windows/optionsdialog.py) keeps its contract: window properties
   header / info / button.0-2 / delay_buttons / enable_buttons / initialized, group 100 and buttons 1001-1003.
   params: ch (card height: 404 normal, 704 big), bh (body text height: 160 / 460) #}
{% with by = 108 + bh + 36 %}
<control type="image">
    <animation effect="fade" start="0" end="100" time="150" tween="cubic" easing="out">WindowOpen</animation>
    <animation effect="fade" start="100" end="0" time="120" tween="cubic" easing="in">WindowClose</animation>
    <posx>0</posx>
    <posy>0</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.dialog_scrim }}">script.plex/white-square.png</texture>
</control>
<control type="group">
    <visible>!String.IsEmpty(Window.Property(initialized))</visible>
    <animation effect="fade" start="0" end="100" time="150" tween="cubic" easing="out">Visible</animation>
    <animation effect="zoom" start="96" end="100" time="150" tween="cubic" easing="out" center="auto">Visible</animation>
    <animation effect="fade" start="100" end="0" time="120" tween="cubic" easing="in">WindowClose</animation>
    <posx>540</posx>
    <posy>{{ vperc(vscale(ch)) }}</posy>
    <width>840</width>
    <height>{{ ch|vscale }}</height>
    <control type="image">
        <posx>0</posx>
        <posy>0</posy>
        <width>840</width>
        <height>{{ ch|vscale }}</height>
        <texture border="28" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r28.png</texture>
    </control>
    <control type="label">
        <posx>36</posx>
        <posy>{{ vscale(36) }}</posy>
        <width>768</width>
        <height>{{ vscale(48) }}</height>
        <font>font20_title</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$INFO[Window.Property(header)]</label>
    </control>
    <control type="textbox">
        <posx>36</posx>
        <posy>{{ vscale(108) }}</posy>
        <width>768</width>
        <height>{{ bh|vscale }}</height>
        <font>font12</font>
        <align>left</align>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <scrolltime>200</scrolltime>
        <autoscroll delay="3000" time="3000" repeat="3000"></autoscroll>
        <label>$INFO[Window.Property(info)]</label>
    </control>
    <control type="grouplist" id="100">
        <defaultcontrol always="true">1001</defaultcontrol>
        <posx>36</posx>
        <posy>{{ by|vscale }}</posy>
        <width>768</width>
        <height>{{ vscale(64) }}</height>
        <align>right</align>
        <itemgap>12</itemgap>
        <orientation>horizontal</orientation>
        <scrolltime>0</scrolltime>
        <onup>noop</onup>
        <ondown>noop</ondown>
        {% include "includes/plezy_dialog_button.xml.tpl" with id = 1001 & prop = "button.0" & visible = "!String.IsEmpty(Window.Property(button.0))" & allowhiddenfocus = True & enable = "String.IsEmpty(Window.Property(delay_buttons)) | !String.IsEmpty(Window.Property(enable_buttons))" %}
        {% include "includes/plezy_dialog_button.xml.tpl" with id = 1002 & prop = "button.1" & visible = "!String.IsEmpty(Window.Property(button.1))" & enable = "String.IsEmpty(Window.Property(delay_buttons)) | !String.IsEmpty(Window.Property(enable_buttons))" %}
        {% include "includes/plezy_dialog_button.xml.tpl" with id = 1003 & prop = "button.2" & visible = "!String.IsEmpty(Window.Property(button.2))" & enable = "String.IsEmpty(Window.Property(delay_buttons)) | !String.IsEmpty(Window.Property(enable_buttons))" %}
    </control>
</control>
{% endwith %}
