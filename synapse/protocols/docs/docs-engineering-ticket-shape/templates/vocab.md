---
name: <epic-name>-vocab
type: vocab
description: Canonical term definitions for <epic-name>
version: 1
---

# Vocabulary

Each term has a structured YAML block (validator-readable) followed by a markdown gloss (human-readable). epic.md, engineering_guide.md, and stories MUST cite terms from this file. They MUST NOT redefine terms locally.

If a term changes meaning, update this file in place. NEVER maintain divergent definitions across artifacts.

---

```yaml
term: <term-name>
category: noun | verb | system | actor | constraint
```

**<Term Name>** — <1-3 sentence definition in context. Specific enough that a reader can use the term consistently. Reference other vocab terms inline where helpful.>

---

```yaml
term: <another-term>
category: noun
```

**<Another Term>** — <definition>

---

<!--
Template usage notes:

- Categories:
  - `noun` — a domain object (e.g., "Job", "Envelope", "Subscription")
  - `verb` — a domain action (e.g., "Enqueue", "Reconcile")
  - `system` — a named subsystem or service (e.g., "Scheduler", "Worker Pool")
  - `actor` — a role that interacts with the system (e.g., "Operator", "Client SDK")
  - `constraint` — a named invariant or rule (e.g., "At-Least-Once Delivery")

- Term names use Title Case in the gloss heading and lowercase-hyphenated in the YAML `term:` field.
- Keep glosses tight (1-3 sentences). Long explanations belong in design.md or engineering_guide.md.
- The YAML block MUST appear before the gloss. Validators parse the YAML; humans read the gloss.
- Separate each term entry with a horizontal rule (`---`) so the YAML blocks are unambiguous to parsers.
- DO NOT inline definitions in epic.md, story.md, or engineering_guide.md — link or reference by name only.
-->
