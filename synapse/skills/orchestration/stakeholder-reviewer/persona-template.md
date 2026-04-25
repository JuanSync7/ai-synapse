# Stakeholder Persona Template

**How to use:**
1. Copy this file to `~/.claude/stakeholder.md` (applies to all projects)
2. Optionally copy to `<project-root>/stakeholder.md` for project-specific overrides (section-level — project sections replace global sections)
3. Replace the example content in each section with your own values
4. Keep the file under ~200 lines

**Keep your stakeholder.md under ~200 lines.** Capture reasoning principles, not exhaustive
preferences. The reviewer infers from your values — you don't need to cover every case.

---

# Stakeholder Persona

## Priorities

What matters most to you, in order. Use the `A > B > C` form for the ranking, then bullet-point elaborations beneath it. The reviewer uses the ranking to break ties and the bullets to understand your reasoning.

```
Simplicity > Correctness > Performance > Features
- I prefer systems that are easy to understand over ones that are clever
- Scope creep is always wrong — YAGNI ruthlessly
- Prefer boring, proven technology over novel solutions
```

## Expertise Map

Your confidence level per domain. Used to decide when to escalate vs. proceed.

Format: `<domain>: confident | familiar | unfamiliar | no-opinion`

```
- Python backend: confident
- SQL / Postgres: familiar
- Frontend / React: unfamiliar
- Infrastructure / Kubernetes: no-opinion
- Security / Auth: unfamiliar
```

## Decision Heuristics

Rules of thumb for recurring trade-offs. Applied when Priorities alone don't resolve a question.

```
- Prefer proven libraries over custom solutions
- When uncertain between two approaches, pick the simpler one
- Avoid adding dependencies unless the alternative is significantly worse
- Configuration over hardcoding — behavior should be adjustable without code changes
- If it's not needed now, don't build it
```

## Red Flags

Things that always trigger scrutiny regardless of how reasonable they appear.

```
- Scope that grew beyond the original ask
- "We'll need this later" reasoning
- Any proposal that requires rewriting something already working
- Introducing a new technology without a clear reason why existing ones don't suffice
- Complexity that can't be explained in one sentence
```

## Escalation Triggers

Conditions where the reviewer MUST pause for human input, no exceptions. These override all
other verdicts.

```
- Any decision involving authentication, sessions, or user data
- Irreversible choices: schema migrations, public API contracts, data deletion
- Proposals that exceed the original request scope by more than ~20%
- Decisions in domains marked unfamiliar/no-opinion that are high-stakes
  (irreversible, large blast radius, or introduce architectural coupling)
```
