#!/usr/bin/env python3
"""Generate fr_additions.json / ru_additions.json / nl_full.json from English miss maps.
Uses deep_translator; masks tokens that must stay literal."""
import json
import re
import time
from pathlib import Path

from deep_translator import GoogleTranslator

ROOT = Path(__file__).resolve().parents[1]
TOOL = Path(__file__).resolve().parent

# Longest-first literal spans to preserve through MT (substring match)
PRESERVE = sorted(
    [
        "sobersteps@pm.me",
        "SoberSteps",
        "Recovery+",
        "RevenueCat",
        "Naomi",
        "Craving Surf",
        "3 AM SOS",
        "3 AM Wall",
        "SMART Recovery",
        "Karma Mirror",
        "Return to Self",
        "AA/NA/SMART",
        "Alcoholics Anonymous",
        "Narcotics Anonymous",
        "Recovery Dharma",
        "In The Rooms",
        "SAMHSA",
        "Supabase",
        "OneSignal",
        "Google",
        "Apple",
        "Magic link",
        "magic link",
        "PRO",
        "CBT",
        "GDPR",
        "TLS",
        "RLS",
        "Flutter",
        "$89.99",
        "$59.99",
        "$9.99",
        "$6.99",
    ],
    key=len,
    reverse=True,
)


def mask(s: str) -> tuple[str, list[str]]:
    vault: list[str] = []
    out = s
    # Placeholders
    out = re.sub(r"%(\d+\$)?[sd]", lambda m: _push(vault, m.group(0)), out)
    out = re.sub(r"\{[a-zA-Z_][a-zA-Z0-9_]*\}", lambda m: _push(vault, m.group(0)), out)
    for pat in PRESERVE:
        out = re.sub(re.escape(pat), lambda m: _push(vault, m.group(0)), out)
    # URLs
    out = re.sub(r"https?://[^\s)]+", lambda m: _push(vault, m.group(0)), out)
    # Phone patterns (keep digits)
    out = re.sub(r"1-800-\d{3}-\d{4}", lambda m: _push(vault, m.group(0)), out)
    return out, vault


def _push(vault: list[str], token: str) -> str:
    vault.append(token)
    return f"⟦{len(vault)-1}⟧"


def unmask(s: str, vault: list[str]) -> str:
    def rep(m):
        i = int(m.group(1))
        return vault[i] if i < len(vault) else m.group(0)

    return re.sub(r"⟦(\d+)⟧", rep, s)


def translate_map(en_miss: dict[str, str], target: str) -> dict[str, str]:
    tr = GoogleTranslator(source="en", target=target)
    out: dict[str, str] = {}
    n = len(en_miss)
    for i, (k, v) in enumerate(en_miss.items(), 1):
        masked, vault = mask(v)
        try:
            t = tr.translate(masked)
            out[k] = unmask(t, vault)
        except Exception as e:
            print("WARN", k, e)
            out[k] = v
        if i % 40 == 0:
            time.sleep(1.2)
        elif i % 8 == 0:
            time.sleep(0.35)
    return out


def main():
    import importlib.util

    spec = importlib.util.spec_from_file_location("merge_l10n", TOOL / "merge_l10n.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    raw = (ROOT / "lib/l10n/strings.dart").read_text(encoding="utf-8")
    en, order = mod.parse_inner(raw, "en", r"\n    \},\n    'pl': \{")
    fr, _ = mod.parse_inner(raw, "fr", r"\n    \},\n    'ru': \{")
    ru, _ = mod.parse_inner(raw, "ru", r"\n    \},\n    'nl': \{")
    nl, _ = mod.parse_inner(raw, "nl", r"\n    \},\n  \};")

    miss_fr = {k: en[k] for k in order if k not in fr}
    miss_ru = {k: en[k] for k in order if k not in ru}
    miss_nl = {k: en[k] for k in order if k not in nl}

    print("fr", len(miss_fr), "ru", len(miss_ru), "nl", len(miss_nl))
    (TOOL / "fr_additions.json").write_text(
        json.dumps(translate_map(miss_fr, "fr"), ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print("wrote fr_additions.json")
    (TOOL / "ru_additions.json").write_text(
        json.dumps(translate_map(miss_ru, "ru"), ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print("wrote ru_additions.json")
    (TOOL / "nl_full.json").write_text(
        json.dumps(translate_map(miss_nl, "nl"), ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print("wrote nl_full.json")


if __name__ == "__main__":
    main()
