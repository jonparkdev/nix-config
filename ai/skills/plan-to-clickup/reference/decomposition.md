# Recursive Decomposition Algorithm

This document describes the four-lens decomposition methodology used to surface hidden work in plan sections.

## Process

For each section/phase in the plan, apply all four lenses sequentially. Each lens generates candidate subtasks.

### Lens 1: Prerequisite / Core / Verify

Split every planned item into three categories:

| Category | Question | Example |
|----------|----------|---------|
| **Prerequisite** | What must exist before the core work can begin? | DB migration, API key provisioned, dependency installed |
| **Core** | What is the actual implementation work? | Write the service, build the UI component |
| **Verify** | How do you prove it works? | Integration test, manual QA checklist, monitoring alert fires correctly |

Common gaps this surfaces:
- Missing test subtasks (verification often omitted in plans)
- Environment setup assumed but not planned
- Data migration or seeding steps

### Lens 2: Implicit Dependencies

For every pair of subtasks within and across epics, ask:

> "Does completing X require Y to exist or be in a certain state?"

Build a dependency graph. Look for:
- **Circular dependencies** -- these indicate the plan needs restructuring
- **Hidden ordering constraints** -- task A says "call the API" but task B builds the API
- **Shared resources** -- two tasks modify the same config file or DB table
- **Cross-team dependencies** -- work that requires someone outside the team

Output: dependency edges between subtasks and across epics.

### Lens 3: Glue Work

For each epic, systematically check these categories:

| Category | Check |
|----------|-------|
| **Configuration** | New env vars, feature flags, config files? |
| **Infrastructure** | DNS, CDN, load balancer, IAM roles, permissions? |
| **Monitoring** | Alerts, dashboards, log queries, error tracking? |
| **Documentation** | API docs, runbooks, architecture diagrams, changelog? |
| **Migration** | Data migration, backwards compatibility, rollback plan? |
| **Security** | Auth changes, new endpoints exposed, secrets rotation? |
| **CI/CD** | New build steps, deploy config, environment variables? |
| **Communication** | Stakeholder notification, user-facing changelog, support docs? |

Each "yes" becomes a subtask typed as `glue`.

### Lens 4: Definition of Done

For each epic, define what you demo at sprint review:

> "When this epic is done, I can show _____ working in _____ environment."

If the definition of done is vague ("it works"), push for specifics:
- What exact user flow do you walk through?
- What data appears on screen?
- What error case do you show handling?
- What metric proves it's working?

Each acceptance criterion becomes part of the epic description and may generate additional verification subtasks.

## Output Format

After applying all four lenses, each planned section produces:

```
Section: "<original section name>"
Epic candidate: "<refined epic name>"
Subtasks:
  - <name> (prerequisite) -- <acceptance criteria>
  - <name> (core) -- <acceptance criteria>
  - <name> (core) -- <acceptance criteria>
  - <name> (glue) -- <acceptance criteria>
  - <name> (verification) -- <acceptance criteria>
Dependencies:
  - Requires: <other epic/subtask names>
  - Blocks: <other epic/subtask names>
Definition of Done: "<specific demo statement>"
```

## Sizing Guidelines

After decomposition, size each subtask:

- **1pt** -- Trivial change, confident it works first try (env var, config toggle)
- **2pt** -- Straightforward work with known approach (CRUD endpoint, simple UI)
- **3pt** -- Moderate complexity or minor unknowns (integration with external service)
- **5pt** -- Significant work or meaningful unknowns (new subsystem, complex logic)
- **8pt** -- Large task, consider splitting further (multi-component feature)
- **13pt** -- Epic-sized, must be split (full feature end-to-end)

If a single subtask is 8+, apply the four lenses again to that subtask specifically.
