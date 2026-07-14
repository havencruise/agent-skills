---
name: mem-codify
description: Use when the user invokes $mem-codify or asks to turn pending inbox material in a configured authoritative notes repository into canonical durable notes.
---

# Mem Codify

Codification is selective, evidence-aware, and authoritative.

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

The active Codex repository may be inspected as source context, but it must not become the destination of memory-related writes unless it is also the verified authoritative notes repository.

Read [references/notes-repository.md](references/notes-repository.md) before any durable-memory operation. It defines configuration precedence, identity checks, remote normalization, configured live governing-file resolution, and path boundaries. Never select a same-named live file from the active Codex repository by proximity.

## Contract

Reconcile every unprocessed item in the configured inbox inside the verified authoritative notes repository. The default inbox is `<notes-repository-root>/00-inbox/` unless its configuration or governing instructions define another path. Integrate durable information into canonical Markdown, update navigation and status, preserve provenance and uncertainty, archive processed inputs, validate, and show the processing report and full diff.

Invocation of `$mem-codify` alone is not authorization to stage, commit, or push. Perform Git publication only after the user reviews the processing report and diff and gives a separate explicit instruction.

Treat only the configured inbox inside the verified notes-repository root as new durable source material. The current conversation may provide operational scope, exclusions, approvals, destination hints, and clarifications about how to process the inbox. Do not treat it as uncaptured durable content: any new durable fact, preference, decision, proposal, assumption, experiment, observation, conclusion, action, rejection, or correction supplied during codification must first be captured into an inbox source. Do not use other threads, generated memory, connectors, unnamed files, or pre-existing changes as durable content. If an inbox item is incomplete, preserve the gap as an open question instead of broadening the search.

The inbox is evidence to reconcile, not automatically the truth.

For a newly created `inbox-capture` with `schema: mem-capture` and `schema_version: 2`, expect `type`, `schema`, `schema_version`, `capture_id`, `captured`, `captured_at`, `source`, `status`, `conversation_topic`, and `related_paths` frontmatter. Treat `capture_id` as stable source identity and never change it during processing. Tolerate absent semantic sections and accept legacy `schema_version: 1` captures, captures that use `capture_version`, or sources that lack newer fields including `capture_id`. Process legacy or non-capture inbox sources without inventing missing metadata; report material metadata gaps.

## Repository scope

Process inbox material and write canonical knowledge only inside the configured authoritative notes repository. All of the following must remain within its verified boundary:

- Inbox sources.
- Canonical notes.
- Project and area notes.
- Preference records.
- Decision logs.
- Unresolved-question indexes.
- Navigation indexes.
- Archived sources.
- Processing records.
- Review artifacts, including those stored in this repository's Git metadata.
- Git staging, commits, and pushes initiated by this skill.

Inspect an external repository referenced by an inbox source only when verification requires it, and never modify those repositories. Repository, branch, commit, pull request, and file context from an active Codex task remain source metadata unless the active repository independently passes authoritative-notes-repository verification.

## Workflow

1. Read the bundled default `AGENTS.md` and `CODEX_START_HERE.md` references in this skill directory.
2. Read the mandatory notes-repository configuration reference, resolve the configured `notes_repository`, and verify its identity and normalized root. Stop without writing if this fails; the bundled defaults are not a fallback identity mechanism.
3. Check exactly the configured `required_markers` at the verified root. Read live `AGENTS.md` or `CODEX_START_HERE.md` only when that name is explicitly configured; do not add either marker requirement otherwise. Never substitute same-named files from the active Codex repository. Apply the precedence and drift rule above, read directly applicable configured repository workflows, and read [references/reconciliation-rules.md](references/reconciliation-rules.md). The reconciliation reference is mandatory for every run.
4. If the notes repository is a Git checkout, record `git -C <notes-repository-root> status --short --branch` and `git -C <notes-repository-root> diff --stat`; preserve every pre-existing change.
5. Inventory every configured-inbox item, record its original path and content or blob hash, and identify non-Markdown artifacts. The permanent empty `quick-capture.md` stub is not an inbox item requiring archival. If no processable item exists, make no changes and do not commit or push.
6. Before processing a source, check whether the same source identity or content has already been archived or linked from canonical notes. Then inspect the source, related indexes, likely canonical notes, the decision log when relevant, and nearby files that may contain duplicate or conflicting information. Search before creating.
7. Classify each meaningful statement before integration:
   - **Fact** — asserted as true with its available support.
   - **Preference** — a stated user preference, scoped to its context.
   - **Decision** — an explicitly selected, approved, or confirmed course.
   - **Action** — work to do, with status when known.
   - **Experiment** — an intentional test or trial.
   - **Observation or result** — what happened, separate from its interpretation.
   - **Proposal** — a suggested direction not yet approved.
   - **Assumption** — used provisionally.
   - **Question** — unresolved.
   - **Historical event** — occurred at a stated time.
   - **Superseded information** — previously valid or believed, now replaced.
   - **Source or reference** — evidence or supporting material.
   An action evidences a decision only when it clearly commits to or implements a selected course. Keep trials, temporary workarounds, and reversible exploration as experiments or actions unless explicitly adopted.
