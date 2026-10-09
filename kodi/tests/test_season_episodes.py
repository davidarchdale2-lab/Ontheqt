# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_season_episodes.py (Plezy TV season detail). Run: python3 -m pytest kodi/tests"""
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
se = _load('plezy_season_episodes')


class Value(str):
    """Stands in for plexnet's PlexValue: a str, empty when the server didn't send the attribute."""


class Item(object):
    def __init__(self, **attrs):
        for k, v in attrs.items():
            setattr(self, k, Value(v))

    def __getattr__(self, attr):  # plexnet returns an empty PlexValue for anything missing
        return Value('')


def test_episode_number_needs_both_numbers():
    assert se.episode_number('1', '3') == u'S1E3'
    assert se.episode_number('0', '2') == u'S0E2'  # specials keep their season 0
    assert se.episode_number('', '3') == u''
    assert se.episode_number('2', None) == u''
    assert se.episode_number('2', '5', u'T{}', u'F{}') == u'T2F5'


def test_card_subtitle_number_and_runtime():
    ep = Item(type='episode', parentIndex='1', index='3', duration='2700000')
    assert se.card_subtitle(ep) == u'S1E3 \xb7 45m'
    long_ep = Item(type='episode', parentIndex='2', index='10', duration='5400000')
    assert se.card_subtitle(long_ep) == u'S2E10 \xb7 1h 30m'


def test_card_subtitle_falls_back_to_air_date_and_drops_missing_runtime():
    dated = Item(type='episode', originallyAvailableAt='2024-03-03', duration='1500000')
    assert se.card_subtitle(dated) == u'Mar 3, 2024 \xb7 25m'
    assert se.card_subtitle(Item(type='episode', parentIndex='1', index='3')) == u'S1E3'
    assert se.card_subtitle(Item(type='episode')) == u''


def test_hero_meta_line_without_scores():
    ep = Item(type='episode', parentIndex='1', index='3', originallyAvailableAt='2024-03-03',
              contentRating='de/16', duration='2700000')
    line, fits = se.hero_meta(ep)
    assert line == u'S1 E3 • Mar 3, 2024 • 16 • 45m'
    assert fits is False  # no scores at all


def test_hero_meta_scores_fit_flag():
    ep = Item(type='episode', parentIndex='1', index='3', originallyAvailableAt='2024-03-03', duration='2700000',
              rating='8.4', ratingImage='imdb://image.rating')
    line, fits = se.hero_meta(ep)
    assert u'IMDb' not in line
    assert fits is True
    line, fits = se.hero_meta(ep, budget=len(line) + 2)
    assert fits is False


def test_hero_meta_sheds_content_rating_then_runtime():
    ep = Item(type='episode', parentIndex='12', index='104', originallyAvailableAt='2024-09-30',
              contentRating='TV-MA', duration='5400000')
    full, _ = se.hero_meta(ep)
    assert full == u'S12 E104 • Sep 30, 2024 • TV-MA • 1h 30m'
    shed, _ = se.hero_meta(ep, budget=len(full) - 1)
    assert shed == u'S12 E104 • Sep 30, 2024 • 1h 30m'
    shed, _ = se.hero_meta(ep, budget=10)
    assert shed == u'S12 E104 • Sep 30, 2024'


def test_count_label():
    assert se.count_label(0) == u''
    assert se.count_label(1) == u'1 episode'
    assert se.count_label(10, u'{} Folge', u'{} Folgen') == u'10 Folgen'


def test_season_hero_own_year_count_and_summary_fallback():
    show = Item(type='show', title='Severance', year='2022', summary='Show summary.', contentRating='TV-MA')
    season = Item(type='season', title='Season 2', year='2025', parentYear='2022', leafCount='10',
                  summary='Season summary.')
    assert se.season_hero(season, show) == {'line': u'Season 2', 'meta': u'2025 • 10 episodes',
                                            'summary': u'Season summary.'}
    bare = Item(type='season', title='Specials', parentYear='2022', leafCount='1')
    assert se.season_hero(bare, show) == {'line': u'Specials', 'meta': u'1 episode', 'summary': u'Show summary.'}


def test_season_hero_without_season_describes_the_show():
    show = Item(type='show', title='Severance', year='2022', summary='Show summary.', contentRating='us/TV-MA')
    assert se.season_hero(None, show) == {'line': u'', 'meta': u'2022 • TV-MA', 'summary': u'Show summary.'}


def test_tracks_video_labels():
    assert se.tracks_video('1080p', 'h264', 'SDR') == u'1080p • H.264'
    assert se.tracks_video('4K', 'hevc', 'DV P8.1/HDR') == u'4K • HEVC • DV P8'
    assert se.tracks_video('4K', 'HEVC', 'HDR') == u'4K • HEVC • HDR'
    assert se.tracks_video('', '', '') == u''
    assert se.tracks_video('720p', 'mpeg2video', None) == u'720p • MPEG-2'


def test_menu_positions_follow_the_template_geometry():
    # Play 60-132, shuffle 142, watched 208, settings 274, more 340 (+44 with the version split)
    assert se.more_menu_pos() == (340, 654)
    assert se.more_menu_pos(multiple=True) == (384, 654)
    # card 0 artwork 60-356, card 1 380-676
    assert se.item_menu_pos(0) == (372, 710)
    assert se.item_menu_pos(1) == (692, 710)
    assert se.item_menu_pos(None) == (372, 710)
