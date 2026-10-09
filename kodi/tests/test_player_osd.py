# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_player_osd.py (Plezy player chrome geometry + helpers) and its agreement
with the seek dialog / queue strip templates. Run: python3 -m pytest kodi/tests"""
import importlib.util
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, '..', 'script.plezy.native')
LIB = os.path.join(ADDON, 'lib')
TEMPLATES = os.path.join(ADDON, 'resources', 'skins', 'Main', '1080i', 'templates')


def _load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(LIB, name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


osd = _load('plezy_player_osd')


def _read(*parts):
    with open(os.path.join(*parts)) as f:
        return f.read()


# ------------------------------------------------------------------ geometry


def test_timeline_geometry_is_symmetric_x1_5():
    assert osd.BAR_X == 36 + 120 + 18
    assert osd.BAR_X + osd.BAR_W + osd.BAR_X == 1920
    assert osd.BAR_RIGHT == osd.BAR_X + osd.BAR_W
    assert osd.TRACK_Y + osd.TRACK_H // 2 == osd.TRACK_CY
    assert osd.BAR_Y < osd.TRACK_CY < osd.BAR_BOTTOM
    # the time pill sits inside the bottom edge of the scrub preview, the preview just above the slider row
    assert osd.SELECTION_Y + osd.SELECTION_H == osd.BIF_Y + osd.BIF_H - 6
    assert osd.BIF_Y + osd.BIF_H < osd.TRACK_Y
    # the chapter strip ends above the time pill
    assert osd.STRIP_Y + osd.STRIP_H < osd.SELECTION_Y
    assert osd.BIGSEEK_ITEM_W * osd.BIGSEEK_ITEMS <= osd.BAR_W


# ------------------------------------------------------------------ helpers


def test_pill_x_centres_on_the_knob():
    assert osd.pill_x(800, 112) == -56


def test_pill_x_clamps_to_the_slider():
    assert osd.pill_x(10, 112) == -10                      # left edge of the pill at the slider start
    w = osd.BAR_W - 5
    assert w + osd.pill_x(w, 112) + 112 == osd.BAR_W         # right edge at the slider end


def test_pill_x_centres_in_the_preview():
    w = 800
    left = osd.bif_x(w)
    x = osd.pill_x(w, 112, bif_left=left)
    assert osd.BAR_X + w + x + 56 == left + osd.BIF_W // 2


def test_bif_x_is_clamped_to_the_slider():
    assert osd.bif_x(0) == osd.BAR_X
    assert osd.bif_x(osd.BAR_W) == osd.BAR_RIGHT - osd.BIF_W
    assert osd.bif_x(800) == osd.BAR_X + 800 - osd.BIF_W // 2


def test_pill_width():
    assert osd.pill_width('21:47') == osd.SELECTION_W
    assert osd.SELECTION_W <= osd.pill_width('1:23:45') < 140
    assert osd.SELECTION_W < osd.pill_width('Opening titles') <= osd.PILL_MAX_W
    assert osd.pill_width('x' * 200) == osd.PILL_MAX_W
    assert osd.pill_width(None) == osd.SELECTION_W


def test_bigseek_group_x_puts_the_dot_on_the_offset():
    assert osd.bigseek_group_x(0) + osd.BIGSEEK_DOT // 2 == osd.BAR_X
    assert osd.bigseek_group_x(40) + osd.BIGSEEK_DOT // 2 == osd.BAR_X + 40


def test_current_index():
    offsets = [0, 60000, 120000, 300000]
    assert osd.current_index(offsets, 0) == 0
    assert osd.current_index(offsets, 59999) == 0
    assert osd.current_index(offsets, 60000) == 1
    assert osd.current_index(offsets, 999999) == 3
    assert osd.current_index([5000], 100) is None
    assert osd.current_index([], 100) is None


def test_right_cluster_centre():
    every = {'subtitles', 'playlist', 'repeat', 'shuffle', 'vs10'}
    # stop is always last, flush with the right padding
    assert osd.right_cluster_centre(every, 'stop') == osd.RIGHT_END - osd.PITCH // 2
    assert osd.right_cluster_centre(every, 'settings') == osd.RIGHT_END - 6 * osd.PITCH - osd.PITCH // 2
    assert osd.right_cluster_centre(every, 'subtitles') == osd.RIGHT_END - 5 * osd.PITCH - osd.PITCH // 2
    # hidden controls after the target move it right
    assert osd.right_cluster_centre({'subtitles'}, 'subtitles') == osd.RIGHT_END - osd.PITCH - osd.PITCH // 2
    assert osd.right_cluster_centre(set(), 'vs10') == osd.RIGHT_END - osd.PITCH - osd.PITCH // 2


def test_dropdown_pos_stays_on_screen():
    x, y = osd.dropdown_pos(1852)
    assert x + osd.DROPDOWN_W <= 1920 - osd.SIDE
    assert y == osd.ROW_Y
    assert osd.dropdown_pos(1000)[0] == 1000 - osd.DROPDOWN_W // 2
    assert osd.dropdown_pos(10)[0] == osd.SIDE


def test_countdown_seconds():
    assert osd.countdown_seconds(100.0, 85.2) == 15
    assert osd.countdown_seconds(100.0, 99.9) == 1
    assert osd.countdown_seconds(100.0, 101.0) == 0
    assert osd.countdown_seconds(None, 5.0) == 0


def test_join_meta():
    assert osd.join_meta(['S1', 'E2', 'Title', '45m']) == u'S1 · E2 · Title · 45m'
    assert osd.join_meta(['', None, '1h 45m']) == '1h 45m'
    assert osd.join_meta([]) == ''


# ------------------------------------------------------------------ template agreement


def _bottom(y):
    return 'vscale({})'.format(1080 - y) + ' }}r'


def test_seek_dialog_template_matches_the_geometry():
    tpl = _read(TEMPLATES, 'script-plex-seek_dialog.xml.tpl')
    # timeline row (bottom-anchored) and the slider track group inside it
    assert _bottom(osd.TIME_ROW_Y) in tpl
    assert '<posx>{}</posx>\n            <posy>{{{{ vscale({}) }}}}</posy>'.format(
        osd.BAR_X, osd.TRACK_Y - osd.TIME_ROW_Y) in tpl
    assert '<width>{}</width>\n                <height>{{{{ vscale({}) }}}}</height>'.format(osd.BAR_W, osd.TRACK_H) in tpl
    main = re.search(r'<control type="button" id="100">(.*?)</control>', tpl, re.S).group(1)
    assert '<posx>{}</posx>'.format(osd.BAR_X) in main
    assert _bottom(osd.BAR_Y) in main and 'vscale({})'.format(osd.BAR_BOTTOM - osd.BAR_Y) in main
    assert '<width>{}</width>'.format(osd.BAR_W) in main
    sel = re.search(r'<control type="group" id="202">(.*?)<control type="group" id="203">', tpl, re.S).group(1)
    assert _bottom(osd.SELECTION_Y) in sel
    # knob centre on the track centre line
    assert 'vscale({})'.format(osd.TRACK_CY - osd.SELECTION_Y - osd.KNOB // 2) in sel
    pill = re.search(r'<control type="group" id="203">(.*?)</control>\s*</control>', tpl, re.S).group(1)
    assert '<width>{}</width>'.format(osd.SELECTION_W) in pill
    assert _bottom(osd.BIF_Y) in re.search(r'<control type="group" id="300">(.*?)<control', tpl, re.S).group(1)
    # big seek: 12 dot items over the slider width, chapter strip items and position
    assert 'width="{}" height="{{{{ vscale({}) }}}}"'.format(osd.BIGSEEK_ITEM_W, osd.BIGSEEK_DOT) in tpl
    assert 'width="{}" height="{{{{ vscale({}) }}}}"'.format(osd.STRIP_ITEM_W, osd.STRIP_H) in tpl
    lst = re.search(r'<control type="list" id="501">(.*?)<itemlayout', tpl, re.S).group(1)
    assert '<posx>{}</posx>'.format(osd.STRIP_X) in lst and _bottom(osd.STRIP_Y) in lst
    # button row
    row = re.search(r'<control type="group" id="400">(.*?)<control type="grouplist" id="440">', tpl, re.S).group(1)
    assert _bottom(osd.ROW_Y) in row and 'vscale({})'.format(osd.ROW_H) in row


def test_bottom_anchored():
    assert osd.bottom_anchored(962, lambda v: v) == 962
    assert osd.bottom_anchored(962, lambda v: int(round(v * 0.75))) == 1080 - int(round(118 * 0.75))


def test_osd_button_pitch_matches():
    body = _read(TEMPLATES, 'includes', 'seek_osd_button.xml.tpl')
    assert 'pitch={}'.format(osd.PITCH) in body
    assert 'pitch={}'.format(osd.PLAY_PITCH) in body
    tpl = _read(TEMPLATES, 'script-plex-seek_dialog.xml.tpl')
    right = re.search(r'<control type="grouplist" id="441">(.*?)\n        </control>', tpl, re.S).group(1)
    # right cluster: right-aligned, ending SIDE px from the screen edge after the 6px trailing spacer
    posx = int(re.search(r'<posx>(\d+)</posx>', right).group(1))
    width = int(re.search(r'<width>(\d+)</width>', right).group(1))
    assert posx + width - 6 == osd.RIGHT_END
    order = re.findall(r'gid=(\d+) & bid=(\d+)', right)
    ids = []
    for _, b in order:  # theme-specific {% if %} branches repeat an id
        if not ids or ids[-1] != int(b):
            ids.append(int(b))
    expected = [i for _, alts in osd.RIGHT_CLUSTER for i in alts]
    assert ids == expected


def test_strip_item_geometry():
    item = _read(TEMPLATES, 'includes', 'seek_strip_item.xml.tpl')
    assert '<width>{}</width>'.format(osd.STRIP_THUMB_W) in item
    assert 'vscale({})'.format(osd.STRIP_THUMB_H) in item
    queue = _read(TEMPLATES, 'script-plex-video_current_playlist.xml.tpl')
    assert 'width="{}" height="{{{{ vscale({}) }}}}"'.format(osd.STRIP_ITEM_W, osd.STRIP_H) in queue


def test_seekdialog_uses_the_shared_geometry():
    src = _read(LIB, 'windows', 'seekdialog.py')
    for name in ('osd.BAR_W', 'osd.BAR_X', 'osd.BAR_Y', 'osd.BAR_RIGHT', 'osd.BAR_BOTTOM', 'osd.SELECTION_Y',
                 'osd.BIF_Y', 'osd.BIGSEEK_DOT_Y', 'osd.STRIP_Y', 'osd.STRIP_H', 'osd.STRIP_THUMB_W'):
        assert name in src, name
    # the old hard-coded 1920px bar and the grouplist offsets are gone
    assert 'setPosition(30, 0)' not in src
    assert '* 1920)' not in src
