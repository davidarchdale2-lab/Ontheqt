# Mental-health instruction set: harness requirements

What the R11 harness must provide to run this set. It is derived from the R11 harness code and contracts (`7_HARNESS/`, `1_INSTRUCTION_SET/deployment/`, `2_MODULES/harness/`). Paths below are relative to the R11 package root. Nothing here has been run against a live installation.

## 1. Runtime injection

The R11 bridge (`7_HARNESS/integrations/aris-r9-webui/runtime-files.mjs`) puts two hash-checked sections into the system prompt. The bridge also adds its own tool and service guidance sections (orders in the 200s), which are not hash-checked.

| Order | Section | Source | Notes |
|---|---|---|---|
| -499 | `aris:rules-of-engagement` | `RULES_OF_ENGAGEMENT.md` | Loaded and hash-checked separately; never merged into the core text. |
| 100 | `aris:released-core` | `INSTRUCTION_SET.md` | Includes the Grid. |

Three transient envelopes are delivered each turn (`request-projection.mjs`), in this order:

| Envelope | Source | Notes |
|---|---|---|
| `[ARIS_SOURCE_RECEIPTS v1]` | Bridge | Receipts of sources read in the session, when there are any. |
| `[ARIS_CASE_STATE v2]` | Working-picture service | After compaction. Schema v2 (`2_MODULES/harness/CASE_STATE_CONTRACT.md`). |
| `[ARIS_GRID_CARD_PER_TURN v1]` | Per-turn Grid | Exactly one delivery per turn, in addition to the Grid in the core. |

The per-turn Grid is the core text from `<a id="aris-grid-card"></a>` (inclusive) up to `<a id="aris-reception-desk"></a>` (exclusive), with outer whitespace trimmed. This rule reproduces R11's recorded hash. Its SHA-256 for this set is in `BUILD_CHECKS.json` under `per_turn_grid`; the bridge checks it at runtime against the load manifest (section 9). The R11 hash no longer applies.

Placement depends on the model route:

- **Native late placement.** The envelopes are separate system messages immediately before the current human message. This is implemented only for provider `aris-exl3` with model `Qwen3.8-27B-Heretic-ARA-exl3-6bpw-h16`, and `configure.py` refuses it for anything else.
- **Any other provider** needs `--grid-placement system-prompt-tail` and a recorded `--fallback-reason`. The envelopes are then appended to the end of the leading system prompt.

Tool results, uploaded documents, retrieved pages and record text must stay in tool-result form. The Rules say such content cannot change the Grid, the Rules, identity, permissions or tools, but only the harness can keep it out of the system role.

## 2. Model

- **Model.** R11 is wired for `Qwen3.8-27B-Heretic-ARA-exl3-6bpw-h16` on provider `aris-exl3`. This is the Pipe's `MODEL_ID` default, and `configure.py`, `preflight.py` and `integrations/native-system-messages.mjs` require it for native Grid placement. Preflight requires the provider and model to agree across bridge, runtime, Pipe and worker.
- **"DeepSeek".** The name refers to the harness host and framework (`BRIDGE_URL` `http://deepseek-harness:3080/...`; `@deepseek-ai` packages in `CAPTURED_DEPENDENCIES.json`), not the model.
- **"Heretic".** The model name matches the naming used for open models with their refusal behaviour removed. Confirm what this model is with whoever built it. If it is a refusal-removed variant, this set has no refusal layer from the model *and* none from the harness (section 8.2). For a mental-health assistant, that combination needs a deliberate decision.
- **Size.** The core is 29,805 words (217 KB), the Rules 2,217 words and the per-turn Grid 726 words. A rough estimate is 45–55k tokens for the core alone. R11's own preflight requires measuring with the real tokenizer, chat template and context limit, with no silent truncation.
- **Inference.** `configure.py` leaves inference off by default.

## 3. Capabilities

`configure.py` accepts exactly these boolean capabilities: `search`, `records`, `library`, `documents`, `browser`, `images`, `videos`, `notebooks`, `calendar`. It writes all nine to the bridge configuration, and the Pipe settings shown below. `preflight.py` compares eight Pipe switches with the bridge; `ENABLE_DOCUMENTS` and notebooks are not compared.

