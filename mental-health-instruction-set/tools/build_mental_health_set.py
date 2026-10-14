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
    'sa-grid:map': '8f79795aa2070bad8495569958795e9b359de041b96fe4ac670badb719b9b204',
    'sa-grid:handoff-map': '1342d0bd8ece9925d550aa60d41abf3663c694f84ca699e4da2a2ad8a100e31f',
    'sa-grid:registered-bullet': '9ac3f55682b764af08ac25c977bc803739049f210df67ea048aae68a5b9f3705',
    'sa-grid:checkpoint-bullet': '47199983230dbb7252530b07232e3af5277941dc5800027732d2f397a2c17ed9',
    'sa-grid:record-table': 'e37c42437a85ed0d412f2e27f35a6994cbe42c0d07e3c261675af9fa8f9282bb',
    'sa-scratchpad:registered-entry': '079a51ef86d88dc2e6fbed7a7800f2c2141ecd6f0d04ba6a078c0fec75569f1c',
    'sa-scratchpad:closing': '0baeb35d2c5e233dd17826530fca927e14aae3dadc1bb99d766e9112cb769d13',
    'sa-scratchpad:resuming': '747e3d1d09f3390f5a52b45dc4e4e322a5bcbc3283b47537dad17cd3fcc3a06c',
    'sa-scratchpad:interface': '996ca502c610830b50f32544bae364e24dde8628921029b5919a03d39830ad3a',
    'sa-scratchpad:templates': 'ad81c5b9df2ecd315d3023c9fb1a3f3da4acc7e32829a375359410cd5d5ec1c8',
    'sa-health-plan:template': '6e5f79755a73d9c68f3d4646935a4128a209bc49f192842c6f76faf61102eaa8',
    'sa-soap:step5': 'bba7612eb95617d0117359a23775c0357d60fcf3cb6ccf687edb70ca7f6e2585',
    'sa-soap:step6': '4f312e72e7002ec05b9f8db42c22e856feb4a5c783986502b204d55b3cfd19e0',
    'sa-soap:identity-closing': 'b9435f1cd55cd0e74b882a71b0fa4108f95faae488907dec32d01f9c20033f5c',
    'sa-soap:template': '5898ca624145c5ecec1e48d2c8a8d2455e58dd32b8602bd9e6e6f4f00ea27632',
    'sa-rules:r2-medical-file': '0855ddb51a8b350f6298a2e5e8a61198c570710a410f9c8da60e0b5b6d3f6002',
    'sa-rules:r14-arrangement': '580b987a5a0aeef2dbd8274dd1bfcc2db230c130dde06012862b23bd4c7e388e',
    'sa-mh:doctor-lens': '5bb0384e5d963e0a443e2b96e510a369e1ef784eda01dfe9885a674ac136075f',
    'sa-mh:doctor-row': '6f35c7e6298c8af6363710e8d010eff038db1b687a380119722edd80c6e1be14',
    'sa-mh:currency-metadata': 'c0c488f2f02951208b588c5e1dd455db397780347efd82a4b1c91ea38b063c05',
    'sa-mh:library-row': '7556da307c05a494a55a91372bc48b7c4bec71450c8a36e35fc02f84858a806e',
    'sa-mh:figure-display': '0bc1cd319c7cd76693589ec4aaac38055e0ae0a59bb67661d5361b2c8fe68e91',
    'sa-mh:aspirin-example': '7e5b08033790da8c387d261539b1a7214708c40c792fb5ac6b58e733a12590a5',
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
        return text[:i].rstrip('\n') + ('\n\n' + replacement if replacement else '\n')
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

def rewrite(text, anchors=ANCHORS):
    for name, anchor in anchors.items():
        text = (text.replace('(<' + name + '>)', '(#' + anchor + ')')
                    .replace('(' + name + ')', '(#' + anchor + ')')
                    .replace('"' + name + '"', '"#' + anchor + '"'))
    return text


def runtime_text(name, text, anchors=ANCHORS):
    text = rewrite(text, anchors)
    if name != 'GRID_CARD.md':
        text = re.sub(r'\n#{1,6} [^\n]+\n(?:[ \t]*\n)*```mermaid\n.*?\n```\n', '\n', text, flags=re.S)
        text = re.sub(r'\n```mermaid\n.*?\n```\n', '\n', text, flags=re.S)
        text = re.sub(r'(?m)^#{1,6} (?:Process map|Process maps|Flowchart)[^\n]*\n(?:[ \t]*\n)*(?=#{1,6} |\Z)', '', text)
    return text


def assemble(modules, anchors=ANCHORS):
    return '\n---\n\n'.join('<a id="' + anchors[n] + '"></a>\n\n' + runtime_text(n, modules[n], anchors) for n in ASSEMBLY_ORDER)


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
STANDALONE_FILES = ['DEPLOYMENT_FACTS.md', 'OPERATIONS.md', 'CRISIS_SUPPORT.md']

# The standalone variant is mental-health only: the general-medicine Doctor lens is removed.
STANDALONE_LENSES = {k: v for k, v in LENSES.items() if k != '01'}
STANDALONE_LENS_SUMMARY = 'Psychiatry, Psychology, Pharmacist, ADHD and Autism'

