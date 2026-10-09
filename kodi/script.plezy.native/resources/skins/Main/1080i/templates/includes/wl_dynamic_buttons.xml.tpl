{# watchlist dynamic play button #}
{% if plezy %}{# Plezy action row (includes/plezy_action_button.xml.tpl): the play slot as an icon-only stadium #}
    {# checking #}
    {% include "includes/plezy_action_button.xml.tpl" with id=2302 & icon="hourglass_empty" & shape="pill" & visible="!String.IsEmpty(Window.Property(disable_playback)) + !String.IsEmpty(Window.Property(wl_availability_checking))" %}
    {# available multiple #}
    {% include "includes/plezy_action_button.xml.tpl" with id=2303 & icon="playlist_play" & shape="pill" & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + !String.IsEmpty(Window.Property(wl_availability_multiple))" %}
    {# available single #}
    {% include "includes/plezy_action_button.xml.tpl" with id=2304 & icon="play_arrow" & shape="pill" & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + String.IsEmpty(Window.Property(wl_availability_multiple)) + !String.IsEmpty(Window.Property(wl_availability))" %}
    {# not available #}
    {% include "includes/plezy_action_button.xml.tpl" with id=2305 & icon="event_upcoming" & shape="pill" & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + String.IsEmpty(Window.Property(wl_availability_multiple)) + String.IsEmpty(Window.Property(wl_availability))" %}
{% else %}
    {# checking #}
    {% include template with name="wait" & id=2302 & visible="!String.IsEmpty(Window.Property(disable_playback)) + !String.IsEmpty(Window.Property(wl_availability_checking))" %}
    {# available multiple #}
    {% include template with name="play_plus" & id=2303 & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + !String.IsEmpty(Window.Property(wl_availability_multiple))" %}
    {# available single #}
    {% include template with name="play" & id=2304 & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + String.IsEmpty(Window.Property(wl_availability_multiple)) + !String.IsEmpty(Window.Property(wl_availability))" %}
    {# not available #}
    {% include template with name="upcoming" & id=2305 & visible="!String.IsEmpty(Window.Property(disable_playback)) + String.IsEmpty(Window.Property(wl_availability_checking)) + String.IsEmpty(Window.Property(wl_availability_multiple)) + String.IsEmpty(Window.Property(wl_availability))" %}
{% endif %}
{# /watchlist dynamic play button #}