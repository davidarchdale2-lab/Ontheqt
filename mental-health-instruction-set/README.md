# Mental-health instruction set (R11-MH, draft)

A mental-health-only derivative of the Dr Seraphina Aris Health Assistant V1 R11 instruction set. It keeps the routing, the shared clinical engine, First Aid and the record tools, keeps six specialist lenses, and drops the physical and allied-health lenses and all media production.

**Status: draft.** Built and structurally checked. Not clinically reviewed, not loaded into a model, not installed. Not for clinical use.

## Contents

| Path | Kind | What it is |
|---|---|---|
| `START_HERE.md` | Written | One-page orientation. |
| `INSTRUCTION_SET.md` | Generated | The core instructions. |
| `RULES_OF_ENGAGEMENT.md` | Generated | The Rules. Loaded as a separately hashed section ahead of the core. |
| `modules/` | Generated | The same modules as separate files, with their process maps. A read-only review copy. |
| `deployment/IMMEDIATE_CARE_REFERENCE_MANIFEST.json` | Copied | Source and review dates for the First Aid immediate-care procedures. |
| `BUILD_CHECKS.json` | Generated | Source and output hashes, the per-turn Grid hash, and the result of every build check. |
| `MODULES.md` | Written | Lens selection, every edit by module, the assembly rules and the build checks. |
| `HARNESS_REQUIREMENTS.md` | Written | What the R11 harness must provide, the safety-critical requirements, and the decisions for the owner. |
| `tools/build_mental_health_set.py` | Written | The build. |
| `tools/package_zip.py` | Written | Packages the folder as a reproducible zip and writes `SHA256SUMS.txt`. |
| `VERSION` | Written | Build identity and status. |
| `SHA256SUMS.txt` | Packaging | SHA-256 of every other file, written by `tools/package_zip.py`. |

Generated files are overwritten on every build. To change content, edit the build script and rebuild; edits made in `modules/` or `INSTRUCTION_SET.md` are lost and never reach the core.

## Rebuild

```
python3 -I -B tools/build_mental_health_set.py \
  --source <path to Dr_Seraphina_Aris_Health_Assistant_V1_R11> \
  --out .
```

The build computes and checks everything in memory. If any check fails, it exits non-zero and writes nothing. Two mechanisms catch changes in the R11 source:

- an edit stops the build if its exact text no longer matches;
- the spans removed by the pinned edits listed in `MODULES.md`, including the 34 dropped lenses, are pinned by SHA-256, so a change inside one stops the build.

The build also proves that its assembler matches R11's: run on the unedited R11 modules, it must reproduce the R11 core byte for byte. Rebuilding removes stale files in `modules/` and `deployment/`, and leaves the written files alone.

## Package

```
python3 -I -B tools/package_zip.py --src . \
  --zip <output.zip> --root Dr_Seraphina_Aris_Mental_Health_Set_V1_R11-MH_draft1
```

This writes `SHA256SUMS.txt`, then a zip with one root folder, fixed timestamps and permissions, and no caches or git files. The same inputs give the same zip bytes. After extracting, run `sha256sum -c SHA256SUMS.txt` inside the root folder.

## Scope decisions

- **Lenses kept:** 01 Doctor, 02 Psychiatry, 03 Psychology, 04 Pharmacist, 09 ADHD, 10 Autism.
- **Lenses dropped:** the other 34, including nursing, occupational therapy, physiotherapy and dietetics. These can be added back (`HARNESS_REQUIREMENTS.md` section 10.7).
- **First Aid:** kept with one wording edit and the visual-explanation paragraph removed. The 999, suicidal-threat, Samaritans, harmful-ingestion and physical first-aid content is unchanged.
- **Removed:** media production, physio assets, clinical source images, and the illustration and video sections.
- **Not changed:** the lens bodies, the shared engine apart from the perspective and specialist tables and one sentence (see `MODULES.md`), and the record templates.
- **Out of scope:** the R11 test battery.

## Before any use

Read sections 8 and 10 of `HARNESS_REQUIREMENTS.md`. The most important points:

- the harness has no output safety filter, and the model's name suggests its refusal behaviour may have been removed;
- the R11 person registry uses name-and-date-of-birth codes, which must be re-keyed before configuring;
- the bridge (at runtime), `configure.py` and `preflight.py` all need a load manifest for this set;
- the clinical content still needs clinical review.
