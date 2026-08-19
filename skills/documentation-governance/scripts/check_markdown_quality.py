#!/usr/bin/env python3
"""Read-only mechanical checks for durable Markdown documentation."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from typing import Any
from urllib.parse import unquote


CONTROL_FIELDS = {
    "role": "Role",
    "status": "Status",
    "canonical source": "Canonical source",
    "replaced by": "Replaced by",
    "review trigger": "Review trigger",
}
VALID_ROLES = {"authoritative", "execution", "evidence", "handoff"}
VALID_STATUSES = {"draft", "active", "completed", "superseded"}
LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
H1_RE = re.compile(r"^#\s+(.+?)\s*$")
H2_RE = re.compile(r"^##\s+(.+?)\s*$", re.IGNORECASE)
FIELD_RE = re.compile(
    r"^\s*[-*]\s*(?:\*\*)?(Role|Status|Canonical source|Replaced by|Review trigger)(?:\*\*)?\s*:\s*(.*?)\s*$",
    re.IGNORECASE,
)
PLACEHOLDER_RE = re.compile(r"\{\{\s*[^{}\s][^{}]*?\s*\}\}")
EXACT_TEMPLATE_LITERALS = {"[Feature Name]", "[Task Name]", "[ADR Number]"}
FENCE_RE = re.compile(r"^\s*(```|~~~)")


@dataclass(frozen=True)
class Scope:
    excluded_prefixes: tuple[str, ...]
    role_prefixes: tuple[tuple[str, str], ...]


def root_relative_prefix(value: str) -> str:
    raw = value.strip().replace("\\", "/")
    if not raw:
        raise argparse.ArgumentTypeError("prefix cannot be empty")
    if re.match(r"^[A-Za-z]:", raw):
        raise argparse.ArgumentTypeError("prefix must be relative to --root")
    path = PurePosixPath(raw)
    if path.is_absolute() or ".." in path.parts:
        raise argparse.ArgumentTypeError("prefix must be relative to --root and cannot traverse upward")
    normalized = path.as_posix().rstrip("/")
    if not normalized or normalized == ".":
        raise argparse.ArgumentTypeError("prefix must name a directory below --root")
    return f"{normalized}/"


def role_prefix(value: str) -> tuple[str, str]:
    role, separator, prefix = value.partition("=")
    normalized_role = role.strip().lower()
    if not separator or normalized_role not in VALID_ROLES:
        choices = ", ".join(sorted(VALID_ROLES))
        raise argparse.ArgumentTypeError(f"role prefix must use ROLE=PREFIX, where ROLE is one of: {choices}")
    return normalized_role, root_relative_prefix(prefix)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, help="Repository root")
    parser.add_argument("--tracked-only", action="store_true", help="Use Git tracked Markdown only")
    parser.add_argument(
        "--exclude-prefix",
        action="append",
        default=[],
        metavar="PREFIX",
        type=root_relative_prefix,
        help="Exclude a root-relative directory prefix (repeatable)",
    )
    parser.add_argument(
        "--role-prefix",
        action="append",
        default=[],
        metavar="ROLE=PREFIX",
        type=role_prefix,
        help="Classify legacy documents under a root-relative prefix (repeatable)",
    )
    parser.add_argument("--format", choices=("json",), default="json")
    return parser.parse_args()


def tracked_markdown(root: Path) -> list[Path]:
    try:
        completed = subprocess.run(
            ["git", "-C", str(root), "ls-files", "-z", "--", "*.md"],
            check=False,
            capture_output=True,
            text=False,
        )
    except FileNotFoundError as error:
        raise RuntimeError("Git is required when --tracked-only is set; omit it for a non-Git directory") from error
    if completed.returncode:
        message = completed.stderr.decode("utf-8", "replace").strip()
        raise RuntimeError(f"Unable to list tracked Markdown: {message or 'git ls-files failed'}")
    return [Path(item.decode("utf-8")) for item in completed.stdout.split(b"\0") if item]


def all_markdown(root: Path) -> list[Path]:
    return sorted(path.relative_to(root) for path in root.rglob("*.md") if path.is_file())


def posix(path: Path) -> str:
    return path.as_posix()


def matches_prefix(path: Path, prefixes: tuple[str, ...]) -> bool:
    return any(posix(path).startswith(prefix) for prefix in prefixes)


def infer_role(path: Path, fields: dict[str, tuple[str, int]], scope: Scope) -> tuple[str, str]:
    declared = fields.get("role")
    if declared and declared[0].lower() in VALID_ROLES:
        return declared[0].lower(), "Document control"
    matching_roles = [(role, prefix) for role, prefix in scope.role_prefixes if posix(path).startswith(prefix)]
    if matching_roles:
        role, prefix = max(matching_roles, key=lambda item: len(item[1]))
        return role, f"configured role prefix: {prefix}"
    return "other", "no Document control role or configured role prefix"


def code_line_mask(lines: list[str]) -> list[bool]:
    masked: list[bool] = []
    fenced = False
    for line in lines:
        if FENCE_RE.match(line):
            fenced = not fenced
            masked.append(True)
        else:
            masked.append(fenced)
    return masked


def heading_slug(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^\w\s-]", "", value)
    value = re.sub(r"[\s-]+", "-", value)
    return value.strip("-")


def headings(lines: list[str], masked: list[bool]) -> set[str]:
    return {
        heading_slug(match.group(1))
        for line, in_code in zip(lines, masked)
        if not in_code and (match := re.match(r"^#{1,6}\s+(.+?)\s*#*\s*$", line))
    }


def h1_title(lines: list[str], masked: list[bool]) -> str | None:
    for line, in_code in zip(lines, masked):
        if not in_code and (match := H1_RE.match(line)):
            return match.group(1).strip()
    return None


def section(lines: list[str], masked: list[bool], name: str) -> tuple[int | None, list[tuple[int, str]]]:
    start: int | None = None
    content: list[tuple[int, str]] = []
    for index, (line, in_code) in enumerate(zip(lines, masked)):
        if in_code:
            continue
        match = H2_RE.match(line)
        if start is None:
            if match and match.group(1).strip().lower() == name.lower():
                start = index
            continue
        if re.match(r"^#{1,2}\s+", line):
            break
        content.append((index, line))
    return start, content


def parse_control(lines: list[str], masked: list[bool]) -> tuple[int | None, dict[str, tuple[str, int]]]:
    start, content = section(lines, masked, "Document control")
    fields: dict[str, tuple[str, int]] = {}
    for index, line in content:
        match = FIELD_RE.match(line)
        if match:
            fields[match.group(1).strip().lower()] = (match.group(2).strip(), index)
    return start, fields


def explicit_status(lines: list[str], masked: list[bool]) -> tuple[str | None, int | None, str | None]:
    start, content = section(lines, masked, "Status")
    if start is None:
        return None, None, None
    for index, line in content:
        text = line.strip().lstrip("-* ").strip()
        if not text:
            continue
        match = re.match(r"(proposed|accepted|deprecated|superseded|rejected|draft|active|completed)\b", text, re.I)
        if match:
            return match.group(1).lower(), index, text
    return None, None, None


def legacy_successor(lines: list[str], masked: list[bool], status: str | None) -> tuple[str | None, int | None]:
    if status != "superseded":
        return None, None
    _, content = section(lines, masked, "Status")
    saw_label = False
    for index, line in content:
        if re.match(r"^\s*Superseded by\s*$", line, re.IGNORECASE):
            saw_label = True
            continue
        if saw_label:
            reference = extract_reference(line)
            if reference:
                return reference, index
            if line.strip():
                break
    return None, None


def extract_reference(value: str) -> str | None:
    markdown = LINK_RE.search(value)
    if markdown:
        value = markdown.group(1)
    else:
        backtick = re.search(r"`([^`]+)`", value)
        if backtick:
            value = backtick.group(1)
        else:
            path = re.search(r"(?:\.?\.?/)?[\w./-]+\.md(?:#[\w-]+)?", value)
            if not path:
                return None
            value = path.group(0)
    return value.strip().split(maxsplit=1)[0]


def resolve_reference(root: Path, source: Path, value: str) -> tuple[Path | None, str | None]:
    target = extract_reference(value)
    if not target or target.lower() in {"self", "none", "n/a"}:
        return None, None
    target = unquote(target)
    path_part, _, fragment = target.partition("#")
    if re.match(r"^[a-z][a-z0-9+.-]*:", path_part, re.I) or path_part.startswith("/"):
        return None, None
    candidate = (source.parent / path_part).resolve() if path_part else source.resolve()
    root_candidate = (root / path_part).resolve() if path_part else source.resolve()
    try:
        candidate.relative_to(root.resolve())
    except ValueError:
        candidate = None
    try:
        root_candidate.relative_to(root.resolve())
    except ValueError:
        root_candidate = None
    if candidate is None:
        return root_candidate, fragment or None
    if candidate.exists() or not path_part or path_part.startswith((".", "..")) or root_candidate is None:
        return candidate, fragment or None
    if root_candidate.exists():
        return root_candidate, fragment or None
    return candidate, fragment or None


def local_link_findings(
    root: Path, relative: Path, lines: list[str], masked: list[bool], headings_by_path: dict[Path, set[str]]
) -> list[dict[str, Any]]:
    findings: list[dict[str, Any]] = []
    source = root / relative
    for index, (line, in_code) in enumerate(zip(lines, masked), start=1):
        if in_code:
            continue
        for match in LINK_RE.finditer(line):
            raw = match.group(1).strip().split(maxsplit=1)[0]
            target, fragment = resolve_reference(root, source, raw)
            if target is None:
                continue
            if not target.exists():
                findings.append(finding(relative, index, "broken_local_link", raw, "repair_link"))
                continue
            if fragment and target.suffix.lower() == ".md":
                target_relative = target.relative_to(root)
                if heading_slug(fragment) not in headings_by_path.get(target_relative, set()):
                    findings.append(finding(relative, index, "broken_local_anchor", raw, "repair_link"))
    return findings


def finding(path: Path, line: int, rule: str, evidence: str, action: str, confidence: str = "high") -> dict[str, Any]:
    return {
        "path": posix(path),
        "line": line,
        "rule": rule,
        "evidence": evidence,
        "recommended_action": action,
        "confidence": confidence,
    }


def control_findings(root: Path, relative: Path, control_start: int | None, fields: dict[str, tuple[str, int]]) -> list[dict[str, Any]]:
    if control_start is None:
        return []
    findings: list[dict[str, Any]] = []
    for key, label in CONTROL_FIELDS.items():
        if key == "replaced by":
            continue
        if key not in fields or not fields[key][0]:
            findings.append(finding(relative, control_start + 1, "missing_document_control_field", label, "validate_control"))
    if role := fields.get("role"):
        if role[0].lower() not in VALID_ROLES:
            findings.append(finding(relative, role[1] + 1, "invalid_document_role", role[0], "validate_control"))
    if status := fields.get("status"):
        normalized = status[0].lower()
        replacement = fields.get("replaced by")
        if normalized not in VALID_STATUSES:
            findings.append(finding(relative, status[1] + 1, "invalid_document_status", status[0], "validate_control"))
        elif normalized == "superseded" and (not replacement or not replacement[0]):
            findings.append(finding(relative, status[1] + 1, "superseded_without_successor", status[0], "validate_control"))
        elif normalized != "superseded" and replacement and replacement[0]:
            findings.append(finding(relative, replacement[1] + 1, "replacement_on_non_superseded_document", replacement[0], "validate_control"))
        if replacement and replacement[0] and normalized == "superseded":
            target, _ = resolve_reference(root, root / relative, replacement[0])
            if target is not None and not target.exists():
                findings.append(finding(relative, replacement[1] + 1, "missing_successor", replacement[0], "repair_link"))
    return findings


def document_action(role: str, control_start: int | None, fields: dict[str, tuple[str, int]], legacy_status: str | None) -> tuple[str, list[str]]:
    if control_start is not None:
        if fields.get("status", ("", 0))[0].lower() == "superseded":
            return "retain", ["explicitly superseded with lifecycle metadata"]
        return "validate_control", ["explicit Document control block"]
    if legacy_status == "superseded":
        return "retain", ["legacy document declares superseded status"]
    if role in {"authoritative", "execution", "evidence", "handoff"}:
        return "manual_lifecycle_review", ["legacy document has no Document control block"]
    return "retain", ["no explicit lifecycle metadata or configured role"]


def collect(root: Path, paths: list[Path], tracked_only: bool, scope: Scope) -> dict[str, Any]:
    records: list[dict[str, Any]] = []
    relationships: list[dict[str, Any]] = []
    headings_by_path: dict[Path, set[str]] = {}
    source: dict[Path, tuple[list[str], list[bool]]] = {}
    excluded_count = 0
    for relative in sorted(paths, key=posix):
        if matches_prefix(relative, scope.excluded_prefixes):
            excluded_count += 1
            continue
        try:
            lines = (root / relative).read_text(encoding="utf-8").splitlines()
        except UnicodeDecodeError:
            continue
        masked = code_line_mask(lines)
        source[relative] = (lines, masked)
        headings_by_path[relative] = headings(lines, masked)

    all_findings: list[dict[str, Any]] = []
    titles: dict[tuple[str, str], list[Path]] = defaultdict(list)
    for relative in sorted(source, key=posix):
        lines, masked = source[relative]
        control_start, fields = parse_control(lines, masked)
        role, role_basis = infer_role(relative, fields, scope)
        legacy_status, legacy_line, legacy_evidence = explicit_status(lines, masked)
        legacy_successor_ref, legacy_successor_line = legacy_successor(lines, masked, legacy_status)
        action, evidence = document_action(role, control_start, fields, legacy_status)
        findings = control_findings(root, relative, control_start, fields)
        findings.extend(local_link_findings(root, relative, lines, masked, headings_by_path))
        for index, (line, in_code) in enumerate(zip(lines, masked), start=1):
            if in_code:
                continue
            for token in PLACEHOLDER_RE.findall(line):
                findings.append(finding(relative, index, "unresolved_template_token", token, "validate_control"))
            for literal in EXACT_TEMPLATE_LITERALS:
                if literal in line:
                    findings.append(finding(relative, index, "unresolved_template_literal", literal, "validate_control"))
        title = h1_title(lines, masked)
        if title and role == "authoritative":
            titles[("authoritative", title.casefold())].append(relative)
        if control_start is None and role in {"authoritative", "execution", "evidence", "handoff"}:
            findings.append(
                finding(relative, 1, "legacy_no_control_block", "legacy document has no Document control block", action, "info")
            )
        if legacy_status and legacy_line is not None:
            evidence.append(f"legacy status: {legacy_evidence}")
        document_relationships: list[dict[str, Any]] = []
        for field, relation in (("canonical source", "canonical_source"), ("replaced by", "successor")):
            if field not in fields or not fields[field][0]:
                continue
            reference = extract_reference(fields[field][0])
            if reference:
                edge = {"relation": relation, "target": reference, "line": fields[field][1] + 1}
                document_relationships.append(edge)
                relationships.append({"path": posix(relative), **edge})
        if legacy_successor_ref and legacy_successor_line is not None:
            edge = {"relation": "successor", "target": legacy_successor_ref, "line": legacy_successor_line + 1}
            document_relationships.append(edge)
            relationships.append({"path": posix(relative), **edge})
            target, _ = resolve_reference(root, root / relative, legacy_successor_ref)
            if target is not None and not target.exists():
                findings.append(
                    finding(relative, legacy_successor_line + 1, "missing_legacy_successor", legacy_successor_ref, "repair_link")
                )
        records.append(
            {
                "path": posix(relative),
                "title": title,
                "role": role,
                "role_basis": role_basis,
                "legacy_status": legacy_status,
                "document_control": {CONTROL_FIELDS[key]: fields[key][0] for key in CONTROL_FIELDS if key in fields},
                "relationships": document_relationships,
                "recommended_action": action,
                "evidence": evidence,
                "findings": findings,
            }
        )
        all_findings.extend(findings)

    for (family, title), duplicates in sorted(titles.items()):
        if len(duplicates) < 2:
            continue
        for relative in duplicates:
            duplicate = finding(relative, 1, "duplicate_authoritative_h1", title, "manual_lifecycle_review", "medium")
            next(record for record in records if record["path"] == posix(relative))["findings"].append(duplicate)
            all_findings.append(duplicate)

    return {
        "schema_version": 1,
        "root": str(root.resolve()),
        "tracked_only": tracked_only,
        "scope": {
            "excluded_prefixes": list(scope.excluded_prefixes),
            "role_prefixes": [{"role": role, "prefix": prefix} for role, prefix in scope.role_prefixes],
        },
        "scanned_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        "summary": {
            "input_markdown_files": len(paths),
            "governed_documents": len(records),
            "excluded_documents": excluded_count,
            "roles": dict(sorted(Counter(record["role"] for record in records).items())),
            "recommended_actions": dict(sorted(Counter(record["recommended_action"] for record in records).items())),
            "findings": dict(sorted(Counter(item["rule"] for item in all_findings).items())),
        },
        "documents": records,
        "findings": sorted(all_findings, key=lambda item: (item["path"], item["line"], item["rule"])),
        "relationships": sorted(relationships, key=lambda item: (item["path"], item["line"], item["relation"])),
    }


def main() -> int:
    args = parse_args()
    root = Path(args.root).expanduser().resolve()
    if not root.is_dir():
        print(json.dumps({"error": f"Repository root does not exist: {root}"}), file=sys.stderr)
        return 2
    try:
        paths = tracked_markdown(root) if args.tracked_only else all_markdown(root)
        scope = Scope(tuple(args.exclude_prefix), tuple(args.role_prefix))
        print(json.dumps(collect(root, paths, args.tracked_only, scope), indent=2, sort_keys=True))
    except RuntimeError as error:
        print(json.dumps({"error": str(error)}), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
