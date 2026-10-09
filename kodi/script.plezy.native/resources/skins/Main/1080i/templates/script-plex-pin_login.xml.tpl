{% extends "base.xml.tpl" %}
{# Plezy's Plex PIN sign-in (edde746/plezy lib/screens/auth/plex_pin_auth_flow.dart + widgets/device_code_dialog.dart): the brand
   column on the left; on the right either the link code (a QR for plex.tv/link, the code large beside it, a waiting row) or, while the
   code is being fetched / the account is being linked, a spinner. Cancel is a text stadium in both states.
   State flag: Window.Property(pin.image.0) is set while the code is shown (lib/windows/signin.py setPin / setLinking);
   pin.char.0..3 hold the code's upper-case characters, linking is set once the token has arrived. Grouplist 400 is the code
   (the id is kept for the layout checks); the only focusable control is Cancel (102). #}
{% block headers %}<defaultcontrol>102</defaultcontrol>{% endblock %}
{% block backgroundcolor %}<backgroundcolor>0x{{ core.plezy.bg }}</backgroundcolor>{% endblock %}
{% block controls %}
{% include "includes/plezy_auth_brand.xml.tpl" %}

<control type="group">
    <posx>0</posx>
    <posy>{{ vperc(vscale(1080)) }}</posy>

    {# state A: the code is shown #}
    <control type="group">
        <visible>!String.IsEmpty(Window.Property(pin.image.0))</visible>
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
        <control type="textbox">
            <posx>996</posx>
            <posy>{{ vscale(288) }}</posy>
            <width>528</width>
            <height>{{ vscale(96) }}</height>
            <font>font12</font>
            <align>left</align>
            <textcolor>{{ core.plezy.summary }}</textcolor>
            <label>$ADDON[script.plezy.native 35222]</label>
        </control>
        {# the QR is Plezy's white rounded tile with black modules; it is drawn untinted #}
        <control type="image">
            <posx>996</posx>
            <posy>{{ vscale(392) }}</posy>
            <width>240</width>
            <height>{{ vscale(240) }}</height>
            <texture>script.plex/plezy/qr-plex-link.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
        <control type="grouplist" id="400">
            <posx>1272</posx>
            <posy>{{ vscale(422) }}</posy>
            <width>248</width>
            <height>{{ vscale(84) }}</height>
            <orientation>horizontal</orientation>
            <align>left</align>
            <itemgap>8</itemgap>
            <usecontrolcoords>true</usecontrolcoords>
            {% for n in range(4) %}
            <control type="label">
                <posx>0</posx>
                <posy>0</posy>
                <width>56</width>
                <height>{{ vscale(84) }}</height>
                <font>font45</font>
                <align>center</align>
                <aligny>center</aligny>
                <scroll>false</scroll>
                <textcolor>{{ core.plezy.text }}</textcolor>
                <label>[B]$INFO[Window.Property(pin.char.{{ n }})][/B]</label>
            </control>
            {% endfor %}
        </control>
        <control type="label">
            <posx>1272</posx>
            <posy>{{ vscale(518) }}</posy>
            <width>252</width>
            <height>{{ vscale(40) }}</height>
            <font>font14</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.text }}</textcolor>
            <label>[B]plex.tv/link[/B]</label>
        </control>
        {# waiting row: a 16lp spinner (28px) and the status in labelSmall #}
        {% include "includes/plezy_spinner.xml.tpl" with x = 996 & y = 662 & size = 28 & color = core.plezy.text %}
        <control type="label">
            <posx>1040</posx>
            <posy>{{ vscale(656) }}</posy>
            <width>484</width>
            <height>{{ vscale(40) }}</height>
            <font>font10</font>
            <align>left</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$ADDON[script.plezy.native 35223]</label>
        </control>
    </control>

    {# state B: asking plex.tv for a code, or linking the account once it was entered #}
    <control type="group">
        <visible>String.IsEmpty(Window.Property(pin.image.0))</visible>
        <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">Visible</animation>
        {% include "includes/plezy_spinner.xml.tpl" with x = 1230 & y = 510 & size = 60 & color = core.plezy.text %}
        <control type="label">
            <visible>String.IsEmpty(Window.Property(linking))</visible>
            <posx>996</posx>
            <posy>{{ vscale(590) }}</posy>
            <width>528</width>
            <height>{{ vscale(40) }}</height>
            <font>font12</font>
            <align>center</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$ADDON[script.plezy.native 32914]</label>
        </control>
        <control type="label">
            <visible>!String.IsEmpty(Window.Property(linking))</visible>
            <posx>996</posx>
            <posy>{{ vscale(590) }}</posy>
            <width>528</width>
            <height>{{ vscale(40) }}</height>
            <font>font12</font>
            <align>center</align>
            <aligny>center</aligny>
            <scroll>false</scroll>
            <textcolor>{{ core.plezy.muted }}</textcolor>
            <label>$ADDON[script.plezy.native 35223]</label>
        </control>
    </control>

    {% include "includes/plezy_signin_button.xml.tpl" with bid = 102 & x = 996 & y = 720 & w = 240 & variant = "text" & label = "$ADDON[script.plezy.native 32337]" %}
</control>
{% endblock controls %}
