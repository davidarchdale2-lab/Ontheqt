# coding=utf-8
"""
Behaviour of script.plezy.native's lib/windows/search.py (SearchDialog) with the Kodi modules stubbed out: which shelves
and chips an answer produces, that a chip click costs no request, focus when chips or lists go away, Back and clear,
the search key, history, errors, and typing while a request is in flight. Run: python3 -m pytest kodi/tests
"""
import importlib.util
import json
import os
import sys
import threading
import time
import types
from unittest import mock

import pytest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, '..', 'script.plezy.native')

ACTION_NAV_BACK = 92
ACTION_PREVIOUS_MENU = 10


class Value(str):
    """Stands in for plexnet's PlexValue."""

    def asInt(self, default=0):
        return int(self or default)

    def asTranscodedImageURL(self, w, h, **kwargs):
        return 'img://%s/%dx%d' % (self, w, h)


class Item(object):
    isWatched = False
    isFullyWatched = False
    unViewedLeafCount = 3

    def __init__(self, TYPE, **attrs):
        self.TYPE = TYPE
        for k, v in attrs.items():
            setattr(self, k, Value(v))

    def __getattr__(self, attr):
        return Value('')

    def get(self, attr, default=''):
        return Value(self.__dict__.get(attr, default))

    def exists(self):
        return True


class Hub(object):
    def __init__(self, hub_type, title, items):
        self.type = hub_type
        self.title = title
        self.items = items
        self.size = Value(str(len(items)))


class Server(object):
    uuid = 'xxxxxxxxcafebabe'

    def __init__(self):
        self.calls = []
        self.answer = []
        self.fail = False
        self.delay = 0

    def hubs(self, count, search_query, section):
        self.calls.append(search_query)
        time.sleep(self.delay)
        if self.fail:
            raise RuntimeError('boom')
        return list(self.answer)


class ManagedListItem(object):
    def __init__(self, label='', label2='', thumbnailImage='', data_source=None):
        self.label, self.label2, self.thumb, self.dataSource = label, label2, thumbnailImage, data_source
        self.props = {}

    def setProperty(self, key, value):
        self.props[key] = value

    def setBoolProperty(self, key, boolean):
        self.props[key] = boolean and '1' or ''


class ManagedControlList(object):
    def __init__(self, win, control_id, max_view_index):
        self.controlID = control_id
        self.items = []

    def reset(self):
        self.items = []

    def addItems(self, items):
        self.items.extend(items)

    def size(self):
        return len(self.items)

    def getSelectedItem(self):
        return self.items[0] if self.items else None


class SafeControlEdit(object):
    def __init__(self, control_id, label_id, win, key_callback=None, grab_focus=False):
        self.text = ''

    def getText(self):
        return self.text

    def setText(self, text):
        self.text = text

    def append(self, text):
        self.text += text

    def delete(self):
        self.text = self.text[:-1]

    def updateLabel(self):
        pass

    def setCompatibleMode(self, on):
        pass


class BaseDialog(object):
    _winID = 1

    def __init__(self, *args, **kwargs):
        self.props = {}
        self.focus = 1001
        self.closed = False

    def setProperty(self, key, value):
        self.props[key] = value

    def getProperty(self, key):
        return self.props.get(key, '')

    def propertyContext(self, key, value='1'):
        win = self

        class Context(object):
            def __enter__(self):
                self.old = win.getProperty(key)
                win.setProperty(key, value)

            def __exit__(self, *args):
                win.setProperty(key, self.old)
        return Context()

    def setFocusId(self, control_id):
        self.focus = control_id

    def getFocusId(self):
        return self.focus

    def onAction(self, action):
        pass

    def doClose(self):
        self.closed = True


class UtilMixin(object):
    def __init__(self):
        pass


def _module(name, **attrs):
    module = types.ModuleType(name)
    module.__dict__.update(attrs)
    sys.modules[name] = module
    return module


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


