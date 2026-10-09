#!/usr/bin/env python3
"""
Build the installable add-on ZIP ("Install from zip file" in Kodi).

usage: python3 build_zip.py <addon_dir> <out.zip>

The archive holds the add-on folder itself (script.plezy.native/...), which is what Kodi expects. Templates are
rendered on the device, so rendered skin XML, caches and editor files are left out.
"""
import fnmatch
import os
import sys
import zipfile

SKIP_DIRS = {'__pycache__', '.pytest_cache', '.idea', '.vscode', '.claude', '.venv', 'tests'}
SKIP_FILES = ['*.pyc', '*.pyo', '.DS_Store']
SKIP_PATHS = ['resources/skins/Main/1080i/*.xml']  # rendered at runtime from templates/

src = os.path.abspath(sys.argv[1])
out = os.path.abspath(sys.argv[2])
top = os.path.basename(src)
count = 0
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk(src):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS)
        for fn in sorted(files):
            full = os.path.join(root, fn)
            rel = os.path.relpath(full, src).replace(os.sep, '/')
            if any(fnmatch.fnmatch(fn, p) for p in SKIP_FILES) or any(fnmatch.fnmatch(rel, p) for p in SKIP_PATHS):
                continue
            z.write(full, top + '/' + rel)
            count += 1
print('{0}: {1} files, {2:.1f} MB'.format(out, count, os.path.getsize(out) / 1e6))
