# Phase 3 Milestone Ladder (Simulation and Verification)

Roadmap linkage:
- `t81-roadmap#16`
- `t81-roadmap/PHASE3_MILESTONE_MATRIX.md` (`P3-M1`)
- Implementation tracker: `t81-hardware#2`

## Milestone Checklist

- [x] Simulation ladder documented (`lint` -> `sim` -> `parity`).
- [x] Reproducible command path published.
- [x] First reproducible evidence artifact paths documented.
- [x] Software/runtime handoff checkpoint recorded.

## Reproducible Validation Commands

```bash
make vectors
make lint
make sim
make parity
```

## Evidence Artifacts

- Sequential observed trace: `sim/out/t81_seq_observed.tsv`
- Sequential expected trace: `sim/vectors/t81_seq_expected.tsv`
- Sequential program vectors: `sim/vectors/t81_seq_program.tsv`
- Top-level testbench build output: `sim/out/t81_top_tb.vvp`
- Sequential testbench build output: `sim/out/t81_core_seq_tb.vvp`

## Software-Hardware Handoff Checkpoint

Contract touchpoints for downstream runtime/software alignment:

1. ISA/sequence contract source: `interfaces/isa-contract.md`
2. Emulator parity gate: `emulator/rtl_parity.py`
3. Ecosystem mapping for cross-repo handoff: `docs/ecosystem-integration.md`
