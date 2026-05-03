# Skill Progress Tasks

Seed list for task tracking. At [NEW], create one task per entry below using the harness task mechanism. Mark each task `in_progress` when its node begins and `completed` when its node exits successfully.

---

- [ ] **[E] Update epic** — Dispatch epic writer; verify epic.md stays declarative and vocab.md is current
- [ ] **[F] Decompose FRs** — Dispatch FR decomposer; verify roster ids are monotonic + unique, all tmp context files conform to schema
- [ ] **[G] Gate: confirm FR roster** — Present roster summary to human; wait for explicit confirmation before proceeding
- [ ] **[S] Dispatch stories** — Build wave DAG from roster edges; fan out story-writer per wave; retry failures once; surface any skip batch
- [ ] **[V] Regenerate eng-guide** — Compute touches union; dispatch eng-guide writer; verify regenerated_at frontmatter and no FR references in primary content
- [ ] **[R] Review eng-guide** — Dispatch eng-guide reviewer; reconcile ambiguous removals or escalate on second failure
