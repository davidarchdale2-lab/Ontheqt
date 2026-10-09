#!/usr/bin/env python3
"""Generate the Plezy-style textures used by script.plezy.native's skin.

usage: python3 make_plezy_textures.py <addon_root> [MaterialSymbolsRounded.ttf MaterialSymbolsRounded.codepoints]

Shapes (pills, rounded masks, focus rings, glow, scrims) are drawn from the Plezy design tokens
(lib/theme/mono_theme.dart, lib/focus/focus_theme.dart in edde746/plezy). Icons are rendered from Google's
Material Symbols Rounded variable font (Apache-2.0), filled, the icon set Plezy uses. Without the font only
the shapes are regenerated and the committed icons are kept.

All textures are white (or the Plezy background colour for scrims) so templates tint them with colordiffuse.
"""
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

SS = 8  # supersampling factor for anti-aliased edges
BG = (0x0E, 0x0F, 0x12)  # Plezy dark bg

root = os.path.abspath(sys.argv[1])
media = os.path.join(root, 'resources', 'skins', 'Main', 'media', 'script.plex')
out = os.path.join(media, 'plezy')
os.makedirs(os.path.join(out, 'icons'), exist_ok=True)


def save(img, name):
    img.save(os.path.join(out, name), optimize=True)


def rounded(w, h, r, fill=255):
    """White rounded rect, anti-aliased."""
    a = Image.new('L', (w * SS, h * SS), 0)
    ImageDraw.Draw(a).rounded_rectangle((0, 0, w * SS - 1, h * SS - 1), radius=r * SS, fill=fill)
    a = a.resize((w, h), Image.LANCZOS)
    img = Image.new('RGBA', (w, h), (255, 255, 255, 0))
    img.putalpha(a)
    return img


def ring(inner_r, stroke, pad=2):
    """Outside stroke around an inner_r rounded rect (Plezy CardFocusBorder: strokeAlignOutside).
    Texture is (inner_r + stroke) * 2 + pad square; use border=inner_r + stroke."""
    outer = inner_r + stroke
    size = outer * 2 + pad
    a = Image.new('L', (size * SS, size * SS), 0)
    d = ImageDraw.Draw(a)
    d.rounded_rectangle((0, 0, size * SS - 1, size * SS - 1), radius=outer * SS, fill=255)
    d.rounded_rectangle((stroke * SS, stroke * SS, (size - stroke) * SS - 1, (size - stroke) * SS - 1),
                        radius=inner_r * SS, fill=0)
    a = a.resize((size, size), Image.LANCZOS)
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    img.putalpha(a)
    return img


def glow(inner_r=8, spread=40):
    """Soft white halo for focused cards (Plezy focusGlowShadows: blur 18 @ .34, blur 34 @ .2).
    Place it spread px outside the card on every side, border=spread + inner_r."""
    core = 24
    size = core + spread * 2
    a = Image.new('L', (size, size), 0)
    ImageDraw.Draw(a).rounded_rectangle((spread, spread, spread + core, spread + core), radius=inner_r, fill=255)
    inner = a.filter(ImageFilter.GaussianBlur(9)).point(lambda v: int(v * 0.34))
    outer = a.filter(ImageFilter.GaussianBlur(17)).point(lambda v: int(v * 0.2))
    # no cut-out: templates draw the halo beneath the opaque artwork, and a hard inner edge would leave a seam
    # wherever a layout's ring sits a pixel or two off the card
    combined = ImageChops.add(inner, outer)
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    img.putalpha(combined)
    return img


def panel_right(r=32, size=80):
    """Expanded sidebar panel: square left edge, rounded trailing corners (Plezy overlayCornerRadius)."""
    a = Image.new('L', (size * SS, size * SS), 0)
    d = ImageDraw.Draw(a)
    d.rounded_rectangle((-(r * SS), 0, size * SS - 1, size * SS - 1), radius=r * SS, fill=255)
    a = a.resize((size, size), Image.LANCZOS)
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    img.putalpha(a)
    return img


def scrim_h():
    """Plezy _buildHorizontalScrim: bg @ .86 -> .32 at 56% -> transparent."""
    w = 512
    img = Image.new('RGBA', (w, 4))
    for x in range(w):
        t = x / (w - 1)
        if t <= 0.56:
            al = 0.86 + (0.32 - 0.86) * (t / 0.56)
        else:
            al = 0.32 * (1 - (t - 0.56) / 0.44)
        for y in range(4):
            img.putpixel((x, y), BG + (int(round(al * 255)),))
    return img


