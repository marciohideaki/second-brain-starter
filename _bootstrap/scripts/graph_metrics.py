#!/usr/bin/env python3
"""
graph-metrics — count WikiLinks, islands, hubs and broken links across the vault.

Pure stdlib, no LLM, no external storage. Writes a markdown snapshot to
_memory/graph-metrics.md.

Metrics:
- Total .md files, total WikiLinks
- % islands (zero outbound links in prose) per category
- Average out-degree
- Top hubs (highest in-degree)
- Broken WikiLinks (target: 0)
- Frontmatter tag layer + maturity violations (target: 0)

Run as a cron job or on demand:
    python3 _bootstrap/scripts/graph_metrics.py
"""

from __future__ import annotations

import datetime as dt
import os
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

# Auto-detect vault: this script lives in _bootstrap/scripts/ — vault is 2 levels up
VAULT_ROOT = Path(__file__).resolve().parents[2]

WIKILINK_RE = re.compile(r"\[\[([^\]]+)\]\]")
CODE_FENCE_RE = re.compile(r"^(```|~~~)")

# Top-level dirs the starter's vault uses. Adjust if your fork adds more.
CATEGORIES = {
    "_knowledge/projects": "projects",
    "_decisions": "decisions",
    "_learnings": "learnings",
    "_pipeline": "pipeline",
    "_sessions": "sessions",
    "_sources": "sources",
    "_wiki": "wiki",
}

# Tag taxonomy — kept deliberately generic. Forks should extend or replace.
LAYER_TAGS = {
    "decision", "learning", "project", "source", "wiki", "session", "memory", "pipeline",
}
MATURITY_TAGS = {
    "production", "beta", "mvp", "spike", "candidate",
    "deprecated", "archived", "active", "wip",
}


def categorize(rel_path: str) -> str:
    for prefix, label in CATEGORIES.items():
        if rel_path.startswith(prefix + "/") or rel_path == prefix:
            return label
    return "other"


def strip_frontmatter_and_code(text: str) -> str:
    """Drop frontmatter and fenced code blocks so we count links in prose only."""
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        if end != -1:
            text = text[end + 5:]
    out: list[str] = []
    in_code = False
    for line in text.split("\n"):
        if CODE_FENCE_RE.match(line):
            in_code = not in_code
            continue
        if in_code:
            continue
        out.append(line)
    return "\n".join(out)


def parse_frontmatter(text: str) -> dict:
    if not text.startswith("---\n"):
        return {}
    end = text.find("\n---\n", 4)
    if end == -1:
        return {}
    fm: dict = {}
    for line in text[4:end].splitlines():
        if ":" not in line:
            continue
        k, v = line.split(":", 1)
        fm[k.strip()] = v.strip()
    return fm


def parse_tags_value(value: str) -> list[str]:
    value = value.strip()
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1]
        return [t.strip().strip('"').strip("'") for t in inner.split(",") if t.strip()]
    return [t.strip() for t in value.split(",") if t.strip()]


def collect_files() -> list[Path]:
    out: list[Path] = []
    skip = {".git", "node_modules", ".obsidian", ".logs", ".github"}
    for root, dirs, files in os.walk(VAULT_ROOT):
        rel_root = Path(root).relative_to(VAULT_ROOT)
        if rel_root.parts and rel_root.parts[0] in skip:
            dirs[:] = []
            continue
        for f in files:
            if f.endswith(".md"):
                out.append(Path(root) / f)
    return out


def normalize_link_target(raw: str) -> str:
    """Resolve a WikiLink target into a vault-relative path without extension."""
    target = raw.split("|")[0].strip()
    target = target.split("#")[0]
    target = target.replace("\\", "/")
    return target.removesuffix(".md")


_LITERAL_PATTERNS = {
    "WikiLinks", "...", "...|...", "wiki-links", "tag",
    "YYYY-MM-DD", "title", "name", "slug",
}


def find_md_for_target(target: str, source: Path, all_files: set[Path]) -> Path | None:
    """Resolve a WikiLink target to a real path inside the vault."""
    if not target or target in _LITERAL_PATTERNS:
        return source  # literal placeholder used in docs — not a broken link
    if "/" in target:
        if target.startswith("/"):
            p = (VAULT_ROOT / target.lstrip("/")).with_suffix(".md")
        else:
            p = (source.parent / target).with_suffix(".md")
        try:
            p = p.resolve()
        except OSError:
            return None
        if p in all_files:
            return p
        return None
    name = target + ".md"
    matches = [f for f in all_files if f.name == name]
    if matches:
        return matches[0]
    suffix_matches = [f for f in all_files if f.stem.endswith("-" + target) or f.stem.endswith(target)]
    if len(suffix_matches) == 1:
        return suffix_matches[0]
    return None


