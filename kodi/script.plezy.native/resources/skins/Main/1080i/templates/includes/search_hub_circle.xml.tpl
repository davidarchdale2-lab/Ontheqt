{# search result shelf, person and genre cards (actors, directors, genres): Plezy circle card, see
   search_person_card.xml.tpl. Uses hub_id from script-plex-search.xml.tpl; applies while hub.display.<hub_id> is "circle". #}
{% include "includes/search_person_card.xml.tpl" with focused=False %}
{% include "includes/search_person_card.xml.tpl" with focused=True %}
