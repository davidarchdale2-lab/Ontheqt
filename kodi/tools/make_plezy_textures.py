#!/usr/bin/env python3
"""Generate the Plezy-style textures used by script.plezy.native's skin.

usage: python3 make_plezy_textures.py <addon_root> [MaterialSymbolsRounded.ttf MaterialSymbolsRounded.codepoints]

Shapes (pills, rounded rects, masks, focus rings, glow, scrims, spinner) are drawn from the Plezy design tokens
(lib/theme/mono_theme.dart, lib/focus/focus_theme.dart in edde746/plezy). Icons are rendered from Google's
Material Symbols Rounded variable font (Apache-2.0), filled, weight 700 - Plezy's AppIcon defaults. Without the
font only the shapes are regenerated and the committed icons are kept.

Extra requests: every JSON file in tools/textures.d/ is merged in, e.g.
  {"icons": ["equalizer", "album"],             -> plezy/icons/<symbol>.png
   "action_icons": ["shuffle"],                  -> plezy/action/<symbol>.png (+ -focus, pill-, label- variants)
   "masks": {"cover-270": [270, 270, 30]},       -> plezy/mask-<name>.png  (w, h, radius)
   "rounded": [36]}                              -> plezy/r<radius>.png
so screens can ask for textures without editing this script. Files are written atomically.

Textures are white (or the Plezy background colour for scrims) so templates tint them with colordiffuse, except
the baked action buttons, whose idle/focus colours are fixed (see ACTION_*).
"""
import glob
import json
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

SS = 8  # supersampling factor for anti-aliased edges
BG = (0x0E, 0x0F, 0x12)        # Plezy dark bg
SURFACE = (0x15, 0x17, 0x1C)   # Plezy dark surface
TEXT = (0xED, 0xED, 0xED)      # Plezy dark text
ACTION_IDLE = SURFACE + (0x61,)  # filled-tonal action, surface @ 38%
ACTION_FOCUS = TEXT + (255,)     # inverseSurface
ACTION_SIZE = 56                 # detail action buttons (Plezy 46 at 1080p, grown so Kodi's bold font fits)

HERE = os.path.dirname(os.path.abspath(__file__))
root = os.path.abspath(sys.argv[1])
media = os.path.join(root, 'resources', 'skins', 'Main', 'media', 'script.plex')
out = os.path.join(media, 'plezy')
for d in ('icons', 'action'):
    os.makedirs(os.path.join(out, d), exist_ok=True)

extra = {'icons': [], 'action_icons': [], 'masks': {}, 'rounded': []}
for fn in sorted(glob.glob(os.path.join(HERE, 'textures.d', '*.json'))):
    with open(fn) as f:
        data = json.load(f)
    extra['icons'] += data.get('icons', [])
    extra['action_icons'] += data.get('action_icons', [])
    extra['masks'].update(data.get('masks', {}))
    extra['rounded'] += data.get('rounded', [])


def save_to(img, path):
    tmp = path + '.tmp{0}.png'.format(os.getpid())
    img.save(tmp, optimize=True)
    os.replace(tmp, path)


def save(img, name):
    save_to(img, os.path.join(out, name))


def alpha_img(a, rgb=(255, 255, 255)):
    img = Image.new('RGBA', a.size, rgb + (0,))
    img.putalpha(a)
    return img


