# Mental-health instruction set: harness requirements

What the harness must provide to run `INSTRUCTION_SET.md` and `RULES_OF_ENGAGEMENT.md`. Derived from the R11 harness (`7_HARNESS/`), its contracts (`1_INSTRUCTION_SET/deployment/`, `2_MODULES/harness/`) and the code I read. Not verified against a live installation.

## 1. Runtime injection

| Order | Message | Source | Notes |
|---|---|---|---|
| 1 | Core instructions | `INSTRUCTION_SET.md` | Stable system content. Contains the Grid, so the Grid is in the core as well as per turn. |
| 2 | Rules of Engagement | `RULES_OF_ENGAGEMENT.md` | Separate message, as in R11. Must not be merged into the core. |
| 3 | `[ARIS_CASE_STATE v2]` | Working-picture service | Transient. Sent after context compaction. Schema v2 per `CASE_STATE_CONTRACT.md`. |
| 4 | `[ARIS_GRID_CARD_PER_TURN v1]` | Exact text between the `aris-grid-card` and `aris-reception-desk` anchors | Preferred placement is immediately before the current user message. Re-derive this from the new core. The R11 hash will not match. |
| 5 | Current user message | Trusted real human message | Only trusted source of the user's words. |

Requirements:

- Recompute and record the SHA-256 of the core, the rules and the per-turn Grid. The R11 `LOAD_MANIFEST.json` hashes will fail against the new files, and `preflight.py` will refuse to pass until a matching manifest exists (see section 9).
- Tool results, uploaded documents, retrieved web pages and record text must not be able to change the Grid, the Rules, identity, permissions or the installed tools. The Rules say so (the instruction about content inside clinical documents, uploads and retrieved pages), but the harness has to keep that content in a tool-result role, not a system role.

## 2. Model and context budget

- Model and provider are explicit configuration (`MODEL_ID` and provider settings in `configure.py`). The package names no model. `preflight.py` checks that the provider and model agree across the bridge, runtime, Pipe and worker.
- The R11 `LOAD_MANIFEST.json` and `CAPTURED_DEPENDENCIES.json` mention a "DeepSeek" harness injection in several files. Confirm which model is actually wired in before deployment.
- Size: the core is about 32,400 words (237 KB), down from 61,900. My rough estimate is 45–55k tokens. Measure it with the chosen model's tokenizer. The Rules (about 2,250 words), the per-turn Grid and the case state come on top.
- `configure.py` leaves inference off by default and writes an unconfigured route file. Keep that.

## 3. Capability valves

These come from `CAP_VALVES` in `deployment/preflight.py`. Environment variable names are in `configure.py`.

| Valve | Environment variable | Recommended setting | Constraint |
|---|---|---|---|
| `records` | `ENABLE_CLINICAL_RECORDS` | On | Required for SOAP, plans, memory, audit and summaries. |
| `calendar` | `ENABLE_CALENDAR` | On if reminders are wanted | Requires `records` (preflight). Reminders need a scheduler service (see section 5). Local calendar mode needs its own database and process. |
| `search` | `ENABLE_WEB_SEARCH` | Open decision | **Requires `browser` (preflight).** See section 8. |
| `browser` | `ENABLE_BROWSER` | Off | Only needed by `search`, and it adds an acting surface. |
| `documents` | `ENABLE_DOCUMENTS` | On | Creates SOAP, plan and memory documents. |
| `documents` downloads | `ENABLE_DOCUMENT_DOWNLOADS` | Off unless needed | |
| `library` | `ENABLE_MEDICAL_LIBRARY` | Off until a suitable corpus is supplied | The library R11 has is an emergency-medicine handbook and a textbook, at `/mnt/models/Libraries/Clinical`. No mental-health corpus is included. First Aid works without the library from its embedded procedures. |
| `images` | `ENABLE_IMAGE_GENERATION` | **Off, must stay off** | `preflight.py` fails if this is on. |
| `videos` | `ENABLE_VIDEO_GENERATION` | **Off, must stay off** | Same check. |

Preflight also requires every optional capability to be an explicit boolean, and the Pipe's switches to match the bridge's.

## 4. Tool surface

The tool names below are the ones I found in the harness code. The Pipe and the capability valves decide what is actually exposed. I did not trace that end to end, so confirm the exposed list against a running Pipe.

