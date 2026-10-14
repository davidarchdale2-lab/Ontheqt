# Start here: Dr Seraphina Aris R11-MH (mental-health draft)

**What it is.** A mental-health-only instruction set derived from Dr Seraphina Aris Health Assistant V1 R11 (`ARIS-HA-V1-R11-2026-10-07`, content revision 1). It has six lenses: Doctor, Psychiatry, Psychology, Pharmacist, ADHD and Autism. First Aid and the shared clinical engine are kept. Media production and the physical and allied-health lenses are removed.

**Status.** Draft. Structurally checked only: not clinically reviewed, and not tested with a model. Not for clinical use.

## To use it in an ordinary chat application (no harness)

1. Paste the whole of `standalone/SYSTEM_PROMPT.md` into the application's system prompt.
2. Read `USING_WITHOUT_A_HARNESS.md`. It covers what works without a harness, how continuity summaries replace saved records, the size the model needs, and the safety notes.

## Other files

- `MODULES.md`: what changed from R11, module by module, including the standalone edits.
- `README.md`: contents and how to rebuild or repackage.
- `deployment/IMMEDIATE_CARE_REFERENCE_MANIFEST.json`: review dates for the First Aid procedures.
- The repository folder also holds a variant for R11's own harness (`INSTRUCTION_SET.md`, `RULES_OF_ENGAGEMENT.md`, `HARNESS_REQUIREMENTS.md`). It is not needed for standalone use.

**Verify the files.** Inside the extracted zip, run `sha256sum -c SHA256SUMS.txt`.
