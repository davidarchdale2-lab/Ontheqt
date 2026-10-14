#!/usr/bin/env python3
"""Build the mental-health-only instruction set from the R11 source package.

Usage:
    python3 -I tools/build_mental_health_set.py --source <R11 package root> --out <output dir>
    python3 -I tools/build_mental_health_set.py --source <R11 package root> --print-pins

Guarantees:
- Every edit either matches exact text once, or removes a span whose SHA-256 is
  pinned in PINS. If the source changes anywhere an edit touches, the build stops.
- All outputs are computed and checked in memory first. If any check fails, the
  build exits non-zero and writes nothing.
- The assembler mirrors R11's Tools/release_common.py. The build proves this by
  assembling the unedited R11 modules and comparing the result with R11's core.
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile
from pathlib import Path

LENSES = {
    '01': 'Doctor',
    '02': 'Psychiatry',
    '03': 'Psychology',
    '04': 'Pharmacist',
    '09': 'ADHD',
    '10': 'Autism',
}
LENS_SUMMARY = 'Doctor, Psychiatry, Psychology, Pharmacist, ADHD and Autism'

MODULE_SOURCES = {
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
REFERENCE_SOURCES = {
    'r11_core': '1_INSTRUCTION_SET/INSTRUCTION_SET.md',
    'release': 'RELEASE.json',
    'immediate_care_manifest': '1_INSTRUCTION_SET/deployment/IMMEDIATE_CARE_REFERENCE_MANIFEST.json',
}

# Order, anchors and runtime text rules follow R11 Tools/release_common.py.
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
PER_TURN_GRID = {
    'start_anchor': 'aris-grid-card',
    'end_before_anchor': 'aris-reception-desk',
    'normalization': 'text from the start anchor tag (inclusive) to the end anchor tag (exclusive), outer whitespace trimmed',
    'marker': '[ARIS_GRID_CARD_PER_TURN v1]',
}

BEGIN = '<!-- ARIS_CLINICAL_CONTENT_BEGIN -->'
END = '<!-- ARIS_CLINICAL_CONTENT_END -->'

# SHA-256 of each source span that an edit removes or replaces without spelling it out.
PINS = {
    'grid:media-bullet': 'd2a35a628b74c93d9f47c4bd3379d4df846a6800a30d8de5f30de542044c53c2',
    'grid:media-section': '485f1a6a0605dfc16cb9264ead8235f565c07ca7bec61befe17320d577c333de',
    'clinical:lens-index': '9ecf62b52be11b762bd7bd10d17eb8a55b73e653e729a4bbd55a9c75f51f7c4b',
    'clinical:illustrations-section': 'ad07f415098ec10f2c040891789b92e8affb2493ba29372f08ef7ca14e92ad5c',
    'clinical:dietitian-row': '658f83a8ed5d303ada7b2d5ae7f19d703ca24c2dab6e731d1d9852f2925824f3',
    'clinical:physio-row': 'd1f620fc0257268f2723040bedf0ed7b970ebb7399316d48129c84c1c4bae3ab',
    'clinical:ot-row': '0f7bbdb6ddf5eae26a2a3825ae479484440bce87de837773ab12a1313cabaf8f',
    'clinical:nurse-row': '05ea1b48fa581f1ed8c910660a0b23406d56fc646b91eeb1bf21752b8b638e67',
    'clinical:specialist-table': '1cfbb6bc001cf1a8f4dedbd6468846e322678fd549a3c5f2742d7a4ad4a98e1b',
    'clinical:dropped-lenses': 'd9bbb9e2a50193fa75feacec7f5caedf2562c44bc837d697e2e3374626127362',
    'first-aid:media-paragraph': '1a22b2e22a872a43d15caf4fe87641a30ff7d5816b7971b43696e2e662483538',
    'health-plan:media-paragraph': 'a864818fe0c06692edc62d68b9bf71de832c6506afe1ad83ea8e1cdcddde9109',
    'soap:media-section': 'e2b146f78141755e883f4c89560fd3f23e28ebc85e582770df331f8b71490d28',
    'operations:media-row': '4b88f875bddea898c071e2752364c5d40caf026385b8eb2c9eec120aa9c5aea7',
    'operations:asset-subsections': 'd2c28ebc81e284d993d1f381106f6dff715b9f86542b5f96e9ae4342a8d5db37',
    'operations:deliverables': '9b564f22219b164b47a429196799a959ba658215ddcd28fe1c103fa769a4f312',
    'rules:media-paragraph': '1ec1abe54ac0ebf50df62de167e6d7534b8c9d7a212075c536d9a3c01750b0fd',
    'sa-grid:registered-bullet': '9ac3f55682b764af08ac25c977bc803739049f210df67ea048aae68a5b9f3705',
    'sa-grid:record-table': 'e37c42437a85ed0d412f2e27f35a6994cbe42c0d07e3c261675af9fa8f9282bb',
    'sa-scratchpad:interface': '996ca502c610830b50f32544bae364e24dde8628921029b5919a03d39830ad3a',
    'sa-scratchpad:templates': 'ad81c5b9df2ecd315d3023c9fb1a3f3da4acc7e32829a375359410cd5d5ec1c8',
    'sa-health-plan:template': '6e5f79755a73d9c68f3d4646935a4128a209bc49f192842c6f76faf61102eaa8',
    'sa-soap:identity-closing': 'b9435f1cd55cd0e74b882a71b0fa4108f95faae488907dec32d01f9c20033f5c',
    'sa-soap:template': '5898ca624145c5ecec1e48d2c8a8d2455e58dd32b8602bd9e6e6f4f00ea27632',
}

# Terms that name a dropped lens, a dropped service or media production.
FORBIDDEN = re.compile(
    r'physiotherap|\bphysio\b|avatar|comfy|\bvideo|\billustrat|\bcrop|\bmedia\b|leaflet|\banimat'
    r'|personal pack|image generation|visual explanation|slide deck|infographic'
    r'|dietitian|dietician|occupational therap|\bnurs(?:e|es|ing)\b|speech and language'
    r'|\bpaediatrics\b|paediatrician|geriatric|palliative|cardiology|respiratory medicine|gastroenterology|hepatology'
    r'|renal medicine|endocrinology|neurology|rheumatology|infectious diseases|microbiology'
    r'|allergy and immunology|dermatology|musculoskeletal|orthopaedic|pain medicine'
    r'|rehabilitation medicine|\burolog|gynaecolog|obstetric|\boncolog|haematology'
    r'|surgery and perioperative|clinical genetics|ophthalmology|ear nose throat|oral and dental'
    r'|sexual reproductive|pregnancy and maternal|diagnostic imaging|laboratory and tissue'
    r'|acute and emergency medicine',
    re.IGNORECASE,
)

# Reviewed generic uses. A forbidden-term hit passes only if it matches an entry here.
ALLOWED = [
    {'file': 'SOAP_TOOL.md', 'term': 'illustrat',
     'line_contains': 'A source-page illustration is reference material rather than an examination finding',
     'reason': 'Evidence rule about reference material, not a media route.'},
    {'file': 'CLINICAL_REASONING_TOOL.md', 'term': 'illustrat',
     'line_contains': 'A source image illustrates what it depicts',
     'reason': 'Evidence appraisal of a supplied or retrieved source image.'},
    {'file': 'CLINICAL_REASONING_TOOL.md', 'term': 'crop',
     'line_contains': 'resolution, lighting and cropping affect what can be examined',
     'reason': 'Evidence appraisal of a supplied photograph.'},
    {'file': 'CLINICAL_REASONING_TOOL.md', 'term': 'video',
     'line_contains': 'a photograph or video shows selected visible features',
     'reason': 'Describes what a person-supplied recording can show; not a production route.'},
    {'file': 'CLINICAL_REASONING_TOOL.md', 'term': 'leaflet',
     'line_contains': 'Relevant information comes from the product leaflet',
     'reason': 'Pharmacist lens: a medicine product leaflet as a source.'},
    {'file': 'RULES_OF_ENGAGEMENT.md', 'term': 'video',
     'line_contains': 'No image or video generation, managed media-production workflow, or prepared-image and personal-pack retrieval is part of this instruction set.',
     'reason': 'The replacement sentence that states the absence of media routes.'},
    {'file': 'RULES_OF_ENGAGEMENT.md', 'term': 'media',
     'line_contains': 'No image or video generation, managed media-production workflow, or prepared-image and personal-pack retrieval is part of this instruction set.',
     'reason': 'The replacement sentence that states the absence of media routes.'},
]

PRINT_PINS = False
SEEN_PINS = {}


def sha(data):
    if isinstance(data, str):
        data = data.encode('utf-8')
    return hashlib.sha256(data).hexdigest()


def fail(label, detail):
    raise SystemExit(f'BUILD STOPPED [{label}]: {detail}')


def pin(label, removed):
    digest = sha(removed)
    SEEN_PINS[label] = digest
    if not PRINT_PINS and PINS.get(label) != digest:
        fail(label, f'the source span this edit removes has changed (sha256 {digest}); '
                    'review the source change, then update PINS')


# ---------------------------------------------------------------- edit helpers

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
        pin(label, text[i:])
        return text[:i].rstrip('\n') + '\n' + replacement
    if text.count(end) != 1:
        fail(label, f'end marker found {text.count(end)} times')
    j = text.index(end)
    if j <= i:
        fail(label, 'end marker precedes start marker')
    pin(label, text[i:j])
    return text[:i] + replacement + text[j:]


def line_index(lines, prefix, label):
    hits = [k for k, line in enumerate(lines) if line.startswith(prefix)]
    if len(hits) != 1:
        fail(label, f'line starting {prefix[:40]!r} found {len(hits)} times')
    return hits[0]


def drop_line(text, prefix, label):
    """Remove one whole line, for example a list item or a table row."""
    lines = text.split('\n')
    k = line_index(lines, prefix, label)
    pin(label, lines[k])
    del lines[k]
    return '\n'.join(lines)


def drop_paragraph(text, prefix, label):
    """Remove a one-line paragraph that sits between blank lines, and one of those blank lines."""
    lines = text.split('\n')
    k = line_index(lines, prefix, label)
    if k == 0 or k + 1 >= len(lines) or lines[k - 1] != '' or lines[k + 1] != '':
        fail(label, 'target is not a stand-alone paragraph between blank lines')
    pin(label, lines[k])
    del lines[k:k + 2]
    return '\n'.join(lines)


def replace_line(text, prefix, new_line, label):
    lines = text.split('\n')
    k = line_index(lines, prefix, label)
    pin(label, lines[k])
    lines[k] = new_line
    return '\n'.join(lines)


# ---------------------------------------------------------------- module edits

def edit_grid(text):
    text = replace_once(text, '# Dr Seraphina Aris - Health Assistant V1 R11\n',
                        '# Dr Seraphina Aris - Health Assistant V1 R11-MH (mental-health draft)\n', 'grid:title')
    text = replace_once(text, 'practical task / media / state storage',
                        'practical task / state storage', 'grid:edge-label')
    text = drop_line(text, '- New media production connects', 'grid:media-bullet')
    text = replace_once(text, 'and 40 specialist lenses.',
                        f'and six professional and specialist lenses ({LENS_SUMMARY}).', 'grid:lens-count')
    text = cut_between(text, '## Media return connection', None, 'grid:media-section')
    return text


def edit_reception(text):
    return replace_once(
        text,
        'for educational information or existing illustrations; personal media production is arranged through the registered context.',
        'for educational information.',
        'reception:educational',
    )


def edit_scratchpad(text):
    return replace_once(text, 'source retrieval and media delivery go to Operations',
                        'source retrieval and document delivery go to Operations', 'scratchpad:routing')


def edit_first_aid(text):
    text = drop_paragraph(text, 'After immediate actions and the next care steps have been communicated',
                          'first-aid:media-paragraph')
    text = replace_once(text, 'a nursing, pharmacy or other professional question can bring its relevant perspective',
                        'a pharmacy or other professional question can bring its relevant perspective in this set',
                        'first-aid:nursing')
    return text


def edit_health_plan(text):
    return drop_paragraph(text, 'Visual explanations of the agreed or proposed plan',
                          'health-plan:media-paragraph')


def edit_soap(text):
    return cut_between(text, '## Recording accompanying media', '## Saving and continuation',
                       'soap:media-section')


def edit_operations(text):
    text = replace_once(text, 'producing documents or media,', 'producing documents,', 'operations:purpose')
    text = drop_line(text, '| Media | Existing-asset retrieval', 'operations:media-row')
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
        f'the six professional and specialist lenses in this set ({LENS_SUMMARY}) contribute their particular perspectives',
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
        ('| Intake, nutritional requirements', 'clinical:dietitian-row'),
        ('| Movement, loading, breathing', 'clinical:physio-row'),
        ('| Meaningful activity, everyday performance', 'clinical:ot-row'),
        ('| Continuing care needs, personal baseline', 'clinical:nurse-row'),
    ]:
        text = drop_line(text, prefix, label)
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
            'allow; care navigation then helps the person reach an appropriate service. '
            'This set contains no specialist lenses for them.\n\n'
        ),
    )
    return text


def edit_rules(text):
    text = replace_line(
        text,
        'Existing prepared images and personal packs can be retrieved during consultation.',
        'No image or video generation, managed media-production workflow, or prepared-image and personal-pack '
        'retrieval is part of this instruction set. Do not offer, queue or describe one.',
        'rules:media-paragraph',
    )
    text = replace_once(
        text,
        'Saving, registration, inspection and delivery are separate outcomes. Do not claim visual or motion review '
        'from a filename, caption, save receipt, or an unavailable inspection facility. Preserve the actual inspection '
        'coverage and unresolved findings. A retrieved still is not a validated animation.',
        'Saving, inspection and delivery are separate outcomes. Do not claim visual review from a filename, caption, '
        'save receipt, or an unavailable inspection facility. Preserve the actual inspection coverage and unresolved findings.',
        'rules:inspection-paragraph',
    )
    text = replace_once(
        text,
        ' Ordinary short written explanations and appointment notes do not become ComfyUI jobs merely because they are documents.',
        '',
        'rules:comfy-sentence',
    )
    return text


# ---------------------------------------------------------------- clinical lenses

def split_clinical(text):
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
    if parts[0].strip():
        fail('clinical:lenses', 'unexpected text before the first lens anchor')
    ids = []
    chunks = {}
    for part in parts[1:]:
        lens_id = re.match(r'<a id="aris-lens-(\d\d)"></a>', part).group(1)
        ids.append(lens_id)
        if re.search(r'(?m)^#{1,2} ', part):
            fail('clinical:lenses', f'lens {lens_id} contains a level-1 or level-2 heading (non-lens content)')
        headings = re.findall(r'(?m)^### (.+)$', part)
        if len(headings) != 1:
            fail('clinical:lenses', f'lens {lens_id} has {len(headings)} level-3 headings; expected exactly one lens title')
        heading = re.search(r'(?m)^### (.+)$', part)
        if lens_id in LENSES and heading.group(1).strip() != LENSES[lens_id]:
            fail('clinical:lenses', f'lens {lens_id} heading is {heading.group(1)!r}, expected {LENSES[lens_id]!r}')
        chunks[lens_id] = part.rstrip() + '\n\n'
    expected_ids = [f'{n:02d}' for n in range(1, 41)]
    if ids != expected_ids:
        fail('clinical:lenses', f'expected lens anchors 01-40 once each in order, found {ids}')
    # Any change inside a dropped lens, including text added after the last lens, stops the build.
    pin('clinical:dropped-lenses', ''.join(chunks[n] for n in expected_ids if n not in LENSES))
    return ''.join(chunks[n] for n in sorted(LENSES))


def build_clinical(raw_text):
    text = edit_clinical(raw_text)
    head, engine, lenses_block, tail = split_clinical(text)
    head = head.rstrip('\n') + '\n\n'
    out = head + engine.lstrip('\n') + '## Specialist clinical lenses\n\n' + select_lenses(lenses_block) + tail.lstrip('\n')
    return out


# ---------------------------------------------------------------- assembly (mirrors R11)

def rewrite(text):
    for name, anchor in ANCHORS.items():
        text = (text.replace('(<' + name + '>)', '(#' + anchor + ')')
                    .replace('(' + name + ')', '(#' + anchor + ')')
                    .replace('"' + name + '"', '"#' + anchor + '"'))
    return text


def runtime_text(name, text):
    text = rewrite(text)
    if name != 'GRID_CARD.md':
        text = re.sub(r'\n#{1,6} [^\n]+\n(?:[ \t]*\n)*```mermaid\n.*?\n```\n', '\n', text, flags=re.S)
        text = re.sub(r'\n```mermaid\n.*?\n```\n', '\n', text, flags=re.S)
        text = re.sub(r'(?m)^#{1,6} (?:Process map|Process maps|Flowchart)[^\n]*\n(?:[ \t]*\n)*(?=#{1,6} |\Z)', '', text)
    return text


def assemble(modules):
    return '\n---\n\n'.join('<a id="' + ANCHORS[n] + '"></a>\n\n' + runtime_text(n, modules[n]) for n in ASSEMBLY_ORDER)


def per_turn_grid(core):
    start = f'<a id="{PER_TURN_GRID["start_anchor"]}"></a>'
    end = f'<a id="{PER_TURN_GRID["end_before_anchor"]}"></a>'
    if core.count(start) != 1 or core.count(end) != 1:
        fail('per-turn-grid', 'Grid anchors missing or duplicated')
    return core[core.index(start):core.index(end)].strip()


# ---------------------------------------------------------------- checks

def check(core, rules, modules, r11_core, raw_modules):
    results = []

    def add(name, ok, detail=None):
        results.append({'check': name, 'result': 'PASS' if ok else 'FAIL', 'detail': detail})

    add('assembler reproduces the R11 core byte for byte from unedited R11 modules',
        assemble(raw_modules) == r11_core)

    lens_ids = re.findall(r'<a id="aris-lens-(\d\d)"></a>', core)
    add('lens anchors are exactly the six kept lenses, once each', lens_ids == sorted(LENSES), lens_ids)

    anchors = re.findall(r'<a id="([^"]+)"></a>', core)
    duplicates = sorted({a for a in anchors if anchors.count(a) > 1})
    add('no duplicate anchors', not duplicates, duplicates)
    anchor_set = set(anchors)

    bad_links = []
    for target in re.findall(r'\]\((<[^>]*>|[^)\s]+)', core):
        target = target.strip('<>')
        if target.startswith(('http://', 'https://', 'mailto:')):
            continue
        if not (target.startswith('#') and target[1:] in anchor_set):
            bad_links.append(target)
    add('every link is external or resolves to an anchor in the core', not bad_links, sorted(set(bad_links)))

    clicks = re.findall(r'(?m)^\s*click \w+ "([^"]*)"', core)
    bad_clicks = [t for t in clicks if not (t.startswith('#') and t[1:] in anchor_set)]
    add('Grid click targets are in-page anchors that exist', bool(clicks) and not bad_clicks,
        {'click_lines': len(clicks), 'unresolved': bad_clicks})

    # Module names also match record-template names (HEALTH_PLAN.md), so only link and click forms count.
    names = '|'.join(re.escape(n) for n in ANCHORS)
    leftover_files = sorted(set(re.findall(r'[(<"](?:' + names + r')(?:#[^)>"]*)?[)>"]', core)))
    add('no module-file link or click target remains in the core', not leftover_files, leftover_files)

    grid = per_turn_grid(core)
    mermaid_total = core.count('```mermaid')
    mermaid_grid = grid.count('```mermaid')
    add('only the two Grid maps remain in the core (R11 runtime policy)', mermaid_total == 2 and mermaid_grid == 2,
        {'core': mermaid_total, 'grid': mermaid_grid})

    rule_headings = re.findall(r'(?m)^## R\d+ · ', core)
    add('Rules of Engagement are not embedded in the core',
        '# Rules of Engagement' not in core and not rule_headings, len(rule_headings))

    unexpected, accepted = [], []
    for name, text in modules.items():
        for lineno, line in enumerate(text.split('\n'), 1):
            for m in FORBIDDEN.finditer(line):
                term = m.group(0).lower()
                rule = next((a for a in ALLOWED if a['file'] == name and term.startswith(a['term'])
                             and a['line_contains'] in line), None)
                (accepted if rule else unexpected).append(f'{name}:{lineno}: {m.group(0)}')
    add('no dropped lens, dropped service or media-production term remains (Rules included; reviewed uses allowlisted)',
        not unexpected, {'unexpected': unexpected, 'accepted': accepted})

    return results


# ---------------------------------------------------------------- standalone variant (no harness)

STANDALONE_SRC = Path(__file__).resolve().parent.parent / 'standalone_src'
STANDALONE_FILES = ['DEPLOYMENT_FACTS.md', 'OPERATIONS.md']

# Names of R11 harness tools, files and paths that must not appear in the standalone prompt.
HARNESS_IDENTIFIERS = re.compile(
    r'/mnt/|CASE_STATE|\.schema\.json|\b(?:get_working_picture_format|change_working_picture|read_scratchpad'
    r'|update_scratchpad|lookup_registered_user|get_record_access|lookup_patient_memory|list_patient_files'
    r'|read_patient_file|request_full_record_access|finish_full_record_access|get_record_template'
    r'|save_prepared_soap|soap_save_status|save_patient_memory|patient_memory_status|save_continuity_summary'
    r'|continuity_summary_status|save_health_plan|save_health_file_audit|record_document_status'
    r'|clinical_reasoning|create_reminder|reminder_status|update_reminder|cancel_reminder|create_document'
    r'|read_uploaded_document|search_medical_library|list_medical_library|read_medical_library|search_web'
    r'|browser_action|get_current_time|create_compute_project|get_compute_result)\b'
    r'|(?:SOAP|HEALTH_PLAN|HEALTH_DATA_SUMMARY|HEALTH_FILE_AUDIT|PERSISTENT_MEMORY)\.(?:md|json)'
)

STANDALONE_ALLOWED = [
    {'file': 'standalone:DEPLOYMENT_FACTS.md', 'term': 'media',
     'line_contains': 'calculator, document service or media service is available.',
     'reason': 'States that no media service is connected.'},
    {'file': 'standalone:OPERATIONS.md', 'term': 'media',
     'line_contains': 'executing a calculation, sending anything or producing media.',
     'reason': 'States that media production is unavailable.'},
    {'file': 'standalone:DEPLOYMENT_FACTS.md', 'term': 'leaflet',
     'line_contains': 'point to the product leaflet, a pharmacist or the prescriber.',
     'reason': 'A medicine product leaflet as a source.'},
]


def standalone_rules(text):
    return replace_once(text, 'System-wide requirements supplied separately by the harness.',
                        'System-wide requirements, supplied in this same prompt.', 'sa-rules:intro')


def standalone_grid(text):
    text = replace_once(text, '# Dr Seraphina Aris - Health Assistant V1 R11-MH (mental-health draft)\n',
                        '# Dr Seraphina Aris - Health Assistant V1 R11-MH standalone (mental-health draft)\n',
                        'sa-grid:title')
    text = replace_once(text, 'M["Operations: read current persistent memory"]',
                        'M["Operations: persistent memory (none connected in this deployment)"]', 'sa-grid:memory-node')
    text = replace_line(
        text, '- Registered consultation starts with persistent memory',
        '- No person registry, stored record or persistent memory is connected in this deployment. Background comes from '
        'what the person supplies in the conversation, including a continuity summary pasted from an earlier conversation.',
        'sa-grid:registered-bullet')
    text = cut_between(
        text, 'The record-producing process supplies content; Operations retrieves',
        'The relevant module defines when a record is appropriate.', 'sa-grid:record-table',
        replacement=(
            'The record-producing process supplies content; Operations prepares the record as text in the conversation, '
            'using its record layouts. Nothing is saved.\n\n'
            '| Record | Preparing process | Operations layout |\n'
            '|---|---|---|\n'
            '| Consultation or amendment | SOAP Creation | SOAP note |\n'
            '| Health-data interpretation | Scratchpad with Clinical Reasoning | Health-data summary |\n'
            '| Agreed or proposed care plan | Health Plan | Health plan |\n'
            '| Comparison of supplied records | Scratchpad with Clinical Reasoning | Record audit |\n'
            '| Continuity for a later conversation | Scratchpad after the other record outcomes | Continuity summary |\n\n'
        ))
    text = replace_once(
        text,
        'Template access does not itself trigger a new record. Operations returns each outcome to its originating process; '
        'closing memory incorporates those outcomes last.',
        'A record layout does not itself call for a new record. Operations returns each outcome to its originating process; '
        'a closing continuity summary incorporates those outcomes last.',
        'sa-grid:template-sentence')
    return text


def standalone_reception(text):
    text = replace_once(
        text,
        'For a registered-user consultation, I start with your saved continuity summary and current condensed record.',
        "I don't keep anything between conversations. If you kept a continuity summary from an earlier conversation, "
        'you can paste it here to carry on.',
        'sa-reception:intro')
    text = replace_once(text, '> - **Your full name** — for a registered-user consultation.',
                        '> - **Your name**, if you would like me to use it.', 'sa-reception:name')
    text = replace_once(
        text,
        "> - **Guest**, or simply ask your question without giving a name — to continue without loading a registered user's personal records.",
        '> - **Guest**, or simply ask your question without giving a name.', 'sa-reception:guest')
    text = replace_once(
        text,
        'A recognised registered introduction starts its memory-first entry, without another identity question or Reception investigation.',
        'No person registry is connected, so a name opens no records.', 'sa-reception:registered-entry')
    return text


def standalone_scratchpad(text):
    text = cut_between(
        text, '## Working-picture interface', '## Templates for investigation and continuity records',
        'sa-scratchpad:interface',
        replacement=(
            '## Working-picture interface\n\n'
            'No working-picture service is connected. The working picture is kept in the conversation: attributed facts, '
            'questions, plans and their status stay distinct there, and the current picture can be restated when it helps '
            'the person or before a record is prepared.\n\n'
        ))
    text = cut_between(
        text, '## Templates for investigation and continuity records', None, 'sa-scratchpad:templates',
        replacement=(
            '## Records for investigation and continuity\n\n'
            'The working picture prepares a health-data summary, record audit or continuity summary through Operations, '
            'using its layouts. Clinical Reasoning supplies the interpretation of supplied measurements or compared records. '
            'Keep unresolved comparisons and coverage visible. An audit changes no record. A continuity summary is prepared '
            'after the other record outcomes, for the person to keep.\n'
        ))
    return text


def standalone_health_plan(text):
    return cut_between(
        text, '## Record template', None, 'sa-health-plan:template',
        replacement=(
            '## Record template\n\n'
            'For a plan prepared as a document, Operations uses its health-plan layout. Populate the chosen goals, proposed '
            'or agreed actions, ownership, feasibility and review from the actual discussion. Clinical Reasoning supplies the '
            'assessment; the layout supplies the structure. The plan is prepared in the chat for the person to keep; it is '
            'not saved. Relevant planning content still contributes to SOAP P.\n'
        ))


def standalone_soap(text):
    text = replace_once(
        text,
        'The recording arrangement can be a prepared copy, temporary session note or a record submitted through Operations. '
        'The returned position describes the note and any established stored reference or linkage. A storage limitation '
        'accompanies prepared content while the enquiry continues.',
        'In this deployment the recording arrangement is a prepared copy in the chat; nothing is submitted or stored. '
        'The note says so, and the enquiry continues.',
        'sa-soap:arrangement')
    text = replace_once(
        text,
        'A later registered consultation reads its current consolidated memory first, then the condensed record and changed '
        'or relevant original notes/amendments as attributed history.',
        'A later conversation starts from what the person supplies, such as a pasted continuity summary or an earlier note, '
        'as attributed history.',
        'sa-soap:later-consultation')
    text = replace_line(
        text, 'The template and record interface carry patient, encounter',
        'A prepared note names the person as they named themselves, if they did, the encounter date if known, its '
        'preparation in this conversation by an AI health assistant, and any earlier note it continues or amends. At close, '
        'the current discussion is compared with any note already prepared in this conversation: unchanged content is not '
        'prepared again, while later information or a correction takes the continuation or amendment route. Record outcomes '
        'then feed the closing continuity summary.',
        'sa-soap:identity-closing')
    text = cut_between(
        text, '## Record template', None, 'sa-soap:template',
        replacement=(
            '## Record template\n\n'
            'Operations uses its SOAP note layout for a SOAP, continuation or amendment. A layout is a blank structure; its '
            'unknowns stay unknown. The prepared note is presented in the chat for the person to keep; it is not saved.\n'
        ))
    return text


def build_standalone(mh_modules, standalone_sources):
    modules = dict(mh_modules)
    modules['GRID_CARD.md'] = standalone_grid(modules['GRID_CARD.md'])
    modules['RECEPTION_DESK.md'] = standalone_reception(modules['RECEPTION_DESK.md'])
    modules['SCRATCHPAD_INVESTIGATORY_TOOL.md'] = standalone_scratchpad(modules['SCRATCHPAD_INVESTIGATORY_TOOL.md'])
    modules['HEALTH_PLAN.md'] = standalone_health_plan(modules['HEALTH_PLAN.md'])
    modules['SOAP_TOOL.md'] = standalone_soap(modules['SOAP_TOOL.md'])
    modules['OPERATIONS.md'] = standalone_sources['OPERATIONS.md']
    rules = standalone_rules(modules.pop('RULES_OF_ENGAGEMENT.md'))
    facts = standalone_sources['DEPLOYMENT_FACTS.md']
    core = assemble(modules)
    grid = per_turn_grid(core).replace(f'<a id="{PER_TURN_GRID["start_anchor"]}"></a>', '').strip()
    grid = re.sub(r'\n-{3}\s*$', '', grid).strip()
    prompt = '\n\n---\n\n'.join([rules.strip(), facts.strip(), core.strip(), PER_TURN_GRID['marker'] + '\n\n' + grid]) + '\n'
    scanned = {n: t for n, t in modules.items() if n != 'OPERATIONS.md'}
    scanned['RULES_OF_ENGAGEMENT.md'] = rules
    scanned['standalone:OPERATIONS.md'] = standalone_sources['OPERATIONS.md']
    scanned['standalone:DEPLOYMENT_FACTS.md'] = facts
    return prompt, scanned


def check_standalone(prompt, scanned):
    results = []

    def add(name, ok, detail=None):
        results.append({'check': name, 'result': 'PASS' if ok else 'FAIL', 'detail': detail})

    add('Rules appear exactly once', prompt.count('# Rules of Engagement') == 1 and len(re.findall(r'(?m)^## R0 · ', prompt)) == 1)
    add('deployment facts appear exactly once', prompt.count('# Standalone deployment facts') == 1)
    start, end = '<a id="aris-grid-card"></a>', '<a id="aris-reception-desk"></a>'
    core_grid = prompt[prompt.index(start) + len(start):prompt.index(end)].strip() if start in prompt and end in prompt else None
    core_grid = re.sub(r'\n-{3}\s*$', '', core_grid).strip() if core_grid else None
    repeated = prompt.split(PER_TURN_GRID['marker'], 1)[-1].strip() if prompt.count(PER_TURN_GRID['marker']) == 1 else None
    add('per-turn Grid is repeated at the end, identical to the Grid in the core', bool(core_grid) and repeated == core_grid)

    lens_ids = re.findall(r'<a id="aris-lens-(\d\d)"></a>', prompt)
    add('lens anchors are exactly the six kept lenses, once each', lens_ids == sorted(LENSES), lens_ids)
    anchors = re.findall(r'<a id="([^"]+)"></a>', prompt)
    duplicates = sorted({a for a in anchors if anchors.count(a) > 1})
    add('no duplicate anchors', not duplicates, duplicates)
    anchor_set = set(anchors)
    bad_links = []
    for target in re.findall(r'\]\((<[^>]*>|[^)\s]+)', prompt):
        target = target.strip('<>')
        if target.startswith(('http://', 'https://', 'mailto:')):
            continue
        if not (target.startswith('#') and target[1:] in anchor_set):
            bad_links.append(target)
    add('every link is external or resolves to an anchor in the prompt', not bad_links, sorted(set(bad_links)))
    clicks = re.findall(r'(?m)^\s*click \w+ "([^"]*)"', prompt)
    bad_clicks = [t for t in clicks if not (t.startswith('#') and t[1:] in anchor_set)]
    add('Grid click targets resolve, in both Grid copies', len(clicks) >= 16 and not bad_clicks,
        {'click_lines': len(clicks), 'unresolved': bad_clicks})
    add('only the Grid maps remain (two in the core, two in the repeated Grid)', prompt.count('```mermaid') == 4,
        prompt.count('```mermaid'))

    harness_refs = sorted(set(m.group(0) for m in HARNESS_IDENTIFIERS.finditer(prompt)))
    add('no harness tool names, file names or server paths remain', not harness_refs, harness_refs)
    stale_promises = [p for p in ('saved continuity summary', 'registered-user consultation', 'supplied separately by the harness')
                      if p in prompt]
    add('no promise of saved records or a harness remains', not stale_promises, stale_promises)

    allowed = ALLOWED + STANDALONE_ALLOWED
    unexpected, accepted = [], []
    for name, text in scanned.items():
        for lineno, line in enumerate(text.split('\n'), 1):
            for m in FORBIDDEN.finditer(line):
                term = m.group(0).lower()
                rule = next((a for a in allowed if a['file'] == name and term.startswith(a['term'])
                             and a['line_contains'] in line), None)
                (accepted if rule else unexpected).append(f'{name}:{lineno}: {m.group(0)}')
    add('no dropped lens, dropped service or media-production term remains (reviewed uses allowlisted)',
        not unexpected, {'unexpected': unexpected, 'accepted': accepted})
    return results


# ---------------------------------------------------------------- main

def main():
    global PRINT_PINS
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', required=True, type=Path)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--print-pins', action='store_true')
    args = parser.parse_args()
    PRINT_PINS = args.print_pins
    if not PRINT_PINS and args.out is None:
        parser.error('--out is required unless --print-pins is given')

    def read(rel):
        path = args.source / rel
        if not path.is_file():
            fail('source', f'missing {rel}')
        return path.read_bytes()

    source_bytes = {rel: read(rel) for rel in list(MODULE_SOURCES.values()) + list(REFERENCE_SOURCES.values())}
    raw = {name: source_bytes[rel].decode('utf-8') for name, rel in MODULE_SOURCES.items()}
    release = json.loads(source_bytes[REFERENCE_SOURCES['release']])

    modules = {
        'GRID_CARD.md': edit_grid(raw['GRID_CARD.md']),
        'RECEPTION_DESK.md': edit_reception(raw['RECEPTION_DESK.md']),
        'SCRATCHPAD_INVESTIGATORY_TOOL.md': edit_scratchpad(raw['SCRATCHPAD_INVESTIGATORY_TOOL.md']),
        'CLINICAL_REASONING_TOOL.md': build_clinical(raw['CLINICAL_REASONING_TOOL.md']),
        'FIRST_AID.md': edit_first_aid(raw['FIRST_AID.md']),
        'HEALTH_PLAN.md': edit_health_plan(raw['HEALTH_PLAN.md']),
        'SOAP_TOOL.md': edit_soap(raw['SOAP_TOOL.md']),
        'OPERATIONS.md': edit_operations(raw['OPERATIONS.md']),
        'RULES_OF_ENGAGEMENT.md': edit_rules(raw['RULES_OF_ENGAGEMENT.md']),
    }

    standalone_sources = {}
    for name in STANDALONE_FILES:
        path = STANDALONE_SRC / name
        if not path.is_file():
            fail('standalone-source', f'missing standalone_src/{name}')
        standalone_sources[name] = path.read_text(encoding='utf-8')
    standalone_prompt, standalone_scanned = build_standalone(modules, standalone_sources)

    if PRINT_PINS:
        print(json.dumps(SEEN_PINS, indent=4))
        return 0
    stale_pins = sorted(set(PINS) - set(SEEN_PINS))
    if stale_pins:
        fail('pins', f'PINS entries no edit used: {stale_pins}')

    core = assemble(modules)
    rules = modules['RULES_OF_ENGAGEMENT.md']
    r11_core = source_bytes[REFERENCE_SOURCES['r11_core']].decode('utf-8')
    raw_for_selftest = {n: raw[n] for n in ASSEMBLY_ORDER}
    checks = check(core, rules, modules, r11_core, raw_for_selftest)
    standalone_checks = check_standalone(standalone_prompt, standalone_scanned)

    outputs = {'INSTRUCTION_SET.md': core, 'RULES_OF_ENGAGEMENT.md': rules}
    for name, text in modules.items():
        outputs[f'modules/{name}'] = text
    outputs['deployment/IMMEDIATE_CARE_REFERENCE_MANIFEST.json'] = source_bytes[REFERENCE_SOURCES['immediate_care_manifest']]
    outputs['standalone/SYSTEM_PROMPT.md'] = standalone_prompt

    def describe(data):
        raw_bytes = data.encode('utf-8') if isinstance(data, str) else data
        entry = {'sha256': sha(raw_bytes), 'bytes': len(raw_bytes)}
        if isinstance(data, str):
            entry['words'] = len(data.split())
        return entry

    grid = per_turn_grid(core)
    report = {
        'variant': 'R11-MH mental-health-only derivative (draft; not clinically reviewed; not installed)',
        'derived_from': {'package_id': release.get('package_id'), 'content_revision': release.get('content_revision')},
        'lenses': LENSES,
        'source_files': {rel: sha(data) for rel, data in sorted(source_bytes.items())},
        'outputs': {rel: describe(data) for rel, data in sorted(outputs.items())},
        'per_turn_grid': dict(PER_TURN_GRID, sha256=sha(grid), words=len(grid.split())),
        'checks': checks,
        'standalone': {
            'sources': {f'standalone_src/{n}': sha(t) for n, t in sorted(standalone_sources.items())},
            'checks': standalone_checks,
        },
    }
    outputs['BUILD_CHECKS.json'] = json.dumps(report, indent=2, ensure_ascii=False) + '\n'

    failed = [c for c in checks + standalone_checks if c['result'] != 'PASS']
    for heading, group in (('harness variant', checks), ('standalone variant', standalone_checks)):
        print(f'-- {heading}')
        for c in group:
            print(f"{c['result']:4}  {c['check']}")
            if c['result'] != 'PASS':
                print('      ', c['detail'])
    if failed:
        print('Build checks failed; nothing was written.', file=sys.stderr)
        return 1

    write_outputs(args.out, outputs)
    print(f"core words: {report['outputs']['INSTRUCTION_SET.md']['words']}  "
          f"rules words: {report['outputs']['RULES_OF_ENGAGEMENT.md']['words']}  "
          f"per-turn Grid words: {report['per_turn_grid']['words']}  "
          f"standalone prompt words: {report['outputs']['standalone/SYSTEM_PROMPT.md']['words']}")
    return 0


def write_outputs(out, outputs):
    """Write every output to a temporary directory, then move each into place; remove stale generated files."""
    out.mkdir(parents=True, exist_ok=True)
    tmp = Path(tempfile.mkdtemp(prefix='.build-', dir=out))
    try:
        for rel, data in outputs.items():
            path = tmp / rel
            path.parent.mkdir(parents=True, exist_ok=True)
            if isinstance(data, str):
                path.write_text(data, encoding='utf-8', newline='\n')
            else:
                path.write_bytes(data)
        for rel in outputs:
            target = out / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            os.replace(tmp / rel, target)
        for managed in ('modules', 'deployment', 'standalone'):
            for path in (out / managed).iterdir():
                if path.is_file() and f'{managed}/{path.name}' not in outputs:
                    path.unlink()
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
