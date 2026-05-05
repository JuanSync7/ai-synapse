# synapse/ Framework Backlog

Non-binding backlog of framework-level ideas surfaced during alpha cleanup. Items here are *captured*, not *committed* — promote to a real skill, agent, or design doc when ready to build.

---

## adopter-CI-template (skill + workflow templates)

**Problem.** ai-synapse's quality bar has two tiers: Tier 1 (structural, deterministic, runs in `.githooks/pre-commit`) and Tier 2 (quality, LLM-judged via `/synapse-gatekeeper`). Today only Tier 1 is enforced automatically — Tier 2 is manual at PR time. Adopter teams have no turnkey way to wire `/synapse-gatekeeper` into their PR workflow, so quality validation depends on whoever remembers to run it.

**Proposal.** Ship a thin skill `adopter-ci-template` that scaffolds portable CI workflow files into an adopter repo. Plus the templates themselves under `templates/ci/` at repo root.

**Shape.**

| Layer | Mechanism | LLM needed? |
|-------|-----------|-------------|
| Tier 1 (structural) | GitHub Action that runs `.githooks/pre-commit` on changed files | No |
| Tier 2 (quality) | GitHub Action that, on changed-artifact PRs, dispatches a configurable LLM CLI (`claude --headless`, `codex`, `gemini`, etc.) to run `/synapse-gatekeeper` and posts the verdict as a PR comment | Yes — but CLI is swappable |

**Open design questions** (need brainstorm before building):
1. Which CI providers to support out-of-box? (GitHub Actions only is the realistic v1; GitLab/CircleCI as templates only)
2. What's the LLM CLI contract? Define a minimal interface (input: artifact path; output: verdict text) and let adopters plug in their preferred CLI.
3. How is the gatekeeper verdict transported? PR comment vs check-run vs gate-required-status.
4. Where does the LLM API key live? OIDC vs repo secrets vs adopter's own runner.
5. Should pre-commit (local) also offer a Tier 2 option for those willing to wait for LLM round-trip? Probably no — pre-commit must stay fast.

**Why not now.** The blast radius (which CIs, which CLIs, what verdict transport) is broad enough that brainstorming first will save building twice. Not a blocker for alpha.

**Owner / unblocker.** Brainstorm via `/synapse-brainstorm adopter-ci-template`, then build.

---

## (template — copy this when adding a new backlog item)

### <kebab-case-name>

**Problem.** What gap or pain motivates this.

**Proposal.** One paragraph on the shape — skill / agent / protocol / tool / docs / etc.

**Open design questions.** What needs brainstorming before building.

**Why not now.** Why this is captured but not staged.

**Owner / unblocker.** Who decides when this lands, or what unblocks it.
