---
name: plan-to-clickup
description: "Decompose a CE plan into sprint-scoped ClickUp epics with subtasks. Surfaces hidden work through recursive drill-down. Use when the user says 'sync to clickup', 'decompose this plan', 'create epics', 'sprint plan this', or has a plan doc ready for execution."
argument-hint: "<path-to-plan> <clickup-list-id>"
disable-model-invocation: true
---

# Plan to ClickUp

Decompose a plan document into sprint-scoped ClickUp epics with subtasks, surfacing hidden work through recursive drill-down.

Plan documents are created by the Compound Engineering (CE) plugin's `/ce:plan` workflow. See [reference/ce-plan-format.md](reference/ce-plan-format.md) for the full format specification, including frontmatter fields, naming conventions, and parsing strategy.

## Phase 1: Parse Plan

1. Accept a path to a plan doc. If not provided, discover the latest in `docs/plans/` (CE plans use the naming convention `YYYY-MM-DD-<type>-<name>-plan.md`).
2. Accept a ClickUp list ID. If not provided, ask the user.
3. Extract YAML frontmatter (`title`, `type`, `date`, `status`).
4. Identify each top-level `##` section as a candidate epic. See the parsing strategy in [reference/ce-plan-format.md](reference/ce-plan-format.md).

If no plan doc is found, stop and tell the user:
> "No plan document found. Create one first with `/ce:plan` or provide a path."

## Phase 2: Recursive Decomposition

Apply four lenses to every planned section. This is the core value — it surfaces work that gets overlooked during high-level planning. Task templates are in `reference/` (one file per template).

| Lens | Question | Surfaces |
|------|----------|----------|
| Prerequisite / Core / Verify | What must exist before? What's the work? How to prove it works? | Missing setup steps, missing tests |
| Implicit Dependencies | Does X need Y across tasks? | Ordering issues, blockers |
| Glue Work | Config, IAM, DNS, monitoring, docs, rollback? | The work nobody writes down |
| Definition of Done | What do you demo at sprint review? | Vague acceptance criteria |

See [reference/decomposition.md](reference/decomposition.md) for the detailed algorithm.

## Phase 3: Sprint Scoping

Size subtasks using fibonacci points (starting at 0.5):

| Points | Duration |
|--------|----------|
| 0.5 | A few hours |
| 1 | Half day |
| 2 | 1 day |
| 3 | 1.5 days |
| 5 | 2.5 days |
| 8 | 4 days |
| 13 | Full sprint |

Rules:
- Create a single epic containing all planned tasks, even if total points exceed 20. Do not auto-split into multiple epics. After reviewing the epic, the user will decide whether to split into multiple epics and redistribute tasks.
- Each epic must have a clear deliverable (demo-able at sprint review).
- Assign dependency ordering across epics.
- Target 5-12 subtasks per epic.

## Phase 4: Generate Intermediate Document

Write the decomposed plan to `docs/plans/<original-name>-decomposed.md`:

```markdown
---
source_plan: docs/plans/YYYY-MM-DD-type-name-plan.md
decomposed_on: YYYY-MM-DD
clickup_list_id: <provided or to-be-filled>
---

# Decomposed: <title>

## Epic 1: <name> [Sprint N]
**Deliverable:** <what you demo>
**Points:** <total fibonacci points>
**Dependencies:** <epic names or "none">
**Priority:** urgent|high|normal|low

### Subtasks
- [ ] **<name>** (<fibonacci pts>) -- <type: prerequisite|core|verification|glue>
  Acceptance criteria: <how to verify>
```

Repeat for each epic. Include a summary section at the top:

```markdown
## Summary
- **Total epics:** N
- **Total points:** N
- **Estimated sprints:** N
- **Critical path:** Epic A -> Epic B -> Epic D
```

## Phase 5: User Review Gate

Present the decomposed doc to the user. Offer these options:

1. **Modify decomposition** -- user edits, then re-run
2. **Sync to ClickUp now** -- proceed to Phase 6
3. **Re-decompose specific sections** -- drill deeper on selected epics
4. **Save decomposition only** -- stop here, no sync

Wait for the user to choose before proceeding. Do not auto-sync.

## Phase 6: ClickUp Sync

**Prerequisite check:** Verify ClickUp MCP is available by checking tool availability. If not:
> "ClickUp MCP not available. Decomposed plan saved. Configure ClickUp MCP to enable sync."

Stop and save the decomposed doc only.

**If MCP is available**, sync each epic following the patterns in [reference/clickup-sync.md](reference/clickup-sync.md):

1. For each epic:
   - `clickup_create_task` with name, description, tags=["epic"], time_estimate (in minutes), priority
   - `clickup_search` to retrieve the created task's `id` and `list.id`
   - For each subtask: `clickup_create_task` with `parent=<epic_id>`, `list_id=<list.id>`
2. Update the decomposed doc with ClickUp task IDs for traceability:
   ```markdown
   ## Epic 1: <name> [Sprint N] <!-- clickup:TASK_ID -->
   ```

## Iterability

- **Re-decompose**: Re-run on an updated plan. If an existing decomposed doc is found, offer to merge or regenerate.
- **Modify then sync**: User edits the decomposed markdown, runs the skill again. Detect that decomposed doc exists and offer sync-only mode.
- **Incremental sync**: Skip epics that already have ClickUp IDs (detected via `<!-- clickup:TASK_ID -->` comments). Only sync new or modified epics.
