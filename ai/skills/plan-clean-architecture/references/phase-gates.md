# Phase Gate Checklist

Run these checks after completing each implementation phase. Do not proceed to the next phase until all applicable checks pass.

## Universal Checks (Every Phase)

```
- [ ] Code compiles / builds without errors
- [ ] Project check command passes (lint + test)
- [ ] No new imports from a layer above
- [ ] All cross-layer references use interfaces
- [ ] New files are in the correct layer directory
- [ ] File naming follows the project's conventions
```

## Phase-Specific Checks

### Phase 1: Domain Models and Interfaces

```
- [ ] Models represent domain concepts, not infrastructure details
      (no JSON tags in domain models unless serialization IS the domain)
- [ ] Interfaces are defined in the consuming layer's package
- [ ] Interface names describe behavior (Reader, Validator, Generator)
      not implementation (PostgresStore, HTTPClient, FileWriter)
- [ ] Each interface has the minimum methods needed by its consumer
- [ ] Interfaces accept and return domain types, not infrastructure types
      (e.g., return domain.User, not *sql.Row)
```

### Phase 2: Business Logic / Services

```
- [ ] Service constructors accept interfaces, not concrete types
- [ ] No I/O in service code (no file reads, HTTP calls, DB queries)
- [ ] No UI framework imports (no cobra, clap, express, flask)
- [ ] Business rules are testable with in-memory fakes
- [ ] Unit tests pass using mocked/faked dependencies
- [ ] Error types are domain-level, not infrastructure-level
      (e.g., ValidationError, not sql.ErrNoRows)
```

### Phase 3: Infrastructure / Platform

```
- [ ] Each infrastructure type implements an interface from Phase 1
- [ ] No business logic in infrastructure code
      (repository does CRUD, not validation or transformation)
- [ ] Infrastructure errors are wrapped into domain error types
- [ ] External dependencies (SDKs, drivers) are isolated here
- [ ] Integration tests verify the implementation satisfies the interface
```

### Phase 4: Wiring / Dependency Injection

```
- [ ] Container/DI holds interface types, not concrete types
- [ ] Concrete types are only referenced inside the wiring code
- [ ] Conditional wiring works (e.g., swap storage backend via config)
- [ ] No business logic in the wiring code
```

### Phase 5: Commands / Controllers / UI

```
- [ ] Outer layer is thin: parse input -> call service -> render output
- [ ] No business logic (no conditionals on domain data)
- [ ] No direct infrastructure access (goes through service interfaces)
- [ ] Error handling maps domain errors to user-facing output
      (exit codes, HTTP status codes, error messages)
- [ ] Output formatting is in the presentation layer, not services
```

### Phase 6: Testing and Documentation

```
- [ ] Unit tests cover business logic (services layer)
- [ ] Unit tests use in-memory fakes (no real I/O)
- [ ] Integration tests cover end-to-end flow
- [ ] Coverage meets the project's target
- [ ] Architecture doc updated if new patterns introduced
- [ ] Command/API documentation written for new user-facing features
- [ ] ADRs written for architectural decisions (if any)
```

## Final Validation

```
- [ ] Full check suite passes (one final run)
- [ ] All success criteria from the spec are met
- [ ] No items from Non-Goals crept into the implementation
- [ ] A deliberate boundary violation is caught by tooling
      (proves enforcement is working)
```

## Quick Reference: What Goes Where

| This code... | Belongs in... | Not in... |
|-------------|--------------|-----------|
| Data types, structs, enums | Domain / models | Infrastructure |
| Validation rules | Services | Commands |
| SQL queries, HTTP calls | Infrastructure | Services |
| Interface definitions | Consumer's package | Implementor's package |
| DI wiring | Container | Commands or services |
| Flag parsing, arg handling | Commands / controllers | Services |
| Output formatting | Presentation / render | Services |
| Error type definitions | Domain errors package | Infrastructure |
