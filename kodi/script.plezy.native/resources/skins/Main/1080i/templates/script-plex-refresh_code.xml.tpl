{% extends "base.xml.tpl" %}
{# The PIN expired before the account was linked (lib/windows/signin.py ExpiredWindow). Plezy's AuthScreen answers a timed-out or
   expired sign-in with its initial buttons and the error in the error colour under them: the same primary "Sign in with Plex"
   stadium here (control 100 starts a new code), with the message below. Back leaves the sign-in. #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block backgroundcolor %}<backgroundcolor>0x{{ core.plezy.bg }}</backgroundcolor>{% endblock %}
{% block controls %}
{% include "includes/plezy_auth_brand.xml.tpl" %}

<control type="group">
    <posx>0</posx>
    <posy>{{ vperc(vscale(1080)) }}</posy>
    {% include "includes/plezy_signin_button.xml.tpl" with bid = 100 & x = 996 & y = 460 & w = 528 & variant = "primary" & label = "$ADDON[script.plezy.native 35220]" %}
    <control type="textbox">
        <posx>996</posx>
        <posy>{{ vscale(548) }}</posy>
        <width>528</width>
        <height>{{ vscale(72) }}</height>
        <font>font12</font>
        <align>center</align>
        <textcolor>{{ core.plezy.error }}</textcolor>
        <label>$ADDON[script.plezy.native 35224]</label>
    </control>
</control>
{% endblock controls %}
