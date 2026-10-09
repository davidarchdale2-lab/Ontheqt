{% extends "base.xml.tpl" %}
{# Plezy AlertDialog: confirmations and messages; see includes/plezy_options_dialog.xml.tpl #}
{% block headers %}<defaultcontrol>1001</defaultcontrol>{% endblock %}
{% block backgroundcolor %}{% endblock %}
{% block controls %}
{% include "includes/plezy_options_dialog.xml.tpl" with ch = 404 & bh = 160 %}
{% endblock controls %}
