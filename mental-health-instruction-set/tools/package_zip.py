#!/usr/bin/env python3
"""Package the mental-health instruction set as a reproducible zip.

Usage: python3 -I -B tools/package_zip.py --src . --profile standalone|harness --zip <output.zip> --root <root folder name>

Adds SHA256SUMS.txt (SHA-256 of every packaged file) inside the zip, and uses
fixed timestamps, permissions and entry order, so the same inputs give the same
archive bytes.
"""
import argparse
import hashlib
import sys
import zipfile
from pathlib import Path

PROFILES = {
    # Harness-free use: the single system prompt and what is needed to understand or rebuild it.
    'standalone': [
        'START_HERE.md',
        'README.md',
        'VERSION',
        'USING_WITHOUT_A_HARNESS.md',
        'MODULES.md',
        'BUILD_CHECKS.json',
        'standalone/SYSTEM_PROMPT.md',
        'standalone_src/CRISIS_SUPPORT.md',
        'standalone_src/DEPLOYMENT_FACTS.md',
        'standalone_src/OPERATIONS.md',
        'tools/build_mental_health_set.py',
        'tools/package_zip.py',
    ],
    # The R11-harness variant.
    'harness': [
        'START_HERE.md',
        'README.md',
        'VERSION',
        'MODULES.md',
        'HARNESS_REQUIREMENTS.md',
        'INSTRUCTION_SET.md',
        'RULES_OF_ENGAGEMENT.md',
        'BUILD_CHECKS.json',
        'deployment/IMMEDIATE_CARE_REFERENCE_MANIFEST.json',
        'modules/CLINICAL_REASONING_TOOL.md',
        'modules/FIRST_AID.md',
        'modules/GRID_CARD.md',
        'modules/HEALTH_PLAN.md',
        'modules/OPERATIONS.md',
        'modules/RECEPTION_DESK.md',
        'modules/RULES_OF_ENGAGEMENT.md',
        'modules/SCRATCHPAD_INVESTIGATORY_TOOL.md',
        'modules/SOAP_TOOL.md',
        'tools/build_mental_health_set.py',
        'tools/package_zip.py',
    ],
}
FIXED_TIME = (2026, 10, 14, 0, 0, 0)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--src', required=True, type=Path)
    p.add_argument('--zip', required=True, type=Path)
    p.add_argument('--root', required=True)
    p.add_argument('--profile', required=True, choices=sorted(PROFILES))
    a = p.parse_args()
    INCLUDE = PROFILES[a.profile]

    missing = [rel for rel in INCLUDE if not (a.src / rel).is_file()]
    if missing:
        raise SystemExit(f'missing files: {missing}')
    extra = sorted(
        str(f.relative_to(a.src)) for f in a.src.rglob('*')
        if f.is_file() and str(f.relative_to(a.src)) not in INCLUDE and f.name not in ('SHA256SUMS.txt', '.gitignore')
    )

    sums = []
    for rel in sorted(INCLUDE):
        sums.append(f'{hashlib.sha256((a.src / rel).read_bytes()).hexdigest()}  {rel}')
    sums_text = '\n'.join(sums) + '\n'

    a.zip.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(a.zip, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        entries = sorted(INCLUDE) + ['SHA256SUMS.txt']
        dirs = sorted({str(Path(rel).parent) for rel in entries if str(Path(rel).parent) != '.'})
        root_info = zipfile.ZipInfo(f'{a.root}/', FIXED_TIME)
        root_info.external_attr = (0o40755 << 16) | 0x10
        z.writestr(root_info, b'')
        for d in dirs:
            info = zipfile.ZipInfo(f'{a.root}/{d}/', FIXED_TIME)
            info.external_attr = (0o40755 << 16) | 0x10
            z.writestr(info, b'')
        for rel in entries:
            data = sums_text.encode('utf-8') if rel == 'SHA256SUMS.txt' else (a.src / rel).read_bytes()
            info = zipfile.ZipInfo(f'{a.root}/{rel}', FIXED_TIME)
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(info, data)

    print(f'wrote {a.zip} ({a.zip.stat().st_size} bytes, {len(INCLUDE) + 1} files)')
    if extra:
        print('not included (present in src):', extra)
    return 0


if __name__ == '__main__':
    sys.exit(main())
