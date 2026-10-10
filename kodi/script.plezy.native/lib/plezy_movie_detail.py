# coding=utf-8
"""
Plezy TV movie / episode detail helpers for lib/windows/preplay.py, ported from edde746/plezy
lib/screens/media_detail_screen.dart (_buildTvDetailScreen, _tvDetailMetadataParts) and
lib/screens/media_detail/{action_buttons,playback_tracks_status}.dart.

Kept free of Kodi imports so kodi/tests can exercise them; callers pass in anything localised.
"""
from __future__ import absolute_import

try:
    from . import plezy_ui
except (ImportError, ValueError):  # loaded by path from kodi/tests
    import plezy_ui

SEPARATOR = plezy_ui.SEPARATOR

# The hero text column is 1092px wide (Plezy's 60% column at 1080p). At Estuary's bold font13 that holds about
# 58 characters; FittedMetadataLine measures, we can only count.
HERO_META_BUDGET = 58

# Action row geometry, mirrored from templates/script-plex-pre_play.xml.tpl (grouplist 301) and
# includes/plezy_action_button.xml.tpl: Play is a 72px stadium, the version split a 42px segment pulled 8px
# towards it (2px gap), every other action a 56px circle, 10px apart.
ROW_X = 60
ROW_GAP = 10
PLAY_W = 72
VERSION_W = 42
VERSION_PULL = -8
BUTTON_W = 56

# Plezy CodecUtils.formatVideoCodec
VIDEO_CODECS = {
    'h264': u'H.264', 'avc1': u'H.264', 'avc': u'H.264',
    'hevc': u'HEVC', 'h265': u'HEVC', 'hev1': u'HEVC',
    'av1': u'AV1', 'vp8': u'VP8', 'vp9': u'VP9',
    'mpeg2video': u'MPEG-2', 'mpeg2': u'MPEG-2', 'mpeg4': u'MPEG-4', 'vc1': u'VC-1',
}


def _text(obj, attr):
    value = getattr(obj, attr, None)
    return u'{0}'.format(value).strip() if value not in (None, False) else u''


def hero_titles(obj):
    """
    (logo/title slot text, episode line) for the hero: an episode keeps its show's name in the title slot and
    gets its own title on the line under it (Plezy #2217); a movie has no second line.
    """
    if _text(obj, 'type') == 'episode':
        return _text(obj, 'grandparentTitle') or _text(obj, 'title'), _text(obj, 'title')
    return _text(obj, 'defaultTitle') or _text(obj, 'title'), u''


def hero_meta(obj, season_fmt=u'S{}', episode_fmt=u'E{}', extra=u'', budget=HERO_META_BUDGET):
    """
    The hero's metadata line without the scores, and whether the score badges (drawn by the template from the
    RatingsMixin images) still fit after it. Plezy sheds the ratings first, then the content rating, then the
    runtime; the episode label and the date always stay. `extra` (the studios of a watchlist item) is appended
    when it fits.
    """
    line = plezy_ui.detail_meta(obj, season_fmt, episode_fmt, hide_ratings=True, budget=budget)
    if extra and len(line) + len(SEPARATOR) + len(extra) <= budget:
        line = SEPARATOR.join(p for p in (line, extra) if p)
    ratings = plezy_ui.ratings_text(obj)
    fits = bool(ratings) and len(line) + (len(SEPARATOR) if line else 0) + len(ratings) <= budget
    return line, fits


def video_codec(codec):
    """Plezy CodecUtils.formatVideoCodec: 'hevc' -> 'HEVC', 'h264' -> 'H.264'."""
    codec = (codec or u'').strip()
    return VIDEO_CODECS.get(codec.lower(), codec.upper())


def tracks_subtitles(title, off):
    """The subtitle slot of the track status: the selected track's name, or Plezy's 'Off' when there is none."""
    return off if not title else title


def tracks_video(resolution, codec, rendering):
    """
    Plezy buildMediaVideoLabels: '4K • HEVC • DV P8' - Dolby Vision by profile only, HDR / HLG as such, and
    plain SDR is not worth a label. `rendering` is plexnet's videoCodecRendering ('DV P8.1/HDR', 'HDR', 'SDR').
    """
    rendering = (rendering or u'').strip().split(u'/', 1)[0].strip()
    if rendering.upper() == u'SDR':
        rendering = u''
    elif rendering.upper().startswith(u'DV P'):
        rendering = u'DV P' + rendering[4:].split(u'.', 1)[0]
    return SEPARATOR.join(p for p in ((resolution or u'').strip(), video_codec(codec), rendering) if p)


def more_menu_x(play=True, version=False, trailer=False, watched=False, watchlist=False, settings=False):
    """Left edge of the row's 'more' button, from which of the actions before it are visible."""
    x = ROW_X
    if play:
        x += PLAY_W + ROW_GAP
    if version:
        x += VERSION_PULL + VERSION_W + ROW_GAP
    for shown in (trailer, watched, watchlist, settings):
        if shown:
            x += BUTTON_W + ROW_GAP
    return x
