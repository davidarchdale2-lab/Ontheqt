{% extends "base.xml.tpl" %}{# this template is unused at the moment (plex.py requirePlexPass() always passes); it keeps the sign-in look #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block backgroundcolor %}<backgroundcolor>0x{{ core.plezy.bg }}</backgroundcolor>{% endblock %}
{% block controls %}
{% include "includes/plezy_auth_brand.xml.tpl" %}

<control type="group">
    <posx>0</posx>
    <posy>{{ vperc(vscale(1080)) }}</posy>
    {% include "includes/plezy_signin_button.xml.tpl" with bid = 100 & x = 996 & y = 508 & w = 528 & variant = "primary" & label = "$ADDON[script.plezy.native 35032]" %}
</control>
{% endblock controls %}
