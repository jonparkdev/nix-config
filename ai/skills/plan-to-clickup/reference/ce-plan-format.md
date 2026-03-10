# CE Plan Document Format

CE (Compound Engineering) is a Claude Code plugin that provides a brainstorm-to-plan workflow. This reference describes the plan document format so the skill can parse any CE plan.

## File Location & Naming

Plans are saved to `docs/plans/` with the naming convention:

```
docs/plans/YYYY-MM-DD-<type>-<descriptive-name>-plan.md
```

Examples:
- `docs/plans/2026-03-03-feat-sync-claude-mcp-all-supported-providers-plan.md`
- `docs/plans/2026-02-08-fix-auth-token-refresh-plan.md`

## YAML Frontmatter

Every CE plan starts with frontmatter:

```yaml
---
title: "feat: Descriptive title with conventional commit prefix"
type: feat|fix|refactor
date: YYYY-MM-DD
status: active|completed
deepened: YYYY-MM-DD        # optional, present if /deepen-plan was run
origin: docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md  # optional
---
```

## Document Structure

CE plans follow one of three templates depending on scope. All share a common structure with these key sections:

### Common Sections (All Templates)

- **Overview / Problem Statement** — what and why
- **Proposed Solution** — high-level approach
- **Acceptance Criteria** — checkboxes (`- [ ]`) defining done
- **Sources & References** — file paths, URLs, related PRs

### Standard Template (Most Common)

- Overview
- Problem Statement / Motivation
- Proposed Solution
- Technical Considerations
- System-Wide Impact
- Acceptance Criteria
- Success Metrics
- Dependencies & Risks
- Sources & References

### Comprehensive Template (Major Changes)

Adds: Alternative Approaches, Risk Analysis & Mitigation, Resource Requirements, Future Considerations, Documentation Plan.

## Parsing Strategy

When decomposing a CE plan into epics:

1. **Read frontmatter** for title, type, date — carry these into the decomposed doc's `source_plan` field.
2. **Identify candidate epics** from top-level `##` sections. Each major section (Proposed Solution subsections, Technical Approach phases, Implementation phases) maps to one or more epics.
3. **Extract acceptance criteria** from `- [ ]` checkboxes — these become verification subtasks or epic-level definitions of done.
4. **Note dependencies** from the Dependencies & Risks section — these inform epic ordering.
5. **Use System-Wide Impact** section to surface glue work (monitoring, error propagation, API parity checks).
