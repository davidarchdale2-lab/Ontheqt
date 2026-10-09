# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_ui.py (hub icons + spotlight text). Run: python3 -m pytest kodi/tests"""
import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SPEC = importlib.util.spec_from_file_location(
    'plezy_ui', os.path.join(HERE, '..', 'script.plezy.native', 'lib', 'plezy_ui.py'))
plezy_ui = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(plezy_ui)


class Value(str):
    """Stands in for plexnet's PlexValue: a str, empty when the server didn't send the attribute."""


class Item(object):
    def __init__(self, **attrs):
        for k, v in attrs.items():
            setattr(self, k, Value(v))

    def __getattr__(self, attr):  # plexnet returns an empty PlexValue for anything missing
        return Value('')


def icon(name):
    return 'script.plex/plezy/icons/{0}.png'.format(name)


def test_continue_watching_by_identifier_and_title():
    assert plezy_ui.hub_icon('home.continue', 'Continue Watching') == icon('hub_continue')
    assert plezy_ui.hub_icon('movie.inprogress.1', 'In Progress') == icon('hub_continue')
    assert plezy_ui.hub_icon('home.ondeck', 'On Deck') == icon('hub_continue')
    assert plezy_ui.hub_icon('', 'On Deck') == icon('hub_continue')


def test_keyword_order_matches_plezy():
    assert plezy_ui.hub_icon('home.movies.recent', 'Recently Added Movies') == icon('hub_recent')
    assert plezy_ui.hub_icon('x', 'Recently Released Movies') == icon('hub_recent')
    assert plezy_ui.hub_icon('x', 'Top Rated Movies') == icon('hub_star')       # before the broad 'top '
    assert plezy_ui.hub_icon('x', 'Top Movies of 2024') == icon('hub_top')
    assert plezy_ui.hub_icon('x', 'Unwatched Shows') == icon('hub_unwatched')   # before 'watched'
    assert plezy_ui.hub_icon('x', 'Recently Watched') == icon('hub_recent')    # 'recent' wins, as in Plezy
    assert plezy_ui.hub_icon('x', 'More in Drama') == icon('hub_drama')
    assert plezy_ui.hub_icon('x', 'Something Else') == icon('hub_default')
    assert plezy_ui.hub_icon(None, None) == icon('hub_default')


def test_movie_spotlight():
    movie = Item(type='movie', title='Arrival', year='2016', duration=str(116 * 60000), contentRating='gb/12A',
                 rating='9.4', ratingImage='rottentomatoes://image.rating.ripe',
                 audienceRating='8.2', audienceRatingImage='rottentomatoes://image.rating.upright',
                 summary='A linguist works with the military.')
    f = plezy_ui.spotlight_fields(movie)
    assert f['title'] == 'Arrival'
    assert f['meta'] == u'RT 94% • Audience 82% • 12A • 1h 56m • 2016'
    assert f['summary'] == 'A linguist works with the military.'


def test_episode_spotlight_and_spoilers():
    ep = Item(type='episode', title='Pilot', grandparentTitle='Severance', parentIndex='1', index='1',
              duration=str(57 * 60000), contentRating='TV-MA', originallyAvailableAt='2022-02-18',
              audienceRating='8.7', audienceRatingImage='imdb://image.rating', summary='Mark is promoted.')
    f = plezy_ui.spotlight_fields(ep)
    assert f['title'] == 'Severance'
    assert f['meta'] == u'S1 \xb7 E1 \xb7 Pilot • IMDb 8.7 • TV-MA • 57m • February 18, 2022'
    hidden = plezy_ui.spotlight_fields(ep, hide_summary=True, hide_title=True, hide_ratings=True)
    assert hidden['summary'] == ''
    assert hidden['meta'] == u'S1 \xb7 E1 • TV-MA • 57m • February 18, 2022'


def test_show_season_and_music():
    show = Item(type='show', title='Severance', year='2022', duration=str(55 * 60000), contentRating='TV-MA')
    assert plezy_ui.spotlight_fields(show)['meta'] == u'TV-MA • 2022'   # no per-episode runtime for a show
    season = Item(type='season', title='Season 2', parentTitle='Severance')
    f = plezy_ui.spotlight_fields(season)
    assert (f['title'], f['meta']) == ('Severance', 'Season 2')
    album = Item(type='album', title='Kid A', parentTitle='Radiohead', year='2000')
    f = plezy_ui.spotlight_fields(album)
    assert (f['title'], f['meta']) == ('Kid A', u'Radiohead • 2000')
    track = Item(type='track', title='Idioteque', grandparentTitle='Radiohead', parentTitle='Kid A',
                 duration=str(309000))
    f = plezy_ui.spotlight_fields(track)
    assert (f['title'], f['meta']) == ('Radiohead', u'Kid A • 5m')


def test_localised_episode_labels_and_durations():
    ep = Item(type='episode', parentIndex='2', index='10', title='x')
    assert plezy_ui.spotlight_fields(ep, season_fmt=u'St.{}', episode_fmt=u'F{}', hide_title=True)['meta'] == u'St.2 \xb7 F10'
    assert plezy_ui.duration_text(0) == ''
    assert plezy_ui.duration_text(45 * 60000) == '45m'
    assert plezy_ui.duration_text(120 * 60000) == '2h'
    assert plezy_ui.full_date('bogus') == ''


def test_meta_line_drops_like_plezy():
    parts = [('label', u'S2 \xb7 E4 \xb7 A Fairly Long Episode Title'), ('ratings', 'IMDb 8.9'),
             ('content_rating', 'TV-MA'), ('duration', '52m'), ('date', 'February 7, 2025')]
    full = plezy_ui.fit_meta(parts, budget=999)
    assert full.count(plezy_ui.SEPARATOR) == 4
    # ratings go first, then the content rating, then the runtime; label and date always stay
    assert plezy_ui.fit_meta(parts, budget=len(full) - 1) == plezy_ui.SEPARATOR.join(
        [parts[0][1], 'TV-MA', '52m', 'February 7, 2025'])
    assert plezy_ui.fit_meta(parts, budget=10) == plezy_ui.SEPARATOR.join([parts[0][1], 'February 7, 2025'])
