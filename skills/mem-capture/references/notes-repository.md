# Notes repository configuration

Read this reference before any durable-memory read or write.

## Configuration source

Resolve `notes_repository` using this precedence:

1. A `notes_repository` mapping explicitly supplied in the current invocation.
2. A configuration file path supplied in the current invocation.
3. The path in the `MEM_NOTES_CONFIG` environment variable.
4. `${XDG_CONFIG_HOME:-$HOME/.config}/agent-memory/notes-repository.yaml`.
5. `$HOME/.codex/notes-repository.yaml` for Codex/OpenAI compatibility.

Use the first available valid source. At each precedence level, resolve and normalize every source present before choosing one. If more than one source at the same precedence level is present and their resolved configurations differ, stop without writing and report the conflict. Equivalent resolved configurations at the same level are one source for precedence purposes.

Do not search the filesystem, infer configuration from the active working directory, or continue to lower-precedence sources after selecting a valid configuration. The bundled example file is never active configuration.

```yaml
notes_repository:
  local_path: /absolute/or/user-expanded/path
  expected_remote: optional Git remote URL
  required_markers:
    - AGENTS.md
    - CODEX_START_HERE.md
```

The shared `examples/notes-repository.example.yaml` file is only a template.

## Field semantics

- `local_path` is the preferred local checkout path. Expand `~` and referenced environment variables without executing shell text, then resolve symlinks and normalize it to an absolute path.
- `expected_remote` is optional. When present, verify that one configured Git remote for the candidate repository matches it. For GitHub remotes, normalize equivalent SCP-style SSH, `ssh://`, and HTTPS forms; normalize the host, remove credentials, trailing slash, and optional `.git`, then compare the owner and repository path.
- `required_markers` lists files or directories that must exist at the candidate root. The skill must check exactly the configured markers and must not silently add marker requirements.

At least one strong identity mechanism must be configured:

- A matching `expected_remote`; or
- A sufficiently specific `required_markers` set.

A local path locates a candidate but does not prove identity. If a Git checkout is used, verify that its normalized top-level path is the candidate root rather than a parent or neighboring repository.

When `AGENTS.md` or `CODEX_START_HERE.md` is explicitly listed in `required_markers`, check and read that exact live file from the verified root. When either name is not configured, do not silently require it or use a same-named file from the active Codex repository; use the bundled per-skill default reference instead.

## Boundary validation

Resolve every inbox, canonical-note, index, archive, and processing-record path relative to the verified root. Normalize each path before use and reject symlink or traversal resolution outside the root. Recheck the boundary before every write or move.

Run Git operations only with the verified root as their explicit working repository. Repository-owned Git metadata returned by a Git command scoped to that root is part of the verified repository boundary only for Git operations and the codification review artifact. Verify that association before use. No durable note may be stored in Git metadata.

The active Codex repository and explicitly referenced external repositories are source context only unless identity verification proves that one is the configured authoritative notes repository.
