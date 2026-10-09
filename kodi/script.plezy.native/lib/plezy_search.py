# coding=utf-8
"""
Plezy search helpers for lib/windows/search.py (SearchDialog), ported from edde746/plezy
lib/screens/search_screen.dart, lib/widgets/media_card.dart (the card's title and subtitle) and
lib/utils/hub_icons.dart:
 - SECTION_BUTTONS / KIND_TYPES: the filter chips (All, Movies, Shows, Music, Photos, People) and the Plex hub types each shows
 - present_kinds / resolve_section / allowed_types: which chips a result set offers, Plezy's fall-back to All
 - hub_icon: the icon in front of a result shelf's title
 - card_texts / thumb_kind: title and subtitle of a result card, which image it loads

Kept free of Kodi imports so they can be tested outside Kodi; callers pass in anything localised.
"""
from __future__ import absolute_import

try:
    from . import plezy_ui
except (ImportError, ValueError):  # loaded by path from kodi/tests
    import plezy_ui

ICON_PATH = plezy_ui.ICON_PATH
PERSON_ICON = ICON_PATH.format('person')
GENRE_ICON = ICON_PATH.format('hub_genre')
HISTORY_ICON = ICON_PATH.format('history')
CLEAR_ICON = ICON_PATH.format('clear_all')
CARD_SEPARATOR = u' \xb7 '  # ' · ' (media_card.dart episode subtitle)

# The chip row, in Plezy's order (All first, People last). Control ids of the togglebuttons in
# templates/script-plex-search.xml.tpl.
SECTION_BUTTONS = {
    901: 'all',
    902: 'movie',
    903: 'show',
    904: 'artist',
    905: 'photo',
    906: 'people',
}
KINDS = ('movie', 'show', 'artist', 'photo', 'people')

# Plex hub types behind each chip. Collections, playlists, genres and clips have no chip of their own (Plezy has
# Collections and Playlists chips; this window keeps a fixed set) and only show under All.
KIND_TYPES = {
    'movie': ('movie',),
    'show': ('show', 'season', 'episode'),
    'artist': ('artist', 'album', 'track'),
    'photo': ('photo', 'photoalbum', 'photodirectory'),
    'people': ('actor', 'director'),
}

# Hub type -> card shape (the value of the hub.display.<id> window property; the card layouts live in
# templates/includes/search_hub_*.xml.tpl)
HUB_DISPLAY = {
    'movie': 'poster',
    'show': 'poster',
    'season': 'poster',
    'collection': 'poster',
    'episode': 'ar16x9',
    'clip': 'ar16x9',
    'artist': 'square',
    'album': 'square',
    'track': 'square',
    'photo': 'square',
    'photoalbum': 'square',
    'photodirectory': 'square',
    'playlist': 'square',
    'actor': 'circle',
    'director': 'circle',
    'genre': 'circle',
}

HUB_ICONS = {
    'movie': 'movie',
    'clip': 'movie',
    'show': 'show',
    'season': 'show',
    'episode': 'show',
    'artist': 'artist',
    'album': 'artist',
    'track': 'artist',
    'photo': 'photo',
    'photoalbum': 'photo',
    'photodirectory': 'photo',
    'actor': 'person',
    'director': 'person',
    'genre': 'hub_genre',
    'playlist': 'playlists',
    'collection': 'hub_collection',
}


def hub_icon(hub_type):
    """Texture path of the icon in front of a result shelf's title."""
    return ICON_PATH.format(HUB_ICONS.get(hub_type or '', 'hub_default'))


def allowed_types(section):
    """Hub types a chip shows; None (no filter) for All and for anything unknown."""
    return KIND_TYPES.get(section)


def present_kinds(hubs):
    """
    Chips a result set can filter by, in chip order. hubs: (hub_type, size) pairs, already limited to the types the
    window can draw. Plezy only shows a kind that has results.
    """
    sizes = {}
    for hub_type, size in hubs:
        if size and size > 0:
            sizes[hub_type] = True
    return [kind for kind in KINDS if any(t in sizes for t in KIND_TYPES[kind])]


