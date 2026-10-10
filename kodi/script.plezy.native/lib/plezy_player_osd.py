# coding=utf-8
"""
Geometry and small pure helpers for the Plezy-style player chrome: the seek dialog OSD
(templates/script-plex-seek_dialog.xml.tpl, lib/windows/seekdialog.py), the queue strip
(script-plex-video_current_playlist.xml.tpl) and post-play (script-plex-video_player.xml.tpl).

Plezy's player controls (edde746/plezy lib/widgets/video_controls/desktop_video_controls.dart, also used on TV)
are laid out in unscaled logical pixels; the add-on draws that chrome at x1.5 (PLEZY_DESIGN.md "Scale"):
  - bottom controls padding 24/16 -> 36/24; button row 48 tall -> 72 (round 40px controls -> 60-64 px discs)
  - timeline row: timestamp, 12 gap, slider (8px track -> 12, focus knob radius 9 -> 28px), 12 gap, timestamp
  - scrub preview 160 wide -> 240x135 (radius 6 -> 9), time pill radius 4 -> 6
  - content strip (tablet metrics on a 1080p TV): 200x112 thumbs on a 212 pitch -> 296x167 on 318

All values are 1080p reference coordinates (the templates' units before vscale). The chrome below the header is
anchored to the bottom edge: templates write posy as "{{ vscale(1080 - y) }}r" and Python converts with
bottom_anchored(y, util.vscalei). tests/test_player_osd.py checks that the template uses the same numbers.

Kodi-free on purpose, so it can be unit tested.
"""
from __future__ import absolute_import, division

import math

SIDE = 36                 # bottom controls side padding (24 * 1.5)

# timeline (VideoTimelineBar horizontal layout)
TIME_W = 120              # timestamp label width either side of the slider
BAR_X = SIDE + TIME_W + 18  # 174: slider left edge (12 * 1.5 gap after the timestamp)
BAR_W = 1920 - 2 * BAR_X    # 1572
BAR_RIGHT = BAR_X + BAR_W   # 1746
TRACK_H = 12              # SliderTheme trackHeight 8
TRACK_CY = 962            # track centre line
TRACK_Y = TRACK_CY - TRACK_H // 2  # 956
TIME_ROW_Y = TRACK_CY - 18  # 944: timestamps row (36 tall) holding the track group
BAR_Y = TRACK_CY - 24     # 938: MAIN_BUTTON_ID (timeline focus target / mouse seek area) top, 48 tall
BAR_BOTTOM = BAR_Y + 48   # 986

# scrub preview (TimelineSlider._buildTooltip): bottom sits 3px above the 30px slider row, pill 6px inside it
BIF_W = 240
BIF_H = 135
BIF_Y = TRACK_CY - 15 - 3 - BIF_H  # 809
SELECTION_W = 112         # time pill (group 203 / image 204 / label 205) default width
SELECTION_H = 40
SELECTION_Y = BIF_Y + BIF_H - 6 - SELECTION_H  # 898: group 202 top; the knob centre is TRACK_CY
KNOB = 28                 # playerFocusKnobRadius 9 -> 28px disc
PILL_MAX_W = 480          # chapter-name pills (forceNextTimeAsChapter)

# Kodi's 12-step big seek (list 501 without chapters): dots on the track
BIGSEEK_ITEMS = 12
BIGSEEK_ITEM_W = BAR_W // BIGSEEK_ITEMS  # 131
BIGSEEK_DOT = 32          # item/list height; an 8px dot (28px knob when focused) centred in it
BIGSEEK_DOT_Y = TRACK_CY - BIGSEEK_DOT // 2  # 946

# chapter strip (ContentStrip, list 501 with chapters), drawn above the timeline
STRIP_X = 30              # panel padding 8 + list padding 12 -> 30
STRIP_ITEM_W = 318        # 212 * 1.5
STRIP_THUMB_W = 296
STRIP_THUMB_H = 167
STRIP_H = 250
STRIP_Y = SELECTION_Y - 24 - STRIP_H  # 624

# button row (two grouplists: transport left, track/settings controls right)
ROW_Y = 972               # grouplists 440/441 top; 96 tall so a zoomed (1.12) disc is not clipped
ROW_H = 96
ROW_CY = ROW_Y + ROW_H // 2  # 1020 (the 72px Plezy row 984..1056)
PITCH = 64                # one round control (40 logical -> 60, +4 so Kodi's glyphs breathe)
PLAY_PITCH = 80           # play/pause (48 logical -> 72)
RIGHT_END = 1920 - SIDE   # 1884: right edge of the last control in the right cluster

# order of the right cluster (template grouplist 441); each entry lists alternative ids for one slot
RIGHT_CLUSTER = (
    ('settings', (403,)),
    ('subtitles', (412,)),
    ('playlist', (410, 430)),
    ('repeat', (401,)),
    ('shuffle', (402, 422)),
    ('vs10', (413,)),
    ('stop', (407,)),
)

