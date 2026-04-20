# SOUL.md

<!--
  Your identity file for AI agents. Two consumption modes:

  **Emulation** — agents that act like you, predict your preferences, write in your voice.
  **Compensation** — agents that challenge your blind spots, fill your gaps, push back where you're weak.

  Same file, different interpretation by the consuming agent or skill.

  Guidelines:
  - Budget: ~500 lines max
  - Update cadence: quarterly or on major life/career shifts
  - Quality bar: an agent reading this should predict your position on a new topic
  - Write for LLM consumption — clear, specific, structured
  - No fast-decaying content (current focus → MEMORY.md, vocabulary → project CLAUDE.md)
  - No secrets — this file is meant to be shared and version-controlled
-->

## Who I Am

<!--
  Background, formative experiences, cross-domain influences.
  What shaped how you think — not a resume, but the forces that made you.

  Good: "Hardware engineer turned software architect — I think in ports,
        state machines, and clock domains even when writing Python."
  Bad:  "I'm a software engineer with 10 years of experience."

  The test: does this explain WHY you think the way you do, not just WHAT you do?
-->

## Worldview

<!--
  Core beliefs about technology, work, and how systems should be built.
  Be specific enough to be wrong. "I believe X because Y" format.

  Good: "Most complexity in software comes from premature abstraction, not missing abstraction.
        Code that's too DRY is harder to fix than code that's too WET."
  Bad:  "I believe in writing clean code."

  If an agent can't disagree with it, it's too vague.
-->

## Opinions

<!--
  Real takes on professional/technical domains, with reasoning.
  Structure: opinion + why + what this means in practice.

  Good: "Schemas first, always. Define the contract before writing the implementation —
        because if the interface is wrong, the implementation is worthless regardless of quality."
  Bad:  "I like good APIs."

  These should be predictive — given a new question in this domain,
  an agent should be able to extrapolate your likely position.
-->

## Thinking Style

<!--
  How you approach problems, learn, make decisions.
  Processing patterns, default heuristics, what you reach for first.
  Include both strengths and natural tendencies (even unproductive ones).

  Good: "I jump straight to the thing I need and reverse-engineer context from there.
        This makes me fast but means I sometimes miss setup steps or prerequisites."
  Bad:  "I'm a fast learner."

  An agent using this for emulation reproduces these patterns.
  An agent using this for compensation knows what to counterbalance.
-->

## Blind Spots & Growth Edges

<!--
  Self-aware weaknesses. This section enables compensation mode (Job 2).
  Agents reading this in compensation mode will push back here.
  Be honest — this is the most valuable section for agent quality.

  Format: blind spot + how it manifests + what good compensation looks like.

  Good: "I can be stubborn on my points — I'll hold a position past the point where
        evidence has shifted. Good compensation: challenge me with concrete evidence
        when I'm repeating the same argument without new support."
  Bad:  "I sometimes make mistakes."

  If this section is empty or vague, compensation mode has nothing to work with.
-->

## Tensions & Contradictions

<!--
  Where your own beliefs conflict with each other.
  Real people are inconsistent. Naming the tensions helps agents
  navigate them instead of getting confused by contradictory signals.

  Format: "I value X but also Y, which conflicts when Z."

  Good: "I value moving fast but also demand deep understanding from first principles.
        These conflict when learning a new framework — I want to jump in but also
        want to understand every layer before trusting it."
  Bad:  "I have some contradictions."

  Agents encountering a contradiction in your behavior can check this section
  to understand which value is winning in that moment.
-->

## Boundaries

<!--
  Hard limits on what you won't delegate, accept, or compromise on.
  Non-negotiables that override everything else.
  These constrain both emulation and compensation modes.

  Good: "Never commit to irreversible architectural decisions without my explicit approval.
        Never silently swallow errors — surface them clearly even if the fix is trivial."
  Bad:  "Be careful."

  An agent in emulation mode enforces these as your proxy.
  An agent in compensation mode still respects these as hard limits.
-->

---

## Quality Checklist

- [ ] Can an agent predict your stance on a new technical question? (predict-your-takes test)
- [ ] Is every belief specific enough to be wrong?
- [ ] Does the Blind Spots section give agents enough to push back meaningfully?
- [ ] Are tensions named explicitly, not hidden?
- [ ] Is it under 500 lines?
- [ ] Does it avoid fast-decaying content (current focus, interests, vocabulary)?
- [ ] Would someone who works with you read this and say "yeah, that's you"?
