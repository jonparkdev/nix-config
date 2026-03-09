# Planning Guidelines

Follow this workflow when the user asks for a plan:

1. **Braindump**: Take the user's raw braindump as-is. Don't interrupt or ask questions yet.
2. **Summarize & Confirm**: Summarize and clean up the braindump into a structured overview. Present it back to the user for confirmation. Allow corrections before proceeding.
3. **Save Draft**: Save the summary to `docs/PRD-XXX.md` (where XXX is the next available number, zero-padded to 3 digits). Link the file path so the user can edit directly.
4. **Deep Interview**: Read the saved plan and interview the user in detail. Ask non-obvious, in-depth questions about: technical implementation, UI/UX, concerns, tradeoffs, edge cases, dependencies, security, rollback strategies, and anything else relevant.
5. **Finalize Plan**: Incorporate interview answers and append the final detailed PLAN to the same `docs/PRD-XXX.md`.

General principles:
- Plans should be detailed and actionable. Include the what, why, and how: specifics, code snippets, config examples, and rationale.
- When a task is large or daunting, break the plan into achievable milestones. Each milestone should be independently shippable or verifiable.
- Order from high-level (product, UX) to low-level (architecture, code). Don't mix abstraction levels.
- Think holistically — what other areas or files could be affected?
