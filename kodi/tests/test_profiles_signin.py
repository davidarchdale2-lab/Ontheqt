# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_profiles.py (profile picker, sign-in). Run: python3 -m pytest kodi/tests"""
import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
LIB = os.path.join(HERE, '..', 'script.plezy.native', 'lib')


def _load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(LIB, name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


pp = _load('plezy_profiles')

LABELS = {'active': 'Active', 'admin': 'Administrator', 'managed': 'Managed user', 'home': 'Home user',
          'protected': 'PIN protected'}


def _dart_color(name):
    """Reference: Plezy's colorForName over the name's UTF-16 code units."""
    if not name:
        return pp.EMPTY_NAME_COLOR
    h = 0
    raw = name.encode('utf-16-le')
    for i in range(0, len(raw), 2):
        h = (h * 31 + raw[i] + (raw[i + 1] << 8)) & 0x7fffffff
    return pp.AVATAR_PALETTE[h % 8]


def test_palette_is_plezys():
    assert pp.AVATAR_PALETTE == ('FF1565C0', 'FF2E7D32', 'FFAD1457', 'FF6A1B9A', 'FF00838F', 'FFE65100',
                                 'FF4527A0', 'FFC62828')


def test_color_for_name_known_values():
    # 'A' = 65, 65 % 8 = 1; 'B' = 66 -> 2; 'Alex' hashes through the *31 recurrence
    assert pp.color_for_name('A') == 'FF2E7D32'
    assert pp.color_for_name('B') == 'FFAD1457'
    h = 0
    for c in 'Alex':
        h = h * 31 + ord(c)
    assert pp.color_for_name('Alex') == pp.AVATAR_PALETTE[h % 8]


def test_color_for_name_empty_and_none():
    assert pp.color_for_name('') == pp.EMPTY_NAME_COLOR
    assert pp.color_for_name(None) == pp.EMPTY_NAME_COLOR


def test_color_for_name_masks_to_31_bits():
    long_name = 'x' * 200  # overflows 31 bits many times over
    assert pp.color_for_name(long_name) == _dart_color(long_name)


def test_color_for_name_uses_utf16_code_units():
    # an emoji is a surrogate pair in Dart; a code point based hash would pick a different entry
    for name in (u'Zoë', u'田中', u'Kid \U0001F600', u'\U0001F600'):
        assert pp.color_for_name(name) == _dart_color(name)
    assert pp.utf16_units(u'\U0001F600') == [0xD83D, 0xDE00]


def test_color_for_name_accepts_bytes():
    assert pp.color_for_name(b'Alex') == pp.color_for_name(u'Alex')


def test_initial_of():
    assert pp.initial_of('alex') == 'A'
    assert pp.initial_of('  maria ') == 'M'
    assert pp.initial_of('') == '?'
    assert pp.initial_of('   ') == '?'
    assert pp.initial_of(None) == '?'
    assert pp.initial_of(u'élan') == u'É'


def test_group_positions():
    assert pp.group_positions(0) == []
    assert pp.group_positions(1) == ['only']
    assert pp.group_positions(2) == ['first', 'last']
    assert pp.group_positions(5) == ['first', 'middle', 'middle', 'middle', 'last']


def test_profile_meta_roles():
    assert pp.profile_meta(LABELS, admin=True) == u'Administrator'
    assert pp.profile_meta(LABELS, managed=True) == u'Managed user'
    assert pp.profile_meta(LABELS) == u'Home user'
    # admin wins over managed, as in a Plex Home
    assert pp.profile_meta(LABELS, admin=True, managed=True) == u'Administrator'


def test_profile_meta_active_and_protected():
    assert pp.profile_meta(LABELS, active=True, admin=True, protected=True) == \
        u'Active • Administrator • PIN protected'
    assert pp.profile_meta(LABELS, active=True) == u'Active • Home user'
    assert pp.profile_meta(LABELS, protected=True, managed=True) == u'Managed user • PIN protected'


def test_pin_chars():
    assert pp.pin_chars('ab7k') == ['A', 'B', '7', 'K']
    assert pp.pin_chars('') == ['', '', '', '']
    assert pp.pin_chars('ab') == ['A', 'B', '', '']
    assert pp.pin_chars('abcdef') == ['A', 'B', 'C', 'D']
    assert pp.pin_chars(None) == ['', '', '', '']
