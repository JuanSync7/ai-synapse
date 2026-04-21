---
name: skill-router
description: "Routes to specialized skills from the ai-skills repository. Use when the user's request matches a known skill domain but no installed skill covers it. Does NOT activate for general coding, debugging, git operations, or conversation."
domain: meta
intent: route
tags: [router, discovery, lazy-load]
user-invocable: false
argument-hint: ""
---

# Skill Router

The only skill that must be installed. All other skills live in the ai-skills repository and are loaded on demand — one at a time, when the user's request matches.

Loading 20+ skills at session start wastes context budget. Most requests need zero or one skill. The router classifies the request against a known domain vocabulary, reads one README to find the skill, then loads it.

> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.

## Repo Location

The ai-skills repository root is the **real path two directories above this file.** Resolve this SKILL.md's symlink to find the repo:

```
this file → ~/.claude/skills/skill-router/SKILL.md (symlink)
real path → <repo>/meta/skill-router/SKILL.md
repo root → <repo>/
```

If the symlink is broken or the repo is missing, tell the user: "ai-skills repo not found — run `scripts/install.sh install meta/skill-router` from the repo root."

## Wrong-Tool Detection

- **User wants to run a specific installed skill** → that skill handles it directly; the router does not interfere
- **User asks how to create a new skill** → this is a skill-creator task, not a routing task. Route to `meta/skill-creator` if not installed, but do not attempt to create skills yourself.
- **User asks to improve or evaluate a skill** → route to `meta/improve-skill` or `meta/write-skill-eval`
- **User asks to run an autonomous pipeline** → route to `orchestration/autonomous-orchestrator`

## Domain Vocabulary

> **Read [`../../SKILL_TAXONOMY.md`](../../SKILL_TAXONOMY.md)** at session start to internalize the domain and intent vocabulary. If SKILL_TAXONOMY.md is missing or unreadable, fall back to directory names as the domain vocabulary — list `<repo>/` and use directory names (`docs/`, `code/`, `meta/`, etc.) as domain hints.

Use this vocabulary to classify every request before routing. The domain tells you which directory to look in; the intent tells you which skill within that directory to pick. The mapping from domain to directory:

| Domain prefix | Directory |
|---------------|-----------|
| `docs.*` | `docs/` |
| `code.*` | `code/` |
| `meta.*` | `meta/` |
| `orchestration` | `orchestration/` |
| `creative` | `creative/` |
| `frameworks.*` | `frameworks/` |

If the request doesn't map to any domain, **stop — proceed without any skill.**

## Routing Algorithm

### Step 1: Classify the request

Using the domain vocabulary, determine the domain and intent. This is a judgment call, not a string match — the user won't say "docs.spec + write", they'll say "write me a spec for the auth system."

**Example:** User says "I need a formal spec for the auth system."
→ Domain: `docs.spec`, Intent: `write` → directory: `docs/`

**Example:** User says "help me design a LangGraph workflow for document processing."
→ Domain: `frameworks.langgraph`, Intent: `write` → directory: `frameworks/`

**Example:** User says "fix the bug in auth.py"
→ No domain match → **stop, no skill needed.**

If the classification is ambiguous (could be two domains), prefer the more specific one. If genuinely unclear, go to Step 2 with both candidates.

### Step 2: Read the domain README

Read `<repo>/<directory>/README.md`. It contains a skill table with names, intents, and one-line descriptions. Pick the best-matching skill from the table.

If no skill matches, try the next candidate domain. If all exhausted, **stop — proceed without any skill.**

### Step 3: Confirm via frontmatter

Read the first 10 lines of `<repo>/<directory>/<skill-name>/SKILL.md` to confirm the `description:` field matches the user's request. The description lists trigger conditions — if the user's phrasing doesn't match, go back to the README and try the next candidate.

### Step 4: Load and follow

Read the full SKILL.md. Before executing, tell the user:

> Using **`<skill-name>`** from ai-skills. To install permanently for `/slash-command` access: `./scripts/install.sh install <domain>/<skill-name>`

Then follow the skill's instructions as if it were installed directly. Load any companion files it references (templates/, references/, rules/, examples/) using paths relative to the skill's directory.

## Suggestion Mode

When the user describes a complex task or goal — especially during planning or brainstorming — proactively suggest relevant skills rather than silently loading one. Present a short list:

> Based on what you're describing, these skills might help:
> 1. **write-spec-docs** — formal requirements specification
> 2. **write-design-docs** — technical design with task decomposition
>
> Want me to load one, or proceed without a skill?

Use suggestion mode when:
- The task is broad and could map to multiple skills
- The user is thinking out loud, not giving a direct instruction
- The user hasn't worked with the skill repo before (first session)

Use direct loading (Steps 1-4) when:
- The request clearly maps to one skill
- The user names a skill or uses language that matches a trigger exactly

## Co-existence with Installed Skills

The user may permanently install frequently-used skills alongside this router. Those skills get `/slash-command` discovery and appear in the session's skill list at boot.

**When a request matches an already-installed skill:** that skill handles it directly — the router does not interfere. The router only activates for requests that no installed skill covers.

**Recommended setup:** Install the router + the 3-5 skills used daily. The router handles the long tail.

## Routing Rules

- **One skill per request.** Never load multiple skills simultaneously — context budget is finite.
- **No routing on simple requests.** If the user asks a question, writes basic code, or has a conversation that no skill covers — respond normally. The router adds value only when a specialized skill exists.
- **Prefer exact trigger match.** A skill's frontmatter `description:` lists its trigger conditions. If the user's phrasing doesn't match any trigger, don't force it.
- **User can name a skill directly.** If the user says "use write-spec-docs" or references a skill by name, skip Steps 1-2 — resolve the skill's path from the domain README and load it.

## When NOT to Route

- General coding tasks (write a function, fix a bug, refactor)
- Simple questions about the codebase
- Git operations (commit, PR, branch management)
- Conversation, planning, or brainstorming that doesn't need a structured output
- Tasks already handled by Claude Code's built-in capabilities

The router's job is to stay out of the way when no skill helps, and to load the right skill fast when one does.