@pytest.fixture(scope='module')
def env():
    """lib.windows.search imported against stubbed Kodi modules; sys.modules is restored afterwards."""
    server = Server()
    store = {}
    with mock.patch.dict(sys.modules):
        xbmcgui = _module('xbmcgui', ACTION_NAV_BACK=ACTION_NAV_BACK, ACTION_PREVIOUS_MENU=ACTION_PREVIOUS_MENU)
        xbmc = _module('xbmc', executebuiltin=lambda command: None)
        _module('kodi_six', xbmcgui=xbmcgui, xbmc=xbmc)

        class ServerManager(object):
            selectedServer = server

        class Account(object):
            ID = '1'
        plexapp = _module('plexnet.plexapp', SERVERMANAGER=ServerManager, ACCOUNT=Account)
        _module('plexnet', plexapp=plexapp)

        class Monitor(object):
            @staticmethod
            def waitForAbort(timeout):
                time.sleep(min(timeout, 0.01))
                return False

        util = _module(
            'lib.util', T=lambda ID, eng='': eng, ERROR=lambda *a, **k: None, DEBUG_LOG=lambda *a, **k: None,
            MONITOR=Monitor, getSetting=lambda key, default=None: store.get(key, default),
            setSetting=lambda key, value: store.__setitem__(key, value),
            ADDON=types.SimpleNamespace(getAddonInfo=lambda key: '/x'), scaleResolution=lambda w, h, by=None: (w, h),
            messageDialog=lambda *a: None)
        lib = _module('lib', util=util, __path__=[os.path.join(ROOT, 'lib')])
        version = {'version': {'major': 19}}
        _module('lib.kodijsonrpc', rpc=types.SimpleNamespace(
            Application=types.SimpleNamespace(GetProperties=lambda properties: version)))
        plezy_ui = sys.modules.get('plezy_ui') or _load('plezy_ui', os.path.join(ROOT, 'lib', 'plezy_ui.py'))
        sys.modules['plezy_ui'] = plezy_ui
        lib.plezy_search = _load('lib.plezy_search', os.path.join(ROOT, 'lib', 'plezy_search.py'))

        windows = _module('lib.windows', __path__=[os.path.join(ROOT, 'lib', 'windows')])
        for name, attrs in (('kodigui', dict(ManagedListItem=ManagedListItem, ManagedControlList=ManagedControlList,
                                             SafeControlEdit=SafeControlEdit, BaseDialog=BaseDialog)),
                            ('windowutils', dict(UtilMixin=UtilMixin)), ('opener', {}), ('optionsdialog', {})):
            setattr(windows, name, _module('lib.windows.' + name, **attrs))
        search = _load('lib.windows.search', os.path.join(ROOT, 'lib', 'windows', 'search.py'))
        search.SearchDialog.DEBOUNCE = 0.02
        yield types.SimpleNamespace(search=search, server=server, store=store)


@pytest.fixture
def dialog(env):
    env.server.calls[:] = []
    env.server.answer = []
    env.server.fail = False
    env.server.delay = 0
    env.store.clear()
    d = env.search.SearchDialog(parent_window=types.SimpleNamespace(setProperty=lambda k, v: None))
    d.onFirstInit()
    yield d
    d.isActive = False


def wait_until(predicate, timeout=5.0):
    start = time.time()
    while not predicate():
        if time.time() - start > timeout:
            raise AssertionError('timed out')
        time.sleep(0.01)


def settled(d):
    wait_until(lambda: not d._resultsRunning and not d.props.get('searching'))


MOVIES = lambda: Hub('movie', 'Movies', [Item('movie', title='Dune', year='2021', thumb='/t/1'),
                                          Item('movie', title='Arrival', year='2016')])
ACTORS = lambda: Hub('actor', 'Actors', [Item('Role', tag='Zendaya', thumb='/p/1'), Item('Role', tag='Nobody')])
DIRECTORS = lambda: Hub('director', 'Directors', [Item('Director', tag='Denis')])
GENRES = lambda: Hub('genre', 'Genres', [Item('Genre', tag='Drama')])
ALBUMS = lambda: Hub('album', 'Albums', [Item('album', title='Discovery', parentTitle='Daft Punk', thumb='/a/1')])
ODD = lambda: Hub('mystery', 'Odd', [Item('movie', title='x')])
EMPTY = lambda: Hub('show', 'Shows', [])


def hub_titles(d, n=6):
    return [d.props.get('hub.%d' % (2100 + i), '') for i in range(n)]


def test_starts_idle_with_focus_on_the_keyboard(dialog):
    assert dialog.props['search.section'] == 'all'
    assert dialog.props['search.has.query'] == ''
    assert dialog.props['show.history'] == ''
    assert dialog.focus == 1001


def test_results_are_contiguous_shelves_with_icons_and_chips(dialog, env):
    env.server.answer = [MOVIES(), ODD(), ACTORS(), EMPTY(), GENRES(), DIRECTORS()]
    dialog.letterClicked(1004)
    dialog.letterClicked(1021)
    assert dialog.props['search.has.query'] == '1'
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    settled(dialog)
    assert env.server.calls == ['du']  # the debounce coalesced both letters
    assert hub_titles(dialog) == ['Movies', 'Actors', 'Genres', 'Directors', '', '']
    assert [dialog.props['hub.display.%d' % i] for i in range(2100, 2104)] == ['poster', 'circle', 'circle', 'circle']
    assert dialog.props['hub.icon.2100'].endswith('icons/movie.png')
    assert dialog.props['hub.icon.2101'].endswith('icons/person.png')
    assert dialog.props['hub.icon.2102'].endswith('icons/hub_genre.png')
    assert dialog.props['hub.text2lines.2100'] == '1'
    assert dialog.props['no.results'] == ''
    assert dialog.props['search.chips'] == '1'
    assert (dialog.props['search.kind.movie'], dialog.props['search.kind.people'],
            dialog.props['search.kind.show']) == ('1', '1', '')


