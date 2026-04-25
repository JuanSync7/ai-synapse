# Companion Dispatch Protocol

Mechanical protocol for [C] Write Companions. Tells the main agent exactly how to compose, dispatch, and verify subagent work.

---

## Extracting the Companion File List

Read the SKILL.md just written at [W]. Every `Load:` declaration names companion files the skill expects at runtime. Each Load entry becomes a dispatch target.

Additionally, check:
- Does the skill have a `rules/` reference? (Always-loaded constraints — may not appear in Load declarations but still need writing)
- Does the memo anticipate companion files not yet in Load declarations? (Surface as a coherence gap back to [W])

---

## Composing a Dispatch

For each companion file, compose a subagent invocation with these inputs:

| Field | Source | Description |
|-------|--------|-------------|
| `file_path` | Load declaration | Where to write the file (relative to skill directory) |
| `file_type` | Folder convention | `reference` \| `template` \| `rule` \| `example` |
| `skill_md` | [W] output | The full SKILL.md content — subagent needs to see how the file is referenced |
| `content_brief` | Decision memo | The relevant section describing what content goes in this file |
| `writing_conventions` | `references/writing-conventions.md` | Full file — structural conventions the subagent must follow |

### Extracting Content Briefs from the Memo

The decision memo's "Companion files anticipated" section maps files to their purpose. For each dispatch:

1. Find the file in the memo's companion table
2. Use the "Purpose" column as the content brief
3. If the memo has an "Architecture details" section with relevant subsections, append that context

If no content brief exists for a file in the memo, this is a gap — do NOT dispatch with an empty brief. Instead, compose the brief from:
- The SKILL.md Load context (which node loads it, what the node does)
- The skill's overall intent from the memo's "What I want" section
- Flag to user that the brief was inferred, not explicit

---

## File Type Behavioral Differences

The `file_type` parameter tells the subagent what kind of content to produce:

| Type | Content style | Structure |
|------|--------------|-----------|
| `reference` | Teaches patterns with annotated examples. Educational tone. Domain knowledge the agent needs at a specific decision point. | Sections with explanations, good/bad contrasts, decision criteria |
| `template` | Skeleton with placeholders to fill in. Prescriptive structure. | The exact output shape with `<placeholder>` markers and inline comments |
| `rule` | Hard constraints stated as imperatives. No hedging. | Flat list of MUST/MUST NOT rules, naming conventions, format requirements |
| `example` | Complete worked example of the skill's output. No placeholders. | A realistic, filled-in instance that shows what "good" looks like end-to-end |

---

## Dispatching

1. Read `agents/skill-companion-file-writer.md` to understand the subagent's input contract
2. Dispatch all companion file subagents **in parallel** — they are independent
3. Set model explicitly on each dispatch (per MUST rule)

---

## Handling Results

### Success
Subagent writes the file and reports success. Proceed to coherence check.

### AGENT FAILURE
Subagent reports failure with specific gaps (e.g., "content brief insufficient — I need to know the exact frontmatter fields"). To retry:

1. Read the failure report — what specific information is missing?
2. Enrich the content brief with the requested information (pull from memo, conversation context, or SKILL.md)
3. Re-dispatch with the enriched brief
4. Maximum 2 retries per file. After 2 failures, surface to user with the gap description.

### Partial Failure
Some subagents succeed, some fail. Do NOT re-dispatch successful files. Only retry failures. Successful results are preserved across retry loops.

---

## Coherence Check

After all subagents report, verify every companion file against its Load declaration in SKILL.md:

1. **Existence:** Does the file exist at the declared path?
2. **Purpose match:** Does the file's content serve the purpose implied by the node that loads it? (e.g., a reference loaded at a "Write" node should contain writing guidance, not output templates)
3. **Completeness:** Does the file cover what the memo's content brief specified?
4. **Convention compliance:** Does the file follow writing-conventions.md for its type?

If any check fails → re-dispatch that file with a corrected brief describing the mismatch. This is the [C] self-loop.

If all pass → exit to [R].
