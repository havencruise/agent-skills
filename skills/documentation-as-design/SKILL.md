---
name: documentation-as-design
description: Apply design principles and lifecycle discipline to durable Markdown, DOCX, PDF, plans, reports, handoffs, instructions, and documentation reviews. Use when Codex creates, edits, consolidates, supersedes, audits, publishes, or evaluates a durable artifact that another person or agent will rely on.
---

# Documentation as Design

Treat durable documentation as maintained system surface. It must have a distinct reader-facing purpose, a canonical source, evidence for its material claims, and a lifecycle action.

## Decide Before Drafting

Search the relevant repository or source set for existing authoritative material. Then choose exactly one action:

- **create** — no existing artifact can serve a distinct durable reader, decision, contract, or evidence need;
- **update** — the existing canonical artifact remains authoritative;
- **consolidate** — multiple active sources can become one canonical source;
- **supersede** — durable history must remain visible but a named successor replaces it;
- **delete** — an ephemeral or duplicate artifact has no unique retained decision or evidence;
- **no durable artifact** — a response, patch description, or temporary handoff is sufficient.

Do not create a document because a file count, template, or familiar process implies one should exist.

## Design Principles

- **Single responsibility and separation of concerns:** each artifact type owns one concern. Do not put decision rationale, detailed implementation, scheduling, task steps, and proof evidence into the same document without a current reader need.
- **DRY and source of truth:** state a fact, decision, contract, or result authoritatively once; downstream artifacts link and summarize only what their reader needs.
- **KISS and YAGNI:** use the smallest useful structure. Include a section, table, diagram, or appendix only when it improves a current decision, action, comparison, contract, or verification.
- **Cohesion and low coupling:** keep the artifact focused; split only when audience, authority, update cadence, or lifecycle genuinely differs.
- **Fail fast and explicit uncertainty:** mark missing evidence, assumptions, contradictions, and unresolved decisions rather than inventing prose or placeholder content.
- **Testability and observability:** make material claims traceable to a source, requirement, command result, or explicit decision.

## Editing and Reduction Pass

When editing a document, inspect the changed material and its canonical/dependent artifacts. Remove or consolidate stale claims, duplicate authority, irrelevant sections, filler tables, obsolete history, unsupported placeholders, and copy-pasted implementation detail. Preserve verified historical facts and supported external contracts.

Never infer a deletion, consolidation, or supersession from title similarity alone. Require explicit authority, evidence, and—when applicable—a safe successor.

## Long-Lived Document Control

For a newly created or substantively revised long-lived artifact, add this compact block. Do not retrofit unchanged legacy documents solely to add metadata.

```markdown
## Document control

- Role: authoritative | execution | evidence | handoff
- Status: draft | active | completed | superseded
- Canonical source: self | [path or approved external source]
- Replaced by: [path] # required only when superseded
- Review trigger: [source change, decision, or event]
```

Use `self` only when the artifact itself is the canonical source. A superseded artifact must name a resolvable successor. PDFs are derived publications: revise the editable canonical source and regenerate the PDF instead of maintaining parallel authority.

## Validation

For Markdown repositories, run the bundled read-only helper after drafting or during an audit. Set `SKILL_DIR` to the installed directory that contains this `SKILL.md`; do not assume the target repository contains the helper:

```bash
python3 "$SKILL_DIR/scripts/check_markdown_quality.py" --root <repository> --tracked-only --format json
```

`--tracked-only` requires Git and a Git worktree; omit it to scan an ordinary directory. The helper has no built-in repository layout: optionally add `--role-prefix <role>=<root-relative-prefix>` for legacy documents and `--exclude-prefix <root-relative-prefix>` for intentional non-document trees. The helper checks mechanical signals only. Apply this skill's semantic rubric to decide whether an artifact is necessary, appropriately scoped, or genuinely duplicate.

For DOCX/PDF work, apply this lifecycle and semantic review alongside the relevant render, accessibility, and source-fidelity checks.

## Completion Check

Report the chosen lifecycle action, canonical source, content removed or consolidated, retained uncertainty, and validation result. Do not create a sidecar artifact merely to record this check.