def main() -> int:
    files = collect_files()
    all_files = {f.resolve() for f in files}

    total_files = len(files)
    by_category: Counter[str] = Counter()
    out_degree: dict[Path, int] = {}
    in_degree: Counter[Path] = Counter()
    islands: dict[str, list[str]] = defaultdict(list)
    broken_links: list[tuple[str, str]] = []
    tag_violations: list[tuple[str, list[str]]] = []

    for f in files:
        try:
            text = f.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        rel = str(f.relative_to(VAULT_ROOT))
        cat = categorize(rel)
        by_category[cat] += 1

        fm = parse_frontmatter(text)
        if "tags" in fm:
            tags = parse_tags_value(fm["tags"])
            has_layer = any(t in LAYER_TAGS for t in tags)
            has_maturity = any(t in MATURITY_TAGS for t in tags)
            if not has_maturity and fm.get("status", "").strip().strip('"') in MATURITY_TAGS:
                has_maturity = True
            missing: list[str] = []
            if not has_layer:
                missing.append("layer")
            if not has_maturity:
                missing.append("maturity")
            if missing:
                tag_violations.append((rel, missing))

        prose = strip_frontmatter_and_code(text)
        out_links_raw = WIKILINK_RE.findall(prose)
        out_count = len(out_links_raw)
        out_degree[f.resolve()] = out_count
        if out_count == 0:
            islands[cat].append(rel)

        for raw in out_links_raw:
            target = normalize_link_target(raw)
            tgt = find_md_for_target(target, f.resolve(), all_files)
            if tgt is None:
                broken_links.append((rel, raw))
            else:
                in_degree[tgt] += 1

    hubs = sorted(in_degree.items(), key=lambda kv: kv[1], reverse=True)[:15]
    total_links = sum(out_degree.values())
    avg_degree = total_links / total_files if total_files else 0.0

    today = dt.date.today().isoformat()
    out_path = VAULT_ROOT / "_memory" / "graph-metrics.md"
    out_path.parent.mkdir(parents=True, exist_ok=True)

    lines: list[str] = []
    lines.append("---")
    lines.append("tags: [memory, knowledge-mgmt, active, generated]")
    lines.append("status: active")
    lines.append(f"updated: {today}")
    lines.append("source: _bootstrap/scripts/graph_metrics.py")
    lines.append("---")
    lines.append("")
    lines.append(f"# Graph Metrics — {today}")
    lines.append("")
    lines.append("> Auto-generated. Snapshot of the WikiLink graph in this vault.")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- **.md files analyzed:** {total_files}")
    lines.append(f"- **Total WikiLinks (prose only, code/frontmatter skipped):** {total_links}")
    lines.append(f"- **Average out-degree:** {avg_degree:.2f}")
    lines.append(f"- **Broken links:** {len(broken_links)}")
    lines.append(f"- **Tag taxonomy violations:** {len(tag_violations)}")
    lines.append("")

    lines.append("## Islands (files with zero outbound links)")
    lines.append("")
    lines.append("| Category | Files | Islands | % |")
    lines.append("|---|---|---|---|")
    for cat, total in sorted(by_category.items(), key=lambda kv: -kv[1]):
        cat_islands = len(islands.get(cat, []))
        pct = (cat_islands / total * 100) if total else 0
        lines.append(f"| {cat} | {total} | {cat_islands} | {pct:.1f}% |")
    total_islands = sum(len(v) for v in islands.values())
    overall_pct = (total_islands / total_files * 100) if total_files else 0
    lines.append(f"| **TOTAL** | **{total_files}** | **{total_islands}** | **{overall_pct:.1f}%** |")
    lines.append("")

    lines.append("## Top hubs (in-degree)")
    lines.append("")
    lines.append("| # | File | Backlinks |")
    lines.append("|---|---|---|")
    for i, (path, deg) in enumerate(hubs, 1):
        rel = path.relative_to(VAULT_ROOT)
        lines.append(f"| {i} | `{rel}` | {deg} |")
    lines.append("")

    if broken_links:
        lines.append(f"## Broken links ({len(broken_links)})")
        lines.append("")
        for src, raw in broken_links[:30]:
            lines.append(f"- `{src}` -> `[[{raw}]]`")
        if len(broken_links) > 30:
            lines.append(f"_... and {len(broken_links) - 30} more_")
        lines.append("")

    if tag_violations:
        lines.append(f"## Frontmatter tag violations ({len(tag_violations)})")
        lines.append("")
        for src, tags in tag_violations[:30]:
            lines.append(f"- `{src}`: missing {tags}")
        if len(tag_violations) > 30:
            lines.append(f"_... and {len(tag_violations) - 30} more_")
        lines.append("")

    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"[graph-metrics] {out_path.relative_to(VAULT_ROOT)} updated", file=sys.stderr)
    print(f"  islands: {overall_pct:.1f}% | avg out-degree: {avg_degree:.2f} | broken: {len(broken_links)} | tag-violations: {len(tag_violations)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