def show_chips(present):
    """Plezy _showFilterChips: a chip strip only helps when there is more than one thing to filter by."""
    return len(present) >= 2


def resolve_section(section, present):
    """A later query without the selected kind falls back to All (Plezy)."""
    if section in (None, '', 'all') or section in present:
        return section or 'all'
    return 'all'


def hub_ids_to_show(hubs, section, handled=None, limit=None):
    """
    Indices into hubs (hub_type, size pairs) that become result rows, in order: the sections' types only, empty and
    unhandled hubs dropped, at most limit. Rows are numbered by their position in this list, so the rows the window
    draws are contiguous (the template's up/down navigation has no gaps to skip).
    """
    allowed = allowed_types(section)
    out = []
    for i, (hub_type, size) in enumerate(hubs):
        if limit is not None and len(out) >= limit:
            break
        if allowed and hub_type not in allowed:
            continue
        if not size or size <= 0:
            continue
        if handled is not None and hub_type not in handled:
            continue
        out.append(i)
    return out


def thumb_kind(item_type):
    """
    Which image of a result to load: 'thumb' (its own poster or still), 'default' (the item's default thumb, which
    tracks and albums need because they often carry only their album's cover), 'composite' (playlists and photo
    folders), or '' (genres have no image; the template draws a glyph).
    """
    if item_type in ('playlist', 'photodirectory'):
        return 'composite'
    if item_type == 'Genre':
        return ''
    if item_type in ('track', 'album'):
        return 'default'
    return 'thumb'


def _text(obj, attr):
    value = getattr(obj, attr, None)
    return u'{0}'.format(value).strip() if value not in (None, False) else u''


def episode_number(parent_index, index, season_fmt=u'S{}', episode_fmt=u'E{}'):
    """'S1E2' (media_card.dart's episode subtitle), '' when either number is missing."""
    season, episode = u'{0}'.format(parent_index or u'').strip(), u'{0}'.format(index or u'').strip()
    if not season or not episode:
        return u''
    return season_fmt.format(season) + episode_fmt.format(episode)


def card_texts(item, season_fmt=u'S{}', episode_fmt=u'E{}', role_labels=None):
    """
    (title, subtitle) under a result card, following Plezy's MediaItem.displayTitle / displaySubtitle:
      movie, show     title / year
      season          show title / season title
      episode         show title / 'S1E2 · episode title'
      album           title / artist
      track           title / artist
      photo           title / date
      Role, Director  name / 'Actor' or 'Director' (role_labels: {'Role': .., 'Director': ..})
    Everything else is its title and nothing else.
    """
    kind = _text(item, 'TYPE')
    title = _text(item, 'title')
    if kind in ('Role', 'Director', 'Genre'):
        name = _text(item, 'tag') or title
        if kind == 'Genre':
            return name, _text(item, 'reasonTitle')
        return name, (role_labels or {}).get(kind) or _text(item, 'reasonTitle')
    if kind == 'playlist':
        return _text(item, 'tag') or title, u''
    if kind in ('movie', 'show'):
        return title, _text(item, 'year')
    if kind == 'season':
        return _text(item, 'parentTitle') or title, title
    if kind == 'episode':
        show = _text(item, 'grandparentTitle')
        number = episode_number(_text(item, 'parentIndex'), _text(item, 'index'), season_fmt, episode_fmt)
        if not show:
            return title, number
        return show, CARD_SEPARATOR.join(p for p in (number, title) if p)
    if kind == 'album':
        return title, _text(item, 'parentTitle')
    if kind == 'track':
        return title, _text(item, 'grandparentTitle') or _text(item, 'originalTitle')
    if kind == 'photo':
        return title, plezy_ui.abbreviated_date(_text(item, 'originallyAvailableAt'))
    return title, u''
