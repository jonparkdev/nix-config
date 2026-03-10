# Boundary Enforcement by Language

How to enforce layer boundaries (prevent inner layers from importing outer layers) in each ecosystem. Choose the approach that matches the project's language and tooling.

## Go

**Tool**: `golangci-lint` with `depguard` linter

**How it works**: Rules in `.golangci.yml` declare which packages each layer is forbidden from importing. Violations fail the lint step.

```yaml
# .golangci.yml
linters-settings:
  depguard:
    rules:
      services-layer:
        files:
          - "**/internal/services/**"
        deny:
          - pkg: "github.com/spf13/cobra"
            desc: "services must not import CLI framework"
```

**Enforcement point**: `golangci-lint run` (CI or pre-commit)

**Strength**: Catches violations at lint time, blocks CI.

## Rust

**Tool**: The language itself (module visibility) + workspace crates

**How it works**: Rust's module system enforces boundaries at compile time. Use `pub(crate)` for crate-internal visibility. For stronger isolation, split layers into separate workspace crates — a crate literally cannot import another crate unless it's declared as a dependency in `Cargo.toml`.

```toml
# Cargo.toml (workspace)
[workspace]
members = ["cli", "core", "infra"]

# core/Cargo.toml — no dependency on cli
[dependencies]
# infra types only via traits defined in core

# cli/Cargo.toml — depends on core, not infra directly
[dependencies]
core = { path = "../core" }
infra = { path = "../infra" }  # only for wiring
```

**Additional tool**: `cargo-modules` for visualizing the dependency graph.

**Enforcement point**: Compiler (won't build if boundaries are violated).

**Strength**: Strongest possible — compiler-enforced. No extra tooling needed if crates are structured correctly.

## TypeScript / JavaScript

**Tool**: `eslint-plugin-boundaries` or `eslint-plugin-import`

**How it works**: ESLint rules declare allowed/forbidden import patterns between directory-based layers.

```json
{
  "rules": {
    "boundaries/element-types": [2, {
      "default": "disallow",
      "rules": [
        { "from": "domain", "allow": [] },
        { "from": "application", "allow": ["domain"] },
        { "from": "infrastructure", "allow": ["domain", "application"] }
      ]
    }]
  }
}
```

**Alternative**: `@nx/enforce-module-boundaries` in Nx monorepos.

**Enforcement point**: `eslint` (CI or editor integration).

**Strength**: Moderate — requires discipline to configure correctly.

## Java / Kotlin

**Tool**: ArchUnit

**How it works**: Architecture rules written as unit tests. Tests fail if imports violate declared boundaries.

```java
@Test
void domainShouldNotDependOnInfrastructure() {
    noClasses()
        .that().resideInAPackage("..domain..")
        .should().dependOnClassesThat()
        .resideInAPackage("..infrastructure..")
        .check(importedClasses);
}
```

**Alternative**: Java modules (`module-info.java`) for compile-time enforcement in Java 9+.

**Enforcement point**: Test suite (ArchUnit) or compiler (Java modules).

**Strength**: Strong — ArchUnit tests are expressive and run in CI.

## Python

**Tool**: `import-linter`

**How it works**: Declare contracts in a config file. The tool analyzes the import graph and reports violations.

```ini
# .importlinter
[importlinter]
root_package = myapp

[importlinter:contract:layers]
name = Layered architecture
type = layers
layers =
    myapp.presentation
    myapp.application
    myapp.domain
```

**Enforcement point**: `lint-imports` command (CI).

**Strength**: Moderate — Python's dynamic nature means some imports can't be caught statically.

## C# / .NET

**Tool**: ArchUnitNET or project references

**How it works**: Similar to Java's ArchUnit — architecture rules as tests. Alternatively, use separate .csproj projects per layer and control references.

**Enforcement point**: Test suite or build system.

## Choosing an Approach

| Approach | Strength | Effort | Best For |
|----------|----------|--------|----------|
| Compiler/language (Rust, Java modules) | Strongest | Low (structural) | New projects, strict boundaries |
| Lint rules (Go depguard, ESLint) | Strong | Medium (config) | Existing projects, gradual adoption |
| Test-based (ArchUnit) | Strong | Medium (test code) | Java/Kotlin, complex rules |
| Convention only | Weak | Low | Small teams, high trust |

For new projects, prefer compiler-enforced boundaries when the language supports it. For existing projects, lint rules are the most practical path to enforcement.
