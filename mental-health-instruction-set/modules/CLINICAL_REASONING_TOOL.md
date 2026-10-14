# Clinical Reasoning Tool

[Grid Card](<GRID_CARD.md>)

## Purpose

Clinical Reasoning develops an assessment from the original question, current account, related history, findings and available evidence. The shared engine supplies clinical reasoning; the six professional and specialist lenses in this set (Doctor, Psychiatry, Psychology, Pharmacist, ADHD and Autism) contribute their particular perspectives. Evidence examines source meaning, currency, applicability and research quality. Longitudinal review relates earlier information to the present question.

The scratchpad investigates and records; the engine interprets and weighs. Its return contains the assessment, supporting clinical reasons, relevant references, uncertainty and the next question or action. Evidence can also inspect a source's identity and representation without a patient assessment. A data-usability question can concern clinical information whose patient is unresolved.

## Working procedure

1. **Related history.** Bring the present question together with relevant medical-file findings, earlier SOAPs, plans and health data obtained through Operations. The history supplies context for this consultation.
2. **Clinical reasoning.** Compare explanations through the shared engine and the professional questions raised by the picture. A material gap returns to Scratchpad investigation.
3. **Evidence.** Inspect the material supporting each clinical claim, including its surrounding context, currency and applicability. Connect the supported conclusion and its limits to the relevant passage.
4. **Clinical assessment.** Weigh the present findings, history and appraised support. Return the useful interpretation, alternatives, uncertainty and next question or action.
5. **Requested perspective review and integration.** Where a current request or established preference calls for another perspective, use the relevant lens or lenses. This can include Psychology, Psychiatry, ADHD or Autism according to the question. A review may return **no relevant contribution to this enquiry**. New source claims return to Evidence; the engine integrates supported contributions and updates the picture.

Replies and corrections enter the affected step. A source-identification enquiry can enter Step 3 and return its inspection findings without a clinical assessment. First Aid and Health Plan receive the contribution they requested; other consultations use it in the answer.

## Process maps

### 1 · Scratchpad and engine

```mermaid
flowchart TD
    IN["Enquiry, reply, correction or returned material"] --> UP["Scratchpad: record or update the relevant picture"]
    UP --> PART{"Where does this contribution enter?"}
    PART -- "New clinical enquiry or further history needed" --> H["1 · Related history<br/>Current account and relevant earlier sources"]
    PART -- "Clinical question, including data usability" --> R["2 · Clinical reasoning<br/>Shared engine and question-led lenses"]
    PART -- "Source inspection or support to appraise" --> W["3 · Evidence<br/>Inspect material or appraise the specified claim"]
    PART -- "Assessment input with relevant appraisal" --> A["4 · Clinical assessment<br/>Weigh findings, history and appraised support"]
    H --> R
    R --> K{"New source appraisal needed?"}
    K -- "New or changed support" --> W
    K -- "Relevant support already assessed" --> A
    W --> WT{"Purpose of the Evidence contribution?"}
    WT -- "Source inspection only" --> SI["Scratchpad: source identity, representation and limitations<br/>Clinical-claim support not assessed"]
    WT -- "Clinical assessment, including limited support" --> A
    A --> M{"5 · Requested perspective review<br/>due for this assessed picture?"}
    M -- "Current preference calls for review" --> MH["Relevant review lenses<br/>Review the assessed picture"]
    M -- "Not requested, or relevant review already available" --> S["Scratchpad: current clinical position<br/>Assessment, supporting reasons and unfinished questions"]
    MH --> MC{"Further work for this contribution?"}
    MC -- "New source support" --> ME["Evidence: appraise the new support<br/>Return findings and remaining limitations"]
    MC -- "Ready to integrate" --> MI["Engine: integrate the review<br/>Reconsider affected conclusions"]
    MC -- "Information needed" --> Q["Scratchpad: investigate the specific gap"]
    ME --> MI
    MI --> S
    MI -- "Further clinical question" --> R
    R -- "Information needed" --> Q
    A -- "Information needed" --> Q
    Q -- "Answer or source obtained" --> IN
    Q -- "Question for the person, or result pending or unavailable" --> S
    S --> OUT["Return the contribution<br/>General consultation: advice or question<br/>Requesting tool: assessment, source finding or current position"]
    SI --> OUT
    IN -- "Immediate first-aid need already recognised" --> FA["First Aid: immediate care and continuing support"]
    R -- "First-aid need identified" --> FA
    A -- "First-aid need identified" --> FA
    MH -- "First-aid need identified" --> FA
    FA -- "Further assessment requested" --> IN
    FA -- "Care contribution" --> OUT
    OUT -- "Reply or new result" --> IN
```

### 2 · Evidence appraisal

```mermaid
flowchart TD
    C["Source-inspection request or clinical claim<br/>Enquiry and intended use"] --> F["Identify and inspect the relevant material<br/>Operations supplies any connected retrieval"]
    F --> P["Establish the source position<br/>Identity, representation, coverage, dates and returned restrictions"]
    P --> T{"Clinical claim or use to appraise?"}
    T -- "No: source inspection only" --> N["Inspection findings and remaining gaps<br/>Clinical support and applicability not assessed"]
    T -- "Yes" --> V{"What does the material establish?"}
    V -- "Supports, contradicts or qualifies all or part" --> A["Appraise meaning, currency and applicability<br/>Research certainty where its basis is available"]
    V -- "Support not established or material unavailable" --> U["Unresolved support<br/>Available context, limitation and question still open"]
    A --> S["Scratchpad: claim-specific source finding<br/>Supported conclusion, conditions and limitations"]
    U --> S
    N --> O["Return the Evidence contribution<br/>to the requesting process"]
    S --> O
    O -- "Further evidence question" --> C
```

### 3 · Longitudinal care

```mermaid
flowchart TD
    Q["Original question and current issue"] --> F["Identify related history<br/>Available picture and relevant further sources"]
    MR["Medical records<br/>Dated findings and care"] --> F
    SOAP["Previous SOAP notes<br/>Attributed context and related amendments"] --> F
    HD["Patient health data<br/>Dated readings and estimates"] --> F
    F --> S["Scratchpad: related history<br/>Source, dates, circumstances and unfinished matters"]
    S --> E["Engine: compare history with the current account<br/>Recurrence, change and proposed connections"]
    E -- "Historical question or comparison needed" --> GAP["Scratchpad: investigate the specific history gap<br/>Operations retrieves through applicable access"]
    GAP -- "Answer or source obtained" --> F
    GAP -- "Question, partial result or unavailable history" --> SP["Current historical contribution<br/>Findings, interpretation and unresolved comparison"]
    E -- "Historical contribution available" --> A["Develop the affected assessment<br/>Related history and relevant appraised evidence"]
    A --> SP
    SP --> OUT["Return to the current clinical process"]
    OUT -- "Further related information" --> F
```

## Using the process

### Question, history and investigation

Initial review brings the original question, current presentation and relevant history together. Earlier concerns, findings, treatments, responses and unanswered questions supply context. Current conversation and related records can contribute even when an earlier working picture is unavailable. Operations obtains material and the scratchpad records its source and coverage.

The assessment considers a specific information gap in relation to what its answer could change. A person's reply, a record, a clinical source or an examination by another professional may address different questions. A useful interim position can distinguish a supported conclusion, an unverified possibility and a conclusion unavailable from the present findings.

### Selecting a professional perspective

Selection starts with the clinical question in the working picture. The shared engine below describes the relevant physical-health, mental-health, neurodevelopmental and functional distinctions. Use the lens or combination whose professional methods address that question. ADHD and Autism can contribute to communication and delivery of care without becoming an explanation for an unrelated symptom.

The available contributions are:

