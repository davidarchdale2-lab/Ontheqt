# coding=utf-8
"""
Plezy music / playlist / person / list helpers for the album, artist, queue, playlists, playlist, person and library
list-view windows, ported from edde746/plezy:
 - lib/screens/music/album_detail_screen.dart + lib/widgets/music/track_row.dart (grouped track rows, meta line)
 - lib/screens/playlist/playlist_detail_screen.dart (item count / duration / smart meta)
 - lib/screens/actor_media_screen.dart (the person header line)
 - lib/widgets/media_card_list_layout.dart (list-view row metadata)

Kept free of Kodi imports so they can be tested outside Kodi; callers pass in anything localised.
"""
from __future__ import absolute_import

try:
    from . import plezy_ui
except (ImportError, ValueError):  # loaded by path from kodi/tests
    import plezy_ui

SEPARATOR = plezy_ui.SEPARATOR  # ' • '

# Geometry mirrored from templates/script-plex-album.xml.tpl and includes/music_track_row.xml.tpl (1080p).
ALBUM_LIST_TOP = 432        # first track row's top while the header is showing
ALBUM_LIST_TOP_SCROLLED = 150   # ... once the header has scrolled away (index > ALBUM_SCROLL_INDEX)
ALBUM_SCROLL_INDEX = 4
TRACK_PITCH = 87            # 84px row + Plezy's 3px group gap
TRACK_ROW_H = 84
ALBUM_MENU_X = 1500         # item menus open beside the more column
ALBUM_BUTTON_MENU = (560, 428)  # album menu opens under the More button (action row at y 364-420)

QUEUE_MENU_POS = (1500, 84)     # the queue window's more button (top right)
NOW_PLAYING_MENU_POS = (1500, 370)


def clean(value):
    return u'{0}'.format(value).strip() if value not in (None, False) else u''


def join_meta(*parts):
    """'2019 • 12 tracks • 48m': the non-empty parts joined by Plezy's bullet."""
    return SEPARATOR.join(p for p in (clean(p) for p in parts) if p)


def group_positions(count):
    """M3E grouped rows (Plezy groupItemRadii): 'single' for one row, else 'top', 'mid'..., 'bottom'."""
    if count <= 0:
        return []
    if count == 1:
        return ['single']
    return ['top'] + ['mid'] * (count - 2) + ['bottom']


def count_text(count, one, many):
    """'1 track' / '12 tracks' from two format strings holding {0}."""
    return (one if count == 1 else many).format(count)


def album_meta(year, track_count, duration_ms, one=u'{0} track', many=u'{0} tracks'):
    """MusicDetailHeader's meta line: year, track count, total length."""
    tracks = count_text(track_count, one, many) if track_count else u''
    return join_meta(year, tracks, plezy_ui.duration_text(duration_ms or 0))


def track_artist(track_artist_name, album_artist_name):
    """The artist shown under a track title: only on compilations, where it differs from the album's artist."""
    name = clean(track_artist_name)
    return name if name and name != clean(album_artist_name) else u''


def disc_label(disc_word, number):
    """'Disc 2' (Plezy drops the old uppercase)."""
    return u'{0} {1}'.format(disc_word, number)


def album_group_positions(disc_counts):
    """group.pos for tracks laid out disc by disc; disc_counts = tracks per disc, in order. -> flat list."""
    result = []
    for count in disc_counts:
        result.extend(group_positions(count))
    return result


def item_menu_pos(view_pos, selected_index):
    """Where a track's more menu opens in the album list: under the row. The header has scrolled away (list at
    y 150) once the selected track's index is past ALBUM_SCROLL_INDEX."""
    top = ALBUM_LIST_TOP_SCROLLED if selected_index > ALBUM_SCROLL_INDEX else ALBUM_LIST_TOP
    return ALBUM_MENU_X, top + view_pos * TRACK_PITCH + TRACK_ROW_H


def to_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def played_flags(count, playing_pos):
    """Queue rows: '1' for the rows before the playing one (history, drawn muted), '' for it and the ones after."""
    if playing_pos is None or playing_pos < 0:
        return [u''] * count
    return [u'1' if i < playing_pos else u'' for i in range(count)]


def playlist_meta(item_count, duration_ms, smart=False, one=u'{0} item', many=u'{0} items', smart_label=u'Smart'):
    """PlaylistDetailScreen's meta line / the playlists grid caption: 'N items • 2h 5m • Smart'."""
    items = count_text(item_count, one, many) if item_count else u''
    return join_meta(items, plezy_ui.duration_text(duration_ms or 0), smart_label if smart else u'')


def playlist_caption(item_count, duration_ms, smart=False, one=u'{0} item', many=u'{0} items', smart_label=u'Smart'):
    """Same as playlist_meta (the caption under a playlist card)."""
    return playlist_meta(item_count, duration_ms, smart, one, many, smart_label)


def artist_album(track_artist_name, album_title):
    """'Artist • Album' subtitle of a playlist track."""
    return join_meta(track_artist_name, album_title)


def episode_subtitle(show, season_label, episode_label):
    """'Show • S1 • E2' subtitle of a playlist episode."""
    return join_meta(show, season_label, episode_label)


def person_meta(type_label, birth_date, age, birth_place, death_date=u''):
    """actor_media_screen header: 'Actor • 3 May 1970 (54) • Place', 'Actor • 3 May 1970 - 9 Jan 2020 (49)'."""
    dates = clean(birth_date)
    if dates and clean(death_date):
        dates = u'{0} - {1}'.format(dates, clean(death_date))
    if dates and clean(age):
        dates = u'{0} ({1})'.format(dates, clean(age))
    return join_meta(type_label, dates, birth_place)


def filmography_count(count, one=u'{0} title', many=u'{0} titles'):
    return count_text(count, one, many) if count else u''


def playing_from(album, year, fmt=u'Playing from {0}'):
    """Now-playing source line (Plezy playingFrom): 'Playing from Currents • 2015'. Empty without an album."""
    album = clean(album)
    return fmt.format(join_meta(album, year)) if album else u''


def list_meta(year, duration_text=u'', subtitle=u''):
    """Library list-row metadata (MediaCardList): episodes 'S1 • E2', everything else 'year • duration'."""
    subtitle = clean(subtitle)
    if subtitle:
        return subtitle
    return join_meta(year, duration_text)


def album_row_title(parent_title, title):
    """Library list views pack 'Artist\\nAlbum' into the label; the two-line title keeps that."""
    parent = clean(parent_title)
    return u'{0}\n{1}'.format(parent, clean(title)) if parent else clean(title)
