{# search result shelf, poster cards (movies, shows, seasons, collections): Plezy card 200x300, see plezy_hub_card.xml.tpl.
   Uses hub_id from script-plex-search.xml.tpl; the layout applies while hub.display.<hub_id> is "poster". #}
{% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=False & cw=200 & ch=300 & mask="script.plex/plezy/mask-poster.png" %}
{% include "includes/plezy_hub_card.xml.tpl" with kind="poster" & focused=True & cw=200 & ch=300 & mask="script.plex/plezy/mask-poster.png" %}