def test_cards_follow_plezy_titles_and_artwork_sizes(dialog, env):
    env.server.answer = [MOVIES(), ACTORS(), GENRES()]
    dialog.letterClicked(1004)
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    settled(dialog)
    dune = dialog.hubControls[0].items[0]
    assert (dune.label, dune.label2, dune.thumb) == ('Dune', '2021', 'img:///t/1/244x361')
    assert dune.props['unwatched'] == '1'
    zendaya = dialog.hubControls[1].items[0]
    assert (zendaya.label, zendaya.label2, zendaya.thumb) == ('Zendaya', 'Actor', 'img:///p/1/244x244')
    assert zendaya.props['glyph'].endswith('icons/person.png')
    drama = dialog.hubControls[2].items[0]
    assert drama.thumb == '' and drama.props['glyph'].endswith('icons/hub_genre.png')


def test_every_card_type_builds(dialog):
    class Track(Item):
        defaultThumb = Value('/trk')
    cases = [
        ('movie', 'poster', dict(title='M', year='2020')), ('show', 'poster', dict(title='S')),
        ('season', 'poster', dict(title='Season 1', parentTitle='S')),
        ('episode', 'ar16x9', dict(title='E', grandparentTitle='S', parentIndex='1', index='2')),
        ('clip', 'ar16x9', dict(title='C')), ('artist', 'square', dict(title='A')),
        ('album', 'square', dict(title='Al', parentTitle='A')),
        ('photo', 'square', dict(title='P', originallyAvailableAt='2020-02-03')),
        ('photodirectory', 'square', dict(title='PD', composite='/c')),
        ('playlist', 'square', dict(tag='Pl', composite='/c', playlistType='audio')),
        ('collection', 'poster', dict(title='Coll')), ('Role', 'circle', dict(tag='R')),
        ('Director', 'circle', dict(tag='D')), ('Genre', 'circle', dict(tag='G')),
    ]
    for kind, display, attrs in cases:
        assert dialog.createListItem(Item(kind, **attrs), display).label
    track = dialog.createListItem(Track('track', title='T', grandparentTitle='Artist'), 'square')
    assert (track.label, track.label2, track.thumb) == ('T', 'Artist', 'img:///trk/244x244')
    episode = dialog.createListItem(Item('episode', title='Pilot', grandparentTitle='Severance', parentIndex='1',
                                         index='2'), 'ar16x9')
    assert (episode.label, episode.label2) == ('Severance', u'S1E2 \xb7 Pilot')


def test_chip_click_filters_the_answer_without_a_request(dialog, env):
    env.server.answer = [MOVIES(), ACTORS(), DIRECTORS()]
    dialog.letterClicked(1004)
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    settled(dialog)
    calls = len(env.server.calls)
    dialog.focus = 906
    dialog.sectionClicked(906)
    assert len(env.server.calls) == calls
    assert dialog.props['search.section'] == 'people'
    assert hub_titles(dialog, 3) == ['Actors', 'Directors', '']
    assert dialog.focus == 906
    dialog.sectionClicked(901)
    assert hub_titles(dialog, 4) == ['Movies', 'Actors', 'Directors', '']


def test_selected_kind_falls_back_to_all_and_focus_follows(dialog, env):
    env.server.answer = [MOVIES(), ACTORS()]
    dialog.letterClicked(1004)
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    settled(dialog)
    dialog.focus = 906
    dialog.sectionClicked(906)
    env.server.answer = [MOVIES(), ALBUMS()]  # the next answer has no people
    dialog.focus = 906
    dialog.letterClicked(1005)
    wait_until(lambda: env.server.calls[-1] == 'de')
    settled(dialog)
    assert dialog.props['search.section'] == 'all'
    assert dialog.props['search.kind.people'] == '' and dialog.props['search.kind.artist'] == '1'
    assert dialog.focus == 901


def test_no_chips_for_a_single_kind_and_focus_leaves_a_vanished_chip(dialog, env):
    env.server.answer = [MOVIES()]
    dialog.focus = 902
    dialog.letterClicked(1004)
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    settled(dialog)
    assert dialog.props['search.chips'] == ''
    assert dialog.focus == 650


def test_back_clears_the_field_before_it_closes(dialog, env):
    env.server.answer = [MOVIES(), ACTORS()]
    dialog.letterClicked(1004)
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    settled(dialog)
    dialog.focus = 650
    dialog.updateFromEdit(ACTION_NAV_BACK, 'd', 'd')
    assert dialog.edit.getText() == '' and not dialog.closed
    assert dialog.props['search.has.query'] == ''
    assert dialog.props['hub.display.2100'] == '' and dialog._idleShown  # the old results are gone at once
    dialog.updateFromEdit(ACTION_NAV_BACK, '', '')
    assert dialog.closed and dialog.isActive is False


