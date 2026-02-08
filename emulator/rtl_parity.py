#!/usr/bin/env python3
"""Compare emulator-generated expected sequential trace with RTL observed trace."""

from __future__ import annotations

import csv
from pathlib import Path


def load_rows(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="\t")
        return list(reader)


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    expected_path = root / "sim" / "vectors" / "t81_seq_expected.tsv"
    observed_path = root / "sim" / "out" / "t81_seq_observed.tsv"

    expected = load_rows(expected_path)
    observed = load_rows(observed_path)

    if len(expected) != len(observed):
        raise SystemExit(
            f"parity failure: row count mismatch expected={len(expected)} observed={len(observed)}"
        )

    for idx, (exp, obs) in enumerate(zip(expected, observed)):
        if exp != obs:
            raise SystemExit(
                "parity failure at row "
                f"{idx}: expected={exp} observed={obs}"
            )

    print(f"parity ok: {len(expected)} rows match ({expected_path.name} vs {observed_path.name})")


if __name__ == "__main__":
    main()
