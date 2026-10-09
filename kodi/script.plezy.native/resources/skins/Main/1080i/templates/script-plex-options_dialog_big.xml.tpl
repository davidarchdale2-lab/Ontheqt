{% extends "base.xml.tpl" %}
{# Plezy AlertDialog with a tall body (changelogs, long messages); see includes/plezy_options_dialog.xml.tpl #}
{% block headers %}<defaultcontrol>1001</defaultcontrol>{% endblock %}
{% block backgroundcolor %}{% endblock %}
{% block controls %}
{% include "includes/plezy_options_dialog.xml.tpl" with ch = 704 & bh = 460 %}
{% endblock controls %}