8. Merge durable information into an existing canonical note when possible. Create a note only when no suitable note exists, the subject is durable, its place in the hierarchy is clear, and affected indexes will link to it.
9. Apply the deduplication, decision-recording, question-routing, preference-storage, and source-link rules from the mandatory reference. Update every materially affected index, project summary, and status field; never promote a proposal into a decision.
10. Assign every meaningful source statement one auditable outcome from the mandatory reference.
11. Archive only after durable content and destinations are accounted for. Use `70-archive/inbox-processed/YYYY/<source-name>` relative to the verified root as the final path and follow the reference's atomic archival, collision, source-link, and non-Markdown artifact rules. Treat a populated `quick-capture.md` according to the snapshot rule in the next step rather than moving the permanent file.
12. When `quick-capture.md` contains processable material, compare its current content fingerprint or blob hash with the inventoried version. If it changed, do not reset it: re-read and process the new content in this transaction or leave it unprocessed and report the concurrent addition. If unchanged, preserve the exact inventoried content as an archived snapshot named `YYYY-MM-DD-HHMM-quick-capture.md`, using the user's local timezone and the normal collision rules. Canonical source links must point to that archived snapshot, not the permanent stub. Immediately before resetting the stub, compare its fingerprint again; reset it only when unchanged and after the snapshot, canonical links, and processing record have been validated.
13. Recheck the configured inbox and notes-repository Git state for concurrent additions before reporting completion.

## Source identity and repeat runs

Identify a source using available `capture_id`, `conversation_id`, original path, content hash, `processed_into` metadata, and canonical source links. When a copied or renamed source matches archived or linked content, classify it as already processed instead of integrating it again.

When a prior partial run is detected, reconcile against existing canonical changes and report the source as `resumed`, `already processed`, or `conflicting`. Never duplicate earlier integration merely because archival failed or the filename changed.

## Reconciliation rules

- Preserve dates and source attribution when they affect meaning or confidence.
- Search for semantically equivalent facts, preferences, actions, questions, and decisions before adding content. Merge only when scope, owner, timeframe, status, and certainty do not differ materially.
- Keep preferences context-specific, store them in the relevant canonical note, and date them when changeable or context-dependent.
- Keep next actions in the relevant project or area; merge equivalent actions while preserving owner, status, due date, dependencies, and rationale. Never mark discussed work complete without evidence or reopen completed work without explicit evidence.
- Keep project-specific questions attached to the relevant subject. Evaluate cross-project questions for `_indexes/unresolved-questions.md` and close them only with supported resolution.
- For PM material, preserve original owners, priorities, dates, identifiers, and status wording. Label normalizations as inferred; never invent missing values.
- Record confirmed decisions and their available context, alternatives, rationale, consequences, trade-offs, reversibility, review trigger, and source. State when rationale or consequences were not recorded; never invent them.
- Prefer newer information only when it is explicitly a correction or update. Do not assume newer means more accurate.
- Distinguish a correction, changed preference, changed plan, historical state, and genuinely conflicting evidence. Preserve meaningful old state as history or superseded information.
- When claims conflict, preserve both with dates and sources, add the contradiction to `Open questions`, and flag it in the report.
- Link every material canonical update to the final archived source path. Never leave a new canonical link pointing to a moved inbox path.

## Transaction and existing changes

