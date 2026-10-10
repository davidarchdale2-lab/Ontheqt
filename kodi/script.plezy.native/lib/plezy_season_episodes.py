# coding=utf-8
"""
Plezy TV season detail helpers for lib/windows/episodes.py (EpisodesWindow), ported from edde746/plezy
lib/screens/media_detail_screen.dart (_buildTvDetailScreen for a season), lib/widgets/media_card.dart (the episode
card's subtitle) and lib/screens/media_detail/playback_tracks_status.dart:
 - card_subtitle: 'S1E3 · 45m' under an episode card (the title line already names the episode)
 - hero_meta: the selected episode's metadata line and whether the score badges still fit after it
 - season_hero: what the hero says while the cast / extras / related rows have focus (the season itself)
 - tracks_video: the picture part of the track status at the action row's right end
 - more_menu_pos / item_menu_pos: where the More menu and an episode card's context menu open

Kept free of Kodi imports so they can be tested outside Kodi; callers pass in anything localised.
"""
from __future__ import absolute_import

try:
    from . import plezy_ui
except (ImportError, ValueError):  # loaded by path from kodi/tests
    import plezy_ui

SEPARATOR = plezy_ui.SEPARATOR      # ' • ' (FittedMetadataLine)
CARD_SEPARATOR = u' \xb7 '          # ' · ' (media_card.dart episode subtitle)

# The hero text column is 1092px wide (Plezy's 60% column at 1080p); at Estuary's bold font13 that holds about
# 58 characters. FittedMetadataLine measures, we can only count.
HERO_META_BUDGET = 58

# Geometry mirrored from templates/script-plex-episodes.xml.tpl (1080p) and includes/plezy_action_button.xml.tpl:
# the action row starts at x 60 with a 72px Play stadium (or split segment plus a 42px version segment pulled 8px
# towards it), then 56px circles 10px apart: shuffle, watched, settings, more.
ROW_X = 60
ROW_Y = 590
ROW_H = 56
ROW_GAP = 10
PLAY_W = 72
VERSION_W = 42
VERSION_PULL = -8
BUTTON_W = 56
BUTTONS_BEFORE_MORE = 3  # shuffle, watched, settings

# Episode rail: the list sits at x 44, cards are inset 16px and 296px wide on a 320px pitch; the rail starts at
# y 652 with a 44px header and the artwork 14px into the card band.
RAIL_LIST_X = 44
CARD_INSET_X = 16
WIDE_W = 296
WIDE_PITCH = WIDE_W + 24
RAIL_Y = 652
CARD_Y = RAIL_Y + 44 + 14

VIDEO_CODECS = {
    'h264': u'H.264', 'avc1': u'H.264', 'avc': u'H.264',
    'hevc': u'HEVC', 'h265': u'HEVC', 'hev1': u'HEVC',
    'av1': u'AV1', 'vp8': u'VP8', 'vp9': u'VP9',
    'mpeg2video': u'MPEG-2', 'mpeg2': u'MPEG-2', 'mpeg4': u'MPEG-4', 'vc1': u'VC-1',
}


def _text(obj, attr):
    value = getattr(obj, attr, None)
    return u'{0}'.format(value).strip() if value not in (None, False) else u''


def _int(obj, attr):
    try:
        return int(float(_text(obj, attr) or 0))
    except ValueError:
        return 0


def episode_number(parent_index, index, season_fmt=u'S{}', episode_fmt=u'E{}'):
    """The card's episode number, Plezy style without a space: 'S1E3' ('' unless both numbers are known)."""
    season, episode = u'{0}'.format(parent_index or u'').strip(), u'{0}'.format(index or u'').strip()
    if not season or not episode:
        return u''
    return u'{0}{1}'.format(season_fmt.format(season), episode_fmt.format(episode))


def card_subtitle(episode, season_fmt=u'S{}', episode_fmt=u'E{}'):
    """
    The muted line under an episode card in the season's rail (media_card.dart, showTitleImplied): the number and
    the runtime, 'S1E3 · 45m'. Episodes without numbers (date-based shows) fall back to the air date.
    """
    number = episode_number(_text(episode, 'parentIndex'), _text(episode, 'index'), season_fmt, episode_fmt)
    if not number:
        number = plezy_ui.abbreviated_date(_text(episode, 'originallyAvailableAt'))
    return CARD_SEPARATOR.join(p for p in (number, plezy_ui.duration_text(_int(episode, 'duration'))) if p)


