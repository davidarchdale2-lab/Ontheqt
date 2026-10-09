# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_movie_detail.py (Plezy TV movie/episode detail hero). Run: python3 -m pytest kodi/tests"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
LIB = os.path.join(HERE, '..', 'script.plezy.native', 'lib')


def _load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(LIB, name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


plezy_ui = sys.modules.setdefault('plezy_ui', _load('plezy_ui'))
detail = _load('plezy_movie_detail')


class Value(str):
    """Stands in for plexnet's PlexValue: a str, empty when the server didn't send the attribute."""


class Item(object):
    def __init__(self, **attrs):
        for k, v in attrs.items():
            setattr(self, k, Value(v))

    def __getattr__(self, attr):  # plexnet returns an empty PlexValue for anything missing
        return Value('')


MOVIE = dict(type='movie', title='Arrival', defaultTitle='Arrival', year='2016', duration=str(116 * 60000),
             contentRating='gb/12A', rating='9.4', ratingImage='rottentomatoes://image.rating.ripe',
             audienceRating='8.2', audienceRatingImage='rottentomatoes://image.rating.upright')


def test_movie_titles():
    assert detail.hero_titles(Item(**MOVIE)) == ('Arrival', '')
    edition = Item(type='movie', title='Blade Runner', defaultTitle=u'Blade Runner • Final Cut')
    assert detail.hero_titles(edition) == (u'Blade Runner • Final Cut', '')


def test_episode_titles_keep_the_show_in_the_slot():
    ep = Item(type='episode', title='Pilot', grandparentTitle='Severance')
    assert detail.hero_titles(ep) == ('Severance', 'Pilot')
    assert detail.hero_titles(Item(type='episode', title='Pilot')) == ('Pilot', 'Pilot')


def test_movie_meta_in_plezy_order_with_badges():
    line, fits = detail.hero_meta(Item(**MOVIE))
    assert line == u'2016 • 12A • 1h 56m'
    assert fits


def test_episode_meta():
    ep = Item(type='episode', title='Pilot', parentIndex='1', index='3', originallyAvailableAt='2024-03-03',
              contentRating='TV-MA', duration=str(45 * 60000))
    line, fits = detail.hero_meta(ep, season_fmt='S{}', episode_fmt='E{}')
    assert line == u'S1 E3 • Mar 3, 2024 • TV-MA • 45m'
    assert not fits  # no ratings at all


def test_badges_are_shed_before_anything_else():
    line, fits = detail.hero_meta(Item(**MOVIE), budget=30)
    assert line == u'2016 • 12A • 1h 56m'
    assert not fits
    # with an even tighter budget the content rating, then the runtime go; the year always stays
    assert detail.hero_meta(Item(**MOVIE), budget=13)[0] == u'2016 • 1h 56m'
    assert detail.hero_meta(Item(**MOVIE), budget=4)[0] == u'2016'


def test_watchlist_studios_appended_when_they_fit():
    line, _ = detail.hero_meta(Item(type='movie', year='2025'), extra='A24')
    assert line == u'2025 • A24'
    line, _ = detail.hero_meta(Item(type='movie', year='2025'), extra='X' * 80)
    assert line == u'2025'
    assert detail.hero_meta(Item(type='movie'), extra='A24')[0] == u'A24'


def test_missing_fields():
    assert detail.hero_meta(Item(type='movie')) == (u'', False)
    assert detail.hero_titles(Item()) == (u'', u'')


def test_tracks_video():
    assert detail.tracks_video('4K', 'HEVC', 'DV P8.1/HDR') == u'4K • HEVC • DV P8'
    assert detail.tracks_video('4K', 'HEVC', 'DV P5') == u'4K • HEVC • DV P5'
    assert detail.tracks_video('4K', 'HEVC', 'HDR') == u'4K • HEVC • HDR'
    assert detail.tracks_video('1080p', 'H264', 'SDR') == u'1080p • H264'
    assert detail.tracks_video('', '', '') == u''
    assert detail.tracks_video(None, 'AV1', None) == u'AV1'


def test_more_menu_x_follows_the_visible_actions():
    # Play, trailer, watched, settings -> more
    assert detail.more_menu_x(play=True, trailer=True, watched=True, settings=True) == 60 + 82 + 3 * 66
    # the version split adds 44 (42 wide, pulled 8px towards Play)
    assert detail.more_menu_x(play=True, version=True, watched=True, settings=True) == 60 + 82 + 44 + 2 * 66
    assert detail.more_menu_x(play=False) == 60
