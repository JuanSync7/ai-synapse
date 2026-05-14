# SystemVerilog/UVM Test Coverage Framework Plan

This document outlines the proposed architecture to implement a SystemVerilog and UVM test coverage framework within the `ai-synapse` ecosystem. It translates your requirements into the repository's native "Skills, Agents, Protocols" taxonomy.

## Decisions Made

- **Simulator Integration:** Verilator will be the targeted simulator/linter.
- **Repository Location:** Artifacts will be placed in the `src/` directory, following the `AGENTS.md` guidelines for adopter artifacts.
- **Approach:** We will execute this step-by-step, starting with the simplest, most foundational components first.

## Proposed Changes

We will introduce a new domain called `hw-verification`. Below are the proposed components based on the `SKILL_TAXONOMY.md`, `AGENT_TAXONOMY.md`, and `PROTOCOL_TAXONOMY.md` rules.

---

### Protocols (Kitchen Rules)
These define the shared rules and contracts that the agents will use to communicate state and failures.

#### [NEW] [hw-verification-failure-reporting-contract.md](file:///c:/Users/Onyx%20V/OneDrive%20-%20University%20of%20Southampton/Year%204/For%20fun/ai-synapse/src/protocols/hw-verification/hw-verification-failure-reporting-contract.md)
- **Purpose:** Defines the "Fail Loudly" requirement. Forces agents to emit critical, formatted notifications when compilation, linting, or coverage targets cannot be met, rather than failing silently or hallucinating fixes.

#### [NEW] [hw-verification-coverage-iteration-schema.md](file:///c:/Users/Onyx%20V/OneDrive%20-%20University%20of%20Southampton/Year%204/For%20fun/ai-synapse/src/protocols/hw-verification/hw-verification-coverage-iteration-schema.md)
- **Purpose:** The state machine schema for the iterative coverage loop, defining the exit condition (Coverage >= 90%).

---

### Agents (Cooks)
The internal LLM personas that specialize in specific verification tasks.

#### [NEW] [hw-verification-linter-agent.md](file:///c:/Users/Onyx%20V/OneDrive%20-%20University%20of%20Southampton/Year%204/For%20fun/ai-synapse/src/agents/hw-verification/hw-verification-linter-agent.md)
- **Purpose:** Specialized in interpreting SystemVerilog lint errors and applying syntactically correct fixes.

#### [NEW] [hw-verification-uvm-agent.md](file:///c:/Users/Onyx%20V/OneDrive%20-%20University%20of%20Southampton/Year%204/For%20fun/ai-synapse/src/agents/hw-verification/hw-verification-uvm-agent.md)
- **Purpose:** Specialized in UVM architecture, sequences, random constraints, and assertions. Analyzes coverage holes and generates tests to hit them.

#### [NEW] [hw-verification-loop-orchestrator.md](file:///c:/Users/Onyx%20V/OneDrive%20-%20University%20of%20Southampton/Year%204/For%20fun/ai-synapse/src/agents/hw-verification/hw-verification-loop-orchestrator.md)
- **Purpose:** Manages the pipeline. Compiles -> Lints -> Simulates -> Checks Coverage -> Delegates to UVM agent or Fails Loudly.

---

### Skills (Recipes)
The user-invocable behaviors that tie the agents and protocols together.

#### [NEW] [SKILL.md (Linter Fixer)](file:///c:/Users/Onyx%20V/OneDrive%20-%20University%20of%20Southampton/Year%204/For%20fun/ai-synapse/src/skills/hw-verification/hw-verification-linter-error-fixer/SKILL.md)
- **Slug:** `hw-verification-linter-error-fixer`
- **Description:** Invoked when lint or compilation errors are detected. Applies fixes to RTL or testbenches.

#### [NEW] [SKILL.md (Coverage Test Generator)](file:///c:/Users/Onyx%20V/OneDrive%20-%20University%20of%20Southampton/Year%204/For%20fun/ai-synapse/src/skills/hw-verification/hw-verification-coverage-test-generator/SKILL.md)
- **Slug:** `hw-verification-coverage-test-generator`
- **Description:** Invoked to analyze coverage reports and generate new constrained random tests or assertions to hit uncovered bins/paths.

#### [NEW] [SKILL.md (Coverage Loop Orchestrator)](file:///c:/Users/Onyx%20V/OneDrive%20-%20University%20of%20Southampton/Year%204/For%20fun/ai-synapse/src/skills/hw-verification/hw-verification-coverage-loop-orchestrator/SKILL.md)
- **Slug:** `hw-verification-coverage-loop-orchestrator`
- **Description:** The master skill that drives the 90% coverage loop. It invokes the linter, the simulation execution (via mechanical tools), and the test generator.

## Verification Plan

### Manual Verification
1. Review the generated `SKILL.md`, `EVAL.md`, agent, and protocol files to ensure they meet the `AGENTS.md` and taxonomy guidelines.
2. Ensure the frontmatter is correctly populated and directory structures are valid (`src/skills/hw-verification/...`).
3. We will run the framework's existing validation tools (if any) to certify the taxonomy constraints.

## Execution Steps

We will proceed iteratively starting from the foundational rules (Protocols), moving to the specialized personas (Agents), and finally the recipes (Skills).

1. **Step 1: Foundation (Protocols)**
   - Create `hw-verification-failure-reporting-contract.md`
   - Create `hw-verification-coverage-iteration-schema.md`
2. **Step 2: Linter Workflow**
   - Create `hw-verification-linter-agent.md`
   - Create `hw-verification-linter-error-fixer` skill (SKILL.md and EVAL.md)
3. **Step 3: UVM Coverage Generation Workflow**
   - Create `hw-verification-uvm-agent.md`
   - Create `hw-verification-coverage-test-generator` skill (SKILL.md and EVAL.md)
4. **Step 4: Loop Orchestration**
   - Create `hw-verification-loop-orchestrator.md`
   - Create `hw-verification-coverage-loop-orchestrator` skill (SKILL.md and EVAL.md)
