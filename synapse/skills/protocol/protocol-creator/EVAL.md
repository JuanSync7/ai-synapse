# Protocol Creator — Evaluation Criteria

## Structural Criteria

(From improve-skill's baseline checklist — no need to duplicate here)

## Execution Criteria

- [ ] **EVAL-E01:** Phase 1 gate enforced before drafting
  - **Test:** Verify the trace shows the Phase 1 gate checklist was evaluated and all 5 conditions confirmed true before any Phase 2 drafting activity began.
  - **Fail signal:** Protocol draft appears in the trace before gate conditions are confirmed, or gate is skipped when anchors are still ambiguous.

- [ ] **EVAL-E02:** Decision memo fast-path triggers correctly
  - **Test:** When a decision memo path is provided as input, verify the trace shows the memo was read, evaluated against the 5 gate conditions, and — if all conditions were met — Phase 2 began without re-eliciting anchors from the user.
  - **Fail signal:** Anchors are re-elicited interactively even though the memo already satisfied all gate conditions, or the memo is ignored and elicitation proceeds from scratch.

- [ ] **EVAL-E03:** Protocol review agent dispatched with correct model
  - **Test:** Verify the trace shows an Agent() call to `agents/protocol-signal-reviewer.md` using `model: sonnet` with the drafted protocol file as input.
  - **Fail signal:** Review agent is not dispatched (inline review substituted instead), or the dispatch omits the model specification.

- [ ] **EVAL-E04:** Re-dispatch on review failure, two-cycle cap honored
  - **Test:** When the first review cycle returns failing checks, verify the trace shows the protocol was revised and the agent was re-dispatched for a second cycle. Verify that after two failing cycles the remaining issues are surfaced to the user rather than a third dispatch occurring.
  - **Fail signal:** Failing checks are ignored and the skill advances to Phase 4 without re-dispatch, or more than two dispatch cycles occur without user escalation.

- [ ] **EVAL-E05:** Phase gate blocks progression on incomplete anchors
  - **Test:** When any of the 5 Phase 1 gate conditions is false (e.g., an anchor is still vague), verify the trace shows a specific clarifying question issued and Phase 2 not entered.
  - **Fail signal:** The skill silently guesses through an underspecified anchor and proceeds to drafting, or a generic question is asked instead of one tied to the specific failing condition.

## Output Criteria

- [ ] **EVAL-O01:** Frontmatter contains all five required fields
  - **Test:** Parse the YAML frontmatter block of the output protocol file. Verify the keys `name`, `description`, `domain`, `type`, and `tags` are all present.
  - **Fail signal:** One or more of the five keys is absent from the frontmatter block.

- [ ] **EVAL-O02:** `description` field is a trigger/routing contract, not a summary
  - **Test:** Read the `description` value. Check whether it answers "when does this protocol fire?" without describing the protocol's internal mechanics or restating the contract rules. If the description could substitute for reading the protocol body, it fails.
  - **Fail signal:** Description says what the protocol does ("validates parameters and logs failures") rather than naming the condition under which it fires ("fires when an agent receives external input before processing").

- [ ] **EVAL-O03:** `domain` and `type` values exist in PROTOCOL_TAXONOMY.md
  - **Test:** Read `PROTOCOL_TAXONOMY.md`. Confirm the exact strings in the protocol's `domain` and `type` frontmatter fields appear as entries in the Domains and Types tables respectively.
  - **Fail signal:** Either value does not appear in PROTOCOL_TAXONOMY.md, or appears to be invented (not registered in the taxonomy).

- [ ] **EVAL-O04:** Mental model section is exactly one paragraph and explains WHY, not HOW
  - **Test:** Locate the body text before the `## Contract` heading. Count the paragraphs. Verify there is exactly one. Then read it and check: does it explain the behavioral gap or failure mode the protocol prevents? Does it restate any contract rule verbatim?
  - **Fail signal:** More than one paragraph present, OR the paragraph contains an imperative instruction that belongs in the Contract section, OR it describes workflow steps rather than the motivation.

- [ ] **EVAL-O05:** Every contract instruction uses commitment language
  - **Test:** Locate every sentence in the `## Contract` section. For each sentence that imposes a behavioral rule, verify it contains at least one of: MUST, NEVER, STOP, DO NOT, BEFORE, AFTER, THEN. Count any sentences that impose a rule without commitment language.
  - **Fail signal:** Any rule-imposing sentence uses hedging language (should, try to, prefer, ideally, consider, may) without a MUST/NEVER/STOP anchor.

- [ ] **EVAL-O06:** Every contract instruction names a specific trigger moment
  - **Test:** For each instruction in `## Contract`, identify the trigger condition. Verify the trigger is a named, observable moment (e.g., "BEFORE returning any response", "AFTER modifying a file in src/") rather than a fuzzy condition.
  - **Fail signal:** Any instruction contains "when appropriate", "as needed", "when necessary", or any other trigger that is not a named, observable moment.

- [ ] **EVAL-O07:** Contract section contains no banned words
  - **Test:** Read the full text of `## Contract` and `## Failure Assertion` sections. Check for the presence of any banned tokens: consider, may want to, appropriate, ideally, when possible, should consider, it's recommended, generally, optionally, could, might, perhaps, arguably, "when appropriate", "as needed", "if desired", "best practice", "try to", "aim to", "prefer X over Y".
  - **Fail signal:** Any banned word or phrase from `rules/banned-words.md` appears in the Contract or Failure Assertion sections.

- [ ] **EVAL-O08:** Failure Assertion section is present and uses the required tag format
  - **Test:** Verify a `## Failure Assertion` section exists. Verify it contains an instruction that produces the string `PROTOCOL FAILURE: <protocol-name> —` followed by a specific reason. Verify the protocol name in the tag matches the `name` frontmatter field exactly.
  - **Fail signal:** Section is absent, OR the tag format deviates from `PROTOCOL FAILURE: <protocol-name> — [reason]`, OR the name in the tag does not match the frontmatter `name` field.

- [ ] **EVAL-O09:** Protocol addresses exactly one behavioral concern
  - **Test:** List all distinct trigger moments in the Contract section. Determine whether removing any one contract instruction would leave the remaining instructions coherent and independently useful. If two independent trigger moments exist, the protocol contains multiple concerns.
  - **Fail signal:** The protocol contains two or more independent trigger moments, or the Contract section enforces behaviors that would each make sense in isolation in a different protocol.

- [ ] **EVAL-O10:** Protocol is within the 30–120 line budget
  - **Test:** Count the total lines in the protocol `.md` file from the opening `---` of the frontmatter to the final line of content, inclusive.
  - **Fail signal:** Line count is below 30 or above 120.

- [ ] **EVAL-O11:** Protocol contains no prohibited sections
  - **Test:** Scan all section headings in the protocol file. Verify none of these headings or equivalents are present: "Injection", "How to Use", "Examples", "Consumers", "Trigger", "Usage". Also verify the body contains no prose explaining how to load the protocol.
  - **Fail signal:** Any prohibited section is present, OR the body contains a paragraph instructing consumers how to inject or load the protocol.

- [ ] **EVAL-O12:** Configuration section, if present, has a default value for every mode
  - **Test:** If a `## Configuration` section exists, locate the mode table. For every row, verify the `Default` column contains an explicit value.
  - **Fail signal:** A mode row exists with a blank or missing Default column value, OR the Configuration section is present but the table has no rows.

- [ ] **EVAL-O13:** `tags` values are all lowercase and hyphenated
  - **Test:** Read the `tags` array from frontmatter. For each tag, verify it contains only lowercase letters, digits, and hyphens — no underscores, spaces, or uppercase characters.
  - **Fail signal:** Any tag contains an uppercase letter, underscore, or space.

- [ ] **EVAL-O14:** Mental model does not restate contract rules
  - **Test:** Extract every imperative instruction from the `## Contract` section. Check whether any of those exact instructions or paraphrases appear in the mental model paragraph.
  - **Fail signal:** The mental model paragraph contains a sentence that functions as a behavioral rule (contains MUST, NEVER, DO NOT, STOP) and that rule also appears in the Contract section.

- [ ] **EVAL-O15:** Protocol file is placed under `src/protocols/<concern>/` with correct naming
  - **Test:** Verify the output file path matches the pattern `src/protocols/<concern>/<protocol-name>.md` where `<protocol-name>` matches the frontmatter `name` field exactly and uses only lowercase letters and hyphens.
  - **Fail signal:** File is placed outside `src/protocols/`, or the filename does not match the frontmatter `name` field, or the filename contains uppercase characters or underscores.

## Test Prompts

### Naive User: Vague contract request

**Prompt:** "can you build a protocol for when agents need to hand off work to each other? like when one finishes and another needs to pick up"

**Why this tests the skill:** Tests whether the skill can elicit enough specificity from an underspecified request to produce a usable behavioral contract rather than a generic template.

---

### Naive User: Domain confusion

**Prompt:** "I want a protocol for my AI agents that are doing research. they keep producing different formats and it's a mess. help"

**Why this tests the skill:** Tests whether the skill correctly scopes "protocol" to inter-agent behavior (output schema, handoff contracts) rather than drifting into prompt engineering or data pipeline advice.

---

### Naive User: Terminology mismatch

**Prompt:** "define a protocol for error handling between my bots — like what happens when one crashes and another needs to know about it"

**Why this tests the skill:** Tests whether the skill handles fault-signaling contracts (a less obvious protocol type) and doesn't conflate "error handling" with code-level try/catch mechanics.

---

### Experienced User: Multi-party negotiation domain

**Prompt:** "I need a protocol for a multi-agent auction system — three bidder agents and one auctioneer agent. Need to define the bid submission contract, tie-breaking behavior, and what happens if a bidder goes silent mid-round."

**Why this tests the skill:** Tests whether the skill handles stateful, multi-party contracts with edge-case branches (timeouts, tie resolution) rather than just simple two-agent handoffs.

---

### Experienced User: Cross-system boundary

**Prompt:** "building a protocol for agents that span two orgs — one side runs on our infra, other side is a vendor's black box. We need a contract that defines trust levels, what fields are redacted before crossing the boundary, and how disputes about data integrity get escalated."

**Why this tests the skill:** Tests whether the skill can model asymmetric trust relationships and cross-boundary data handling, not just internal homogeneous agent networks.

---

### Experienced User: Behavioral constraint protocol

**Prompt:** "I want a protocol that governs how a critic agent is allowed to interrupt a planner agent mid-task. It shouldn't be able to halt planning outright — only flag concerns and the planner decides whether to pause. How do I formalize that?"

**Why this tests the skill:** Tests whether the skill can express authority hierarchies and veto/advisory distinctions as first-class behavioral contracts.

---

### Adversarial: Scope creep bait

**Prompt:** "create a protocol for everything — agent communication, error handling, logging format, memory access, rate limiting, and also how agents should decide what to prioritize when they have conflicting goals. basically the full governance layer."

**Why this tests the skill:** Tests whether the skill correctly identifies this as multi-concern and splits or pushes back rather than producing a sprawling document.

---

### Adversarial: Unusual domain — physical-world agents

**Prompt:** "need a protocol for coordinating robot arms in a shared workspace — when arm A is in a zone, arm B needs to know it can't enter without a clearance signal. how do we define that contract formally for our AI control layer?"

**Why this tests the skill:** Tests whether the skill can apply inter-agent behavioral contract thinking to a physical/robotics domain rather than defaulting to purely software-layer assumptions.

---

### Wrong Tool: Policy document request

**Prompt:** "write me a governance policy for how our team decides which new AI agents are allowed to be deployed into production — who approves, what review criteria, sign-off chain"

**Why this tests the skill:** This is a human governance/process document, not an inter-agent behavioral contract — the skill should redirect to a documentation or policy-writing skill.

---

### Wrong Tool: API schema design

**Prompt:** "can you define the request/response schema for the REST API my orchestrator will use to call subagents? JSON fields, status codes, error envelopes — the works"

**Why this tests the skill:** This is an API design task (OpenAPI spec or similar), not a behavioral protocol — tests whether the skill correctly distinguishes interface contracts from behavioral contracts.
