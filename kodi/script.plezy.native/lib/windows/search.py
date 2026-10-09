from __future__ import absolute_import

import json
import threading
import time

from kodi_six import xbmcgui, xbmc
from plexnet import plexapp

from lib import util
from lib import plezy_search
from lib.util import T
from lib.kodijsonrpc import rpc
from . import kodigui
from . import opener
from . import optionsdialog
from . import windowutils


class HistoryItem(object):
    TYPE = 'history'

    def __init__(self, query, is_clear=False):
        self.query = query
        self.title = query
        self.is_clear = is_clear


class SearchDialog(kodigui.BaseDialog, windowutils.UtilMixin):
    xmlFile = 'script-plex-search.xml'
    path = util.ADDON.getAddonInfo('path')
    theme = 'Main'
    res = '1080i'
    width = 1920
    height = 1080

    LETTERS = 'abcdefghijklmnopqrstuvwxyz0123456789 '
    # chips: All, Movies, Shows, Music, Photos, People (templates/script-plex-search.xml.tpl, grouplist 900)
    SECTION_BUTTONS = plezy_search.SECTION_BUTTONS

    EDIT_CONTROL_ID = 650
    CLEAR_BUTTON_ID = 999  # the field's clear (x) button
    SEARCH_KEY_ID = 954  # the keyboard's search key
    BUTTON_A_ID = 1001
    SEARCH_HUB_COUNT = 12  # must match core.search_hub_count in lib/templating/context.py
    HISTORY_LIST_ID = 2050
    MAX_HISTORY_ITEMS = 10
    DEBOUNCE = 0.5  # Plezy's searchDebounceDuration
    CURSOR = u'[COLOR FFEDEDED]|[/COLOR]'  # the field's caret in Plezy's text colour (core.plezy.text), not PM4K orange

    # hub type -> card shape; includes/search_hub_*.xml.tpl draw the four shapes
    HUBMAP = dict((hub_type, {'type': display}) for hub_type, display in plezy_search.HUB_DISPLAY.items())

    # artwork size per card shape, as home's rows request it (the cards show them at 200x300, 400x225, 200x200)
    THUMB_DIM = {
        'poster': util.scaleResolution(244, 361),
        'ar16x9': util.scaleResolution(532, 299),
        'square': util.scaleResolution(244, 244),
        'circle': util.scaleResolution(244, 244),
    }

    def __init__(self, *args, **kwargs):
        kodigui.BaseDialog.__init__(self, *args, **kwargs)
        windowutils.UtilMixin.__init__(self)
        self.parentWindow = kwargs.get('parent_window')
        self.sectionID = kwargs.get('section_id')
        self.resultsThread = None
        self.updateResultsTimeout = 0
        self.isActive = True
        self.useKodiKbd = util.getSetting('search_use_kodi_kbd')
        self._resultsLock = threading.Lock()  # guards the search thread's bookkeeping
        self._resultsDirty = False  # the field changed since the last search started
        self._resultsRunning = False  # a search thread is alive
        self._showLock = threading.RLock()  # showHubs runs on the search thread and, for a chip click, the UI thread
        self._hubsCache = None  # (query, hubs) of the last answer, so a chip can re-filter it without a request
        self._focusFirstResult = False  # the keyboard's search key was pressed: focus the first result on arrival
        self._idleShown = False  # the history / idle state is what the window shows (the field is empty)

    def onFirstInit(self):
        self.hubControls = [
            kodigui.ManagedControlList(self, 2100 + i, 5)
            for i in range(self.SEARCH_HUB_COUNT)
        ]
        self.historyList = kodigui.ManagedControlList(self, self.HISTORY_LIST_ID, self.MAX_HISTORY_ITEMS + 1)

        self.edit = kodigui.SafeControlEdit(self.EDIT_CONTROL_ID, 651, self, key_callback=self.updateFromEdit,
                                            grab_focus=True)
        # Plezy's caret is the text colour. SafeControlEdit reads self.CURSOR when it draws the label.
        self.edit.CURSOR = self.CURSOR
        self.edit.updateLabel()
        self.edit.setCompatibleMode(rpc.Application.GetProperties(properties=["version"])["version"]["major"] < 17)
        if self.useKodiKbd:
            self.setProperty('hide.kbd', '1')
            self.setFocusId(self.EDIT_CONTROL_ID)
            xbmc.executebuiltin('Action(Select,{0})'.format(self._winID))
        else:
            self.setFocusId(self.BUTTON_A_ID)
        self.setProperty('search.section', 'all')
        self.setProperty('search.has.query', '')
        self.showSearchHistory()

    def onReInit(self):
        # Re-displayed (e.g. returning from an opened result): re-evaluate the view.
        # onFirstInit only runs on the first init, so without this the history view
        # never re-renders after the dialog is shown again.
        if self.edit.getText():
            self.setProperty('search.has.query', '1')
            self.updateResults(0)
        else:
            self.setProperty('search.has.query', '')
            self.showSearchHistory()

    def onAction(self, action):
        try:
            if action in (xbmcgui.ACTION_NAV_BACK, xbmcgui.ACTION_PREVIOUS_MENU):
                self.isActive = False
        except:
            util.ERROR()

        kodigui.BaseDialog.onAction(self, action)

    def onClick(self, controlID):
        if 1000 < controlID < 1037:
            self.letterClicked(controlID)
        elif controlID in self.SECTION_BUTTONS:
            self.sectionClicked(controlID)
        elif controlID == 951:
            self.deleteClicked()
        elif controlID == 952:
            self.letterClicked(1037)
        elif controlID == 953:
            self.clearClicked()
        elif controlID == self.SEARCH_KEY_ID:
            self.submitClicked()
        elif controlID == self.CLEAR_BUTTON_ID:
            # the field's x: Plezy clears the text and keeps the field focused
            self.clearClicked()
            self.setFocusId(self.EDIT_CONTROL_ID)
        elif 2099 < controlID < 2200:
            self.hubItemClicked(controlID)
        elif controlID == self.HISTORY_LIST_ID:
            self.historyItemClicked()

    def onFocus(self, controlID):
        if 2099 < controlID < 2200:
            self.setProperty('hub.focus', str(controlID - 2100))

    def updateFromEdit(self, actionID, oldVal, newVal):
        if actionID == xbmcgui.ACTION_PREVIOUS_MENU:
            self.isActive = False
            self.doClose()
            return

        if actionID == xbmcgui.ACTION_NAV_BACK:
            # Plezy: Back in the field clears the text first and only then leaves
            if self.edit.getText():
                self.clearClicked()
            else:
                self.isActive = False
                self.doClose()
            return

        if oldVal != newVal:
            self.updateQuery()

    def updateQuery(self, delay=None, focusFirst=False):
        # drives the hint, the clear button, the chips and the idle state of the template
        text = self.edit.getText()
        self.setProperty('search.has.query', text and '1' or '')
        self._focusFirstResult = bool(focusFirst and text)
        if text:
            self.updateResults(delay)
        elif not self._idleShown:
            # an emptied field has nothing to wait for: the history (or the idle message) replaces the results at once
            self._hubsCache = None
            self.showSearchHistory()

    def updateResults(self, delay=None):
        """Search for the field's text once typing pauses (Plezy debounces by 500ms); delay 0 searches now."""
        with self._resultsLock:
            self.updateResultsTimeout = time.time() + (self.DEBOUNCE if delay is None else delay)
            self._resultsDirty = True
            if self._resultsRunning:
                return  # the running thread notices the field changed and searches again
            self._resultsRunning = True
            self.resultsThread = threading.Thread(target=self._updateResults, name='search.update')
            self.resultsThread.start()

    def _updateResults(self):
        try:
            while self.isActive:
                while time.time() < self.updateResultsTimeout and not util.MONITOR.waitForAbort(0.1):
                    pass

                with self._resultsLock:
                    self._resultsDirty = False

                try:
                    self._reallyUpdateResults()
                except Exception:
                    util.ERROR()

                with self._resultsLock:
                    if not self._resultsDirty:
                        self._resultsRunning = False
                        return
        finally:
            with self._resultsLock:
                self._resultsRunning = False

    def _reallyUpdateResults(self):
        query = self.edit.getText()
        if query:
            with self.propertyContext('searching'):
                self.setProperty('search.error', '')
                try:
                    hubs = list(plexapp.SERVERMANAGER.selectedServer.hubs(count=10, search_query=query,
                                                                           section=self.sectionID))
                except Exception:
                    util.ERROR()
                    self._hubsCache = None
                    with self._showLock:
                        self.clearHubs()
                        self._idleShown = False
                        self.setProperty('search.error', '1')
                    return
                if query != self.edit.getText():
                    return  # typed on meanwhile: the next pass searches for that
                self._hubsCache = (query, hubs)
                self.showHubs(hubs)
        else:
            self._hubsCache = None
            if not self._idleShown:
                self.showSearchHistory()

    def cachedHubs(self):
        """The last answer if it is for what the field says now, else None."""
        cache = self._hubsCache
        if cache and cache[0] == self.edit.getText():
            return cache[1]
        return None

    def sectionClicked(self, controlID):
        section = self.SECTION_BUTTONS[controlID]
        old = self.getProperty('search.section')
        if old == section:
            return
        self.setProperty('search.section', section)
        # a chip filters what was already fetched: no new request
        hubs = self.cachedHubs()
        if hubs is not None:
            self.showHubs(hubs)
        else:
            self.updateResults(0)

    def submitClicked(self):
        """The keyboard's search key: submit now and focus the first result as soon as it is there (Plezy)."""
        if not self.edit.getText():
            return
        hubs = self.cachedHubs()
        if hubs is not None and not self._resultsDirty:
            self.focusResults()
            return
        self._focusFirstResult = True
        self.updateResults(0)

    def focusResults(self):
        for control in self.hubControls:
            if control.size() > 0:
                self.setFocusId(control.controlID)
                return True
        return False

    def letterClicked(self, controlID):
        letter = self.LETTERS[controlID - 1001]
        self.edit.append(letter)
        self.updateQuery()

    def deleteClicked(self):
        self.edit.delete()
        self.updateQuery()

    def clearClicked(self):
        self.edit.setText('')
        self.updateQuery()

    def _historyKey(self):
        server = plexapp.SERVERMANAGER.selectedServer
        if not server:
            return None
        return 'search.history.{0}.{1}'.format(server.uuid[-8:], plexapp.ACCOUNT.ID)

    def loadSearchHistory(self):
        key = self._historyKey()
        if not key:
            return []
        try:
            return json.loads(util.getSetting(key, '[]'))[:self.MAX_HISTORY_ITEMS]
        except Exception:
            util.ERROR()
            return []

    def saveSearchHistory(self, history):
        key = self._historyKey()
        if not key:
            return
        try:
            util.setSetting(key, json.dumps(history[:self.MAX_HISTORY_ITEMS]))
        except Exception:
            util.ERROR()

    def addToHistory(self, title):
        if not title or not title.strip():
            return
        title = title.strip()
        history = self.loadSearchHistory()
        if title in history:
            history.remove(title)
        history.insert(0, title)
        self.saveSearchHistory(history)

    def clearSearchHistory(self):
        key = self._historyKey()
        if key:
            try:
                util.setSetting(key, '[]')
            except Exception:
                util.ERROR()

    def showSearchHistory(self):
        with self._showLock:
            fid = self.focusId()
            self.clearHubs()
            self._idleShown = True
            history = self.loadSearchHistory()
            if not history:
                self.setProperty('show.history', '')
                self.restoreFocus(fid, 0)
                return
            items = []
            for query in history:
                mli = kodigui.ManagedListItem(query, data_source=HistoryItem(query))
                mli.setProperty('icon', plezy_search.HISTORY_ICON)
                items.append(mli)
            clear_label = T(35005, 'Clear search history')
            clear_mli = kodigui.ManagedListItem(clear_label, data_source=HistoryItem(clear_label, is_clear=True))
            clear_mli.setProperty('icon', plezy_search.CLEAR_ICON)
            items.append(clear_mli)
            self.historyList.reset()
            self.historyList.addItems(items)
            self.setProperty('show.history', '1')
            self.restoreFocus(fid, 0)

    def historyItemClicked(self):
        mli = self.historyList.getSelectedItem()
        if not mli:
            return
        item = mli.dataSource
        if getattr(item, 'is_clear', False):
            button = optionsdialog.show(
                T(35005, 'Clear search history'),
                T(35006, 'Clear all search history?'),
                T(32328, 'Yes'),
                T(32329, 'No'),
            )
            if button == 0:
                self.clearSearchHistory()
                self.showSearchHistory()
            return
        self.edit.setText(item.query)
        self.updateQuery(0, focusFirst=True)  # Plezy submits a picked query: the first result takes focus on arrival

    def hubItemClicked(self, hubControlID):
        for control in self.hubControls:
            if control.controlID == hubControlID:
                break
        else:
            return

        mli = control.getSelectedItem()
        if not mli:
            return

        hubItem = mli.dataSource
        if hubItem.TYPE == 'playlist' and not hubItem.exists():  # Workaround for server bug
            util.messageDialog('No Access', 'Playlist not accessible by this user.')
            util.DEBUG_LOG('Search: Playlist does not exist - probably wrong user')
            return

        self.addToHistory(self.edit.getText())
        self.doClose()
        try:
            command = opener.open(hubItem)

            if not hubItem.exists():
                control.removeManagedItem(mli)

            self.processCommand(command)
        finally:
            if not self.exitCommand:
                self.show()
            else:
                self.isActive = False

    def roleLabels(self):
        return {'Role': T(32384, 'Actor'), 'Director': T(32383, 'Director')}

    def createListItem(self, hubItem, display='poster'):
        """
        One card. Title and subtitle follow Plezy's displayTitle / displaySubtitle (plezy_search.card_texts); artwork is
        requested at the card's shape. Everything comes from the hub answer, never from a request of its own.
        """
        kind = hubItem.TYPE
        w, h = self.THUMB_DIM.get(display, self.THUMB_DIM['poster'])

        which = plezy_search.thumb_kind(kind)
        if which == 'composite':
            source = hubItem.get('composite')
        elif which == 'default':
            source = hubItem.defaultThumb
        elif which == 'thumb':
            source = hubItem.get('thumb')
        else:
            source = None
        thumb = source.asTranscodedImageURL(w, h) if source else ''

        label, label2 = plezy_search.card_texts(hubItem, T(32310, 'S{}'), T(32311, 'E{}'), self.roleLabels())
        mli = kodigui.ManagedListItem(label, label2, thumbnailImage=thumb, data_source=hubItem)

        if kind in ('Role', 'Director'):
            mli.setProperty('glyph', plezy_search.PERSON_ICON)
        elif kind == 'Genre':
            mli.setProperty('glyph', plezy_search.GENRE_ICON)
        elif kind == 'playlist':
            mli.setProperty('thumb.fallback', 'script.plex/thumb_fallbacks/{0}.png'.format(
                hubItem.playlistType == 'audio' and 'music' or 'movie'))
        elif kind == 'photodirectory':
            mli.setProperty('thumb.fallback', 'script.plex/thumb_fallbacks/photo.png')
        elif kind in ('movie', 'clip', 'collection'):
            mli.setProperty('thumb.fallback', 'script.plex/thumb_fallbacks/movie.png')
        elif kind in ('artist', 'album', 'track'):
            mli.setProperty('thumb.fallback', 'script.plex/thumb_fallbacks/music.png')
        elif kind in ('show', 'season', 'episode'):
            mli.setProperty('thumb.fallback', 'script.plex/thumb_fallbacks/show.png')
        elif kind == 'photo':
            mli.setProperty('thumb.fallback', 'script.plex/thumb_fallbacks/photo.png')

        self.setWatchedFlags(mli, hubItem)
        return mli

    def setWatchedFlags(self, mli, hubItem):
        """The watched / unwatched markers of home's cards; read from the hub answer, so no request."""
        try:
            kind = hubItem.TYPE
            if kind in ('movie', 'episode'):
                if not hubItem.isWatched:
                    mli.setProperty('unwatched', '1')
                mli.setBoolProperty('watched', hubItem.isFullyWatched)
            elif kind in ('show', 'season'):
                if not hubItem.isWatched:
                    mli.setProperty('unwatched.count', str(hubItem.unViewedLeafCount))
                    mli.setBoolProperty('unwatched.count.large', hubItem.unViewedLeafCount > 999)
                mli.setBoolProperty('watched', hubItem.isFullyWatched)
        except Exception:
            util.DEBUG_LOG('Search: no watched state for {0}'.format(hubItem))

    def focusId(self):
        try:
            return self.getFocusId()
        except RuntimeError:
            return 0

    def hubListIDs(self):
        return [self.HISTORY_LIST_ID] + [2100 + i for i in range(self.SEARCH_HUB_COUNT)]

    def entryControlID(self):
        """Where the focus goes when the list it was on is gone: the keyboard, or the field with the Kodi keyboard."""
        return self.EDIT_CONTROL_ID if self.getProperty('hide.kbd') else self.BUTTON_A_ID

    def restoreFocus(self, fid, rows):
        """
        The list that had focus may have just been emptied by a refresh (results replaced by history or by new results),
        which would drop focus. Put it back on the same shelf if it is still there, else on the first one, else on the
        keyboard.
        """
        if fid not in self.hubListIDs():
            return
        try:
            if fid != self.HISTORY_LIST_ID and fid - 2100 < rows:
                self.setFocusId(fid)
            elif rows:
                self.setFocusId(2100)
            elif self.historyList.size() > 0:
                self.setFocusId(self.HISTORY_LIST_ID)
            else:
                self.setFocusId(self.entryControlID())
        except RuntimeError:
            pass

    def showHubs(self, hubs):
        """
        Fill the result shelves. Which chips exist, which one is selected and which shelves show are all decided from the
        hubs already fetched, so a chip click costs no request.
        """
        hubs = list(hubs)
        with self._showLock:
            fid = self.focusId()
            pairs = [(h.type, h.size.asInt()) for h in hubs]
            present = plezy_search.present_kinds([p for p in pairs if p[0] in self.HUBMAP])
            section = plezy_search.resolve_section(self.getProperty('search.section'), present)

            # build every card before touching the window, so the swap is quick
            rows = []
            for i in plezy_search.hub_ids_to_show(pairs, section, self.HUBMAP, self.SEARCH_HUB_COUNT):
                hub = hubs[i]
                display = self.HUBMAP[hub.type]['type']
                items = [mli for mli in (self.createListItem(item, display) for item in hub.items) if mli]
                if items:
                    rows.append((hub, display, items))

            self.clearHubs(keep_chips=True)
            self._idleShown = False
            if section != self.getProperty('search.section'):
                self.setProperty('search.section', section)
            for kind in plezy_search.KINDS:
                self.setProperty('search.kind.{0}'.format(kind), kind in present and '1' or '')
            chips = plezy_search.show_chips(present)
            self.setProperty('search.chips', chips and '1' or '')

            controlID = None
            for idx, (hub, display, items) in enumerate(rows):
                self.opaqueBackground()
                cid = self.showHub(hub, idx, display, items)
                controlID = controlID or cid

            self.setProperty('no.results', '' if controlID else '1')

            # focus may have been on something that just went away
            focusFirst = self._focusFirstResult
            self._focusFirstResult = False
            chip = plezy_search.SECTION_BUTTONS.get(fid)
            chipGone = chip is not None and (not chips or (chip != 'all' and chip not in present))
            if focusFirst and controlID:
                self.setFocusId(controlID)
            elif chipGone:
                self.setFocusId(901 if chips else self.EDIT_CONTROL_ID)
            else:
                self.restoreFocus(fid, len(rows))

            fid = self.focusId()
            if 2099 < fid < 2200:
                self.setProperty('hub.focus', str(fid - 2100))

    def showHub(self, hub, idx, display, items):
        util.DEBUG_LOG('Showing search hub: {0} at {1}', hub.type, idx)
        hub_id = 2100 + idx
        control = self.hubControls[idx]

        self.setProperty('hub.display.{0}'.format(hub_id), display)
        self.setProperty('hub.{0}'.format(hub_id), hub.title)
        self.setProperty('hub.icon.{0}'.format(hub_id), plezy_search.hub_icon(hub.type))
        self.setProperty('hub.text2lines.{0}'.format(hub_id), '1')

        control.reset()
        control.addItems(items)

        return control.controlID

    def clearHubs(self, keep_chips=False):
        self.opaqueBackground(on=False)
        self.setProperty('no.results', '')
        self.setProperty('search.error', '')
        for i, control in enumerate(self.hubControls):
            control.reset()
            hub_id = 2100 + i
            self.setProperty('hub.{0}'.format(hub_id), '')
            self.setProperty('hub.display.{0}'.format(hub_id), '')
            self.setProperty('hub.icon.{0}'.format(hub_id), '')
            self.setProperty('hub.text2lines.{0}'.format(hub_id), '')
        self.setProperty('hub.focus', '')
        if not keep_chips:
            self.setProperty('search.chips', '')
            for kind in plezy_search.KINDS:
                self.setProperty('search.kind.{0}'.format(kind), '')
        self.historyList.reset()
        self.setProperty('show.history', '')

    def opaqueBackground(self, on=True):
        self.parentWindow.setProperty('search.dialog.hasresults', on and '1' or '')

    def wait(self):
        while self.isActive and not util.MONITOR.waitForAbort(0.1):
            pass


def dialog(parent_window, section_id=None):
    parent_window.setProperty('search.dialog.hasresults', '')
    with parent_window.propertyContext('search.dialog'):
        try:
            w = SearchDialog.open(parent_window=parent_window, section_id=section_id)
            w.wait()
            command = w.exitCommand or ''
            del w
            return command
        finally:
            parent_window.setProperty('search.dialog.hasresults', '')
