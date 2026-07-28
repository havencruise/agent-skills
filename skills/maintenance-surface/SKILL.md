---
name: maintenance-surface
description: Apply a rigorous maintenance-surface reduction policy to code implementation, bug fixes, refactoring, and code review. Use when Codex adds or changes production code, resolves defects, restructures modules, or evaluates whether an implementation contains unnecessary complexity, duplication, obsolete paths, flags, wrappers, tests, or abstractions.
---

# Maintenance Surface

Keep the implementation correct while actively reducing unnecessary future maintenance. Prefer a smaller, clearer, behaviorally sufficient system over additive patches.

## Required Workflow

1. Identify the changed behavior, its supported consumers, and the observable behavior that must remain true.
2. Search the affected implementation path before adding code. Locate existing equivalents, duplicate rules, obsolete paths, compatibility shims, unused flags, wrappers, helpers, imports, tests, fixtures, and comments.
3. Choose the smallest sufficient change:
   - extend or simplify a correct existing path before adding another;
   - consolidate duplicated behavior when it has a shared responsibility;
   - remove redundant in-scope code when replacement behavior is verified;
   - retain complexity only for a current consumer, explicit requirement, verified compatibility need, or evidence-backed material risk.
4. Verify that cleanup preserves accepted behavior with focused tests and the applicable quality checks.

## Decisions and Boundaries

- Do not remove code outside confirmed scope merely because it looks suspicious; report it separately.
- Do not remove a supported behavior, active consumer path, migration, compatibility contract, or evidence-backed fallback without an explicit scope decision.
- Do not create a new abstraction, mode, adapter, configuration switch, or fallback solely to anticipate a future need.
- Do not preserve a superseded implementation in comments or as dead code. Use version control for history.
- Do not optimize for line-count reduction at the expense of clarity, correctness, security, or a real boundary.

## Completion Check

Before completion, state a concise maintenance-surface assessment:

- **Removed or consolidated:** the in-scope surface reduced, or `none`.
- **Retained deliberately:** complexity kept and its current justification.
- **No safe reduction:** when the change only adds code, the evidence that made reduction unsafe or inapplicable.
- **Proof:** the tests or checks that preserve the required behavior.

The assessment belongs in the task result, review, or implementation summary; do not create a durable document solely to record it.
