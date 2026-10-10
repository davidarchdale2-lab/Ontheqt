# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_music.py (Plezy album / artist / queue / playlist / person / list-view text
and geometry helpers) and the geometry the music windows' Python shares with their templates. Run: python3 -m pytest kodi/tests"""
import importlib.util
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, '..', 'script.plezy.native')
LIB = os.path.join(ADDON, 'lib')
TEMPLATES = os.path.join(ADDON, 'resources', 'skins', 'Main', '1080i', 'templates')


def _load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(LIB, name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


plezy_ui = sys.modules.setdefault('plezy_ui', _load('plezy_ui'))
pm = _load('plezy_music')

BULLET = u' • '


def test_group_positions():
    assert pm.group_positions(0) == []
    assert pm.group_positions(1) == ['single']
    assert pm.group_positions(2) == ['top', 'bottom']
    assert pm.group_positions(5) == ['top', 'mid', 'mid', 'mid', 'bottom']


def test_album_group_positions_per_disc():
    assert pm.album_group_positions([3, 1]) == ['top', 'mid', 'bottom', 'single']
    assert pm.album_group_positions([]) == []


def test_join_meta_drops_empty_parts():
    assert pm.join_meta(u'2019', u'', None, u'48m') == u'2019' + BULLET + u'48m'
    assert pm.join_meta(None, u'') == u''


def test_album_meta():
    assert pm.album_meta(u'2015', 13, 51 * 60000 + 20000) == u'2015' + BULLET + u'13 tracks' + BULLET + u'51m'
    assert pm.album_meta(u'', 1, 0) == u'1 track'
    assert pm.album_meta(u'1999', 0, 0) == u'1999'
    assert pm.album_meta(u'2001', 2, 3600000 + 5 * 60000, one=u'{0} Titel', many=u'{0} Titel') == u'2001' + BULLET + u'2 Titel' + BULLET + u'1h 5m'


def test_track_artist_only_on_compilations():
    assert pm.track_artist(u'', u'Tame Impala') == u''
    assert pm.track_artist(u'Tame Impala', u'Tame Impala') == u''
    assert pm.track_artist(u'Pond', u'Various Artists') == u'Pond'
    assert pm.track_artist(None, u'X') == u''


def test_disc_label_is_not_uppercased():
    assert pm.disc_label(u'Disc', 2) == u'Disc 2'


def test_item_menu_pos_follows_the_scrolled_header():
    # header showing: the list starts at 432 and each row is 87px
    assert pm.item_menu_pos(0, 0) == (pm.ALBUM_MENU_X, 432 + 84)
    assert pm.item_menu_pos(3, 3) == (pm.ALBUM_MENU_X, 432 + 3 * 87 + 84)
    # past the fifth track the header has scrolled away: the list starts at 150
    assert pm.item_menu_pos(6, 9) == (pm.ALBUM_MENU_X, 150 + 6 * 87 + 84)
    assert pm.item_menu_pos(0, pm.ALBUM_SCROLL_INDEX) == (pm.ALBUM_MENU_X, 432 + 84)
    assert pm.item_menu_pos(0, pm.ALBUM_SCROLL_INDEX + 1) == (pm.ALBUM_MENU_X, 150 + 84)


def test_to_int():
    assert pm.to_int('7') == 7
    assert pm.to_int('', 3) == 3
    assert pm.to_int(None, -1) == -1


def test_played_flags():
    assert pm.played_flags(4, 2) == [u'1', u'1', u'', u'']
    assert pm.played_flags(3, 0) == [u'', u'', u'']
    assert pm.played_flags(3, None) == [u'', u'', u'']
    assert pm.played_flags(0, 0) == []


def test_playlist_meta():
    assert pm.playlist_meta(42, 2 * 3600000 + 54 * 60000) == u'42 items' + BULLET + u'2h 54m'
    assert pm.playlist_meta(1, 60000, smart=True) == u'1 item' + BULLET + u'1m' + BULLET + u'Smart'
    assert pm.playlist_meta(0, 0) == u''
    assert pm.playlist_meta(5, 0, smart=True, smart_label=u'Smart playlist') == u'5 items' + BULLET + u'Smart playlist'
    assert pm.playlist_caption(3, 120000) == pm.playlist_meta(3, 120000)


def test_playlist_track_subtitles():
    assert pm.artist_album(u'Daft Punk', u'Discovery') == u'Daft Punk' + BULLET + u'Discovery'
    assert pm.artist_album(u'Daft Punk', u'') == u'Daft Punk'
    assert pm.episode_subtitle(u'Andor', u'S1', u'E10') == u'Andor' + BULLET + u'S1' + BULLET + u'E10'


def test_person_meta():
    assert pm.person_meta(u'Actor', u'3 May 1970', u'54', u'London') == u'Actor' + BULLET + u'3 May 1970 (54)' + BULLET + u'London'
    assert pm.person_meta(u'Director', u'', u'', u'') == u'Director'
    assert pm.person_meta(u'Actor', u'', u'54', u'London') == u'Actor' + BULLET + u'London'
    assert pm.person_meta(u'Actor', u'3 May 1950', u'69', u'', u'9 Jan 2020') == u'Actor' + BULLET + u'3 May 1950 - 9 Jan 2020 (69)'


def test_filmography_count():
    assert pm.filmography_count(0) == u''
    assert pm.filmography_count(1) == u'1 title'
    assert pm.filmography_count(12) == u'12 titles'


def test_list_meta():
    assert pm.list_meta(u'2016', u'1 hr 56 mins') == u'2016' + BULLET + u'1 hr 56 mins'
    assert pm.list_meta(u'', u'45 mins') == u'45 mins'
    assert pm.list_meta(u'2016', u'') == u'2016'
    # episodes: the 'S1 • E2' line wins
    assert pm.list_meta(u'', u'', u'S1' + BULLET + u'E2') == u'S1' + BULLET + u'E2'


def test_album_row_title_keeps_the_two_lines():
    assert pm.album_row_title(u'Tame Impala', u'Currents') == u'Tame Impala\nCurrents'
    assert pm.album_row_title(u'', u'Currents') == u'Currents'


# ---- the seek bars: Python's constants must match the numbers the templates pass to includes/music_seek.xml.tpl ----

def _read(path):
    with open(path, encoding='utf-8') as f:
        return f.read()


def _class_constants(path):
    """NAME = int / util.vscalei(int) assignments in a window class body (no Kodi imports needed)."""
    values = {}
    for m in re.finditer(r'^    ([A-Z_]+) = (?:util\.vscalei\()?(\d+)\)?\s*(?:#.*)?$', _read(path), re.M):
        values[m.group(1)] = int(m.group(2))
    return values


def _seek_args(template):
    m = re.search(r'music_seek\.xml\.tpl" with x=(\d+) & w=(\d+) & y=(\d+) & img=(\d+)', _read(os.path.join(TEMPLATES, template)))
    assert m, template
    return tuple(int(v) for v in m.groups())


def _check_seek(py_file, template, image_id):
    c = _class_constants(os.path.join(LIB, 'windows', py_file))
    x, w, y, img = _seek_args(template)
    assert img == image_id
    assert c['SEEK_IMAGE_WIDTH'] == w
    assert c['BAR_X'] == x
    assert c['BAR_RIGHT'] == x + w
    assert c['BAR_Y'] == y
    assert c['BAR_BOTTOM'] == y + 78
    assert c['SELECTION_INDICATOR_Y'] == y - 32


def test_now_playing_seek_geometry_matches_template():
    _check_seek('musicplayer.py', 'script-plex-music_player.xml.tpl', 200)


def test_queue_seek_geometry_matches_template():
    _check_seek('currentplaylist.py', 'script-plex-music_current_playlist.xml.tpl', 510)


def test_dropdown_positions_match_the_layouts():
    # the more button of the now-playing window sits at x 1758 + 42 (centre); the queue's at the top right
    assert pm.NOW_PLAYING_MENU_POS[0] == pm.QUEUE_MENU_POS[0] == pm.ALBUM_MENU_X
    # album menu: under the More button of the action row (row 364-420)
    assert pm.ALBUM_BUTTON_MENU[1] == 364 + 56 + 8


def _read(*parts):
    with open(os.path.join(ADDON, *parts), encoding='utf-8') as f:
        return f.read()


def test_playing_from():
    assert pm.playing_from(u'Currents', u'2015') == u'Playing from Currents' + BULLET + u'2015'
    assert pm.playing_from(u'Currents', u'') == u'Playing from Currents'
    assert pm.playing_from(u'', u'2015') == u''  # no leading bullet for a track without an album


def test_queue_close_chevron_is_handled_in_python():
    queue = _read('resources', 'skins', 'Main', '1080i', 'templates', 'script-plex-music_current_playlist.xml.tpl')
    player = _read('resources', 'skins', 'Main', '1080i', 'templates', 'script-plex-music_player.xml.tpl')
    assert '<onclick>Close</onclick>' not in queue and 'onclick="Close"' not in player  # Close is not a Kodi builtin
    assert re.search(r'elif controlID == self\.PLAYLIST_BUTTON_ID:\s+self\.doClose\(\)', _read('lib', 'windows', 'currentplaylist.py'))


def test_hub_focus_cleared_off_the_rows():
    assert re.search(r"else:\s+#[^\n]*\n\s+self\.setProperty\('hub\.focus', '0'\)", _read('lib', 'windows', 'person.py'))
    assert re.search(r"class ArtistWindow.*?def onFocus.*?setProperty\('hub\.focus', '0'\)", _read('lib', 'windows', 'subitems.py'), re.S)


def test_person_date_has_no_zero_padded_day():
    src = _read('lib', 'windows', 'person.py')
    assert "strftime('%B %d, %Y')" not in src and 'd.day' in src


def test_dropdown_anchors_are_vscaled():
    for name in ('tracks', 'currentplaylist', 'playlist', 'person'):
        assert 'vscalei' in _read('lib', 'windows', name + '.py')
