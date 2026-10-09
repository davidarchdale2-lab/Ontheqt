# coding=utf-8
"""
Behaviour of script.plezy.native's lib/windows/userselect.py (the Plezy profile switcher) and the PIN sign-in window of
lib/windows/signin.py with the Kodi modules stubbed out: the properties each profile tile needs, how the PIN dialog's boxes
follow the entered digits, the "switching" overlay, a wrong PIN (message, no modal dialog, cursor back on '1') and the
Cancel button of the link-code window. Run: python3 -m pytest kodi/tests
"""
import importlib.util
import os
import sys
import types
from unittest import mock

import pytest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, '..', 'script.plezy.native')

ACTION_NAV_BACK = 92
ACTION_PREVIOUS_MENU = 10
ACTION_BACKSPACE = 110
ACTION_SELECT_ITEM = 7


class UserSwitchForbiddenException(Exception):
    pass


class User(dict):
    """plexnet's HomeUser: a dict whose attributes read its keys (None when absent)."""

    def __getattr__(self, attr):
        return self.get(attr)


class ManagedListItem(object):
    def __init__(self, label='', label2='', thumbnailImage='', data_source=None, properties=None):
        self.label, self.label2, self.thumb, self.dataSource = label, label2, thumbnailImage, data_source
        self.props = dict(properties or {})

    def setProperty(self, key, value):
        self.props[key] = value

    def getProperty(self, key):
        return self.props.get(key, '')


class EmptyDataSource(object):
    title = ''
    isProtected = False

    def __bool__(self):
        return False

    __nonzero__ = __bool__


class ManagedControlList(object):
    def __init__(self, win, control_id, max_view_index):
        self.controlID = control_id
        self.items = []
        self.selected = 0

    def reset(self):
        self.items = []

    def addItems(self, items):
        self.items.extend(items)

    def getSelectedItem(self):
        return self.items[self.selected] if self.items else None

    def setSelectedItemByPos(self, pos):
        self.selected = pos


class BaseWindow(object):
    @classmethod
    def create(cls, **kwargs):
        return cls()

    def __init__(self, *args, **kwargs):
        self.props = {}
        self.focus = 101
        self.closed = False

    def setProperty(self, key, value):
        self.props[key] = value

    def getProperty(self, key):
        return self.props.get(key, '')

    def setFocusId(self, control_id):
        self.focus = control_id

    def onAction(self, action):
        pass

    def doClose(self, **kwargs):
        self.closed = True


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


class Env(object):
    pass


@pytest.fixture(scope='module')
def env():
    """userselect.py and signin.py imported against stubbed Kodi modules; sys.modules is restored afterwards."""
    e = Env()
    e.messages = []
    e.visible = {}
    with mock.patch.dict(sys.modules):
        xbmcgui = _module('xbmcgui', ACTION_NAV_BACK=ACTION_NAV_BACK, ACTION_PREVIOUS_MENU=ACTION_PREVIOUS_MENU,
                          ACTION_BACKSPACE=ACTION_BACKSPACE, ACTION_SELECT_ITEM=ACTION_SELECT_ITEM)
        xbmc = _module('xbmc', getCondVisibility=lambda cond: e.visible.get(cond, False),
                       executebuiltin=lambda command: None)
        _module('kodi_six', xbmcgui=xbmcgui, xbmc=xbmc)

        class Account(object):
            ID = '1'
            homeUsers = []
            switchUser = True
            result = True
            raises = None

            @classmethod
            def safeUserThumb(cls, user_id, thumb=''):
                return thumb

            @classmethod
            def switchHomeUser(cls, user_id, pin=None):
                e.switched = (user_id, pin)
                if cls.raises:
                    raise cls.raises
                return cls.result

            @classmethod
            def updateHomeUsers(cls, **kwargs):
                e.updated = True
        e.account = Account
        plexapp = _module('plexnet.plexapp', ACCOUNT=Account, util=types.SimpleNamespace(APP=object()))
        _module('plexnet', plexapp=plexapp)
        _module('plexnet.exceptions', UserSwitchForbiddenException=UserSwitchForbiddenException)

        util = _module(
            'lib.util', T=lambda ID, eng='': eng, ERROR=lambda *a, **k: None, DEBUG_LOG=lambda *a, **k: None,
            getSetting=lambda key, default=None: default,
            vscalei=lambda value: int(value),
            ADDON=types.SimpleNamespace(getAddonInfo=lambda key: '/x'),
            messageDialog=lambda *a: e.messages.append(a))
        lib = _module('lib', util=util, __path__=[os.path.join(ROOT, 'lib')])
        lib.plezy_profiles = _load('lib.plezy_profiles', os.path.join(ROOT, 'lib', 'plezy_profiles.py'))

        class CallbackEvent(object):
            def __init__(self, *args, **kwargs):
                self.closed = False

            def __enter__(self):
                return self

            def __exit__(self, *args):
                return False

            def close(self):
                self.closed = True
        lib.plex = _module('lib.plex', CallbackEvent=CallbackEvent)

        windows = _module('lib.windows', __path__=[os.path.join(ROOT, 'lib', 'windows')])
        kodigui = _module('lib.windows.kodigui', BaseWindow=BaseWindow, ManagedListItem=ManagedListItem,
                          ManagedControlList=ManagedControlList, EmptyDataSource=EmptyDataSource)
        windows.kodigui = kodigui
        windows.busy = _module('lib.windows.busy', dialog=lambda *a, **k: (lambda func: func))
        windows.dropdown = _module('lib.windows.dropdown')
        e.userselect = _load('lib.windows.userselect', os.path.join(ROOT, 'lib', 'windows', 'userselect.py'))
        e.signin = _load('lib.windows.signin', os.path.join(ROOT, 'lib', 'windows', 'signin.py'))
        yield e