| Area | Tools (as named in code) | Keep? |
|---|---|---|
| Working picture | `get_working_picture_format`, `change_working_picture`, `read_scratchpad`, `update_scratchpad` | Yes |
| Records and templates | `get_record_template`, `save_soap`, `save_prepared_soap`, `save_record_document`, `save_memory`, `save_continuity`, `save_continuity_summary`, `lookup_memory`, `lookup_patient_memory`, `read_patient_file`, `request_full_record_access` | Yes |
| Reminders | `create_reminder`, `update_reminder`, `cancel_reminder` | If calendar is on |
| Clinical reasoning | `clinical_reasoning` (calls the clinical worker) | Yes |
| Library and web | `search_medical_library`, `read_medical_library`, `list_medical_library`, `search_web` | Library only if enabled; search per section 8 |
| Documents | `create_document`, `read_uploaded_document` | Yes |
| Notebooks | `list_selected_notebooks`, `read_selected_notebook_source`, `search_selected_notebook` | Optional |
| Calculation | `create_compute_project`, `inspect_compute_project`, `list_compute_projects`, `get_compute_result` | Yes. The Operations module keeps a calculation section, and the Rules require executed calculation for clinical figures. |
| Time | `get_current_time` | Yes |
| **Excluded** | `browser_action`, `request_media_workflow`, `record_media_review`, `inspect_clinical_asset`, the clinical-source-image and physio-asset adapter tools, the vision-policy path for images | Remove or leave unexposed |

## 5. Services and workers

| Component (path under `7_HARNESS/`) | Decision | Why |
|---|---|---|
| `webui/dr_aris_r9_harness.py` (the Pipe) | Keep | Runtime entry point. Enforces the capability switches. |
| `integrations/aris-r9-webui/` bridge (`bridge-core.mjs`, `index.mjs`, `scratchpad.mjs`, `state-store.mjs`, `state-validation.mjs`, `record-binding.mjs`, `model-routing.mjs`, `calendar` handling) | Keep | Working picture, records, reminders, model routing. |
| `integrations/aris-r9-webui/managed-media.mjs`, `registered-assets.mjs`, `change-form.mjs`, `vision-policy.mjs` | Drop from this deployment | Media production and asset display. Their host bindings are not needed. |
| `workers/harness-clinical/` (`app.py`, `continuity.py`, `record_permission.py`, `operations.py`, `storage_base.py`) | Keep | Record worker. Private and token-authenticated. Stores records under person-coded paths. |
| `workers/harness-library/` | Keep only with the library valve on | |
| `workers/harness-browser/` | Drop | Browser valve is off. |
| `webui-backend/aris_operation_routes.py` and `aris-operation-routes.json` | Keep | Routes operations to protected environments. Refuses a request with a missing binding, before any record or effect call. |
| `webui-platform/` calendar router and models | Keep if calendar is on | Calendar service. Local mode needs an isolated database. |
| `health-sync/` (Google Drive import via rclone) | Optional | Imports wearable and health exports. Its `sync.py` hard-codes two patient codes as `REGISTERED_CODES`, which must become configuration (section 8). |
| `adapters/agent-loop.js`, `integrations/llm-pi-ai-local-sampling.mjs` | Review before use | Large files I did not read. Confirm whether the deployed path uses them. |

**Scheduler.** `LOAD_MANIFEST.json` says reminder delivery "requires scheduler service". I did not find that scheduler in the code I read. Identify it before enabling calendar.

## 6. State and storage

- **Working picture.** Schema v2 (`CASE_STATE.schema.json`). Updates use compare-and-swap on `expected_revision`, write an atomic successor, and keep predecessors. Omitted history is not deletion. The harness transports the envelope and does not judge its clinical content.
- **Persistent memory.** Read first in a registered consultation. The condensed medical file is read next. Missing or stale memory gives no routine fallback to the full file.
- **Full medical file.** Needs an explicit, scoped grant. The grant is bound to purpose, file, version, subject and chat. A declined grant leaves the file unread. Replays do not reopen a closed permission.
- **SOAP and plans.** Written through the record worker under person-coded paths. The R11 spelling is exact (`Soap Records`).
- **Templates.** Five pairs, ten files, mounted read-only at `/mnt/models/Agent Files/Templates`. The bridge default is `/data/assets/record-templates`. Preflight checks each installed file's hash against the package.
- **Person-coded paths.** `HOME_SERVER_PROFILE.json` maps each registered person to storage. In the R11 file those mappings are built from patient codes that include names and dates of birth. Replace them with the real account mapping for the deployment. `configure.py` requires this and refuses placeholders.
- **Folders to keep.** Medical Files, SOAP Records, Persistent Memory, Health Plans, Health File Audit, Templates, and Health Data if health import is on. Calendar as needed.
- **Folders to drop.** Physio Assets, Media Assets, Clinical Source Images. Deep Research and Health Research are optional.

