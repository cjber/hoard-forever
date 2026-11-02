#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/forever_tools/sync.py check
python3 tools/check_editorconfig.py
python3 tools/check_family.py
python3 tools/check_copy.py docs/curseforge.md README.md
python3 tools/check_locales.py
python3 tools/lint_secret.py