| Capability | Pipe setting(s) | Recommended | Constraints and notes |
|---|---|---|---|
| `records` | `ENABLE_CLINICAL_RECORDS` | On | Needs `CLINICAL_WORKER_TOKEN`. Required for SOAP, plans, audits, memory and summaries. |
| `calendar` | `ENABLE_CALENDAR` | Off until commissioned | `configure.py` refuses calendar without `records`. The Pipe also requires `/app/backend/data/aris_tools/aris_calendar.py`. No scheduler implementation is packaged (section 5). |
| `search` | `ENABLE_WEB_SEARCH` | Off for the first build | `configure.py` refuses search without `browser`. See section 8.3. |
| `browser` | `ENABLE_BROWSER` | Off | Needs `BROWSER_WORKER_TOKEN`. Can navigate, enter text and activate controls. |
| `documents` | `ENABLE_DOCUMENT_DOWNLOADS` and `ENABLE_DOCUMENTS` | On | Both are set from this one capability. Downloads enable `create_document` (txt, md, pdf, docx, xlsx, pptx; uploaded images can be embedded). `ENABLE_DOCUMENTS` also enables OCR of attachments through `DOCUMENT_WORKER_URL` (default `http://harness-documents:8090`, not packaged), which needs `DOCUMENT_WORKER_TOKEN`. |
| `library` | `ENABLE_MEDICAL_LIBRARY` | Off unless a suitable corpus is supplied | Needs `LIBRARY_WORKER_TOKEN`; admin users only. R11 references several Oxford clinical handbooks and textbooks (`LIBRARY_REFERENCE_REGISTRY.json` and First Aid's reference list), and the package does not establish what is actually held. None of them is a mental-health corpus. |
| `notebooks` | `NOTEBOOK_IDS` | Off (empty) | Admin users only. `configure.py` always writes `NOTEBOOK_IDS` and the bridge `notebookIds` empty; to use notebooks, fill both by hand. Preflight leaves this as a manual check. |
| `images`, `videos` | `ENABLE_IMAGE_GENERATION`, `ENABLE_VIDEO_GENERATION` | **Off, must stay off** | `configure.py` refuses them and preflight fails on them. |

## 4. Tool surface

These names are registered in the bridge (mainly `clinical-readonly.mjs`, `scratchpad.mjs`, `module-controls.mjs` and `index.mjs`). The capabilities and bindings decide which ones are exposed. Confirm the exposed list with R11's authenticated `/inspect` before use.

| Area | Registered tools | Keep |
|---|---|---|
| Working picture | `get_working_picture_format`, `read_scratchpad`, `update_scratchpad`, `change_working_picture` | Yes |
| Identity and access | `lookup_registered_user`, `get_record_access` | Yes |
| Records | `lookup_patient_memory`, `list_patient_files`, `read_patient_file`, `request_full_record_access`, `finish_full_record_access` | Yes |
| Saving and recovery | `get_record_template`, `save_prepared_soap`, `soap_save_status`, `save_patient_memory`, `patient_memory_status`, `save_continuity_summary`, `continuity_summary_status`, `save_health_plan`, `save_health_file_audit`, `record_document_status` | Yes. The `*_status` tools recover an uncertain save by its original operation ID; they back requirement 8.5. |
| Calculation | `calculate`; local toolkit `create_compute_project`, `inspect_compute_project`, `list_compute_projects`, `get_compute_result`, `import_compute_file`, `download_compute_artifact` | Yes. The Rules require executed calculation for clinical figures. The last two move files into and out of a compute project. |
| Clinical module | `clinical_reasoning` | Yes, where available. A module handoff that raises the next step's reasoning effort to `xhigh`; it calls no worker. It is registered only for the Dr Aris profile on provider `aris-exl3` with a Qwen model. On a fallback provider neither this tool nor the medium/xhigh module policy exists. |
| Reminders | `create_reminder`, `reminder_status`, `update_reminder`, `cancel_reminder` | Only with calendar on |
| Documents | `create_document`, `read_uploaded_document` | Yes |
| Library | `search_medical_library`, `list_medical_library`, `read_medical_library` | Only with library on |
| Web | `search_web`, `browser_action` | Only if section 10.1 is decided that way |
| Notebooks | `list_selected_notebooks`, `search_selected_notebook`, `read_selected_notebook_source` | Optional |
| Time | `get_current_time` | Yes |
| **Media and assets** | `request_media_workflow`, `media_job_status`, `cancel_media_job`, `record_media_review`, `search_clinical_assets` and the other asset-adapter tools, `inspect_clinical_asset` | **Not exposed.** These register only when their bindings (`config.managedMedia`, `config.assets`) report `commissioned: true`. Leave those bindings unset. |

## 5. Components

Paths are under `7_HARNESS/`.

| Component | Decision | Notes |
|---|---|---|
| `webui/dr_aris_r9_harness.py` (the Pipe) | Keep | Enforces capability switches; loads `/app/backend/data/local_toolkit_v1.py`; enables calendar only if `aris_tools/aris_calendar.py` is installed. |
| `integrations/aris-r9-webui/` (the bridge) | Keep the whole directory | Includes `change-form.mjs`, the working-picture change form behind `change_working_picture`. |
| `integrations/aris-r9-webui/managed-media.mjs`, `registered-assets.mjs`, `integrations/vision-policy.mjs` | Keep installed, leave unbound | `index.mjs` imports all three statically, and calls `visionReady` on every request. Deleting them breaks the bridge. Leaving their bindings unset keeps the media and asset tools unregistered. |
| Shared `integrations/` files the bridge imports (for example `sampling-policy.mjs`, `tool-protocol/`, `local-toolkit/`) | Keep | Trace the full import graph from `aris-r9-webui/index.mjs` before removing anything else. |
| `workers/harness-clinical/` (`app.py`, `public_projection.py`, `continuity.py`, `record_permission.py`, `operations.py`, `storage_base.py`) | Keep | Private, token-authenticated record and calculation worker. |
| `workers/harness-library/` | Only with library on | |
| `workers/harness-browser/` | Only with browser on | |
| `webui-backend/aris_operation_routes.py` | Keep | Reads the host-private `aris-operation-routes.json`, which `configure.py` writes as `unconfigured`. Refuses an incomplete protected binding before any record or effect call. |
| `webui-backend/local_toolkit_v1.py`, `local_model_controls.py`, `aris_tools/aris_calendar.py` | Keep | Compute tools, model lease, and reminders (with calendar on). |
| `webui-platform/` calendar router and models | With calendar on | |
| OCR document worker (`harness-documents`) | External | Not in the package. Needed only for attachment OCR. |
| `health-sync/` | Optional | Imports wearable and health exports. `sync.py` (`REGISTERED_CODES`) and `health_processor.py` (`PEOPLE`) hard-code the two R11 patient codes (section 6). |
| `adapters/agent-loop.js`, `integrations/llm-pi-ai-local-sampling.mjs` | Not reviewed | Confirm whether the deployed path uses them. |

**Scheduler.** The reminder tools describe "the installed Open WebUI calendar scheduler", and the Pipe's calendar setting says to enable it only after the adapter and scheduler are commissioned. No scheduler implementation is packaged. Identify it before turning calendar on.

## 6. State, storage and identifiers

- **Working picture.** Schema v2. Updates are compare-and-swap on `expected_revision`, write an atomic successor and keep predecessors. The harness transports the envelope without judging its clinical content.
- **Memory first.** A registered consultation reads persistent memory, then the condensed medical file. Missing memory gives no routine fallback to the full file.
- **Full medical file.** Needs an explicit grant bound to purpose, file, version, subject and chat. A declined grant leaves the file unread, and a replay cannot reopen a closed grant.
- **Store mounts.** `preflight.py` requires all eight person stores, whatever the capabilities. `soaps`, `plans`, `audit` and `memory` are mounted read-write; `medical`, `health`, `research` and `calendar` read-only. Their R11 folder names are: Medical Files, Soap Records, Health Data, Health Plans, Health Research, Health File Audit, Persistent Memory Dr Aris, Agent Calendar.
- **Not used.** Physio Assets, Media Assets and Clinical Source Images.
- **Templates.** Copy the ten template files and their README to the host's `/mnt/models/Agent Files/Templates`, mounted read-only into the bridge at `/data/assets/record-templates`. Preflight checks their hashes only when run with `--templates <mount>`.
- **Identifiers.** The R11 person registry uses patient IDs built from a full name and a date of birth. Supplying an account map does not remove them. `configure.py` builds its registry from `HOME_SERVER_PROFILE.json` `patient_mappings`, accepts only account-map values that are existing `patient_id`s, rejects only account IDs containing `REDACTED` or `PLACEHOLDER`, and writes each person's `registered_full_name` into the files it generates.
- **Removing the identifiers.** Re-key each mapping before running `configure.py`: `patient_id`, `patient_code`, `registered_full_name`, `display_name` and every person-coded store path. Do this in both copies of `HOME_SERVER_PROFILE.json` (`1_INSTRUCTION_SET/deployment/` and `source_bodies/deployment/`). The same codes also appear in:
  - `1_INSTRUCTION_SET/deployment/MEDIA_WORKFLOWS.json`, `SERVER_FOLDER_ROUTES.txt` and `STORAGE_LAYOUT.md`
  - `7_HARNESS/health-sync/sync.py`, `health_processor.py` and `README.md`
  - `Tools/verify_package.py`
  - three test files under `3_TESTS/`

## 7. Routing and isolation

- Production and protected routes are separate explicit configurations. A protected route without its complete binding is refused before any record or effect call.
- Separate clinical roots do not isolate calendar or document outputs, so bind those effects to the same protected environment.
- `effects_isolated` is an operator attestation, not an automatic audit.
- On a bound route with a local calendar provider, the WebUI database must be isolated, or calendar is unavailable.
- Historical labelled fixtures must not be turned into genuine clinical records. Exclude them before model retrieval.

## 8. Safety-critical requirements

1. **First Aid must not depend on tools.** The 999 and crisis signposts must appear even when records, memory, calendar or search are unavailable. The Rules put First Aid first, so do not gate it behind any lookup.
2. **No harness-side safety filter.** R11 records `answer_checking: false`, `additional_output_safety_filter: false` and `answer_rewriting: false`. Mental-health safety therefore rests on these instructions and the model (see section 2 on the model name).
3. **No identifying clinical content in outbound search.** Rule R2 forbids sending identifying clinical material to an external service without permission. If search is enabled, enforce this where the query is built, not only in the instructions.
4. **AI disclosure.** Rule R5 requires the assistant to present as an AI health assistant. Check that the front end does too.
5. **Report actual outcomes.** A timeout is pending or unknown, not success. Use the `*_status` recovery tools before retrying a write. For reminders, saving and delivery are separate facts.
6. **Immediate-care procedures are dated.** `deployment/IMMEDIATE_CARE_REFERENCE_MANIFEST.json` gives the ICP-01 to ICP-05 source review as 2026-09-21, review due 2027-03-21, with no fresh guideline validation in R11. Re-review on or before that date.
7. **Medicines need a source.** Rule R13 requires checking doses, thresholds and intervals against an applicable source. With library and search both off, psychotropic medicine advice has no source facility except what the user uploads, and the model has to say so. Supply a suitable corpus (for example national formulary or mental-health guidance), or accept that limitation.
8. **Test and production separation.** R11 removed evaluation labels from model-visible content, so only host configuration separates test use from real use. Verify that binding on the real host.

## 9. Tooling that needs changing for a derived set

- **`configure.py`** checks the core and rules hashes against the package's `1_INSTRUCTION_SET/LOAD_MANIFEST.json` and stops with "Rebuild R11 load hashes first" on mismatch.
- **`preflight.py`** requires `RELEASE.json` version `R11` and the same hashes, checks ten template files, and expects images and videos off.
- **The bridge, at runtime.** `integrations/aris-r9-webui/scratchpad.mjs` reads `<pack>/1_INSTRUCTION_SET/LOAD_MANIFEST.json`, where `<pack>` is two directories above the configured core path. It refuses to start the working picture unless all of these match:
  - `core.sha256` and `harness_rules.sha256` match the runtime hashes;
  - `per_turn_grid.sha256` matches the Grid it extracts from the core;
  - `structured_case_state.schema_sha256` matches `<pack>/2_MODULES/harness/CASE_STATE.schema.json`.

  The bridge also loads the other case-state schemas and `CASE_STATE_INITIAL.json` from `<pack>/2_MODULES/harness/`. These are unchanged R11 files and are not in this package.
- **What the owner must do.** Stage this set in R11's layout:
  - `INSTRUCTION_SET.md` under `<pack>/1_INSTRUCTION_SET/`;
  - the Rules at the path the runtime configuration names;
  - R11's `2_MODULES/harness/` case-state files.

  Then write a load manifest and release record in R11's schema, using the hashes in `BUILD_CHECKS.json`. Generalising `configure.py` and `preflight.py` alone is not enough, because the bridge still fails closed. This package deliberately does not ship a manifest, because a ready-made one would read as deployable.
- **Build identity in saved records.** Rule R14 requires the actual build identity in persisted records, but the R11 build ID `ARIS-HA-V1-R11-2026-10-07` is hard-coded in three places:
  - `workers/harness-clinical/continuity.py` (`BUILD`, used by `operations.py` for `runtime_build`);
  - the request body of every Pipe call to the clinical worker (`webui/dr_aris_r9_harness.py`);
  - the bridge health endpoint (`integrations/aris-r9-webui/index.mjs`).

  Change them to this set's identity (see `VERSION`), or accept that saved records will name the R11 build.
- **Naming.** `aris-r9` names are compatibility identifiers. Keep them consistent across the bridge, Pipe and worker, or rename them everywhere at once.

## 10. Decisions for the owner

1. **Search and browser.** Leave both off for the first build, or turn both on and implement 8.3.
2. **Model and safety layer.** Confirm the model (section 2), and decide whether a harness-side safety check is wanted. Any such check needs clinical design and review; none is supplied here.
3. **Medicine sources.** Supply a corpus, or accept the limitation in 8.7.
4. **Reminders.** Turn calendar on only after the scheduler is identified and delivery evidence has been tested.
5. **Identifiers.** Re-key the person registry and the files listed in section 6 before configuring.
6. **Health import.** Optional. If used, parameterise `PEOPLE` and `REGISTERED_CODES`.
7. **Lenses.** To add a lens back, edit the build script and rebuild. In every case:
   - add the lens to `LENSES` and `LENS_SUMMARY`;
   - update the lens-index replacement and the two lens-count texts (Grid and Clinical Reasoning purpose);
   - take its terms out of `FORBIDDEN`;
   - update the `clinical:dropped-lenses` pin (`--print-pins` gives the new value).

   Then, depending on the lens:
   - **Lenses 05–08** (Registered Nurse, Occupational Therapist, Physiotherapist, Dietitian): remove that lens's `drop_line` row edit and its pin. For the nurse, also revert the `first-aid:nursing` and `clinical:nursing-sentence` edits.
   - **Lenses 11–40:** these came from the specialist-contribution table, which `clinical:specialist-table` replaces whole. Revise that edit so the relevant rows stay, and rewrite its replacement sentence, which says the set has no specialist lenses.

   Update `MODULES.md` to match.
8. **Build identity.** Change the hard-coded R11 build ID in the harness (section 9), or accept R11 provenance in saved records.

## 11. Not verified

- None of R11's component tests or offline checks were run for this set.
- The core has not been loaded into any model, so prompt capacity, behaviour and output quality are unknown.
- The clinical content has not been reviewed. R11's own position, that clinical source currency was not revalidated, still applies.