def scrim_v():
    """Plezy spotlight vertical gradient: black @ .45 -> transparent at 38% -> bg @ .96."""
    h = 512
    img = Image.new('RGBA', (4, h))
    for y in range(h):
        t = y / (h - 1)
        if t <= 0.38:
            px = (0, 0, 0, int(round(0.45 * (1 - t / 0.38) * 255)))
        else:
            px = BG + (int(round(0.96 * (t - 0.38) / 0.62 * 255)),)
        for x in range(4):
            img.putpixel((x, y), px)
    return img


def scrim_bottom():
    """Plain fade to bg for the bottom of list screens."""
    h = 256
    img = Image.new('RGBA', (4, h))
    for y in range(h):
        al = int(round(0.96 * (y / (h - 1)) ** 1.4 * 255))
        for x in range(4):
            img.putpixel((x, y), BG + (al,))
    return img


# radius tokens: sm 8, md 12, lg 20, card 14; pills for 40/48/56/64 tall controls
for r in (8, 12, 14, 20):
    save(rounded(r * 2 + 2, r * 2 + 2, r), 'r{}.png'.format(r))
for h in (40, 48, 56, 64):
    save(rounded(h + 2, h + 2, h // 2), 'pill-{}.png'.format(h))

# poster masks at their on-screen size (Kodi stretches diffuse masks to the control)
for name, (w, h) in {'poster': (200, 300), 'wide': (400, 225), 'square': (200, 200),
                     'grid-poster': (244, 361), 'grid-wide': (532, 299), 'grid-square': (244, 244)}.items():
    save(rounded(w, h, 8), 'mask-{}.png'.format(name))

save(ring(8, 3), 'ring-8.png')      # 2.5px Plezy focus border, rounded to 3 for 1080p
save(ring(12, 3), 'ring-12.png')
save(ring(24, 3), 'ring-pill-48.png')
save(glow(), 'glow.png')
save(panel_right(), 'panel-right-32.png')
save(scrim_h(), 'scrim-h.png')
save(scrim_v(), 'scrim-v.png')
save(scrim_bottom(), 'scrim-bottom.png')

# ---- "plezy" button theme: the modern glyphs, focused as a white disc with the glyph knocked out ----
def plezy_buttons():
    src_dir = os.path.join(media, 'buttons', 'player', 'modern')
    dst_dir = os.path.join(media, 'buttons', 'player', 'plezy')
    os.makedirs(dst_dir, exist_ok=True)
    for fn in sorted(os.listdir(src_dir)):
        if not fn.endswith('.png'):
            continue
        glyph_img = Image.open(os.path.join(src_dir, fn)).convert('RGBA')
        w, h = glyph_img.size
        a = glyph_img.getchannel('A')
        bbox = a.getbbox() or (0, 0, w, h)
        # Plezy's round controls: ~24px glyph in a 40px disc
        d = min(int(max(bbox[2] - bbox[0], bbox[3] - bbox[1]) / 0.58), h - 4)
        cx, cy = (bbox[0] + bbox[2]) / 2.0, (bbox[1] + bbox[3]) / 2.0
        disc_l = Image.new('L', (w * SS, h * SS), 0)
        ImageDraw.Draw(disc_l).ellipse(((cx - d / 2.0) * SS, (cy - d / 2.0) * SS, (cx + d / 2.0) * SS, (cy + d / 2.0) * SS), fill=255)
        disc_l = disc_l.resize((w, h), Image.LANCZOS)
        focus = Image.new('RGBA', (w, h), (255, 255, 255, 0))
        focus.putalpha(ImageChops.subtract(disc_l, a))
        plain = Image.new('RGBA', (w, h), (255, 255, 255, 0))
        plain.putalpha(a)
        plain.save(os.path.join(dst_dir, fn), optimize=True)
        focus.save(os.path.join(dst_dir, fn[:-4] + '-focus.png'), optimize=True)


plezy_buttons()

# ---- icons ----
ICONS = {
    # sidebar / sections (Plezy content_utils + navigation_tabs)
    'home': 'home', 'movie': 'movie', 'show': 'tv', 'artist': 'music_note', 'photo': 'photo',
    'playlists': 'playlist_play', 'watchlist': 'bookmark', 'channels': 'live_tv', 'libraries': 'video_library',
    'search': 'search', 'settings': 'settings', 'chevron_right': 'chevron_right', 'person': 'person',
    # hub rows (Plezy hub_icons.dart)
    'hub_continue': 'play_circle', 'hub_default': 'auto_awesome', 'hub_trending': 'trending_up',
    'hub_popular': 'whatshot', 'hub_seasonal': 'calendar_month', 'hub_new': 'new_releases',
    'hub_recent': 'schedule', 'hub_star': 'star', 'hub_top': 'military_tech', 'hub_thriller': 'warning',
    'hub_comedy': 'mood', 'hub_action': 'flash_on', 'hub_drama': 'theater_comedy', 'hub_fantasy': 'auto_fix_high',
    'hub_scifi': 'rocket_launch', 'hub_horror': 'nights_stay', 'hub_romance': 'favorite',
    'hub_adventure': 'explore', 'hub_playlist': 'playlist_play', 'hub_unwatched': 'visibility_off',
    'hub_watched': 'visibility', 'hub_network': 'tv', 'hub_person': 'person', 'hub_decade': 'history',
    'hub_start': 'play_arrow', 'hub_recommended': 'thumb_up', 'hub_genre': 'category',
}

if len(sys.argv) >= 4:
    font_path, cp_path = sys.argv[2], sys.argv[3]
    codepoints = {}
    with open(cp_path, encoding='utf-8') as f:
        for line in f:
            name, cp = line.split()
            codepoints[name] = int(cp, 16)
    font = ImageFont.truetype(font_path, 80 * SS // 2)
    axes = {a['name'].decode() if isinstance(a['name'], bytes) else a['name']: a for a in font.get_variation_axes()}
    want = {'Fill': 1, 'FILL': 1, 'Grade': 0, 'GRAD': 0, 'Optical size': 48, 'opsz': 48, 'Weight': 500, 'wght': 500}
    font.set_variation_by_axes([want.get(name, a.get('default', 0)) for name, a in axes.items()])
    canvas = 96
    for fname, symbol in ICONS.items():
        ch = chr(codepoints[symbol])
        big = Image.new('L', (canvas * SS // 2, canvas * SS // 2), 0)
        d = ImageDraw.Draw(big)
        l, t, r, b = d.textbbox((0, 0), ch, font=font)
        d.text(((big.width - (r - l)) / 2 - l, (big.height - (b - t)) / 2 - t), ch, font=font, fill=255)
        a = big.resize((canvas, canvas), Image.LANCZOS)
        img = Image.new('RGBA', (canvas, canvas), (255, 255, 255, 0))
        img.putalpha(a)
        save(img, os.path.join('icons', fname + '.png'))
    print('icons:', len(ICONS))

    def glyph(symbol, size, scale=1.0):
        a = Image.open(os.path.join(out, 'icons', symbol + '.png')).getchannel('A')
        inner = max(1, int(round(size * scale)))
        a = a.resize((inner, inner), Image.LANCZOS)
        full = Image.new('L', (size, size), 0)
        full.paste(a, ((size - inner) // 2, (size - inner) // 2))
        return full

    def plain(symbol, size):
        img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
        img.putalpha(glyph(symbol, size))
        return img

    def disc(symbol, size):
        # legacy "-focus" button art: white disc with the glyph knocked out
        d = Image.new('L', (size * SS, size * SS), 0)
        ImageDraw.Draw(d).ellipse((0, 0, size * SS - 1, size * SS - 1), fill=255)
        d = d.resize((size, size), Image.LANCZOS)
        d = ImageChops.subtract(d, glyph(symbol, size, 0.62))
        img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
        img.putalpha(d)
        return img

    # swap the legacy Plex glyphs the add-on references by path for the Plezy (Material Symbols) ones
    legacy = os.path.join(media, 'buttons')
    for name in ('search', 'home'):
        plain(name, 40).save(os.path.join(legacy, name + '.png'), optimize=True)
        disc(name, 71).save(os.path.join(legacy, name + '-focus.png'), optimize=True)
    types = os.path.join(media, 'home', 'type')
    for name in ('home', 'movie', 'show', 'artist', 'photo', 'playlists', 'watchlist', 'channels'):
        plain(name, 72).save(os.path.join(types, name + '.png'), optimize=True)
print('textures written to', out)
