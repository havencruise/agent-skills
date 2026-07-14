---
name: mem-capture
description: Use when the user invokes $mem-capture or asks to preserve the current Codex conversation and explicitly named artifacts in a configured authoritative notes repository before later codification.
---

# Mem Capture

Capture is loss-aware and non-authoritative.

## Default governing references

At the start of every run, read this skill's bundled default references: [references/AGENTS.md](references/AGENTS.md) and [references/CODEX_START_HERE.md](references/CODEX_START_HERE.md). These per-skill copies make the default operating guidance available regardless of the active working directory.

Apply governing instructions in this order: direct user instructions, verified live repository instructions, then the bundled default references. After verifying the authoritative notes repository, read live `AGENTS.md` or `CODEX_START_HERE.md` only when they are explicitly configured as required markers. If a configured live file differs from its bundled copy, follow the live file for repository-specific behavior and report the drift. The bundled copies cannot satisfy repository identity verification, replace configured markers, authorize writes, or weaken the authoritative-repository, path-safety, and Git-authorization rules in this skill.

## Authoritative notes repository

All durable-memory operations must target one configured authoritative notes repository.

The authoritative notes repository may have any name and may exist at any local path. Do not assume that it is named `prashanth-memory`, is the current working repository, or is located under a particular home-directory path.

Before reading or writing durable notes:

1. Resolve the configured notes repository.
2. Verify its repository identity.
3. Resolve all note paths relative to its verified root.
4. Confirm that every normalized read or write path remains inside that root.
5. Stop without writing when the configured repository cannot be resolved or verified.

Never fall back to:

- The current working repository.
- The repository associated with the active Codex conversation.
- The first repository found with a matching directory name.
- A newly created notes directory.
- A temporary directory.
- Any repository that has not passed identity verification.

The active Codex repository may be captured as source context, but it must not become the destination of memory-related writes unless it is also the verified authoritative notes repository.

Read [references/notes-repository.md](references/notes-repository.md) before any durable-memory operation. It defines configuration precedence, identity checks, remote normalization, configured live governing-file resolution, and path boundaries. Never select a same-named live file from the active Codex repository by proximity.

## Contract

Capture the current Codex conversation into one self-contained, loss-minimized Markdown note inside the verified authoritative notes repository for later processing by `$mem-codify`. Favor high recall and minimal judgment. Do not update canonical notes, resolve contradictions, or promote proposals into decisions.

Use only the current conversation and files, images, links, local paths, commands, or outputs explicitly named, attached, or produced here. Read existing inbox notes only to identify an earlier capture of this same conversation. Do not search other threads, generated Codex memory, connectors, repositories, or external sources for additional context. An explicitly named external artifact may be opened when needed, but do not traverse beyond that artifact or inspect neighboring paths.

This boundary keeps capture predictable and leaves historical retrieval or broad import to a separate skill.

## Write boundary

Create or append to exactly one inbox capture inside the configured authoritative notes repository. The default destination is `<notes-repository-root>/00-inbox/` unless the notes-repository configuration or its governing instructions define a different inbox path.

Do not write the capture into the active Codex working repository unless it is also the verified authoritative notes repository. Repository, branch, commit, pull request, and file context from the active Codex task are source metadata only.

## Capture and conversation identity

For every new capture, generate a stable unique `capture_id`, such as a locally generated collision-resistant UUID, and preserve it unchanged across addenda. Use a platform-provided identifier as `conversation_id` when available. Do not invent a value that appears platform-issued.

Identify an earlier capture of the same conversation in this order:

1. Matching `conversation_id`.
2. Matching stable platform conversation URL or identifier.
3. A prior capture explicitly identified by the current invocation.
4. Strong agreement among repository, project, branch, topic, capture time, and already-captured content.

Never append based only on a similar title or topic. When identity is uncertain, create a new capture and report the possible relationship.

## Must capture

- User-provided facts and user-stated preferences.
- Confirmed decisions.
- Proposals and recommendations.
- Assumptions used during reasoning.
- Experiments performed and observations or results produced.
- Conclusions reached.
- Rejected options and why they were rejected.
- Work actually performed and its observed result.
- Next actions, owners, dates, dependencies, and status when stated.
- Unresolved questions.
- Corrections to earlier statements and facts.
- Relevant URLs, files, artifacts, commands, and outputs. Preserve full output when it is material evidence or is needed to reproduce or understand the result.
- Source context needed to understand the note later.

Preserve uncertainty and the distinction between facts, preferences, decisions, proposals, assumptions, experiments, observations, conclusions, actions, and questions. Only label something as a decision when the user explicitly selected, approved, or confirmed a course.

An action may evidence a decision only when it clearly commits to or implements a selected course. Experiments, trials, temporary workarounds, and reversible exploratory steps remain actions or experiments unless explicitly adopted.

Never infer that agreement with an explanation is a decision, a recommendation is user intent, a discussed action was completed, a file changed without evidence, or silence is acceptance.

