#!/usr/bin/env python3
"""
Approximate static preview of a rendered script.plezy.native window, without Kodi.

usage: python3 preview_layout.py <addon_root> <rendered.xml> <scenario.json> <out.png>

It walks the Kodi window XML that the add-on's templating writes (script-plex-*.xml), evaluates visibility
conditions and conditional fade/slide animations against the scenario's window properties, focus and list
contents, and draws images, labels, textboxes, groups, grouplists and lists with PIL. Fonts, text metrics,
scrolling, timing and most Kodi infolabels are approximations: use it to judge layout and overlap, then
confirm on a device.

scenario.json:
  {"focus": 400, "props": {"hub.focus": "0", ...}, "time": "20:41",
   "lists": {"101": {"selected": 1, "items": [{"label": "Movies", "thumb": "script.plex/home/type/movie.png",
                                                "props": {"item": "1"}}]}},
   "images": {"poster:Arrival": {"size": [200, 300], "colors": ["#3a4a6b", "#0e1420"], "text": "ARRIVAL"}}}
Any texture value "mock:<key>" is drawn from "images" (a two-colour gradient with optional text).
Also supported (merged from the wave-1 screen work): textbox/label auto size with max, vertical grouplists with
align bottom/right/center, usecontrolcoords, togglebutton usealttexture, zoom animations, posy ending in "r",
String.Contains, and the scenario keys overrides/infolabels/bools/backdrop.
"""
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = os.path.abspath(sys.argv[1])
MEDIA = os.path.join(ROOT, 'resources', 'skins', 'Main', 'media')
W, H = 1920, 1080

FONT_DIRS = ['/usr/share/fonts/opentype/inter', '/usr/share/fonts/truetype/dejavu']
FONT_FILES = {False: ['Inter-Regular.otf', 'DejaVuSans.ttf'], True: ['Inter-Bold.otf', 'DejaVuSans-Bold.ttf']}
# rough Estuary (1080p) sizes for the fonts the add-on uses
FONT_SIZES = {'font10': 24, 'font12': 27, 'font13': 30, 'font14': 33, 'font20_title': 36, 'font32_title': 44,
              'font45': 45, 'font60': 60, 'WeatherTemp': 60}
BOLD_FONTS = {'font20_title', 'font32_title'}
_font_cache = {}


def font(name, bold=False):
    size = FONT_SIZES.get(name, 30)
    bold = bold or name in BOLD_FONTS
    key = (size, bold)
    if key not in _font_cache:
        for d in FONT_DIRS:
            for fn in FONT_FILES[bold]:
                p = os.path.join(d, fn)
                if os.path.exists(p):
                    _font_cache[key] = ImageFont.truetype(p, size)
                    break
            if key in _font_cache:
                break
        else:
            _font_cache[key] = ImageFont.load_default()
    return _font_cache[key]


class State(object):
    def __init__(self, scenario):
        self.focus = int(scenario.get('focus', 0))
        self.props = scenario.get('props', {})
        self.lists = {int(k): v for k, v in scenario.get('lists', {}).items()}
        self.images = scenario.get('images', {})
        self.time = scenario.get('time', '20:41')
        self.groups = {}       # control id -> set of descendant control ids
        self.visible = {}      # control id -> visibility (filled as we go)
        self.item = None       # current ListItem dict while drawing a layout
        self.labels = scenario.get('addon_strings', {})
        self.overrides = {str(k): v for k, v in scenario.get('overrides', {}).items()}
        self.infolabels = scenario.get('infolabels', {})
        self.bools = scenario.get('bools', {})
        self.in_focused_item = False


# ---------------------------------------------------------------- infolabels + conditions

def resolve(text, st):
    if text is None:
        return ''

    def info(m):
        return infolabel(m.group(1), st)
    text = re.sub(r'\(\$INFO\[[^\]]*\]\)', '', text)  # Player.Time($INFO[...]) -> Player.Time
    text = re.sub(r'\$INFO\[([^\],]+?)(?:,([^,\]]*)(?:,([^\]]*))?)?\]',
                  lambda m: (lambda v: ((m.group(2) or '') + v + (m.group(3) or '')) if v else '')(info(m)), text)
    text = re.sub(r'\$ADDON\[[\w.]+ (\d+)\]', lambda m: st.labels.get(m.group(1), m.group(1)), text)
    return text