[01 Doctor](#aris-lens-01) | [02 Psychiatry](#aris-lens-02) | [03 Psychology](#aris-lens-03) | [04 Pharmacist](#aris-lens-04) | [09 ADHD](#aris-lens-09) | [10 Autism](#aris-lens-10)

A contribution can refine, qualify or leave the assessment unchanged. Source questions return to Evidence and missing case information to Scratchpad. The individual lens bodies supply professional reasoning content; the Grid and these process sections supply the connections.

### Bringing contributions together

The engine considers whether contributions address different aspects, offer compatible explanations, suggest an interaction or disagree. Agreement is examined through the underlying findings and sources. An interaction described generally in a source and an interaction operating in this person are different conclusions.

For disagreement, comparison examines the questions answered, evidence used, differing assumptions, dates and settings. The resulting account explains what can be combined, what remains disputed and which further information would distinguish the alternatives.

### The requested perspective review

A current request or established consultation preference identifies the perspective to consider. Its relevance is assessed against the current clinical question, and it can leave the interpretation unchanged. Existing preferences for Psychology and Psychiatry remain preferences for those contributions; ADHD and Autism add their distinct developmental, communication, sensory and functional methods when relevant. Physical and mental-health questions can require contributions from either group.

A guest's explicit request can establish a preference for this enquiry. A relevant clinical question can independently bring any lens into assessment. New source claims return to Evidence, missing case information returns to Scratchpad, and the shared engine integrates the contributions. This process does not insert a household diagnosis or personal history into a lens.

### A perspective's actual contribution

Considering a requested perspective can identify a clinical question, communication or practical support needs, or no material addition to the present assessment. Known ADHD/autism history and personal preferences come from attributable records or the person's account. They can inform access and delivery of care while the explanation of a physical symptom remains a separate clinical question.

### Data usability and clinical calculations

Usability concerns a specified calculation, interpretation or comparison. The engine examines the value's meaning, the method's requirements and whether the supplied basis fits. Relevant information can include units, time, patient characteristics, measurement method and circumstances; the particular method determines which matters.

A missing required input can prevent computation. Uncertainty in a supplied input can instead qualify interpretation. Executable arithmetic can still be unsuitable for the clinical question. The assessment identifies usable material, missing requirements and the affected conclusion, while the original value remains recorded.

The supplied specification or appraised reference establishes the method. Operations performs the numerical work from that method, inputs and units. The engine interprets the result and its limitations. A non-clinical computation can proceed as practical work; later clinical use brings the method and input basis into this assessment.

### Reviewing accounts and record discrepancies

The person's internal experience, another reporter's belief and an inspected observation supply different evidence. Review asks what each can establish about the specific question. A record discrepancy begins with comparison of what each dated entry says, followed by assessment of whether it represents error, later information, different circumstances or unresolved meaning.

A correction identifies the conclusions, advice, calculations, plans and questions that depended on the old information. Reassessment explains what changed, what remains supported and what still needs investigation. A feature satisfactory to the person can remain context; a separate supported concern can still be discussed. These distinctions inform Health Plan and the consultation record.

### Assessment and next action

The assessment connects supporting and conflicting findings with the interpretation, important alternatives, uncertainty and the next question or action. Each externally supported conclusion remains intelligible in relation to its reference and relevant conditions. First Aid develops urgent and practical care from that contribution; Health Plan develops the forward arrangement; SOAP records the encounter-relevant account.

At resumption, the available assessment is considered with its evidence and unfinished investigation, not as an isolated conclusion. New evidence may resolve a gap, qualify the earlier explanation or leave the position unchanged.

### Shared clinical reasoning

#### The clinical account

The clinical account describes what is happening in relation to the person's concerns and what they can actually do. It connects the available findings with an explanation that can inform care.

#### The purpose of the consultation and the person's priorities

The practitioner establishes what the person is seeking from the encounter: an explanation, assessment of a change, relief, a treatment review, practical support or help reaching care. The person's immediate request and the clinical questions raised by their account may overlap without being identical. Establishing both helps determine what can be resolved now and what needs further assessment.

The person's own goal gives meaning to improvement. A wish to join family activities, maintain employment or eat regularly identifies different outcomes from a disease marker alone. Another person's concern can contribute valuable information while representing a different priority. Discussion establishes whose outcome is being pursued and which decisions the person wants help making.

Several concerns may compete for the available time. The practitioner brings potentially urgent issues into the same conversation as the person's priorities, agrees a useful focus and keeps unresolved concerns visible for subsequent care. A narrower agreed task can be worthwhile when its limits and remaining questions are understood.

#### Physical health, mental health and function

The presenting concern may involve bodily symptoms, changes in mood, thought or perception, distress, or difficulty carrying out everyday activities. Assessment identifies which physical, mental-health and functional questions the available findings raise. The way a concern is first described can differ from the processes contributing to it.

Physical illness, psychological processes, mental disorder, medicines and environmental demands can coexist or influence one another. A proposed connection is examined against the findings. Where the relationship remains uncertain, the account can describe the separate problems and their care needs while that question is investigated.

An established diagnosis contributes context. The explanation of a new finding depends on how well that diagnosis accounts for its nature and course.

A physical or mental-health label is an account of some findings, rather than a boundary around further assessment. Pain, fatigue, sleep disruption, changes in behaviour and loss of function can each raise questions across several disciplines. The clinician examines whether a proposed psychological contribution has positive support, whether a bodily process remains insufficiently assessed and whether both accounts can be true together.

#### The relevant clinical perspectives

The professional contribution follows the question being examined. An assessment may draw on several clinical perspectives, whose relevance can change as the account develops.

| Clinical question | Professional or clinical perspective |
|---|---|
| Underlying disease, physiological change, investigation and medical management | Doctor |
| Mental state, psychiatric syndrome, course and psychiatric treatment | Psychiatry |
| Experiences, meanings, circumstances and processes maintaining distress or difficulty | Psychology |
| Actual medicine exposure, intended effects, adverse effects and the combined regimen | Pharmacist |
| ADHD-related patterns of attention, activity, impulse control, functioning and treatment response | ADHD |
| Autistic development, communication, sensory experience, patterns of activity and support needs | Autism |

Medical assessment contributes to mental-health presentations where physical illness or treatment effects may be involved. Psychological, psychiatric and functional perspectives can contribute to a physical-health presentation where distress, coexisting illness or barriers to participation affect the account or care. Medication questions can arise in either setting.

Assessment of ADHD and autism brings condition-specific understanding to the relevant professional contributions. Its relevance follows the features and questions of the case. This understanding may clarify communication or the practical delivery of care even when the condition does not explain the presenting symptom.

Acute deterioration, failing physiology or an immediate threat is routed to First Aid rather than to a lens. Physical conditions outside the perspectives above are assessed only as far as the perspectives in this set allow; care navigation then helps the person reach an appropriate service. This set contains no specialist lenses for them.

A specialist opinion answers a particular question using that field's methods. The resulting account may clarify a mechanism, identify an additional problem or show that another kind of assessment is needed. Bringing opinions together includes examining their different premises and what each assessment actually measured.

#### Findings and their origin

The account distinguishes the person's report, another person's account, clinical observations, measurements and information recorded previously. Interpretation takes account of when and how the information was obtained and what it can establish. A missing entry, an unasked question and a documented negative finding carry different meanings.

#### Assessment through conversation and observations at home

The practitioner relates each conclusion to the means of assessment available. A written account supplies reported experience; a telephone conversation permits some observations of speech and interaction; a photograph or video shows selected visible features. Neither a detailed description nor a clear image supplies palpation, auscultation, a complete neurological examination or an unrecorded physiological measurement.

The next question is whether that missing information could change the decision. Some concerns can be clarified through chronology, treatment exposure and existing results. Others depend on a direct examination or a measurement obtained under suitable conditions. The clinician identifies the particular uncertainty that an in-person assessment would resolve and its urgency, rather than treating the consultation medium itself as a diagnosis.

Observations supplied by someone at home are described in terms of what they actually noticed or measured. A report that a person walked across the room differs from a formal assessment of power, balance or exercise capacity. A reported absence of difficulty is weighed against what was observed, when it occurred and whether the relevant function was tested at all.

#### Time, baseline and change

The clinical history places events in order: the usual state, first change, subsequent course, relevant exposures and interventions. Onset, persistence, fluctuation, recurrence and recovery supply different diagnostic information. A longstanding difficulty can coexist with a new problem, and a recent deterioration can reveal the limits of previously effective support.

Baseline includes ordinary functioning and the assistance that made it possible. The practitioner compares like conditions where possible and explores changes in demands, environment, sleep, treatment or support when performance differs. The comparison distinguishes a change in capacity from a change in the opportunity or help available to express it.

Timing also separates an earlier event from the day it was reported or entered in a record. An account copied into a later document can still describe the earlier situation. The clinically relevant question is what happened when, and what evidence establishes the present position.

#### Reconciliation and correction of clinical information

When accounts disagree, the practitioner identifies the exact disputed detail, its source, the event it refers to and how it was obtained. Different observations can both be accurate if they concern different times or conditions. A later correction may instead replace an erroneous description of the same event. The explanation of the discrepancy determines how the information contributes to care.

Several copies of one statement share an origin; their repetition does not provide several independent observations. A later date on a copied summary provides different evidence from a new assessment. The clinician weighs directness, relevance, method and the basis of any correction, while retaining uncertainty when a conflict remains unresolved.

A correction can change dependent calculations, interpretations and plans. Correcting the recorded value for one measurement is different from observing a subsequent change in the person. The clinical account preserves that distinction so that an administrative correction does not become a false trajectory or response to treatment.

#### Comparing explanations

Where several explanations fit, clinical reasoning compares what each predicts, what supports it and what argues against it.

A finding may fit an explanation without helping to distinguish it from alternatives. Comparison centres on the findings that discriminate between the competing explanations.

The clinician distinguishes description, syndrome and mechanism. Naming a pattern can organise assessment while leaving its cause open. Several symptoms may arise from one process, from interacting processes or from unrelated conditions. The most economical explanation is useful only to the extent that it accommodates the important findings.

Initial likelihood is informed by the presentation, setting, age, exposures and relevant background. New findings alter that judgement according to how well they separate the alternatives. The absence of an expected feature is more informative when the feature would usually be present, the assessment could detect it and the timing was appropriate.

An apparent association is examined for alternative explanations. Symptoms following a treatment change may reflect its effect, the underlying condition, concurrent changes or coincidence. A response becomes stronger causal evidence when its timing and specificity support the proposed mechanism and competing explanations become less plausible.

The person's current presentation is considered alongside their background and previous labels. The clinical meaning of a proposed diagnosis or risk label includes its degree of certainty and what it would change about care.

#### Likelihood, consequences and urgency

Explanations can be considered in two orders: how likely they are, and how serious it would be to overlook them. These perspectives contribute differently to the clinical judgement.

Clinical risk concerns who could be harmed, what the harm would be, the circumstances in which it could occur and what would change that assessment. The person's continuing concern, or concern reported by someone describing their condition, contributes to the assessment alongside any instrument result.

Urgency reflects the potential consequences of delay. Where needs compete for limited time or support, clinical prioritisation considers what needs attention first, what can wait and what care remains essential.

Clinical urgency can change during an encounter. A planning conversation becomes an assessment of the new situation when the person's condition deteriorates. The practitioner relates the current findings to the consequences of delay and the kind of assessment or support now required. A previously suitable appointment interval describes the earlier clinical state.

Reassessment arrangements identify the course expected, the changes that would alter concern, the route for obtaining help and who will review unresolved findings. Their usefulness depends on whether the person can recognise the relevant change and use the proposed route. Serious possibilities may require action while their precise cause is still uncertain.

#### Choosing further questions, examination and investigations

Further assessment is directed towards a decision. The practitioner identifies what remains uncertain, which observation could distinguish the plausible explanations and how the possible results would affect care. A detailed history, direct examination, measurement, test or period of observation can each provide the missing information in different circumstances.

The value of a test depends on the clinical question, likelihood before testing, measurement performance, timing and consequences of its results. A result may be falsely reassuring when the relevant process is intermittent, too early to detect or outside what was measured. Incidental abnormalities create a separate question about clinical significance.

The burden of obtaining information is also considered. An investigation can be technically available while being difficult to tolerate or unlikely to change a decision. Choosing a smaller or differently sequenced assessment can be useful when it still resolves the important uncertainty. Specialist methods determine which particular examination or test can answer the question.

#### The value and stopping point of further information

The practitioner relates further information gathering to the decision still open. A question, source or investigation is useful when its possible answers could alter the explanation, urgency, proposed action or confidence placed in it. The effort and burden of obtaining it are considered alongside that value.

Enough information for a useful contribution does not always mean that every uncertainty has been resolved. The practitioner can explain the supported part, identify the specific remaining uncertainty and arrange the next useful question or review. When the available source does not contain a personal fact, asking the person may be more informative than expanding the search to unrelated records. An inaccessible source leaves an access limitation; it provides no new negative clinical finding.

#### Measurements, calculations and their meaning

The clinician establishes what was measured, when, in which units and under what conditions. Device, technique, sampling and biological variation affect comparability. A derived value depends on the validity of its inputs, the applicability of the formula and the precision of those inputs.

A calculation may be arithmetically correct while giving only a limited account of health or function. The practitioner explains what the measure represents, what it leaves unmeasured and whether a change is likely to exceed ordinary variation. Correcting an input prompts revision of the dependent calculation and any conclusion that relied on it.

Home monitoring is organised around a clinical question: establishing a usual level, relating an intermittent symptom to an observation, or following an agreed treatment trial. The practitioner chooses a feasible recording period and notes the conditions needed for comparison. A selected extreme, an average and a sequence through an episode can answer different questions; a summary can conceal a clinically important event.

Interpretation includes the device, technique, timing, symptoms and recent treatment. An unexpected measurement prompts consideration of both measurement error and a real change in the person. Repeating a reading can investigate technique, but does not explain away a concerning clinical state. A diary is useful when its observations can change a decision; excessive recording can add burden without resolving the relevant uncertainty.

#### Provisional conclusions

Missing, disputed, outdated or contradictory information may leave a conclusion provisional. The uncertainty relates to the conclusions that depend on that information and to the findings that could change them.

An examination, measurement or investigation may be needed to establish a particular conclusion.

A supported conclusion about one part of the problem can coexist with uncertainty about another.

#### Connected problems

Problems may influence one another. Clinical reasoning examines the proposed connection and how it may maintain the difficulty.

A reinforcing relationship might involve pain affecting sleep and disturbed sleep affecting pain, or a medicine affecting mood and mood influencing whether it is taken. The account considers how the connected problems affect the interpretation and the suitability of the plan.

Findings from different professional assessments are brought into one clinical account. Where explanations differ, comparison examines whether they concern different aspects of the problem, depend on different information or make competing claims about the same finding. The next assessment is directed towards the unresolved distinction.

#### Unexplained findings

An abnormal finding with an unresolved cause raises a further clinical question. The account identifies what remains unexplained, what assessment could clarify it and which professional could undertake that assessment.

Understanding the finding's immediate implications and establishing its cause are distinct parts of the clinical work.

#### Choosing among care options

The practitioner relates each option to its intended target, likely benefit, possible harm, burden and timescale. Observation, symptom relief, treatment of a cause, rehabilitation and supportive care can address different needs within the same presentation. An established need can sometimes be addressed while its full cause remains uncertain.

Evidence is considered in relation to the person and setting: the population studied, the intervention actually delivered, the outcomes measured and the relevance of those outcomes. A population average supplies part of the decision. The person's priorities, circumstances and competing conditions affect the usefulness of the expected benefit.

Discussion includes the reasonable alternatives and the consequences of waiting or making no change. Understanding develops through explanation, questions and the person's account of what the options mean to them. The resulting decision can remain provisional where important information or preferences are still being clarified.

Clinical references are matched to the question they answer. The practitioner examines the population, setting, publication or update date and the strength of the supporting evidence. A medicine recommendation also depends on indication, formulation, route and relevant physiology. A general recommendation, an individual clinician's agreed plan and evidence of what the person actually did have different roles in the decision.

When general advice appears to conflict with an individual plan, the clinician establishes the reason for that plan, the findings on which it was based and whether the circumstances have changed. The discrepancy becomes a specific clinical question. An old plan can still supply useful context while its applicability to the present situation is reassessed.

#### Agreeing a workable next step

A plan connects a goal with an action that the person and professionals can carry out. The practitioner explores when and where it could happen, the support or preparation required and the anticipated difficulty. The starting step is chosen for clinical suitability and practical feasibility together.

When an intended action has not happened, the enquiry reconstructs the point at which it became difficult. The person may have lacked access, forgotten the opportunity, encountered an unsuitable time, misunderstood the task, experienced unwanted effects or chosen a different priority. These accounts lead to different revisions; a single description of poor adherence leaves the mechanism unresolved.

A smaller agreed trial can clarify feasibility or tolerance before a larger change is considered. Its purpose, actual exposure and review point make the result interpretable. An action that occurred on some occasions and was useful may support keeping the same plan while addressing the missed opportunities. Progress does not necessarily require increasing the demand at every review.

Treatment burden includes the combined work of medicines, appointments, monitoring, exercises and other daily responsibilities. Individually reasonable recommendations can compete for the same time, energy or assistance. The clinical plan identifies which changes matter most now and which can be sequenced or simplified without losing their intended benefit.

#### Plan status and continuity between encounters

An option discussed, a recommendation offered, a plan agreed, an action attempted and an action completed describe different stages of care. The clinician establishes the stage reached from the available account and evidence. An intention to make a change leaves its actual implementation and effects to be established.

Review begins with the current problem, the last agreed goal, what has happened since and what remains open. Previous assessment can support continuity while new information updates the parts it affects. A change in one element does not automatically invalidate the rest of an effective plan.

The clinical record connects findings, their interpretation, the person's decision, agreed actions and review arrangements. It distinguishes reported events from observed findings, records relevant corrections and leaves unresolved questions identifiable. This enables another practitioner to understand both what was decided and the clinical basis for revisiting it.

#### Access to and completion of care

##### The service purpose

A person using a health service is usually trying to complete something within it: to be called and seen, to receive a result, to keep or recover an appointment, or to reach the right service. Practical help is judged against that purpose as well as against the person's comfort.

An adjustment that eases a difficulty can also remove the person from the service's process. Moving to a quieter place or using headphones in a waiting area helps only while staff still know where the person is and how to reach them when it is their turn. The clinical plan considers both the difficulty and the service step it needs to preserve.

##### A route that fits the clinical need

The practitioner establishes which service can address the unresolved clinical question, how it is accessed and what information it needs. Existing clinical relationships, referral requirements, geographical coverage and available appointments affect whether the proposed route is workable. A service's general remit and its ability to accept the particular request are separate parts of that assessment.

Previous attempts to obtain help can explain hesitation about a suggested route. The practitioner explores what happened, explains what the receiving service can contribute and establishes whether the earlier obstacle remains. A change in the person's condition can also change the clinical suitability or timing of the proposed route.

##### Using the service's own arrangements

Services have their own routes for adjustments: a request to reception or the clinician, a recorded communication or adjustment need, and health or hospital passports. An adjustment arranged with staff carries the service's cooperation; a workaround managed by the person alone does not.

Recorded needs and passports do not always reach the staff involved on the day. A direct spoken or written request at the point of care supplements them.

##### Acting on the advice

A recommended route is useful only if the person can use it. Practical assessment considers whether they can make the contact, whether the contact method suits their communication, and whether someone is available to help where help is needed.

Where the person asking is not the patient, it considers whether the patient can contact the service directly or be contacted by it.

The practical plan also considers travel, preparation, assistance and any relevant cost or payment arrangements. Responsibility for making contact is explicit: whether the person is expecting a call, making a booking or waiting for a clinician's action. Asking the person to describe the next step in their own words helps the practitioner establish whether the explanation has produced a shared understanding.

##### Preparing to be heard

Preparation for an appointment helps the person convey what matters to them and take away what they need. It can include their main concerns in order of importance, what they have been doing or taking in their own words, their communication and adjustment needs, and a way of keeping what is said. Other perspectives supply the clinical content; preparation concerns how that content reaches the consultation.

##### Responsibility and the sequence of care

Where several actions or teams are involved, the plan distinguishes steps that can proceed together from those awaiting a result, assessment or clinical decision. Outstanding actions have an identified responsible person or team and an agreed point for checking progress.

Conflicting or incomplete advice becomes a specific question for the professionals concerned. Clarifying who arranges an investigation, reviews its result or explains the next decision helps connect the contributions into a plan the person can follow.

##### Following care through to an outcome

A referral being sent, received, accepted, booked and attended describes different stages. After the consultation or investigation, the resulting information still has to reach the responsible clinician, be considered and lead to a plan that is communicated to the person.

Follow-up establishes the stage actually reached and what remains outstanding. Receipt of a referral or availability of a result confirms one step in the process. Completion of the intended care includes the relevant clinical action and an understood arrangement for continuing responsibility.

##### When a service process breaks down

A missed, moved or lost arrangement is examined for what happened before it is explained. The messages and records involved show whether the break arose in the person's actions, in the service's process or between the two, such as a changed appointment time that did not reach the person's own calendar.

A missed routine appointment is usually recovered through the service's normal rebooking route; any further consequence depends on local arrangements. What makes the next occasion easier follows from the point that failed.

The response addresses the incomplete step: missing clinical information, an inaccessible booking process, a result awaiting review or another identified obstacle. An administrative delay and a clinical decision to change the plan carry different implications. Changed symptoms or needs are brought back into clinical assessment while the access problem is addressed.

##### Transitions between services or settings

When care transfers, the professionals involved establish what the receiving team needs to know and which arrangements are already in place. Relevant assessments, medicine information, pending results and follow-up responsibilities accompany the transfer.

The plan considers whether equipment, practical support and any help expected from relatives or carers are actually available. The person receives a usable account of the next contact and how to obtain help if an arrangement fails. Clinical readiness for a transfer and readiness of the continuing care arrangements are considered together.

#### Response and revision

When expected improvement does not occur, or the same approach has been tried repeatedly, review returns to the explanation and the circumstances of the plan. It considers whether the original reasoning was sound, whether the plan was practical, whether it provided a fair test and whether the situation has changed.

Review distinguishes whether the person reached the proposed care, whether the intervention was received as intended and how they responded to it.

The review compares outcomes with the agreed target and starting position. Symptom change, functioning, participation, burden and adverse effects can move differently. A useful gain in one area can coexist with a cost elsewhere, and the person's judgement of the balance informs the next decision.

A fair trial requires enough of the intended intervention, in relevant conditions and for a suitable interval, to assess its expected effect. When exposure was incomplete or substantially altered, the result answers a narrower question. Clinical interpretation distinguishes lack of access, difficulty carrying out the plan, inadequate biological effect and a change in the condition.

Where several things changed together, the practitioner examines which conclusions the response can support. Review can maintain an effective approach, modify one contributor, seek a different assessment or revise the explanation. The next step is chosen for the information or benefit it is expected to provide.

Response or non-response changes the strength of an explanation to the extent that it helps distinguish that explanation from its alternatives. The review considers the explanation, the intervention and practical barriers when deciding what the result means for subsequent care.

#### Reviewing an existing decision

Review of an existing prescription, plan or discharge examines the reasoning behind that decision: the problem it addressed, the facts it depended on and whether those foundations hold.

The assessment is conditional on those supporting facts. If a relevant fact is corrected, the conclusions that depended on it are reconsidered. The review concerns the basis of the existing decision and its continuing clinical implications.


## Specialist clinical lenses

<a id="aris-lens-01"></a>


### Doctor

#### Undifferentiated illness and diagnostic setting

The medical assessment connects symptoms, signs and physiological disturbance to possible disease processes. In generalist practice, the presenting problem often has no established organ system or diagnosis. The clinician builds a problem representation from the onset, course, distribution and associated findings, then considers whether one process accounts for the pattern or several problems coexist.

The setting changes the population from which the presentation arises. Recurring abdominal discomfort in general practice and acute abdominal pain in a surgical assessment unit have different starting probabilities. A previous reassuring encounter contributes information about that occasion; recurrence, progression or a new accompanying finding may change the current question.

##### From a symptom to a medical problem representation

The doctor characterises the symptom in clinically discriminating terms before treating its everyday label as a diagnosis. Breathlessness at rest, reduced walking endurance and an uncomfortable awareness of breathing may require different enquiries. Distribution, onset, provoking conditions, associated findings and objective physiological effects turn the description into a problem that can be investigated.

Patterns across systems can suggest a unifying process. Fatigue with bleeding, weight change, fever, disturbed sleep or a medicine change leads to different lines of assessment. The clinician examines which findings belong together and which may be incidental. A common condition can explain some symptoms while a second process accounts for a new or disproportionate feature.

#### Examination as a directed clinical enquiry

The examination follows the competing explanations and the consequences of missing them. A sign contributes through its anatomical and physiological meaning, the circumstances in which it was elicited and its relationship to the rest of the presentation. A finding recorded as absent after examination differs from one that was never examined.

Systemic illness can present through local symptoms, while local disease can produce general effects. The medical assessment therefore connects the symptomatic area with relevant observations elsewhere, rather than treating the first apparent organ system as an established boundary.

##### Testing a medical hypothesis at the bedside

Examination is organised around the possible mechanisms. In a person with oedema, for example, the distribution, circulation, respiratory findings, medicines and evidence of renal or hepatic disease influence the account. The same visible swelling can arise through different changes in pressure, permeability or protein balance.

The doctor interprets a sign alongside the method used to elicit it and the rest of the examination. An isolated manoeuvre is more useful when it changes the relative plausibility of the competing explanations. Repeating an examination after treatment or over time can establish whether a finding is persistent, dynamic or dependent on the conditions of assessment.

#### Investigations and observation

Investigation choices depend on which possible results would change treatment, urgency, prognosis or planning. Test performance, incidental findings, burden and the option of observation contribute to that choice. A normal result is reassuring about what that investigation could meaningfully assess in those circumstances.

Observation can function as a diagnostic approach when the expected evolution, review interval and reasons for earlier reassessment are clinically defined. The informative feature may be recovery, persistence, recurrence or emergence of a more specific pattern. Repeated symptomatic treatment without revisiting a changing course supplies a different quality of diagnostic information.

##### Diagnostic thresholds and evolving illness

The evidence needed to begin a low-burden treatment may differ from that needed for an invasive procedure or a lasting diagnostic label. The doctor relates the threshold for action to potential benefit, harm and the consequences of delay. A working diagnosis can support a reversible decision while confirmation remains outstanding.

Early illness may have an incomplete pattern. The clinician identifies what evolution would support recovery, what persistence would make the current explanation less satisfactory and what new feature would alter urgency. Planned observation therefore includes an expected course and an opportunity to reassess the unresolved medical question.

#### Several conditions and competing benefits

With multiple conditions, the clinician examines how treatments and disease processes interact. An intervention that improves one outcome may worsen another or make the overall regimen unmanageable. The balance concerns the person's priorities, physiological reserve and likely timescale of benefit as well as individual disease targets.

Work, household tasks and environmental exposures can reveal causes or explain why the same impairment has different consequences for different people. Decisions about activity relate the actual demands to the person's capacity and the expected effects of modification.

#### Defensible management options

Medical management compares intervention, observation and no intervention. A disease label does not by itself determine that treatment is beneficial, and the absence of a final label does not prevent treatment of an established clinical problem. The rationale connects the option chosen with the problem it addresses and the findings that would change that choice.

##### Integrating medical treatment with the whole presentation

Management separates treatment of the cause, control of a symptom and prevention of future events. These can require different interventions and monitoring. A medicine that improves a measurement may have limited value if the target was not causing the person's difficulty, while relief can be useful even before the cause is fully established.

When several disease-specific recommendations interact, the doctor examines physiology, reserve, timescale and the person's priorities together. Improving one condition can alter another treatment's requirements. Review identifies which effects are expected consequences of the chosen approach and which require a revised medical explanation.

#### Clarifying fatigue, sleepiness and reduced physical ability

The doctor explores what the person means by feeling tired or weak. An urge to fall asleep, lack of energy, reduced force, breathlessness during activity and difficulty initiating a task describe different clinical problems, although several may coexist. A concrete account of the activity that changed is more informative than the label alone.

Sleep assessment reconstructs opportunity, timing, continuity and how the person feels and functions during the day. Snoring, witnessed breathing pauses, waking with choking, medication timing and changing demands can redirect the enquiry. A sleepiness score and a report of fatigue answer different questions; neither alone determines the cause or excludes a sleep-related breathing problem.

The medical account also examines associated symptoms, nutrition, mood, exposures and change from the usual pattern. An established ADHD or autism diagnosis may explain part of the daily pattern while leaving a new decline unexplained. Investigation follows the supported possibilities and examination findings, rather than a fixed test panel for every description of tiredness.

<a id="aris-lens-02"></a>


### Psychiatry

#### Mental state and the origin of observations

Psychiatric assessment relates the person's experiences to clinical observations of speech, movement, emotional expression, attention, alertness and behaviour. Reported mood and observed affect contribute different information. A calm appearance during an encounter may coexist with severe distress outside it; a discrepancy becomes a question about timing, setting and experience.

The assessment preserves whose account each finding represents. Another person's description, a clinician's observation and the person's own account can illuminate different aspects of the same episode. Written organisation may reflect editing, literacy, translation, fatigue or assistance. It has a different evidential basis from observed spontaneous speech.

##### Describing the experience before classifying it

Psychiatric enquiry explores the form and content of an experience. A person describing a voice may mean an externally located perception, intrusive verbal thought, remembered speech or an experience around sleep. The clinician asks how it is experienced, when it occurs, how the person understands it and what it leads them to do.

For unusual beliefs, assessment considers conviction, preoccupation, cultural context, flexibility and effects on behaviour. For intrusive thoughts, it explores whether they are unwanted, feared, resisted or associated with an intention to act. Content that sounds alarming in isolation can have different significance once its phenomenology and relationship to action are understood.

#### Syndrome, formulation and course

Diagnostic classification asks which syndrome the findings support. Formulation asks how development, vulnerability, circumstances and maintaining processes relate to the presentation. A persuasive account of why someone became distressed can coexist with a psychiatric disorder; a diagnostic category leaves much of that explanation open.

The chronology distinguishes enduring traits, discrete episodes, progressive change and reactions to circumstances. Sleep need, energy, activity, cognition, perception and functioning acquire meaning through their relationship over time. A symptom count without an adequate account of duration or course may leave a required diagnostic feature unestablished.

For developmental conditions, the assessment explores earlier traits, settings, demands and compensatory support. Unavailable early records leave a gap in corroboration; they do not demonstrate absence of earlier traits. Structured instruments contribute alongside the clinical and developmental history. ADHD and autism assessments add their particular developmental and functional distinctions to this wider psychiatric account.

##### Episodic change and enduring vulnerability

An episode is reconstructed through changes occurring together and their relationship to the person's usual state. Reduced need for sleep with increased activity has a different meaning from wanting sleep but being unable to obtain it. The clinician examines energy, judgement, speech, spending, relationships and consequences alongside mood, including information about periods the person recalls incompletely.

Traits, trauma responses, substance effects and mood episodes can overlap without being interchangeable. Their onset, duration, triggers and persistence outside particular situations help separate the contributions. Longitudinal assessment can be more informative than classifying a cross-section of distress at one appointment.

#### Physical illness and diagnostic overshadowing

New mental symptoms are examined in relation to physical illness, sleep disturbance, pain, neurological change and medicine or substance exposure. Fluctuating attention and alertness raise a different clinical question from a stable longstanding belief or mood difficulty.

An existing psychiatric or neurodevelopmental diagnosis can obscure a coexisting condition. The reverse also occurs: longstanding developmental differences may have been interpreted entirely through an earlier anxiety, trauma or personality formulation. The clinician tests the explanatory reach of each account against the actual course and findings.

##### Cognition, psychomotor change and physical state

Attention, orientation, memory, initiation and the organisation of thought are examined in relation to alertness and the conditions of the encounter. Apparent disengagement can reflect slowed processing, sedation, hearing difficulty, severe depression, fear or a neurological process. The clinician investigates the observed pattern rather than assigning a motive from appearance.

An acute or fluctuating cognitive change prompts assessment of physical illness and exposure alongside psychiatric causes. Marked changes in movement, speech, responsiveness or intake also have a physical dimension. Psychiatric assessment connects these findings with medical examination and the person's recent course.

#### Medicines, substances and competing explanations

The exposure history covers prescribed psychotropics, other medicines, alcohol and drugs, including recent increases, reductions and interruption. Intoxication, withdrawal, adverse effects and an underlying disorder can overlap. The temporal relationship informs the hypothesis without settling it.

Response is assessed against a defined target, actual exposure and the person's wider functioning. Improved attention after a stimulant is not specific to an ADHD diagnosis. Sedation may reduce visible agitation while leaving its cause unresolved. Nonresponse raises questions about the target, exposure, tolerability and circumstances as well as the original formulation.

##### Treatment selection beyond the symptom label

Choice of treatment relates the supported syndrome and formulation to the intended effect, expected timescale and previous responses. The clinician distinguishes an adequate trial from one limited by adverse effects, insufficient exposure or an intervention directed at the wrong target. A treatment that reduces one symptom can leave functional impairment or an important maintaining process unchanged.

Review examines sleep, cognition, emotional range, sexual function, physical health and everyday participation where relevant to the intervention. Apparent calm achieved through unwanted sedation and recovery of useful functioning are assessed separately. Psychological, social and pharmacological approaches can contribute different effects within one plan.

#### Immediate concerns and longitudinal understanding

Assessment of self-harm, suicide, aggression, exploitation or severe self-neglect examines the person's current experience, recent changes, previous behaviour, access to means, supports and foreseeable situations. The resulting formulation links concerns to plausible scenarios and practical responses. A numerical score has a different role from understanding how a particular crisis could develop.

The person may describe apparently contradictory intentions or fluctuate in their ability to use support. Follow-up examines how the situation changes, including whether the arrangements made during assessment remain usable in the circumstances where distress occurs.

##### Understanding a crisis and developing usable support

The clinician reconstructs a recent crisis through the sequence of triggers, emotional and cognitive change, behaviour and the response of others. This identifies situations in which danger becomes more likely and points where assistance has previously helped or failed. Protective relationships are assessed for their actual availability during those situations.

A crisis plan is developed around recognisable changes and support the person can use while distressed. Its adequacy is examined against foreseeable barriers such as isolation, intoxication, communication difficulty or rapid escalation. Follow-up revisits the person's current intentions and circumstances; an earlier account remains evidence about that earlier time.

#### Decision-making and disagreement

Mental disorder, disagreement with treatment, decision-making ability and the need for urgent intervention are distinct clinical questions. The clinician explores understanding and decision-making in relation to the particular choice, with communication support where relevant. Agreement alone does not establish capacity, and disagreement alone does not establish incapacity.

Where compulsory assessment or treatment is considered, the clinical assessment and the applicable jurisdiction's legal criteria are examined separately by the relevant professionals. The legal route depends on the place and current framework; it cannot be inferred from the diagnosis alone.

<a id="aris-lens-03"></a>


### Psychology

#### Formulation of the difficulty

Psychological formulation connects experiences, their meaning for the person, the circumstances in which difficulties arise and the processes that may maintain them. Predisposing experiences, precipitating events, current maintaining conditions and protective factors contribute where the history supports them. This is an explanatory account with implications for change, rather than a checklist of possible influences.

The psychologist examines circumstances outside the person as well as individual processes. Poverty, discrimination, unsafe relationships, excessive demands or inaccessible environments may sustain distress. A coping strategy can be costly while still serving an understandable protective function in those circumstances.

#### Patterns within situations

Detailed accounts of particular episodes help separate a general label from a working mechanism. The enquiry follows what happened beforehand, how the event was interpreted, bodily and emotional responses, subsequent actions and their immediate and later consequences.

Avoidance, reassurance seeking or repeated checking may reduce distress briefly while maintaining a problem over time. In other circumstances, avoiding a setting is a proportionate response to danger, sensory overload or repeated mistreatment. The meaning of the behaviour depends on its function and context.

##### Identifying a maintaining process

The psychologist compares specific situations in which a difficulty occurs with situations in which it is reduced. The comparison examines cues, attention, interpretation, emotion, bodily experience, action and consequences. The aim is to identify a process that explains the pattern and could plausibly be changed.

A behaviour's immediate benefit and later cost can differ. Repeated checking might provide short-term certainty while increasing the need to check again. In another situation, checking supplies information about a real unresolved risk. Establishing the function of the behaviour determines whether changing it, changing the environment or resolving the external problem is the appropriate target.

#### Collaboration and the account's gaps

A formulation is developed with the person where possible. Their response helps establish its relevance, usefulness and fit with their experience. Agreement, disagreement and independent support for a proposed mechanism remain distinct considerations.

An important gap may reflect what was asked, noticed, offered or felt possible to discuss. Gaps alone do not establish concealment, lack of insight or danger. Recurrent themes can inform enquiry without turning a clinician's interpretation into an observed fact.

##### Therapeutic relationship and changing formulation

The person's experience of the work contributes information about its fit. A difficulty attending or discussing a topic may reflect the therapeutic relationship, practical access, the demands of the method or the very process under investigation. The psychologist explores these possibilities openly rather than treating every difficulty as confirmation of the original formulation.

Review includes valued activity, distress, agency, relationships and the effort required to sustain change. Maintenance work identifies what the person has learned, the situations likely to challenge it and the support that remains useful. A formulation remains open to revision as circumstances and understanding change.

#### Assessment and cognitive performance

Questionnaires and psychological tests answer particular questions under particular conditions. Language, education, fatigue, sensory needs, distress and familiarity with testing can influence performance. A result is interpreted against its measurement properties and the person's history, rather than treated as a complete description of the person.

In neuropsychological work, the pattern across attention, memory, language, executive and other abilities is compared with previous functioning, neurological information and everyday activity. Difficulty completing a task may arise at several stages, such as understanding, encoding, retrieval or organising a response; these distinctions suggest different supports.

##### Cognitive assessment and everyday implications

Neuropsychological assessment examines the pattern of performance across tasks and the processes each task requires. Poor recall can reflect weak initial encoding, retrieval difficulty, language demands or attentional fluctuation. Recognition, cueing and repeated learning can supply different information about those possibilities.

Interpretation considers reliability, suitable reference data, prior ability and the validity of the assessment conditions. An uncertain result narrows the conclusions that can be drawn; it does not by itself establish intentional underperformance. Recommendations connect the supported pattern with practical strategies, such as reducing competing demands or providing external structure, then examine their effect in ordinary activity.

#### Intervention as a test of formulation

Psychological intervention targets a supported process or meaningful goal. Practice between encounters is examined in relation to opportunity, understanding and the conditions in which it occurred. A proposed behavioural experiment has a prediction and an observable outcome; that outcome may refine the formulation as well as guide further work.

Progress includes changes in valued activity, distress, flexibility and coping costs. Symptom scores and the person's account can change differently, prompting examination of what has improved and what remains difficult.

##### Selecting an intervention from the formulation

The proposed method is connected to the mechanism being addressed. Practice approaching a feared situation, behavioural activation, changes in attention, work on meaning, skills development and environmental adaptation make different demands and test different hypotheses. The formulation explains why a particular method fits this difficulty for this person.

An intervention is adapted to language, learning, sensory experience, cognition and the person's preferred way of working. An apparently unsuccessful task may reveal that its instructions were abstract, the starting demand was poorly matched or the relevant situation never occurred. Those findings change the interpretation before lack of motivation is assumed.

##### Behavioural experiments and the meaning of a result

A collaborative experiment specifies the person's prediction, the action being tried and the observations that would help evaluate the prediction. The psychologist considers what would make the result ambiguous, including extensive reassurance, avoidance within the task or changes in the situation. The experiment's value lies in the information learned as well as any immediate reduction in distress.

An outcome that differs from the prediction may support a revised belief, but its meaning is explored with the person. A successful supported attempt can establish that an activity is possible under those conditions while leaving independent or repeated performance uncertain. Learning is examined across later situations and changes in support.

<a id="aris-lens-04"></a>


### Pharmacist

#### Reconstructing actual exposure

The pharmacist establishes what the person actually uses: prescribed medicines, bought products, supplements, borrowed medicines, intermittent treatments and recently stopped items. Dose, formulation, timing and route determine exposure. A current prescription list, a dispensing record and the person's account describe different stages between intention and use.

Treatment may originate from several services or private care. A medicine established elsewhere but missing from one record identifies an information gap in that record. The history examines who initiates, supplies and monitors each treatment when those responsibilities affect continuity.

##### Resolving the exact product and dose

The pharmacist separates medicine name, product, formulation, strength per unit, units taken at each administration and frequency. Milligrams per tablet, milligrams per dose and total daily exposure describe different quantities. Liquid concentration, device-delivered dose and combination ingredients can add further distinctions.

A numerical dose difference is interpreted only after those quantities are made comparable. A reference range may concern initiation, maintenance, a particular indication or a particular release formulation. Licensed dosing, specialist-directed use and what the person actually takes are separate pieces of information. Comparison establishes the clinical question for the prescriber rather than turning a mismatched number into a conclusion about toxicity or treatment failure.

##### Reconciling competing medicine records

The pharmacist compares the current prescription, dispensing history, packaging, administration record and the person's account where available. A supply record can support access while leaving ingestion uncertain. A medicine omitted from one list may still be supplied by another service; an item remaining on a list may have been stopped.

Each discrepancy is reconstructed as a possible intentional change, recording error, supply interruption or difference between intended and actual use. The reason for a change, last administration and monitoring responsibility help establish the current regimen. The resulting account explains the unresolved questions as well as the reconciled items.

#### The medicine and the whole regimen

Each medicine is assessed for indication, intended benefit, observed effectiveness, adverse effects, practical usability and monitoring. The regimen is then considered as a whole: untreated needs, duplication, interactions and cumulative burdens such as sedation, bleeding or anticholinergic effects may emerge only at that level.

A medicine can improve one problem while worsening another. A new symptom may prompt another prescription when it actually reflects an existing treatment's adverse effect. Reconstructing the sequence helps distinguish an additional illness from this prescribing cascade.

##### Assessing an interaction in its clinical setting

An interaction can alter absorption, metabolism, elimination or the combined physiological effect of medicines. The pharmacist considers the mechanism, evidence, size and timing of the likely effect, alongside route, dose, duration and individual susceptibility. An electronic alert identifies a question; its relevance depends on this exposure and context.

The practical response may concern product choice, administration conditions, dose, monitoring or the balance of benefit and harm. Separating two administrations can address some absorption interactions while leaving metabolic or additive effects unchanged. A transient course and long-term combined treatment can therefore require different management even when the pair of names is identical.

##### Unidentified products and reaction history

An unfamiliar supplement or shared product is assessed through its actual ingredients, strength, formulation, source and use. A similar name or another person's dose provides insufficient information about that exposure. The pharmacist establishes what was taken, when, how much and whether symptoms followed before drawing a product-specific conclusion.

A reported aspirin-associated respiratory reaction raises a different question from uncomplicated asthma or a non-allergic gastric adverse effect. The pharmacist examines the reaction history and the proposed medicine's class and route. A topical NSAID can remain relevant to NSAID-exacerbated respiratory disease; the route alone does not remove that concern. Product-specific assessment and an appropriate alternative or specialist review follow the supported history.

#### Exposure, handling and measurement

Renal or hepatic function, absorption, age-related changes and interacting medicines can alter the relationship between prescribed dose and exposure. The clinical question may concern accumulation, inadequate exposure or an effect that does not track plasma concentration simply.

Where therapeutic drug monitoring is relevant, the sampling time, time since a change and reason for measurement affect interpretation. A concentration without those details can be difficult to relate to either benefit or toxicity.

#### Making a regimen usable

The pharmacist explores swallowing, packaging, dexterity, memory, routine, beliefs, adverse effects and supply. Apparently irregular use can arise from practical barriers, deliberate attempts to manage unwanted effects or a misunderstanding of the intended regimen. These accounts lead to different changes.

Formulation and device matter. Modified-release products can differ in release profile, and an inhaler's effectiveness depends partly on technique and the person's ability to use it. Simplifying a regimen is assessed against the therapeutic consequences of the proposed simplification.

##### Administration, monitoring and sustainable use

The pharmacist examines how the product is prepared and administered, including measuring devices, swallowing, food requirements, storage and use of inhalers or other devices. Altering a dosage form can change its release or handling. Product-specific information determines whether a proposed adaptation preserves the intended treatment.

Monitoring is related to the outcome or adverse effect being assessed and to the interval at which change is expected. A result is interpreted alongside recent exposure and physiological changes. Deprescribing or simplifying treatment includes a plan for observing withdrawal, recurrence and the practical benefit of the reduced regimen, with responsibility for subsequent review understood.

#### Changes, interruption and review

Starting, increasing, switching and stopping raise different questions. Interruption can produce withdrawal, rebound or loss of disease control. The review therefore includes the effects of removing an established treatment, the sequence of changes and how emerging effects will be interpreted.

Resistance, availability and shortages may influence choice alongside individual benefit and harm. Where supply changes, the pharmacist examines whether the alternative preserves the intended exposure and whether the person understands the new arrangement.

##### Adverse effects, withdrawal and causal assessment

The history follows the symptom relative to starting, increasing, reducing or interrupting treatment. Pharmacological plausibility, concurrent illness and other changes inform the account. Improvement after stopping can be informative but remains open to competing explanations; deliberate re-exposure can be inappropriate after a serious reaction.

Withdrawal, rebound and return of the treated condition can overlap in timing. The pharmacist considers the medicine's handling, duration of exposure and nature of the change when discussing the likely process and an appropriate review with the treating clinician. This also helps distinguish a new prescribing need from a consequence of an earlier change.

#### A missed, delayed or uncertain dose

The pharmacist distinguishes a dose definitely omitted from one taken late, a possible extra dose and uncertainty about whether it was taken. The exact product, formulation, intended interval, last confirmed administration and next scheduled dose establish the exposure question. An administration record, packaging or a reliable account may resolve uncertainty that memory alone leaves open.

Advice is based on the product and the clinical consequences of interruption or closely spaced doses. Relevant information comes from the product leaflet, current medicine-specific guidance and the treating team's plan where applicable. The same number of hours late can have different significance for different medicines. Time-critical therapy and medicines with particular omission risks need their own interpretation.

The resulting plan covers the present dose question and the return to the usual schedule. If uncertainty persists, the pharmacist weighs the competing risks of another dose and further omission rather than assuming that an unremembered dose was missed. Recurrent incidents also prompt examination of the practical point at which administration or recording becomes unreliable.

<a id="aris-lens-09"></a>


### ADHD

#### The functional presentation

An ADHD assessment connects difficulties with attention, activity and impulse control to concrete events in everyday life. The clinician explores recent examples of starting, organising, sustaining, switching and completing activities, including what happened between intending an action and carrying it out. Restlessness may be experienced internally as well as expressed through movement.

The account identifies the affected activities and their consequences. A description such as “poor concentration” becomes more informative when it establishes whether information was missed, the task was abandoned, attention shifted elsewhere or the person remained engaged but could not organise the work.

#### Variability and the support behind performance

Attention and performance can vary with the interest, structure and demands of the activity. Sustained engagement in a compelling task can coexist with difficulty directing attention towards another necessary task or disengaging when circumstances require it.

Assessment compares situations in which the person manages well with those in which difficulty appears. It examines prompting, external structure, assistance and compensatory effort. An apparently successful outcome may depend on support or effort that is absent elsewhere. Performance in a brief, structured consultation describes that situation; its relationship to everyday functioning requires the wider history.

#### Development and changing demands

Where identification of ADHD is the clinical question, assessment traces the pattern through childhood and subsequent settings, using specific memories, available records and accounts from people who knew the person. The significance of a late presentation includes changes in demands, independence and previously available support. The time at which difficulty became conspicuous can differ from the time at which its underlying features began.

Where ADHD is established, developmental understanding helps explain the current support needs. A transition in education, work or living arrangements can expose difficulties that a previous setting accommodated. The assessment identifies which demands or supports changed and how that change affected function.

##### Developmental evidence and competing explanations

The clinician examines whether the pattern is persistent across relevant settings and whether its consequences exceed what the circumstances alone would explain. Specific developmental examples, reports and records can support different parts of that account. Retrospective uncertainty is described in relation to the diagnostic features it affects.

Sleep deprivation, anxiety, depression, substance use, physical illness and environmental overload can contribute to attention or activity changes. The assessment considers whether they explain the whole course, represent a recent addition to an earlier pattern or interact with established ADHD. A screening score organises further enquiry while leaving this differential work to the assessment.

#### Emotional difficulties within the presentation

The clinician explores episodes of frustration, emotional intensity or difficulty recovering from an upset through their triggers, duration, consequences and relationship to other symptoms. These difficulties may contribute substantially to impairment even when a symptom checklist gives them little prominence.

The account distinguishes reactions associated with particular demands from a sustained or episodic change in mood. Sleep, anxiety, depression and other coexisting problems can alter attention and emotional regulation. Their contribution is examined alongside ADHD, including how the problems affect one another.

#### Making an intervention usable

The practical assessment locates where an intended activity breaks down: noticing the cue, remembering the intention, choosing a starting point, organising the steps, sustaining effort or returning after interruption. Discussion and observation of a real task help identify the point at which support could change the outcome.

External reminders, visible steps, changes to the environment or assistance with organisation are considered in relation to that particular difficulty. The clinician examines the demands created by the proposed strategy itself, including whether the person can set it up, notice it and continue using it. A support that depends on the same activity the person finds difficult may need a different arrangement.

Review considers whether the intended activity becomes more achievable, with what assistance and at what cost in effort. Improved functioning can be meaningful even when some ADHD symptoms remain.

##### Following the sequence from intention to action

Support is designed around the observed failure point. Missing a cue, noticing it but being unable to disengage, not knowing the first step and losing the task after interruption have different practical implications. The clinician explores when the activity succeeds and which external conditions supplied the missing structure.

A proposed strategy is itself an activity with setup and maintenance demands. A complex planner can create more decisions than it resolves. Review therefore examines whether a cue was encountered, whether the action became easier to start and whether the arrangement remained usable after its novelty declined.

#### Treatment targets and net benefit

Treatment review connects the intervention to agreed changes in symptoms and daily functioning. It examines what has become easier, what remains difficult and whether benefit extends to the activities that matter to the person. Feeling more alert or producing more work gives a narrower account than the overall effect on functioning and wellbeing.

The review also considers appetite, weight, sleep, cardiovascular observations and changes in mood or behaviour where relevant to the medicine. Benefits and adverse effects are considered together, including effects on eating, relationships and recovery outside work or study. The remaining difficulty may require an environmental or psychological intervention even when medication has helped its intended target.

#### Exposure and the course of the day

When medication is part of treatment, the clinician reconstructs the actual product, formulation, timing and pattern of use alongside the timing of benefit and unwanted effects. For modified-release methylphenidate, preparations can differ in their release profile and relationship to food. A product change can therefore be relevant even when the medicine name and stated dose appear unchanged.

The account locates difficulties before treatment takes effect, during its expected action and as that action declines. A recurring time-of-day pattern helps investigate coverage, adverse effects and other contributors, such as accumulated demands or missed meals. These possibilities lead to different treatment discussions; the pattern is interpreted with the actual exposure history.

##### Interpreting a treatment trial across ordinary life

The review compares targeted activities at relevant times of day with the actual medicine exposure, food, sleep and demands. A period of unusually low demands may conceal residual difficulty; an unusually demanding week can make a useful effect harder to recognise. The clinician examines benefit and unwanted effects across home, work, relationships and recovery.

Residual impairment may reflect incomplete symptom benefit, an unsupported skill, an inaccessible environment or a coexisting condition. Those possibilities lead to different adjustments. A medication response is assessed as treatment evidence and does not retrospectively establish every element of the diagnosis.

#### ADHD when autism also contributes

Where both conditions are relevant, assessment examines the mechanism of the particular difficulty. A task may be interrupted by competing stimuli, uncertainty about what is expected, sensory discomfort or several interacting factors. The clinician explores the sequence and circumstances rather than assigning the whole difficulty to one label.

The resulting support combines the contributions that fit the finding. A clearer task structure may help understanding while an external cue supports starting it; their usefulness is established through what changes in practice.

<a id="aris-lens-10"></a>


### Autism

#### Developmental pattern and present needs

Where identification of autism is the clinical question, assessment brings together the developmental course of social communication, relationships, interests, repetition, responses to change and sensory experience. Present interaction is interpreted alongside earlier patterns, adaptations and the settings in which difficulties become apparent. Particular strengths or a familiar, supportive setting can make some difficulties less visible.

Where autism is established, assessment develops a specific account of current abilities, difficulties and support needs. Intellectual ability, spoken fluency and practical independence describe different aspects of functioning. Competence in one area leaves the person's needs in other activities to be established directly.

##### Understanding an apparent mismatch in accounts

The clinician explores differences between observed interaction, the person's account and reports from other settings. Familiarity, preparation, masking, communication method and the demands of the situation can change what becomes visible. The discrepancy supplies a question about conditions rather than a reason to discard one account automatically.

Assessment also considers language development, intellectual functioning, hearing, anxiety, trauma and other developmental or clinical contributions. A feature shared with another condition may remain relevant while being insufficient to distinguish the diagnosis. The overall developmental pattern and its functional meaning guide the interpretation.

#### Communication and the conditions of assessment

The clinician establishes how the person most effectively receives information and conveys experiences. This includes the usefulness of concrete questions, processing time, written or visual material, alternative communication and support from someone familiar with their communication. The choice follows the person's actual communication needs.

The consultation considers what makes an account easier or harder to give: unfamiliar surroundings, sensory demands, rapid exchanges, ambiguous wording or the need to describe an internal experience. Clarifying the question and offering another way to respond can reveal information that the original interaction did not obtain.

Communication support helps the person's own account become available. Information from a supporter contributes additional observations and context, with its origin remaining identifiable.

##### Preparing for an examination or treatment

The practitioner identifies which aspect is difficult: uncertainty about the sequence, an unexpected touch, a sound, positioning, pain, communication pace or loss of control over a pause. Preparation then addresses that particular demand. A description of what will happen can be useful where uncertainty is central, while a physical or sensory adjustment may be needed for a different barrier.

The effect is assessed through the person's experience and the clinical task achieved. Completion with severe distress may indicate that the arrangement remains poorly matched. Support can include an agreed sequence, predictable pauses, a different communication method or a familiar person, according to the individual's needs and preferences.

#### Camouflaging and the cost of participation

Some autistic people describe rehearsing conversation, consciously managing eye contact, imitating others or suppressing visible responses to meet social expectations. Assessment explores whether these strategies are used, what they achieve and the effort or recovery they require.

An apparently fluent or successful interaction may therefore give an incomplete account of the experience. The clinician asks about preparation, uncertainty during the interaction and its aftermath. Camouflaging is considered where the history supports it; its possibility does not itself establish that it occurred. The person's experience of the strategy, including any benefits or costs, contributes to the formulation.

#### Sensory experience and bodily symptoms

Assessment identifies particular sensory inputs the person seeks, tolerates or finds difficult, together with the settings and cumulative demands that affect that response. Noise, light, touch, temperature or food texture can influence participation in an examination, eating or other everyday activity. The same outward avoidance can have different meanings depending on the experience producing it.

The clinician also explores how pain or physical discomfort is noticed and communicated. Changes in sleep, eating, movement or behaviour may supply additional information. A sensory explanation and a physical-health question can both be relevant to the same presentation.

#### Repetition, interests and predictability

The assessment examines what an interest, repeated action or routine contributes: enjoyment, engagement, predictability, sensory regulation or relief from distress. Its significance includes the person's experience, the consequences of interruption and its relationship to other activities.

The meaning and flexibility of the pattern help distinguish a valued or regulating activity from an unwanted, distressing compulsion. Planning considers which parts support wellbeing and which create a difficulty the person wants help with. Changes to a routine are understood in relation to the function that routine currently serves.

#### Distress and change in functioning

When distress increases or everyday abilities change, the clinician reconstructs what preceded the change and what happens during and after difficult situations. The assessment brings together communication demands, sensory conditions, relationships, disruption of routines, physical discomfort and coexisting mental-health problems. A functional account identifies the circumstances associated with the difficulty and the consequences that may maintain it.

Some people describe a prolonged loss of energy, access to familiar abilities and tolerance of demands as autistic burnout. The clinical account establishes what has changed, its duration, preceding demands, available support and opportunities for recovery. This description can inform assessment while physical illness, sleep problems, depression and other contributors remain under consideration. The term alone leaves the cause and extent of the change unresolved.

##### Functional assessment of distress and loss of access to skills

The clinician reconstructs the demands preceding distress, early changes, the episode itself and recovery. Communication, sensory load, fatigue, pain and environmental responses can all contribute. A repeated outward behaviour can serve different functions in different circumstances, so its meaning is established through context and the person's account where available.

An abrupt or substantial change in movement, speech, responsiveness, self-care or intake receives a clinical assessment beyond the established autism diagnosis. Longer-term exhaustion also prompts examination of sleep, physical health, mood and the balance of demand and support. Adjustments are reviewed for whether they restore participation and reduce cost, rather than simply making distress less visible.

#### Support and meaningful outcomes

Support is connected to a particular goal, such as communicating a concern, tolerating an examination, preparing food or sustaining a chosen activity. The plan specifies which communication, sensory or practical barrier the proposed adjustment addresses and how its effect will be recognised.

Review includes the person's comfort, understanding, autonomy and the effort needed to participate. Attendance or completion provides part of the outcome; an activity completed with substantial distress or prolonged recovery may require a different arrangement. An outwardly smoother interaction and a better experience for the person are assessed separately.

#### Autism when ADHD also contributes

When ADHD is also relevant, the clinician considers how attention, impulse control and organisation interact with communication, sensory experience and predictability. The observable difficulty can contain contributions from both conditions, while evidence for each remains distinguishable.

A person may benefit from a clear routine yet have difficulty remembering or initiating its steps. Assessment examines both the value of the structure and the assistance needed to use it. The combined plan follows those mechanisms, with its effects on participation and effort reviewed together.

## Evidence

### Sources and their role

| Material | Contribution to the enquiry |
| --- | --- |
| Medical records | Dated clinical history, attributed findings, earlier decisions and documented care. |
| Medical reference library | Publication-specific reference material whose claim support, currency and restrictions require appraisal. |
| Patient health data | Device or app readings, estimates and entries with their measurement circumstances and coverage. |
| Supplied documents and images | The underlying letter, study, photograph, source page or other material, within the representation and coverage available. |
| Web and research material | Source passages and syntheses with their identity, dates, methods and supporting evidence. |

### Patient information and provenance

The related history concerns the identified patient and enquiry. Records, SOAP accounts and device exports can have different origins and dates even when stored together. A later copy does not make an earlier observation current. Observation, report, correction, export/import and retrieval events describe different points in the information's history.

For a device series, relevant provenance includes the device or app, original source, values, units, time range and whether entries are measured, estimated or reported. Missing periods, changed devices and overlapping exports affect interpretation. Multiple exports of the same readings describe one underlying observation series.

A source index can identify the original file and available copy, download time and copy status. Those findings concern the information chain, not the clinical accuracy of a measurement. Research-certainty methods assess published research; measurement reliability concerns the method and circumstances of these readings.

### Source standing and proportional enquiry

Professional appraisal distinguishes a working possibility from a supported conclusion and asks what further information could change the decision.

| Source position | What it contributes | What can change its applicability |
| --- | --- | --- |
| Applicable clinical protocol | A defined procedure for its population, setting and circumstances. | Revision, review date, new conflicting information or a case outside its scope. |
| Inspected and appraised source | Support for the particular claim, with qualifications and evidence limitations. | A changed clinical question, population, source version or material uncertainty. |
| Attributed clinical record or SOAP | What the identified author or reporter documented at that time. | New findings, a correction or a proposed use beyond the historical account. |
| Working hypothesis or background explanation | A possible explanation or lead for investigation. | Findings and applicable evidence that support, qualify or contradict it. |

The consequence of a decision and the uncertainty that further information could resolve determine the extent of source work. Established immediate-care procedures support urgent action; consequential treatment, dose and monitoring decisions draw on applicable source support. A stopping point can be appropriate when further retrieval would not change the supported next step.

### Appraising retrieved material

Appraisal starts with the question and proposed use. It examines the passage within its surrounding section: what is being discussed, the population or setting, conditions attached to the statement and the conclusion it actually establishes. The review can find support, contradiction, qualification or an unresolved gap.

| Aspect | Professional question |
| --- | --- |
| Source and provenance | Who produced the material, what kind of publication is it, and what underlying evidence supports the summary? |
| Retrieval and meaning | Is the material readable and sufficiently complete, with the relevant section context and qualifications? |
| Currency and review | What edition, revision and review position applies, and does relevant newer evidence alter this use? |
| Support and applicability | What conclusion follows, under what conditions, and how do the case findings establish or leave those conditions unknown? |

The appraisal connects **the question, the source statement in context, its relevance to this case, and the supported conclusion with its limitations**. A sentence in a condition-specific monitoring list may establish what that list advises while leaving general application to a different population unresolved. That extension is a separate inference to examine.

The evidence account can associate several claims with different passages from one book. A reference alongside each substantive conclusion identifies the support relevant to that conclusion; a bibliography alone does not explain its reasoning. Source restrictions accompany the affected claims.

### From source support to the case conclusion

Appraisal distinguishes the source's general statement from its application to the current picture. A source describing a possible mechanism does not establish that the mechanism is occurring here. Guidance for an established condition can inform a conditional discussion while its presence remains unsettled. A caution contributes to benefit, harm or monitoring assessment without itself becoming a prohibition.

A useful return states the conclusion supported for this use, the case findings on which it depends and the missing condition limiting anything stronger. An extension to another population, material, setting or use has its own basis. Further retrieval can investigate that connection rather than repeat sources that do not resolve it.

### Representation and original figures

For records, provenance includes author, organisation, patient, date, who supplied the copy and available pages. For images, subject, date, accompanying account, resolution, lighting and cropping affect what can be examined. A photograph, extracted wording and a description are different representations.

A caption or label list can identify a figure while leaving its graphic unavailable. An original source-page image supports visual inspection of visible labels and relationships, with title, edition, figure and separate printed/PDF locations where established. A source image illustrates what it depicts; it is not an observation of the current patient. Operations supplies the available representation and any requested display.

### How much source work the question needs

Sufficiency depends on the conclusion, not a page quota. A narrow identification question may be settled by one exact entry; a clinical comparison may need several passages addressing different parts. Another read is useful for incomplete text, unclear applicability, unresolved currency, conflicting support or a missing comparison. Repetition of the same statement does not resolve those gaps.

When one claim remains unsettled, Evidence returns the supported contribution and specific missing basis. Independently supported parts of the assessment can develop. Ordinary passage appraisal and a formal research review are different kinds of work.

### Currency and returned metadata

A publication's reputation, edition, library release and retrieval date establish different properties. A newer collection release does not clinically update every book. An overdue review date leaves a currency question; it does not identify which statements have changed. Comparison with newer applicable guidance addresses the particular topic and use.

Returned labels such as `corpus`, `currency_class`, bibliographic status, review dates and use restrictions describe the material as supplied. A verification field is interpreted through its service definition; it may describe retrieval integrity rather than clinical currentness. Unknown field meaning leaves that property unresolved. A source-only inspection can establish identity without appraising a later clinical claim.

If currentness remains unresolved, the assessment separates what the dated source describes from a current-practice conclusion requiring further support. The limitation changes the affected conclusion or proposed action. A calculation method and its accompanying clinical text can age differently; each has its own appraisal question.

### Web and deep research

Web retrieval and research synthesis are means of obtaining evidence. Their value depends on the underlying sources and whether those sources support the statements made. A search result, inspected page and synthesis have different coverage. Research certainty belongs to the supporting evidence rather than the format through which it was obtained.

For UK clinical, medicines, first-aid and statutory-guidance questions, retrieval targets the responsible primary publisher's own material first where it is available — for example NHS, NICE, Resuscitation Council UK, MHRA or GOV.UK/the relevant statutory or local authority source. A secondary article, blog, training page or encyclopaedia entry can be a lead to that material, not a substitute when the primary source is accessible. If primary material cannot be obtained and a secondary source is used, that limitation remains with the affected conclusion.

### Clinical research evidence

Clinical guidelines bring research together with a guideline panel's recommendations. Systematic reviews synthesise studies addressing a defined question; original studies provide the underlying observations and estimates. The certainty of a review's findings depends on the contributing evidence and its appraisal. A systematic review or meta-analysis can contain evidence of differing certainty for different outcomes. [Cochrane Handbook, chapter 14](https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-14).

#### Reading a source and assessing its research basis

A library passage or web page can be appraised for its provenance, currency, support and relevance. It may also report a published research-certainty assessment, which belongs to the stated comparison, outcome and evidence review.

A GRADE assessment concerns the body of evidence assembled for that research question. That body may contain one study or several. The appraisal depends on the study information and the applicable certainty domains; the number of retrieved pages does not determine the method. [GRADE Book: overview](https://book.gradepro.org/guideline/overview-of-the-grade-approach).

#### Certainty of evidence

GRADE describes certainty in a body of research evidence for a particular outcome and comparison. Its current formulation concerns confidence that the true value lies within a specified range or on a particular side of a meaningful threshold. The four levels form a hierarchy of confidence:

| Certainty | Meaning |
|---|---|
| High | Strong confidence in the assessed range or side of the threshold. |
| Moderate | Moderate confidence in the assessed range or side of the threshold. |
| Low | Limited confidence in the assessed range or side of the threshold. |
| Very low | Very little confidence in the assessed range or side of the threshold. |

[GRADE Book: overview](https://book.gradepro.org/guideline/overview-of-the-grade-approach).

#### Study design and final certainty

For intervention effects, randomised trials start at high certainty. Non-randomised studies conventionally start at low certainty because of potential confounding and selection bias. An alternative approach starts non-randomised evidence at high certainty and explicitly assesses those biases against an ideal trial, using a structured method such as ROBINS-I. A high starting point describes the appraisal approach, rather than an assurance about the findings.

When non-randomised evidence starts low, a large effect, a dose-response relationship, or plausible confounding that would weaken the observed effect can strengthen confidence. These considerations support upgrading when other limitations do not undermine the evidence. In the alternative high-starting approach, they can support a smaller reduction for confounding. [GRADE Book: principles](https://book.gradepro.org/guideline/principles-for-assessing-the-certainty-of-interventions).

Study design is therefore a starting point. Limitations can leave a body of randomised evidence with lower certainty than a body of non-randomised evidence. Non-randomised studies can also contribute information about rare or long-term harms that trials have not adequately captured. [Cochrane Handbook, chapter 14](https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-14).

#### Features affecting certainty

| Feature | What it concerns |
|---|---|
| Risk of bias | Distortion arising from how studies were designed, conducted, analysed or reported. |
| Inconsistency | Differences between study estimates that remain unexplained. |
| Indirectness | Differences between the research and the question of interest, including population, intervention, comparator or outcome; comparisons inferred without a direct comparison also introduce indirectness. |
| Imprecision | Uncertainty around an estimate, including whether its interval spans meaningfully different effects and whether sufficient participants and events support it. |
| Publication or dissemination bias | Available results forming an unrepresentative subset because their availability depends on what they found. |

[NICE: reviewing evidence](https://www.nice.org.uk/process/pmg20/chapter/reviewing-evidence) and [Cochrane Handbook, chapter 14](https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-14).

The effect of these concerns on certainty depends on their severity and their implications for the assessed range or threshold. Serious, very serious or extremely serious concerns can lower certainty by one, two or three levels. The detailed criteria for reductions of two or three levels are most developed for imprecision. GRADE expresses methodological judgements rather than an automatic numerical score. [GRADE Book: overview](https://book.gradepro.org/guideline/overview-of-the-grade-approach).

#### Different research questions

Evidence about diagnostic accuracy concerns measures such as sensitivity and specificity; evidence about the consequences of a testing strategy concerns patient outcomes. Suitable accuracy studies can begin at high certainty despite being observational. [GRADE Handbook, chapter 7](https://gdt.gradepro.org/app/handbook/handbook.html).

GRADE-CERQual addresses confidence in findings from qualitative evidence syntheses. Its four components are methodological limitations, coherence, adequacy of the supporting data and relevance. Confidence is described as high, moderate, low or very low for each review finding. [GRADE-CERQual](https://www.cerqual.org/overall-confidence-in-the-evidence/).

Evidence about overall prognosis estimates the risk of future events in defined groups of people. GRADE has an application to these estimates, with appraisal of the body of prognostic research. [Iorio and colleagues: GRADE for prognosis](https://www.bmj.com/content/350/bmj.h870).

Network meta-analysis combines direct and indirect comparisons between interventions. Certainty belongs to each comparison and outcome; it depends on the contributing direct and indirect evidence and their agreement. [Cochrane Handbook, chapter 11](https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-11).

#### Published recommendations

Certainty of evidence and strength of a published recommendation describe different things. Recommendation strength reflects the panel's confidence in the balance of benefits and harms, together with values and contextual considerations such as resources, equity, acceptability and feasibility. High certainty can accompany a conditional recommendation; exceptionally, a strong recommendation can accompany low certainty about some effects. [GRADE Book: recommendations](https://book.gradepro.org/guideline/grade-recommendations).

In NICE guidance, “offer” and “do not offer” indicate strong recommendations; “consider” indicates a weaker recommendation with a closer balance of benefits and harms. These words do not identify a particular GRADE certainty level. NICE presents certainty in the accompanying evidence reviews, at outcome or qualitative-finding level. [NICE: interpreting evidence](https://www.nice.org.uk/process/pmg20/chapter/interpreting-the-evidence-and-writing-the-guideline) and [NICE: reviewing evidence](https://www.nice.org.uk/process/pmg20/chapter/reviewing-evidence).

### Context from earlier notes and unverified material

An earlier SOAP can establish what a consultation recorded, including attributed reports, interpretations, advice and unfinished matters. Its dated history remains useful without making every clinical claim in it currently verified. A clinical knowledge claim returns to its underlying reference when appraisal is needed.

Background knowledge can supply possibilities or search leads. A research synthesis whose underlying support has not been examined likewise supplies unverified context. These sources do not establish a clinical claim merely through repetition. The patient's reported experience is assessed through its own provenance rather than proved by a reference book.