Preserve chronology where it matters, especially for corrections, changed decisions, rejected proposals, work performed, and evidence that superseded an earlier claim. For these cases, add short ISO-dated entries under `Conversation progression`.

## May omit

- Greetings and conversational filler.
- Repeated acknowledgements.
- Failed wording attempts with no lasting value.
- Verbose reasoning that did not affect the outcome.
- Tool mechanics that do not matter later.

Do not omit uncertainty, disagreement, rejected choices, or context merely to make the note shorter.

## Workflow

1. Read the bundled default `AGENTS.md` and `CODEX_START_HERE.md` references in this skill directory.
2. Read the mandatory notes-repository configuration reference, resolve the configured `notes_repository`, and verify its identity and normalized root. Stop without writing if this fails; the bundled defaults are not a fallback identity mechanism.
3. Check exactly the configured `required_markers` at the verified root. Read live `AGENTS.md` or `CODEX_START_HERE.md` only when that name is explicitly configured; do not add either marker requirement otherwise. Never substitute same-named files from the active Codex repository. Apply the precedence and drift rule above.
4. If the notes repository is a Git checkout, record `git -C <notes-repository-root> status --short --branch`; preserve every pre-existing change. Record active-task Git context separately only when it is useful source metadata.
5. Inspect the complete current conversation and explicitly named artifacts.
6. Check the configured inbox inside the verified root for an earlier capture using the conversation-identity order above.
7. For a first capture, generate its `capture_id` and create `YYYY-MM-DD-HHMM-<conversation-title>.md` inside that inbox, using a filesystem-safe slug of the current conversation title. Use the user's local timezone for the filename date and time, `captured`, `captured_at`, and addendum timestamps. If no title is available, derive a short topic slug from the conversation.
8. If the same conversation was captured earlier, append only newly emerged information under an ISO timestamped addendum, preserve its `capture_id` unchanged, update `last_captured_at`, and never duplicate the entire note, overwrite a capture, or rewrite an earlier state because later information differs.
9. Check epistemic labels, chronology, coverage, sensitive information, and the normalized destination boundary, then write exactly one inbox file and no other file.

Use this required frontmatter:

```yaml
---
type: inbox-capture
schema: mem-capture
schema_version: 2
capture_id: UUID
captured: YYYY-MM-DD
captured_at: YYYY-MM-DDTHH:MM:SS±HH:MM
source: codex-conversation
status: unprocessed
conversation_topic: Topic
related_paths: []
---
```

Include these optional fields whenever their value is known and applicable to the conversation:

```yaml
conversation_id: ID
last_captured_message: ID-or-timestamp
last_captured_at: YYYY-MM-DDTHH:MM:SS±HH:MM
project: Project
repository: Repository-name-or-relative-path
branch: Branch
commit: Commit-SHA
working_tree_status: Summary
```

Use the semantic categories below, but omit empty headings from the rendered note. The `schema` and `schema_version` fields define the contract; `$mem-codify` must tolerate absent sections.

```markdown
# Conversation capture: <conversation_topic>

## Context
## Conversation progression
## Facts
## Preferences
## Decisions
## Proposals
## Assumptions
## Experiments and observations
## Conclusions
## Rejected options
## Work performed
## Next actions
## Open questions
## Corrections and superseded statements
## Sources and artifacts
```

Redact passwords, tokens, private keys, SSNs, full account numbers, and similar secrets with a typed marker such as `[REDACTED—credential]`. Note the omission without reproducing the value. Link to an approved source location instead of copying a large private document.

## Quality gate

Before finishing, ask: Could a future agent understand what happened, what was actually decided, and what remains unresolved without reopening the original conversation?

If not, add the missing context. Verify that one inbox file changed, no canonical file changed, and no source state was silently lost.

## Multi-agent rule

Use one agent by default. Use subagents only with explicit user authorization and when independent extraction materially reduces risk, such as two or more source groups or a conflict-heavy conversation. Treat two source groups as a default trigger for considering delegation, not a hard gate. Subagents are read-only extractors; the main agent alone reconciles overlaps and writes the capture. Subagents never edit the repository or communicate directly with one another.

## Never do

- Do not edit canonical notes, indexes, decisions, or PM records.
- Do not process, reset, archive, or delete inbox material.
- Do not resolve contradictions or reinterpret tentative language as certainty.
- Do not stage, commit, or push.
- Do not write outside the verified authoritative notes-repository root, follow inbox symlinks outside it, or accept traversal paths.
- Do not broaden the source boundary without explicit user direction.

## Completion report

Report the verified notes-repository identity mechanism, exact inbox path, whether it was created or appended, and the number of captured entries under each non-empty semantic category. Do not count clauses inside one entry separately unless they were deliberately split into separate entries. Also report uncertainty retained, redactions or low-value material omitted, and any source artifact that could not be read. Confirm that no canonical notes, other inbox files, external repositories, or Git history were changed.
