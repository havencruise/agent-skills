#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
installer="$repo_root/scripts/install-skills.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/agent-skills-renames.XXXXXX")
trap 'rm -rf "$test_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_exists() {
  [ -e "$1" ] || fail "expected path to exist: $1"
}

assert_missing() {
  [ ! -e "$1" ] || fail "expected path to be absent: $1"
}

list_output=$($installer --list)
printf '%s\n' "$list_output" | grep -Fx 'documentation-governance' >/dev/null \
  || fail 'renamed skill is missing from --list'
if printf '%s\n' "$list_output" | grep -Fx 'documentation-as-design' >/dev/null; then
  fail 'legacy skill remains available from --list'
fi

clean_target="$test_root/clean/skills"
$installer --target "$clean_target" --yes --no-backup documentation-governance >/dev/null
assert_exists "$clean_target/documentation-governance/SKILL.md"
assert_missing "$clean_target/documentation-as-design"
grep -Fx 'name: documentation-governance' \
  "$clean_target/documentation-governance/SKILL.md" >/dev/null \
  || fail 'clean installation has stale skill frontmatter'

upgrade_target="$test_root/upgrade/skills"
legacy_dir="$upgrade_target/documentation-as-design"
legacy_backup_dir="$upgrade_target/documentation-as-design.backup-20260801-000000"
mkdir -p "$legacy_dir"
mkdir -p "$legacy_backup_dir"
printf '%s\n' \
  '---' \
  'name: documentation-as-design' \
  'description: Legacy fixture.' \
  '---' \
  '# Documentation as Design' > "$legacy_dir/SKILL.md"
printf '%s\n' \
  '---' \
  'name: documentation-as-design' \
  'description: Legacy backup fixture.' \
  '---' \
  '# Documentation as Design' > "$legacy_backup_dir/SKILL.md"

dry_run_output=$($installer --target "$upgrade_target" --dry-run documentation-governance)
assert_missing "$upgrade_target/documentation-governance"
assert_exists "$legacy_dir"
printf '%s\n' "$dry_run_output" | grep -F 'Would install:' >/dev/null \
  || fail 'rename dry-run should describe the new installation'
printf '%s\n' "$dry_run_output" | grep -F 'Would move legacy directory outside the discovery root:' >/dev/null \
  || fail 'rename dry-run should describe legacy-directory retirement'

$installer --target "$upgrade_target" --yes documentation-governance >/dev/null
assert_exists "$upgrade_target/documentation-governance/SKILL.md"
assert_missing "$legacy_dir"

backup_root="$test_root/upgrade/skills-backups"
legacy_backups=$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d \
  -name 'documentation-as-design.backup-*' | wc -l | tr -d ' ')
[ "$legacy_backups" -eq 2 ] || fail 'expected legacy directories to be backed up outside the discovery root'

unexpected_legacy=$(find "$upgrade_target" -mindepth 1 -maxdepth 1 -type d \
  -name 'documentation-as-design*' -print)
[ -z "$unexpected_legacy" ] || fail "found legacy skill directories in discovery root: $unexpected_legacy"

update_target="$test_root/update/skills"
$installer --target "$update_target" --yes maintenance-surface >/dev/null
printf '\n# Local change\n' >> "$update_target/maintenance-surface/SKILL.md"
$installer --target "$update_target" --yes maintenance-surface >/dev/null
diff -ru "$repo_root/skills/maintenance-surface" "$update_target/maintenance-surface" >/dev/null \
  || fail 'ordinary skill update did not restore repository contents'
update_backups=$(find "$test_root/update/skills-backups" -mindepth 1 -maxdepth 1 \
  -type d -name 'maintenance-surface.backup-*' | wc -l | tr -d ' ')
[ "$update_backups" -eq 1 ] || fail 'ordinary update backup is missing outside the discovery root'
unexpected_update_backups=$(find "$update_target" -mindepth 1 -maxdepth 1 -type d \
  -name 'maintenance-surface.backup-*' -print)
[ -z "$unexpected_update_backups" ] \
  || fail "found ordinary update backup in discovery root: $unexpected_update_backups"

if $installer --target "$test_root/rejected/skills" documentation-as-design \
  >"$test_root/rejected.out" 2>"$test_root/rejected.err"; then
  fail 'legacy skill name should not remain installable'
fi
grep -F 'renamed to documentation-governance' "$test_root/rejected.err" >/dev/null \
  || fail 'legacy invocation should explain the renamed skill'

printf 'PASS: clean install, legacy-name migration, and ordinary update\n'
