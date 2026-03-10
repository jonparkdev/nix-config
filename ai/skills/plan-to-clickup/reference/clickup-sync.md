# ClickUp Sync Reference

Patterns and field mappings for creating ClickUp tasks via MCP.

## Task Creation Pattern

### Epic Creation

Use the epic template from [epic-template.md](epic-template.md) for the task description. Fill in each field from the decomposed plan data:

```
clickup_create_task:
  list_id: <user-provided list ID>
  name: "<epic name>"
  description: |
    **Epic Name:** <epic name>

    **Objective:** <deliverable from decomposed plan>

    **Business Value:** <derived from plan's problem statement/motivation>

    **Scope:** <what this epic covers, from decomposed subtask list>

    **Background:** <relevant context from source plan>

    **Stakeholders:** <from plan's stakeholders or ask user>

    **Dependencies:** <epic dependency names from decomposition>

    **Acceptance Criteria:**
    - <acceptance criteria from decomposed subtasks>

    **TDD:** <link to source plan doc path>

    **Risks:** <from plan's risks section or decomposition findings>
  tags: ["epic"]
  priority: 1-4 (1=urgent, 2=high, 3=normal, 4=low)
  time_estimate: <total minutes based on points>
```

### Subtask Creation (Two-Step)

Subtasks require the parent task's `id` and `list.id`. Direct creation without fetching parent info first may fail with auth errors.

**Step 1: Search for parent**
```
clickup_search:
  keywords: "<epic name>"
```

Extract `id` and `list.id` from results.

**Step 2: Create subtask**

Use the task template from [task-template.md](task-template.md) for the description:

```
clickup_create_task:
  list_id: <parent's list.id from search>
  parent: <parent's id from search>
  name: "<subtask name>"
  description: |
    **Task Title:** <subtask name>

    **Description:** <what needs to be accomplished, derived from decomposition>

    **Priority:** <Low/High/Urgent>

    **Acceptance Criteria:**
    - <criteria from decomposition>

    **Resources Needed:** <tools, systems, or info required>

    **Dependencies:** <other subtasks or epics this depends on>

    **Notes:** Type: prerequisite|core|verification|glue. Points: <fibonacci pts>.
  time_estimate: <minutes>
  priority: 1-4
```

## Field Mapping

### Time Estimates

Convert fibonacci points to minutes:

| Points | Days | Minutes |
|--------|------|---------|
| 1 | 0.5 | 240 |
| 2 | 1 | 480 |
| 3 | 1.5 | 720 |
| 5 | 2.5 | 1200 |
| 8 | 4 | 1920 |
| 13 | 6.5 | 3120 |

### Priority Mapping

| Plan Priority | ClickUp Value |
|---------------|---------------|
| urgent | 1 |
| high | 2 |
| normal | 3 |
| low | 4 |

### Tags

- Epics: `["epic"]`
- Subtasks inherit no extra tags by default (ClickUp shows hierarchy via parent)

## Task Writing Style

Follow these conventions from the existing ClickUp skill:

- **Present tense** for describing the problem ("warnings clutter output" not "warnings cluttered output")
- **Problem first, then solution** -- describe what's wrong before how to fix it
- **High-level focus** -- explain what and why, not implementation details
- **No file lists or code specifics** -- those belong in PRs, not tickets
- **Concise names** -- "Resolve server build warnings" not "Fix backend server build warnings (31 warnings resolved)"
- **Definition of Done** -- all tasks include what "done" looks like

## Common Errors

### "Parent not child of list"

The parent task is in a different list than the `list_id` specified. Always use the parent's actual `list.id` from search results, not the original list ID.

### Time estimates not showing

ClickUp caches time estimates. They may not appear in the UI immediately. The value is still stored correctly.

## Traceability

After syncing, update the decomposed doc with ClickUp task IDs:

```markdown
## Epic 1: Setup Infrastructure [Sprint 1] <!-- clickup:abc123 -->

### Subtasks
- [x] **Provision database** (2) -- prerequisite <!-- clickup:def456 -->
```

This enables:
- **Incremental sync**: skip tasks that already have IDs
- **Status tracking**: future tooling can read IDs to check completion
- **Audit trail**: plan doc links back to execution
