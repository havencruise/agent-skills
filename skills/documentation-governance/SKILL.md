---
name: documentation-governance
description: Govern durable Markdown, DOCX, PDF, plans, reports, handoffs, instructions, and documentation reviews across their lifecycle. Use when Codex creates, revises, consolidates, publishes, supersedes, retires, audits, or evaluates durable artifacts that require canonical authority, evidence traceability, dependency management, controlled derived copies, and safe publication or retirement.
---

# Documentation as Design

Treat durable documentation as maintained system surface. Give each artifact a distinct reader-facing purpose, claim-scoped authority, evidence for material claims, and a coherent lifecycle change set.

## Operating Contract

Perform durable-document work in this order:

1. Inspect applicable repository policy, then existing authority, evidence, and dependents.
2. Complete the evidence-first preflight.
3. Define the lifecycle change set.
4. Verify the safety gates.
5. Execute authorized actions.
6. Validate the authority graph and document mechanics, then report.

Use these terms consistently:

- **Coherent change set:** actions serving one reader-facing durable outcome.
- **Repository documentation policy:** the locally applicable rules for retention, legal or historical evidence, metadata or frontmatter, ownership, publication, and review.
- **Primary action:** the lifecycle action that describes that outcome, not merely the first file edited.
- **Companion action:** a required action whose omission would leave duplicate authority, lost evidence, broken references, stale copies, or outdated generated outputs.
- **Authoritative owner:** the location amended when a governed value changes and the source that governs any derived copy.
- **Authority graph:** the bounded map connecting authoritative owners, supporting evidence, derived copies, successors, dependents, and generated outputs.
- **Derived operational copy:** semantically faithful content repeated locally for safe action without acquiring authority.
- **Resolvable successor:** a successor that exists after the change, is accessible to intended readers, and unambiguously identifies the active authority.
- **Unique evidence:** retained decisions, rationale, dates, provenance, results, exceptions, and unresolved contradictions.
- **Refresh trigger:** an observable event requiring reverification and a defined response.
- **Stale artifact:** an artifact whose refresh trigger has occurred since its last supported verification, whose governed content diverges from its owner, or whose repository-defined review limit has expired.

## Repository Policy Input

Before applying this skill's generic defaults, inspect documentation policy that applies to the target path:

1. Establish the policy boundary as the version-control root when present; otherwise use the user-scoped working directory or source set. Read repository instructions and only the directory-scoped instructions inherited by each target path; do not apply sibling-scoped policy outside its subtree.
2. Inspect documentation policies, accepted decisions, systems-of-record declarations, and controlling contracts.
3. Inspect schemas, templates, frontmatter validators, linters, generation or publication tooling, and index conventions for enforced requirements.
4. Identify applicable retention, legal-evidence, ownership, publication, and review-cadence rules.

Record the inspected locations, their applicable scope, and the requirements that affect the work in the active context. Treat an observed pattern in one document as evidence to investigate, not as policy by itself.

Apply repository policy wherever it speaks; use this skill's defaults only where applicable policy is silent. Use the repository's declared scoping and precedence rules when policies differ. If applicable policies conflict and no local rule resolves them, preserve each sourced requirement and block any destructive, authoritative, or publication action that depends on choosing one. When policy is absent or inaccessible, state what was inspected and the resulting coverage boundary; do not invent a retention schedule, archive cadence, metadata format, owner, or publication rule.

## Evidence-First Preflight

Before every creation or revision, record:

~~~markdown
Preflight
- Loss if absent:
- Reliance and stale harm:
- Source precedence:
- Dependents and generated outputs:
- Stale when:
~~~

Use every answer:

- **Loss** determines whether a durable artifact is justified.
- **Reliance and stale harm** determine verification depth.
- **Source precedence** determines authority and conflict treatment.
- **Dependents and generated outputs** determine companion actions.
- **Stale when** determines review and refresh behavior.

Scale the evidence by consequence, uncertainty, dependency reach, and reversibility. For local, reversible, low-consequence edits, use concise answers and a focused search. For a spelling- or formatting-only revision, concise **unchanged** or **not applicable** answers are sufficient when meaning, authority, dependencies, and staleness controls are unaffected. Explicitly surface the full preflight before canonical, operational, contractual, destructive, conflicting, cross-boundary, or dependency-heavy work. For routine edits, summarize the conclusions at completion.