# In the standalone variant, Crisis Support takes First Aid's place in the assembly.
STANDALONE_ANCHORS = dict(ANCHORS, **{'FIRST_AID.md': 'aris-crisis-support'})

# Renames First Aid references in the generated modules and Rules; applied in order.
FIRST_AID_RENAMES = [
    ('> - **999** — for first aid or emergency assistance.', '> - **999** — if you are in crisis or in danger now.'),
    ('Acute deterioration, failing physiology or an immediate threat is routed to First Aid rather than to a lens.',
     'An immediate threat to safety is routed to Crisis Support, and acute physical deterioration or failing physiology '
     'is signposted to 999; neither goes to a lens.'),
    ('Immediate First Aid', 'Immediate Crisis Support'),
    ('immediate First Aid', 'immediate Crisis Support'),
    ('First-aid need', 'Crisis need'),
    ('first-aid need', 'crisis need'),
    ('First Aid', 'Crisis Support'),
    ('first-aid', 'crisis'),
    ('first aid', 'crisis support'),
]

# Physical first-aid content that must not reach the standalone prompt.
FIRST_AID_CONTENT = re.compile(
    r'first[ -]aid|ICP-0|cardiac arrest|chest compressions|tourniquet|heart attack might|stroke might|abdominal thrust'
    r'|aris-first-aid', re.IGNORECASE)
FIRST_AID_ALLOWED_SENTENCES = [
    'This set provides no physical first aid.',
    'This set gives no first-aid procedures.',
    'It gives no first-aid procedures.',
]

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
     'line_contains': 'Retrieving personal records, saving, scheduling, sending anything and producing media need a connected service.',
     'reason': 'States that media production is unavailable.'},
    {'file': 'standalone:DEPLOYMENT_FACTS.md', 'term': 'leaflet',
     'line_contains': 'point to the product leaflet, a pharmacist or the prescriber.',
     'reason': 'A medicine product leaflet as a source.'},
    {'file': 'standalone:DEPLOYMENT_FACTS.md', 'term': 'leaflet',
     'line_contains': "give Crisis Support's advice on possible overdose at once, not the leaflet",
     'reason': 'Overdose routing: tells the model not to rely on the medicine leaflet.'},
    {'file': 'standalone:CRISIS_SUPPORT.md', 'term': 'leaflet',
     'line_contains': 'give this advice at once, not the leaflet, even when there are no symptoms',
     'reason': 'Overdose routing: tells the model not to rely on the medicine leaflet.'},
    {'file': 'CLINICAL_REASONING_TOOL.md', 'term': 'leaflet',
     'line_contains': 'this lens does not judge from the amount or the leaflet whether it is safe',
     'reason': 'Pharmacist lens: sends an extra dose to the overdose advice rather than the leaflet.'},
]


def replace_all(text, old, new, label, expected):
    count = text.count(old)
    if count != expected:
        fail(label, f'expected {expected} matches, found {count}')
    return text.replace(old, new)


def standalone_rules(text):
    text = replace_once(text, 'System-wide requirements supplied separately by the harness.',
                        'System-wide requirements, supplied in this same prompt.', 'sa-rules:intro')
    text = replace_once(
        text,
        'Resolve a supplied self-introduction through the configured profile metadata and existing application access.',
        'A supplied self-introduction is a name, not identity; no profile metadata or record access is connected.',
        'sa-rules:r2-profile')
    text = replace_line(
        text, 'The owner’s standing recording arrangement makes ordinary registered health consultations recordable',
        'In this deployment there is no standing recording arrangement. Prepare a SOAP, plan, research or audit document as '
        'text in the chat when the person asks for one or accepts an offer. A person\'s choice not to have a document '
        'prepared takes precedence over any offer. A format request is not a SOAP request, and a document is not created '
        'merely to complete a checklist.',
        'sa-rules:r14-arrangement')
    text = replace_once(
        text,
        'At close, reuse an unchanged accepted SOAP and its actual content revision instead of creating a duplicate. '
        'New clinical content uses the appropriate continuation or amendment. After formal-record outcomes, prepare the '
        'relevant consolidated-memory handover. A failed save leaves its exact outcome and unfinished work; it does not '
        'restore a superseded clinical fact.',
        'At close, do not prepare again a note already prepared in this conversation whose content is unchanged. New '
        'clinical content uses the appropriate continuation or amendment. After any other records, offer the continuity '
        'summary described in the deployment facts.',
        'sa-rules:r14-close')
    text = cut_between(
        text, 'Ordinary registered consultations use the current persistent memory', 'A supplied self-introduction is a name, not identity',
        'sa-rules:r2-medical-file',
        replacement=(
            'No medical file, condensed record or persistent memory is connected in this deployment, so no full-file read, '
            'intake or audit permission arises. Material the person pastes or attaches is supplied material: work only with '
            'what was supplied, do not ask permission to open records that cannot be opened, and do not reconstruct missing '
            'content. Reading supplied material never permits rewriting the source.\n\n'
        ))
    text = replace_once(text, 'Retain the accepted state revision, corrections and request identities through the state interface.',
                        'Retain the accepted working picture and its corrections in the conversation.', 'sa-rules:r19-state')
    return text


