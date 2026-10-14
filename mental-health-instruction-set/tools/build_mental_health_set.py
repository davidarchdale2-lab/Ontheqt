#!/usr/bin/env python3
"""Build the mental-health-only instruction set from the R11 source package.

Usage:
    python3 -I tools/build_mental_health_set.py --source <R11 package root> --out <output dir>

Every edit is an exact-match replacement that must match exactly once; the build
stops if the source has drifted from what this transform expects.
"""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

LENSES = {
    '01': 'Doctor',
    '02': 'Psychiatry',
    '03': 'Psychology',
    '04': 'Pharmacist',
    '09': 'ADHD',
    '10': 'Autism',
}

SOURCES = {
    'GRID_CARD.md': 'source_bodies/runtime/modules/GRID_CARD.md',
    'RECEPTION_DESK.md': 'source_bodies/runtime/modules/RECEPTION_DESK.md',
    'SCRATCHPAD_INVESTIGATORY_TOOL.md': 'source_bodies/runtime/modules/SCRATCHPAD_INVESTIGATORY_TOOL.md',
    'CLINICAL_REASONING_TOOL.md': 'source_bodies/runtime/modules/CLINICAL_REASONING_TOOL.md',
    'FIRST_AID.md': 'source_bodies/runtime/modules/FIRST_AID.md',
    'HEALTH_PLAN.md': 'source_bodies/runtime/modules/HEALTH_PLAN.md',
    'SOAP_TOOL.md': 'source_bodies/runtime/modules/SOAP_TOOL.md',
    'OPERATIONS.md': 'source_bodies/runtime/modules/OPERATIONS.md',
    'RULES_OF_ENGAGEMENT.md': '2_MODULES/harness/RULES_OF_ENGAGEMENT.md',
}

# Order and anchors follow the R11 assembled INSTRUCTION_SET.md.
ASSEMBLY_ORDER = [
    'GRID_CARD.md',
    'RECEPTION_DESK.md',
    'SCRATCHPAD_INVESTIGATORY_TOOL.md',
    'CLINICAL_REASONING_TOOL.md',
    'FIRST_AID.md',
    'HEALTH_PLAN.md',
    'SOAP_TOOL.md',
    'OPERATIONS.md',
]
ANCHORS = {
    'GRID_CARD.md': 'aris-grid-card',
    'RECEPTION_DESK.md': 'aris-reception-desk',
    'SCRATCHPAD_INVESTIGATORY_TOOL.md': 'aris-scratchpad-investigatory-tool',
    'CLINICAL_REASONING_TOOL.md': 'aris-clinical-reasoning-tool',
    'FIRST_AID.md': 'aris-first-aid',
    'HEALTH_PLAN.md': 'aris-health-plan',
    'SOAP_TOOL.md': 'aris-soap-creation',
    'OPERATIONS.md': 'aris-operations',
}

BEGIN = '<!-- ARIS_CLINICAL_CONTENT_BEGIN -->'
END = '<!-- ARIS_CLINICAL_CONTENT_END -->'

# Terms that name a dropped lens, a dropped service or media production.
FORBIDDEN = re.compile(
    r'physiotherap|\bphysio\b|avatar|comfy|\bvideo|\billustrat|\bcrop|\bmedia\b|leaflet'
    r'|dietitian|occupational therap|nurse|speech and language|geriatric|palliative'
    r'|cardiology|respiratory medicine|gastroenterology|renal medicine|endocrinology'
    r'|neurology|rheumatology|infectious diseases|allergy and immunology|dermatology'
    r'|musculoskeletal|pain medicine|rehabilitation medicine|urology|oncology|haematology'
    r'|surgery and perioperative|clinical genetics|ophthalmology|ear nose throat'
    r'|oral and dental|sexual reproductive|pregnancy and maternal|diagnostic imaging'
    r'|laboratory and tissue|acute and emergency medicine',
    re.IGNORECASE,
)


def fail(label, detail):
    raise SystemExit(f'BUILD STOPPED [{label}]: {detail}')


def replace_once(text, old, new, label):
    count = text.count(old)
    if count != 1:
        fail(label, f'expected 1 match, found {count}')
    return text.replace(old, new)