When an answer is **none** or **not found**, name what was inspected. If nothing durable would be lost, choose **no durable artifact** or update an existing owner instead of creating a file.

Determine source precedence using the applicable repository policy, accepted decisions, designated systems of record, or controlling contracts found during policy inspection. Distinguish prescriptive intended behavior from descriptive current state; neither automatically overrides the other. Do not infer precedence from recency, title, file type, or proximity. If precedence remains unresolved, preserve every sourced claim and block any authoritative rewrite or destructive action that depends on choosing a winner.

Keep the preflight in the active work context. Persist only information that readers need; do not add a boilerplate preflight section, generic metadata block, or sidecar merely to record the process.

## Lifecycle Change Set

Choose one primary action for each coherent outcome, then add zero or more required companion actions:

~~~markdown
Lifecycle change set
- State: proposed | performed | blocked
- Primary: <action> — <target and intended outcome>
- Companions:
  - <action> — <target>; required because <reason>; status <state>
  - none
- Safety evidence:
  - <condition and supporting evidence>
~~~

Choose the primary action by outcome:

- **create** — a distinct durable reader, decision, contract, or evidence need has no suitable owner;
- **update** — one existing canonical artifact remains the owner;
- **consolidate** — material from multiple active sources becomes one owner;
- **supersede** — replacement, rather than merging multiple active sources, is the main outcome;
- **delete** — removing an artifact with no retained value is the main outcome;
- **no durable artifact** — no persistent artifact mutation is needed.

Include all and only the actions required to complete the primary outcome. Name each companion's target and reason. Use lifecycle actions for durable artifacts and explicit dependency actions such as relink, refresh, regenerate, or invalidate. A companion is mandatory when omitting it would leave duplicate active authority, strand readers at an obsolete source, discard unique evidence, break a reference, or leave a copy or generated output stale.

For **consolidate**, name the destination and every input. Give each input one disposition: **supersede** when history or a durable redirect is needed, **delete** when no unique retained content or dependency remains, or **update/retain as derived** when point-of-action usability still requires a sourced local copy.

Split unrelated outcomes into separate change sets. Do not smuggle opportunistic cleanup into companions. **No durable artifact** cannot conceal another durable mutation; if an existing artifact changes, make that change the primary action.

Example:

~~~markdown
- Primary: consolidate
- Companions: supersede old-runbook.md; delete duplicate-notes.md
- Safety: successor resolves, unique history and evidence are retained, and dependents are updated
~~~

## Authority and Intentional Operational Copies

Assign one authoritative owner to each material fact, decision, contract, command, threshold, emergency rule, interface value, or result. Treat overlapping owners as a conflict, not intentional duplication.

Permit the smallest complete local operational unit needed to act safely without impractical or unsafe indirection. Include the relevant scope, prerequisites, action or value, and stop or success conditions. Preserve the owner's meaning exactly. Treat a meaning-changing adaptation as a separately authorized local rule with its own rationale, not as a derived copy.

Verify each derived copy against its owner during the current revision. Place provenance at the nearest unambiguous scope:

- When one external source and one trigger govern the whole artifact, use document-level **Canonical source** and **Review trigger**.
- When an artifact owns its primary concern but imports commands, thresholds, or interface values, use **Canonical source: self** for the owned concern and annotate the imported content locally.
- When sources or triggers differ, annotate the relevant section, table row, or operational block.

Use this exact compact form whenever local attribution is required:

~~~markdown
Derived from: <resolvable source and relevant section or version>
Refresh trigger: <observable event> → <revalidate, update, regenerate, or invalidate>
~~~

Do not substitute a combined provenance paragraph or only a document-level review trigger when different source-and-trigger groups govern different items.

Use a path, stable anchor, version, or approved external source precise enough to locate and reverify the governed content. Make each refresh trigger identify both the observable change surface and the required response. Reject circular source chains.

When a trigger occurs, refresh the copy in the same change or mark it stale and unresolved. Never silently present an unverifiable action-critical copy as current. Allow no refresh event only for immutable evidence; explain why it is immutable and how later evidence will be appended or linked without rewriting history.

