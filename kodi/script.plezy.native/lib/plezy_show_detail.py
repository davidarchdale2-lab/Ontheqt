# coding=utf-8
"""
Plezy TV show detail helpers (edde746/plezy lib/screens/media_detail_screen.dart, TV layout) for ShowWindow:
 - season_hero: what the hero says while a season card is focused (Plezy's hero follows the focused rail item)
 - count_label / season_subtitle: '10 episodes' under a season card, '6 seasons'
 - play_state: the Play pill's label and resume icon from the show's on-deck episode (_getPlayButtonLabel/_Icon)
 - first_trailer: the trailer button's clip (_getPrimaryTrailer) from the extras the show was loaded with
 - season_menu_pos: where the season context menu opens next to the focused card

Kept free of Kodi imports so they can be tested outside Kodi; callers pass in anything localised.
"""
from __future__ import absolute_import

SEPARATOR = u' • '
TRAILER_TYPE = 1  # plexnet.media.METADATA_RELATED_TRAILER

# rail geometry of templates/script-plex-seasons.xml.tpl (1080p): list x, artwork inset, card pitch, row top
RAIL_LIST_X = 44
CARD_INSET_X = 16
POSTER_W = 174
CARD_PITCH = POSTER_W + 24
SEASON_MENU_Y = 700

# hero summary: font12 (~25px NotoSans) in the 1072px textbox fits about 82 characters; a lower figure errs towards
# more lines, which only makes the info block's focus fill a line taller, never short of the text
SUMMARY_CHARS_PER_LINE = 78
SUMMARY_MAX_LINES = 3


def _text(obj, attr):
    value = getattr(obj, attr, None)
    return u'{0}'.format(value).strip() if value not in (None, False) else u''


def _int(obj, attr):
    try:
        return int(float(_text(obj, attr) or 0))
    except ValueError:
        return 0


def count_label(count, one_fmt=u'{} episode', many_fmt=u'{} episodes'):
    """'1 episode' / '10 episodes' ('' for nothing to count)."""
    if count <= 0:
        return u''
    return (one_fmt if count == 1 else many_fmt).format(count)


def season_subtitle(season, one_fmt=u'{} episode', many_fmt=u'{} episodes'):
    """The muted line under a season card: its episode count (leafCount)."""
    return count_label(_int(season, 'leafCount'), one_fmt, many_fmt)


def season_hero(season, show_summary=u'', one_fmt=u'{} episode', many_fmt=u'{} episodes'):
    """
    The hero while a season card is focused, Plezy-style (the extra title line above the metadata, the summary
    falling back to the show's): {'line': 'Season 2', 'meta': '2019 • 10 episodes', 'summary': ...}.
    Only the season's own year: parentYear is the show's premiere and would misdate later seasons.
    """
    parts = [_text(season, 'year'), season_subtitle(season, one_fmt, many_fmt)]
    return {
        'line': _text(season, 'title'),
        'meta': SEPARATOR.join(p for p in parts if p),
        'summary': _text(season, 'summary') or (show_summary or u''),
    }


def summary_lines(text, chars_per_line=SUMMARY_CHARS_PER_LINE, max_lines=SUMMARY_MAX_LINES):
    """
    Rendered line count (0-max_lines) of the hero summary, estimated by greedy word wrap: Kodi's textbox is auto
    height, and the template picks the info block's focus fill by this ('' in the property for no summary).
    """
    lines = 0
    for paragraph in (text or u'').strip().splitlines():
        words = paragraph.split()
        lines += 1  # a blank line in the middle takes a line too
        if not words:
            if lines >= max_lines:
                return max_lines
            continue
        width = 0
        for word in words:
            need = len(word) + (1 if width else 0)
            if width and width + need > chars_per_line:
                lines += 1
                width = 0
                need = len(word)
            while need > chars_per_line:  # one very long word breaks mid-word
                lines += 1
                need -= chars_per_line
            width += need
        if lines >= max_lines:
            return max_lines
    return min(lines, max_lines)


def first_on_deck(on_deck):
    """The show's next episode (show.onDeck, loaded with includeOnDeck=1), or None."""
    try:
        for episode in on_deck or ():
            return episode
    except TypeError:
        pass
    return None


def default_play_season(seasons):
    """Plezy defaultPlaybackSeason: the first real season (index > 0), else the first one (specials only), else None."""
    first = None
    try:
        for season in seasons or ():
            if first is None:
                first = season
            if _int(season, 'index') > 0:
                return season
    except TypeError:
        pass
    return first


def play_state(on_deck, label_fn, fallback=u'Play', seasons=None):
    """
    (label, resume) for the show's Play pill: the on-deck episode as 'S1 E3' (label_fn(parentIndex, index)) with
    the resume icon when it has progress. With no on-deck episode (never started, or marked unwatched) Plezy
    offers the first episode of the default season ('S1E1'); the plain fallback label when there are no seasons.
    """
    episode = first_on_deck(on_deck)
    if episode is None:
        season = default_play_season(seasons)
        if season is not None:
            return label_fn(_text(season, 'index'), u'1') or fallback, False
        return fallback, False
    label = label_fn(_text(episode, 'parentIndex'), _text(episode, 'index')) or fallback
    return label, _int(episode, 'viewOffset') > 0


def first_trailer(extras, trailer_type=TRAILER_TYPE):
    """The first trailer among the show's extras, or None."""
    try:
        for extra in extras or ():
            if _int(extra, 'extraType') == trailer_type:
                return extra
    except TypeError:
        pass
    return None


def scale_pos(pos, scale_y):
    """A 1080p (x, y) as the dropdown wants it: y is an absolute screen coordinate, so it follows vscale
    (scale_y is util.vscalei) when the display is not 16:9."""
    return pos[0], int(scale_y(pos[1]))


def season_menu_pos(view_position):
    """Top-left of the season context menu: just right of the focused season card (the dialog shifts it into
    the screen when it would overflow)."""
    view_position = max(0, int(view_position or 0))
    return RAIL_LIST_X + CARD_INSET_X + view_position * CARD_PITCH + POSTER_W + 16, SEASON_MENU_Y
