{% extends "script-plex-pre_play.xml.tpl" %}
{# Watchlist pre-play: the track-status slot at the action row's right end carries the server availability instead #}
{% block streams %}
    {% include "includes/wl_availability.xml.tpl" with plezy=True %}
{% endblock %}