Treat provenance as maintenance information, not as a requirement that an operator navigate elsewhere during an incident. Keep enough local context for safe action even when the authoritative source is temporarily unavailable.

## Design Principles

- **Single responsibility and separation of concerns:** let each artifact type own one concern. Do not combine decision rationale, detailed implementation, scheduling, task steps, and proof evidence without a current reader need.
- **KISS and YAGNI:** use the smallest useful structure. Include a section, table, diagram, or appendix only when it improves a current decision, action, comparison, contract, or verification.
- **Cohesion and low coupling:** keep the artifact focused; split only when audience, authority, update cadence, or lifecycle genuinely differs.
- **Fail fast and explicit uncertainty:** mark missing evidence, assumptions, contradictions, and unresolved decisions rather than inventing prose or placeholder content.
- **Testability and observability:** make material claims traceable to a source, requirement, command result, or explicit decision.

Do not create a document because a file count, template, or familiar process implies one should exist.

## Editing, Dependencies, and Safety

Inspect the changed material, its authoritative owners, and its dependents. Search the bounded source set for:

- outgoing links;
- incoming references by path, title, anchor, and distinctive copied text;
- indexes and navigation;
- generation scripts or manifests;
- derived formats and published outputs.

Give every discovered dependent a disposition: **update**, **relink**, **regenerate**, **invalidate**, or **no change** with a reason. Report inaccessible external boundaries and do not claim complete dependency coverage.

During the reduction pass, remove stale claims, parallel authority, unattributed or unjustified duplication, irrelevant sections, filler tables, unsupported placeholders, and obsolete detail. Preserve verified history, supported contracts, and justified operational copies with resolvable sources and refresh triggers.

Never infer consolidation, supersession, or deletion from title similarity alone. Before superseding or deleting:

1. Inventory unique facts, decisions, evidence, dates, rationale, provenance, exceptions, and contradictions.
2. Map retained material to a named successor or approved evidence location.
3. Create or update the successor first.
4. Verify that intended readers can resolve it.
5. Repair references, refresh operational copies, and regenerate derived outputs.
6. Perform destructive disposition last.

Supersede when reader-visible history or a durable redirect remains necessary. Delete only when no unique durable content or unmet dependency remains. Git history alone does not satisfy reader-facing retention unless repository policy explicitly says it does.

If evidence, authority, or dependency coverage is incomplete, leave the predecessor intact and report the action as blocked. When an inaccessible or externally owned dependent cannot be updated, mark the change set incomplete; do not claim successful consolidation or supersession while readers can still encounter contradictory active material.

## Authority Graph Review

Build the bounded authority graph during initial inspection. Review it before any safety-gated mutation and again after execution. Include these relationships when present:

- **governs** — an owner controls a material claim, decision, command, threshold, contract, interface value, or result;
- **supports** — evidence substantiates a material claim or decision;
- **derived from** — an operational copy or publication repeats governed content;
- **replaced by** — a superseded artifact redirects readers to its successor;
- **depends on** — a reader-facing artifact, index, script, or system consumes the owner;
- **generates** — an editable source or process produces an output.

Perform and record this review:

~~~markdown
Authority graph review
- Applicable repository policy:
- Changed authoritative owners:
- Canonical sources and successors resolved:
- Material claims and decisions traced to evidence:
- Affected dependents and output dispositions:
- Refresh triggers evaluated:
- Stale or unverifiable derived copies:
- Parallel owners, cycles, or unresolved conflicts:
- Inaccessible boundaries:
~~~

Resolve every local canonical-source, **Derived from**, and successor reference from the directory of the artifact containing it unless repository policy explicitly defines repository-root-relative syntax. Open the computed target and verify any supplied anchor and governed content before marking the reference resolved; a same-named file or search hit elsewhere is not resolution. Verify that approved external sources are accessible to the intended readers or record the boundary as inaccessible. A successor must identify the active authority, not merely any existing file.

Trace each material claim or decision that affects a reader's decision, action, contract, or interpretation of results to a source, requirement, command result, accepted decision, or explicit provenance statement. When traceability is absent, label the content as an unsupported assumption or unresolved claim; do not present it as settled authority.