def cut_between(text, start, end, label, replacement=''):
    if text.count(start) != 1:
        fail(label, f'start marker found {text.count(start)} times')
    i = text.index(start)
    if end is None:
        return text[:i].rstrip('\n') + '\n' + replacement
    if text.count(end) != 1:
        fail(label, f'end marker found {text.count(end)} times')
    j = text.index(end)
    if j <= i:
        fail(label, 'end marker precedes start marker')
    return text[:i] + replacement + text[j:]


def line_index(lines, prefix, label):
    hits = [k for k, line in enumerate(lines) if line.startswith(prefix)]
    if len(hits) != 1:
        fail(label, f'line starting {prefix[:40]!r} found {len(hits)} times')
    return hits[0]


def drop_paragraph(text, prefix, label):
    """Remove the single line starting with prefix and one following blank line."""
    lines = text.split('\n')
    k = line_index(lines, prefix, label)
    end = k + 2 if k + 1 < len(lines) and lines[k + 1] == '' else k + 1
    del lines[k:end]
    return '\n'.join(lines)


def replace_line(text, prefix, new_line, label):
    lines = text.split('\n')
    k = line_index(lines, prefix, label)
    lines[k] = new_line
    return '\n'.join(lines)


def edit_grid(text):
    text = replace_once(text, 'practical task / media / state storage',
                        'practical task / state storage', 'grid:edge-label')
    text = drop_paragraph(text, '- New media production connects', 'grid:media-bullet')
    text = replace_once(text, 'and 40 specialist lenses.',
                        'and six specialist lenses (Doctor, Psychiatry, Psychology, Pharmacist, ADHD and Autism).',
                        'grid:lens-count')
    text = cut_between(text, '## Media return connection', None, 'grid:media-section')
    return text


def edit_scratchpad(text):
    return replace_once(text, 'source retrieval and media delivery go to Operations',
                        'source retrieval and document delivery go to Operations', 'scratchpad:routing')


def edit_reception(text):
    return replace_once(
        text,
        'for educational information or existing illustrations; personal media production is arranged through the registered context.',
        'for educational information.',
        'reception:educational',
    )


def edit_first_aid(text):
    return drop_paragraph(text, 'After immediate actions and the next care steps have been communicated',
                          'first-aid:media-paragraph')


def edit_health_plan(text):
    return drop_paragraph(text, 'Visual explanations of the agreed or proposed plan',
                          'health-plan:media-paragraph')


def edit_soap(text):
    return cut_between(text, '## Recording accompanying media', '## Saving and continuation',
                       'soap:media-section')


def edit_operations(text):
    text = replace_once(text, 'producing documents or media,', 'producing documents,', 'operations:purpose')
    lines = text.split('\n')
    del lines[line_index(lines, '| Media | Existing-asset retrieval', 'operations:media-row')]
    text = '\n'.join(lines)
    text = cut_between(text, '#### Prepared clinical source images', '### Web and browser',
                       'operations:asset-subsections')
    text = cut_between(
        text, '## Deliverables and media', '## Understanding the response',
        'operations:deliverables',
        replacement=(
            '## Deliverables\n\n'
            'Ordinary text answers, appointment questions and clinical records use the appropriate '
            'text/document or record service. Document production creates or exports prepared material '
            'into the requested format that this deployment makes available.\n\n'
        ),
    )
    return text