def make_user(user_id, title, **kwargs):
    return User(id=user_id, title=title, thumb='', isAdmin=kwargs.get('admin', False),
                isProtected=kwargs.get('protected', False), isManaged=kwargs.get('managed', False))


@pytest.fixture
def win(env):
    env.messages[:] = []
    env.visible.clear()
    env.switched = None
    env.account.ID = '2'
    env.account.result = True
    env.account.switchUser = True
    env.account.raises = None
    env.account.homeUsers = [make_user('1', 'Alex', admin=True), make_user('2', 'Maria'),
                             make_user('3', 'Sam', protected=True), make_user('4', 'Kids', managed=True)]
    w = env.userselect.UserSelectWindow()
    w.userList = ManagedControlList(w, 101, 6)
    w.start()
    return w


def test_tile_properties(win):
    items = win.userList.items
    assert [i.props['group.pos'] for i in items[:4]] == ['first', 'middle', 'middle', 'last']
    assert [i.label2 for i in items[:4]] == ['A', 'M', 'S', 'K']
    pp = sys.modules['lib'].plezy_profiles
    assert [i.props['avatar.color'] for i in items[:4]] == [pp.color_for_name(n) for n in ('Alex', 'Maria', 'Sam', 'Kids')]
    assert all(len(i.props['avatar.color']) == 8 for i in items[:4])
    assert [i.props['active'] for i in items[:4]] == ['', '1', '', '']
    assert [i.props['protected'] for i in items[:4]] == ['', '', '1', '']
    assert items[0].props['meta'] == u'Administrator'
    assert items[1].props['meta'] == u'Active • Home user'
    assert items[2].props['meta'] == u'Home user • PIN protected'
    assert items[3].props['meta'] == u'Managed user'
    assert all(i.props['pin.len'] == '0' for i in items[:4])


def test_refresh_row_is_last_and_untouched(win):
    last = win.userList.items[-1]
    assert last.props == {'empty': '1'}
    assert not last.dataSource


def test_active_user_is_preselected_and_window_ready(win):
    assert win.userList.selected == 1
    assert win.focus == 101
    assert win.props['initialized'] == '1'
    assert win.props['busy'] == ''


def test_single_user_is_an_only_tile(env):
    env.account.homeUsers = [make_user('1', 'Solo')]
    w = env.userselect.UserSelectWindow()
    w.userList = ManagedControlList(w, 101, 6)
    w.start()
    assert w.userList.items[0].props['group.pos'] == 'only'


def test_untitled_user_does_not_break_the_list(env):
    env.account.homeUsers = [make_user('1', None)]
    w = env.userselect.UserSelectWindow()
    w.userList = ManagedControlList(w, 101, 6)
    w.start()
    assert w.userList.items[0].label2 == '?'
    assert w.userList.items[0].props['avatar.color'] == 'FFEDEDED'


def pin_item(win):
    win.userList.selected = 2
    return win.userList.getSelectedItem()