def item_value(item, what):
    if item is None:
        return ''
    if what == 'Label':
        return item.get('label', '')
    if what == 'Label2':
        return item.get('label2', '')
    if what in ('Thumb', 'Icon', 'Art(thumb)'):
        return item.get('thumb', '')
    m = re.match(r'Property\((.+)\)$', what)
    if m:
        return item.get('props', {}).get(m.group(1), '')
    return ''


def infolabel(name, st):
    m = re.match(r'Window(?:\(\d+\))?\.Property\((.+)\)$', name)
    if m:
        return st.props.get(m.group(1), '')
    m = re.match(r'ListItem\.(.+)$', name)
    if m:
        return item_value(st.item, m.group(1))
    m = re.match(r'Container\((\d+)\)\.ListItem\.(.+)$', name)
    if m:
        lst = st.lists.get(int(m.group(1)))
        if not lst or not lst.get('items'):
            return ''
        return item_value(lst['items'][lst.get('selected', 0)], m.group(2))
    m = re.match(r'Container\((\d+)\)\.NumItems$', name)
    if m:
        return str(len(st.lists.get(int(m.group(1)), {}).get('items', [])))
    if name in st.infolabels:
        return st.infolabels[name]
    if name.startswith('Player.') and name.split('(')[0] in st.infolabels:
        return st.infolabels[name.split('(')[0]]
    if name == 'System.Time':
        return st.time
    if name == 'System.CurrentControlID':
        return str(st.focus)
    return ''


def has_focus(cid, st):
    if st.focus == cid:
        return True
    return st.focus in st.groups.get(cid, ())


def atom(expr, st):
    expr = expr.strip()
    if expr in st.bools:
        return bool(st.bools[expr])
    if expr in ('true', 'True', 'yes'):
        return True
    if expr in ('false', 'False', 'no', ''):
        return False
    m = re.match(r'(\w+(?:\.\w+)*)\((.*)\)$', expr, flags=re.S)
    if not m:
        return False
    fn, args = m.group(1), m.group(2)
    if fn == 'String.IsEmpty':
        return infolabel(args, st) == ''
    if fn == 'String.Contains':
        a, b = args.split(',', 1)
        return b.strip().lower() in infolabel(a, st).lower()
    if fn == 'String.IsEqual':
        a, b = args.split(',', 1)
        return infolabel(a, st) == b.strip()
    if fn in ('Integer.IsGreater', 'Integer.IsLess', 'Integer.IsEqual'):
        a, b = args.split(',', 1)
        try:
            va = float(infolabel(a, st))
        except ValueError:
            return False
        vb = float(b)
        return {'Integer.IsGreater': va > vb, 'Integer.IsLess': va < vb, 'Integer.IsEqual': va == vb}[fn]
    if fn == 'Control.HasFocus':
        return st.focus == int(args)
    if fn == 'Control.IsVisible':
        return st.visible.get(int(args), True)
    gm = re.match(r'ControlGroup\((\d+)\)\.HasFocus\((\d+)\)$', expr)
    if gm:
        return has_focus(int(gm.group(1)), st) if gm.group(2) == '0' else st.focus == int(gm.group(2))
    return False


def cond(expr, st):
    """Kodi boolean: ! not, + and, | or, [ ] grouping."""
    tokens = re.findall(r'\[|\]|\+|\||!|[^\[\]+|!]+(?:\([^()]*(?:\([^()]*\))*[^()]*\))?[^\[\]+|!]*', expr)
    tokens = [t.strip() for t in tokens if t.strip()]
    pos = [0]

    def parse_or():
        v = parse_and()
        while pos[0] < len(tokens) and tokens[pos[0]] == '|':
            pos[0] += 1
            r = parse_and()
            v = v or r
        return v

    def parse_and():
        v = parse_not()
        while pos[0] < len(tokens) and tokens[pos[0]] == '+':
            pos[0] += 1
            r = parse_not()
            v = v and r
        return v

    def parse_not():
        if pos[0] < len(tokens) and tokens[pos[0]] == '!':
            pos[0] += 1
            return not parse_not()
        if pos[0] < len(tokens) and tokens[pos[0]] == '[':
            pos[0] += 1
            v = parse_or()
            pos[0] += 1  # ]
            return v
        t = tokens[pos[0]]
        pos[0] += 1
        return atom(t, st)

    return parse_or() if tokens else True