DROPDOWN_W = 360          # windows/dropdown.py DropdownDialog.dropWidth
DROPDOWN_BOTTOM = ROW_Y   # dropdowns opened from the right cluster sit on top of the button row


def bottom_anchored(y, vscale, height=1080):
    """Window y of a 1080p reference position that hugs the bottom edge. On non-16:9 displays the add-on scales
    heights (util.vscalei / the templates' vscale), so the player chrome is laid out from the bottom
    (templates: posy "{{ vscale(1080 - y) }}r")."""
    return height - vscale(height - y)


def clamp(value, low, high):
    return max(low, min(high, value))


def pill_width(text, minimum=SELECTION_W, maximum=PILL_MAX_W, char_w=13, padding=32):
    """Approximate width for the time pill when it shows a chapter name instead of a time (font10)."""
    return int(clamp(len(text or '') * char_w + padding, minimum, maximum))


def bif_x(w, bif_w=BIF_W, bar_x=BAR_X, bar_w=BAR_W):
    """Absolute x of the scrub preview: centred on the bar offset w, clamped to the slider (Plezy tooltip)."""
    return bar_x + int(clamp(w - bif_w / 2.0, 0, bar_w - bif_w))


def pill_x(w, box_w=SELECTION_W, bif_left=None, bar_x=BAR_X, bar_w=BAR_W):
    """x of the time pill group (203) relative to the selection indicator group (202), which Python places at
    bar_x + w. Without a preview the pill is centred on the knob and clamped to the slider; with one it is centred
    in the preview's bottom edge, like Plezy's time label inside the scrub thumbnail."""
    if bif_left is not None:
        centre = bif_left - bar_x + BIF_W / 2.0
    else:
        centre = w
    left = clamp(centre - box_w / 2.0, 0, max(bar_w - box_w, 0))
    return int(round(left - w))


def bigseek_group_x(px_offset, bar_x=BAR_X, dot=BIGSEEK_DOT):
    """x of big seek group 500 so the dot of the closest 1/12 step sits on the selected offset."""
    return bar_x - dot // 2 + px_offset


def current_index(offsets, position):
    """Index of the last offset <= position (the chapter playing at position), or None."""
    idx = None
    for i, off in enumerate(offsets):
        if off is None:
            continue
        if off <= position:
            idx = i
        else:
            break
    return idx


def right_cluster_centre(visible, target_key, right_end=RIGHT_END, pitch=PITCH):
    """Centre x of a right-cluster control. visible: set/dict of RIGHT_CLUSTER keys that are shown (settings and
    stop are always shown). The cluster is right-aligned, so the controls after the target decide its position."""
    keys = [k for k, _ in RIGHT_CLUSTER if k in ('settings', 'stop') or k in visible or k == target_key]
    after = len(keys) - 1 - keys.index(target_key)
    return int(right_end - after * pitch - pitch / 2.0)


def dropdown_pos(centre_x, width=DROPDOWN_W, screen_w=1920, bottom=DROPDOWN_BOTTOM):
    """(x, y) for dropdown.showDropdown(..., pos_is_bottom=True) centred over a control."""
    return int(clamp(centre_x - width / 2.0, SIDE, screen_w - width - SIDE)), bottom


def countdown_seconds(timeout, now):
    """Whole seconds left on the post-play timer, as shown on the Play next pill."""
    if timeout is None:
        return 0
    return max(0, int(math.ceil(timeout - now)))


def join_meta(parts, sep=u' · '):
    """Plezy's toBulletedString: non-empty parts joined with a middle dot."""
    return sep.join(p for p in parts if p)


def episode_code(parent_index, index, season_fmt=u'S{}', episode_fmt=u'E{}', sep=u''):
    """
    'S1E2' (sep u'') or 'S1 · E2' (sep u' · ') for an episode. '' unless BOTH numbers are present: plexnet returns
    an empty PlexValue for a missing attribute, which would otherwise render as 'SE' or 'Season  · Episode '.
    """
    season, episode = u'{0}'.format(parent_index or u'').strip(), u'{0}'.format(index or u'').strip()
    if not season or not episode:
        return u''
    return season_fmt.format(season) + sep + episode_fmt.format(episode)


def queue_subtitle(show, parent_index, index, season_fmt=u'S{}', episode_fmt=u'E{}'):
    """Plezy formatQueueItemSubtitle: 'Show · S1E2', or the show title alone when a number is missing."""
    return join_meta((show, episode_code(parent_index, index, season_fmt, episode_fmt)))


def marker_reaches_end(end_offset, duration, negoff=3000):
    """True when a (final) marker runs to the end of the video, i.e. skipping it leaves the video (seekdialog.
    handleFinalMarker only seeks past a final marker that ends more than negoff ms before the end)."""
    return end_offset >= duration - negoff