def hero_meta(episode, season_fmt=u'S{}', episode_fmt=u'E{}', budget=HERO_META_BUDGET):
    """
    The hero's metadata line for the selected episode without the scores ('S1 E3 • Mar 3, 2024 • TV-14 • 45m'),
    and whether the score badges (drawn by the template from the RatingsMixin images) still fit after it. Plezy
    sheds the ratings first, then the content rating, then the runtime; the label and the date always stay.
    """
    line = plezy_ui.detail_meta(episode, season_fmt, episode_fmt, hide_ratings=True, budget=budget)
    ratings = plezy_ui.ratings_text(episode)
    fits = bool(ratings) and len(line) + (len(SEPARATOR) if line else 0) + len(ratings) <= budget
    return line, fits


def count_label(count, one_fmt=u'{} episode', many_fmt=u'{} episodes'):
    """'1 episode' / '10 episodes' ('' for nothing to count)."""
    if count <= 0:
        return u''
    return (one_fmt if count == 1 else many_fmt).format(count)


def season_hero(season, show=None, one_fmt=u'{} episode', many_fmt=u'{} episodes'):
    """
    The hero while a non-episode row has focus: Plezy clears the focused episode and describes the item the screen
    is about, here the season: {'line': 'Season 2', 'meta': '2019 • 10 episodes', 'summary': ...}. Only the
    season's own year (parentYear is the show's premiere and would misdate later seasons); the summary falls back to
    the show's. Without a season (a show-wide episode list) it describes the show.
    """
    if season is None:
        parts = [_text(show, 'year'), (_text(show, 'contentRating').split(u'/', 1)[-1])]
        return {'line': u'', 'meta': SEPARATOR.join(p for p in parts if p), 'summary': _text(show, 'summary')}
    parts = [_text(season, 'year'), count_label(_int(season, 'leafCount'), one_fmt, many_fmt),
             _text(season, 'contentRating').split(u'/', 1)[-1]]
    return {
        'line': _text(season, 'title'),
        'meta': SEPARATOR.join(p for p in parts if p),
        'summary': _text(season, 'summary') or _text(show, 'summary'),
    }


def video_codec(codec):
    """Plezy CodecUtils.formatVideoCodec: 'hevc' -> 'HEVC', 'h264' -> 'H.264'."""
    codec = (codec or u'').strip()
    return VIDEO_CODECS.get(codec.lower(), codec.upper())


def tracks_video(resolution, codec, rendering):
    """
    Plezy buildMediaVideoLabels: '1080p • HEVC • HDR' - Dolby Vision by profile only, HDR / HLG as such, and plain
    SDR is not worth a label. `rendering` is plexnet's videoCodecRendering ('DV P8.1/HDR', 'HDR', 'SDR').
    """
    rendering = (rendering or u'').strip().split(u'/', 1)[0].strip()
    if rendering.upper() == u'SDR':
        rendering = u''
    elif rendering.upper().startswith(u'DV P'):
        rendering = u'DV P' + rendering[4:].split(u'.', 1)[0]
    return SEPARATOR.join(p for p in ((resolution or u'').strip(), video_codec(codec), rendering) if p)


def more_menu_pos(multiple=False):
    """Top-left of the More menu: under the row's last button (shifted up by the dropdown when it overflows)."""
    x = ROW_X + PLAY_W + ROW_GAP + BUTTONS_BEFORE_MORE * (BUTTON_W + ROW_GAP)
    if multiple:
        x += VERSION_PULL + VERSION_W + ROW_GAP
    return x, ROW_Y + ROW_H + 8


def item_menu_pos(view_position):
    """Top-left of an episode card's context menu: right of the card, level with its artwork (the episode row is
    always at the top of the rail when it has focus)."""
    view_position = max(0, int(view_position or 0))
    return RAIL_LIST_X + CARD_INSET_X + view_position * WIDE_PITCH + WIDE_W + 16, CARD_Y


# The action row is group 300 with one version and 1300 with several; the page keys and the watched key work on
# either (the hidden twin is never focused).
ACTION_ROW_GROUPS = (300, 1300)


def action_row_focused():
    """Kodi boolean condition: focus is inside whichever action row group is showing."""
    return u'[{}]'.format(u' | '.join(u'ControlGroup({}).HasFocus(0)'.format(g) for g in ACTION_ROW_GROUPS))


def backdrop_step(swapped, focused_id, related_id):
    """What the window backdrop should do when `focused_id` takes focus. The related-shows row previews the focused
    show's art, but Plezy keeps the season's own backdrop, so it goes back as soon as focus leaves that row.
    Returns 'related' (preview the focused show), 'restore' (back to the season / show) or None (leave it)."""
    if focused_id == related_id:
        return u'related'
    if swapped:
        return u'restore'
    return None
