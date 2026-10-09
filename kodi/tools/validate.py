#!/usr/bin/env python3
"""
Render every template at 1080p and 4:3 and check both renders against baseline renders of the previous release.

usage: python3 -I validate.py <addon_root> <work_dir> <baseline_1080> <baseline_43> [--only name,name]

<work_dir> receives render_1080/ and render_43/. --only limits the report to layouts whose file name contains one
of the given substrings (e.g. --only pre_play,episodes); rendering always covers everything. Exit status is 1 when
a reported layout fails to render or fails a check.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
addon, work, base_1080, base_43 = (os.path.abspath(p) for p in sys.argv[1:5])
only = []
if '--only' in sys.argv:
    only = [s for s in sys.argv[sys.argv.index('--only') + 1].split(',') if s]


def relevant(line):
    return not only or any(o in line for o in only)


bad = False
for res, base in (('1920x1080', base_1080), ('1440x1080', base_43)):
    out = os.path.join(work, 'render_1080' if res == '1920x1080' else 'render_43')
    subprocess.run(['rm', '-rf', out], check=True)
    r = subprocess.run([sys.executable, '-I', os.path.join(HERE, 'render_templates.py'), addon, out, '--res', res],
                       capture_output=True, text=True)
    lines = r.stdout.splitlines()
    fails = [l for l in lines if l.startswith('   ') and relevant(l)]
    print('[{0}] {1}'.format(res, lines[0] if lines else r.stderr.strip()[-300:]))
    for l in fails:
        print('  render failure:', l.strip())
    bad |= bool(fails) or r.returncode != 0
    c = subprocess.run([sys.executable, '-I', os.path.join(HERE, 'check_layouts.py'), addon, base, out],
                       capture_output=True, text=True)
    problems = [l for l in c.stdout.splitlines()[1:] if l.startswith('   ') and relevant(l)]
    print('[{0}] check: {1} relevant problems'.format(res, len(problems)))
    for l in problems:
        print('  ', l.strip())
    bad |= bool(problems)
subprocess.run(['find', addon, '-name', '__pycache__', '-type', 'd', '-prune', '-exec', 'rm', '-rf', '{}', '+'])
sys.exit(1 if bad else 0)
