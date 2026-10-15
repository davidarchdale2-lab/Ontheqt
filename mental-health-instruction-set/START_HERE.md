# Start here: Dr Kate Aris R11-MH (mental-health draft)

**What it is.** A mental-health-only instruction set derived from Dr Seraphina Aris Health Assistant V1 R11 (`ARIS-HA-V1-R11-2026-10-07`, content revision 1). It comes in two variants.

- **Standalone** (`standalone/SYSTEM_PROMPT.md`), for an ordinary chat application.
  - Presents itself as **Dr Kate Aris**, an AI mental-health assistant.
  - Has five lenses: Psychiatry, Psychology, Pharmacist, ADHD and Autism.
  - First Aid is replaced by **Crisis Support**. It covers suicidal crisis, self-harm, possible overdose and urgent medicine-safety concerns, and gives no first-aid procedures. Any other emergency is signposted to 999.
  - A health question with no mental-health side is signposted elsewhere.
- **Harness** (`INSTRUCTION_SET.md`, `RULES_OF_ENGAGEMENT.md`), for R11's own harness.
  - Keeps R11's name (Dr Seraphina Aris), six lenses (the five above plus Doctor) and R11's First Aid.

In both variants, media production and the physical and allied-health lenses are removed, and the shared clinical engine is kept.

**Status.** Draft. Structurally checked only: not clinically reviewed, and not tested with a model. Not for clinical use.

## To use it in an ordinary chat application (no harness)

1. Paste the whole of `standalone/SYSTEM_PROMPT.md` into the application's system prompt.
2. Read `USING_WITHOUT_A_HARNESS.md`. It covers:
   - what works without a harness;
   - how continuity summaries replace saved records;
   - the size the model needs;
   - the safety notes.

## Other files

- `MODULES.md`: what changed from R11, module by module, including the standalone edits.
- `README.md`: contents and how to rebuild or repackage.
- `standalone_src/`: the texts written for the standalone variant (deployment facts, Crisis Support, Operations).
- The repository folder also holds the harness variant (`INSTRUCTION_SET.md`, `RULES_OF_ENGAGEMENT.md`, `HARNESS_REQUIREMENTS.md`, and the First Aid review dates in `deployment/`). None of it is needed for standalone use.

**Verify the files.** Inside the extracted zip, run `sha256sum -c SHA256SUMS.txt`.
