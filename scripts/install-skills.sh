#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  install-skills.sh [options] [skill ...]

Install or update folder-based skills from this repository.

Options:
  --target DIR       Destination skills directory. Default: $HOME/.codex/skills
  --all              Install all skills under ./skills. This is the default.
  --dry-run          Show what would be installed without changing files.
  --yes              Approve all updates without prompting.
  --no-backup        Replace existing skill directories without keeping backups.
  --list             List available skills and exit.
  -h, --help         Show this help.

Examples:
  scripts/install-skills.sh
  scripts/install-skills.sh --target ~/.codex/skills mem-capture mem-codify
  scripts/install-skills.sh --target ~/.some-agent/skills --all
  scripts/install-skills.sh --dry-run
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_root="$repo_root/skills"
target_root="$HOME/.codex/skills"
dry_run=0
backup=1
install_all=1
list_only=0
assume_yes=0
skills=()

[ -d "$source_root" ] || die "source skills directory not found: $source_root"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      [ "$#" -ge 2 ] || die "--target requires a value"
      target_root=$2
      shift 2
      ;;
    --all)
      install_all=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --yes|-y)
      assume_yes=1
      shift
      ;;
    --no-backup)
      backup=0
      shift
      ;;
    --list)
      list_only=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      die "unknown option: $1"
      ;;
    *)
      install_all=0
      skills+=("$1")
      shift
      ;;
  esac
done

case "$target_root" in
  "~") target_root=$HOME ;;
  "~/"*) target_root="$HOME/${target_root#~/}" ;;
esac

backup_root="${target_root%/}-backups"

available_skills() {
  find "$source_root" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print \
    | sed "s#^$source_root/##" \
    | sort
}

if [ "$list_only" -eq 1 ]; then
  available_skills
  exit 0
fi

if [ "$install_all" -eq 1 ]; then
  skills=()
  while IFS= read -r skill_name; do
    skills+=("$skill_name")
  done < <(available_skills)
fi

[ "${#skills[@]}" -gt 0 ] || die "no skills selected"