def rounded_alpha(w, h, radii):
    """Anti-aliased rounded rect alpha; radii = r or (top-left, top-right, bottom-right, bottom-left)."""
    if isinstance(radii, (int, float)):
        radii = (radii,) * 4
    W, H = w * SS, h * SS
    if len(set(radii)) == 1:
        a = Image.new('L', (W, H), 0)
        ImageDraw.Draw(a).rounded_rectangle((0, 0, W - 1, H - 1), radius=int(radii[0] * SS), fill=255)
        return a.resize((w, h), Image.LANCZOS)
    a = Image.new('L', (W, H), 255)
    for (cx, cy, sx, sy), r in zip(((0, 0, 1, 1), (W, 0, -1, 1), (W, H, -1, -1), (0, H, 1, -1)), radii):
        R = int(r * SS)
        if R <= 0:
            continue
        x0, x1 = sorted((cx, cx + sx * R))
        y0, y1 = sorted((cy, cy + sy * R))
        square = Image.new('L', (W, H), 0)
        ImageDraw.Draw(square).rectangle((x0, y0, x1 - 1, y1 - 1), fill=255)
        disc = Image.new('L', (W, H), 0)
        ccx, ccy = cx + sx * R, cy + sy * R
        ImageDraw.Draw(disc).ellipse((ccx - R, ccy - R, ccx + R - 1, ccy + R - 1), fill=255)
        # inside the corner square keep only the quarter disc
        a = ImageChops.subtract(a, ImageChops.subtract(square, disc))
    return a.resize((w, h), Image.LANCZOS)


def rounded(w, h, r):
    return alpha_img(rounded_alpha(w, h, r))


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
    return alpha_img(a.resize((size, size), Image.LANCZOS))


def inside_stroke(size, r, stroke):
    """Stroke drawn inside a size x size rounded rect of radius r (border = r)."""
    a = Image.new('L', (size * SS, size * SS), 0)
    d = ImageDraw.Draw(a)
    d.rounded_rectangle((0, 0, size * SS - 1, size * SS - 1), radius=r * SS, fill=255)
    d.rounded_rectangle((stroke * SS, stroke * SS, (size - stroke) * SS - 1, (size - stroke) * SS - 1),
                        radius=max(0, (r - stroke)) * SS, fill=0)
    return alpha_img(a.resize((size, size), Image.LANCZOS))


def circle(size):
    a = Image.new('L', (size * SS, size * SS), 0)
    ImageDraw.Draw(a).ellipse((0, 0, size * SS - 1, size * SS - 1), fill=255)
    return alpha_img(a.resize((size, size), Image.LANCZOS))


def ring_circle(diameter, stroke):
    """Outside stroke of a circle; texture is diameter + 2 * stroke + 2 square, drawn at -(stroke+1)."""
    size = diameter + 2 * stroke + 2
    a = Image.new('L', (size * SS, size * SS), 0)
    d = ImageDraw.Draw(a)
    d.ellipse((SS, SS, (size - 1) * SS - 1, (size - 1) * SS - 1), fill=255)
    o = (stroke + 1) * SS
    d.ellipse((o, o, size * SS - o - 1, size * SS - o - 1), fill=0)
    return alpha_img(a.resize((size, size), Image.LANCZOS))


def glow(inner_r=8, spread=40, core=24):
    """Soft white halo for focused cards (Plezy focusGlowShadows: blur 18 @ .34, blur 34 @ .2).
    Place it spread px outside the card on every side, border=spread + inner_r."""
    size = core + spread * 2
    a = Image.new('L', (size, size), 0)
    ImageDraw.Draw(a).rounded_rectangle((spread, spread, spread + core, spread + core), radius=inner_r, fill=255)
    inner = a.filter(ImageFilter.GaussianBlur(9)).point(lambda v: int(v * 0.34))
    outer = a.filter(ImageFilter.GaussianBlur(17)).point(lambda v: int(v * 0.2))
    # no cut-out: templates draw the halo beneath the opaque artwork, and a hard inner edge would leave a seam
    # wherever a layout's ring sits a pixel or two off the card
    return alpha_img(ImageChops.add(inner, outer))


def glow_circle(diameter=200, spread=40):
    size = diameter + spread * 2
    a = Image.new('L', (size, size), 0)
    ImageDraw.Draw(a).ellipse((spread, spread, spread + diameter, spread + diameter), fill=255)
    inner = a.filter(ImageFilter.GaussianBlur(9)).point(lambda v: int(v * 0.34))
    outer = a.filter(ImageFilter.GaussianBlur(17)).point(lambda v: int(v * 0.2))
    return alpha_img(ImageChops.add(inner, outer))


