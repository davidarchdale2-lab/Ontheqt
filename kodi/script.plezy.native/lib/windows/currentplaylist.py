from __future__ import absolute_import

from kodi_six import xbmc
from kodi_six import xbmcgui

from lib import kodijsonrpc
from lib import player
from lib import plezy_music
from lib import util
from lib.util import T
from . import busy
from . import dropdown
from . import kodigui
from . import opener
from . import windowutils


def require_duration(f):
    def wrapper(self, *args, **kwargs):
        if not self.duration:
            self.setDuration()
        return f(self, *args, **kwargs)
    return wrapper


class CurrentPlaylistWindow(kodigui.ControlledWindow, windowutils.UtilMixin):
    xmlFile = 'script-plex-music_current_playlist.xml'
    path = util.ADDON.getAddonInfo('path')
    theme = 'Main'
    res = '1080i'
    width = 1920
    height = 1080

    LI_THUMB_DIM = (64, 64)
    ALBUM_THUMB_DIM = util.scaleResolution(639, 639)

    PLAYLIST_LIST_ID = 101

    SEEK_BUTTON_ID = 500
    SEEK_IMAGE_ID = 510

    POSITION_IMAGE_ID = 201
    SELECTION_INDICATOR = 202
    SELECTION_BOX = 203

    REPEAT_BUTTON_ID = 401
    SHUFFLE_BUTTON_ID = 402
    SHUFFLE_REMOTE_BUTTON_ID = 422
    SKIP_PREV_BUTTON_ID = 404
    SKIP_NEXT_BUTTON_ID = 409
    PLAYLIST_BUTTON_ID = 410
    OPTIONS_BUTTON_ID = 411
    STOP_BUTTON_ID = 407

    # Seek bar geometry, mirrored from includes/music_seek.xml.tpl (the queue window: x 894, w 990, pill top y 200).
    # The selection image and the time bubble sit in a group at BAR_X, so setPosition's x is relative to the bar.
    SEEK_IMAGE_WIDTH = 990
    SELECTION_BOX_WIDTH = 101
    SELECTION_INDICATOR_Y = util.vscalei(168)

    BAR_X = 894
    BAR_Y = util.vscalei(200)
    BAR_RIGHT = 1884
    BAR_BOTTOM = util.vscalei(278)
    SEEK_STEP = 10000  # Plezy seeks by 10 seconds

    NP_BACKGROUND_BLUR = 60      # Plezy: ImageFilter.blur sigma 60
    NP_BACKGROUND_OPACITY = 22   # ... at 22%

    OPTIONS_MENU_POS = plezy_music.QUEUE_MENU_POS

    def __init__(self, *args, **kwargs):
        kodigui.ControlledWindow.__init__(self, *args, **kwargs)
        self.selectedOffset = 0
        self.duration = None
        self.track = None
        self.setDuration()
        self.exitCommand = None
        self.musicPlayerWinID = kwargs.get('winID')

    def doClose(self, **kwargs):
        player.PLAYER.off('av.started', self.onPlayBackStarted)
        player.PLAYER.off('playlist.changed', self.playQueueCallback)
        if player.PLAYER.handler.playQueue and player.PLAYER.handler.playQueue.isRemote:
            player.PLAYER.handler.playQueue.off('change', self.updateProperties)
        self.commonDeinit()
        kodigui.ControlledWindow.doClose(self)

    def commonInit(self):
        player.PLAYER.on('starting.audio', self.onAudioStarting)
        player.PLAYER.on('started.audio', self.onAudioStarted)
        player.PLAYER.on('changed.audio', self.onAudioChanged)

    def commonDeinit(self):
        player.PLAYER.off('starting.audio', self.onAudioStarting)
        player.PLAYER.off('started.audio', self.onAudioStarted)
        player.PLAYER.off('changed.audio', self.onAudioChanged)

    def onFirstInit(self):
        self.playlistListControl = kodigui.ManagedControlList(self, self.PLAYLIST_LIST_ID, 6)  # ~6.5 queue rows are visible
        self.setupSeekbar()

        self.fillPlaylist()
        self.selectPlayingItem()
        self.setFocusId(self.PLAYLIST_LIST_ID)
        self.commonInit()
        self.updateProperties()
        self.setNowPlayingBackground()
        if player.PLAYER.handler.playQueue and player.PLAYER.handler.playQueue.isRemote:
            player.PLAYER.handler.playQueue.on('change', self.updateProperties)
        player.PLAYER.on('playlist.changed', self.playQueueCallback)

    def onAction(self, action):
        try:
            controlID = self.getFocusId()
            if action in (xbmcgui.ACTION_PREVIOUS_MENU, xbmcgui.ACTION_NAV_BACK):
                self.doClose()
                return
            if self.checkSeekActions(action, controlID):
                return
        except:
            util.ERROR()

        kodigui.ControlledWindow.onAction(self, action)

    def onClick(self, controlID):
        if controlID == self.PLAYLIST_LIST_ID:
            self.playlistListClicked()
        elif controlID == self.SEEK_BUTTON_ID:
            self.seekButtonClicked()
        elif controlID == self.SHUFFLE_BUTTON_ID:
            self.fillPlaylist()
            self.selectPlayingItem()
        elif controlID == self.SHUFFLE_REMOTE_BUTTON_ID:
            player.PLAYER.handler.playQueue.setShuffle()
        elif controlID == self.REPEAT_BUTTON_ID:
            self.repeatButtonClicked()
        elif controlID == self.SKIP_PREV_BUTTON_ID:
            self.skipPrevButtonClicked()
            self.selectPlayingItem()
        elif controlID == self.SKIP_NEXT_BUTTON_ID:
            self.skipNextButtonClicked()
            self.selectPlayingItem()
        elif controlID == self.OPTIONS_BUTTON_ID:
            self.optionsButtonClicked()
        elif controlID == self.STOP_BUTTON_ID:
            self.stopButtonClicked()

    def onFocus(self, controlID):
        if controlID == self.SEEK_BUTTON_ID:
            try:
                if player.PLAYER.isPlaying():
                    self.selectedOffset = player.PLAYER.getTime() * 1000
                else:
                    self.selectedOffset = 0
            except RuntimeError:
                self.selectedOffset = 0

            self.updateSelectedProgress()

    def onPlayBackStarted(self, **kwargs):
        self.setDuration()

    def onAudioStarting(self, *args, **kwargs):
        util.setGlobalProperty('ignore_spinner', '1')
        self.ignoreStopCommands = True

    def onAudioStarted(self, *args, **kwargs):
        util.setGlobalProperty('ignore_spinner', '')
        self.ignoreStopCommands = False
        self.selectedOffset = 0
        self.duration = None
        self.setDuration()
        self.setNowPlayingBackground()
        self.updatePlayed()

    def onAudioChanged(self, *args, **kwargs):
        util.setGlobalProperty('ignore_spinner', '')
        self.ignoreStopCommands = False
        self.setDuration()

    def repeatButtonClicked(self):
        if player.PLAYER.handler.playQueue and player.PLAYER.handler.playQueue.isRemote:
            if xbmc.getCondVisibility('Playlist.IsRepeatOne'):
                xbmc.executebuiltin('PlayerControl(RepeatOff)')
            elif player.PLAYER.handler.playQueue.isRepeat:
                player.PLAYER.handler.playQueue.setRepeat(False)
                player.PLAYER.handler.playQueue.refresh(force=True)
                xbmc.executebuiltin('PlayerControl(RepeatOne)')
            else:
                player.PLAYER.handler.playQueue.setRepeat(True)
                player.PLAYER.handler.playQueue.refresh(force=True)
        else:
            xbmc.executebuiltin('PlayerControl(Repeat)')

    def skipPrevButtonClicked(self):
        if not xbmc.getCondVisibility('MusicPlayer.HasPrevious') and player.PLAYER.handler.playQueue and player.PLAYER.handler.playQueue.isRemote:
            util.DEBUG_LOG('MusicPlayer: No previous in Kodi playlist - refreshing remote PQ')
            if not player.PLAYER.handler.playQueue.refresh(force=True, wait=True):
                return

        xbmc.executebuiltin('PlayerControl(Previous)')

    def skipNextButtonClicked(self):
        if not xbmc.getCondVisibility('MusicPlayer.HasNext') and player.PLAYER.handler.playQueue and player.PLAYER.handler.playQueue.isRemote:
            util.DEBUG_LOG('MusicPlayer: No next in Kodi playlist - refreshing remote PQ')
            if not player.PLAYER.handler.playQueue.refresh(force=True, wait=True):
                return

        xbmc.executebuiltin('PlayerControl(Next)')

    def optionsButtonClicked(self, pos=None):
        pos = pos or self.OPTIONS_MENU_POS
        track = player.PLAYER.currentTrack()
        if not track:
            return

        options = []

        options.append({'key': 'to_album', 'display': T(32300, 'Go to Album')})
        options.append({'key': 'to_artist', 'display': T(32301, 'Go to Artist')})
        options.append({'key': 'to_section', 'display': T(32302, u'Go to {0}').format(track.getLibrarySectionTitle())})

        choice = dropdown.showDropdown(options, pos, pos_is_bottom=False, close_on_playback_ended=True)
        if not choice:
            return

        if choice['key'] == 'to_album':
            self.processCommand(opener.open(track.parentRatingKey))
        elif choice['key'] == 'to_artist':
            self.processCommand(opener.open(track.grandparentRatingKey))
        elif choice['key'] == 'to_section':
            self.goHome(track.getLibrarySectionId())

    def stopButtonClicked(self):
        xbmc.executebuiltin('Action(Back, {})'.format(self.musicPlayerWinID))
        util.MONITOR.waitForAbort(0.5)
        player.PLAYER.stopAndWait()
        self.exitCommand = "STOP"
        self.doClose()

    def selectPlayingItem(self):
        for mli in reversed(self.playlistListControl):
            if xbmc.getCondVisibility('String.StartsWith(MusicPlayer.Comment,{0})'.format(mli.dataSource['comment'].split(':', 1)[0])):
                self.playlistListControl.selectItem(mli.pos())
                break

    def playQueueCallback(self, **kwargs):
        self.setProperty('pq.isshuffled', player.PLAYER.handler.playQueue.isShuffled and '1' or '')
        mli = self.playlistListControl.getSelectedItem()
        pi = mli.dataSource
        plexID = pi['comment'].split(':', 1)[0]
        viewPos = self.playlistListControl.getViewPosition()

        self.fillPlaylist()

        # due to Kodi playlist limitations and necessary swappery, we might've got the current item twice in the list;
        # select the latest one
        for ni in reversed(self.playlistListControl):
            if ni.dataSource['comment'].split(':', 1)[0] == plexID:
                self.playlistListControl.selectItem(ni.pos())
                break

        util.MONITOR.waitForAbort(0.25)

        newViewPos = self.playlistListControl.getViewPosition()
        if viewPos != newViewPos:
            diff = newViewPos - viewPos
            self.playlistListControl.shiftView(diff, True)

    def seekButtonClicked(self):
        player.PLAYER.seekTime(self.selectedOffset / 1000.0)

    def playlistListClicked(self):
        mli = self.playlistListControl.getSelectedItem()
        if not mli:
            return
        self.onAudioStarting()
        player.PLAYER.playselected(mli.pos())

    def createListItem(self, pi, idx):
        # Plezy's queue rows name only the artist under the title
        artists = pi['artist']
        label2 = artists[0] if artists else ''
        plexInfo = pi['comment']
        mli = kodigui.ManagedListItem(pi['title'], label2, thumbnailImage=pi['thumbnail'], data_source=pi)
        mli.setProperty('track.duration', util.simplifiedTimeDisplay(pi['duration'] * 1000))
        if plexInfo.startswith('PLEX-'):
            mli.setProperty('track.ID', plexInfo.split('-', 1)[-1].split(':', 1)[0])
            mli.setProperty('track.number', str(pi['playcount']))
        else:
            mli.setProperty('track.ID', '!NONE!')
            mli.setProperty('track.number', str(pi['track']))
            mli.setProperty('playlist.position', str(idx))

        mli.setProperty('file', pi['file'])
        return mli

    @busy.dialog()
    def fillPlaylist(self):
        items = []
        idx = 1
        for pi in kodijsonrpc.rpc.PlayList.GetItems(
            playlistid=xbmc.PLAYLIST_MUSIC, properties=['title', 'artist', 'album', 'track', 'thumbnail', 'duration', 'playcount', 'comment', 'file']
        )['items']:
            mli = self.createListItem(pi, idx)
            if mli:
                mli.setProperty('index', str(idx))
                items.append(mli)
                idx += 1

        # M3E grouped rows: big outer corners on the first and last card
        for mli, pos in zip(items, plezy_music.group_positions(len(items))):
            mli.setProperty('group.pos', pos)

        self.playlistListControl.reset()
        self.playlistListControl.addItems(items)
        self.updatePlayed()

    def playingPosition(self):
        """List position of the track Kodi is playing (the last match, as selectPlayingItem), or None."""
        comment = xbmc.getInfoLabel('MusicPlayer.Comment') or ''
        if not comment:
            return None
        for mli in reversed(self.playlistListControl):
            try:
                prefix = mli.dataSource['comment'].split(':', 1)[0]
            except Exception:
                continue
            if prefix and comment.startswith(prefix):
                return mli.pos()
        return None

    def updatePlayed(self):
        """Mark the rows before the playing one as played (Plezy draws the queue's history muted). Local loop."""
        if not getattr(self, 'playlistListControl', None):  # the now-playing window has no queue list
            return
        try:
            flags = plezy_music.played_flags(self.playlistListControl.size(), self.playingPosition())
            for mli, flag in zip(self.playlistListControl, flags):
                if mli.getProperty('played') != flag:
                    mli.setProperty('played', flag)
        except Exception:
            util.ERROR()

    def setNowPlayingBackground(self):
        """The cover blurred by the Plex transcoder at 22% over the dark background (Plezy blurs it in-app). Builds a
        URL only: Kodi fetches the image once per track. Without it the template falls back to the plain cover."""
        try:
            track = player.PLAYER.currentTrack()
            art = track and (track.defaultThumb or track.parentThumb)
            if not art:
                return
            url = art.asTranscodedImageURL(
                self.width, self.height,
                blur=max(util.addonSettings.backgroundArtBlurAmount2, self.NP_BACKGROUND_BLUR),
                opacity=self.NP_BACKGROUND_OPACITY,
                background='0E0F12'
            )
            if url:
                self.setProperty('np.background', url)
        except Exception:
            util.ERROR()

    def setupSeekbar(self):
        self.seekbarControl = self.getControl(self.SEEK_IMAGE_ID)
        self.selectionIndicator = self.getControl(self.SELECTION_INDICATOR)
        self.selectionBox = self.getControl(self.SELECTION_BOX)
        self.selectionBoxHalf = self.SELECTION_BOX_WIDTH // 2
        self.selectionBoxMax = self.SEEK_IMAGE_WIDTH
        player.PLAYER.on('av.started', self.onPlayBackStarted)

    def checkSeekActions(self, action, controlID):
        if controlID == self.SEEK_BUTTON_ID:
            if action == xbmcgui.ACTION_MOUSE_MOVE:
                self.seekMouse(action)
                return True
            elif action in (xbmcgui.ACTION_MOVE_RIGHT, xbmcgui.ACTION_NEXT_ITEM):
                self.seekForward(self.SEEK_STEP)
                return True
            elif action in (xbmcgui.ACTION_MOVE_LEFT, xbmcgui.ACTION_PREV_ITEM):
                self.seekBack(self.SEEK_STEP)
                return True
            # elif action == xbmcgui.ACTION_MOVE_UP:
            #     self.seekForward(60000)
            # elif action == xbmcgui.ACTION_MOVE_DOWN:
            #     self.seekBack(60000)
        elif action == xbmcgui.ACTION_STOP:
            self.stopButtonClicked()
            return True

    def setDuration(self):
        try:
            #duration = None
            #if self.track:
            #    duration = self.track.duration.asInt()
            #if not duration:
            #    duration = player.PLAYER.getTotalTime() * 1000
            #if not duration:
            duration = player.PLAYER.getMusicInfoTag().getDuration() * 1000
            self.duration = duration if duration > 0 else self.duration
        except (RuntimeError, AttributeError):  # Not playing
            pass

    @require_duration
    def seekForward(self, offset):
        self.selectedOffset += offset
        if self.selectedOffset > self.duration:
            self.selectedOffset = self.duration

        self.updateSelectedProgress()

    @require_duration
    def seekBack(self, offset):
        self.selectedOffset -= offset
        if self.selectedOffset < 0:
            self.selectedOffset = 0

        self.updateSelectedProgress()

    @require_duration
    def seekMouse(self, action):
        x = self.mouseXTrans(action.getAmount1())
        y = self.mouseYTrans(action.getAmount2())
        if not (self.BAR_Y <= y <= self.BAR_BOTTOM):
            return

        if not (self.BAR_X <= x <= self.BAR_RIGHT):
            return

        self.selectedOffset = int((x - self.BAR_X) / float(self.SEEK_IMAGE_WIDTH) * self.duration)
        self.updateSelectedProgress()

    @require_duration
    def updateSelectedProgress(self):
        if not self.duration:
            return

        ratio = self.selectedOffset / float(self.duration)
        w = int(ratio * self.SEEK_IMAGE_WIDTH)
        self.seekbarControl.setWidth(w or 1)

        self.selectionIndicator.setPosition(w, self.SELECTION_INDICATOR_Y)
        if w < self.selectionBoxHalf - 3:
            self.selectionBox.setPosition((-self.selectionBoxHalf + (self.selectionBoxHalf - w)) - 3, 0)
        elif w > self.selectionBoxMax:
            self.selectionBox.setPosition((-self.SELECTION_BOX_WIDTH + (self.SEEK_IMAGE_WIDTH - w)) + 3, 0)
        else:
            self.selectionBox.setPosition(-self.selectionBoxHalf, 0)
        self.setProperty('time.selection', util.simplifiedTimeDisplay(int(self.selectedOffset)))

    def updateProperties(self, **kwargs):
        pq = player.PLAYER.handler.playQueue
        if pq:
            if pq.isRemote:
                self.setProperty('pq.isRemote', '1')
                self.setProperty('pq.hasnext', pq.allowSkipNext and '1' or '')
                self.setProperty('pq.hasprev', pq.allowSkipPrev and '1' or '')
                self.setProperty('pq.repeat', pq.isRepeat and '1' or '')
                self.setProperty('pq.shuffled', pq.isShuffled and '1' or '')
            else:
                self.setProperties(('pq.isRemote', 'pq.hasnext', 'pq.hasprev', 'pq.repeat', 'pq.shuffled'), '')
