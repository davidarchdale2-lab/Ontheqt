{# search result shelf, wide cards (episodes, clips): Plezy card 400x225, see plezy_hub_card.xml.tpl.
   Uses hub_id from script-plex-search.xml.tpl; applies while hub.display.<hub_id> is "ar16x9". #}
{% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=False & cw=400 & ch=225 & mask="script.plex/plezy/mask-wide.png" %}
{% include "includes/plezy_hub_card.xml.tpl" with kind="ar16x9" & focused=True & cw=400 & ch=225 & mask="script.plex/plezy/mask-wide.png" %}