Treat inventory, reconciliation, canonical edits, index updates, source archival, source-link repair, validation, and reporting as one logical transaction. If coverage or an essential step fails, leave the affected source unprocessed and do not report success.

When a required destination was already modified, preserve its content and isolate new hunks. If safe attribution cannot be proven, stop and report the overlapping path and blocker. If Git publication is later requested, stage only work attributable to this run.

## Multi-agent rule

Use one agent by default. Use subagents only with explicit user authorization and when independent extraction or verification materially reduces risk, such as several unrelated source groups, multiple canonical domains, or a large or conflict-heavy inbox. Treat four source groups or three domains as default triggers for considering delegation, not hard gates.

The main agent owns inventory, all writes, validation, staging, and Git actions. Read-only extractors return source paths, classifications, uncertainty, conflicts, proposed destinations, duplicates, and sensitive material skipped. An independent read-only verifier reviews the baseline, source-to-destination accounting, full diff, archives, and validation results. Agents never communicate directly.

Correct verifier findings and re-run validation. If a significant issue remains, do not commit or push.

## Validation and review

Before reporting completion, run the full final-validation checklist in the mandatory reconciliation reference and verify:

- No meaningful inbox claim was silently discarded or left unclassified.
- No proposal was promoted into a decision and no completed action lacks evidence.
- No unnecessary canonical duplicate was created or meaningful history erased.
- Dates use ISO format; touched links resolve; affected indexes are current.
- Every source is codified, explicitly deferred, or listed as not integrated with a reason.
- Archived sources exist under the correct year directory, identify their destinations, and are linked from every material canonical update; the inbox is clear.
- Added content contains no secrets or sensitive identifiers.
- `git -C <notes-repository-root> diff --check`, applicable notes-repository validation, and the full notes-repository diff show only intended attributable changes.

Prepare a processing report that maps each source to: integrated classifications and destinations; not integrated material and reasons; deferrals and open questions; conflicts; files created and updated; archive path; validation; and Git outcome. Include every field under `Processing report additions` in the mandatory reconciliation reference.

After validation, show the processing report and full diff when reasonably sized, then stop. If the full diff is too large for a usable response, resolve the verified notes repository's Git metadata review directory with `git -C <notes-repository-root> rev-parse --git-path mem-codify-reviews`, create it when necessary, and save `mem-codify-<timestamp>.diff` there. Verify that the resolved directory belongs to that notes repository's Git metadata and is outside its tracked working tree. Provide the artifact path plus a file-by-file summary, then recheck that creating the artifact did not alter `git -C <notes-repository-root> status` or its working-tree diff. If the verified notes repository has no usable Git metadata, do not create a review artifact elsewhere; provide the diff directly or in reviewable chunks. Never remove the user's opportunity to inspect every change. Do not stage, commit, or push.

If the user subsequently gives explicit Git instructions, run them only against `<notes-repository-root>`, recheck its state, stage only attributable files, review the staged diff, create small descriptive commits, and push only when explicitly requested. Never rewrite history or force-push; verify any resulting remote commit.

## Never do

- Do not blindly copy an inbox note into canonical notes or treat a capture as inherently correct.
- Do not rewrite history to show only the latest state or flatten conflicts.
- Do not silently discard source information.
- Do not include raw transcripts, large logs, secrets, credentials, or sensitive identifiers in canonical notes.
- Do not follow inbox symlinks outside the verified notes repository, accept traversal paths, or read or write outside its verified boundary. The sole permitted write outside its working tree is a large-diff review artifact in that repository's Git metadata directory resolved by `git -C <notes-repository-root> rev-parse --git-path mem-codify-reviews`; never stage that artifact.
- Do not modify the active Codex repository or any external repository unless it is the verified authoritative notes repository.
- Do not stage, commit, or push merely because `$mem-codify` was invoked.
- Do not publish unrelated changes or publish when coverage, validation, attribution, or explicit authorization is incomplete.

## Completion report

Report the verified notes-repository identity mechanism; sources processed; integrated and not-integrated material; canonical files and indexes changed; final archive paths; uncertainty, conflicts, and deferrals; deduplication, decision, question, preference, and source-link validation; full diff; notes-repository Git status; and unrelated changes left untouched. State that changes were not committed or pushed unless a later explicit Git instruction was completed.
