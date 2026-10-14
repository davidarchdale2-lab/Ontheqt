# Using the set without a harness

`standalone/SYSTEM_PROMPT.md` is the whole instruction set as one system prompt, for an ordinary chat application with no harness, tools or record store.

It is a mental-health assistant. It covers mental health, including ADHD and autism, through five lenses: Psychiatry, Psychology, Pharmacist, ADHD and Autism.

- **Physical health.** Considered only where it may cause, mimic or complicate a mental-health difficulty, or concerns a relevant medicine. A question with no mental-health side gets a brief signpost to the GP, a pharmacist or NHS 111.
- **Crisis Support.** It handles:
  - suicidal crisis and self-harm;
  - possible overdose, intentional or by mistake;
  - missed or stopped medicines;
  - urgent mental-health routes.
- **No first aid.** The prompt contains no first-aid procedures. Any other emergency is signposted to 999, and the 999 call handler gives any instructions.

## How to use it

1. Open the chat application's system prompt setting. It may be called "system prompt", "system message" or "custom instructions".
2. Paste the entire contents of `standalone/SYSTEM_PROMPT.md`. Do not trim it: the Grid is repeated at the end on purpose, and the Rules come first on purpose.
3. Start a new conversation. The assistant opens with its introduction, or answers straight away if the first message is already a question.

**Size.** The prompt is about 189 KB, roughly 26,900 words. As a rough guide, the model needs a context window well above 50,000 tokens, plus room for the conversation itself. Check the setting in your application. For a local model, set its context length explicitly, because many runners default to something much smaller and silently cut long prompts.

## What changes without a harness

| Harness feature | Without a harness |
|---|---|
| Registered users, record lookup, persistent memory | None. A name is only a name. To continue earlier work, paste the continuity summary from a previous conversation. |
| Saving SOAP notes, plans, audits and summaries | Records are written out in the chat for you to copy and keep. The assistant is told never to say anything was saved. |
| Full medical-file reading with permission | Not applicable. The assistant works only with what you paste or attach. |
| Reminders and calendar | None. The assistant can suggest wording for a reminder you set yourself. |
| Medical library and web search | None. Doses, thresholds and guideline details cannot be checked against a current source, and the assistant is told to say so. |
| Calculator | None. The assistant does not work out a dose, interval, taper or any other figure you would act on for treatment; it gives the method and inputs for a pharmacist or prescriber to use. A descriptive figure, such as an average of readings you supply, is shown with its method as an unverified estimate. |
| Per-turn Grid and case-state injection | The Grid is included twice in the prompt, at the start of the core and at the end, which is what R11 itself does for models without the special placement. The working picture lives in the conversation. |

If your chat application can read attached files, the assistant may use that for its actual purpose. The prompt tells it to report what it read and what it could not.

## Continuity between conversations

At the end of a consultation, ask for a **continuity summary**, or accept the assistant's offer of one. Save it yourself. Next time, paste it at the start. The assistant treats it as material you supplied, notes its date, and asks what has changed.

## Safety notes

- **Added safety content needs checking.** The standalone variant adds content that is not from R11, written for this set:
  - the Crisis Support module, apart from its suicidal-threat and poisoning guidance, which is adapted from R11's First Aid;
  - no treatment figures and no harmful-amount information;
  - routing for a possible overdose, intentional or by mistake, and for a missed or stopped medicine;
  - routing for self-harm that has happened, and for someone who cannot keep themselves safe;
  - safeguarding steps, with helplines for each UK nation;
  - an urgent mental-health route (NHS 111 and its mental-health option, NHS 24, Lifeline in Northern Ireland, Samaritans, Shout);
  - guidance for people outside the UK;
  - the scope rule for questions with no mental-health side;
  - routing of a suspected physical cause, and of a medical question in a safeguarding disclosure, to the GP, NHS 111 or 999 in place of R11's Doctor lens;
  - the UK services note (NHS 24 in Scotland; no NHS 111 in Northern Ireland);
  - the replacement medicine examples in the Pharmacist lens.

  Every telephone number and service name in it must be checked against its publisher before use.

- **Draft, not for clinical use.** The clinical content has not been clinically reviewed for this set, and R11 states its source currency was not revalidated.
- **No safety layer except the instructions.** Without a harness there is nothing between the model and the person. Safety rests entirely on this prompt and on the model's own behaviour.
- **Choice of model.** R11 was built for a local model named `Qwen3.8-27B-Heretic-ARA-exl3-6bpw-h16`. That name follows the naming used for open models whose refusal behaviour has been removed. Running a refusal-removed model directly, with no harness, for mental-health conversations leaves no safeguard except this prompt. Confirm what that model is before using it, and prefer a model with intact safety training.
- **UK emergency routes.** Crisis Support signposts 999, NHS 111, NHS 24, Lifeline, Samaritans (116 123) and Shout. In Northern Ireland, which has no NHS 111, the prompt points to the GP, the GP out-of-hours service or A&E instead. For a person outside the UK, the assistant gives the immediate action and points to their local emergency number (112 across the EU), a local crisis line, or a local poison information service, doctor or pharmacist. For regular use outside the UK, the numbers in the prompt would need changing.
- **No physical first aid.** The assistant will not talk anyone through first aid. In an emergency it signposts 999, and the call handler gives instructions.
- **Privacy.** The chat application may keep conversation history on its own servers or device. That is outside the assistant's control. Paste only what you are comfortable storing there.

## Changing the prompt

Do not edit `standalone/SYSTEM_PROMPT.md` by hand; it is regenerated.

- To change the wording written for standalone use, edit `standalone_src/DEPLOYMENT_FACTS.md`, `standalone_src/CRISIS_SUPPORT.md` or `standalone_src/OPERATIONS.md`.
- To change the other standalone edits, edit the `standalone_*` functions in `tools/build_mental_health_set.py`.

Then rebuild (see `README.md`).