def panel_right(r=32, size=80):
    """Expanded sidebar panel: square left edge, rounded trailing corners (Plezy overlayCornerRadius)."""
    a = Image.new('L', (size * SS, size * SS), 0)
    ImageDraw.Draw(a).rounded_rectangle((-(r * SS), 0, size * SS - 1, size * SS - 1), radius=r * SS, fill=255)
    return alpha_img(a.resize((size, size), Image.LANCZOS))


def gradient(w, h, fn, horizontal):
    img = Image.new('RGBA', (w, h))
    n = w if horizontal else h
    for i in range(n):
        px = fn(i / float(n - 1))
        if horizontal:
            for y in range(h):
                img.putpixel((i, y), px)
        else:
            for x in range(w):
                img.putpixel((x, i), px)
    return img


def scrim_h_px(t):
    """Plezy _buildHorizontalScrim: bg @ .86 -> .32 at 56% -> transparent."""
    al = 0.86 + (0.32 - 0.86) * (t / 0.56) if t <= 0.56 else 0.32 * (1 - (t - 0.56) / 0.44)
    return BG + (int(round(al * 255)),)


def scrim_v_px(t):
    """Plezy spotlight vertical gradient: black @ .45 -> transparent at 38% -> bg @ .96."""
    if t <= 0.38:
        return 0, 0, 0, int(round(0.45 * (1 - t / 0.38) * 255))
    return BG + (int(round(0.96 * (t - 0.38) / 0.62 * 255)),)


def spinner(size=96, stroke=8, sweep=270):
    """CircularProgressIndicator stand-in: an arc with round caps; templates rotate it with a looping animation."""
    a = Image.new('L', (size * SS, size * SS), 0)
    d = ImageDraw.Draw(a)
    s, half = stroke * SS, stroke * SS / 2.0
    box = (half, half, size * SS - half - 1, size * SS - half - 1)
    d.arc(box, -90, -90 + sweep, fill=255, width=s)
    import math
    c, rad = (size * SS - 1) / 2.0, (size * SS - stroke * SS) / 2.0
    for ang in (-90, -90 + sweep):
        x, y = c + rad * math.cos(math.radians(ang)), c + rad * math.sin(math.radians(ang))
        d.ellipse((x - half, y - half, x + half, y + half), fill=255)
    return alpha_img(a.resize((size, size), Image.LANCZOS))


# ---- shapes ----
# radius tokens: xs 5/6, sm 8, md 12, card 14, lg 20, dialogs 28, sheets 16/32; pills for 40-64 tall controls
for r in sorted(set([6, 8, 12, 14, 16, 20, 24, 28, 30, 32] + [int(v) for v in extra['rounded']])):
    save(rounded(r * 2 + 2, r * 2 + 2, r), 'r{0}.png'.format(r))
