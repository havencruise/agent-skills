#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bootstrap-memory.sh DEST [options]

Create a fresh durable memory repository from the bundled template.

Options:
  --name NAME            Repository display name. Default: Personal Memory
  --owner NAME           Optional owner name used in AGENTS.md.
  --remote URL           Optional expected Git remote for generated skill config.
  --config PATH          Write a notes-repository config YAML to PATH.
  --no-git               Do not run git init.
  --no-commit            Initialize Git but do not create the first commit.
  -h, --help             Show this help.

Examples:
  scripts/bootstrap-memory.sh ~/Documents/Personal/memory
  scripts/bootstrap-memory.sh ~/memory --name "Team Memory" --owner "Data Team" --no-commit
  scripts/bootstrap-memory.sh ~/memory --config ~/.config/agent-memory/notes-repository.yaml
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

if [ "${1:-}" = "" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

dest=$1
shift

repo_name="Personal Memory"
owner_name=""
expected_remote=""
config_path=""
init_git=1
make_commit=1
today=$(date +%F)

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name)
      [ "$#" -ge 2 ] || die "--name requires a value"
      repo_name=$2
      shift 2
      ;;
    --owner)
      [ "$#" -ge 2 ] || die "--owner requires a value"
      owner_name=$2
      shift 2
      ;;
    --remote)
      [ "$#" -ge 2 ] || die "--remote requires a value"
      expected_remote=$2
      shift 2
      ;;
    --config)
      [ "$#" -ge 2 ] || die "--config requires a value"
      config_path=$2
      shift 2
      ;;
    --no-git)
      init_git=0
      make_commit=0
      shift
      ;;
    --no-commit)
      make_commit=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
template_dir="$repo_root/templates/memory-repository"

[ -d "$template_dir" ] || die "template directory not found: $template_dir"

case "$dest" in
  "~") dest=$HOME ;;
  "~/"*) dest="$HOME/${dest#~/}" ;;
esac

mkdir -p "$(dirname -- "$dest")"

if [ -e "$dest" ]; then
  die "destination already exists: $dest"
fi

cp -R "$template_dir" "$dest"

replace_token() {
  token=$1
  value=$2
  TOKEN=$token VALUE=$value find "$dest" -type f -name '*.md' -exec perl -0pi -e 'BEGIN { $token = $ENV{TOKEN}; $value = $ENV{VALUE}; } s/\Q$token\E/$value/g' {} +
}

replace_token "{{MEMORY_REPOSITORY_NAME}}" "$repo_name"
replace_token "{{TODAY}}" "$today"

if [ -n "$owner_name" ]; then
  replace_token "{{OWNER_PREFIX}}" "$owner_name's "
else
  replace_token "{{OWNER_PREFIX}}" "a "
fi

if [ "$init_git" -eq 1 ]; then
  if command -v git >/dev/null 2>&1; then
    git -C "$dest" init
    if [ "$make_commit" -eq 1 ]; then
      git -C "$dest" add .
      if git -C "$dest" commit -m "Initialize durable memory repository"; then
        :
      else
        printf 'Git repository initialized, but initial commit failed. Review git identity or commit manually.\n' >&2
      fi
    fi
  else
    printf 'Git not found; created files without initializing a repository.\n' >&2
  fi
fi

if [ -n "$config_path" ]; then
  case "$config_path" in
    "~") config_path=$HOME ;;
    "~/"*) config_path="$HOME/${config_path#~/}" ;;
  esac
  mkdir -p "$(dirname -- "$config_path")"
  {
    printf 'notes_repository:\n'
    printf '  local_path: %s\n' "$dest"
    if [ -n "$expected_remote" ]; then
      printf '  expected_remote: %s\n' "$expected_remote"
    fi
    printf '  required_markers:\n'
    printf '    - AGENTS.md\n'
    printf '    - CODEX_START_HERE.md\n'
  } > "$config_path"
fi

printf '\nCreated memory repository at:\n'
printf '  %s\n' "$dest"

if [ -n "$config_path" ]; then
  printf '\nWrote notes-repository config:\n'
  printf '  %s\n' "$config_path"
fi

printf '\nNext:\n'
printf '  cd "%s"\n' "$dest"
printf '  Read AGENTS.md and CODEX_START_HERE.md\n'
printf '  Add raw notes to 00-inbox/quick-capture.md\n'