STANDALONE_GRID_MAP = '''flowchart TD
    OPEN["Conversation opening without an enquiry"] --> R["Reception Desk"]
    R -- "Introduction / invitation" --> C["Chat"]
    R -- "Supplied opening information" --> W["Scratchpad Investigatory Tool<br/>Current working picture"]
    IN["Name, enquiry, reply, correction, new information<br/>or pasted summary, note or record"] --> W
    IN -- "Immediate First Aid" --> FA["First Aid"]
    R -- "Immediate First Aid request" --> FA
    W -- "First-aid need / urgent development" --> FA
    W -- "Clinical / data-usability / Evidence from available picture" --> E["Clinical Reasoning"]
    E -- "Findings / assessment / investigation question" --> W
    W -- "Factual result / question / limitation / non-patient close" --> C
    E -- "General consultation / source contribution" --> C
    FA -- "Findings / assessment question" --> W
    E -- "First-aid need / assessment return" --> FA
    FA -- "Immediate / continuing contribution" --> C
    W -- "Develop / review plan" --> P["Health Plan"]
    P -- "Picture / updates / clinical question" --> W
    E -- "Planning contribution" --> P
    P -- "Plan / question / present position" --> C
    W -- "Supplied material / practical task" --> O["Operations"]
    O -- "Practical outcome / not available here" --> W
    W -- "Note requested or offer accepted / amendment" --> N["SOAP Creation"]
    N -- "Prepare in chat" --> O
    O -- "Prepared note (not saved)" --> N
    N -- "Prepared note, not saved" --> W
    W -- "Close: offer continuity summary" --> O
    P -- "Prepare plan in chat" --> O
    O -- "Prepared plan (not saved)" --> P
    C -- "Material for a requested note" --> N
    N -- "Picture / missing basis / changed findings" --> W
    N -- "Note (prepared, not saved)" --> C
    C -- "Reply / new information" --> IN
    click R "RECEPTION_DESK.md"
    click W "SCRATCHPAD_INVESTIGATORY_TOOL.md"
    click E "CLINICAL_REASONING_TOOL.md"
    click FA "FIRST_AID.md"
    click P "HEALTH_PLAN.md"
    click N "SOAP_TOOL.md"
    click O "OPERATIONS.md"
'''

STANDALONE_HANDOFF_MAP = '''    Q["Requesting process"] --> O["Operations"]
    O --> G{"Can it be done<br/>within the conversation?"}
    G -- "Yes" --> X["Prepare text / read supplied material"]
    G -- "Needs a connected service" --> NS["Not available in this deployment"]
    X --> B["Return to originating process"]
    NS --> B
'''


def standalone_grid(text):
    text = replace_once(text, '# Dr Seraphina Aris - Health Assistant V1 R11-MH (mental-health draft)\n',
                        '# Dr Seraphina Aris - Mental Health Assistant V1 R11-MH standalone (draft)\n',
                        'sa-grid:title')
    text = cut_between(text, 'flowchart TD\n    OPEN["Conversation opening without an enquiry"]', '```\n\n## Operations handoff',
                       'sa-grid:map', replacement=STANDALONE_GRID_MAP)
    text = cut_between(text, '    Q["Requesting process"] --> O["Operations"]', '```\n\n## Enquiry and continuity connections',
                       'sa-grid:handoff-map', replacement=STANDALONE_HANDOFF_MAP)
    text = replace_line(
        text, '- Registered consultation starts with persistent memory',
        '- No person registry, stored record or persistent memory is connected in this deployment. Background comes from '
        'what the person supplies in the conversation, including a continuity summary pasted from an earlier conversation.',
        'sa-grid:registered-bullet')
    text = replace_line(text, '- A checkpoint identifies the actual unfinished work',
                        '- A pasted continuity summary can name unfinished work from an earlier conversation; continue it '
                        'from what the person supplies, and ask what has changed since.', 'sa-grid:checkpoint-bullet')
    text = replace_once(text, 'closing memory follows the formal-record outcomes.',
                        'a closing continuity summary follows any other records prepared.', 'sa-grid:closing-memory')
    text = replace_once(text, 'Operations carries the applicable tool preconditions and returned outcomes.',
                        'Operations states what can be done within the conversation and returns unavailable work as unavailable.',
                        'sa-grid:operations-sentence')
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
        "I can't carry anything over to a later conversation, although the chat application you are using may keep its "
        'own history of this one. If you kept a continuity summary from an earlier conversation, you can paste it here '
        'to carry on.',
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
    text = replace_once(text, 'Registered/guest describes personal context, while First Aid/educational describes the requested work.',
                        "A name or 'Guest' only sets how the person is addressed; neither opens records. First Aid/educational "
                        'describes the requested work.', 'sa-reception:registered-guest')
    return text


