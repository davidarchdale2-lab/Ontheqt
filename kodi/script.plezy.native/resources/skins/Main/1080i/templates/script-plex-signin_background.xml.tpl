{% extends "base.xml.tpl" %}
{# Sits behind the sign-in windows (lib/plex.py authorize) and only shows in the gaps between them; each of those windows is a full
   window that draws the same brand panel. The window has no controls (the header names control 100 as before, which does not exist). #}
{% block headers %}<defaultcontrol>100</defaultcontrol>{% endblock %}
{% block backgroundcolor %}<backgroundcolor>0x{{ core.plezy.bg }}</backgroundcolor>{% endblock %}
{% block controls %}
{% include "includes/plezy_auth_brand.xml.tpl" %}
{% endblock %}