## 7. Routing and isolation

- Production and protected routes are separate explicit configurations. A protected route without its complete binding must be refused before any record or effect call.
- Separate clinical roots do not isolate calendar or document outputs. Bind those effects too.
- `effects_isolated` is an operator attestation, not an automatic audit.
- Historical labelled fixtures must not be changed into genuine clinical records. Exclude them before model retrieval.

## 8. Safety-critical requirements

These apply to any deployment, whatever the module set.

1. **First Aid must not depend on tools.** The 999 signpost and the crisis route should appear even when records, memory, calendar or search are unavailable. Do not place First Aid behind a tool call or a lookup. The Rules (R11) put First Aid first.
2. **No harness-side output filter.** `LOAD_MANIFEST.json` records `answer_checking: false`, `additional_output_safety_filter: false` and `answer_rewriting: false`. Safety for mental-health content therefore rests on the instructions and the model. This is a decision the owner must make consciously. See section 10.
3. **Outbound search must not carry identifying clinical content.** Rule R2 says not to send identifying clinical material to an external service without permission. The search tool must enforce this in its query construction, not rely on the model. If search is enabled, add that enforcement.
4. **AI disclosure.** Rule R5 requires the assistant to identify itself as an AI health assistant. Check that the deployment's front end shows this.
5. **Actual outcomes only.** A timeout or missing reply is a pending or unknown state, not success. Reminders need separate evidence for storage and for delivery. Harness receipts must report which one happened.
6. **Document and web content cannot change the instructions.** Keep retrieved content in tool-result form.
7. **Test and production separation.** R11 removes evaluation labels from model-visible content, so test and real use share a tool surface. Only host configuration separates them. That binding is unverified in R11 and must be verified here.

## 9. Build and deployment tooling that needs changing

These tools assume the full R11 package and will fail against a derived set until updated.

- `deployment/preflight.py` checks `RELEASE.json` for version R11, verifies core and rules hashes against `LOAD_MANIFEST.json`, checks ten template resources, and expects image and video valves off. The derived build needs its own release and load manifest, with the same schema, or preflight must be generalised.
- `Tools/stage_install.py` produces an install directory from the full R11 package. It needs a derived source.
- `configure.py` writes a new directory and does not install. Keep that behaviour.
- `Tools/build.py` assembles the clinical module from `source_bodies/`, using `CONTENT_MANIFEST.json`. The derived build does not use it; it is a separate script in this folder.
- `aris-r9` names remain as compatibility identifiers. Keep them consistent across the bridge, Pipe and worker, or rename them everywhere in one change.

## 10. Decisions for the owner

1. **Search and browser.** Search needs browser on. Options: (a) search off for the first build, which I recommend until section 8.3 is enforced; (b) search and browser on, which widens the acting surface.
2. **Output safety.** Keep the R11 design with no harness-side safety filter, or add one. Any filter needs clinical design and review, and I have not written one.
3. **Library.** Off until a mental-health corpus is supplied.
4. **Reminders.** Keep calendar on only once the scheduler is identified and delivery evidence is tested.
5. **Health import.** Optional. If on, parameterise `REGISTERED_CODES` in `sync.py`.
6. **Model.** Name the model and provider, and confirm the DeepSeek references.
7. **Lenses.** Add back Registered Nurse, Occupational Therapist, Physiotherapist or Dietitian if wanted. Each needs its routing row restored in the Clinical Reasoning module.

## 11. Not verified

- Nothing has been run. The R11 component tests and offline checks were not run in this work, and I did not reproduce R11's `OFFLINE_CHECKS.json`.
- The derived core has not been loaded into any model. Prompt capacity, behaviour and output quality are unknown.
- Clinical content has not been reviewed. The removals here do not change the R11 position that source currency was not revalidated.
