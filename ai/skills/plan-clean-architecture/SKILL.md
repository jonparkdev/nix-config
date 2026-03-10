---
name: plan-clean-architecture
description: >
  Plan and execute features for codebases that follow Clean Architecture (layered
  separation, dependency inversion, interface boundaries). This skill should be used
  when planning new modules, significant features, or architectural changes in projects
  with layer separation (cmd/services/platform, controller/domain/infrastructure, or
  similar). Produces a comprehensive spec that covers architecture, interfaces, boundary
  enforcement, phased implementation with gate checks, and validation. Triggers on
  "plan a feature", "write a spec", "add a module", "design this feature",
  "implement this spec", or when the user describes a feature that spans multiple
  architectural layers.
argument-hint: [feature description or braindump]
---

# Plan Clean Architecture

Produce a comprehensive spec for features in layered architecture codebases. The spec covers everything from architecture discovery through phased implementation with verification gates.

## When to Use

- Adding a new module or domain to a codebase
- Planning a feature that touches multiple layers
- Architectural changes (new storage backend, new external integration)
- Breaking changes that affect interfaces
- Starting a new project with clean architecture

Skip this for bug fixes, small changes within a single layer, or documentation-only work.

## Planning Workflow

Follow these steps in order. Each step produces a concrete artifact or decision. The output is a single spec document that serves as both the plan and the execution guide.

### Step 1: Find or Establish the Architecture

Determine whether an architecture doc exists. Search for: AGENTS.md, ARCHITECTURE.md, docs/architecture.md, or equivalent.

**If the project has an architecture doc:**

1. Read it fully
2. Identify the layer structure and dependency direction
3. Note enforced boundaries (linter rules, import restrictions)
4. Identify the check command (`justfile`, `Makefile`, `package.json`, `Cargo.toml`)
5. Read one existing module end-to-end as a reference implementation

**If the project has no architecture doc (greenfield or undocumented):**

Establishing the architecture is the first planning output. Decide:

1. **Layer structure** — How many layers, what each is responsible for
2. **Dependency direction** — Which layers can import which (always outer -> inner)
3. **Boundary enforcement** — How violations are caught (see [references/enforcement-tools.md](references/enforcement-tools.md))
4. **Interface strategy** — Where interfaces are defined (in the consuming layer)
5. **Module pattern** — How new feature domains are added
6. **Check command** — What to run to verify the build (lint + test)

Write the architecture doc as a concrete deliverable of the plan. Include it as Phase 0 in the spec's implementation plan.

**Capture the layer map** (either discovered or established):

```
[Outer Layer] --> [Middle Layer] --> [Inner Layer]
     via interfaces       via interfaces
```

Common patterns:

| Pattern | Layers (outer to inner) |
|---------|------------------------|
| Go CLI | `cmd/` -> `services/` -> `platform/` |
| Hexagonal / Ports & Adapters | `adapters/` -> `application/` -> `domain/` |
| Rails-style (layered) | `controllers/` -> `services/` -> `models/` |
| Spring / Java | `controller/` -> `service/` -> `repository/` |
| Rust (workspace) | `cli/` -> `core/` -> `infra/` (crate boundaries) |

### Step 2: Analyze Layer Impact

For the proposed feature, determine which layers it touches and what each layer needs.

Ask these questions:

1. **Does it need new domain models or business logic?** -> Inner layer (services/domain)
2. **Does it need new I/O, storage, or external APIs?** -> Infrastructure layer (platform/adapters)
3. **Does it need new user-facing commands or endpoints?** -> Outer layer (cmd/controllers)
4. **Does it need new interfaces at layer boundaries?** -> Interface definitions
5. **Does it need new rendering or output formats?** -> Presentation layer

Record the impact as a checklist. For detailed guidance, see [references/layer-analysis.md](references/layer-analysis.md).

### Step 3: Design Interfaces First

Interfaces are the contract between layers. Define them before implementations.

For each layer boundary the feature crosses:

