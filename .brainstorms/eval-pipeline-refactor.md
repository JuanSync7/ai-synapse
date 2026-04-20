# Brainstorm Notes — EVAL Pipeline Refactor

## Status
Phase: B
Outcome: pending (multi-skill architecture refactor + new concepts: agents, protocols)

## Resolved

- **EVAL.md has 4 sections:** Structural, Execution, Output, Test Prompts. Complete.
- **Execution criteria are a real tier (EVAL-E).** Added E01-E05 to write-test-coverage as proof of concept.
- **Agent vs Skill boundary:** User-invocable = skill. Internal recipe dispatched by skills = agent definition in `src/agents/`. Symlinked into consumer skills.
- **Demote to agent definitions:** skill-eval-judge, skill-eval-prompter. New: skill-eval-auditor.
- **Metaphor:** Skill = recipe (user-facing). Agent definition = recipe (internal). LLM instance = cook. Subagent = cook delegated by another cook.
- **Execution trace is NOT an agent.** It's a protocol — a form the cook fills out when asked. Lives in `src/protocols/`, not `src/agents/`.
- **Trace is a toggle/switch.** Not baked into every execution. Observer (improve-skill, user, auto-research) injects it when needed. Like turning on a security camera.
- **Trace is Langfuse-equivalent for Claude Code.** Claude has no built-in observability like LangGraph+Langfuse. Protocols fill that gap as a convention.
- **Nesting:** configurable setting (shallow by default, deep when needed).
- **Cost:** let traces grow — full visibility, no caps. Half-visibility defeats the purpose.
- **Persistence:** traces written to file for review (like `research/traces/`).
- **Decision + Context traces:** yes, future trace types beyond execution.

## Open Threads

1. **What other protocols exist?** Need to identify the full `src/protocols/` inventory.
2. **Trace file format and storage location.** Where do persisted traces go?
3. **How does improve-skill consume traces for EVAL-E grading?**
4. **LangGraph migration path.** Protocols → node middleware. Agent definitions → node prompt templates.
5. **Structural criteria: agent or stays hardcoded in improve-skill?**

## Key Insights

- Trace protocol is Claude Code's answer to Langfuse/LangSmith. No built-in observability, so conventions fill the gap.
- Three categories emerged: Skills (user-facing recipes), Agents (internal recipes), Protocols (shared conventions/schemas injected into agents).
- "Too many skills" problem solved by proper categorization — not everything is a skill.
- Trace as a toggle means zero overhead in normal execution, full observability when debugging.

## Tensions

- **Protocols are a new top-level concept.** Adds repo complexity. But the alternative is burying shared conventions inside individual skills (not DRY, not discoverable).
- **Self-reported traces.** Cook reports on itself — no external monitor. Trustworthy for LLMs following instructions, but not independently verifiable.

## Discarded

- **Expand skill-eval-judge for execution criteria.** Persona conflict.
- **New standalone skill for execution criteria.** Overhead for always-dispatched workload.
- **Absorb improve-skill into skill-creator.** Different lifecycles.
- **skill-creator as argument router.** Already too complex.
- **Trace as permanent agent output.** Wasteful — toggle instead.
- **Trace format inside improve-skill only.** Not shared — multiple consumers need it.
- **report-execution-trace.md as an agent.** It's not a cook, it's a form.
