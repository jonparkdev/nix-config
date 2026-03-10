# Spec Template for Clean Architecture Projects

Copy and adapt this template when writing a feature specification.

---

```markdown
# [Project] vX.Y Spec

One-line description (concise, no fluff)

---

## 1. Objective

Build/Implement X with Y:

* Action-oriented bullet (what, not why)
* Another bullet (3-5 words)
* Keep it short

**Prerequisite**: [spec or feature that must exist first]
**Target**: [language version, framework version]

---

## 2. Use Cases

### Use Case 1: [Name]

[2-3 sentences describing a concrete scenario. Who does what, what happens.]

### Use Case 2: [Name]

[Another scenario, ideally covering a different aspect of the feature.]

---

## 3. Architecture

### Folder Layout

```
cmd/module/          (or controllers/, routes/, etc.)
├── command.go
internal/services/module/   (or domain/, application/)
├── interfaces.go
├── service.go
internal/platform/module/   (or infrastructure/, adapters/)
├── repository.go
```

### Layer Dependencies

```
[Outer] --> [Middle] --> [Inner]
   via interfaces    via interfaces
```

### New Interfaces

```
Interface: [Name]
Defined in: [layer/package]
Methods:
  - Method(input) -> (output, error)
Implemented by: [concrete type in lower layer]
Used by: [consumer in upper layer]
```

### Boundary Enforcement

How layer violations are caught:

| Mechanism | Tool | Config | Enforcement Point |
|-----------|------|--------|-------------------|
| [e.g., Import restrictions] | [e.g., golangci-lint depguard] | [e.g., .golangci.yml] | [e.g., CI lint step] |
| [e.g., Crate boundaries] | [e.g., Cargo workspace] | [e.g., Cargo.toml] | [e.g., Compiler] |

Check command: `[e.g., just check, cargo clippy && cargo test]`

---

## 4. Implementation Plan

### Phase 0: Architecture Doc (greenfield only)
1. Create architecture doc (AGENTS.md / ARCHITECTURE.md)
2. Configure boundary enforcement tooling
3. Verify enforcement catches a deliberate violation

**Gate checks:**
- [ ] Architecture doc exists and describes layers, boundaries, conventions
- [ ] Enforcement tooling configured and tested
- [ ] Check command runs successfully

### Phase 1: Domain / Interfaces
1. Define models
2. Define service interfaces
3. Write unit tests for business logic

**Gate checks:**
- [ ] Check command passes
- [ ] Models represent domain concepts, not infrastructure details
- [ ] Interfaces defined in consuming layer's package
- [ ] Interface names describe behavior (Reader, Validator), not implementation
- [ ] Interfaces accept/return domain types, not infrastructure types

### Phase 2: Business Logic / Services
1. Implement service with business logic
2. Write unit tests using in-memory fakes

**Gate checks:**
- [ ] Check command passes
- [ ] Service constructors accept interfaces, not concrete types
- [ ] No I/O in service code
- [ ] No UI/CLI framework imports in service code
- [ ] Unit tests pass with mocked/faked dependencies
- [ ] Error types are domain-level (ValidationError, not sql.ErrNoRows)

### Phase 3: Infrastructure / Platform
1. Implement repository / external client
2. Satisfy interfaces from Phase 1
3. Write integration tests

**Gate checks:**
- [ ] Check command passes
- [ ] Each infrastructure type implements an interface from Phase 1
- [ ] No business logic in infrastructure code
- [ ] Infrastructure errors wrapped into domain error types
- [ ] External dependencies (SDKs, drivers) isolated in this layer

### Phase 4: Wiring / Dependency Injection
1. Add to dependency injection container
2. Connect concrete implementations to interfaces

**Gate checks:**
- [ ] Check command passes
- [ ] Container/DI holds interface types, not concrete types
- [ ] Concrete types only referenced inside wiring code
- [ ] No business logic in wiring code

### Phase 5: Commands / Controllers / UI
1. Create user-facing entry points
2. Call services via interfaces only

**Gate checks:**
- [ ] Check command passes
- [ ] Outer layer is thin: parse input -> call service -> render output
- [ ] No business logic in commands/controllers
- [ ] No direct infrastructure access (goes through service interfaces)
- [ ] Error handling maps domain errors to user-facing output

### Phase 6: Testing & Documentation
1. End-to-end / integration tests
2. Update architecture doc if new patterns introduced
3. Write command / API documentation
4. Write ADRs for architectural decisions (if any)

**Gate checks:**
- [ ] Check command passes
- [ ] Unit tests use in-memory fakes (no real I/O)
- [ ] Integration tests cover end-to-end flow
- [ ] Coverage meets project target
- [ ] Documentation updated

---

## 5. Success Criteria

**Implementation**:
- [ ] Interfaces defined
- [ ] Service implemented
- [ ] Infrastructure implemented
- [ ] Wired in container / DI
- [ ] Commands / endpoints created

**Testing**:
- [ ] Unit tests for business logic (target: >=70%)
- [ ] Integration tests pass
- [ ] Full check suite passes

**Boundary integrity**:
- [ ] No layer imports from a layer above it
- [ ] All cross-layer dependencies are interfaces
- [ ] A deliberate boundary violation is caught by tooling

**Documentation**:
- [ ] Architecture guide updated
- [ ] Command / API docs written
- [ ] ADR written (if applicable)

---

## 6. Common Violations

| Violation | Symptom | Fix |
|-----------|---------|-----|
| Service imports CLI framework | Lint failure or direct import | Move CLI-dependent logic to command layer |
| Infrastructure imports service | Upward dependency | Define interface in infra that service implements, or restructure |
| Business logic in command layer | Conditionals, loops over domain data | Move to service method, command calls service |
| Concrete type crosses boundary | Container field is `*PostgresRepo` not `Repository` | Change to interface type |
| Test requires real I/O | Test creates files, hits network | Create in-memory fake implementing the interface |

---

## 7. Non-Goals

Out of scope for this spec:

- Feature X (defer to vY)
- Feature Z (separate spec needed)
- Optimization W (premature at this stage)
```

---

## Template Usage Notes

**Objective section**: Use concise bullets. If a bullet needs more than 5 words, it's probably two bullets. Never write paragraphs here.

**Folder layout**: Always use ASCII tree format. Show only new or modified files.

**Boundary enforcement**: Always specify the tool, its config file, and when it runs. If the language itself enforces boundaries (Rust crates, Java modules), state that.

**Implementation phases**: Order inside-out. Domain and interfaces first, UI and commands last. Every phase must include gate checks — the verification that must pass before the next phase.

**Gate checks**: Include the project's check command in every phase. Add phase-specific checks from the phase gates reference. These are not optional — they prevent architectural drift during implementation.

**Common violations**: Include this section. It tells the implementor what to watch for and how to fix it. Adapt the examples to the project's ecosystem.

**Success criteria**: Use checkboxes. Include a boundary integrity section that verifies enforcement tooling catches violations.

**Non-goals**: Always include this section. It prevents scope creep. If nothing is deferred, state "None — this spec is tightly scoped."

**Target length**: 200-500 lines for a feature spec, 500-800 for a module spec.
