# Repository instructions

This repository is the user's durable personal knowledge base.

## Core rules

- Markdown files are the source of truth.
- Never silently delete meaningful information.
- Preserve dates, distinctions, and historical context.
- Separate facts, assumptions, decisions, recommendations, and open questions.
- Prefer updating an existing canonical note over creating duplicates.
- Record meaningful decisions in `50-decisions/decision-log.md`.
- Use ISO dates: `YYYY-MM-DD`.
- Keep summaries concise but complete.
- Do not store passwords, authentication tokens, SSNs, full account numbers, private keys, medical identifiers, or similar secrets.

## Processing inbox material

1. Read all unprocessed material in `00-inbox`.
2. Identify the correct area, project, person, resource, or decision file.
3. Merge durable information into an existing canonical note where possible.
4. Preserve source dates and uncertainty.
5. Update relevant indexes.
6. Move processed source material to `70-archive/inbox-processed/`.
7. Produce a change summary before committing.
8. Do not commit or push unless explicitly requested.

## Writing standards

Use these headings when useful:

- Summary
- Current state
- Facts
- Decisions
- Next actions
- Open questions
- History
- Sources

## Conflict handling

When two notes conflict:

- Do not guess.
- Preserve both claims.
- Add them under `Open questions`.
- Include dates and sources.
- Flag the contradiction in the change summary.

## Git

- Make small, descriptive commits.
- Never rewrite history.
- Never force-push.
- Do not push without explicit permission.
