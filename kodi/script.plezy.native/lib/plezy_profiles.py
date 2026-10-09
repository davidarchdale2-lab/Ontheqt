# coding=utf-8
"""
Profile picker and sign-in helpers, ported from edde746/plezy:
 - color_for_name / initial_of: the avatar fallback disc (lib/utils/initials_palette.dart, profiles/profile_avatar.dart)
 - group_positions: which corner shape each tile of the connected profile group uses (groupItemRadii)
 - profile_meta: the muted line under a profile's name (the Kodi stand-in for Plezy's backend chips)
 - pin_chars: the four characters of the plex.tv/link code

Kept free of Kodi imports so they can be tested outside Kodi; callers pass in anything localised.
"""
from __future__ import absolute_import

SEPARATOR = u' • '

# lib/utils/initials_palette.dart: dark enough that a plain white initial always has contrast
AVATAR_PALETTE = (
    'FF1565C0',  # blue
    'FF2E7D32',  # green
    'FFAD1457',  # pink
    'FF6A1B9A',  # purple
    'FF00838F',  # teal
    'FFE65100',  # orange
    'FF4527A0',  # deep purple
    'FFC62828',  # red
)
# theme.colorScheme.primary in the mono theme (an empty name has no palette entry)
EMPTY_NAME_COLOR = 'FFEDEDED'


def _text(value):
    if value is None:
        return u''
    if isinstance(value, bytes):
        return value.decode('utf-8', 'replace')
    return u'{0}'.format(value)


def utf16_units(name):
    """The UTF-16 code units of name (Dart's String.codeUnits), whatever the Python build's string width."""
    data = bytearray(_text(name).encode('utf-16-le', 'surrogatepass' if str is not bytes else 'strict'))
    return [data[i] | (data[i + 1] << 8) for i in range(0, len(data) - 1, 2)]


def color_for_name(name):
    """Plezy colorForName: the avatar disc colour (AARRGGBB) for a profile name."""
    units = utf16_units(name)
    if not units:
        return EMPTY_NAME_COLOR
    h = 0
    for unit in units:
        h = (h * 31 + unit) & 0x7fffffff
    return AVATAR_PALETTE[h % len(AVATAR_PALETTE)]


def initial_of(name):
    """Plezy initialOf: the first character of the trimmed name, upper-cased, or '?' for an empty name."""
    trimmed = _text(name).strip()
    if not trimmed:
        return u'?'
    return trimmed[:1].upper()


def group_positions(count):
    """Position of each tile in a connected group of count tiles: only / first / middle / last."""
    if count <= 0:
        return []
    if count == 1:
        return ['only']
    return ['first'] + ['middle'] * (count - 2) + ['last']


def profile_meta(labels, active=False, admin=False, managed=False, protected=False):
    """
    The muted line under a profile name: 'Active - Administrator|Managed user|Home user - PIN protected'.
    labels: dict with active, admin, managed, home and protected (localised by the caller).
    """
    parts = []
    if active:
        parts.append(labels['active'])
    if admin:
        parts.append(labels['admin'])
    elif managed:
        parts.append(labels['managed'])
    else:
        parts.append(labels['home'])
    if protected:
        parts.append(labels['protected'])
    return SEPARATOR.join(parts)


def pin_chars(pin, count=4):
    """The upper-case characters of the plex.tv/link code, padded with '' up to count."""
    pin = _text(pin)
    return [pin[i].upper() if i < len(pin) else u'' for i in range(count)]
