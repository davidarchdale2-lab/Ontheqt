{% extends "base.xml.tpl" %}
{# A message on the sign-in panel (lib/windows/signin.py SignInMessage; Window.Property(message)). Plezy shows such text in the dialog's
   body style, so it is regular weight font12. Control 100 is an OK stadium now (it used to be an invisible full-screen button). #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block backgroundcolor %}<backgroundcolor>0x{{ core.plezy.bg }}</backgroundcolor>{% endblock %}
{% block controls %}
{% include "includes/plezy_auth_brand.xml.tpl" %}

<control type="group">
    <posx>0</posx>
    <posy>{{ vperc(vscale(1080)) }}</posy>
    <control type="textbox">
        <posx>996</posx>
        <posy>{{ vscale(380) }}</posy>
        <width>528</width>
        <height>{{ vscale(212) }}</height>
        <font>font12</font>
        <align>left</align>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$INFO[Window.Property(message)]</label>
    </control>
    {% include "includes/plezy_signin_button.xml.tpl" with bid = 100 & x = 996 & y = 616 & w = 240 & variant = "primary" & label = "$ADDON[script.plezy.native 32997]" %}
</control>
{% endblock %}
