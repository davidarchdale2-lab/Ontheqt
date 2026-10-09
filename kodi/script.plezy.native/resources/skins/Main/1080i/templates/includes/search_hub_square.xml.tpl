{# search result shelf, square cards (artists, albums, tracks, photos, playlists): Plezy card 200x200, see
   plezy_hub_card.xml.tpl. Uses hub_id from script-plex-search.xml.tpl; applies while hub.display.<hub_id> is "square". #}
{% include "includes/plezy_hub_card.xml.tpl" with kind="square" & focused=False & cw=200 & ch=200 & mask="script.plex/plezy/mask-square.png" %}
{% include "includes/plezy_hub_card.xml.tpl" with kind="square" & focused=True & cw=200 & ch=200 & mask="script.plex/plezy/mask-square.png" %}