def edit_clinical(text):
    text = replace_once(
        text,
        'the 40 professional and specialist lenses contribute their particular perspectives',
        'the six professional and specialist lenses in this set (Doctor, Psychiatry, Psychology, '
        'Pharmacist, ADHD and Autism) contribute their particular perspectives',
        'clinical:purpose',
    )
    text = replace_line(
        text, '[01 Doctor](#aris-lens-01) |',
        '[01 Doctor](#aris-lens-01) | [02 Psychiatry](#aris-lens-02) | [03 Psychology](#aris-lens-03) | '
        '[04 Pharmacist](#aris-lens-04) | [09 ADHD](#aris-lens-09) | [10 Autism](#aris-lens-10)',
        'clinical:lens-index',
    )
    text = cut_between(text, '#### Illustrations and videos accompanying advice', BEGIN,
                       'clinical:illustrations-section')
    for prefix, label in [
        ('| Intake, nutritional requirements', 'dietitian-row'),
        ('| Movement, loading, breathing', 'physio-row'),
        ('| Meaningful activity, everyday performance', 'ot-row'),
        ('| Continuing care needs, personal baseline', 'nurse-row'),
    ]:
        lines = text.split('\n')
        del lines[line_index(lines, prefix, f'clinical:{label}')]
        text = '\n'.join(lines)
    text = replace_once(text, 'Medication and nursing questions can arise in either setting.',
                        'Medication questions can arise in either setting.', 'clinical:nursing-sentence')
    text = cut_between(
        text,
        'Specialist contributions refine the question within these broader professional perspectives.',
        'A specialist opinion answers a particular question',
        'clinical:specialist-table',
        replacement=(
            'Acute deterioration, failing physiology or an immediate threat is routed to First Aid rather than to a lens. '
            'Physical conditions outside the perspectives above are assessed only as far as the perspectives in this set '
            'allow, and are referred to the appropriate specialist service. This set contains no specialist lenses for them.\n\n'
        ),
    )
    return text


def edit_rules(text):
    return replace_line(
        text,
        'Existing prepared images and personal packs can be retrieved during consultation.',
        'No image, video, presentation or media-production route is part of this instruction set. Do not offer, '
        'queue or describe one, and do not claim that a prepared image or personal pack is available.',
        'rules:media-paragraph',
    )


def split_clinical(text):
    """Return (head, engine, lenses_block, tail) around the content markers."""
    if text.count(BEGIN) != 1 or text.count(END) != 1:
        fail('clinical:markers', 'content markers missing or duplicated')
    head, rest = text.split(BEGIN, 1)
    body, tail = rest.split(END, 1)
    marker = '## Specialist clinical lenses'
    if body.count(marker) != 1:
        fail('clinical:lens-heading', 'lens heading not found exactly once')
    engine, lenses = body.split(marker, 1)
    return head, engine, lenses, tail


def select_lenses(lenses_block):
    parts = re.split(r'(?=<a id="aris-lens-\d\d"></a>)', lenses_block)
    chunks = {}
    for part in parts:
        match = re.match(r'<a id="aris-lens-(\d\d)"></a>', part)
        if match:
            chunks[match.group(1)] = part.rstrip() + '\n\n'
    missing = [n for n in LENSES if n not in chunks]
    if missing:
        fail('clinical:lenses', f'missing lens anchors {missing}')
    return ''.join(chunks[n] for n in sorted(LENSES))


def strip_nav(text):
    return '\n'.join(
        line for line in text.split('\n')
        if not re.fullmatch(r'\[[^\]]+\]\(<[A-Z_]+\.md>\)', line.strip())
    )


def link_to_anchor(text, label):
    def repl(match):
        name = match.group(1)
        if name not in ANCHORS:
            fail(label, f'unmapped module link {name}')
        return f'(#{ANCHORS[name]})'
    return re.sub(r'\(<([A-Z_]+\.md)>\)', repl, text)


def assemble(modules):
    chunks = []
    for name in ASSEMBLY_ORDER:
        body = link_to_anchor(strip_nav(modules[name]).strip(), f'assemble:{name}').strip()
        chunks.append(f'<a id="{ANCHORS[name]}"></a>\n\n{body}\n')
    return '\n\n---\n\n'.join(chunks)


