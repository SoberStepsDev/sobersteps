#!/usr/bin/env python3
"""Merge en order + existing locale tails + additions → rewrite fr, ru, nl in lib/l10n/strings.dart."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STR = ROOT / "lib/l10n/strings.dart"


def read_dart_sq_string(chunk: str, i: int) -> tuple[str, int]:
    """Parse from first char after opening `'`. Returns (decoded, index after closing `'`)."""
    out: list[str] = []
    n = len(chunk)
    while i < n:
        c = chunk[i]
        if c == "\\" and i + 1 < n:
            nxt = chunk[i + 1]
            if nxt == "'":
                out.append("'")
                i += 2
                continue
            if nxt == "n":
                out.append("\n")
                i += 2
                continue
            if nxt == "\\":
                out.append("\\")
                i += 2
                continue
            if nxt == "$":
                out.append("$")
                i += 2
                continue
            out.append(nxt)
            i += 2
            continue
        if c == "'":
            return "".join(out), i + 1
        out.append(c)
        i += 1
    raise SystemExit("unterminated Dart string in strings.dart")


def parse_inner(text: str, locale: str, closing: str):
    """closing: regex that matches from end of inner map (starts with newline before `},`)."""
    m = re.search(rf"'{locale}':\s*\{{([\s\S]*?){closing}", text)
    if not m:
        raise SystemExit(f"block {locale!r} not found (closing {closing!r})")
    chunk = "".join(
        ln for ln in m.group(1).splitlines(True) if not ln.strip().startswith("//")
    )
    d, order = {}, []
    i, n = 0, len(chunk)
    while i < n:
        while i < n and chunk[i] in " \t\n":
            i += 1
        if i >= n:
            break
        if chunk[i] != "'":
            i += 1
            continue
        i += 1
        ks = i
        while i < n and chunk[i] != "'":
            i += 2 if chunk[i] == "\\" else 1
        key = chunk[ks:i]
        i += 1
        while i < n and chunk[i] in " \t":
            i += 1
        if i >= n or chunk[i] != ":":
            continue
        i += 1
        while i < n and chunk[i] in " \t":
            i += 1
        if i >= n or chunk[i] != "'":
            continue
        i += 1
        val, i = read_dart_sq_string(chunk, i)
        d[key] = val
        order.append(key)
        while i < n and chunk[i] in " \t":
            i += 1
        if i < n and chunk[i] == ",":
            i += 1
    return d, order


def dart_quote(val: str) -> str:
    # Normalize MT/JSON glitches (const-safe ASCII where helpful).
    val = (
        val.replace("\r\n", "\n")
        .replace("\r", "\n")
        .replace("\u2028", "\n")
        .replace("\u2029", "\n")
    )
    val = (
        val.replace("\u2018", "'")
        .replace("\u2019", "'")
        .replace("\u201c", '"')
        .replace("\u201d", '"')
    )
    val = val.replace("\u2013", "-").replace("\u2014", "-")
    while "\\'" in val:
        val = val.replace("\\'", "'")
    parts: list[str] = ["'"]
    for c in val:
        if c == "\\":
            parts.append("\\\\")
        elif c == "'":
            parts.append("\\'")
        elif c == "\n":
            parts.append("\\n")
        elif c == "\r":
            parts.append("\\r")
        elif c == "\t":
            parts.append("\\t")
        elif c == "$":
            parts.append(r"\$")
        else:
            parts.append(c)
    parts.append("'")
    return "".join(parts)


def emit_locale(loc: str, values: dict, key_order: list[str]) -> str:
    lines = [f"    '{loc}': {{"]
    buf = []

    def flush():
        nonlocal buf
        if buf:
            lines.append("      " + ", ".join(buf) + ",")
            buf = []

    for k in key_order:
        buf.append(f"'{k}': {dart_quote(values[k])}")
        if len(", ".join(buf)) > 96:
            flush()
    flush()
    lines.append("    },")
    return "\n".join(lines) + "\n"


def main():
    raw = STR.read_text(encoding="utf-8")

    en, order = parse_inner(raw, "en", r"\n    \},\n    'pl': \{")
    fr_old, _ = parse_inner(raw, "fr", r"\n    \},\n    'ru': \{")
    ru_old, _ = parse_inner(raw, "ru", r"\n    \},\n    'nl': \{")
    nl_old, _ = parse_inner(raw, "nl", r"\n    \},\n  \};")

    tool = Path(__file__).parent
    fr_add = json.loads((tool / "fr_additions.json").read_text(encoding="utf-8"))
    ru_add = json.loads((tool / "ru_additions.json").read_text(encoding="utf-8"))
    nl_full = json.loads((tool / "nl_full.json").read_text(encoding="utf-8"))

    fr = {**en, **fr_add, **fr_old}
    ru = {**en, **ru_add, **ru_old}
    nl = {**en, **nl_full, **nl_old}

    for label, d in [("fr", fr), ("ru", ru), ("nl", nl)]:
        miss = [k for k in order if k not in d]
        if miss:
            raise SystemExit(f"{label} missing {len(miss)} keys e.g. {miss[:5]}")

    text = raw
    for loc, d, closing in (
        ("fr", fr, r"(?=\n    'ru': \{)"),
        ("ru", ru, r"(?=\n    'nl': \{)"),
        ("nl", nl, r"(?=\n  \};)"),
    ):
        body = emit_locale(loc, d, order).rstrip()
        pat = re.compile(rf"    '{loc}':\s*\{{[\s\S]*?\n    \}},{closing}", re.M)
        # Callable repl: str repl would interpret `\n` and mangle Dart `\n` escapes.
        text, n = pat.subn(lambda _m: body, text, count=1)
        if n != 1:
            raise SystemExit(f"replace {loc} count={n}")

    STR.write_text(text, encoding="utf-8")
    print("updated", STR)


if __name__ == "__main__":
    main()