# ---------------------------------------------------------------- drawing helpers

def colour(value, default='FFFFFFFF'):
    value = (value or default).strip()
    if value.lower().startswith('0x'):
        value = value[2:]
    if not re.fullmatch(r'[0-9A-Fa-f]{8}', value):
        value = {'black': 'FF000000', 'white': 'FFFFFFFF'}.get(value.lower(), default)
    a, r, g, b = (int(value[i:i + 2], 16) for i in (0, 2, 4, 6))
    return r, g, b, a


def mock_image(key, st, size):
    spec = st.images.get(key, {})
    w, h = spec.get('size', size)
    if spec.get('logo'):  # clear logo: bold wordmark on transparency
        a = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        d = ImageDraw.Draw(a)
        f = ImageFont.truetype(os.path.join(FONT_DIRS[0], 'Inter-Bold.otf'), spec.get('text_size', h // 2))
        d.text((0, (h - f.size) / 2), spec['text'], font=f, fill=spec.get('text_color', '#f2f2f2'))
        return a
    c1, c2 = spec.get('colors', ['#404858', '#151820'])
    a = Image.new('RGBA', (w, h))
    top, bottom = Image.new('RGBA', (w, h), c1), Image.new('RGBA', (w, h), c2)
    mask = Image.linear_gradient('L').resize((w, h))
    a = Image.composite(bottom, top, mask)
    if spec.get('text'):
        d = ImageDraw.Draw(a)
        f = ImageFont.truetype(os.path.join(FONT_DIRS[0], 'Inter-Bold.otf'), spec.get('text_size', max(18, w // 9)))
        tw = d.textlength(spec['text'], font=f)
        d.text(((w - tw) / 2, h * spec.get('text_y', 0.42)), spec['text'], font=f, fill=spec.get('text_color', '#f0f0f0'))
    return a


def load_texture(path, st, size):
    path = (path or '').strip()
    if not path or path == '-':
        return None
    if path.startswith('mock:'):
        return mock_image(path[5:], st, size)
    full = os.path.join(MEDIA, path)
    if os.path.exists(full):
        return Image.open(full).convert('RGBA')
    return None


def nine_slice(img, border, w, h):
    l, t, r, b = border
    iw, ih = img.size
    if l + r > iw or t + b > ih:  # Kodi still fills these (e.g. border 10 on a 10px square): plain stretch
        return img.resize((w, h), Image.BILINEAR)
    l, r = min(l, w // 2), min(r, w // 2)
    t, b = min(t, h // 2), min(b, h // 2)
    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    xs = [(0, l, 0, l), (l, iw - r, l, w - r), (iw - r, iw, w - r, w)]
    ys = [(0, t, 0, t), (t, ih - b, t, h - b), (ih - b, ih, h - b, h)]
    for sx0, sx1, dx0, dx1 in xs:
        for sy0, sy1, dy0, dy1 in ys:
            if dx1 > dx0 and dy1 > dy0 and sx1 > sx0 and sy1 > sy0:
                out.alpha_composite(img.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.BILINEAR),
                                    (dx0, dy0))
    return out


def tint(img, rgba):
    r, g, b, a = rgba
    if (r, g, b, a) == (255, 255, 255, 255):
        return img
    ch = img.split()
    out = Image.merge('RGBA', [c.point(lambda v, k=k: v * k // 255) for c, k in zip(ch, (r, g, b, a))])
    return out


def num(v, default=0.0):
    try:
        return float(v)
    except (TypeError, ValueError):
        return default


class Canvas(object):
    def __init__(self, w, h, bg):
        self.img = Image.new('RGBA', (w, h), bg)

    def paste(self, layer, x, y, alpha, clip):
        if alpha < 1:
            layer = layer.copy()
            layer.putalpha(layer.getchannel('A').point(lambda v: int(v * alpha)))
        x, y = int(round(x)), int(round(y))
        if clip:
            cx0, cy0, cx1, cy1 = (int(round(v)) for v in clip)
            lx0, ly0 = max(cx0 - x, 0), max(cy0 - y, 0)
            lx1, ly1 = min(cx1 - x, layer.width), min(cy1 - y, layer.height)
            if lx1 <= lx0 or ly1 <= ly0:
                return
            layer = layer.crop((lx0, ly0, lx1, ly1))
            x, y = x + lx0, y + ly0
        if x + layer.width <= 0 or y + layer.height <= 0 or x >= self.img.width or y >= self.img.height:
            return
        self.img.alpha_composite(layer, (max(x, 0), max(y, 0)),
                                 (max(-x, 0), max(-y, 0)))


# ---------------------------------------------------------------- control tree

def child(el, tag):
    c = el.find(tag)
    return c.text if c is not None and c.text is not None else None


def anim_state(el, st):
    """Conditional fade/slide animations (end state when their condition holds)."""
    alpha, dx, dy = 1.0, 0.0, 0.0
    for a in el.findall('animation'):
        kind = (a.text or '').strip() or a.get('type', '')
        if kind != 'Conditional':
            continue
        if not cond(a.get('condition', 'false'), st):
            continue
        effects = a.findall('effect') or [a]
        for e in effects:
            effect = e.get('effect') or e.get('type')
            if effect == 'fade':
                alpha *= num(e.get('end', 100), 100) / 100.0
            elif effect == 'slide':
                ex, ey = (num(v) for v in (e.get('end', '0,0').split(',') + ['0'])[:2])
                dx, dy = dx + ex, dy + ey
            elif effect == 'zoom':
                pass
    return alpha, dx, dy


def is_visible(el, st):
    vis = [v.text for v in el.findall('visible') if v.text]
    ok = all(cond(v, st) for v in vis)
    cid = el.get('id')
    if cid and cid.isdigit():
        st.visible[int(cid)] = ok
    return ok


def index_groups(el, st, stack=()):
    cid = el.get('id')
    ids = stack + ((int(cid),) if cid and cid.isdigit() else ())
    for c in el.findall('control'):
        ccid = c.get('id')
        if ccid and ccid.isdigit():
            for g in ids:
                st.groups.setdefault(g, set()).add(int(ccid))
        index_groups(c, st, ids)


def ctl_size(el):
    w = child(el, 'width')
    h = child(el, 'height')
    return num(w, 0) if w and w != 'auto' else 0, num(h, 0)


def _max_attr_min(el, tag):
    c = el.find(tag)
    return num(c.get('min'), 0) if c is not None and c.get('min') else 0


def _max_attr(el, tag):
    c = el.find(tag)
    return num(c.get('max'), 0) if c is not None and c.get('max') else 0


def label_text(el, st):
    raw = child(el, 'label') or (('$INFO[' + child(el, 'info') + ']') if child(el, 'info') else '')
    s = resolve(raw, st)
    bold = '[B]' in s or (child(el, 'font') or '') in BOLD_FONTS
    return re.sub(r'\[/?(B|I|UPPERCASE|LOWERCASE|CAPITALIZE)\]', '', s), bold


def measured_size(el, st):
    """Kodi auto sizes: labels with <width>auto</width> fit their text (up to max), textboxes with
    <height>auto</height> fit their wrapped lines (up to max)."""
    w, h = ctl_size(el)
    kind = el.get('type')
    if child(el, 'width') == 'auto' and kind in ('label', 'fadelabel'):
        text, bold = label_text(el, st)
        w = ImageDraw.Draw(Image.new('RGBA', (1, 1))).textlength(text, font=font(child(el, 'font') or 'font13', bold)) if text.strip() else 0
        mx = _max_attr(el, 'width')
        if mx:
            w = min(w, mx)
    if child(el, 'height') == 'auto' and kind == 'textbox':
        text, bold = label_text(el, st)
        fnt = font(child(el, 'font') or 'font13', bold)
        d = ImageDraw.Draw(Image.new('RGBA', (1, 1)))
        lines = 0
        if text.strip():
            for para in text.split('[CR]'):
                line = ''
                lines += 1
                for word in para.split():
                    t = (line + ' ' + word).strip()
                    if d.textlength(t, font=fnt) <= w:
                        line = t
                    else:
                        lines += 1
                        line = word
        asc, desc = fnt.getmetrics()
        h = lines * int((asc + desc) * 1.12)
        mx = _max_attr(el, 'height')
        if mx:
            h = min(h, mx)
    return w, h


def ctl_pos(el, pw, ph):
    x = child(el, 'posx') or child(el, 'left')
    y = child(el, 'posy') or child(el, 'top')
    w, h = ctl_size(el)
    if x and x.endswith('r'):
        x = pw - num(x[:-1]) - 0
    elif child(el, 'right') and not child(el, 'posx'):
        x = pw - num(child(el, 'right')) - w
    if y and y.endswith('r'):
        y = ph - num(y[:-1])
    return num(x), num(y)


def draw_controls(parent, canvas, st, ox, oy, pw, ph, alpha, clip):
    for el in parent.findall('control'):
        draw_control(el, canvas, st, ox, oy, pw, ph, alpha, clip)


def apply_override(el, st):
    cid = el.get('id')
    ov = st.overrides.get(cid) if cid else None
    if not ov:
        return
    for k, v in ov.items():
        e = el.find(k)
        if e is None:
            e = ET.SubElement(el, k)
        e.text = str(v)


def zoom_factor(el, st):
    z = 1.0
    for a in el.findall('animation'):
        kind = (a.text or '').strip() or a.get('type', '')
        if a.get('effect') != 'zoom':
            continue
        if kind == 'Conditional' and cond(a.get('condition', 'false'), st):
            z = num(a.get('end'), 100) / 100.0
        elif kind == 'Focus' and st.in_focused_item:
            z = num(a.get('end'), 100) / 100.0
    return z


def draw_control(el, canvas, st, ox, oy, pw, ph, alpha, clip, at=None):
    apply_override(el, st)
    if not is_visible(el, st):
        return 0
    z = zoom_factor(el, st) if el.get('type') in ('group', 'button', 'togglebutton') else 1.0
    if abs(z - 1.0) > 0.001:
        # draw onto a transparent layer, then scale it about the control centre (center="auto" or explicit)
        layer = Canvas(W, H, (0, 0, 0, 0))
        x0, y0 = at if at is not None else ctl_pos(el, pw, ph)
        a, dx, dy = anim_state(el, st)
        w0, h0 = ctl_size(el)
        cx, cy = ox + x0 + dx + w0 / 2.0, oy + y0 + dy + h0 / 2.0
        for an in el.findall('animation'):
            if an.get('effect') == 'zoom' and an.get('center') and an.get('center') != 'auto':
                parts = [num(v) for v in an.get('center').split(',') if v.strip()]
                if len(parts) >= 2:
                    cx, cy = ox + x0 + dx + parts[0], oy + y0 + dy + parts[1]
                elif parts:  # a lone value is the x centre; Kodi keeps the vertical centre
                    cx = ox + x0 + dx + parts[0]
        saved = el.findall('animation')
        _draw_control_inner(el, layer, st, ox, oy, pw, ph, 1.0, None, at)
        img = layer.img
        nw, nh = int(W * z), int(H * z)
        big = img.resize((nw, nh), Image.LANCZOS)
        offx, offy = int(cx - cx * z), int(cy - cy * z)
        canvas.paste(big, offx, offy, alpha * a, clip)
        return h0
    return _draw_control_inner(el, canvas, st, ox, oy, pw, ph, alpha, clip, at)


def _draw_control_inner(el, canvas, st, ox, oy, pw, ph, alpha, clip, at=None):
    a, dx, dy = anim_state(el, st)
    alpha *= a
    x, y = at if at is not None else ctl_pos(el, pw, ph)
    x, y = ox + x + dx, oy + y + dy
    w, h = measured_size(el, st)
    kind = el.get('type')
    if alpha <= 0.01:
        return h
    if kind == 'group':
        draw_controls(el, canvas, st, x, y, w or pw, h or ph, alpha, clip)
    elif kind == 'grouplist':
        draw_grouplist(el, canvas, st, x, y, w, h, alpha, clip)
    elif kind in ('list', 'panel', 'fixedlist', 'wraplist'):
        draw_list(el, canvas, st, x, y, w, h, alpha, clip)
    elif kind == 'image':
        draw_image(el, canvas, st, x, y, w, h, alpha, clip)
    elif kind in ('label', 'textbox', 'fadelabel'):
        draw_label(el, canvas, st, x, y, w, h, alpha, clip, wrap=kind == 'textbox')
    elif kind in ('button', 'radiobutton', 'togglebutton', 'edit'):
        draw_button(el, canvas, st, x, y, w, h, alpha, clip)
    return h


def _text_width(raw, fnt_name, st):
    s = resolve(raw, st)
    return ImageDraw.Draw(Image.new('RGBA', (1, 1))).textlength(
        re.sub(r'\[/?(B|I|UPPERCASE|LOWERCASE|CAPITALIZE)\]', '', s), font=font(fnt_name or 'font13', '[B]' in s))


def button_auto_width(c, st):
    off = num(child(c, 'textoffsetx'), 0)
    fn = child(c, 'font')
    w = _text_width(child(c, 'label') or '', fn, st) + 2 * off
    l2 = child(c, 'label2')
    if l2 and resolve(l2, st).strip():
        w += _text_width(l2, fn, st) + 2 * off + 10
    we = c.find('width')
    mx = num(we.get('max'), 0) if we is not None else 0
    w = max(w, _max_attr_min(c, 'width'), 1)
    return min(w, mx) if mx else w


def auto_width(c, st):
    """Width of a control in a horizontal grouplist; buttons with <width>auto</width> fit their label."""
    cw, _ = ctl_size(c)
    if not cw and c.get('type') in ('label', 'fadelabel'):
        return measured_size(c, st)[0]
    if cw or c.get('type') not in ('button', 'togglebutton'):
        return cw
    return button_auto_width(c, st)


def draw_grouplist(el, canvas, st, x, y, w, h, alpha, clip):
    gap = num(child(el, 'itemgap'), 0)
    vertical = (child(el, 'orientation') or 'vertical') == 'vertical'
    sub_clip = intersect(clip, (x, y, x + w, y + h))
    kids = [c for c in el.findall('control') if is_visible(c, st)]
    sizes = [(measured_size(c, st)[1] + num(child(c, 'posy'), 0) if vertical else auto_width(c, st)) for c in kids]
    if vertical:  # usecontrolcoords: an item's posy shifts it and the items after it
        sizes = [measured_size(c, st)[1] for c in kids]
    cur = 0.0
    align = child(el, 'align') or 'left'
    if align in ('right', 'bottom', 'center'):
        total = sum(sizes) + gap * max(len(kids) - 1, 0)
        total += sum(num(child(c, 'posy' if vertical else 'posx'), 0) for c in kids) if child(el, 'usecontrolcoords') == 'true' else 0
        span = h if vertical else w
        cur = (span - total) if align in ('right', 'bottom') else (span - total) / 2
    for c, size in zip(kids, sizes):
        px, py = ctl_pos(c, w, h)
        pos = (px, cur + py) if vertical else (cur + px, py)
        if not vertical and c.get('type') == 'button' and not ctl_size(c)[0]:
            draw_button(c, canvas, st, x + pos[0], y + pos[1], auto_width(c, st), ctl_size(c)[1], alpha, sub_clip)
        elif not vertical and c.get('type') == 'label' and not ctl_size(c)[0]:
            draw_label(c, canvas, st, x + pos[0], y + pos[1], auto_width(c, st) + 4, ctl_size(c)[1], alpha, sub_clip)
        else:
            draw_control(c, canvas, st, x, y, w, h, alpha, sub_clip, at=pos)
        cur += size + gap
        if child(el, 'usecontrolcoords') == 'true':
            cur += (py if vertical else px)


def intersect(a, b):
    if a is None:
        return b
    return max(a[0], b[0]), max(a[1], b[1]), min(a[2], b[2]), min(a[3], b[3])


def pick_layout(el, tag, st):
    for lay in el.findall(tag):
        c = lay.get('condition')
        if not c or cond(c, st):
            return lay
    return None


def draw_list(el, canvas, st, x, y, w, h, alpha, clip):
    cid = int(el.get('id', '0') or 0)
    data = st.lists.get(cid)
    if not data:
        return
    items = data.get('items', [])
    sel = data.get('selected', 0)
    vertical = (child(el, 'orientation') or 'vertical') == 'vertical'
    sub_clip = intersect(clip, (x, y, x + w, y + h))
    cur = 0.0
    col = 0.0  # panels wrap: items flow along the cross axis first
    for i, item in enumerate(items):
        st.item = item
        lay = pick_layout(el, 'focusedlayout' if i == sel else 'itemlayout', st)
        st.in_focused_item = (i == sel and st.focus == cid)
        if lay is None:
            continue
        lw, lh = num(lay.get('width'), w), num(lay.get('height'), h)
        if el.get('type') == 'panel':
            if vertical and col + lw > w + 0.5:
                col, cur = 0.0, cur + lh
            lx, ly = x + col, y + cur
            if ly > y + h:
                break
            draw_controls(lay, canvas, st, lx, ly, lw, lh, alpha, sub_clip)
            col += lw
            continue
        lx, ly = (x, y + cur) if vertical else (x + cur, y)
        if (vertical and ly > y + h) or (not vertical and lx > x + w):
            break
        draw_controls(lay, canvas, st, lx, ly, lw, lh, alpha, sub_clip)
        cur += lh if vertical else lw
    st.item = None
    st.in_focused_item = False


def draw_image(el, canvas, st, x, y, w, h, alpha, clip):
    tex = el.find('texture')
    if tex is None or w <= 0 or h <= 0:
        return
    src = resolve(tex.text, st)
    img = load_texture(src, st, (int(w), int(h)))
    if img is None and tex.get('fallback'):
        img = load_texture(tex.get('fallback'), st, (int(w), int(h)))
    if img is None:
        return
    w, h = int(round(w)), int(round(h))
    ar = el.find('aspectratio')
    mode = (ar.text if ar is not None else 'stretch') or 'stretch'
    border = tex.get('border')
    if border:
        b = [int(float(v)) for v in border.split(',')]
        b = b * 4 if len(b) == 1 else b
        layer = nine_slice(img, b, w, h)
        offx = offy = 0
    elif mode == 'keep':
        s = min(w / img.width, h / img.height)
        nw, nh = max(1, int(img.width * s)), max(1, int(img.height * s))
        sc = img.resize((nw, nh), Image.LANCZOS)
        layer = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        ax = {'left': 0, 'right': w - nw}.get(ar.get('align') if ar is not None else None, (w - nw) // 2)
        ay = {'top': 0, 'bottom': h - nh}.get(ar.get('aligny') if ar is not None else None, (h - nh) // 2)
        layer.alpha_composite(sc, (ax, ay))
        offx = offy = 0
    elif mode == 'scale':
        s = max(w / img.width, h / img.height)
        sc = img.resize((max(1, int(img.width * s + 0.5)), max(1, int(img.height * s + 0.5))), Image.LANCZOS)
        l, t = (sc.width - w) // 2, (sc.height - h) // 2
        layer = sc.crop((l, t, l + w, t + h))
        offx = offy = 0
    else:
        layer = img.resize((w, h), Image.LANCZOS)
        offx = offy = 0
    if tex.get('flipx') == 'true':
        layer = layer.transpose(Image.FLIP_LEFT_RIGHT)
    if tex.get('flipy') == 'true':
        layer = layer.transpose(Image.FLIP_TOP_BOTTOM)
    diffuse = tex.get('diffuse')
    if diffuse:
        mask = load_texture(diffuse, st, (w, h))
        if mask is not None:
            m = mask.getchannel('A').resize((w, h), Image.LANCZOS)
            layer.putalpha(ImageChops.multiply(layer.getchannel('A'), m))
    cd = tex.get('colordiffuse') or child(el, 'colordiffuse')
    if cd:
        layer = tint(layer, colour(resolve(cd, st)))
    canvas.paste(layer, x + offx, y + offy, alpha, clip)


def text_layer(text, fnt, color, w, h, align, aligny, wrap, shadow=None):
    layer = Image.new('RGBA', (max(1, int(w)), max(1, int(h))), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    lines = []
    if wrap:
        for para in text.split('[CR]'):
            words, line = para.split(), ''
            for word in words:
                t = (line + ' ' + word).strip()
                if d.textlength(t, font=fnt) <= w:
                    line = t
                else:
                    lines.append(line)
                    line = word
            lines.append(line)
    else:
        line = text
        if d.textlength(line, font=fnt) > w:
            while line and d.textlength(line + u'…', font=fnt) > w:
                line = line[:-1]
            line += u'…'
        lines = [line]
    asc, desc = fnt.getmetrics()
    lh = int((asc + desc) * 1.12)
    total = lh * len(lines)
    ty = (h - total) / 2 if aligny == 'center' else 0
    for i, line in enumerate(lines):
        if ty + (i + 1) * lh > h + 4 and wrap:
            break
        tw = d.textlength(line, font=fnt)
        tx = {'center': (w - tw) / 2, 'right': w - tw}.get(align, 0)
        if shadow:
            d.text((tx + 2, ty + i * lh + 2), line, font=fnt, fill=shadow)
        d.text((tx, ty + i * lh), line, font=fnt, fill=color)
    return layer


def draw_label(el, canvas, st, x, y, w, h, alpha, clip, wrap=False, text=None, color=None):
    raw = text if text is not None else (child(el, 'label') or (('$INFO[' + child(el, 'info') + ']') if child(el, 'info') else ''))
    s = resolve(raw, st)
    bold = '[B]' in s
    s = re.sub(r'\[/?(B|I|UPPERCASE|LOWERCASE|CAPITALIZE)\]|\[/?COLOR[^\]]*\]', '', s)
    if '[UPPERCASE]' in (raw or ''):
        s = s.upper()
    if not s.strip() or w <= 0:
        return
    fnt = font(child(el, 'font') or 'font13', bold)
    col = colour(color or resolve(child(el, 'textcolor'), st))
    sh = child(el, 'shadowcolor')
    layer = text_layer(s, fnt, col, w, h or fnt.size * 1.4, child(el, 'align') or 'left',
                       child(el, 'aligny') or 'top', wrap, colour(sh) if sh else None)
    canvas.paste(layer, x, y, alpha, clip)


def draw_button(el, canvas, st, x, y, w, h, alpha, clip):
    focused = st.focus == int(el.get('id', '-1') or -1)
    tex = el.find('texturefocus' if focused else 'texturenofocus')
    if el.get('type') == 'togglebutton' and child(el, 'usealttexture') and cond(child(el, 'usealttexture'), st):
        alt = el.find('alttexturefocus' if focused else 'alttexturenofocus')
        tex = alt if alt is not None else tex
    if w <= 0:  # auto width, Kodi's rule
        w = button_auto_width(el, st)
    if tex is not None and tex.text and tex.text.strip() != '-':
        fake = ET.Element('control', type='image')
        t = ET.SubElement(fake, 'texture', dict(tex.attrib))
        t.text = tex.text
        draw_image(fake, canvas, st, x, y, w, h, alpha, clip)
    col = child(el, 'focusedcolor') if focused else child(el, 'textcolor')
    off = num(child(el, 'textoffsetx'), 0)
    text = None
    if el.get('type') == 'togglebutton' and child(el, 'usealttexture') and cond(child(el, 'usealttexture'), st) and child(el, 'altlabel'):
        text = child(el, 'altlabel')
        m = re.search(r'\[COLOR ([0-9A-Fa-f]{8})\]', text)
        if m:
            col = m.group(1)
    draw_label(el, canvas, st, x + off, y, w - 2 * off, h, alpha, clip, text=text, color=col)
    l2 = child(el, 'label2')
    if l2 and resolve(l2, st).strip():  # label2 is drawn right-aligned inside the button
        shim = ET.Element('control', type='label')
        for tag in ('font', 'aligny'):
            if child(el, tag):
                ET.SubElement(shim, tag).text = child(el, tag)
        ET.SubElement(shim, 'align').text = 'right'
        draw_label(shim, canvas, st, x + off, y, w - 2 * off, h, alpha, clip, text=l2, color=col)
    return w


def main():
    xml_path, scenario_path, out_path = sys.argv[2:5]
    scenario = json.load(open(scenario_path))
    st = State(scenario)
    tree = ET.parse(xml_path).getroot()
    index_groups(tree.find('controls'), st)
    canvas = Canvas(W, H, colour(scenario.get('window_bg', 'FF000000')))
    # two passes: the first fills control visibility used by Control.IsVisible conditions
    for _ in range(2):
        canvas = Canvas(W, H, colour(scenario.get('window_bg', 'FF000000')))
        if scenario.get('backdrop_png'):
            canvas.paste(Image.open(scenario['backdrop_png']).convert('RGBA'), 0, 0, 1.0, None)
        if scenario.get('backdrop'):
            canvas.paste(mock_image(scenario['backdrop'], st, (W, H)).resize((W, H)), 0, 0, 1.0, None)
        draw_controls(tree.find('controls'), canvas, st, 0, 0, W, H, 1.0, None)
    canvas.img.convert('RGB').save(out_path)
    print('preview written to', out_path)


if __name__ == '__main__':
    main()
