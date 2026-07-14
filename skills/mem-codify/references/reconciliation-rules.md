# Reconciliation rules

Apply every section during `$mem-codify`.

## Contents

- Statement outcomes and semantic deduplication
- Canonical ownership and derivative indexes
- Decision records and global decision-log criteria
- Cross-project unresolved questions
- Preference routing
- Canonical source links and atomic archival
- Non-Markdown artifacts and path safety
- Processing report additions
- Required final validation

## Statement outcomes

Assign every meaningful source statement exactly one outcome:

- `integrated-new`
- `merged-existing`
- `updated-existing`
- `preserved-as-history`
- `deferred`
- `not-integrated`
- `conflict-retained`
- `already-codified`

Record the outcome and destination or reason in the processing report. Do not use an unlisted status without explaining it.

A statement receives exactly one outcome but may have multiple destinations. List every destination under that single outcome. Do not assign a separate outcome merely because the statement also updated an index or decision log in addition to its owning canonical note.

## Semantic deduplication

Before adding any fact, preference, action, question, or decision:

1. Search the likely canonical note and related repository files for semantically equivalent content.
2. Treat differently worded statements as duplicates when they describe the same underlying fact, commitment, action, or question.
3. Merge equivalent items into one canonical representation instead of appending another copy.
4. Preserve additional dates, rationale, sources, status, dependencies, and qualifiers from the new material.
5. Do not merge items whose scope, owner, timeframe, status, or certainty differs materially.
6. When equivalence is uncertain, preserve both and flag the possible duplication in the processing report.

### Equivalent facts

- Update an existing fact only when new material adds evidence, precision, a correction, or a newer state.
- Preserve historical values when a fact changed over time.
- Do not replace a dated historical fact with a current fact as though both describe the same point in time.

### Equivalent actions

- Preserve the existing canonical action and merge new owner, due date, status, dependency, or rationale.
- Prefer the most specific wording.
- Do not create a duplicate task merely because it appeared in another conversation.
- Do not reopen a completed action unless new material explicitly establishes that it must be done again.
- Distinguish recurring actions from accidental duplicates.

## Canonical ownership and derivative indexes

Treat indexes as derivative navigation surfaces. The owning canonical note remains authoritative. Index and `HOME.md` entries must link to the owning note and contain only the minimum status or summary needed for navigation. Update derivative entries when the owner changes; do not let an index become an independent source claim or duplicate the canonical history.

## Decision records

For every confirmed decision, record when available: decision, date, status, context, options considered, rationale, expected consequences, trade-offs, reversibility, review trigger or date, and source.

Do not invent missing rationale or consequences. State that they were not recorded when unavailable.

Rationale should preserve relevant constraints, priorities, evidence, rejected options, risks accepted, and risks avoided. Consequences should preserve new commitments, affected projects or areas, downstream changes, costs, dependencies, future constraints, obsolete items, and follow-up work.

### Global decision-log criteria

Add a decision to `50-decisions/decision-log.md` when one or more apply:

- It affects multiple projects or areas.
- It establishes a durable operating principle, policy, or standard.
- It is costly, risky, or difficult to reverse.
- It changes the source of truth, architecture, workflow, or ownership model.
- It explains later decisions or repository structure.
- It replaces or supersedes an earlier meaningful decision.
- It creates a long-term commitment.
- Its rationale is likely to matter later or forgetting it risks repeating the debate.

Do not add routine implementation choices, trivial preferences, temporary experiments, or low-impact task decisions unless the user explicitly requests it. Record confirmed decisions that do not meet these criteria in the relevant project, area, or person note.

## Cross-project unresolved questions

Route a question to `_indexes/unresolved-questions.md` when it affects multiple projects or areas, lacks a clear owner note, blocks broader planning, concerns a shared policy or dependency, should remain visible outside its origin, or may change several canonical notes.

Keep project-specific questions in their project or area note. For an indexed question, record a short question, date raised, originating-note link, affected projects or areas, known owner or dependency, and status. Avoid duplicating the full discussion.

When resolved, record the resolution in the owning canonical note, update or remove the active index entry, add a resolution link, and retain historically relevant question history.

## Preference routing

Store each preference in the relevant person, life area, project, tool, product category, workflow, or environment note. Do not default all preferences to one global profile.

Date a preference when it may change, is context-dependent, or changed from an earlier preference. Stable preferences need a date only when useful for provenance. Never generalize a narrow preference into a universal one.

Before merging similar preferences, compare subject, context, purpose, timeframe, strength, and exceptions. Preserve both when any dimension differs materially. For example, a low-profile-keyboard preference is not equivalent to a full-height-keyboard preference specifically for gaming; a quiet-café work preference is not equivalent to a lively-restaurant dinner preference.

## Canonical source links and archival validation