def check(output_text, module_texts):
    results = []

    lens_ids = sorted(set(re.findall(r'<a id="aris-lens-(\d\d)"></a>', output_text)))
    results.append({'check': 'lens anchors are exactly the six kept lenses',
                    'result': 'PASS' if lens_ids == sorted(LENSES) else 'FAIL', 'detail': lens_ids})

    anchors = set(re.findall(r'<a id="([^"]+)"></a>', output_text))
    links = set(re.findall(r'\(#([a-z0-9-]+)\)', output_text))
    unresolved = sorted(links - anchors)
    results.append({'check': 'every in-page link resolves to an anchor',
                    'result': 'PASS' if not unresolved else 'FAIL', 'detail': unresolved})

    grid_targets = set(re.findall(r'click \w+ "#([a-z0-9-]+)"', output_text))
    results.append({'check': 'Grid click targets exist',
                    'result': 'PASS' if grid_targets <= anchors else 'FAIL',
                    'detail': sorted(grid_targets - anchors)})

    leftover = []
    for name, text in module_texts.items():
        for match in FORBIDDEN.finditer(text):
            leftover.append(f'{name}: {match.group(0)}')
    results.append({'check': 'no dropped lens, dropped service or media-production term remains',
                    'result': 'PASS' if not leftover else 'REVIEW', 'detail': leftover[:50]})

    results.append({'check': 'Rules of Engagement kept as a separate file (not in core)',
                    'result': 'PASS' if '# Rules of Engagement' not in output_text else 'FAIL', 'detail': None})
    return results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()

    raw = {}
    for name, rel in SOURCES.items():
        path = args.source / rel
        if not path.is_file():
            fail('source', f'missing {rel}')
        raw[name] = path.read_text(encoding='utf-8')

    modules = {}
    modules['GRID_CARD.md'] = edit_grid(raw['GRID_CARD.md'])
    modules['RECEPTION_DESK.md'] = edit_reception(raw['RECEPTION_DESK.md'])
    modules['SCRATCHPAD_INVESTIGATORY_TOOL.md'] = edit_scratchpad(raw['SCRATCHPAD_INVESTIGATORY_TOOL.md'])
    modules['FIRST_AID.md'] = edit_first_aid(raw['FIRST_AID.md'])
    modules['HEALTH_PLAN.md'] = edit_health_plan(raw['HEALTH_PLAN.md'])
    modules['SOAP_TOOL.md'] = edit_soap(raw['SOAP_TOOL.md'])
    modules['OPERATIONS.md'] = edit_operations(raw['OPERATIONS.md'])
    modules['RULES_OF_ENGAGEMENT.md'] = edit_rules(raw['RULES_OF_ENGAGEMENT.md'])

    clinical = edit_clinical(raw['CLINICAL_REASONING_TOOL.md'])
    head, engine, lenses_block, tail = split_clinical(clinical)
    clinical_out = head + engine + '## Specialist clinical lenses\n\n' + select_lenses(lenses_block) + tail
    modules['CLINICAL_REASONING_TOOL.md'] = clinical_out.replace(BEGIN, '').replace(END, '')

    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / 'modules').mkdir(exist_ok=True)
    for name, text in modules.items():
        (args.out / 'modules' / name).write_text(text, encoding='utf-8', newline='\n')

    core = assemble(modules)
    (args.out / 'INSTRUCTION_SET.md').write_text(core, encoding='utf-8', newline='\n')
    rules = strip_nav(modules['RULES_OF_ENGAGEMENT.md']).strip() + '\n'
    (args.out / 'RULES_OF_ENGAGEMENT.md').write_text(rules, encoding='utf-8', newline='\n')

    checks = check(core, {k: v for k, v in modules.items() if k != 'RULES_OF_ENGAGEMENT.md'})
    manifest = {
        'derived_from': 'Dr_Seraphina_Aris_Health_Assistant_V1_R11 (content revision 1)',
        'variant': 'mental-health-only (draft, not clinically reviewed)',
        'lenses': {k: v for k, v in LENSES.items()},
        'core': {'path': 'INSTRUCTION_SET.md',
                 'sha256': hashlib.sha256(core.encode('utf-8')).hexdigest(),
                 'words': len(core.split())},
        'rules': {'path': 'RULES_OF_ENGAGEMENT.md',
                  'sha256': hashlib.sha256(rules.encode('utf-8')).hexdigest(),
                  'words': len(rules.split())},
        'checks': checks,
    }
    (args.out / 'BUILD_CHECKS.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n',
                                                encoding='utf-8')

    print(f"core words: {manifest['core']['words']}  rules words: {manifest['rules']['words']}")
    for c in checks:
        print(f"{c['result']:6} {c['check']}")
        if c['result'] != 'PASS' and c['detail']:
            print('       ', c['detail'])
    return 0


if __name__ == '__main__':
    sys.exit(main())
