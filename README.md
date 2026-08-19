# Agent Skills

Reusable skills for LLM agents.

This repository is intentionally not tied to one agent runtime. Runtime-specific metadata can live beside a skill when useful, such as `agents/openai.yaml` for Codex/OpenAI environments.

## Skills

- `skills/documentation-governance` governs durable-document authority, evidence, dependencies, publication, and retirement.
- `skills/maintenance-surface` reduces unnecessary maintenance surface in code changes and reviews.
- `skills/mem-capture` captures an active agent conversation into a configured authoritative notes repository inbox.
- `skills/mem-codify` processes pending inbox material into canonical durable Markdown notes.

## Install Or Update Skills

Install all skills into the default Codex/OpenAI skills directory:

```sh
scripts/install-skills.sh
```

Install selected skills:

```sh
scripts/install-skills.sh mem-capture mem-codify
```

Install into another folder-based agent runtime:

```sh
scripts/install-skills.sh --target ~/.some-agent/skills --all
```

Preview an update without changing files:

```sh
scripts/install-skills.sh --dry-run
```

When a selected skill is already installed, the installer compares the installed copy with this repository, prints release notes based on the actual changed files, shows the diff, and asks for approval before updating. Identical skills are skipped.

By default, an approved update moves the old installed directory outside the discovery root into a sibling `<target>-backups/` directory before copying the new version. Use `--no-backup` when you want a direct replacement, and `--yes` when you want to approve all updates non-interactively.

To update from this repository later:

```sh
git pull
scripts/install-skills.sh
```

For unattended updates:

```sh
git pull
scripts/install-skills.sh --yes
```

### Rename migration

`documentation-as-design` has been renamed to `documentation-governance`. This is a breaking rename for explicit `$documentation-as-design` invocations and local policy references; update them to `$documentation-governance`.

After updating this repository, install the renamed skill with the repository installer:

```sh
git pull
scripts/install-skills.sh --yes documentation-governance
```

The installer moves a previously installed `documentation-as-design` directory, including same-root backups created by older installer versions, outside the discovery root and installs `documentation-governance`. It does not install a compatibility alias.

## Bootstrap A Memory Repository

Create a new durable memory folder from the starter framework:

```sh
scripts/bootstrap-memory.sh ~/Documents/Personal/memory --name "Personal Memory"
```

To also write a config file used by the memory skills:

```sh
scripts/bootstrap-memory.sh ~/Documents/Personal/memory \
  --config ~/.config/agent-memory/notes-repository.yaml
```

## Configuration

The memory skills require a local notes repository configuration. Start from:

```text
examples/notes-repository.example.yaml
```

Copy it into the configuration location expected by the target runtime and update the local path, expected remote, and required markers for that machine.

Do not commit machine-specific local paths, credentials, or private repository configuration.
