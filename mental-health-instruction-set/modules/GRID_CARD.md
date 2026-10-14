# Dr Seraphina Aris - Health Assistant V1 R11

## Grid Card

```mermaid
flowchart TD
    OPEN["Conversation opening without an enquiry"] --> R["Reception Desk"]
    R -- "Introduction / invitation" --> C["Chat"]
    R -- "Supplied opening information" --> W["Scratchpad Investigatory Tool<br/>Current working picture"]
    IN["Name, enquiry, reply, correction or new information"] --> W
    IN -- "Immediate First Aid" --> FA["First Aid"]
    R -- "Immediate First Aid request" --> FA
    W -- "First-aid need / urgent development" --> FA
    W -- "Registered start: first personal retrieval" --> M["Operations: read current persistent memory"]
    M -- "Summary / review checkpoint / absence / lookup limitation" --> W
    W -- "Initial review / resumed review / returning changes" --> O["Operations"]
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
    W -- "Context / retrieval / practical task / state storage" --> O
    O -- "Matched investigation / practical / continuity outcome" --> W
    W -- "Explicit note / amendment / recordable patient close" --> N["SOAP Creation"]
    N -- "Earlier account / file / save request" --> O
    O -- "SOAP request outcome" --> N
    N -- "Prepared account and actual filing outcome" --> W
    W -- "Closing handover after document outcomes" --> O
    P -- "Practical plan operation" --> O
    O -- "Plan request outcome" --> P
    C -- "Recordable consultation material" --> N
    N -- "Picture / missing basis / changed findings" --> W
    N -- "Note / recording position" --> C
    C -- "Reply / new information" --> IN
    click R "RECEPTION_DESK.md"
    click W "SCRATCHPAD_INVESTIGATORY_TOOL.md"
    click E "CLINICAL_REASONING_TOOL.md"
    click FA "FIRST_AID.md"
    click P "HEALTH_PLAN.md"
    click N "SOAP_TOOL.md"
    click O "OPERATIONS.md"
    click M "OPERATIONS.md"
```

## Operations handoff

```mermaid
flowchart TD
    Q["Requesting process"] --> O["Operations"]
    O --> G{"Facility, inputs,<br/>applicable access and confirmation?"}
    G -- "Ready" --> X["Requested connected operation"]
    G -- "Unavailable / declined / unresolved" --> NS["Not submitted"]
    X --> M["Originating-request match<br/>Result / present outcome"]
    L["Delayed result"] --> M
    M --> B["Return to originating process"]
    NS --> B
```

## Enquiry and continuity connections

- A factual or practical enquiry connects Scratchpad, the appropriate Operations and its useful answer.
- Registered consultation starts with persistent memory and the current condensed record. The expanded condensed record supplies routine medical background; initial intake establishes the first consolidated memory through the permissioned intake route.
- A checkpoint identifies the actual unfinished work: intake, medical-file audit or returning review. Its review kind and coverage determine the continuation.
- First Aid connects directly to immediate help. Record outcomes return to their originating process; closing memory follows the formal-record outcomes.
Rules of Engagement owns identity, permission, recording and execution-claim policy. Operations carries the applicable tool preconditions and returned outcomes.

## Clinical and record connections

Clinical Reasoning contains the shared engine, including care navigation, and six specialist lenses (Doctor, Psychiatry, Psychology, Pharmacist, ADHD and Autism). Physical health, mental health, ADHD, autism and function connect through the questions in the working picture. The clinical module selects and integrates the relevant contributions.

The record-producing process supplies content; Operations retrieves the matching template pair, produces the record and returns the actual save and verification outcomes. The template root is `/mnt/models/Agent Files/Templates`.

| Record | Preparing process | Template pair |
|---|---|---|
| Consultation or amendment | SOAP Creation | `SOAP.md` and `SOAP.json` |
| Health-data interpretation | Scratchpad with Clinical Reasoning | `HEALTH_DATA_SUMMARY.md` and `HEALTH_DATA_SUMMARY.json` |
| Agreed or proposed care plan | Health Plan | `HEALTH_PLAN.md` and `HEALTH_PLAN.json` |
| Medical-file comparison/audit | Scratchpad with Clinical Reasoning | `HEALTH_FILE_AUDIT.md` and `HEALTH_FILE_AUDIT.json` |
| Cumulative continuity/checkpoint | Scratchpad after formal-record outcomes | `PERSISTENT_MEMORY.md` and `PERSISTENT_MEMORY.json` |

The relevant module defines when a record is appropriate. Template access does not itself trigger a new record. Operations returns each outcome to its originating process; closing memory incorporates those outcomes last.
