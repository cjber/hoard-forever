"""Check this addon's dead-code gate against cjber/forever-core main."""

import hashlib
import urllib.error
import urllib.request
from pathlib import Path

PATHS = ("tools/deadcode.py", "tools/deadcode-allow.txt")


def main():
    failures = []
    for path in PATHS:
        try:
            with urllib.request.urlopen(
                f"https://raw.githubusercontent.com/cjber/forever-core/main/{path}", timeout=60
            ) as response:
                expected = response.read()
        except (OSError, urllib.error.URLError, TimeoutError) as error:
            failures.append(f"{path}: could not read core main: {error}")
            continue
        actual = (Path.cwd() / path).read_bytes()
        if actual != expected:
            failures.append(
                f"{path}: consumer {hashlib.sha256(actual).hexdigest()[:12]} "
                f"core {hashlib.sha256(expected).hexdigest()[:12]}"
            )
    if failures:
        raise SystemExit("Vendored files differ from forever-core main:\n  " + "\n  ".join(failures))
    print(f"{len(PATHS)} dead-code gate files match forever-core main.")


if __name__ == "__main__":
    main()
