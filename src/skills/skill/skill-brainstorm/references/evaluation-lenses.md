# Evaluation Lenses

Five lenses for Phase B pressure-testing. Each lens focuses on a different dimension of skill quality. Not every lens applies to every brainstorm — select based on skill type.

## The Five Lenses

### Usability
**Core question:** Will a user know when and how to invoke this skill?

**Diagnostic questions:**
- "What phrase would a user actually say to trigger this?"
- "If someone reads only the description, will they know this is the right skill?"
- "Is the output format what the user would expect, or will they be surprised?"
- "Does the skill name communicate what it does?"

**Catches:** Bad triggers, confusing descriptions, unclear output format, wrong audience assumptions.

### Robustness
**Core question:** What happens when things go wrong or sideways?

**Diagnostic questions:**
- "What if the input is ambiguous or incomplete?"
- "What if the user provides partial information?"
- "What happens with adversarial or edge-case input?"
- "What if a dependency (file, API, sibling skill) is missing or broken?"
- "What's the failure mode — silent garbage or loud error?"

**Catches:** Edge cases, ambiguous input handling, missing preconditions, silent failures, unhandled error paths.

### Maintenance
**Core question:** Will this skill survive codebase and ecosystem evolution?

**Diagnostic questions:**
- "Is this coupled to something that changes frequently?"
- "If a sibling skill is renamed or removed, does this break?"
- "Will this still make sense in 6 months?"
- "Does this reference specific file paths, API versions, or tool names that could drift?"

**Catches:** Brittle coupling, hard-coded assumptions, temporal drift, stale references, version lock-in.

### Preciseness
**Core question:** Is every token in this skill earning its place?

**Diagnostic questions:**
- "Could you remove this instruction and get the same output?"
- "Is this something Claude already knows from training?"
- "Could you say this in half the words without losing the judgment?"
- "Is this a decision or an option list? Skills should state decisions."

**Catches:** Bloat, redundancy, instructions that don't change behavior, teaching what training already covers, documentation disguised as context injection.

### Boundary
**Core question:** Where does this skill stop and something else start?

**Diagnostic questions:**
- "What's the adjacent skill that handles the next thing?"
- "What happens when someone invokes this but actually meant a sibling?"
- "Is the scope creeping into territory another skill owns?"
- "Can you write the boundary sentence: 'This skill does X; [sibling] does Y'?"

**Catches:** Scope creep, sibling overlap, routing misfires, unclear handoffs, missing Wrong-Tool Detection entries.

## Lens Selection by Skill Type

Not all lenses are equally important for every skill. Prioritize based on type:

| Skill type | Primary lenses | Why |
|-----------|---------------|-----|
| Workflow/orchestration | Boundary + Robustness | Multi-step flows break at boundaries and error paths |
| Formatting/output | Usability + Preciseness | Output shape and token efficiency matter most |
| Domain knowledge | Maintenance + Preciseness | Domain facts drift; knowledge injection must earn its tokens |
| Discipline-enforcing | Robustness + Boundary | Agents rationalize past soft constraints; scope must be airtight |

Apply all five lenses, but spend more time on the primary ones for the skill type.
