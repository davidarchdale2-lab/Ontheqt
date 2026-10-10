# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_show_detail.py (Plezy TV show detail). Run: python3 -m pytest kodi/tests"""
import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SPEC = importlib.util.spec_from_file_location(
    'plezy_show_detail', os.path.join(HERE, '..', 'script.plezy.native', 'lib', 'plezy_show_detail.py'))
sd = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(sd)


class Value(str):
    """Stands in for plexnet's PlexValue: a str, empty when the server didn't send the attribute."""


class Item(object):
    def __init__(self, **attrs):
        for k, v in attrs.items():
            setattr(self, k, Value(v))

    def __getattr__(self, attr):  # plexnet returns an empty PlexValue for anything missing
        return Value('')


def s1e3(season, episode):
    return u'S{0} E{1}'.format(season, episode) if season and episode else u''


def test_count_label_singular_plural_and_empty():
    assert sd.count_label(1, u'{} episode', u'{} episodes') == u'1 episode'
    assert sd.count_label(10, u'{} episode', u'{} episodes') == u'10 episodes'
    assert sd.count_label(0) == u''


def test_season_subtitle_uses_leaf_count():
    assert sd.season_subtitle(Item(leafCount='8')) == u'8 episodes'
    assert sd.season_subtitle(Item(leafCount='1')) == u'1 episode'
    assert sd.season_subtitle(Item()) == u''


def test_season_hero_line_meta_and_summary_fallback():
    hero = sd.season_hero(Item(title='Season 2', year='2025', leafCount='10'), u'The show.')
    assert hero == {'line': u'Season 2', 'meta': u'2025 • 10 episodes', 'summary': u'The show.'}
    own = sd.season_hero(Item(title='Season 1', leafCount='9', summary='First.', parentYear='2022'), u'The show.')
    # the show's premiere year is not the season's
    assert own == {'line': u'Season 1', 'meta': u'9 episodes', 'summary': u'First.'}
    assert sd.season_hero(Item(title='Specials'))['meta'] == u''


def test_play_state_from_on_deck():
    assert sd.play_state([Item(parentIndex='2', index='4', viewOffset='120000')], s1e3) == (u'S2 E4', True)
    assert sd.play_state([Item(parentIndex='1', index='1')], s1e3) == (u'S1 E1', False)
    # no on-deck episode (fully watched, or not loaded): plain Play
    assert sd.play_state([], s1e3, u'Play') == (u'Play', False)
    assert sd.play_state(Value(''), s1e3, u'Play') == (u'Play', False)  # attribute missing on a partial object
    # numbers missing: fall back too
    assert sd.play_state([Item(index='3')], s1e3, u'Play') == (u'Play', False)


def test_play_state_without_on_deck_offers_the_default_season_first_episode():
    seasons = [Item(index='0', title='Specials'), Item(index='1'), Item(index='2')]
    # Plezy defaultPlaybackSeason: the first real season, so 'S1E1' rather than a bare Play
    assert sd.play_state([], s1e3, u'Play', seasons) == (u'S1 E1', False)
    assert sd.play_state(Value(''), s1e3, u'Play', seasons) == (u'S1 E1', False)
    # specials only: the first one; no seasons yet: the plain label
    assert sd.play_state([], s1e3, u'Play', [Item(index='0')]) == (u'S0 E1', False)
    assert sd.play_state([], s1e3, u'Play', []) == (u'Play', False)
    assert sd.play_state([], s1e3, u'Play', None) == (u'Play', False)
    # a season without an index cannot be labelled
    assert sd.play_state([], s1e3, u'Play', [Item(title='?')]) == (u'Play', False)
    # the on-deck episode still wins
    assert sd.play_state([Item(parentIndex='2', index='4')], s1e3, u'Play', seasons) == (u'S2 E4', False)


def test_default_play_season():
    s0, s1 = Item(index='0'), Item(index='1')
    assert sd.default_play_season([s0, s1]) is s1
    assert sd.default_play_season([s0]) is s0
    assert sd.default_play_season([]) is None
    assert sd.default_play_season(Value('')) is None


def test_summary_lines_estimates_the_wrapped_line_count():
    assert sd.summary_lines(u'') == 0
    assert sd.summary_lines(None) == 0
    assert sd.summary_lines(u'   \n ') == 0
    assert sd.summary_lines(u'One line.') == 1
    assert sd.summary_lines(u'word ' * 20) == 2  # 99 characters wrap onto a second line
    assert sd.summary_lines(u'word ' * 40) == 3
    assert sd.summary_lines(u'word ' * 400) == sd.SUMMARY_MAX_LINES  # more than three: the box shows three
    assert sd.summary_lines(u'First paragraph.\n\nSecond.') == 3  # the blank line takes a line
    assert sd.summary_lines(u'x' * 100) == 2  # a very long word breaks mid-word
    assert sd.summary_lines(u'a b', chars_per_line=1) == 2


def test_scale_pos_scales_only_y():
    assert sd.scale_pos((440, 656), lambda y: y) == (440, 656)
    assert sd.scale_pos((440, 656), lambda y: round(y * 0.75)) == (440, 492)
    assert sd.scale_pos(sd.season_menu_pos(0), lambda y: int(y * 0.75))[1] == 525


def test_first_trailer():
    extras = [Item(title='Featurette', extraType='10'), Item(title='Teaser', extraType='1'),
              Item(title='Trailer 2', extraType='1')]
    assert sd.first_trailer(extras).title == 'Teaser'
    assert sd.first_trailer([Item(extraType='5')]) is None
    assert sd.first_trailer(None) is None
    assert sd.first_trailer(Value('')) is None


def test_season_menu_pos_next_to_the_card():
    x0, y = sd.season_menu_pos(0)
    assert (x0, y) == (44 + 16 + 174 + 16, sd.SEASON_MENU_Y)
    assert sd.season_menu_pos(2)[0] == x0 + 2 * 198
    assert sd.season_menu_pos(None)[0] == x0
    assert sd.season_menu_pos(-1)[0] == x0