def standalone_scratchpad(text):
    text = replace_once(text, '| Continuity | Consolidated summary reference and revision, provisional-review position, sources and '
                              'distinct discovery/read/processing/incorporation checkpoints, filing outcomes and matters needed '
                              'for later review. |',
                        '| Continuity | Any pasted continuity summary with its date, material supplied and read, records prepared '
                        'in this conversation, and matters for a later conversation. |', 'sa-scratchpad:continuity-row')
    text = replace_once(text, 'Personal-record operations receive the subject selected through the existing application interface.',
                        'No registry is connected, so no personal-record operation applies.', 'sa-scratchpad:record-operations')
    text = replace_once(text, 'Operations resolves a supplied registered introduction through profile metadata under existing application access.',
                        'A supplied name is a form of address, not identity, and opens no records.', 'sa-scratchpad:introduction')
    text = cut_between(
        text, '### Registered entry: persistent memory first', '## How the person is feeling and managing',
        'sa-scratchpad:registered-entry',
        replacement=(
            '### Entry without a registry\n\n'
            'No registry, persistent memory or medical file is connected, so no one is a registered user, no lookup is made '
            'and no permission to read a medical file is requested. A name, including a full name, is only the person\'s '
            'chosen form of address: it starts no retrieval or intake, and help does not wait on it. Every consultation '
            'begins from the person\'s current account. If the person gives only a name, acknowledge it and invite them to '
            'say what they need.\n\n'
            'Earlier background comes only from what the person supplies in this conversation: a pasted continuity summary, '
            'an earlier note, plan, letter or result, or their own account. Attribute it, keep its date and origin, review '
            'it only as far as it was actually read, and say what was not supplied. For a pasted continuity summary, note its '
            'date, ask what has changed since, and bring its still-relevant background, active plans and open questions into '
            'the working picture without treating its earlier assessments, including any earlier statement about safety, as '
            'current. Present the useful update and answer rather than reciting the summary. Nothing is saved or resumed '
            'outside this conversation.\n\n'
        ))
    text = replace_once(
        text,
        'A child disclosure or safeguarding concern without immediate danger develops through the Doctor perspective; '
        'immediate danger goes straight to First Aid while the child\'s account remains attributed and minimally questioned.',
        'A disclosure of abuse, neglect or exploitation without immediate danger follows **Safeguarding** in the deployment '
        'facts, with the Doctor perspective for any medical question; immediate danger goes straight to First Aid while the '
        'person\'s account remains attributed and minimally questioned.',
        'sa-scratchpad:safeguarding')
    text = replace_once(text, 'or request related records and clinical sources through Operations',
                        'or ask the person for related records they hold', 'sa-scratchpad:request-records')
    text = replace_once(text, 'preparation of a note and its storage are separate events supplied by SOAP and Operations',
                        'a note is prepared by SOAP and presented in the chat; nothing is stored', 'sa-scratchpad:note-storage')
    text = replace_once(text, 'The account enters attributed `current_facts` as reported information.',
                        'The account enters the working picture as attributed, reported information.', 'sa-scratchpad:current-facts')
    text = replace_once(text, 'A relevant unanswered question remains in `questions` as information not yet obtained,',
                        'A relevant unanswered question remains open as information not yet obtained,', 'sa-scratchpad:questions')
    text = replace_once(text, 'sufficiently specified practical work, source retrieval and document delivery go to Operations.',
                        'sufficiently specified practical work, reading supplied material and preparing documents as text go '
                        'to Operations.', 'sa-scratchpad:routing')
    text = cut_between(
        text, 'The working picture carries the recording choice and the documents arising from the consultation.',
        '## Source standing and data usability', 'sa-scratchpad:closing',
        replacement=(
            'The working picture carries the recording choice and the documents prepared in this conversation. SOAP, Health '
            'Plan or the audit process prepares the relevant account as text when the person asks for one or accepts an '
            'offer; Operations presents it in the chat. Nothing is saved.\n\n'
            'At the close of a consultation that produced findings, advice or plans, finalise the useful working-picture '
            'position and offer a continuity summary, using the Operations layout and prepared after any other records. It '
            'carries forward still-relevant background from any summary the person pasted, active plans, unanswered '
            'questions and this consultation. It is a consolidated handover, not a diary of the last exchange. Name any '
            'pasted summary it follows by that summary\'s own stated date. Do not create a record code, reference number or '
            'time; a date appears only as the Operations record header allows. A summary the person declines is not '
            'prepared, and an interrupted conversation is never presented as a completed close.\n\n'
            '## Selecting and preserving the clinical handover\n\n'
            'Choose the clinically relevant content of the continuity summary: still-relevant background, the person\'s '
            'explicit preferences, current findings and their interpretation, meaningful changes, active plans, outstanding '
            'questions, safety matters discussed, health-data findings and the material actually read. Selection and '
            'organisation are part of the clinical handover. Copying every fact into background, leaving known preferences '
            'empty, or treating every previous assessment as current does not accomplish that work.\n\n'
            'Keep current and superseded information distinct, with the history needed to interpret the change. A sourced '
            'consideration that a perspective adds no material clinical conclusion is different from a new provisional '
            'diagnosis. Preserve known measurement periods, units, source series and limitations in the health-data account; '
            'keep genuinely unknown fields unknown.\n\n'
            'If the conversation is interrupted, give the useful answer and state what remains unfinished; nothing carries '
            'over unless the person keeps a summary. Immediate First Aid can interrupt routine record work at any point.\n\n'
        ))
    text = cut_between(
        text, '## Keeping and resuming the working picture', '## Working-picture interface', 'sa-scratchpad:resuming',
        replacement=(
            '## Keeping and resuming the working picture\n\n'
            'Within this conversation, the working picture, its sources and unfinished investigation support the next reply '
            'without repeating Reception. A located reference, inspected passage and appraised claim remain distinct.\n\n'
            'A new conversation opens a new working picture from the current account and supplied material only. A pasted '
            'continuity summary brings forward dated continuity; it does not import the earlier conversation. A bare "resume" '
            'or "carry on from last time" with nothing pasted gets a brief explanation that earlier conversations cannot be '
            'seen here, and an invitation to paste the summary or describe where things stand. Earlier content is never '
            'reconstructed or guessed.\n\n'
        ))
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


