# Start here: Dr Seraphina Aris R11-MH (mental-health draft)

**What it is.** A mental-health-only instruction set derived from Dr Seraphina Aris Health Assistant V1 R11 (`ARIS-HA-V1-R11-2026-10-07`, content revision 1). It has six lenses: Doctor, Psychiatry, Psychology, Pharmacist, ADHD and Autism. First Aid, the shared clinical engine and the record tools are kept. Media production and the physical and allied-health lenses are removed.

**Status.** Draft. Structurally checked only: not clinically reviewed, not loaded into a model, not installed. Not for clinical use.

**Load order in the R11 bridge.** `RULES_OF_ENGAGEMENT.md` (section order -499), then `INSTRUCTION_SET.md` (order 100), each hash-checked separately. Then the transient case state and the per-turn Grid. The per-turn Grid's extraction rule and hash are in `BUILD_CHECKS.json`.

**Read next.**

1. `HARNESS_REQUIREMENTS.md`, sections 8 (safety-critical) and 10 (decisions).
2. `MODULES.md`: what changed from R11, module by module.
3. `README.md`: contents and how to rebuild.

**Verify the files.** `sha256sum -c SHA256SUMS.txt`