for skill in "${skills[@]}"; do
  case "$skill" in
    documentation-as-design)
      die "skill documentation-as-design has been renamed to documentation-governance; install documentation-governance instead"
      ;;
    */*|.*|'') die "invalid skill name: $skill" ;;
  esac
  [ -f "$source_root/$skill/SKILL.md" ] || die "skill not found or missing SKILL.md: $skill"
done

timestamp=$(date +%Y%m%d-%H%M%S)

skill_diff() {
  diff -ru --exclude='.DS_Store' "$1" "$2"
}

skill_has_changes() {
  ! skill_diff "$1" "$2" >/dev/null
}

show_release_notes() {
  local skill=$1
  local src=$2
  local dst=$3
  local changed_files

  printf '\nRelease notes for %s\n' "$skill"
  printf '%s\n' "------------------------------"
  printf 'Source:    %s\n' "$src"
  printf 'Installed: %s\n\n' "$dst"

  printf 'Changed files:\n'
  set +e
  changed_files=$(diff -qr --exclude='.DS_Store' "$dst" "$src")
  set -e
  if [ -n "$changed_files" ]; then
    printf '%s\n' "$changed_files" \
      | sed \
        -e "s#^Files $dst/##" \
        -e "s# and $src/# -> #" \
        -e "s# differ\$# modified#" \
        -e "s#^Only in $src/#added: #" \
        -e "s#^Only in $dst/#removed: #"
  else
    printf 'No file-level changes detected.\n'
  fi

  printf '\nDiff:\n'
  skill_diff "$dst" "$src" || true
}

approve_update() {
  local skill=$1
  local reply

  if [ "$assume_yes" -eq 1 ]; then
    return 0
  fi

  printf '\nUpdate %s? [y/N] ' "$skill"
  read -r reply || reply=
  case "$reply" in
    y|Y|yes|YES|Yes) return 0 ;;
    *) return 1 ;;
  esac
}

copy_skill() {
  local src=$1
  local dst=$2

  if [ -e "$dst" ]; then
    retire_installed_path "$dst"
  fi

  mkdir -p "$dst"
  (cd "$src" && tar --exclude='.DS_Store' -cf - .) | (cd "$dst" && tar -xf -)
}

backup_destination() {
  local installed_path=$1
  local candidate="$backup_root/$(basename -- "$installed_path").backup-$timestamp"
  local suffix=1

  while [ -e "$candidate" ]; do
    candidate="$backup_root/$(basename -- "$installed_path").backup-$timestamp-$suffix"
    suffix=$((suffix + 1))
  done

  printf '%s\n' "$candidate"
}

retire_installed_path() {
  local installed_path=$1
  local backup_path

  if [ "$backup" -eq 1 ]; then
    backup_path=$(backup_destination "$installed_path")
    mkdir -p "$backup_root"
    mv "$installed_path" "$backup_path"
    printf 'Backed up %s -> %s\n' "$installed_path" "$backup_path"
  else
    rm -rf "$installed_path"
    printf 'Removed %s\n' "$installed_path"
  fi
}

if [ "$dry_run" -eq 1 ]; then
  printf 'Would install to: %s\n' "$target_root"
else
  mkdir -p "$target_root"
fi

for skill in "${skills[@]}"; do
  src="$source_root/$skill"
  dst="$target_root/$skill"

  legacy_skill=
  legacy_paths=()
  case "$skill" in
    documentation-governance)
      legacy_skill=documentation-as-design
      if [ -d "$target_root" ]; then
        while IFS= read -r legacy_path; do
          legacy_paths+=("$legacy_path")
        done < <(
          find "$target_root" -mindepth 1 -maxdepth 1 -type d \
            \( -name "$legacy_skill" -o -name "$legacy_skill.backup-*" \) -print \
            | sort
        )
      fi
      ;;
  esac

  if [ "${#legacy_paths[@]}" -gt 0 ]; then
    printf '\nRename migration: %s -> %s\n' "$legacy_skill" "$skill"
    printf 'Legacy directories to retire from the discovery root:\n'
    printf '  %s\n' "${legacy_paths[@]}"

    legacy_active="$target_root/$legacy_skill"
    if [ -e "$legacy_active" ]; then
      show_release_notes "$skill (renamed from $legacy_skill)" "$src" "$legacy_active"
    elif [ -e "$dst" ] && skill_has_changes "$dst" "$src"; then
      show_release_notes "$skill" "$src" "$dst"
    fi

    if [ "$dry_run" -eq 1 ]; then
      if [ -e "$dst" ]; then
        if skill_has_changes "$dst" "$src"; then
          printf '\nWould update: %s -> %s\n' "$src" "$dst"
        else
          printf 'Renamed skill is already up to date: %s\n' "$skill"
        fi
      else
        printf '\nWould install: %s -> %s\n' "$src" "$dst"
      fi

      for legacy_path in "${legacy_paths[@]}"; do
        if [ "$backup" -eq 1 ]; then
          printf 'Would move legacy directory outside the discovery root: %s -> %s\n' \
            "$legacy_path" "$(backup_destination "$legacy_path")"
        else
          printf 'Would remove legacy directory: %s\n' "$legacy_path"
        fi
      done
      continue
    fi

    if approve_update "$legacy_skill -> $skill"; then
      if [ ! -e "$dst" ] || skill_has_changes "$dst" "$src"; then
        copy_skill "$src" "$dst"
      fi
      for legacy_path in "${legacy_paths[@]}"; do
        retire_installed_path "$legacy_path"
      done
      printf 'Migrated %s -> %s\n' "$legacy_skill" "$dst"
    else
      printf 'Skipped rename migration: %s -> %s\n' "$legacy_skill" "$skill"
    fi
    continue
  fi

  if [ "$dry_run" -eq 1 ]; then
    if [ -e "$dst" ]; then
      if skill_has_changes "$dst" "$src"; then
        show_release_notes "$skill" "$src" "$dst"
        printf '\nWould update: %s -> %s\n' "$src" "$dst"
        if [ "$backup" -eq 1 ]; then
          printf 'Would back up existing directory to: %s\n' "$(backup_destination "$dst")"
        fi
      else
        printf 'Already up to date: %s\n' "$skill"
      fi
    else
      printf 'Would install: %s -> %s\n' "$src" "$dst"
    fi
    continue
  fi

  if [ -e "$dst" ]; then
    if skill_has_changes "$dst" "$src"; then
      show_release_notes "$skill" "$src" "$dst"
      if approve_update "$skill"; then
        copy_skill "$src" "$dst"
        printf 'Updated %s -> %s\n' "$skill" "$dst"
      else
        printf 'Skipped %s\n' "$skill"
      fi
    else
      printf 'Already up to date: %s\n' "$skill"
    fi
    continue
  fi

  copy_skill "$src" "$dst"
  printf 'Installed %s -> %s\n' "$skill" "$dst"
done

printf '\nDone.\n'
