# coding=utf-8
"""Kodi-free helpers for the Plezy-styled settings, dialogs and menus (see PLEZY_DESIGN.md).

The windows (lib/windows/settings.py, dropdown.py, dialog.py, playersettings.py) hand the properties these helpers
compute to the templates, which stay free of arithmetic and string building.
"""
from __future__ import absolute_import

SECTION_ICON = 'script.plex/plezy/icons/{0}.png'

# Material Symbols (script.plex/plezy/icons/<name>.png) per settings section id; unknown ids fall back to "tune"
SECTION_ICONS = {
    'main': 'settings',
    'video': 'play_circle',
    'audio': 'subtitles',
    'ui': 'palette',
    'player': 'smart_display',
    'player_user': 'manage_accounts',
    'network': 'lan',
    'system': 'tune',
    'about': 'info',
}

# Material Symbols per row of the player settings sheet (Plezy's video_settings_sheet gives every row an icon)
PLAYER_SETTING_ICONS = {
    'audio': 'audiotrack',
    'subs': 'subtitles',
    'quality': 'high_quality',
    'download_subs': 'download',
    'kodi_video': 'tv',
    'kodi_audio': 'volume_up',
    'kodi_subtitle': 'closed_caption',
    'kodi_colours': 'palette',
    'kodi_resolutions': 'aspect_ratio',
    'stream_info': 'info',
}

# PM4K indicator images a dropdown row can carry that mean "this is the current choice"
_SELECTED_MARKERS = ('check', 'arrow-', 'circle-19')

SUBTITLE_SEPARATOR = u' · '


def section_icon(section_id):
    """Texture path for a settings section row."""
    return SECTION_ICON.format(SECTION_ICONS.get(section_id, 'tune'))


def player_setting_icon(key):
    """Texture path for a row of the player settings sheet ('' for rows without a known icon)."""
    name = PLAYER_SETTING_ICONS.get(key)
    return SECTION_ICON.format(name) if name else ''


def section_subtitle(labels, limit=3):
    """Plezy shows what a settings group contains under its title: the first few setting names joined with a dot."""
    names = []
    for label in labels:
        if not label:
            continue
        label = u'{0}'.format(label).strip()
        if label:
            names.append(label)
        if len(names) >= limit:
            break
    return SUBTITLE_SEPARATOR.join(names)


def setting_subtitle(value, description):
    """Plezy's settings tiles carry the current value as their subtitle; with a description too, both share the line
    ("value \u00b7 description", the precedent set by SettingChecklistTile)."""
    parts = []
    for part in (value, description):
        if part is None:
            continue
        part = u'{0}'.format(part).strip()
        if part:
            parts.append(part)
    return SUBTITLE_SEPARATOR.join(parts)


def group_flags(index, count):
    """(first, last) for row `index` of a grouped list of `count` rows: the M3E group rounds only its outer corners."""
    if count <= 0:
        return False, False
    return index == 0, index == count - 1


def indicator_selected(indicator):
    """True when a dropdown row's indicator image marks the current choice (check, sort arrows, enabled dot)."""
    if not indicator:
        return False
    indicator = u'{0}'.format(indicator)
    return any(marker in indicator for marker in _SELECTED_MARKERS)


def menu_slots(with_indicator, indicator, has_submenu):
    """Trailing icons a dropdown row shows (indicator image, submenu chevron): decides how wide its label may be."""
    return (1 if with_indicator and indicator else 0) + (1 if has_submenu else 0)


def menu_row_properties(with_indicator, indicator, has_submenu):
    """List item properties for a dropdown row: {'selected': '1' or '', 'slots': '0'|'1'|'2'}."""
    return {
        'selected': '1' if with_indicator and indicator_selected(indicator) else '',
        'slots': str(menu_slots(with_indicator, indicator, has_submenu)),
    }


def bottom_anchored_dropdown_y(count, option_height, max_rows=14, pad=80):
    """Top of a dropdown that grows upwards from a bottom edge: never more than `max_rows` rows are drawn (the list
    scrolls past that), so the offset stays bounded and the top cannot be pushed off the screen."""
    return min(count, max_rows) * option_height + pad


def focus_just_changed(now, focus_time, window=0.15):
    """True when focus moved within `window` seconds before `now`: Kodi runs onFocus and then onAction for the same key
    press, so a RIGHT that has just landed on a list must not also be handled as a press on that list."""
    return focus_time is not None and 0 <= now - focus_time < window
