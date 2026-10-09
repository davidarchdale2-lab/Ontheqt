# coding=utf-8
"""Tests for script.plezy.native's lib/plezy_search.py (Plezy search). Run: python3 -m pytest kodi/tests"""
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
ps = _load('plezy_search')


class Value(str):
    """Stands in for plexnet's PlexValue: a str, empty when the server didn't send the attribute."""


class Item(object):
    def __init__(self, TYPE, **attrs):
        self.TYPE = TYPE
        for k, v in attrs.items():
            setattr(self, k, Value(v))

    def __getattr__(self, attr):  # plexnet returns an empty PlexValue for anything missing
        return Value('')


def test_chip_buttons_cover_every_kind_once():
    assert ps.SECTION_BUTTONS[901] == 'all'
    assert [ps.SECTION_BUTTONS[i] for i in range(902, 907)] == list(ps.KINDS)
    assert set(ps.KIND_TYPES) == set(ps.KINDS)


def test_every_filter_type_has_a_card_shape():
    for types in ps.KIND_TYPES.values():
        for hub_type in types:
            assert hub_type in ps.HUB_DISPLAY, hub_type
    assert set(ps.HUB_DISPLAY.values()) == {'poster', 'square', 'ar16x9', 'circle'}


def test_present_kinds_follow_chip_order_and_ignore_empty_hubs():
    hubs = [('actor', 3), ('album', 2), ('movie', 0), ('episode', 4), ('genre', 5)]
    assert ps.present_kinds(hubs) == ['show', 'artist', 'people']
    assert ps.present_kinds([('movie', 0), ('show', 0)]) == []
    assert ps.present_kinds([]) == []
    assert ps.present_kinds([('collection', 3), ('playlist', 1)]) == []  # no chip for these


def test_chips_only_show_when_there_is_something_to_filter_by():
    assert not ps.show_chips([])
    assert not ps.show_chips(['movie'])
    assert ps.show_chips(['movie', 'people'])


def test_selected_kind_falls_back_to_all_when_a_later_query_lacks_it():
    assert ps.resolve_section('movie', ['movie', 'show']) == 'movie'
    assert ps.resolve_section('artist', ['movie', 'show']) == 'all'
    assert ps.resolve_section('all', []) == 'all'
    assert ps.resolve_section('', ['movie']) == 'all'
    assert ps.resolve_section(None, ['movie']) == 'all'


def test_hub_rows_are_contiguous_and_limited():
    hubs = [('movie', 4), ('mystery', 2), ('show', 0), ('episode', 3), ('actor', 1)]
    handled = ps.HUB_DISPLAY
    assert ps.hub_ids_to_show(hubs, 'all', handled) == [0, 3, 4]
    assert ps.hub_ids_to_show(hubs, 'show', handled) == [3]
    assert ps.hub_ids_to_show(hubs, 'people', handled) == [4]
    assert ps.hub_ids_to_show(hubs, 'all', handled, limit=2) == [0, 3]
    assert ps.hub_ids_to_show(hubs, 'photo', handled) == []
    assert ps.hub_ids_to_show(hubs, 'all') == [0, 1, 3, 4]  # no handled filter: only empties drop


def test_allowed_types_for_all_is_no_filter():
    assert ps.allowed_types('all') is None
    assert ps.allowed_types('people') == ('actor', 'director')
    assert ps.allowed_types('nonsense') is None


def test_hub_icons():
    assert ps.hub_icon('movie') == 'script.plex/plezy/icons/movie.png'
    assert ps.hub_icon('season') == 'script.plex/plezy/icons/show.png'
    assert ps.hub_icon('track') == 'script.plex/plezy/icons/artist.png'
    assert ps.hub_icon('actor') == 'script.plex/plezy/icons/person.png'
    assert ps.hub_icon('playlist') == 'script.plex/plezy/icons/playlists.png'
    assert ps.hub_icon('something new') == 'script.plex/plezy/icons/hub_default.png'
    assert ps.hub_icon(None) == 'script.plex/plezy/icons/hub_default.png'


