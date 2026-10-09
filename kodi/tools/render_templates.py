"""Render every script-plex-*.xml.tpl for every theme x indicator style, outside Kodi.

usage: python3 -I render_templates.py <addon_root> <out_dir> [--res WxH]
Mirrors lib/templating/render.py + core.py (prepare_template_data) without Kodi; a resolution other than 16:9
exercises the vscale path. Failing layouts are listed and skipped.
"""
import copy, glob, os, sys, types

root = os.path.abspath(sys.argv[1])
out_dir = os.path.abspath(sys.argv[2])
res = (1920, 1080)
if '--res' in sys.argv:
    w, h = sys.argv[sys.argv.index('--res') + 1].split('x')
    res = (int(w), int(h))

sys.path.append(os.path.join(root, 'lib', '_included_packages'))  # append: its py2 typing.py must not shadow stdlib

# stub the Kodi-dependent modules the templating package touches
lib = types.ModuleType('lib'); lib.__path__ = [os.path.join(root, 'lib')]
sys.modules['lib'] = lib
lg = types.ModuleType('lib.logging'); lg.log = lambda *a, **k: None; lg.log_error = lg.log
sys.modules['lib.logging'] = lg
import importlib.util
def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec); sys.modules[name] = m; spec.loader.exec_module(m); return m
load('lib.aspectratio', os.path.join(root, 'lib', 'aspectratio.py'))
tpl = types.ModuleType('lib.templating'); tpl.__path__ = [os.path.join(root, 'lib', 'templating')]
sys.modules['lib.templating'] = tpl
util = load('lib.templating.util', os.path.join(root, 'lib', 'templating', 'util.py'))
load('lib.templating.filters', os.path.join(root, 'lib', 'templating', 'filters.py'))
ctxmod = load('lib.templating.context', os.path.join(root, 'lib', 'templating', 'context.py'))

import ibis
from ibis.context import ContextDict

def build_stack(inheritor, sources):
    inherit_from = inheritor.pop("INHERIT", None)
    data_stack = [inheritor]
    while inherit_from:
        inheritor = ContextDict(copy.deepcopy(sources[inherit_from]))
        inherit_from = inheritor.pop("INHERIT", None)
        data_stack.append(inheritor)
    return data_stack

def prepare(thm, context):
    tc = {"theme": {}}
    data_stack = build_stack({"INHERIT": thm}, context.pop("themes"))
    while data_stack:
        util.deep_update(tc["theme"], data_stack.pop())
    for ctx in ("core", "indicators"):
        if "START" not in context[ctx]:
            data_stack.append(context[ctx])
        else:
            data_stack = build_stack(context[ctx]["START"], context[ctx])
        tc[ctx] = ContextDict()
        while data_stack:
            util.deep_update(tc[ctx], data_stack.pop())
    return ContextDict(tc)

tdir = os.path.join(root, 'resources', 'skins', 'Main', '1080i', 'templates')
loader = ibis.loaders.FileLoader(tdir)
ibis.loader = loader
names = sorted(os.path.basename(f) for f in glob.glob(os.path.join(tdir, 'script-plex-*.xml.tpl')))
themes = [t for t in ctxmod.TEMPLATE_CONTEXTS['themes'] if t != 'base']
styles = [s for s in ctxmod.TEMPLATE_CONTEXTS['indicators'] if s != 'base']
needs_scaling = res != (1920, 1080) and abs(res[0] / res[1] - 16 / 9) > 0.01
count = 0
failures = []
for theme in themes:
    for style in styles:
        context = copy.deepcopy(ctxmod.TEMPLATE_CONTEXTS)
        util.deep_update(context, {
            "core": {"resolution": list(res), "needs_scaling": needs_scaling, "hub_count": 8},
            "indicators": {"START": {"INHERIT": style, "style": style, "hide_aw_bg": False, "use_scaling": True}},
        })
        data = prepare(theme, context)
        d = os.path.join(out_dir, theme, style); os.makedirs(d, exist_ok=True)
        for n in names:
            loader.cache = {}
            try:
                xml = loader(n).render(copy.deepcopy(data))
            except Exception as e:
                failures.append('%s/%s/%s: %s' % (theme, style, n, str(e).splitlines()[0]))
                continue
            with open(os.path.join(d, n[:-4]), 'w', encoding='utf-8') as f:
                f.write(xml)
            count += 1
print('rendered', count, 'layouts:', len(names), 'templates x', len(themes), 'themes x', len(styles), 'indicator styles')
print('failures:', len(failures))
for line in sorted(set(f.split(': ', 1)[0].split('/', 2)[0] + '/' + f.split('/', 2)[2] for f in failures)):
    print('  ', line)