def standalone_clinical(text):
    text = replace_once(text, 'Operations performs the numerical work from that method, inputs and units.',
                        'No calculation facility is connected in this deployment; Operations, Calculations, states what can be given.',
                        'sa-clinical:calculation')
    text = replace_once(text, 'obtained through Operations', 'that the person has supplied', 'sa-clinical:related-history')
    text = replace_once(text, 'Operations obtains material and the scratchpad records its source and coverage.',
                        'Material comes from what the person supplies, and the scratchpad records its source and coverage.',
                        'sa-clinical:obtains-material')
    return text


def standalone_health_plan(text):
    text = replace_once(text, 'A later consultation obtains the recorded plan through the filing system.',
                        'The plan is not kept after this conversation; a later conversation can use it only if the person '
                        'pastes it back, so offer it in a form they can keep.', 'sa-health-plan:filing')
    text = replace_once(text, 'Operations supplies requested document production or connected actions and their outcomes.',
                        'Operations prepares a requested plan document as text in the chat; booking, reminders and contact are '
                        'unavailable, so offer wording the person can use themselves.', 'sa-health-plan:connected-actions')
    return cut_between(
        text, '## Record template', None, 'sa-health-plan:template',
        replacement=(
            '## Preparing the plan as a document\n\n'
            'For a plan prepared as a document, Operations uses its health-plan layout. Populate the chosen goals, proposed '
            'or agreed actions, ownership, feasibility and review from the actual discussion. Clinical Reasoning supplies the '
            'assessment; the layout supplies the structure. The plan is prepared in the chat for the person to keep; it is '
            'not saved. Relevant planning content still contributes to SOAP P.\n'
        ))


def standalone_soap(text):
    text = replace_once(text, "Bring together the person's existing reference where available, current enquiry,",
                        'Bring together how the patient was named, if they were, the current enquiry,', 'sa-soap:step1')
    text = replace_line(
        text, '5. **Prepare and file.**',
        '5. **Prepare.** When the person asks for a note, or accepts an offer of one, prepare the dated account in the chat '
        'using the Operations SOAP layout. Nothing is filed or saved, and no reference number is created.',
        'sa-soap:step5')
    text = replace_line(
        text, '6. **Return the handover material.**',
        '6. **Return the handover material.** Return the prepared note to the working picture. At close its content feeds '
        'the continuity summary offered to the person. A note the person keeps and later pastes back is supplied material.',
        'sa-soap:step6')
    text = replace_once(text, 'The note identifies the patient, existing patient reference where available, encounter,',
                        'The note identifies the patient, encounter,', 'sa-soap:identity')
    text = replace_once(text, 'This travels with the account during later retrieval,',
                        'This stays with the note if the person keeps it and pastes it back,', 'sa-soap:provenance')
    text = replace_once(text, '| Relationships | Relevant earlier record and any established amendment or saved-note reference. |',
                        '| Relationships | Relevant earlier supplied record or note, and any amendment link. |', 'sa-soap:relationships')
    text = replace_once(text, 'Known correction content can remain preparatory while its original saved reference is missing.',
                        'Known correction content can remain preparatory while the earlier note is not supplied.', 'sa-soap:correction')
    text = replace_once(text, 'Recording or saving has a separate outcome.', 'Nothing is saved.', 'sa-soap:recording-outcome')
    text = replace_once(text, 'The working picture supplies the recording arrangement and purpose of the account. Its clinical '
                              'content can be prepared before any storage result is available.',
                        'The working picture supplies the purpose of the account and any request for a note.', 'sa-soap:purpose')
    text = replace_once(text, 'source dates and recording arrangement.', 'and source dates.', 'sa-soap:step1-arrangement')
    text = replace_once(text, 'Rules R14 owns the authorship and filing requirements', 'Rules R14 owns the authorship requirements',
                        'sa-soap:r14-filing')
    text = replace_once(text, 'accompany the note through its reference without', 'accompany the note, named in it, without',
                        'sa-soap:audit-reference')
    text = replace_once(text, 'correction material awaiting a reference', 'correction material naming the earlier note',
                        'sa-soap:document-kind')
    text = replace_once(text, 'A requested account can be prepared and unsaved. A dated amendment may await storage.',
                        'A requested account is prepared in the chat and not saved. A dated amendment names the note it corrects.',
                        'sa-soap:await-storage')
    text = replace_once(text, '| Recording | Unsaved/preparation-only, or the position returned by Operations. |',
                        '| Recording | Prepared in the chat; not saved. |', 'sa-soap:recording-row')
    text = replace_once(text, 'A reference can connect the matter to an acknowledged pending operation or earlier source.',
                        'A reference can connect the matter to an earlier supplied source.', 'sa-soap:pending')
    text = replace_once(
        text,
        'The recording arrangement can be a prepared copy, temporary session note or a record submitted through Operations. '
        'The returned position describes the note and any established stored reference or linkage. A storage limitation '
        'accompanies prepared content while the enquiry continues.',
        'In this deployment there is no standing recording arrangement. A note is prepared in the chat only when the person '
        'asks for one or accepts an offer; nothing is submitted or stored. The note says so, and the enquiry continues.',
        'sa-soap:arrangement')
    text = replace_once(
        text,
        'A later registered consultation reads its current consolidated memory first, then the condensed record and changed '
        'or relevant original notes/amendments as attributed history.',
        'A later conversation starts from what the person supplies, such as a pasted continuity summary or an earlier note, '
        'as attributed history.',
        'sa-soap:later-consultation')
    text = replace_once(text, 'Operations retrieves the material requested; the scratchpad receives its attributed account',
                        'Earlier notes are available only as the person supplies them; the scratchpad receives their '
                        'attributed account', 'sa-soap:later-use')
    text = replace_line(
        text, 'The template and record interface carry patient, encounter',
        'A prepared note names the patient as named in the conversation, if named, and the reporter where different; the '
        'encounter date if known; its preparation in this conversation by an AI health assistant; and any earlier note it '
        'continues or amends. At close, the current discussion is compared with any note already prepared in this '
        'conversation: unchanged content is not prepared again, while later information or a correction takes the '
        'continuation or amendment route. Record outcomes then feed the closing continuity summary.',
        'sa-soap:identity-closing')
    text = cut_between(
        text, '## Record template', None, 'sa-soap:template',
        replacement=(
            '## Preparing the note\n\n'
            'Operations uses its SOAP note layout for a SOAP, continuation or amendment. A layout is a blank structure; its '
            'unknowns stay unknown. The prepared note is presented in the chat for the person to keep; it is not saved.\n'
        ))
    return text


