# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_settings.py (settings, dialogs and menus). Run: python3 -m pytest kodi/tests"""
import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
LIB = os.path.join(HERE, '..', 'script.plezy.native', 'lib')


def _load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(LIB, name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


ps = _load('plezy_settings')
MEDIA = os.path.join(HERE, '..', 'script.plezy.native', 'resources', 'skins', 'Main', 'media')


def test_section_icon_known_and_fallback():
    assert ps.section_icon('main') == 'script.plex/plezy/icons/settings.png'
    assert ps.section_icon('about') == 'script.plex/plezy/icons/info.png'
    assert ps.section_icon('nope') == 'script.plex/plezy/icons/tune.png'


def test_every_icon_the_python_can_hand_out_exists():
    names = set(ps.SECTION_ICONS.values()) | set(ps.PLAYER_SETTING_ICONS.values()) | {'tune'}
    for name in names:
        assert os.path.exists(os.path.join(MEDIA, 'script.plex', 'plezy', 'icons', name + '.png')), name


def test_section_subtitle_joins_first_three_labels():
    assert ps.section_subtitle(['A', 'B', 'C', 'D']) == u'A · B · C'
    assert ps.section_subtitle(['A']) == 'A'
    assert ps.section_subtitle([]) == ''


def test_section_subtitle_skips_blank_labels_before_the_limit():
    assert ps.section_subtitle([None, '', '  ', 'A', 'B', 'C', 'D']) == u'A · B · C'
    assert ps.section_subtitle(['A', 'B', 'C'], limit=2) == u'A · B'


def test_setting_subtitle_value_and_description():
    assert ps.setting_subtitle('3 s', '') == '3 s'
    assert ps.setting_subtitle('', 'Skip user selection.') == 'Skip user selection.'
    assert ps.setting_subtitle('HEVC, VC-1', 'Select codecs.') == u'HEVC, VC-1 · Select codecs.'
    assert ps.setting_subtitle(None, None) == ''
    assert ps.setting_subtitle(' x ', ' ') == 'x'


def test_group_flags_round_only_the_outer_corners():
    assert ps.group_flags(0, 1) == (True, True)
    assert [ps.group_flags(i, 3) for i in range(3)] == [(True, False), (False, False), (False, True)]
    assert ps.group_flags(0, 0) == (False, False)


def test_indicator_selected_marks_current_choices_only():
    assert ps.indicator_selected('script.plex/home/device/check.png')
    assert ps.indicator_selected('script.plex/indicators/arrow-down.png')
    assert ps.indicator_selected('script.plex/indicators/arrow-up.png')
    assert ps.indicator_selected('script.plex/indicators/circle-19.png')
    assert not ps.indicator_selected('script.plex/indicators/remove.png')
    assert not ps.indicator_selected('')
    assert not ps.indicator_selected(None)


def test_menu_slots_counts_trailing_icons():
    assert ps.menu_slots(False, 'x.png', False) == 0
    assert ps.menu_slots(True, '', False) == 0
    assert ps.menu_slots(True, 'x.png', False) == 1
    assert ps.menu_slots(False, '', True) == 1
    assert ps.menu_slots(True, 'x.png', True) == 2


def test_menu_row_properties():
    assert ps.menu_row_properties(True, 'script.plex/home/device/check.png', False) == {'selected': '1', 'slots': '1'}
    assert ps.menu_row_properties(True, 'script.plex/indicators/circle-19.png', True) == {'selected': '1', 'slots': '2'}
    assert ps.menu_row_properties(True, 'script.plex/indicators/remove.png', False) == {'selected': '', 'slots': '1'}
    # an indicator image only counts when the dialog was opened with indicators
    assert ps.menu_row_properties(False, 'script.plex/home/device/check.png', False) == {'selected': '', 'slots': '0'}
    assert ps.menu_row_properties(True, '', True) == {'selected': '', 'slots': '1'}


def test_player_setting_icon():
    assert ps.player_setting_icon('audio') == 'script.plex/plezy/icons/audiotrack.png'
    assert ps.player_setting_icon('stream_info') == 'script.plex/plezy/icons/info.png'
    assert ps.player_setting_icon('unknown') == ''


def test_bottom_anchored_dropdown_y_is_bounded():
    assert ps.bottom_anchored_dropdown_y(3, 66) == 3 * 66 + 80
    assert ps.bottom_anchored_dropdown_y(14, 66) == 14 * 66 + 80
    # more than 14 rows scroll, so the offset (and with it the dropdown's top) stops growing
    assert ps.bottom_anchored_dropdown_y(40, 66) == 14 * 66 + 80


def test_focus_just_changed():
    assert ps.focus_just_changed(10.05, 10.0)
    assert not ps.focus_just_changed(10.5, 10.0)
    assert not ps.focus_just_changed(10.0, None)