def test_escape_closes_even_with_text(dialog):
    dialog.edit.setText('abc')
    dialog.updateFromEdit(ACTION_PREVIOUS_MENU, 'abc', 'abc')
    assert dialog.closed


def test_typing_unchanged_text_does_not_search_again(dialog, env):
    dialog.edit.setText('abc')
    dialog.updateFromEdit(0, 'abc', 'abc')
    time.sleep(0.1)
    assert env.server.calls == []


def test_clear_button_empties_the_field_and_keeps_it_focused(dialog, env):
    env.server.answer = [MOVIES()]
    dialog.edit.setText('abc')
    dialog.updateQuery(0)
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    dialog.onClick(999)
    assert dialog.edit.getText() == '' and dialog.focus == 650 and dialog.props['search.has.query'] == ''


def test_no_results_and_error_states(dialog, env):
    env.server.answer = []
    dialog.edit.setText('zzz')
    dialog.updateQuery(0)
    wait_until(lambda: dialog.props.get('no.results') == '1')
    settled(dialog)
    assert dialog.props['search.chips'] == '' and dialog.props['search.error'] == ''

    env.server.fail = True
    dialog.edit.setText('boom')
    dialog.updateQuery(0)
    wait_until(lambda: dialog.props.get('search.error') == '1')
    settled(dialog)
    assert dialog.props['no.results'] == '' and not dialog.props.get('searching')
    env.server.fail = False
    env.server.answer = [MOVIES()]
    dialog.edit.setText('fine')
    dialog.updateQuery(0)  # the thread survived the failure
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    assert dialog.props['search.error'] == ''


def test_typing_during_a_request_is_not_lost(dialog, env):
    env.server.answer = [MOVIES()]
    env.server.delay = 0.3
    dialog.edit.setText('a')
    dialog.updateQuery(0)
    wait_until(lambda: env.server.calls == ['a'])
    dialog.edit.setText('ab')
    dialog.updateQuery(0)
    wait_until(lambda: env.server.calls == ['a', 'ab'])
    settled(dialog)
    assert dialog._hubsCache[0] == 'ab' and dialog.cachedHubs() is not None


def test_stale_answer_is_not_shown(dialog, env):
    env.server.answer = [MOVIES()]
    env.server.delay = 0.3
    dialog.edit.setText('a')
    dialog.updateQuery(0)
    wait_until(lambda: env.server.calls == ['a'])
    dialog.edit.setText('')
    dialog.updateQuery()
    settled(dialog)
    assert dialog.props.get('hub.display.2100', '') == '' and dialog._idleShown


def test_search_key_focuses_the_first_result(dialog, env):
    env.server.answer = [MOVIES()]
    dialog.edit.setText('q')
    dialog.focus = 954
    dialog.onClick(954)  # nothing fetched yet: it focuses when the answer arrives
    wait_until(lambda: dialog.focus == 2100)
    dialog.focus = 954
    dialog.onClick(954)  # fetched: at once
    assert dialog.focus == 2100


def test_search_key_ignores_an_empty_field(dialog):
    dialog.focus = 954
    dialog.onClick(954)
    assert dialog.focus == 954


def test_history_rows_use_plezy_icons_and_a_pick_searches_right_away(dialog, env):
    env.store['search.history.cafebabe.1'] = json.dumps(['dune', 'arrival'])
    env.server.answer = [MOVIES()]
    dialog.showSearchHistory()
    assert dialog.props['show.history'] == '1' and len(dialog.historyList.items) == 3
    assert dialog.historyList.items[0].props['icon'].endswith('icons/history.png')
    assert dialog.historyList.items[2].props['icon'].endswith('icons/clear_all.png')
    dialog.focus = 2050
    dialog.historyItemClicked()
    wait_until(lambda: dialog.props.get('hub.display.2100') and dialog.focus == 2100)
    assert dialog.props['show.history'] == '' and env.server.calls == ['dune']
    dialog.focus = 2100
    dialog.edit.setText('')
    dialog.updateQuery()
    assert dialog.props['show.history'] == '1' and dialog.focus == 2050  # focus did not fall with the results


def test_reinit_rerenders_results_or_history(dialog, env):
    env.server.answer = [MOVIES()]
    dialog.edit.setText('abc')
    dialog.onReInit()
    wait_until(lambda: dialog.props.get('hub.display.2100'))
    dialog.edit.setText('')
    dialog.onReInit()
    assert dialog._idleShown and dialog.props['search.has.query'] == ''
