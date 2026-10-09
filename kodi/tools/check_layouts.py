"""Compare a fresh render against the baseline render.

usage: python3 -I check_layouts.py <addon_root> <baseline_dir> <new_dir>
(both dirs from render_templates.py; render the previous release as the baseline)
Checks: well-formed XML; every static script.plex/ texture exists; fonts stay within the baseline set;
no control id present in a baseline layout is missing from the new one; no duplicate ids per layout.
"""
import collections, glob, os, re, sys
import xml.etree.ElementTree as ET

root, base_dir, new_dir = (os.path.abspath(p) for p in sys.argv[1:4])
media = os.path.join(root, 'resources', 'skins', 'Main', 'media')
TEX_TAGS = {'texture', 'texturefocus', 'texturenofocus', 'alttexturefocus', 'alttexturenofocus', 'texturebg',
            'midtexture', 'lefttexture', 'righttexture', 'overlaytexture', 'nibtexture', 'nibtexturefocus',
            'texturesliderbar', 'texturesliderbarfocus', 'textureradioonfocus', 'textureradioonnofocus',
            'textureradioofffocus', 'textureradiooffnofocus', 'imagepath', 'bordertexture'}

def scan(path):
    tree = ET.parse(path)
    ids, fonts, tex = [], set(), set()
    for el in tree.iter():
        if el.tag == 'control' and el.get('id'):
            ids.append(el.get('id'))
        if el.tag == 'font' and el.text:
            fonts.add(el.text.strip())
        if el.tag in TEX_TAGS:
            for v in (el.text, el.get('diffuse')):
                if v and v.strip().startswith('script.plex/') and '$' not in v:
                    tex.add(v.strip())
    return ids, fonts, tex

errors = []
base_fonts = set()
for f in glob.glob(os.path.join(base_dir, '**', '*.xml'), recursive=True):
    base_fonts |= scan(f)[1]

n = 0
for f in sorted(glob.glob(os.path.join(new_dir, '**', '*.xml'), recursive=True)):
    rel = os.path.relpath(f, new_dir); n += 1
    try:
        ids, fonts, tex = scan(f)
    except ET.ParseError as e:
        errors.append('%s: XML error %s' % (rel, e)); continue
    dups = [i for i, c in collections.Counter(ids).items() if c > 1]
    bf = os.path.join(base_dir, rel)
    if os.path.exists(bf):
        bids = scan(bf)[0]
        missing = sorted(set(bids) - set(ids), key=int)
        if missing:
            errors.append('%s: control ids removed: %s' % (rel, missing))
        bd = {i for i, c in collections.Counter(bids).items() if c > 1}
        dups = [d for d in dups if d not in bd]
    if dups:
        errors.append('%s: new duplicate ids: %s' % (rel, dups))
    for t in tex:
        if not os.path.exists(os.path.join(media, t)):
            errors.append('%s: missing texture %s' % (rel, t))
    extra = fonts - base_fonts
    if extra:
        errors.append('%s: fonts outside baseline set: %s' % (rel, sorted(extra)))

uniq = sorted(set(e.split(': ', 1)[1] + '  [' + e.split('/')[-1].split(':')[0] + ']' for e in errors))
print('checked', n, 'layouts;', len(errors), 'problems')
for e in uniq[:80]:
    print('  ', e)
print('baseline fonts:', sorted(base_fonts))
sys.exit(1 if errors else 0)