Start with every changed owner and trace inbound references, derived copies, operational procedures, generation inputs, indexes, and publications. Give every affected dependent one disposition: **update**, **relink**, **regenerate**, **invalidate**, or **no change** with reason.

Evaluate each refresh trigger against observable changes since the last supported verification. Mark a derived copy stale when its trigger has occurred, it diverges from its owner, or an applicable review limit has expired. Mark it unverifiable when the owner, trigger state, or verification evidence cannot be inspected. Refresh an action-critical copy in the same change or mark it stale and unresolved.

Treat unresolved canonical sources, missing successors, unsupported material decisions, action-critical stale copies, authority cycles, parallel owners, and undispositioned affected dependencies as blocking for the actions they make unsafe. Preserve the affected artifacts and report the needed evidence or decision. Do not claim complete graph coverage across inaccessible boundaries.

## Repository Conventions and Document Control

Use the repository's required frontmatter, status, ownership, retention, publication, and review conventions. Do not add this skill's metadata when local policy already supplies lifecycle control in another form.

If applicable policy is silent and a newly created or substantively revised long-lived artifact needs explicit lifecycle control, use this compact fallback. Do not retrofit unchanged legacy documents solely to add metadata.

~~~markdown
## Document control

- Role: authoritative | execution | evidence | handoff
- Status: draft | active | completed | superseded
- Canonical source: self | [path or approved external source]
- Replaced by: [path] # required only when superseded
- Review trigger: [observable source change, decision, or event → required response]
~~~

Use **Canonical source** for the owner of the artifact's primary document-level concern. Use **self** only when the artifact owns that concern; annotate any differently owned content at its nearest scope. A superseded artifact must name a resolvable successor.

Treat generated PDFs as derived publications. Revise the editable canonical source and make PDF regeneration a companion action instead of maintaining parallel authority. When repository policy or a controlling contract designates a signed or final PDF as immutable evidence, preserve it unchanged and append or link later corrections according to that policy.

## Validation

For Markdown repositories, run the bundled read-only helper after drafting or during an audit. Set `SKILL_DIR` to the installed directory that contains this `SKILL.md`; do not assume the target repository contains the helper:

~~~bash
python3 "$SKILL_DIR/scripts/check_markdown_quality.py" --root <repository> --tracked-only --format json
~~~

`--tracked-only` requires Git and a Git worktree; omit it to scan an ordinary directory. The helper has no built-in repository layout: optionally add `--role-prefix <role>=<root-relative-prefix>` for legacy documents and `--exclude-prefix <root-relative-prefix>` for intentional non-document trees.

The helper mechanically checks ordinary Markdown local links and anchors, fields in this skill's fallback control block, and declared successor presence and local existence. It records some relationships but does not traverse or validate the authority graph. In particular, manually review bare or backticked canonical-source values, external accessibility, evidence sufficiency, policy applicability, affected-dependency completeness, cycles, trigger state, and derived-copy freshness.

Treat the helper's `recommended_action` as a per-document mechanical recommendation, not as the primary or companion lifecycle action. A passing result does not satisfy the authority graph review or prove authority, precedence, evidence retention, dependency completeness, or derived-copy freshness.

For DOCX/PDF work, apply this lifecycle and semantic review alongside the relevant render, accessibility, and source-fidelity checks.

## Completion Report

Report:

~~~markdown
Completion
- State: proposed | performed | blocked
- Repository policy inspected and applied:
- Preflight conclusions:
- Primary: <action> — <target>; status <state>
- Companions:
  - <action> — <target>; reason <reason>; status <state>
  - none
- Safety evidence:
- Authority graph review:
- Authoritative owners:
- Derived copies, sources, and refresh triggers:
- Stale or unverifiable copies:
- Dependents and generated outputs:
- Retained uncertainty, conflicts, or inaccessible boundaries:
- Validation:
~~~

Use every field for canonical, operational, contractual, destructive, conflicting, cross-boundary, or dependency-heavy work; write **none** with inspected evidence rather than omitting a field. For routine edits, compress unchanged conclusions while retaining the state, applied policy, primary and companion results, authority-graph result, boundaries, and validation. Use **proposed** during audits, reviews, and plans that do not authorize mutation, **performed** only for completed actions, and **blocked** for unmet safety conditions.

Do not create a sidecar artifact merely to record this report.
