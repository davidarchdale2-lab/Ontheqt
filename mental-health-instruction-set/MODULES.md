# Mental-health instruction set: module manifest

Derived from `Dr_Seraphina_Aris_Health_Assistant_V1_R11` (content revision 1). Built by `tools/build_mental_health_set.py`. Status: draft, not clinically reviewed, not installed.

## Lens selection

| Lens | Status | Reason |
|---|---|---|
| 02 Psychiatry | Kept | Core mental-health specialty |
| 03 Psychology | Kept | Core mental-health specialty |
| 09 ADHD | Kept | Neurodevelopmental, named in the engine as a selectable lens |
| 10 Autism | Kept | Neurodevelopmental, named in the engine as a selectable lens |
| 01 Doctor | Kept | Medical causes of mental-health symptoms; the engine routes physical-illness questions here |
| 04 Pharmacist | Kept | Psychotropic regimens, interactions, adherence, withdrawal |
| 05–08, 11–40 | Dropped (34 lenses) | Physical and allied-health specialties. Includes Registered Nurse, Occupational Therapist, Physiotherapist and Dietitian, which are candidates to add back |

Lens bodies are copied verbatim from the R11 source. Nothing in the kept lenses refers to a dropped lens.

## Modules

| Module | Status | What changed |
|---|---|---|
| Grid Card | Kept, edited | Removed "media" from the operations edge label and the media-production bullet. Removed the "Media return connection" section. Lens count changed from 40 to six, with names listed. |
| Reception Desk | Kept, edited | Removed the "personal media production" clause from the Educational option. |
| Scratchpad Investigatory Tool | Kept, edited | "media delivery" changed to "document delivery" in the routing sentence. Otherwise unchanged. |
| Clinical Reasoning Tool | Kept, rebuilt | Shared engine kept, including care navigation and the mental-health and neurodevelopmental distinctions. Lens index and the lens count in the purpose text now list the six kept lenses. Removed the "Illustrations and videos accompanying advice" section. Removed the Dietitian, Physiotherapist, Occupational therapist and Registered nurse rows from the perspective table. Replaced the specialist-contribution table with one routing sentence: acute deterioration goes to First Aid, and other physical conditions are referred. Evidence section kept unchanged. |
| First Aid Tool | Kept, one paragraph removed | Removed the paragraph that routed visual explanations after First Aid. Everything else is unchanged, including the 999 signpost, the suicidal-threat section and the Samaritans signpost, and the physical first-aid procedures. |
| Health Plan Tool | Kept, one paragraph removed | Removed the visual-explanation paragraph. |
| SOAP Creation Tool | Kept, one section removed | Removed "Recording accompanying media". |
| Operations Tool | Kept, trimmed | Removed the Media row from the connections table. Removed the "Prepared clinical source images" and "Premade physiotherapy assets and personal packs" subsections. Replaced "Deliverables and media" with "Deliverables", which keeps text, record and document production and drops the five production workflows, the managed handover, and the save and register section. |
| Rules of Engagement | Kept as a separate file, one paragraph replaced | The media paragraph now states that no image, video, presentation or media-production route exists in this set. |

## Output

| File | Contents |
|---|---|
| `INSTRUCTION_SET.md` | Core, assembled in R11 order: Grid, Reception, Scratchpad, Clinical Reasoning (with six lenses), First Aid, Health Plan, SOAP, Operations. About 32,400 words, down from 61,900. |
| `RULES_OF_ENGAGEMENT.md` | Separate file, loaded as its own system message, as in R11. |
| `modules/*.md` | The same modules as separate files, with their relative links intact. |
| `BUILD_CHECKS.json` | Structural checks and SHA-256 of the core and rules files. |

## What the build checks, and what it does not

Checks: exactly six lens anchors; every in-page link resolves; Grid click targets exist; Rules kept separate; no dropped lens, dropped service or media-production term remains.

The forbidden-term check reports five generic uses it cannot tell apart from a dropped reference, and each was read and accepted: "illustrates" and "illustrated" in the SOAP and Evidence sections (a source-page illustration is reference material), "video" as a type of evidence in the assessment-method paragraph, "leaflet" in the Pharmacist lens (a product leaflet as a medicines source), and "cropping" in the Evidence section's image-appraisal rule.

Not checked: whether any clinical statement is correct, current or complete. The R11 source states that its clinical source currency has not been revalidated, and the removals here do not change that.
