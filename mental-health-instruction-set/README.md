# Mental-health instruction set (R11-MH, draft)

A mental-health-only derivative of the Dr Seraphina Aris Health Assistant V1 R11 instruction set. It keeps R11's routing and shared clinical engine, and drops the physical and allied-health lenses and all media production.

The build produces two variants:

- **Standalone (no harness).** `standalone/SYSTEM_PROMPT.md` is one system prompt for an ordinary chat application. Use this one if you are not running R11's harness. See `USING_WITHOUT_A_HARNESS.md`.
  - It is a mental-health assistant with five lenses.
  - **Crisis Support** replaces First Aid.
- **Harness.** `INSTRUCTION_SET.md` and `RULES_OF_ENGAGEMENT.md` are for R11's own harness, with records, memory and tools. See `HARNESS_REQUIREMENTS.md`.
  - It keeps six lenses and R11's First Aid.

**Status: draft.** Built and structurally checked. Not clinically reviewed and not tested with a model. Not for clinical use.

## Contents

| Path | Kind | What it is |
|---|---|---|
| `START_HERE.md` | Written | One-page orientation. |
| `standalone/SYSTEM_PROMPT.md` | Generated | Standalone variant: Rules, deployment facts, core, and the Grid repeated at the end. |
| `standalone_src/DEPLOYMENT_FACTS.md`, `standalone_src/CRISIS_SUPPORT.md`, `standalone_src/OPERATIONS.md` | Written | Hand-written standalone texts:<br>• the deployment facts: what this deployment lacks, its scope, and the safety rules for both;<br>• Crisis Support, which replaces First Aid;<br>• an Operations module that works only within the conversation. |
| `USING_WITHOUT_A_HARNESS.md` | Written | How to use the standalone variant, and its safety notes. |
| `INSTRUCTION_SET.md` | Generated | Harness variant: the core instructions. |
| `RULES_OF_ENGAGEMENT.md` | Generated | Harness variant: the Rules, loaded as a separately hashed section ahead of the core. |
| `modules/` | Generated | Harness variant modules as separate files, with their process maps. A read-only review copy. |
| `HARNESS_REQUIREMENTS.md` | Written | What R11's harness must provide for the harness variant. |
| `deployment/IMMEDIATE_CARE_REFERENCE_MANIFEST.json` | Copied | Harness variant: source and review dates for the First Aid immediate-care procedures. |
| `BUILD_CHECKS.json` | Generated | Source and output hashes, and the result of every build check for both variants. |
| `MODULES.md` | Written | Lens selection, every edit by module (both variants), the assembly rules and the build checks. |
| `tools/build_mental_health_set.py` | Written | The build. |
| `tools/package_zip.py` | Written | Packages a variant as a reproducible zip, with `SHA256SUMS.txt` inside. |
| `VERSION` | Written | Build identity and status. |

Generated files are overwritten on every build. To change content, edit the build script or `standalone_src/`, then rebuild. Edits made directly in generated files are lost.

## Rebuild

```
python3 -I -B tools/build_mental_health_set.py \
  --source <path to Dr_Seraphina_Aris_Health_Assistant_V1_R11> \
  --out .
```

The build computes and checks everything in memory. If any check fails, it exits non-zero and writes nothing. Two mechanisms catch changes in the R11 source:

- an edit stops the build if its exact text no longer matches;
- the spans removed by the pinned edits listed in `MODULES.md`, including the 34 dropped lenses, are pinned by SHA-256, so a change inside one stops the build.

The build also proves that its assembler matches R11's: run on the unedited R11 modules, it must reproduce the R11 core byte for byte. Rebuilding removes stale files in `modules/`, `deployment/` and `standalone/`, and leaves the written files alone.

## Package

```
python3 -I -B tools/package_zip.py --src . --profile standalone \
  --zip <output.zip> --root Dr_Seraphina_Aris_Mental_Health_Standalone_V1_R11-MH_draft2
```

Use `--profile harness` for the harness variant. The zip has one root folder, fixed timestamps and permissions, and no caches or git files, and the same inputs give the same zip bytes. After extracting, run `sha256sum -c SHA256SUMS.txt` inside the root folder.

## Scope decisions

- **Lenses kept:**
  - harness: 01 Doctor, 02 Psychiatry, 03 Psychology, 04 Pharmacist, 09 ADHD, 10 Autism;
  - standalone: the same without 01 Doctor.
- **Lenses dropped:** the other 34, including nursing, occupational therapy, physiotherapy and dietetics. They can be added back (`HARNESS_REQUIREMENTS.md` section 10.7).
- **First Aid (harness):** kept with one wording edit and the visual-explanation paragraph removed. The 999, suicidal-threat, Samaritans, harmful-ingestion and physical first-aid content is unchanged.
- **Crisis Support (standalone):** replaces First Aid. It covers:
  - suicidal crisis and self-harm;
  - possible overdose, intentional or by mistake;
  - missed or stopped medicines;
  - urgent mental-health routes.

  It gives no first-aid procedures, and signposts any other emergency to 999.
- **Standalone scope:** mental health, including ADHD and autism.
  - Physical health is considered only where it may cause, mimic or complicate a mental-health difficulty, or concerns a relevant medicine.
  - Other health questions are signposted to the GP, a pharmacist or NHS 111.
  - The Doctor lens's fatigue and sleep subsection moves into Psychiatry.
  - Library-only evidence text and physical-medicine examples are removed or replaced.
  - The assistant is named a mental-health assistant.
- **Removed:** media production, physio assets, clinical source images, and the illustration and video sections.
- **Not changed:** the shared engine, apart from the edits listed in `MODULES.md`. The kept lens bodies are unchanged in the harness variant. In the standalone variant:
  - Psychiatry gains the Doctor lens's fatigue subsection, with a GP route;
  - the Pharmacist lens has replaced examples and an added extra-dose and missed-medicine route (see `MODULES.md`, Mental-health-only pass).
- **Standalone additions:** written for this set, not from R11.
  - The deployment facts add:
    - rules for working without tools;
    - the scope rule and a UK services note;
    - overdose and missed-medicine routing;
    - UK safeguarding signposts.
  - Crisis Support is new text, apart from its suicidal-threat and poisoning guidance, which is adapted from R11's First Aid. It includes the guidance for people outside the UK.
  - The GP, NHS 111 and 999 routes that replace the Doctor lens are new text.
- **Out of scope:** the R11 test battery.

## Before any use

Read the safety notes in `USING_WITHOUT_A_HARNESS.md` (standalone) or sections 8 and 10 of `HARNESS_REQUIREMENTS.md` (harness). The most important points:

- there is no safety layer except the instructions;
- the model R11 was built for has a name suggesting its refusal behaviour was removed;
- the clinical content, and the safety texts added for this set, still need clinical review.
