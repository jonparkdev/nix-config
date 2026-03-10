# Layer Impact Analysis

A systematic approach to determining which architectural layers a feature touches and what each layer needs.

## The Five Questions

For any proposed feature, answer these questions:

### 1. Does it introduce new domain concepts?

New data types, business rules, or domain logic.

**Signs it does:**
- New nouns in the feature description (e.g., "secrets", "applications", "feeds")
- New verbs that represent business operations (e.g., "generate", "validate", "sync")
- New constraints or rules (e.g., "names must be unique", "paths are relative to repo root")

**Layer impact:** Inner layer (services/domain). Define models and business logic here.

### 2. Does it need new I/O?

File system, network, database, or external service access.

**Signs it does:**
- Reading/writing files in a new format
- Calling a new API or service
- New persistence requirements
- New external tool invocation (git, kubectl, helm)

**Layer impact:** Infrastructure layer (platform/adapters/repository). Implement I/O here, expose via interface.

### 3. Does it need new interfaces?

Contracts between layers that don't exist yet.

**Signs it does:**
- A service needs to call something that doesn't have an abstraction yet
- A new module needs its own container/wiring
- An existing interface needs new methods (consider ISP — maybe a new interface instead)

**Layer impact:** Interface definitions. Place in the consuming layer's package.

### 4. Does it change user-facing behavior?

New commands, endpoints, flags, or output formats.

**Signs it does:**
- New CLI subcommands or API routes
- New flags or parameters
- New output format (JSON, YAML, table)
- Changed exit codes or error messages

**Layer impact:** Outer layer (cmd/controllers). Orchestrate via interfaces only.

### 5. Does it change the wiring?

How dependencies are connected.

**Signs it does:**
- New concrete types need to be instantiated
- New interfaces need to be satisfied
- Conditional wiring (e.g., "use Postgres if configured, else YAML")
- New module registration

**Layer impact:** Container/DI layer. Wire concrete to abstract.

## Impact Matrix

Record the analysis as a matrix:

```
Feature: [name]

| Question | Answer | Layer | Changes Needed |
|----------|--------|-------|----------------|
| New domain concepts? | Yes/No | services/ | [list] |
| New I/O? | Yes/No | platform/ | [list] |
| New interfaces? | Yes/No | interfaces | [list] |
| New user-facing? | Yes/No | cmd/ | [list] |
| New wiring? | Yes/No | container | [list] |
```

## Common Patterns

### Adding a command to an existing module

Typical impact: outer layer only + maybe one new service method.

```
[ ] New service interface method
[ ] Implement method in existing service
[ ] New command file
[ ] Register command in module
[ ] Tests for new method
```

### Adding a new module

Typical impact: all layers.

```
[ ] New domain models
[ ] New service interfaces
[ ] New service implementations
[ ] New platform/infrastructure code (if I/O needed)
[ ] New container (per-module DI)
[ ] New module registration
[ ] New commands
[ ] Tests at every layer
[ ] Documentation
```

### Adding a new storage backend

Typical impact: infrastructure + wiring only.

```
[ ] New implementation of existing interface
[ ] Updated container wiring (conditional)
[ ] Tests for new implementation
[ ] No changes to services, commands, or business logic
```

### Adding a new output format

Typical impact: presentation layer only.

```
[ ] New renderer or formatter
[ ] Updated output mode handling
[ ] Tests for new format
[ ] No changes to services or storage
```

## Red Flags

If your analysis shows any of these, the architecture may need adjustment before proceeding:

- **Service layer needs to import a UI or CLI package** — business logic is leaking into the wrong layer
- **Infrastructure layer calls service layer** — dependency direction is reversed
- **A single change touches every layer** — the feature may be too broad (split it) or the boundaries may be wrong
- **An interface has more than 5-6 methods** — consider splitting (Interface Segregation Principle)
- **Tests require real I/O to run** — missing an interface at the infrastructure boundary