def standalone_mental_health_only(modules, rules):
    """Remove the Doctor lens and retrieval-only Evidence material; name the assistant a mental-health assistant."""
    clinical = modules['CLINICAL_REASONING_TOOL.md']
    # The Doctor lens's fatigue and sleep subsection bears on mental health, so it moves into Psychiatry.
    fatigue_head = '#### Clarifying fatigue, sleepiness and reduced physical ability'
    if clinical.count(fatigue_head) != 1:
        fail('sa-mh:fatigue', 'fatigue subsection heading not found once')
    fatigue = clinical[clinical.index(fatigue_head):clinical.index('<a id="aris-lens-02"></a>')].strip()
    fatigue = replace_once(fatigue, fatigue_head, '##### Clarifying fatigue, sleepiness and low energy', 'sa-mh:fatigue-head')
    fatigue = replace_once(fatigue, 'The doctor explores', 'The clinician explores', 'sa-mh:fatigue-clinician')
    fatigue = replace_once(fatigue, 'The medical account also examines', 'The account also examines', 'sa-mh:fatigue-account')
    fatigue = replace_once(
        fatigue,
        'Investigation follows the supported possibilities and examination findings, rather than a fixed test panel for every '
        'description of tiredness.',
        "A possible physical or sleep-related cause is for the person's GP to assess, or NHS 111 the same day if it is sudden "
        'or rapidly worsening, rather than being set aside as part of the mental-health picture.',
        'sa-mh:fatigue-investigation')
    clinical = cut_between(clinical, '<a id="aris-lens-01"></a>', '<a id="aris-lens-02"></a>', 'sa-mh:doctor-lens')
    clinical = replace_once(clinical, '#### Medicines, substances and competing explanations',
                            fatigue + '\n\n#### Medicines, substances and competing explanations', 'sa-mh:fatigue-move')
    clinical = replace_once(clinical, '[01 Doctor](#aris-lens-01) | ', '', 'sa-mh:lens-index')
    clinical = replace_once(clinical, f'the six professional and specialist lenses in this set ({LENS_SUMMARY})',
                            f'the five professional and specialist lenses in this set ({STANDALONE_LENS_SUMMARY})', 'sa-mh:purpose')
    clinical = drop_line(clinical, '| Underlying disease, physiological change, investigation and medical management | Doctor |',
                         'sa-mh:doctor-row')
    clinical = replace_once(
        clinical,
        'Medical assessment contributes to mental-health presentations where physical illness or treatment effects may be involved.',
        'Physical illness, substances and treatment effects can cause, mimic or complicate a mental-health presentation; the '
        "Psychiatry and Pharmacist perspectives consider them. A suspected physical cause is for the person's GP to assess. "
        'Sudden confusion needs 999 or A&E now ([NHS: confusion](https://www.nhs.uk/symptoms/confusion/)), and any other '
        'sudden or rapidly worsening change needs same-day advice from NHS 111 or an urgent GP appointment.',
        'sa-mh:medical-assessment')
    clinical = replace_once(
        clinical,
        'Physical conditions outside the perspectives above are assessed only as far as the perspectives in this set allow; '
        'care navigation then helps the person reach an appropriate service. This set contains no specialist lenses for them.',
        'A health question with no mental-health aspect is outside this set (see **Scope** in the deployment facts); care '
        'navigation helps the person reach an appropriate service.',
        'sa-mh:out-of-scope')
    clinical = replace_once(
        clinical,
        'Neither a detailed description nor a clear image supplies palpation, auscultation, a complete neurological examination '
        'or an unrecorded physiological measurement.',
        'Neither a detailed description nor a clear image supplies an observed mental state, a physical examination or an '
        'unrecorded measurement.',
        'sa-mh:remote-assessment')
    clinical = replace_once(
        clinical,
        'A report that a person walked across the room differs from a formal assessment of power, balance or exercise capacity.',
        'A report that a person seemed withdrawn differs from a formal assessment of their mental state.',
        'sa-mh:home-observation')
    clinical = replace_once(clinical, 'Established immediate-care procedures support urgent action;',
                            "Crisis Support's established signposts support urgent action;", 'sa-mh:evidence-crisis')
    # Pharmacist: psychotropic examples in place of respiratory ones, and the extra-dose route to Crisis Support.
    clinical = drop_paragraph(clinical, 'A reported aspirin-associated respiratory reaction', 'sa-mh:aspirin-example')
    clinical = replace_once(clinical, '##### Unidentified products and reaction history', '##### Unidentified products',
                            'sa-mh:unidentified-heading')
    clinical = replace_once(clinical, '### Representation and original figures', '### Representation of records and images',
                            'sa-mh:representation-heading')
    clinical = replace_once(clinical, 'A library passage or web page can be appraised',
                            'A source passage or web page can be appraised', 'sa-mh:library-passage')
    clinical = replace_once(
        clinical,
        "Modified-release products can differ in release profile, and an inhaler's effectiveness depends partly on technique "
        "and the person's ability to use it.",
        'Modified-release products, such as different methylphenidate or quetiapine preparations, can differ in release '
        'profile, and a liquid, orodispersible or long-acting injectable form can change how usable a regimen is.',
        'sa-mh:formulation')
    clinical = replace_once(clinical, 'food requirements, storage and use of inhalers or other devices',
                            'food requirements and storage', 'sa-mh:devices')
    clinical = replace_once(clinical, 'Resistance, availability and shortages may influence choice',
                            'Availability and shortages may influence choice', 'sa-mh:resistance')
    clinical = replace_once(
        clinical,
        'An administration record, packaging or a reliable account may resolve uncertainty that memory alone leaves open.',
        'An administration record, packaging or a reliable account may resolve uncertainty that memory alone leaves open. '
        'A possible extra dose, or any amount above the intended dose, taken intentionally or by mistake, goes first to '
        "Crisis Support's advice on possible overdose (R11), even without symptoms; this lens does not judge from the amount "
        "or the leaflet whether it is safe. A missed or stopped medicine where the gap may matter also follows Crisis "
        "Support's section on missed or stopped medicines.",
        'sa-mh:extra-dose')
    clinical = cut_between(
        clinical, '### Currency and returned metadata', '### Web and deep research', 'sa-mh:currency-metadata',
        replacement='### Currency\n\nA dated source describes practice as at its date, and a newer edition or retrieval date does '
                    'not update every statement in it. If currentness remains unresolved, the assessment separates what the '
                    'dated source describes from a current-practice conclusion requiring further support, and the limitation '
                    'stays with the affected conclusion.\n\n')
    clinical = drop_line(clinical, '| Medical reference library |', 'sa-mh:library-row')
    clinical = drop_paragraph(clinical, 'A caption or label list can identify a figure', 'sa-mh:figure-display')
    modules['CLINICAL_REASONING_TOOL.md'] = clinical
    grid = replace_once(
        modules['GRID_CARD.md'], f'six professional and specialist lenses ({LENS_SUMMARY})',
        f'five professional and specialist lenses ({STANDALONE_LENS_SUMMARY})', 'sa-mh:grid-lenses')
    # The routing-map node for Crisis Support keeps R11's First Aid id; rename it so no First Aid abbreviation remains.
    if re.search(r'\bCS\b', grid) or len(re.findall(r'\bFA\b', grid)) != 7:
        fail('sa-mh:grid-node', 'expected exactly 7 uses of node id FA and none of CS in the Grid map')
    modules['GRID_CARD.md'] = re.sub(r'\bFA\b', 'CS', grid)
    modules['SCRATCHPAD_INVESTIGATORY_TOOL.md'] = replace_once(
        modules['SCRATCHPAD_INVESTIGATORY_TOOL.md'], ', with the Doctor perspective for any medical question;',
        ", with any medical question signposted to the person's GP or NHS 111;", 'sa-mh:safeguarding-doctor')
    for name in modules:
        modules[name] = modules[name].replace('AI health assistant', 'AI mental-health assistant')
    rules = replace_once(rules, '**Dr Seraphina Aris - Health Assistant V1**', '**Dr Seraphina Aris - Mental Health Assistant V1**',
                         'sa-mh:rules-title')
    rules = replace_once(rules, '**AI health assistant**', '**AI mental-health assistant**', 'sa-mh:r5')
    rules = replace_once(
        rules,
        'A released source-checked immediate-care procedure can be used within its documented scope and review boundary, '
        'subject to known conflicting information.',
        "Crisis Support's signposts and safety guidance can be used within their stated scope, subject to known conflicting "
        'information.',
        'sa-mh:r6')
    rules = replace_once(rules, 'Crisis Support may use its already source-checked immediate procedure without waiting for '
                         'a repeat lookup', 'Crisis Support may give its signposts and safety guidance without waiting for a '
                         'source lookup', 'sa-mh:r13')
    modules['HEALTH_PLAN.md'] = replace_once(
        modules['HEALTH_PLAN.md'], 'A plan can concern general health, connected problems,',
        'A plan can concern mental health and wellbeing, connected problems,', 'sa-mh:plan-scope')
    modules['HEALTH_PLAN.md'] = replace_once(
        modules['HEALTH_PLAN.md'], 'supplies the framework for adults with multiple long-term conditions.',
        'supplies the framework for adults with multiple long-term conditions, where physical conditions also affect the plan.',
        'sa-mh:plan-ng56')
    return modules, rules