for h in (40, 48, 56, 64):
    save(rounded(h + 2, h + 2, h // 2), 'pill-{0}.png'.format(h))
# menu first/last rows: top-only and bottom-only r12 (border="12")
save(alpha_img(rounded_alpha(26, 26, (12, 12, 0, 0))), 'r12-top.png')
save(alpha_img(rounded_alpha(26, 26, (0, 0, 12, 12))), 'r12-bottom.png')
# M3E connected groups (groupItemRadii: radiusLg 20 outside, radiusXs 6 between rows); 44x44, border="20"
save(alpha_img(rounded_alpha(44, 44, (20, 20, 6, 6))), 'group-top.png')
save(alpha_img(rounded_alpha(44, 44, (6, 6, 6, 6))), 'group-mid.png')
save(alpha_img(rounded_alpha(44, 44, (6, 6, 20, 20))), 'group-bottom.png')
save(alpha_img(rounded_alpha(44, 44, (20, 20, 20, 20))), 'group-single.png')
# M3E split button for a 56px action row: stadium outer corners, r8 joined corners (border="28,28,8,28" / "8,28,28,28")
save(alpha_img(rounded_alpha(60, 56, (28, 8, 8, 28))), 'split-l-56.png')
save(alpha_img(rounded_alpha(60, 56, (8, 28, 28, 8))), 'split-r-56.png')

# diffuse masks at their on-screen size (Kodi stretches a diffuse mask to the control)
MASKS = {
    'poster': (200, 300, 8), 'wide': (400, 225, 8), 'square': (200, 200, 8),
    'grid-poster': (244, 361, 8), 'grid-wide': (532, 299, 8), 'grid-square': (244, 244, 8),
    # detail-screen rails (Plezy tallPosterScale .72)
    'rail-poster': (174, 261, 8), 'rail-square': (174, 174, 8), 'rail-wide': (296, 167, 8),
    # player strips and scrub preview
    'strip': (240, 136, 12), 'bif': (320, 180, 12),
    # music / lists
    'cover-270': (270, 270, 30), 'np-600': (600, 600, 30), 'np-600-paused': (600, 600, 42),
    'np-688': (688, 688, 30), 'np-688-paused': (688, 688, 42),
    'list-poster': (128, 192, 12), 'list-square': (128, 128, 12),
    'row-square': (96, 96, 9), 'row-wide': (171, 96, 9),
}
for name, spec in extra['masks'].items():
    MASKS[name] = tuple(spec)
for name, (w, h, r) in MASKS.items():
    save(rounded(w, h, r), 'mask-{0}.png'.format(name))
save(circle(200), 'mask-circle.png')
save(circle(128), 'circle.png')

save(ring(8, 3), 'ring-8.png')      # 2.5px Plezy focus border, rounded to 3 for 1080p
save(ring(12, 3), 'ring-12.png')
save(ring(24, 3), 'ring-pill-48.png')
save(ring(28, 3), 'ring-pill-56.png')
save(ring(32, 3), 'ring-pill-64.png')
save(ring_circle(200, 3), 'ring-circle.png')        # 208x208, drawn at (-4, -4) around a 200px circle
save(inside_stroke(66, 33, 2), 'outline-pill-64.png')   # OutlinedButton outline, border 33
save(inside_stroke(66, 33, 3), 'focus-pill-64.png')     # FocusTheme.focusDecoration on outlined/text buttons
save(inside_stroke(18, 8, 2), 'outline-r8.png')         # inactive PIN box, border 8
save(glow(), 'glow.png')
save(glow_circle(), 'glow-circle.png')                 # 280x280 around a 200px circle, drawn at (-40, -40)
save(panel_right(), 'panel-right-32.png')
save(spinner(), 'spinner.png')
save(gradient(512, 4, scrim_h_px, True), 'scrim-h.png')
save(gradient(4, 512, scrim_v_px, False), 'scrim-v.png')
save(gradient(4, 256, lambda t: BG + (int(round(0.96 * t ** 1.4 * 255)),), False), 'scrim-bottom.png')
# player chrome: black .70 -> 0 (flip for the bottom); content strip panel black 0 -> .65 at 42% -> .70
save(gradient(4, 256, lambda t: (0, 0, 0, int(round(0.70 * (1 - t) * 255))), False), 'scrim-top.png')
save(gradient(4, 256, lambda t: (0, 0, 0, int(round((0.65 * t / 0.42 if t <= 0.42 else 0.65 + 0.05 * (t - 0.42) / 0.58) * 255))), False),
     'scrim-strip.png')

# plex.tv/link QR for the sign-in screen (only when segno is installed; the committed PNG is kept otherwise)
try:
    import segno
    qr = segno.make('https://plex.tv/link', error='m')
    tmp = os.path.join(out, 'qr-tmp.png')
    qr.save(tmp, scale=8, border=4, dark='#000000', light='#ffffff')
    q = Image.open(tmp).convert('RGBA').resize((240, 240), Image.NEAREST)
    os.remove(tmp)
    q.putalpha(ImageChops.multiply(q.getchannel('A'), rounded_alpha(240, 240, 12)))
    save(q, 'qr-plex-link.png')
except ImportError:
    pass


# ---- "plezy" button theme: the modern glyphs; focus is Plezy's player focus disc (white disc, dark glyph) ----
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
        focus = Image.new('RGBA', (w, h), TEXT + (0,))
        focus.putalpha(disc_l)
        dark = Image.new('RGBA', (w, h), BG + (0,))
        dark.putalpha(a)
        focus.alpha_composite(dark)
        save_to(alpha_img(a), os.path.join(dst_dir, fn))
        save_to(focus, os.path.join(dst_dir, fn[:-4] + '-focus.png'))


plezy_buttons()

# ---- icons ----
NAMED_ICONS = {
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
    # detail rails
    'hub_cast': 'group', 'hub_extras': 'theaters', 'hub_related': 'recommend', 'hub_collection': 'video_library',
    'hub_similar': 'auto_awesome', 'hub_reviews': 'reviews', 'hub_seasons': 'tv',
}
# icons/<symbol>.png, named by their Material Symbols name
SYMBOL_ICONS = [
    # transport / player
    'play_arrow', 'resume', 'pause', 'stop', 'skip_previous', 'skip_next', 'fast_rewind', 'fast_forward',
    'replay', 'replay_5', 'replay_10', 'replay_30', 'forward_5', 'forward_10', 'forward_30', 'forward_media',
    'shuffle', 'repeat', 'repeat_one', 'queue_music', 'queue', 'tune', 'subtitles', 'subtitles_off', 'audiotrack',
    'closed_caption', 'aspect_ratio', 'hdr_strong', 'graphic_eq', 'equalizer', 'art_track', 'bookmarks', 'analytics',
    'speed', 'high_quality', 'picture_in_picture', 'volume_up', 'volume_off', 'playlist_play', 'play_circle',
    # actions
    'check', 'check_circle', 'remove_done', 'info', 'more_vert', 'more_horiz', 'bookmark_add', 'bookmark_added',
    'hourglass_empty', 'hourglass_top', 'event_upcoming', 'theaters', 'group', 'recommend', 'reviews', 'download',
    'close', 'refresh', 'lock', 'power_settings_new', 'dns', 'delete', 'edit', 'add', 'remove', 'star',
    # navigation / chrome
    'arrow_back', 'arrow_upward', 'arrow_downward', 'swap_vert', 'chevron_left', 'chevron_right',
    'keyboard_arrow_down', 'keyboard_arrow_up', 'keyboard_arrow_left', 'keyboard_arrow_right', 'filter_list',
    'sort', 'grid_view', 'view_list', 'home', 'search', 'settings',
    # search / input
    'backspace', 'space_bar', 'clear_all', 'history', 'search_off', 'keyboard',
    # media types / music
    'movie', 'tv', 'music_note', 'album', 'photo', 'photo_library', 'video_library', 'person', 'live_tv', 'mic',
    # settings
    'palette', 'smart_display', 'manage_accounts', 'lan', 'radio_button_checked', 'check_box',
    'account_circle', 'language', 'storage', 'bug_report', 'wifi', 'cloud',
]
OUTLINE_ICONS = ['radio_button_unchecked', 'check_box_outline_blank']  # FILL 0
SYMBOL_ICONS = sorted(set(SYMBOL_ICONS + extra['icons']))

ACTION_ICONS = sorted(set([
    'play_arrow', 'resume', 'shuffle', 'theaters', 'check', 'remove_done', 'bookmark_add', 'bookmark_added',
    'subtitles', 'more_vert', 'more_horiz', 'info', 'tune', 'playlist_play', 'hourglass_empty', 'event_upcoming',
    'play_circle', 'keyboard_arrow_down', 'delete', 'edit', 'person', 'album', 'queue_music', 'radio',
] + extra['action_icons']))

if len(sys.argv) >= 4:
    font_path, cp_path = sys.argv[2], sys.argv[3]
    codepoints = {}
    with open(cp_path, encoding='utf-8') as f:
        for line in f:
            name, cp = line.split()
            codepoints[name] = int(cp, 16)

    def make_font(fill):
        font = ImageFont.truetype(font_path, 80 * SS // 2)
        axes = {a['name'].decode() if isinstance(a['name'], bytes) else a['name']: a
                for a in font.get_variation_axes()}
        want = {'Fill': fill, 'FILL': fill, 'Grade': 0, 'GRAD': 0, 'Optical size': 48, 'opsz': 48,
                'Weight': 700, 'wght': 700}
        font.set_variation_by_axes([want.get(name, a.get('default', 0)) for name, a in axes.items()])
        return font

    fonts = {1: make_font(1), 0: make_font(0)}
    canvas = 96

    def render(symbol, fill=1):
        ch = chr(codepoints[symbol])
        big = Image.new('L', (canvas * SS // 2, canvas * SS // 2), 0)
        d = ImageDraw.Draw(big)
        font = fonts[fill]
        l, t, r, b = d.textbbox((0, 0), ch, font=font)
        d.text(((big.width - (r - l)) / 2 - l, (big.height - (b - t)) / 2 - t), ch, font=font, fill=255)
        return big.resize((canvas, canvas), Image.LANCZOS)

    for fname, symbol in NAMED_ICONS.items():
        save(alpha_img(render(symbol)), os.path.join('icons', fname + '.png'))
    missing = [s for s in SYMBOL_ICONS + OUTLINE_ICONS if s not in codepoints]
    if missing:
        sys.exit('unknown Material Symbols names: {0}'.format(', '.join(missing)))
    for symbol in SYMBOL_ICONS:
        save(alpha_img(render(symbol)), os.path.join('icons', symbol + '.png'))
    for symbol in OUTLINE_ICONS:
        save(alpha_img(render(symbol, fill=0)), os.path.join('icons', symbol + '.png'))
    print('icons:', len(NAMED_ICONS) + len(SYMBOL_ICONS) + len(OUTLINE_ICONS))

    def glyph(symbol, size, scale=1.0):
        a = render(symbol)
        inner = max(1, int(round(size * scale)))
        a = a.resize((inner, inner), Image.LANCZOS)
        full = Image.new('L', (size, size), 0)
        full.paste(a, ((size - inner) // 2, (size - inner) // 2))
        return full

    def colour_layer(a, rgba):
        img = Image.new('RGBA', a.size, rgba[:3] + (0,))
        img.putalpha(a.point(lambda v: v * rgba[3] // 255))
        return img

    def compose(shape_a, glyph_a, bg, fg, glyph_box):
        """shape filled with bg, glyph (pasted into glyph_box) in fg."""
        img = colour_layer(shape_a, bg)
        g = Image.new('L', shape_a.size, 0)
        g.paste(glyph_a, glyph_box[:2])
        img.alpha_composite(colour_layer(ImageChops.multiply(g, shape_a), fg))
        return img

    # baked detail action buttons (Plezy action_buttons.dart, TV): idle = surface @38% + text glyph,
    # focus = text fill + bg glyph. 2x resolution for the fixed-size ones.
    S2 = ACTION_SIZE * 2
    for symbol in ACTION_ICONS:
        g2 = glyph(symbol, int(S2 * 0.46))           # 21/46 of the button
        off2 = ((S2 - g2.width) // 2, (S2 - g2.height) // 2)
        disc = circle(S2).getchannel('A')
        save(compose(disc, g2, ACTION_IDLE, TEXT + (255,), off2), os.path.join('action', symbol + '.png'))
        save(compose(disc, g2, ACTION_FOCUS, BG + (255,), off2), os.path.join('action', symbol + '-focus.png'))
        # icon-only stadium (movies/episodes Play: 72 x 56)
        pw, ph = 72 * 2, S2
        pill = rounded_alpha(pw, ph, ph // 2)
        offp = ((pw - g2.width) // 2, (ph - g2.height) // 2)
        save(compose(pill, g2, ACTION_IDLE, TEXT + (255,), offp), os.path.join('action', 'pill-' + symbol + '.png'))
        save(compose(pill, g2, ACTION_FOCUS, BG + (255,), offp), os.path.join('action', 'pill-' + symbol + '-focus.png'))
        # labelled stadium, 1x with the glyph in the left cap: border="64,28,28,28", textoffsetx 62
        lw, lh = 100, ACTION_SIZE
        g1 = glyph(symbol, 28)
        lab = rounded_alpha(lw, lh, lh // 2)
        offl = (20, (lh - 28) // 2)
        save(compose(lab, g1, ACTION_IDLE, TEXT + (255,), offl), os.path.join('action', 'label-' + symbol + '.png'))
        save(compose(lab, g1, ACTION_FOCUS, BG + (255,), offl), os.path.join('action', 'label-' + symbol + '-focus.png'))
    # split "play version" segment (42 x 56 at 2x): r8 joined corner on the left, stadium on the right
    vw = 42 * 2
    seg = rounded_alpha(vw, S2, (16, S2 // 2, S2 // 2, 16))
    gv = glyph('keyboard_arrow_down', int(S2 * 0.46))
    offv = ((vw - gv.width) // 2 - 4, (S2 - gv.height) // 2)
    save(compose(seg, gv, ACTION_IDLE, TEXT + (255,), offv), os.path.join('action', 'version.png'))
    save(compose(seg, gv, ACTION_FOCUS, BG + (255,), offv), os.path.join('action', 'version-focus.png'))
    # matching left segment for Play when a version split follows (72 x 56 at 2x)
    segl = rounded_alpha(72 * 2, S2, (S2 // 2, 16, 16, S2 // 2))
    for symbol in ('play_arrow', 'resume'):
        gp = glyph(symbol, int(S2 * 0.46))
        offs = ((72 * 2 - gp.width) // 2, (S2 - gp.height) // 2)
        save(compose(segl, gp, ACTION_IDLE, TEXT + (255,), offs), os.path.join('action', 'split-' + symbol + '.png'))
        save(compose(segl, gp, ACTION_FOCUS, BG + (255,), offs), os.path.join('action', 'split-' + symbol + '-focus.png'))
    print('action buttons:', len(ACTION_ICONS))

    def plain(symbol, size):
        return alpha_img(glyph(symbol, size))

    def disc_knockout(symbol, size):
        # legacy "-focus" button art: white disc with the glyph knocked out
        d = circle(size).getchannel('A')
        return alpha_img(ImageChops.subtract(d, glyph(symbol, size, 0.62)))

    # swap the legacy Plex glyphs the add-on references by path for the Plezy (Material Symbols) ones
    legacy = os.path.join(media, 'buttons')
    for name in ('search', 'home'):
        save_to(plain(name, 40), os.path.join(legacy, name + '.png'))
        save_to(disc_knockout(name, 71), os.path.join(legacy, name + '-focus.png'))
    types = os.path.join(media, 'home', 'type')
    for name, symbol in (('home', 'home'), ('movie', 'movie'), ('show', 'tv'), ('artist', 'music_note'),
                         ('photo', 'photo'), ('playlists', 'playlist_play'), ('watchlist', 'bookmark'),
                         ('channels', 'live_tv')):
        save_to(plain(symbol, 72), os.path.join(types, name + '.png'))
print('textures written to', out)