Every material codified update must retain a traceable source reference under `Sources`, `History`, or the relevant dated entry. Use a stable relative repository path, preserve the source date, and avoid repeating the same source link within one note.

The final link must point to `70-archive/inbox-processed/YYYY/<capture-file>`, not the former `00-inbox` path.

Before marking a source processed, use this atomic sequence:

1. Confirm all durable content and destinations are accounted for.
2. Determine the final year-based archive path and ensure it does not collide with an existing file.
3. Prepare all canonical and index edits in memory, including source links that use the final archive path, without modifying destination files.
4. Record the expected fingerprint of every existing destination. Validate that existing destinations are writable and unchanged, new destinations have writable non-conflicting parents, and no prepared edit overlaps unattributable work.
5. Recheck the source fingerprint and every expected destination fingerprint immediately before moving the source. Stop before the move if any value differs.
6. Move the source to the final path.
7. Atomically write each prepared canonical and index file, using same-directory temporary files and atomic replacement or an environment-provided equivalent rather than truncating a destination in place.
8. Verify source existence, destination contents, and every new link.
9. Only after validation succeeds, add `status: processed`, `processed: YYYY-MM-DD`, and `processed_into:` metadata to the archived Markdown source; validate the archived source again, then report success and the final path.

If a post-move step fails, roll back only changes attributable to this transaction and restore the source to its original inbox path when that can be done safely without overwriting concurrent work. Otherwise, leave the archived source marked unprocessed, report the partial transaction and exact paths, and do not claim success.

If the archive filename already exists and content differs, do not overwrite it. Use a deterministic suffix derived from source identity or stop and report the collision. If source links cannot be updated safely, do not mark the item fully processed.

For a populated `quick-capture.md`, preserve the inventoried source bytes verbatim in the timestamped archived snapshot; never move or link to the permanent stub. In place of step 6, atomically create the snapshot from the inventoried bytes, then continue the sequence and reset the stub only after successful validation. Because changing the snapshot would destroy byte-for-byte provenance, record `status`, `processed`, `processed_into`, the source fingerprint, and validation in a sibling `YYYY-MM-DD-HHMM-quick-capture.processing.md` record. Apply the same collision, source-link, validation, and recovery requirements to the snapshot and its processing record.

## Non-Markdown artifacts and path safety

- Preserve original images, PDFs, JSON files, CSVs, and large binaries in the archive; never mutate binary artifacts or embed large binary content in Markdown.
- Create a Markdown sidecar processing record for artifacts that cannot hold frontmatter. Record original and final paths, media type, content hash when identity matters, `processed_into` destinations, extraction notes, and validation.
- Treat directories as containers to inventory, not single files to move blindly. Process their contained sources explicitly.
- Do not follow symlinks outside the verified authoritative notes repository. Reject traversal paths and any source, archive, canonical-note, or index read or write that escapes its verified root. The sole non-working-tree write is the large-diff review artifact in that notes repository's Git metadata directory, as defined by the main skill.
- Preserve symlinks only when their target is inside the repository and the repository intentionally treats the link as source material; otherwise defer and report it.

## Processing report additions

Include these fields in every processing report. Use `None` when a field has no entries; do not omit it.

```markdown
### Deduplication

- Statement outcomes by source:
- Facts merged:
- Actions merged:
- Potential duplicates preserved for review:

### Decisions

- Decisions added to canonical notes:
- Decisions added to 50-decisions/decision-log.md:
- Decisions not added to the global log and why:
- Missing rationale or consequences:

### Questions

- Project-specific questions retained locally:
- Cross-project questions added to _indexes/unresolved-questions.md:
- Resolved questions removed or updated:

### Preferences

- Preferences added or updated:
- Changeable preferences dated:
- Prior preferences preserved as history:

### Provenance

- Original inbox path:
- Final archive path:
- Canonical files linking to the archived source:
- Source-link validation result:
```

## Required final validation

Verify all of the following:

- The authoritative notes-repository identity was verified before durable reads or writes.
- Every touched note path remained inside the verified root, external repositories remained unchanged, and Git and review-artifact operations were scoped to the verified notes repository.
- Every meaningful statement has one allowed outcome and a destination or reason.
- Equivalent facts and actions were deduplicated.
- Confirmed decisions include rationale and consequences when available.
- Meaningful decisions were evaluated against the global decision-log criteria.
- Cross-project questions were evaluated for `_indexes/unresolved-questions.md`.
- Preferences were stored in the relevant canonical note and changeable preferences were dated.
- Every material codified item has a canonical source reference.
- Source links point to the final archived path and none broke during archival.
- Source identity was checked against archives and canonical links before integration.
- Archive collisions, non-Markdown sidecars, artifact hashes, symlinks, and path boundaries were handled according to this reference.