def test_pin_boxes_follow_the_digits(win):
    item = pin_item(win)
    for expected, key in ((1, 201), (2, 205), (3, 210)):
        win.pinEntryClicked(key)
        assert item.props['pin.len'] == str(expected)
    assert item.props['editing.pin'] == '150'
    win.pinEntryClicked(211)
    assert item.props['pin.len'] == '2'
    win.pinEntryClicked(211)
    win.pinEntryClicked(211)
    assert item.props['pin.len'] == '0'
    assert item.props['editing.pin'] == ''
    assert item.props['pin'] == 'Sam'


def test_new_digit_clears_the_error(win):
    item = pin_item(win)
    win.setProperty('pin.error', 'Wrong pin entered!')
    win.pinEntryClicked(204)
    assert win.props['pin.error'] == ''
    assert item.props['pin.len'] == '1'


def test_fourth_digit_submits_the_pin(win):
    item = pin_item(win)
    calls = []
    win.userSelected = lambda it, pin=None: calls.append((it, pin))
    for key in (201, 202, 203, 204):
        win.pinEntryClicked(key)
    assert calls == [(item, '1234')]
    assert item.props['pin.len'] == '4'


def test_refocusing_the_list_resets_the_pin(win):
    item = pin_item(win)
    win.pinEntryClicked(201)
    win.setProperty('pin.error', 'Wrong pin entered!')
    win.onFocus(101)
    assert item.props['editing.pin'] == ''
    assert item.props['pin.len'] == '0'
    assert win.props['pin.error'] == ''


def test_wrong_pin_keeps_the_dialog_and_shows_the_error(env, win):
    env.account.result = False
    item = pin_item(win)
    win.focus = 205
    for key in (201, 202, 203, 204):
        win.pinEntryClicked(key)
    assert env.switched == ('3', '1234')
    assert win.props['pin.error'] == 'Wrong pin entered!'
    assert item.props['pin.len'] == '0'
    assert item.props['editing.pin'] == ''
    assert win.focus == 400
    assert win.props['switching'] == ''
    assert env.messages == []
    assert not win.closed


def test_failed_switch_without_a_pin_still_uses_the_message_dialog(env, win):
    env.account.result = False
    win.userSelected(win.userList.items[0])
    assert len(env.messages) == 1
    assert win.props['switching'] == ''
    assert win.getProperty('pin.error') == ''
    assert not win.closed


def test_successful_switch_keeps_the_overlay_until_the_window_closes(env, win):
    win.userSelected(win.userList.items[0])
    assert env.switched == ('1', None)
    assert win.selected is True
    assert win.closed
    assert win.props['switching'] == '1'


def test_switch_forbidden_asks_for_a_retry(env, win):
    env.account.raises = UserSwitchForbiddenException()
    win.userSelected(win.userList.items[0])
    assert win.selected == 'retry'
    assert win.closed
    assert env.updated


def test_switching_overlay_is_up_while_the_switch_runs(env, win):
    seen = []
    original = env.account.switchHomeUser
    env.account.switchHomeUser = classmethod(lambda cls, user_id, pin=None: seen.append(win.props.get('switching')) or True)
    try:
        win.userSelected(win.userList.items[0])
    finally:
        env.account.switchHomeUser = original
    assert seen == ['1']


class Action(object):
    def __init__(self, action_id):
        self.id = action_id

    def getId(self):
        return self.id


def test_pin_login_window_publishes_the_code(env):
    w = env.signin.PinLoginWindow()
    w.setPin('k7wb')
    assert [w.props['pin.char.%d' % i] for i in range(4)] == ['K', '7', 'W', 'B']
    assert w.props['pin.image.0'] == 'script.plex/sign_in/digits/K.png'
    w.setLinking()
    assert w.props['linking'] == '1'
    assert [w.props['pin.image.%d' % i] for i in range(4)] == [''] * 4
    assert [w.props['pin.char.%d' % i] for i in range(4)] == [''] * 4


def test_pin_login_cancel_button_aborts(env):
    w = env.signin.PinLoginWindow()
    assert env.signin.PinLoginWindow.CANCEL_BUTTON_ID == 102
    w.onClick(999)
    assert not w.abort
    w.onClick(102)
    assert w.abort


def test_pin_login_back_aborts(env):
    w = env.signin.PinLoginWindow()
    w.onAction(ACTION_NAV_BACK)
    assert w.abort