def build_standalone(mh_modules, standalone_sources):
    modules = dict(mh_modules)
    modules['GRID_CARD.md'] = standalone_grid(modules['GRID_CARD.md'])
    modules['RECEPTION_DESK.md'] = standalone_reception(modules['RECEPTION_DESK.md'])
    modules['SCRATCHPAD_INVESTIGATORY_TOOL.md'] = standalone_scratchpad(modules['SCRATCHPAD_INVESTIGATORY_TOOL.md'])
    modules['CLINICAL_REASONING_TOOL.md'] = standalone_clinical(modules['CLINICAL_REASONING_TOOL.md'])
    modules['HEALTH_PLAN.md'] = standalone_health_plan(modules['HEALTH_PLAN.md'])
    modules['SOAP_TOOL.md'] = standalone_soap(modules['SOAP_TOOL.md'])
    rules = standalone_rules(modules.pop('RULES_OF_ENGAGEMENT.md'))
    for name in list(modules) + ['rules']:
        text = rules if name == 'rules' else modules[name]
        for old, new in FIRST_AID_RENAMES:
            text = text.replace(old, new)
        if name == 'rules':
            rules = text
        else:
            modules[name] = text
    modules, rules = standalone_mental_health_only(modules, rules)
    modules['OPERATIONS.md'] = standalone_sources['OPERATIONS.md']
    modules['FIRST_AID.md'] = standalone_sources['CRISIS_SUPPORT.md']
    facts = standalone_sources['DEPLOYMENT_FACTS.md']
    core = assemble(modules, STANDALONE_ANCHORS)
    grid = per_turn_grid(core).replace(f'<a id="{PER_TURN_GRID["start_anchor"]}"></a>', '').strip()
    grid = re.sub(r'\n-{3}\s*$', '', grid).strip()
    repeat_note = 'Repeat of the Grid Card above, for routing on every turn. It adds no new instructions.'
    prompt = '\n\n---\n\n'.join([rules.strip(), facts.strip(), core.strip(),
                                  PER_TURN_GRID['marker'] + '\n\n' + repeat_note + '\n\n' + grid]) + '\n'
    scanned = {n: t for n, t in modules.items() if n not in ('OPERATIONS.md', 'FIRST_AID.md')}
    scanned['RULES_OF_ENGAGEMENT.md'] = rules
    scanned['standalone:OPERATIONS.md'] = standalone_sources['OPERATIONS.md']
    scanned['standalone:CRISIS_SUPPORT.md'] = standalone_sources['CRISIS_SUPPORT.md']
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
    if repeated:
        repeated = repeated.split('\n\n', 1)[-1].strip()
    add('per-turn Grid is repeated at the end, identical to the Grid in the core', bool(core_grid) and repeated == core_grid)

    lens_ids = re.findall(r'<a id="aris-lens-(\d\d)"></a>', prompt)
    add('lens anchors are exactly the five standalone lenses, once each', lens_ids == sorted(STANDALONE_LENSES), lens_ids)
    leftovers = sorted(set(re.findall(r'Doctor (?:perspective|lens)|\| Doctor \||AI health assistant|(?<!Mental )Health Assistant V1|\bFA\b', prompt)))
    add('no Doctor lens routing, general "health assistant" naming or First Aid node id remains', not leftovers, leftovers)
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
    add('Grid click targets resolve, in both Grid copies', len(clicks) == 14 and not bad_clicks,
        {'click_lines': len(clicks), 'unresolved': bad_clicks})
    add('only the Grid maps remain (two in the core, two in the repeated Grid)', prompt.count('```mermaid') == 4,
        prompt.count('```mermaid'))

    harness_refs = sorted(set(m.group(0) for m in HARNESS_IDENTIFIERS.finditer(prompt)))
    add('no harness tool names, file names or server paths remain', not harness_refs, harness_refs)
    stale_promises = [p for p in ('saved continuity summary', 'registered-user consultation', 'supplied separately by the harness')
                      if p in prompt]
    add('no promise of saved records or a harness remains', not stale_promises, stale_promises)

    visible = re.sub(r'\]\((<[^>]*>|[^)\s]+)\)', ']()', prompt)  # link targets are not model-visible prose
    for sentence in FIRST_AID_ALLOWED_SENTENCES:
        visible = visible.replace(sentence, '')
    first_aid = sorted(set(m.group(0) for m in FIRST_AID_CONTENT.finditer(visible)))
    add('no first-aid procedures or First Aid references remain; Crisis Support is present',
        not first_aid and prompt.count('<a id="aris-crisis-support"></a>') == 1 and '# Crisis Support' in prompt, first_aid)

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