def test_thumb_kind():
    assert ps.thumb_kind('movie') == 'thumb'
    assert ps.thumb_kind('episode') == 'thumb'  # the still, not the season poster
    assert ps.thumb_kind('track') == 'default'
    assert ps.thumb_kind('album') == 'default'
    assert ps.thumb_kind('playlist') == 'composite'
    assert ps.thumb_kind('photodirectory') == 'composite'
    assert ps.thumb_kind('Genre') == ''
    assert ps.thumb_kind('Role') == 'thumb'


def test_movie_and_show_cards_show_the_year():
    assert ps.card_texts(Item('movie', title='Arrival', year='2016')) == (u'Arrival', u'2016')
    assert ps.card_texts(Item('show', title='Severance')) == (u'Severance', u'')


def test_season_card_names_the_show_first():
    season = Item('season', title='Season 2', parentTitle='Severance')
    assert ps.card_texts(season) == (u'Severance', u'Season 2')
    assert ps.card_texts(Item('season', title='Season 2')) == (u'Season 2', u'Season 2')


def test_episode_card_has_number_and_title_in_the_subtitle():
    ep = Item('episode', title="Woe's Hollow", grandparentTitle='Severance', parentIndex='2', index='4')
    assert ps.card_texts(ep) == (u'Severance', u"S2E4 \xb7 Woe's Hollow")
    assert ps.card_texts(ep, u'T{}', u'F{}') == (u'Severance', u"T2F4 \xb7 Woe's Hollow")
    no_number = Item('episode', title='Pilot', grandparentTitle='Severance')
    assert ps.card_texts(no_number) == (u'Severance', u'Pilot')
    orphan = Item('episode', title='Pilot', parentIndex='1', index='1')
    assert ps.card_texts(orphan) == (u'Pilot', u'S1E1')


def test_music_cards_name_the_artist():
    assert ps.card_texts(Item('album', title='Discovery', parentTitle='Daft Punk')) == (u'Discovery', u'Daft Punk')
    track = Item('track', title='One More Time', grandparentTitle='Daft Punk', parentTitle='Discovery')
    assert ps.card_texts(track) == (u'One More Time', u'Daft Punk')
    assert ps.card_texts(Item('artist', title='Daft Punk')) == (u'Daft Punk', u'')


def test_photo_card_shows_the_date_when_there_is_one():
    assert ps.card_texts(Item('photo', title='IMG_1', originallyAvailableAt='2024-03-03')) == (u'IMG_1', u'Mar 3, 2024')
    assert ps.card_texts(Item('photo', title='IMG_2')) == (u'IMG_2', u'')
    assert ps.card_texts(Item('photodirectory', title='Holiday')) == (u'Holiday', u'')


def test_person_card_has_a_credit_line():
    labels = {'Role': u'Actor', 'Director': u'Director'}
    assert ps.card_texts(Item('Role', tag='Tom Hanks'), role_labels=labels) == (u'Tom Hanks', u'Actor')
    assert ps.card_texts(Item('Director', tag='Denis Villeneuve'), role_labels=labels) == (u'Denis Villeneuve', u'Director')
    assert ps.card_texts(Item('Role', tag='Tom Hanks', reasonTitle='Cast'))[1] == u'Cast'  # no labels given: server's
    assert ps.card_texts(Item('Genre', tag='Drama', reasonTitle='Movies')) == (u'Drama', u'Movies')


def test_playlist_card_uses_its_tag():
    assert ps.card_texts(Item('playlist', tag='Road trip', title='x')) == (u'Road trip', u'')
    assert ps.card_texts(Item('playlist', title='Road trip')) == (u'Road trip', u'')


def test_unknown_types_fall_back_to_the_title():
    assert ps.card_texts(Item('collection', title='Marvel')) == (u'Marvel', u'')
    assert ps.card_texts(Item('clip', title='Trailer')) == (u'Trailer', u'')
