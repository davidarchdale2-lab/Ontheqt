# Mental-health instruction set (draft)

A mental-health-only derivative of the Dr Seraphina Aris Health Assistant V1 R11 instruction set. It keeps the routing, the shared clinical engine, First Aid and the record tools. It keeps six specialist lenses and drops the physical and allied-health lenses and all media production.

**Status: draft.** Built and structurally checked. Not clinically reviewed, not loaded into a model, not installed.

## Contents

| Path | What it is |
|---|---|
| `INSTRUCTION_SET.md` | The core instructions, assembled. Load as the stable system content. |
| `RULES_OF_ENGAGEMENT.md` | The Rules. Load as a separate system message. |
| `modules/` | The same modules as separate files, for review and editing. |
| `MODULES.md` | What each module is, what was kept, edited or dropped, and why. |
| `HARNESS_REQUIREMENTS.md` | What the harness must provide, the safety-critical requirements, and the decisions the owner needs to make. |
| `BUILD_CHECKS.json` | Output of the last build: structural checks and file hashes. |
| `tools/build_mental_health_set.py` | Rebuilds everything from the R11 source. |

## Rebuild

```
python3 -I tools/build_mental_health_set.py \
  --source <path to Dr_Seraphina_Aris_Health_Assistant_V1_R11> \
  --out .
```

The build applies each edit as an exact-match replacement that must match once. If the source changes, it stops and reports which edit no longer matches, rather than producing a silently wrong file.

## Scope decisions made here

- **Lenses kept:** 01 Doctor, 02 Psychiatry, 03 Psychology, 04 Pharmacist, 09 ADHD, 10 Autism. Nursing, occupational therapy, physiotherapy and dietetics are dropped and can be added back.
- **Kept as is:** First Aid (including the 999 and suicidal-threat routes), the shared engine's mental-health and neurodevelopmental distinctions, and the Evidence section.
- **Dropped:** media production, physiotherapy assets, clinical source images, and the illustration sections.
- **Not changed:** the lens bodies, the Rules text beyond the media paragraph, and the record templates.
- **Test battery:** excluded, per your instruction.

## Open items

See section 10 of `HARNESS_REQUIREMENTS.md`. The main ones are the search and browser dependency, the lack of a harness-side output safety filter, and the identifiers in the R11 storage profile.