1. Define the interface in the layer that **consumes** it
2. Keep interfaces minimal — only methods the consumer needs
3. Name interfaces by behavior, not implementation (`SecretReader`, not `AWSSecretManager`)
4. Consider testability — can this interface be trivially mocked?

```
# Interface design template
Layer: [which layer defines this interface]
Name: [behavior-focused name]
Methods:
  - MethodName(inputs) -> (outputs, error)
Consumer: [who calls it]
Implementor: [who implements it]
```

### Step 4: Write the Spec

Create a single specification document that covers planning and execution. The spec is the complete guide — anyone (human or AI) should be able to implement the feature from this document alone.

**Required sections:**

| Section | Content |
|---------|---------|
| **Objective** | Concise bullets — what to build (3-5 words per bullet) |
| **Use Cases** | 2-3 concrete scenarios showing the feature in action |
| **Architecture** | ASCII folder layout + layer dependency diagram |
| **Interfaces** | New or modified interfaces at each boundary |
| **Boundary Enforcement** | How violations are caught (tool, config, enforcement point) |
| **Implementation Plan** | Numbered phases, ordered inside-out, with gate checks per phase |
| **Success Criteria** | Checkboxes for implementation, testing, validation |
| **Non-Goals** | Explicitly deferred items |

**Implementation phases** should be ordered inside-out and each phase must include its gate checks — the verification steps that must pass before proceeding to the next phase. For the full phase gate checklist, see [references/phase-gates.md](references/phase-gates.md).

**Boundary enforcement** must specify:
- What tool catches violations (linter, compiler, architecture tests)
- Where the configuration lives (config file path)
- When it runs (CI, pre-commit, compile time)

If the architecture doc was created in Step 1 (greenfield), include it as Phase 0.

For the full spec template, see [references/spec-template.md](references/spec-template.md).

### Step 5: Decide on ADRs

Create an Architecture Decision Record when any of these apply:

- **New dependency** introduced (library, service, database)
- **Layer boundary changed** (new layer, merged layers, new import rule)
- **Interface pattern changed** (new base interface, breaking change to existing)
- **Trade-off made** where the alternative was reasonable (chose X over Y, and someone might ask why)
- **Convention established** that future code must follow

Skip ADRs for: implementation details within a single layer, bug fixes, documentation, test additions.

ADR format:

```markdown
# ADR NNNN: Title

**Status**: Proposed | Accepted | Rejected | Superseded
**Context**: Which spec or feature prompted this

## Context
What problem or decision point arose.

## Decision
What was decided.

## Consequences
Trade-offs accepted. What becomes easier and harder.
```

### Step 6: Validate the Plan

Before implementation, verify:

- [ ] Every new file has a clear layer assignment
- [ ] No layer imports from a layer above it
- [ ] All cross-layer dependencies are interfaces
- [ ] Each implementation phase has gate checks
- [ ] Each phase is independently testable
- [ ] Boundary enforcement is specified (tool + config + when it runs)
- [ ] Success criteria include the project's check command
- [ ] Non-goals are explicit (prevents scope creep)

## Calibrating for Project Size

Not every project needs the full ceremony. Match the planning depth to the codebase:

| Codebase Size | Spec? | ADRs? | Per-layer interfaces? | Enforcement? |
|--------------|-------|-------|-----------------------|-------------|
| Script (<500 LOC) | No | No | No — just separate concerns | Convention |
| Small app (500-5k LOC) | Lightweight | Only for dependencies | At storage/external boundaries | Convention |
| Medium app (5k-50k LOC) | Yes | Yes | Yes | Linter or tests |
| Large app (50k+ LOC) | Yes, detailed | Yes, required | Yes | Linter + CI |

## Reference

- [references/spec-template.md](references/spec-template.md) — Reusable spec template
- [references/layer-analysis.md](references/layer-analysis.md) — Detailed guide for analyzing layer impact
- [references/enforcement-tools.md](references/enforcement-tools.md) — Boundary enforcement tools by language/ecosystem
- [references/phase-gates.md](references/phase-gates.md) — Full phase gate checklist per implementation phase
